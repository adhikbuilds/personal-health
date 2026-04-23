# Personal Health — ML training + production readiness guide

> **Who this is for:** the person who'll own the model pipeline on an in-house server.
>
> **Scope:** how the current scoring model works, what data you have vs. what you need, how to train it on your own hardware, what parameters to pick, and the concrete gates between "research notebook" and "production."
>
> **Reading time:** 20 minutes.

---

## 1. What the model actually does today

There isn't one model — there are two pipelines, and both need different attention.

### 1.1 Pose extraction (vendored, do NOT retrain)
- **What:** MediaPipe Pose Landmarker (`models/pose_landmarker.task`, ~30 MB).
- **Role:** Input video/frames → 33 normalized keypoints per frame (x, y, z, visibility).
- **State:** Google-published, ships as a `.task` file, no retraining needed. Treat as a black box. Only swap if pose quality is visibly bad on Indian body types (v2 concern, not v1).

### 1.2 Form score (the custom model — THIS is what you train)
- **Input:** Per-frame keypoints + sport tag + derived features (joint angles, symmetry index, rep-phase state).
- **Output:** A single form score per rep (0-100) + optional per-joint subscores.
- **Current implementation:** `services/realtime_analyzer.py` + `services/intelligence.py` combine **hand-coded rules** (ideal joint ranges per sport, in `IDEAL_RANGES` in `routes/progress.py`) with a **RandomForest / gradient-boosting fallback** from `pipeline/retrain.py`.
- **Weakness:** The rules do most of the work. The ML model is only used as a tie-breaker. That's fine for v0 but won't scale — every new sport requires hand-tuning ranges.

### 1.3 What you train on

The **form score regressor** — input: features derived from a session. Output: form score (continuous 0-100). Supervised learning.

Labels come from two sources:
- **Synthetic data** — `dataset/generate_real_dataset.py` creates labeled samples by perturbing ideal poses and scoring the distance. Current size: ~10 K samples.
- **Real sessions** — as athletes use the app, sessions flow into `db/sessions.json`. Each session has frames + a hand-rule-derived form score. After enough real sessions (target: 500+), you retrain with real > synthetic mixing.

---

## 2. Data you have vs. data you need

### 2.1 What's on disk today

| Path | Size | Role |
|---|---|---|
| `dataset/training_data.csv` | ~10 K rows | Synthetic labeled features |
| `dataset/sources/synthetic_generated.csv` | ~10 K rows | Pre-engineered features |
| `dataset/research/biomechanical_references.json` | small | Ideal joint ranges per sport (hand-curated) |
| `dataset/research/scoring_rubrics.json` | small | Per-sport rubric weights |
| `db/sessions.json` | 544 sessions | Real sessions (mix of seed + a few real athletes) |
| `db/frames/*.jsonl` | frame streams | Real per-frame keypoints |

### 2.2 What you're missing (for a model worth shipping)

1. **Real labeled sessions — 500 to 2000.** Target split: 100/sport across 8 sports. You have ~30 seeded athletes and 544 sessions, but only a tiny fraction are real-device footage. You'll need a labeling effort (see §4).
2. **Athletes across body types.** Synthetic data is pose-agnostic; real data from tall/short/child athletes is essential. Seeded data is Indian-name-mapped, but the underlying keypoints are simulated.
3. **Video, not just keypoints.** For any future model that looks at *movement*, not just angles (e.g. LSTM over sequences), you need the raw frames. Currently only keypoints land in `db/frames/*.jsonl` — raw video is deleted after ingestion. **Change this** if you want richer models.
4. **Expert-labeled "ground truth" scores.** 50-100 sessions where a real coach gave a form score on paper. This is your test set — don't train on it.

### 2.3 Where to source external data

**Public datasets you can leverage:**

- **Human3.6M** — 3.6M frames, 11 subjects, 15 activities. Great pre-train for pose. [http://vision.imar.ro/human3.6m/](http://vision.imar.ro/human3.6m/) (academic access required)
- **NTU RGB+D 120** — 114,480 videos, 120 action classes. Good for sport-action classification. Free for research.
- **Penn Action Dataset** — 2,326 sports-focused videos, 15 action classes. Most relevant. [http://dreamdragon.github.io/PennAction/](http://dreamdragon.github.io/PennAction/)
- **MPII Human Pose** — 25 K images, 410 activities. Pose-only pre-training.
- **YouTube-8M sports subset** — huge scale but label noise is high.

**Indian-specific — much harder:**
- SAI (Sports Authority of India) — they have internal video archives, but access is political. Worth a formal partnership if you're going commercial.
- Academy video archives (cricket academies, athletics clubs) — direct outreach with a data-use agreement.
- Crowdsource via the app itself — every logged session becomes training data. This is the flywheel.

**What to do first:** you don't need external data to ship v1. Your synthetic + accumulating real sessions are enough to retrain on. But by month 2-3, plan for either a partnership or a paid labeling effort.

---

## 3. Training on your own server

### 3.1 Hardware sizing (honest numbers)

- **Minimum to retrain:** any Linux box with ≥ 16 GB RAM, an 8-core CPU, 100 GB SSD. GPU not required for the current RandomForest / LightGBM setup.
- **For future deep models (LSTM / 1D CNN over keypoint sequences):** one NVIDIA GPU with ≥ 8 GB VRAM (RTX 3060 is enough for v1). 24 GB if you want to train multiple sport-specific heads in parallel.
- **Storage projection:** each real session = ~400 KB of keypoints. 10,000 sessions = ~4 GB. Raw video (if you keep it) = ~50 MB/session → 500 GB at 10K sessions. Budget storage accordingly.

### 3.2 Pipeline commands (current code)

```bash
cd /Users/aagarwal/personal-project/personal-health-backend
. venv/bin/activate

# Step 1 — rebuild training features from sessions.json + synthetic
python pipeline/retrain.py --mode build-features \
    --include-real \
    --min-sessions-per-sport 50 \
    --out dataset/training_data.csv

# Step 2 — train, with cross-validation
python pipeline/retrain.py --mode train \
    --model gbm \
    --target form_score \
    --cv 5 \
    --out models/form_score_v2.pkl

# Step 3 — validate against the held-out expert-labeled set
python dataset/validate_and_report.py \
    --model models/form_score_v2.pkl \
    --test-set dataset/expert_labeled_2026q2.csv \
    --report dataset/reports/form_score_v2.md

# Step 4 — promote (only after quality gate)
python services/model_registry.py promote \
    --model models/form_score_v2.pkl \
    --against-prod models/form_score_v1.pkl \
    --min-improvement 0.05
```

### 3.3 Parameters to pick (first training run)

**For LightGBM / GBM (current default):**
- `num_leaves`: 31 (start). Increase only if training R² < 0.8 AND val R² tracks training within 0.05.
- `learning_rate`: 0.05
- `n_estimators`: 500, with `early_stopping_rounds=30`
- `min_child_samples`: 20
- `objective`: regression_l2
- `metric`: rmse

**For a simple baseline (sanity check):**
- RandomForest with `n_estimators=200`, `max_depth=12`, `min_samples_leaf=5`. If GBM doesn't beat this, something is wrong with your features.

**If moving to deep (v2):**
- 1D CNN or Bi-LSTM over sequence of 30-60 frames.
- Input shape: (seq_len, n_keypoints=33, n_channels=3).
- Use Adam with lr=3e-4, weight_decay=1e-4.
- Augment via temporal jitter (drop random frames) and mirror-flip (50% chance).
- Train with early-stopping on val RMSE, patience 10 epochs.

### 3.4 Split strategy

Critical: **split by athlete_id, not by session**. Otherwise the model memorizes individual movement signatures and the val RMSE lies.

```python
from sklearn.model_selection import GroupKFold
cv = GroupKFold(n_splits=5)
for train_idx, val_idx in cv.split(X, y, groups=df['athlete_id']):
    ...
```

### 3.5 Quality gate (must pass before promoting to production)

From `services/model_registry.py`:

1. **Val RMSE** improves by ≥ 5% vs. the current prod model.
2. **Per-sport** val RMSE: no sport regresses > 10%. If it does, the new model is worse for that sport — don't promote across-the-board; ship per-sport.
3. **Predicted form-score distribution** within ±5 points of the current prod model's mean (prevents one model predicting everyone at 80 and looking "better" but useless).
4. **Inference latency** < 50 ms per rep on a mid-range CPU.

If any gate fails, model stays on the shelf.

### 3.6 Deploying on your server

For the current LightGBM / pickle-based setup:

```bash
# On your server, pull and serve
cd /path/to/personal-health-backend
. venv/bin/activate
python api_server.py  # reads models/form_score_v<latest>.pkl at startup
```

For GPU-served models later:
- TorchServe or NVIDIA Triton — more infra than needed for v1.
- A simpler pattern: a dedicated `inference_worker.py` that loads the model once and consumes from a Redis queue populated by the FastAPI handler. Horizontal scale per sport.

---

## 4. The labeling loop (how you build a real dataset)

Without labeled data you're stuck with synthetic. Here's the cheapest path to a real dataset:

1. **Instrument the app:** every completed session already uploads frames to `db/frames/{session_id}.jsonl`. Good — no change needed.
2. **Build a labeling console** (doesn't exist yet — this is a production gap). A web page where a coach watches a session replay + sees the current model's score + can override it. Stored override → `db/expert_labels.jsonl`.
3. **Recruit 3-5 coaches** (cricket, athletics, football, gym) to label 20 sessions each. Pay per session (₹50-100). Target: 100 labeled sessions in 2 weeks.
4. **Retrain** using labeled data as the gold standard + unlabeled real sessions for semi-supervised.
5. **Active learning** — have the model flag the sessions it's most uncertain about; route those to coaches first. Maximizes label efficiency.

**Cost projection for a labeled dataset:**
- 1000 sessions × ₹80/session = ₹80,000 (~$1000 USD).
- Vs. hiring a single ML engineer for a month = ₹3-5 lakh.
- Labels are the leverage point. Build the console, pay the coaches, collect.

---

## 5. Production-readiness checklist (beyond just the model)

### 5.1 Model serving
- [ ] Models are versioned with semver in `models/`. Current prod tracked in `services/model_registry.py`.
- [ ] Every inference logs the model_version to `db/sessions.json` so you can attribute any regression to a specific model.
- [ ] Rollback in < 5 minutes: keep the previous version on disk, one env var swap + restart.
- [ ] Shadow mode: new model runs alongside prod for 1 week, logs predictions, flags where it disagrees substantially. Only promote after human review.

### 5.2 Data infrastructure
- [ ] Move `db/sessions.json`, `db/athletes.json` from JSON on disk to **Postgres**. Anything > ~500 athletes, JSON is a bottleneck. See `stories/ST-12-postgres-migration.md`.
- [ ] Nightly Postgres dump → S3 bucket with 30-day retention. You can lose prod — you cannot lose the training set.
- [ ] Frame JSONL files — move to S3 with a 90-day lifecycle policy. You don't need them hot after training.

### 5.3 Monitoring
- [ ] APM (Sentry / Datadog / self-hosted Grafana) for the FastAPI backend. Current `logging_setup.py` is text logs to stdout — fine for dev, not for prod.
- [ ] Alert on: model latency > 100 ms p99, inference error rate > 1%, form-score distribution shift (KL divergence against a rolling baseline).
- [ ] Dashboard showing the form-score distribution per sport per day. If cricket suddenly averages 20 below baseline, something's wrong with pose extraction.

### 5.4 Trust + compliance
- [ ] DPDP consent recorded per athlete (already wired on `POST /auth/accept-disclaimer`).
- [ ] Injury-risk warnings must be human-reviewed before showing. Never let the ML alone say "you are injured."
- [ ] Privacy policy + terms of service pages — see `stories/` (Legal epic, not yet split).

### 5.5 Feedback loop
- [ ] Every session's form score has a "was this accurate?" one-tap feedback button for the athlete. Zero friction.
- [ ] Store responses in `db/athlete_feedback.jsonl`. Weekly review.
- [ ] Coaches get a weekly email summarizing "10 sessions where the model disagreed most with the coach's historical feedback" — turns feedback into labels.

---

## 6. What to do this week (concrete next steps)

1. **Decide on a server.** Any Linux box with 16 GB RAM is enough for v1. If on cloud, prefer `ap-south-1` (Mumbai) for DPDP data residency.
2. **Pull the repo.** Your `pipeline/retrain.py` already works end-to-end on synthetic data. Run it once. Make sure it finishes without errors.
3. **Commit a training run.** Run `python pipeline/retrain.py --mode train` and save the output. That's your v1 baseline.
4. **Build a bare-bones labeling console.** Even a Jupyter notebook where you can page through sessions, watch the keypoint replay, and type a score 0-100 is enough. 100 labeled sessions is the minimum viable training set.
5. **Promote only after quality gate passes.** Don't ship a model that regresses on any sport.

---

## 7. What to read (in priority order)

1. Google's MediaPipe Pose docs — understand the 33 keypoints and their reliability flags.
2. Google's Movenet paper (alternative pose model, might be worth swapping in).
3. "Sports Biomechanics Analysis Using Computer Vision" — survey paper, gives vocabulary.
4. The `dataset/research/biomechanical_references.json` file in your repo — the hand-curated rules encode domain knowledge. Read them before you train; you'll find features to add.

---

## 8. What NOT to do

- Don't try to train a general "perfect form" model. Sport-specific heads beat a single big model every time.
- Don't trust synthetic data alone past v1. It will overfit to the perturbation function you used to generate it.
- Don't ship a model that "feels better" without a quality gate. Every regression is a churned athlete.
- Don't retrain weekly. Monthly with clear versioning + 1-week shadow mode is better than chasing noise.
- Don't put the ML model in the critical path for notifications (PBs, injury warnings). The hand-rules in `routes/progress.py` are your safety net.

---

**Questions this guide doesn't answer:**
- Cloud vs. on-prem ML infra for v2 — depends on traffic. Ask again at 10K DAU.
- Whether to use TensorFlow Lite for on-device inference — already scaffolded (`models/*.tflite`), worth exploring once the server model stabilizes.
- Federated learning for privacy — 2027 concern, not now.

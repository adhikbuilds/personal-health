# Sprint: Personal Fitness — Production Readiness

**Lead:** Adhik Agarwal + Raj Shukla
**Assignee:** Claude Code (buddy agent)
**Repo:** https://github.com/adhikbuilds/ (backend, frontend, android)
**Branch:** `develop` — all work goes here
**Duration:** 7–13 Apr 2026

---

## Context — What This Is

Personal Health is a phone-first sports biomechanics AI platform. Athletes train using their phone camera; the app grades their form in real-time, tracks heart rate via rPPG, and over time trains a model on real session data.

The **Personal Fitness** domain is the core — pose analysis, form scoring, heart rate, session tracking, coaching intelligence, ML pipeline. The code exists and mostly works, but has critical bugs, data leakage in the model, hardcoded assumptions, and missing production safeguards.

This sprint is about making it **production-ready** — not adding new features, but fixing what's broken, removing what's wrong, and hardening what's fragile.

---

## Problem Statement

> I am a young athlete (17–28) training 4–5 times a week without a personal coach.
> I'm trying to use an AI app to grade my form and track my progress over time.
> But the app gives me jump height estimates based on a hardcoded 170cm body height (I'm 158cm), the form scoring model was trained with data leakage so I can't trust the scores, and there's no rate limiting so the server crashes when 10 athletes stream simultaneously.
> Because the system was built for demo, not production — and nobody audited the pipeline for real-world deployment.
> Which makes me feel like the scores are meaningless and the app is a toy, not a tool.

---

## Jobs-to-be-Done (Fitness Domain)

### Functional Jobs
- **Get accurate form feedback** — not approximate, not based on wrong body measurements
- **See my progress over time** — trend that's real, not inflated by model bugs
- **Train without the server crashing** — system stays up when 10+ athletes use it simultaneously
- **Know my jump height** — calibrated to MY body, not a generic 170cm human

### Emotional Jobs
- **Trust the score** — if the app says 78, I believe it's 78, not a random number
- **Feel safe** — if my form is degrading toward injury, the app warns me before I get hurt

### Social Jobs
- **Show my coach real data** — numbers that a coach would validate, not dismiss as "app nonsense"

---

## What Exists Today (Current State)

| Component | Status | Key Issue |
|-----------|--------|-----------|
| `services/pose_analyzer.py` (688 lines) | Works | Body height hardcoded to 170cm; phase detection only for 3/8 sports |
| `services/rppg_processor.py` (287 lines) | Works | No server-side face validation; SNR thresholds untuned |
| `services/intelligence.py` (290 lines) | Works | Rule-based only; tier thresholds not tuned to real population |
| `services/feature_extractor.py` (261 lines) | **BROKEN** | **form_score included as input feature = data leakage** |
| `pipeline/model_trainer.py` (341 lines) | Works | 98.6% accuracy but inflated due to data leakage; 100% synthetic data |
| `pipeline/generate_dataset.py` (503 lines) | Works | No temporal coherence between frames; no injury patterns |
| `routes/fitness.py` (601 lines) | Works | No rate limiting; frames dropped silently at queue=50; no auth |
| `services/realtime_analyzer.py` (368 lines) | Dev-only | Desktop tool, not integrated with API |

### The 5 Critical Issues

1. **Data Leakage** — `feature_extractor.py` includes `form_score` as an input feature. The model is predicting the answer using the answer. Reported 98.6% accuracy is fake.
2. **Hardcoded Body Height** — `pose_analyzer.py` line 539 assumes every athlete is 170cm. Jump height estimates are wrong for anyone else.
3. **No Rate Limiting** — 10 athletes streaming 30fps = 300 frames/sec. Server will OOM.
4. **No Model Monitoring** — Can't detect if model accuracy degrades on real athletes.
5. **Synthetic-Only Training** — Zero real athlete data in model. Domain gap unknown.

---

## User Stories — Prioritized

---

### P0 — Must Fix (Ship-Blocking Bugs)

---

#### PF-01: Fix Data Leakage in Feature Extractor

**As a** product owner trusting the ML pipeline,
**I want** the feature extractor to exclude form_score from the input feature vector,
**so that** the model learns from actual biomechanics, not from the label it's predicting.

**Acceptance Criteria:**
- **Given** `services/feature_extractor.py` currently includes `form_score` in the 23-feature vector
- **When** the fix is applied
- **Then** `form_score` is removed from `FEATURE_NAMES` and `frame_to_vector()`
- **And** the feature vector is now 22 dimensions (not 23)
- **And** `NORM_RANGES` no longer has a `form_score` entry
- **And** `get_csv_headers()` returns 22 feature columns + label columns
- **And** `dataset/dataset_schema.md` is updated to reflect 22 features
- **And** a comment is added explaining why form_score is excluded

**Tech notes:**
- File: `services/feature_extractor.py` lines 82-83
- After this fix, PF-02 (retrain model) must run

---

#### PF-02: Retrain Model Without Data Leakage

**As a** product owner,
**I want** the ML model retrained on the corrected 22-feature vector,
**so that** the reported accuracy reflects real predictive power, not leakage.

**Acceptance Criteria:**
- **Given** PF-01 is complete (form_score removed from features)
- **When** `python pipeline/generate_dataset.py` is run
- **Then** `dataset/training_data.csv` has 22 feature columns (not 23)
- **And** `python pipeline/model_trainer.py` trains successfully on the new dataset
- **And** `models/pose_classifier.h5` and `models/pose_classifier.tflite` are regenerated
- **And** `models/norm_params.json` has 22 entries (not 23)
- **And** `models/training_metrics.json` records the new accuracy (expected: 85-92%, down from fake 98.6%)
- **And** the accuracy drop is documented in a comment in `model_trainer.py`

**Tech notes:**
- Blocked by PF-01
- Expected accuracy drop is healthy — it means the model is now learning real patterns

---

#### PF-03: Add Body Height to Athlete Profile + Pose Analyzer

**As an** athlete who is 158cm tall,
**I want** the app to use my actual height for jump height calculations,
**so that** my jump height estimates are accurate, not based on a generic 170cm assumption.

**Acceptance Criteria:**
- **Given** `services/pose_analyzer.py` line 539 hardcodes `body_height_cm = 170`
- **When** the fix is applied
- **Then** `PoseAnalyzer.__init__()` accepts an optional `body_height_cm` parameter (default 170)
- **And** `routes/fitness.py` passes athlete's height from `ATHLETE_DB[athlete_id].get("height_cm", 170)` when creating PoseAnalyzer
- **And** `database.py` athlete schema supports `height_cm` field
- **And** the `POST /athlete` endpoint accepts optional `height_cm` in `NewAthleteRequest`
- **And** `seed_athletes.py` generates heights between 155-190cm (normal distribution, mean 170, std 8)
- **And** jump height estimates in session summaries use the athlete's actual height

**Tech notes:**
- File: `services/pose_analyzer.py`, `routes/fitness.py`, `routes/athletes.py`, `database.py`
- The height is used in CoM (center of mass) normalization and jump height estimation

---

#### PF-04: Add Rate Limiting on Frame Ingestion

**As a** system running 10+ concurrent athlete sessions,
**I want** per-session frame rate limiting,
**so that** the server doesn't OOM or drop frames silently.

**Acceptance Criteria:**
- **Given** `routes/fitness.py` `/session/{id}/frame` endpoint currently accepts unlimited frames
- **When** rate limiting is added
- **Then** each session is limited to max 10 frames/second (configurable)
- **And** frames exceeding the limit return 429 with `{"error": "Rate limit exceeded", "max_fps": 10}`
- **And** the analysis queue size is increased from 50 to 200
- **And** when queue is full, response includes `{"warning": "Analysis queue full, frame stored but not analyzed"}`
- **And** a `_RATE_LIMITS` dict in `database.py` tracks `{session_id: last_frame_timestamp}`
- **And** rate limit is cleaned up when session ends

**Tech notes:**
- Simple token bucket: track last frame timestamp per session, reject if < 100ms gap
- Don't use external libraries — keep it in-process

---

### P1 — Should Fix (Production Quality)

---

#### PF-05: Add Phase Detection for All 8 Sports

**As an** athlete doing sprint drills or javelin throws,
**I want** the app to detect my movement phases correctly,
**so that** phase-specific feedback makes sense for my sport.

**Acceptance Criteria:**
- **Given** `services/pose_analyzer.py` only implements phase detection for vertical_jump, squat, snatch
- **When** phase detection is extended
- **Then** all 8 sports have phase classification: vertical_jump, sprint, squat, push_up, pull_up, snatch, javelin, cricket_bat
- **And** each sport has at least 3 distinct phases defined
- **And** phase transitions use the existing heuristic approach (knee angle + CoM velocity thresholds)
- **And** the `SPORT_IDEAL_ANGLES` dict is verified to have entries for all 8 sports
- **And** unknown sports default to a generic 3-phase cycle (ready/active/recovery)

**Phase definitions per sport:**
- **sprint:** start / acceleration / max_velocity / deceleration
- **push_up:** up / descent / bottom / ascent
- **pull_up:** hang / pull / top / descent
- **javelin:** approach / crossover / delivery / follow_through
- **cricket_bat:** stance / backswing / downswing / follow_through

---

#### PF-06: Add Temporal Smoothing to Form Score

**As an** athlete watching my live form score,
**I want** the score to be smooth and stable,
**so that** a single bad frame doesn't cause my score to spike from 80 to 30 and back.

**Acceptance Criteria:**
- **Given** `services/pose_analyzer.py` computes form_score per-frame with no smoothing
- **When** temporal smoothing is added
- **Then** form_score uses an exponential moving average (EMA) with alpha=0.3
- **And** the smoothed score is stored in `BiomechanicalFrame.form_score`
- **And** the raw (unsmoothed) score is available as `BiomechanicalFrame.raw_form_score`
- **And** smoothing resets when a new session starts (not carried between sessions)
- **And** the first frame of a session uses raw score (no history to smooth against)

---

#### PF-07: Add Injury Risk Flags Based on Asymmetry

**As a** coach monitoring my athletes,
**I want** the system to flag when an athlete's left-right asymmetry exceeds safe thresholds,
**so that** I can intervene before a preventable injury.

**Acceptance Criteria:**
- **Given** `services/pose_analyzer.py` computes `limb_symmetry_idx` (0-1 scale)
- **When** injury risk detection is added
- **Then** if symmetry_idx < 0.80 for 3+ consecutive frames, flag as `"asymmetry_warning"`
- **And** if symmetry_idx < 0.70 for any frame, flag as `"asymmetry_critical"`
- **And** flags are included in the frame analysis result sent via WebSocket
- **And** flags are included in the session summary under `"injury_flags": [...]`
- **And** `services/intelligence.py` AnomalyDetector checks for asymmetry flags in session history
- **And** the `/athlete/{id}/insights` response includes `"injury_risk_factors": [...]`

---

#### PF-08: Add Model Prediction Logging

**As a** product owner monitoring model quality,
**I want** every model prediction logged with input features and output,
**so that** I can detect accuracy drift when real athletes start using the app.

**Acceptance Criteria:**
- **Given** `routes/fitness.py` analysis_worker runs MediaPipe and produces form scores
- **When** prediction logging is added
- **Then** each prediction is appended to `db/predictions.jsonl` (one JSON line per prediction)
- **And** each log entry contains: `session_id`, `frame_num`, `timestamp`, `sport`, `form_score`, `form_quality`, `phase`, `symmetry_idx`
- **And** the log file rotates daily (max 7 days retained)
- **And** a new endpoint `GET /model/stats` returns: total predictions today, avg form_score, quality distribution, prediction count by sport
- **And** logging does not block the analysis worker (fire-and-forget append)

---

#### PF-09: Validate rPPG Signal Source

**As an** athlete measuring heart rate,
**I want** the server to reject invalid RGB signals,
**so that** I don't get fake BPM readings from a camera pointed at the ceiling.

**Acceptance Criteria:**
- **Given** `services/rppg_processor.py` accepts any R, G, B values without validation
- **When** signal validation is added
- **Then** if R, G, B are all < 10 or all > 245 (too dark or blown out), return `{"signal_quality": "invalid", "message": "Adjust lighting"}`
- **And** if R, G, B variance over 20 frames is < 0.5 (flat signal = not skin), return `{"signal_quality": "no_pulse", "message": "Ensure face is visible"}`
- **And** if computed BPM changes by > 40 BPM between consecutive readings, flag as `"artifact"` and hold previous BPM
- **And** these checks are in `rppg_processor.py`, not in the route handler

---

### P2 — Nice to Have (Next Sprint Candidates)

---

#### PF-10: Per-Sport Model Variants

**As a** sprint athlete,
**I want** the ML model to be trained specifically on sprint biomechanics,
**so that** my form score reflects sprint technique, not vertical jump criteria.

**Acceptance Criteria:**
- **Given** `pipeline/model_trainer.py` trains one model for all sports
- **When** per-sport training is added
- **Then** `model_trainer.py` accepts a `--sport` flag to train on a single sport
- **And** models are saved as `models/pose_classifier_{sport}.tflite`
- **And** `routes/fitness.py` loads the sport-specific model when creating PoseAnalyzer
- **And** fallback to the generic model if sport-specific model doesn't exist

---

#### PF-11: Temporal Coherence in Synthetic Dataset

**As a** ML engineer retraining the model,
**I want** synthetic training data to have realistic frame-to-frame transitions,
**so that** the model learns temporal patterns, not just per-frame snapshots.

**Acceptance Criteria:**
- **Given** `pipeline/generate_dataset.py` generates each frame independently
- **When** temporal coherence is added
- **Then** frames are generated in sequences of 30 (1 second at 30fps)
- **And** within a sequence, joint angles change smoothly (max 5° per frame)
- **And** phases progress in order (setup → descent → takeoff → flight → landing)
- **And** form_score within a sequence varies by max 5 points (simulating consistent effort)
- **And** a `sequence_id` column is added to the CSV

---

#### PF-12: Session Frame Persistence to Disk

**As a** product owner,
**I want** session frames to be saved to disk, not just kept in memory,
**so that** server restarts don't lose in-progress session data.

**Acceptance Criteria:**
- **Given** `FRAME_BUFFER` is an in-memory dict that's lost on restart
- **When** frame persistence is added
- **Then** frames are written to `db/frames/{session_id}.jsonl` (append-only, one JSON line per frame)
- **And** on server restart, active sessions' frames are reloaded from disk
- **And** frame files are deleted 24 hours after session ends (cleanup cron)
- **And** the `/session/{id}/end` summary computation reads from disk if memory buffer is empty

---

#### PF-13: Multi-Person Detection Guard

**As an** athlete training with a partner nearby,
**I want** the app to warn me if multiple people are in frame,
**so that** pose analysis doesn't confuse my skeleton with someone else's.

**Acceptance Criteria:**
- **Given** MediaPipe detects the most prominent person but doesn't warn about others
- **When** multi-person detection is added
- **Then** if MediaPipe confidence for the primary detection drops below 0.6 AND a second person is partially visible, return `"warning": "Multiple people detected — ensure only you are in frame"`
- **And** the warning is included in the frame result but analysis still proceeds on the primary detection

---

## Story Index

| ID | Title | Priority | Blocked By | Effort |
|----|-------|----------|------------|--------|
| PF-01 | Fix data leakage in feature extractor | P0 | — | 1 hr |
| PF-02 | Retrain model without data leakage | P0 | PF-01 | 1 hr |
| PF-03 | Add body height to athlete profile | P0 | — | 2 hr |
| PF-04 | Add rate limiting on frame ingestion | P0 | — | 1 hr |
| PF-05 | Phase detection for all 8 sports | P1 | — | 3 hr |
| PF-06 | Temporal smoothing on form score | P1 | — | 1 hr |
| PF-07 | Injury risk flags (asymmetry) | P1 | — | 2 hr |
| PF-08 | Model prediction logging | P1 | — | 2 hr |
| PF-09 | Validate rPPG signal source | P1 | — | 1 hr |
| PF-10 | Per-sport model variants | P2 | PF-01, PF-02 | 4 hr |
| PF-11 | Temporal coherence in synthetic data | P2 | — | 3 hr |
| PF-12 | Session frame persistence to disk | P2 | — | 3 hr |
| PF-13 | Multi-person detection guard | P2 | — | 2 hr |

**Backend Total: 4 P0s, 5 P1s, 4 P2s = 13 stories**

---

## Frontend Stories (personal-health-frontend)

**Repo:** https://github.com/adhikbuilds/personal-health-frontend.git
**Branch:** `develop`
**Stack:** Node.js, Express, EJS, Chart.js

---

### P0 — Must Fix

---

#### FE-01: Create wellness.ejs Placeholder Page

**As a** user clicking "Wellness" in the navigation,
**I want** to see a proper placeholder page instead of a 404 error,
**so that** the app feels complete even while the wellness module is under development.

**Acceptance Criteria:**
- **Given** server.js has a `/wellness` route but `views/wellness.ejs` doesn't exist
- **When** the page is created
- **Then** `views/wellness.ejs` renders with the same sidebar as dashboard.ejs (Overview, Dashboard, Wellness highlighted, Map)
- **And** the page shows a centered card with title "Wellness Dashboard" and message "Coming soon — nutrition tracking, sleep analysis, and recovery scoring are being built by the team."
- **And** a link back to /dashboard is included
- **And** the page uses the project dark theme: bg `#0a0e1a`, cards `#111827`, accent `#06b6d4`, text `#f1f5f9`
- **And** `public/css/wellness.css` is created with matching styles
- **And** `node -c server.js` passes without errors

---

#### FE-02: Remove All Emoji Icons from Landing Page

**As a** user viewing the landing page,
**I want** professional SVG icons instead of emoji characters,
**so that** the app looks production-grade, not like a prototype.

**Acceptance Criteria:**
- **Given** `views/index.ejs` may still have emoji characters used as structural icons
- **When** the fix is applied
- **Then** all feature card icons use inline SVG (stroke-based, color `#06b6d4`)
- **And** no `📐`, `❤️`, `📊`, `🏠`, `📷`, or similar emoji appear as UI elements in any `.ejs` file
- **And** emojis in user-generated content or data (like social posts) are acceptable — only structural UI icons must be SVG

---

#### FE-03: Verify No Hardcoded IPs in Frontend Views

**As a** developer deploying the app,
**I want** zero hardcoded IPs in any view template,
**so that** the app works on any network without code changes.

**Acceptance Criteria:**
- **Given** all `.ejs` files in `views/`
- **When** scanned for hardcoded IPs
- **Then** no file contains `192.168.`, `10.0.`, `127.0.0.1`, or `localhost:8082`
- **And** server.js may reference `FASTAPI_HOST` from env (that's fine — it's config, not hardcoded)
- **And** all API calls in views use relative paths (`/api/...`) or `window.AB_CONFIG.API_BASE`

---

### P1 — Should Fix

---

#### FE-04: Fix Dashboard to Auto-Connect to Live Sessions

**As a** coach opening the dashboard,
**I want** the dashboard to automatically show live metrics when an athlete starts a session on the app,
**so that** I don't have to manually start a session from the web to see real-time data.

**Acceptance Criteria:**
- **Given** the dashboard polls `/sessions/active` every 10 seconds
- **When** an active session is detected
- **Then** the Live Metrics card appears automatically (no manual Start button needed)
- **And** the dashboard connects to the WebSocket for that session's live metrics
- **And** when the session ends, the Live Metrics card hides and recent sessions refresh
- **And** there is no "Start Session" or "Stop" button on the web dashboard (sessions are phone-only)
- **And** the sport dropdown selector is removed (not needed for monitoring)

---

#### FE-05: Add Color-Coded Form Scores in Sessions Table

**As a** coach reviewing recent sessions,
**I want** form scores to be color-coded (green/yellow/red),
**so that** I can instantly spot which sessions had good vs poor form.

**Acceptance Criteria:**
- **Given** the Recent Sessions table shows avg form scores
- **When** scores are rendered
- **Then** scores >= 75 are green (`#22c55e`)
- **And** scores 55-74 are yellow (`#f59e0b`)
- **And** scores < 55 are red (`#ef4444`)
- **And** null/missing scores show `—` in gray (`#64748b`)

---

#### FE-06: Replace "AI Model" Stat Card with "Avg Form Score"

**As a** coach looking at the stats row,
**I want** to see average form score across recent sessions instead of "AI Model: Ready/Not trained",
**so that** I see actionable data, not developer status.

**Acceptance Criteria:**
- **Given** the dashboard stats row has 4 cards
- **When** the 4th card is updated
- **Then** it shows "Avg Form Score" label with the average of the last 20 completed sessions' form scores
- **And** the value is rounded to 1 decimal place
- **And** if no completed sessions exist, it shows `—`

---

## Frontend Story Index

| ID | Title | Priority | Effort |
|----|-------|----------|--------|
| FE-01 | Create wellness.ejs placeholder | P0 | 30 min |
| FE-02 | Remove emoji icons from landing | P0 | 15 min |
| FE-03 | Verify no hardcoded IPs | P0 | 10 min |
| FE-04 | Dashboard auto-connect live sessions | P1 | 30 min |
| FE-05 | Color-coded form scores | P1 | 15 min |
| FE-06 | Replace AI Model stat with Avg Form Score | P1 | 15 min |

---

## Android Stories (personal-health-android)

**Repo:** https://github.com/adhikbuilds/personal-health-android.git
**Branch:** `develop`
**Stack:** React Native, Expo SDK 54, React Navigation 6

---

### P0 — Must Fix

---

#### AN-01: Fix ActiveBharat Branding in App.js and Screens

**As a** user opening the app,
**I want** to see "Personal Health" branding everywhere,
**so that** the app identity is consistent and correct.

**Acceptance Criteria:**
- **Given** App.js line 1 comment says "ActiveBharat"
- **When** branding is fixed
- **Then** all references to "ActiveBharat", "active_bharat", "Eklavya" in App.js and all screen files are replaced with "Personal Health"
- **And** grep -ri "activebharat\|eklavya" src/ App.js returns no results

---

#### AN-02: Verify All Screen Imports in App.js

**As a** developer pulling the code,
**I want** App.js to import all screens from the correct domain folder paths,
**so that** the app doesn't crash on launch.

**Acceptance Criteria:**
- **Given** screens were moved from flat `src/screens/` to domain folders
- **When** App.js is checked
- **Then** every import path in App.js points to a file that actually exists:
  - `./src/screens/core/HomeScreen` exists
  - `./src/screens/core/MetricsScreen` exists
  - `./src/screens/core/AcademyScreen` exists
  - `./src/screens/core/HubScreen` exists
  - `./src/screens/fitness/TrainScreen` exists
  - `./src/screens/fitness/GhostSkeletonScreen` exists
  - `./src/screens/fitness/RPPGScreen` exists
  - `./src/screens/fitness/FitnessTestScreen` exists
  - `./src/screens/social/MapScreen` exists
  - `./src/screens/social/FieldBookingScreen` exists
  - `./src/screens/social/LearnSportsScreen` exists
  - `./src/screens/social/GetActiveScreen` exists
  - `./src/screens/social/ClassesScreen` exists
  - `./src/screens/social/SocialFeedScreen` exists
- **And** no old flat imports like `./src/screens/HomeScreen` exist in App.js
- **And** no .js files remain at `src/screens/` root level (all must be in subdirectories)

---

#### AN-03: Verify No Hardcoded IPs in Source

**As a** developer running the app on a different network,
**I want** zero hardcoded IPs in the source code,
**so that** the app connects to the backend via configuration, not hardcoded addresses.

**Acceptance Criteria:**
- **Given** all `.js` files in `src/`
- **When** scanned for hardcoded IPs
- **Then** no file contains `192.168.`, `10.0.2.2`, `127.0.0.1`, or `localhost:8082`
- **And** `src/constants.js` reads `BACKEND_HOST` from `app.json` extra config
- **And** `src/services/api.js` uses `BACKEND_HOST` from constants, not hardcoded URLs

---

### P1 — Should Fix

---

#### AN-04: Replace Emoji Tab Icons with Vector Icons

**As a** user navigating the app,
**I want** professional vector icons in the tab bar instead of emojis,
**so that** the app looks polished and renders consistently across all Android devices.

**Acceptance Criteria:**
- **Given** App.js `TAB_ICONS` dict uses emojis: `🏠`, `📊`, `📷`, `📚`, `👤`, `🗺️`
- **When** icons are updated
- **Then** TAB_ICONS uses `@expo/vector-icons` (Ionicons or MaterialCommunityIcons — already in Expo)
- **And** the tab bar renders vector icons that scale cleanly and match the cyan accent color when active
- **And** no emoji characters remain as navigation or structural UI elements in App.js
- **And** emojis in content (social posts, class thumbnails) are acceptable

**Implementation hint:**
```jsx
import { Ionicons } from '@expo/vector-icons';
// Then in tabBarIcon: <Ionicons name={iconName} size={22} color={focused ? '#06b6d4' : '#64748b'} />
```

---

#### AN-05: Add Wellness Placeholder in Content Grid

**As an** athlete on the HomeScreen,
**I want** a "Wellness" tile in the content grid that navigates to a coming-soon screen,
**so that** I know the feature is being built and will be available soon.

**Acceptance Criteria:**
- **Given** HomeScreen has a content grid with tiles (Fitness Test, Learn Sports, Get Active, etc.)
- **When** a Wellness tile is added
- **Then** a tile labeled "Wellness" appears in the content grid with a health/heart vector icon
- **And** tapping it navigates to a simple WellnessPlaceholderScreen in `src/screens/wellness/`
- **And** the placeholder screen shows: "Wellness — Coming Soon" with a back button
- **And** the placeholder screen follows the dark theme
- **And** App.js registers the new screen in the Stack navigator
- **And** the screen file is at `src/screens/wellness/WellnessPlaceholderScreen.js`

---

## Android Story Index

| ID | Title | Priority | Effort |
|----|-------|----------|--------|
| AN-01 | Fix ActiveBharat branding | P0 | 15 min |
| AN-02 | Verify all screen imports | P0 | 15 min |
| AN-03 | Verify no hardcoded IPs | P0 | 10 min |
| AN-04 | Replace emoji tab icons with vector icons | P1 | 30 min |
| AN-05 | Add wellness placeholder tile + screen | P1 | 30 min |

---

## Full Sprint Summary

| Layer | P0 | P1 | P2 | Total |
|-------|----|----|-------|-------|
| Backend | 4 | 5 | 4 | 13 |
| Frontend | 3 | 3 | 0 | 6 |
| Android | 3 | 2 | 0 | 5 |
| **Total** | **10** | **10** | **4** | **24 stories** |

---

## Rules for the Buddy Agent

1. **Only push to `develop` branch** on repos under `https://github.com/adhikbuilds/`
2. **Read the file before editing** — always
3. **Run ruff check + ruff format** before committing any Python changes
4. **All JSON writes use `_save_db()` or `_save_json()`** from `database.py` — never raw `json.dump`
5. **No hardcoded IPs** — no `192.168.*`, no `localhost:8082` in source
6. **Test imports on Python 3.9** — the venv uses 3.9, use `Optional[str]` not `str | None` in FastAPI function signatures and Pydantic models
7. **Don't touch wellness domain** — interns are working there. Stay in `routes/fitness.py`, `services/`, `pipeline/`
8. **Commit per story** — one commit per PF-XX, with story ID in commit message

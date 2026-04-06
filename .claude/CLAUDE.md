# Personal Health — Claude Code Project Instructions

## What this project is

A phone-first sports biomechanics AI platform. Athletes train using their phone camera; the app grades their form in real-time, tracks heart rate via rPPG, and over time trains a model on real session data. Three layers: Data (collection), Intelligence (model), Generative (AI coach).

## Stack at a glance

| Layer | Tech |
|-------|------|
| Android app | React Native, Expo SDK 54, expo-camera |
| Backend API | FastAPI (Python), MediaPipe, TensorFlow |
| Frontend | Node.js, Express, EJS, port 8083 |
| Database | JSON files in `db/` (sessions.json, athletes.json) |
| ML pipeline | `generate_dataset.py` → `model_trainer.py` → `.tflite` |

Key files:
- `personal-health-backend/api_server.py` — main API, all endpoints
- `personal-health-backend/pose_analyzer.py` — MediaPipe wrapper
- `personal-health-backend/rppg_processor.py` — heart rate from camera
- `personal-health-android/src/constants.js` — backend host config (set via `app.json`)
- `personal-health-frontend/server.js` — Express + proxy setup
- `VISION.md` — full product vision, layers, GTM, milestones

## Coding rules

- No hardcoded IPs anywhere. Frontend uses relative `/api` paths. Android reads `BACKEND_HOST` from `app.json extra.backendHost`.
- No "ActiveBharat" branding anywhere — this is "Personal Health" throughout.
- Dashboard and UI: single accent colour `#06b6d4`, dark theme `#0a0e1a` / `#111827`, no random multi-colour variants.
- API data keys: `/leaderboard` returns `data.leaderboard[]`, `/athletes` returns `{athletes:[], total:N}`, `/sessions/active` returns `{active_sessions:[]}`.
- Backend sessions use async analysis queue — never block the HTTP response waiting for MediaPipe.
- All writes to `db/*.json` go through `_save_db()` in `api_server.py`.

## PM Skills available

This project has access to structured product management frameworks from the `Product-Manager-Skills` library. When working on product decisions, features, or user research, use these skills:

### Use `jobs-to-be-done` when:
- A new feature is proposed — ask "what job is the athlete hiring this for?"
- Deciding between two implementations
- Writing any user-facing copy

**Core JTBD for this product:**
- Athlete: "Help me improve my form without a coach standing next to me"
- Athlete: "Show me I'm getting better over time, not just grinding"
- Coach: "Let me see how my athletes are doing when I'm not there"
- Parent: "Tell me if my kid is training safely and not getting injured"

### Use `proto-persona` when:
- Designing any new screen
- Writing marketing copy or ad hooks
- Scoping a feature (who is it for?)

**Current personas:**
1. **Aspiring club athlete, 17–24** — trains 4–5x/week, no personal coach, motivated by leaderboard + improvement trend, shares on Instagram
2. **State-level athlete, 20–28** — already has a coach but uses app for self-monitoring between sessions, cares about precise angle data
3. **Sports coach, 28–45** — runs sessions with 15–30 athletes, wants remote visibility, not technical, judges by whether athletes improve

### Use `problem-statement` when:
- Starting any new feature sprint
- Writing a PRD section
- Briefing a design

**Canonical problem statement:**
> Athletes who train without a coach have no way to know if their form is improving or deteriorating between sessions, which leads to ingrained bad habits, plateau, and preventable injury — yet the tools that solve this (biomechanics labs, personal coaches) are inaccessible to 99% of athletes by cost and geography.

### Use `prd-development` when:
- A feature is big enough to need sign-off before building
- You need to define acceptance criteria
- Coordinating work across Android + backend + frontend

### Use `opportunity-solution-tree` when:
- There are multiple ways to solve the same athlete problem
- Prioritising backlog items
- Deciding what NOT to build

### Use `positioning-statement` when:
- Writing ad copy
- Describing the product to a new user
- Writing app store description

**Draft positioning:**
> For athletes who train without a personal coach, Personal Health is a phone-first biomechanics platform that grades your form in real-time and tells you exactly what to fix — so every session makes you measurably better, not just tired.

### Use `roadmap-planning` when:
- Planning sprint work
- Communicating priorities to interns
- Deciding what milestone to target next

**Current milestones (from VISION.md):**
1. Working demo — app → form score in <60s
2. First huddle — 15+ athletes, 150+ sessions
3. First retrain — 500+ real sessions, model beats synthetic baseline
4. First coaching note — LLM + session summary integration
5. First revenue — ₹199/mo subscription live

## Agent shortcuts

Three specialist agents are available in `.claude/agents/`:

- `/agent:security-scanner` — run a full SAST audit across the codebase
- `/agent:unit-tests-bot` — generate unit tests for any module
- `/agent:git-commit-bot` — write a conventional commit message and push

## When generating code

1. Read the file before editing it.
2. Check `api_server.py` endpoint response shapes before writing frontend JS that consumes them.
3. For any new Android screen: copy the pattern from `TrainScreen.js` — it has the correct `expo-camera` + WebSocket + cleanup pattern.
4. For new backend endpoints: add them inside the `if FASTAPI_AVAILABLE:` block, follow the existing response shape conventions.
5. Run `seed_athletes.py` then `seed_sessions.py` after any `db/*.json` reset.

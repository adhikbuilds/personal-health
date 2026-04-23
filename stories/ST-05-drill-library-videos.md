# ST-05 — Drill library with looping form videos

**Size:** 🔨 M (1-2 days dev + content production in parallel) · **Persona:** All athletes · **Phase:** Pre-session drill pick

## Problem

`DrillPickerScreen` and `OnboardingScreen` step 1 show drills as text tiles ("Sprint", "Vertical Jump"). A new athlete doesn't know what "correct form" looks like, so the first-session grade is noisy (athlete does the wrong movement, gets scored badly, churns).

## Target state

Each drill tile has a 3-second looping silent video of correct form. Tap the tile → full-screen video with "do 3 reps like this" + "start" button. Source videos are shot on turf/outdoors (not in a studio gym).

## Acceptance criteria

- [ ] New `public/drill-videos/` directory in `personal-health-backend/` (or an S3/CDN path if you have one).
- [ ] Backend endpoint `GET /drills/catalog` that returns `[{ key, label, sport, video_url, thumbnail_url, duration_ms, cues[] }, ...]`. Videos < 500 KB each (WebM, 480p, 3 seconds).
- [ ] `DrillCatalog` service in Android + web that caches the response.
- [ ] Android `DrillPickerScreen`:
  - Each tile plays its 3-sec clip in a muted, auto-playing loop (use `expo-video`, which is SDK 54's replacement for `expo-av`).
  - Tap → full-screen playback with spoken-voice cue (optional) + "start" CTA.
- [ ] Onboarding step 1 reuses the same tile component.
- [ ] Web `PlanPage` uses the same catalog for the weekly plan's drill rows.

## Content production (parallel track — NOT engineer)

**Videos needed (v1):** 8 drills, 3 seconds each.
1. Sprint — A-skip
2. Sprint — high knees
3. Vertical jump — counter-movement jump
4. Squat — bodyweight depth
5. Push-up — proper elbow angle
6. Javelin — block-leg plant
7. Cricket bat — stance + swing
8. Football — kick mechanics

**Shoot spec:**
- Outdoor, natural light, single athlete in frame, phone propped 2m away on a cone (same as the user's shooting context).
- 16:9 or 1:1 (square is better for RN video components).
- 3 seconds, silent. Can loop seamlessly (last frame ≈ first frame).
- One clean rep per clip.

**Who produces:** a content lead with an athlete + a phone. This story's engineering part ships with a placeholder-videos set (any 3-second stock footage); the real videos can be swapped in via the catalog endpoint's `video_url` once they exist.

## Files to touch

### Backend
- Create `personal-health-backend/routes/drills.py` with:
  ```python
  @router.get("/drills/catalog")
  async def drill_catalog():
      return {"drills": [...]}  # loaded from db/drills.json
  ```
- Create `personal-health-backend/db/drills.json` with the 8 drill entries + local filesystem paths under `public/drill-videos/`.
- Mount static files for `/public/drill-videos/*.webm` in `api_server.py`.

### Android
- Install `expo-video`: `npx expo install expo-video`
- Create `personal-health-android/src/components/DrillTile.js` — renders video-thumb + label + sport chip.
- Update `personal-health-android/src/screens/fitness/DrillPickerScreen.js` to use it.
- Update `personal-health-android/src/screens/fitness/OnboardingScreen.js` step 1 to use the same tile.

### Web
- `personal-health-frontend/src/pages/PlanPage.jsx` — drill rows use the new catalog (small render change).

## Copy cue format (shown below video, optional)

- 1 line per cue, 2-3 cues per drill.
- Example for A-skip: "Drive knee to 90°. Land on ball of foot. Short ground contact."

## PM metrics

- First-session form-score variance. Hypothesis: videos reduce variance (fewer athletes doing the wrong movement). Measure σ before/after.
- % of new athletes who tap a drill tile → actually start the session (no back-out). Target ≥ 80%.

## Out of scope

- Slow-motion replay inside the video (ST-05.5).
- Multiple difficulty tiers per drill (ST-05.6).
- Coach-recorded personalized videos — that's ST-09 (voice-note compose) extended.

## Anti-patterns

- Gym-studio videos with a trainer in a bodycon outfit. Wrong audience.
- Over-produced slow-mo edits. Athletes lose patience.
- Voiceover instructions during the loop. Silent + text cues only.

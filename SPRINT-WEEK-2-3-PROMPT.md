# Sprint Week 2-3 — Close the Experience Loop

> **Scope:** four stories. Nothing outside them.
> **Base prompt:** load `BIOMECHANICS-ARCHITECT.md` first. Every design decision must pass its differentiation test and hard constraints.
> **You are:** the Principal Designer + PM role defined in that prompt, narrowed to these four stories.

---

## The four stories (do not expand scope)

| # | Story | Primary persona | Layer(s) |
|---|---|---|---|
| **2.1** | Share card rendering in Android | Arjun (17-24, club athlete) | Android |
| **1.1** | Audio cue engine for form correction | Arjun | Android + BE |
| **1.3** | Phone placement wizard (pre-session) | Arjun, Priya | Android |
| **5.1** | 60-second onboarding | Arjun (first-time) | Android |

These four together deliver the core promise: *"install the app → 60s later you're getting audio-graded reps → 30s after that you're sharing a card to Instagram."* If we ship these four well, the product is demo-able. If we ship three of them brilliantly and skip one, the demo breaks.

---

## Backend endpoints you consume (do NOT build new ones — they exist)

- `GET /session/{id}/share-card` → returns `{variant, hero_number, hero_label, delta, sub, chip, chip_colour, share_text, share_url, image_url, design_system, multiplayer}`. Use this verbatim; the variant+copy choice is already data-driven. Do not override on the client.
- `POST /session/{id}/frames` → frame-push endpoint for in-session inference (already wired in `TrainScreen.js`).
- `GET /athlete/{id}/plan/weekly` → used to pre-fill drill picker in onboarding.
- `POST /session/start`, `POST /session/{id}/end` → existing.

If you need a new endpoint, stop and spec it as a story — do not inline endpoints from the client.

---

## Design system — locked (no variants)

| Token | Value | Usage |
|---|---|---|
| accent | `#06b6d4` | hero numbers, CTAs, progress indicators |
| background | `#0a0e1a` | all screen backgrounds |
| surface | `#111827` | cards, modals |
| text primary | `#f9fafb` | headlines, body |
| text secondary | `#9ca3af` | metadata, captions |
| success (rare) | `#10b981` | PB variant chip only |
| warning (rare) | `#f59e0b` | injury risk only |

**In-session:** type ≥ 36pt. One number on screen max. No side panels. Audio is primary channel.
**Pre/post-session:** dense is OK. Type ≥ 16pt. Tap targets normal size.
**Never:** gradients, multi-colour variants, motivational quotes, profile photos on share cards, "challenge your friends" CTAs.

---

## Story 2.1 — Share card rendering in Android

**User story:** "After I finish a session, I see one number and one sentence. If I want to share it, one tap opens Instagram with the card pre-filled. If the session was bad, the card doesn't lie but also doesn't rub my face in it."

**Phase:** Post-session (Arjun, 30-90s dopamine window, sweating, phone in sweaty hand).

### Acceptance criteria

- [ ] On session end, `TrainScreen.js` navigates to a new `ShareCardScreen` and calls `GET /session/{id}/share-card`.
- [ ] Card renders using the response's `design_system` colours (do not hardcode in RN; let backend dictate).
- [ ] Layout:
  - Hero number: 120pt, bold, cyan (`#06b6d4`), centered.
  - Below: `hero_label` in 16pt uppercase `#9ca3af` (e.g. "form score", "personal best").
  - Below that: `delta` with an arrow (`▲` / `▼` / `—`) coloured cyan for up, `#9ca3af` for flat, desaturated red `#9ca3af` for down (*never* bright red post-session — that's for injury risk only).
  - Below that: `sub` in 14pt `#9ca3af`.
  - Corner chip: `chip` text in `chip_colour` (backend-driven).
  - Background: solid `#0a0e1a`. No gradient. No profile photo. No logo bomb — small "Personal Health" wordmark in `#6b7280` at the foot.
- [ ] One-tap share button at bottom, cyan pill, opens Instagram Stories via the `instagram_deeplink` from the response. Fallback: OS share sheet with `share_text` + a rendered image.
- [ ] The `show_up` variant (bad session) does **not** show a delta line at all. It shows the score, "session logged", and "showed up" chip. That's the whole card. Do not add encouragement copy.
- [ ] **Multiplayer hooks (server-driven):** if `multiplayer.huddle_auto_post: true`, show a secondary chip "posted to huddle" on the card. If `multiplayer.coach_will_see: true`, show "coach will see this" in `#9ca3af` below the share button. Transparency beats surprise.
- [ ] **Haptic:** single soft pulse when the card first renders (success bookmark moment). No haptic on share tap — OS handles that.

### PM success metrics

- % of completed sessions where the card screen is viewed. Target: >70%.
- % of viewed cards where share is tapped. Target: >20% for `pb`, >5% for `streak`, >1% for `show_up`.
- % of share taps that complete external share. Target: >60% (friction = Instagram not installed).

### Anti-patterns (reject in review)

- Any gradient.
- A motivational quote.
- A "try again" CTA on bad sessions (implies the session was a failure — it wasn't).
- A share button on the `show_up` variant that says "Share this!" — make it neutral ("Share"), tiny, optional.

---

## Story 1.1 — Audio cue engine for form correction

**User story:** "I'm sprinting. The phone is 4 metres away on a cone. When my knee drive drops, I hear a flat, coach-like voice say 'drive higher' within a second. It never yells. It never says 'great job'. It only speaks when it has something actionable."

**Phase:** In-session (Phase 2 — phone propped, athlete moving, glances <1s, cannot tap).

### Acceptance criteria

- [ ] Ship one sport first (recommend **sprint**, because the knee-drive signal is the cleanest in the existing pose output). Other sports follow the same pattern.
- [ ] Three cues, no more:
  - "drive your knee higher" (triggered: knee angle at peak drive < 85° across 3 consecutive reps)
  - "land softer" (triggered: landing impact proxy — vertical velocity at contact — exceeds athlete's baseline by 20% across 2 reps)
  - "longer stride" (triggered: stride time + ground contact time ratio < 1.1 across 3 reps)
- [ ] Detection runs server-side via existing `/frames` analysis worker. Server sends a WebSocket event `{type: "cue", text: "drive your knee higher", urgency: "normal"}` to the client.
- [ ] Android speaks it using `expo-speech` with a **flat, calm voice** — explicitly NOT excited. `rate: 1.0`, `pitch: 0.9`. No exclamation marks in the text ever.
- [ ] **Throttle:** one cue every 4 seconds minimum. If a second cue fires during cooldown, drop it (do not queue).
- [ ] **Silence when in range:** if the athlete is performing well, the app is silent. The cue-triggered check must not become a constant stream. Aim for <3 cues per 60-second block in good-form sessions.
- [ ] **Audio over music:** use audio session mode `Ducking` on Android so the cue lowers the athlete's music briefly instead of cutting it.
- [ ] **Visual fallback:** if `expo-speech` fails, fire a single-line subtitle bar at the top of the screen for 2s. Must be ≥ 36pt. No beep.
- [ ] **Injury-risk cue (separate urgency):** if pose analyzer flags landing angle in injury range, send `{type: "cue", text: "pause — check your landing", urgency: "warning"}`. Android speaks it louder, ducks harder, and shows a red bar. This is the *only* red in-session UI. Bar clears after 3s.

### Backend work

- [ ] Extend the analysis worker to emit cue events per rep into the existing WebSocket stream (there's already a `/realtime/{session_id}` WS — piggyback it).
- [ ] Cue rules live in `services/cues.py` (new file). Each rule: `(trigger_fn, message, cooldown_s)`. Unit-test every rule with 3 good / 3 bad frame sequences.
- [ ] Respect the athlete's **personal baseline** for "landing impact" — not a global threshold. Pull from `intelligence_report` or compute from last 10 completed sessions. If fewer than 5 sessions exist, use a conservative global threshold.

### PM success metrics

- A/B test: cues on vs. off. Measure next-session return rate within 7 days.
- Cue comprehension: post-session 1-tap survey "did the audio help?" (yes/no/confusing). Target: >70% yes, <10% confusing.
- Cue frequency: median cues per 60-second block <3 in high-form sessions, <8 in low-form sessions.

### Anti-patterns (reject in review)

- An excited voice. "Great drive!" "Push it!" — all banned. You are not a Peloton instructor.
- Cueing every rep. The silence between cues is as important as the cues.
- Cue overlapping speech. Throttle is non-negotiable.
- Beeping (except for rest-timer end, which is a separate story).
- Visual cues that require >1s to parse. If the eye can't absorb it mid-stride, cut it.

---

## Story 1.3 — Phone placement wizard (pre-session)

**User story:** "I prop my phone on a cone 2m away. The app tells me whether it can actually see me. If it can't, it tells me what to move — not some vague 'adjust camera' toast."

**Phase:** Pre-session (thumb on phone, dense UI OK, 15-30s budget).

### Acceptance criteria

- [ ] New screen `PlacementWizardScreen` that appears after the athlete picks a drill, before the session starts.
- [ ] Live camera preview, full-screen.
- [ ] MediaPipe runs locally (already in the codebase); if not available, fall back to server-side frame check via `/pose/check` (new thin endpoint, spec below).
- [ ] Overlay states, cycle through as pose detection updates:
  - **RED border + "no full body visible":** if fewer than 17 landmarks visible.
  - **YELLOW border + "step further back":** if the athlete's bounding box is >70% of frame height.
  - **YELLOW border + "step closer":** if the bounding box is <35% of frame height.
  - **YELLOW border + "move phone lower":** if hips are in the top third of frame.
  - **YELLOW border + "move phone higher":** if head is in the bottom half of frame.
  - **GREEN border + "ready":** all checks pass for 1.5 consecutive seconds. Auto-advances to "tap to start session."
- [ ] A single "start anyway" button (tap target ≥ 60pt), greyed out until green or at 15s timeout. If the athlete insists, the session proceeds with a warning banner during session: "setup sub-optimal — scores may be less accurate."
- [ ] A "setup tips" pull-up sheet (one tap) with a 10s looping video of "correct tripod placement" — shot in outdoor sunlight on a turf, not a studio.
- [ ] **Haptic:** single confirmation pulse when state transitions to GREEN.

### Backend micro-endpoint (if MediaPipe-on-device isn't ready)

- [ ] `POST /pose/check` → takes a single JPEG frame, returns `{landmarks_visible: int, bbox_pct: float, head_y_pct: float, hips_y_pct: float, recommendation: "step_back" | "step_closer" | "move_lower" | "move_higher" | "ready" | "no_body"}`. <200ms target.

### PM success metrics

- % of new users who reach GREEN before first session. Target: >85%.
- Median time-to-green from wizard entry. Target: <30s.
- % of sessions started via "start anyway" (sub-optimal override). Should be <10%; higher means the thresholds are too strict.

### Anti-patterns (reject in review)

- Dense technical language ("adjust camera angle", "frame composition sub-optimal"). Use sport language — "step back", "move phone lower".
- Red border used for anything except "no body." Red is an anxiety signal; don't overuse.
- Blocking the athlete from starting if they really want to. The override exists because sometimes the cone falls over and they just need to get one rep in.

---

## Story 5.1 — 60-second onboarding

**User story:** "I install the app. I land on a screen that, in under 60 seconds, has me pointing my phone at a wall and doing 3 reps of my chosen drill. I see my first score. Then the app tells me what was good and what to work on. I did not read a tutorial. I did not sign up with email. I did not see a paywall."

**Phase:** Pre-session for a first-time user, leading straight into in-session and post-session.

### Acceptance criteria

- [ ] **Zero-friction entry:** no email, no password, no OTP on first session. Generate an anonymous `athlete_id`, store locally. Offer account creation *after* the first score (so the athlete has something to save).
- [ ] **Sport picker:** one screen, 6 tiles max. Each tile: sport name + a 3-second looping motion video (not a static icon). Top row: sprint / vertical jump / push-up. Second row: squat / javelin / cricket bat. Tap to choose, auto-advance.
- [ ] **"Place your phone" screen:** reuses Story 1.3 wizard. Override button enabled after 10s instead of 15s (more permissive for first-timers).
- [ ] **"Do 3 reps" prompt:** spoken aloud, shown on screen in 44pt. Minimal UI otherwise. No stats ticker.
- [ ] **First-score reveal:** after 3 reps, auto-end session. Navigate to share card (reuses Story 2.1). Card variant for first session is a new variant `first_session` that backend returns — same visuals, copy reads "first session logged · {sport}".
- [ ] **Post-score prompt:** *after* the score is visible, offer account creation as a single optional tile: "save your progress — takes 10 seconds." One-tap Google Sign-In or skip. Skipping keeps the session on an anonymous device-bound account.
- [ ] **Total budget from install to first-score view: ≤ 90 seconds** measured on a clean install on a mid-range Android (Pixel 6a-class, not flagship).

### PM success metrics

- Install → first session start: >70%.
- First session start → first score view: >85% (lower bound = model failures + phone placement failures).
- First score → account creation (within 24h): >40%.

### Anti-patterns (reject in review)

- Requiring email/password before any value is delivered.
- A tutorial carousel. "Swipe to see how it works" screens convert poorly and the product is self-evident once the first score shows.
- A paywall anywhere in the onboarding. First session is always free.
- Asking for notification permission before the first score. Request it *after* the athlete has seen a score and therefore has a reason to care about notifications.

---

## Required response structure for every design decision you make

When you propose a screen, button, copy change, or logic flow, output this:

1. **Story #** (2.1 / 1.1 / 1.3 / 5.1 — reject if outside scope).
2. **Phase** (pre-session / in-session / post-session / onboarding).
3. **User story sentence** (1-2 lines in Arjun/Priya's voice).
4. **Logic Map** (what client does, what backend call it makes, what response it handles).
5. **Multiplayer Logic Map** (who else sees this, when, how it changes behavior — or explicit "solo, justified because ___").
6. **UX description** (layout, top-to-bottom, type sizes, colours).
7. **Haptic / audio notes** (what plays when).
8. **PM metric** (what we'd measure).
9. **Anti-pattern check** — differentiation test: would this advice differ from Strava, Calm, Peloton? If not, reject and redesign.

---

## Out of scope (do not touch these in this sprint)

- Leaderboard UI
- Huddle mode UI
- Coach dashboard (already shipped on backend, frontend owned by PM directly)
- Paywall (separate sprint)
- Auth / account deletion / legal pages (separate sprint)
- Nutrition endpoints (recently merged, frontend consumer TBD)
- Any change to the backend score calculation, rubrics, or model

If a task requires touching these, stop and flag. Do not expand scope.

---

## Copy principles (apply ruthlessly to every string you write)

- No exclamation marks in in-session voice cues.
- No em-dash-em-dash — use a single em-dash or colon.
- Sport language > wellness language. "drive your knee higher" > "elevate your form."
- Actionable > descriptive. "land softer" > "impact detected."
- Silent > verbose. If the cue adds no instruction, don't speak.
- No first person from the app ("let me show you..."). The app is a tool, not a character.

---

## Definition of Done for the sprint

- [ ] All four stories deployed to a test Android APK.
- [ ] One end-to-end demo video: install → onboarding → first session with audio cues → share card → share to Instagram (or share sheet if Instagram not installed on the test device).
- [ ] Each story has: a screen recording on outdoor lighting (park, not desk), a short write-up in PM-voice (one paragraph each), and the PM metrics it's instrumented for.
- [ ] One-pager listing *which* anti-patterns you considered and rejected. Reviewers will use this to pressure-test compliance with the architect prompt.


# Story index — Personal Health production-readiness

Each story here is self-contained. Pick one, read its MD, ship it. No cross-dependencies unless noted in the "Depends on" line of a story.

**Status key:**
- ⚡ S — small, <1 day
- 🔨 M — medium, 1-3 days
- 🏗 L — large, 3+ days (scope, not effort — delegate if possible)

---

## 🟢 Immediate (ship this week — high leverage, small effort)

| # | Story | Size | Primary persona | What ships |
|---|---|---|---|---|
| [ST-01](./ST-01-sport-specific-drill-filter.md) | Sport-specific drill filter in onboarding | ⚡ S | Arjun (first-time) | Onboarding step 2 shows only the drills that match the picked sport |
| [ST-02](./ST-02-first-score-celebration.md) | First-score celebration screen | ⚡ S | Arjun (first-time) | After first session, a dedicated "your first score" moment before the generic ShareCard |
| [ST-03](./ST-03-invite-coach-prompt.md) | "Invite your coach" post-first-session prompt | 🔨 M | Arjun → Coach Raj | Loop-closer that turns solo athletes into roster athletes |
| [ST-04](./ST-04-sport-aware-empty-states.md) | Sport-aware empty states | ⚡ S | All new athletes | Empty lists say "your first X lands here", not "no data" |
| [ST-05](./ST-05-drill-library-videos.md) | Drill library with looping videos | 🔨 M | All athletes | Every drill tile shows a 3-second form video, not a text label |

## 🟡 Medium-term (week 2-3 — production gates)

| # | Story | Size | Primary persona | What ships |
|---|---|---|---|---|
| [ST-06](./ST-06-android-coach-mode.md) | Android coach mode (morning + inbox + roster) | 🔨 M | Coach Raj | Trainer can run morning triage + reply to athletes from a phone |
| [ST-07](./ST-07-google-oauth.md) | Google Sign-In | 🔨 M | All users | One-tap signup, optional account upgrade from anonymous |
| [ST-08](./ST-08-parent-sms-integration.md) | Parent SMS weekly digest + injury alert | 🔨 M | Parent (tertiary) | Weekly SMS → no-login web digest page |
| [ST-09](./ST-09-voice-note-compose-android.md) | Voice-note compose on Android (trainer side) | 🔨 M | Coach Raj | Record 30s → send to N athletes → athlete reply inbox |

## 🔴 Larger (month 1+ — deferred but spec'd)

| # | Story | Size | Primary persona | What ships |
|---|---|---|---|---|
| [ST-10](./ST-10-razorpay-billing.md) | Razorpay subscription billing | 🏗 L | All + coach tier | ₹199/mo athlete plan, ₹499/mo coach plan, auto-renewal |
| [ST-11](./ST-11-fcm-eas-dev-build.md) | EAS dev build for real push delivery | 🔨 M | All | Push notifications actually reach the phone (not just DB) |
| [ST-12](./ST-12-postgres-migration.md) | Migrate JSON files to Postgres | 🏗 L | Ops | Scale past ~500 athletes |

## 🎬 Content production (requires human, cannot be done by a dev)

| # | Story | Size | Who does it | What ships |
|---|---|---|---|---|
| [ST-13](./ST-13-demo-videos.md) | End-to-end demo + outdoor screen recordings + drill reference videos | 🏗 L | Product lead with a phone + turf | Marketing assets + in-app drill reference clips |

---

## How to use this folder

1. Pick one MD. Read top-to-bottom (≤150 lines each).
2. Every story has a **"Files to touch"** section with exact paths and any line numbers I could identify.
3. Every story has an **"Acceptance criteria"** checklist. When every box is checked, it's shippable.
4. Mark it done by moving the file to `stories/done/` with a short "what I actually shipped" note at the top.

## Canonical design context (applies to every story)

- Design system locked: accent `#06b6d4`, bg `#0a0e1a`, surface `#111827`. Never introduce a second accent.
- In-session UI: ≥ 36pt type, one number on screen, audio-first, no tap targets except "stop".
- Copy: sport language over wellness language. No "!" in in-session voice cues. Never "we miss you."
- Multiplayer: every flow should answer "who else sees this?" — default to closed circles (huddle + roster), never open timelines.
- Differentiation test before shipping: would this advice differ from Strava, Calm, or Peloton? If not, rewrite.

Source prompts this backlog derives from:
- `/Users/aagarwal/personal-project/BIOMECHANICS-ARCHITECT.md`
- `/Users/aagarwal/personal-project/SPRINT-WEEK-2-3-PROMPT.md`
- `/Users/aagarwal/personal-project/TRAINER-FIRST-PROMPT.md`

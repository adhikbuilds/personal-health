# ST-04 — Sport-aware empty states

**Size:** ⚡ S (2-4 hr) · **Persona:** All new athletes · **Phase:** All tabs

## Problem

A brand-new athlete opens the app and sees:

- `HomeScreen` → "Form Score: —" / "Sessions: 0" / "0 BPI"
- `NutritionScreen` → "No meals logged"
- `WellnessScreen` → "No recent wellness data. Log your morning check-in!"
- `HuddleScreen` → "No huddles"
- `SocialFeedScreen` → "No activity"

Every tab is empty. Feels broken. There's no path forward from any of them.

## Target state

Every empty state shows:

1. A **specific** line about what appears here after the first action.
2. A **CTA** that takes the user directly to the action (not just "tap X to start").
3. A neutral tone — not guilt ("you haven't trained yet") but also not wellness-y ("your journey awaits").

## Acceptance criteria

Each card below gets a purposeful empty state. Specifics:

- [ ] **HomeScreen `FitnessScoreCard`** — when `score === 0 || score == null`:
  - Hero: "—"
  - Body: "Your first form score lands here. Takes 60 seconds."
  - CTA: "Start training" → navigation.navigate('Camera')
- [ ] **HomeScreen `streakPill`** when streak is 0:
  - Text: "Start your streak"
  - No count shown (currently shows "0 day streak" which demotivates)
- [ ] **NutritionScreen** when 0 meals:
  - Body: "Log a meal to see your macros trend through the day."
  - CTA: "Log breakfast" / "Log lunch" / "Log dinner" / "Log snack" depending on local time.
- [ ] **WellnessScreen** when wellness_score is null:
  - Body: "One 15-second check-in and you'll see recovery readiness based on sleep, mood, soreness."
  - CTA: "Start check-in" → WellnessLogForm
- [ ] **HuddleScreen** when no huddles:
  - Body: "Huddles are groups of 15-20 athletes training together. Your coach creates the huddle — once you're added, sessions show here."
  - NO CTA (creating a huddle is coach-only, and there's no coach yet — this teaches, it doesn't ask).
- [ ] **SocialFeedScreen** when no activity:
  - Body: "Your huddle + coach's roster post here — PBs, milestones, coach notes. Add your coach to see activity."
  - CTA: "Invite your coach" → triggers ST-03 flow.

## Files to touch

- `personal-health-android/src/screens/core/HomeScreen.js` — search for the StatCard with `value=fitnessScore?.score || '—'` and wrap the whole block with a "first-time" branch.
- `personal-health-android/src/screens/nutrition/NutritionScreen.js` — `loading` branch and "no meals today" branch.
- `personal-health-android/src/screens/wellness/WellnessScreen.js` — existing null-score path (around the `Log Today` CTA) — enhance copy + keep CTA.
- `personal-health-android/src/screens/social/SocialFeedScreen.js` — empty state path.
- `personal-health-android/src/screens/fitness/HuddleScreen.js` (if exists — check `src/screens/`) — otherwise skip this one.

## Copy principles

- **Never** "No data" / "Nothing here yet" / "Empty" — these are technical phrases.
- **Always** name the ACTION that changes the state ("Log a meal", "Start training").
- **Never** use "your journey" / "your path" / "your wellness".

## PM metrics

- First-session start rate from HomeScreen (tap "Start training" on the empty fitness card). Measure before + after.
- Bounce rate from tabs that used to be empty. Should drop.

## Out of scope

- Skeleton loaders (loading states are separate from empty states — if empty-state patterns want skeletons, that's ST-04.5).
- Dashboard card reordering.
- New tabs.

## Anti-patterns

- Using placeholder ghost cards ("Session 1 — pending" / "Meal — waiting"). These feel like broken data.
- CTAs that scroll you inside the same empty screen ("Learn more").
- Any emoji beyond what's already in the codebase's existing icons.

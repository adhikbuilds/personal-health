# ST-01 — Sport-specific drill filter in onboarding

**Size:** ⚡ S (20-40 min) · **Persona:** Arjun (first-time) · **Phase:** Pre-session onboarding

## Problem

After `OnboardingScreen` step 0 the athlete picks a sport (e.g. `cricket_bat`). Step 1's drill grid currently shows **all** drills (sprint, jump, squat…). A cricket athlete sees running drills and churns.

## Target state

Step 1 shows only drills valid for the sport the athlete just picked, with the top card highlighted as "your sport's core drill." If the picked sport has fewer than 3 drills, pad with related cross-training drills, never unrelated ones.

## Acceptance criteria

- [ ] Pick **Cricket Bat** in step 0 → step 1 shows cricket drills first, then neutral warm-up drills (planks/push-ups). Never shows `sprint` or `vertical_jump`.
- [ ] Pick **Sprint** → step 1 shows sprint-specific drills first (A-skip, high-knees), then cross-training.
- [ ] Pick **Vertical Jump** → step 1 shows vertical-jump drills (squat, box jump, depth jump).
- [ ] The first card on step 1 has a "Your sport" chip (already built — check `suggestedChip` style).
- [ ] If the athlete skipped sport selection via "Skip to dashboard" (they never reach step 1), behavior unchanged.

## Files to touch

- `personal-health-android/src/screens/fitness/OnboardingScreen.js`
  - Existing `DRILLS` constant (around line 31) — add a `sports: [...]` array to each drill listing which sports it's relevant for.
  - Existing `relevantDrills` `useMemo` (around line 145) — replace the current "primary sport first, rest after" logic with "filter to drills whose `sports` array contains `selectedSport`, then sort primary-first."

## Data mapping to use

```js
// Example — fill this out for all 8 sports in SPORTS_META
const DRILL_RELEVANCE = {
  sprint:        ['a_skip', 'high_knees', 'bounds', 'plank'],
  vertical_jump: ['squat', 'box_jump', 'depth_jump', 'plank'],
  push_up:       ['push_up', 'plank', 'pike_push_up'],
  squat:         ['squat', 'box_jump', 'lunge'],
  javelin:       ['plank', 'shoulder_press', 'medicine_ball_throw'],
  cricket_bat:   ['cricket_bat_swing', 'plank', 'shoulder_rotation'],
  football:      ['a_skip', 'high_knees', 'sidestep', 'squat'],
  swimming:      ['plank', 'shoulder_press', 'flutter_kick'],
};
```

## PM metrics

- % of new athletes who complete step 1 → step 2 (placement wizard). Target ≥ 70% (current baseline: measure before shipping).
- % of sessions started from onboarding that are in the sport the user picked. Target ≥ 85%.

## Out of scope

- Adding new drills to the catalog (that's ST-05).
- Sport auto-detection from pose during onboarding.

## Anti-patterns

- Hardcoding the drill list inside `relevantDrills` — keep the mapping as a top-level constant so it's one-line to extend.
- Showing **zero** drills for an unknown sport — always fall back to the full list with the primary-first sort.

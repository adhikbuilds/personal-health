# ST-02 — First-score celebration screen

**Size:** ⚡ S (half a day) · **Persona:** Arjun (first-time) · **Phase:** Post-session, first session only

## Problem

After an athlete's FIRST session, they land on the generic `ShareCardScreen`. There's no "this is YOUR first score, here's what it means" moment. The product's core promise — *"every session makes you measurably better"* — has no anchor.

## Target state

A dedicated first-score screen that appears **only after the first completed session**, before the regular ShareCard. It explains:

1. What the number means ("Your form score is 72 — graded from your knee drive, hip extension, and landing symmetry").
2. What's next ("Your next session will show a ▲ or ▼ vs. this 72. Aim to stay consistent, then improve.")
3. One tap to continue to the normal ShareCard.

No scoreboarding, no comparisons to others, no paywall.

## Acceptance criteria

- [ ] New screen `FirstScoreScreen` in `src/screens/fitness/`.
- [ ] Routed from `CameraSession`'s end-of-session logic ONLY when `hasCompletedOnboarding()` is false AND there's no prior completed session for this athlete.
- [ ] Shows the session's form score at 120pt in accent cyan `#06b6d4`.
- [ ] Below: a 2-sentence explainer generated from the session's actual weakest joint (e.g. "Your knee drive averaged 78°. 85° would put you in the top 10% of your sport.")
- [ ] "Continue" button advances to the regular `ShareCardScreen`.
- [ ] After Continue, calls `markOnboardingComplete()` so subsequent sessions go straight to `ShareCardScreen`.
- [ ] **Haptic:** single medium impact on screen mount.
- [ ] **No share button on THIS screen** — the regular ShareCard has it. This screen is purely an internal celebration.

## Files to touch

- Create `personal-health-android/src/screens/fitness/FirstScoreScreen.js`.
- `personal-health-android/App.js`:
  - Import FirstScoreScreen at the top with other fitness imports.
  - Add `<Stack.Screen name="FirstScore">` between `PlacementWizard` and `ShareCard`.
- `personal-health-android/src/screens/fitness/TrainScreen.js` (or wherever session-end navigates):
  - Find the `navigation.replace('ShareCard', ...)` call. Wrap in a check:
    ```js
    const onboarded = await hasCompletedOnboarding();
    navigation.replace(onboarded ? 'ShareCard' : 'FirstScore', { sessionId, athleteId });
    ```

## Backend endpoints to use

- `GET /session/{id}/share-card` — already returns `hero_number`, `hero_label`, weak-joint hints.
- `GET /athlete/{id}/progress` — pull weakest joint for the explainer copy.

No new backend work.

## Copy principles

- Never use `!` in the explainer.
- One sentence per line. Max 3 lines.
- Specific > motivational. "Your knee angle averaged 78°" beats "Great start on your journey!".
- Never compare to other users on this screen.

## PM metrics

- % of new athletes who tap "Continue" vs. back out. Target ≥ 90%.
- Next-session rate within 72 hours of first score. A/B test FirstScoreScreen-on vs. off. Target lift: +10pp.

## Out of scope

- Share button on first-score (belongs on regular ShareCard).
- Sport-specific copy templates (v1 uses a generic template with the weak-joint substitution).
- Animations beyond the haptic.

## Anti-patterns

- A gradient background (design system locked).
- A motivational quote ("You did it!", "Great start!" — banned).
- A paywall or upsell.
- Percentile comparison to strangers ("you're top 10%" — reject, not in a closed circle).

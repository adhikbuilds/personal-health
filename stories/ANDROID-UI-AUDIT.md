# Android UI — production-readiness audit (2026-04-19)

Scoped to `personal-health-android/src/screens/` — 30 screens across core/, fitness/, nutrition/, social/, wellness/.

**Production readiness score today: 6.2 / 10.** v1-shippable after the TOP-10 fixes below.

---

## TOP-10 highest-impact fixes

Ordered by leverage (visual impact × risk-adjusted effort).

1. **Replace hardcoded `'athlete_01'` fallbacks in 9 files** — blocks multi-user onboarding. Use the deviceIdentity.getOrCreateAnonymousAthleteId() result everywhere. Touch: HomeScreen:258, TrainScreen:138 + :270, OnboardingScreen:110, WellnessScreen:45, NutritionScreen:29, NutritionGoalsScreen:19, HubScreen, WellnessLogFormScreen.
2. **Add error fallback UI to WellnessScreen, NutritionScreen, DrillPickerScreen** — today they show an infinite spinner on API failure. Replace with "failed to load — retry" state.
3. **Centralize typography in tokens.js, update all screens** — 59 distinct font sizes found vs. 10 defined tokens. Define semantic sizes (h1–h6, body, caption) + sweep all hardcoded `fontSize: NN` values.
4. **Centralize spacing** — 15 distinct padding/margin values found vs. 8 token sizes. Same sweep.
5. **Skeleton loaders on MetricsScreen + FitnessTestScreen** — currently blank for 2-3s during API load. Replace with pulsing placeholders.
6. **Add haptics to all primary CTAs** — only 5 of 30 screens have any haptic feedback. NutritionScreen tile taps, WellnessScreen CTA, SocialFeed like/follow, HomeScreen grid taps all silent. Adding is one line per tap.
7. **Fix WellnessScreen empty state CTA** — "Log your morning check-in" is styled like text but is tappable. Users miss it.
8. **Standardize button sizes: 44 × 44pt minimum** — WellnessLogFormScreen interBtn (46×38), SocialFeedScreen createBtn (38×38) both below iOS/Android guidance.
9. **Graceful API timeout fallback** — 5s timeout + retry UI on HomeScreen, DrillPickerScreen, CoachInboxScreen.
10. **Migrate `SafeAreaView` from `react-native` → `react-native-safe-area-context`** — 5 screens still use the deprecated one (TrainScreen:8, OnboardingScreen:5, MetricsScreen, FieldBookingScreen, WellnessPlaceholderScreen). Future-proofs for notch support.

---

## Findings by category (all P0/P1/P2)

### P0 — visible bugs / obvious crash paths

- **Hardcoded `'athlete_01'` fallback** (9 files) — leaks seed data into prod.
- **WellnessScreen / NutritionScreen / DrillPickerScreen** — catch API errors without updating UI state. Infinite spinners.
- **TrainScreen audio / Speech error paths** — no fallback if iOS silent mode or speech engine unavailable → crash.
- **CoachInboxScreen voice upload** fails silently with no user feedback.

### P1 — unpolished surfaces a user would notice in demo

- **59 distinct font sizes** across screens vs. 10 defined in tokens.js. Every screen has its own ad-hoc scale.
- **15 distinct spacing values** vs. 8 tokens. Inconsistent whitespace.
- **Haptics absent** on 80% of button presses.
- **Empty-state copy** is generic ("No data") on multiple screens. No CTAs embedded in empty states.
- **HomeScreen** has 7 concurrent API calls on mount with only 1-2 error handlers. Graceful degradation missing.
- **TrainScreen camera permission** shows "loading camera" for 3-8s with a spinner; no user-controllable abort.
- **MetricsScreen + FitnessTestScreen** block render until first API response. 2-3s blank screen.
- **WellnessLogFormScreen** allows empty form submission (no validation).
- **MealLogScreen** allows negative meal values.

### P2 — polish nice-to-haves

- No image caching (no screens use images yet, but FastImage recommended when they do).
- `SafeAreaView` from `react-native` (deprecated) in 5 screens.
- `expo-av` (deprecated, replaced by `expo-audio` in SDK 54) in TrainScreen, CoachInboxScreen.
- Inconsistent font-weight choices (400/500/600/700/800/900 all used; no semantic weight map).

---

## Screens with the biggest revamp ROI

Rank 1–5 (most-seen × most-unpolished):

1. **HomeScreen** — every user lands here every session. Score card, grid, empty states all need the sweep.
2. **TrainScreen (CameraSession)** — the product's core moment. Needs audio-cue error handling, loading polish, haptic on start/stop.
3. **WellnessScreen** — currently the weakest empty state. "2+ weeks" copy is demotivating.
4. **NutritionScreen** — empty meal slots show nothing, not a CTA. Easy win.
5. **OnboardingScreen** — the first impression. Step 1 drill list isn't sport-filtered (see ST-01).

---

## What this doesn't cover

- Performance profiling (Hermes bytecode size, list virtualization, over-rendering) — separate audit with a profiler build.
- Accessibility (screen reader, font scaling, color contrast against WCAG) — separate audit with `@react-native-community/a11y`.
- Dark-light mode support — app is dark-only today, which is intentional.

---

## Files never touched by this audit

- `App.js` (navigation shell — kept minimal intentionally)
- `index.js` / entry points
- Anything under `android/` / `ios/` native dirs (Gradle + Xcode territory)
- Tests (none exist for UI — that's its own gap)

# Android Sprint — Four Stories Only

## 2.1 Share card rendering in Android
Story # 2.1  
Phase: post-session  
User story sentence: "I finish, I see one number and one sentence, and I can share it without the app turning my bad day into a humiliation ritual."  
Logic Map: `TrainScreen` ends the session, navigates to `ShareCardScreen`, calls `GET /session/{id}/share-card`, renders backend-driven copy and colours, then attempts Instagram deep link first and OS share sheet second.  
Multiplayer Logic Map: coach and huddle visibility are server-driven through `multiplayer.*`; the client exposes that transparently instead of surprising the athlete later.  
UX description: near-black background, one 120pt cyan number, uppercase 16pt label, optional delta line, one low-key chip, and a single cyan share pill.  
Haptic / audio notes: one soft haptic when the card appears, no extra audio or haptic on share.  
PM metric: share-card view rate after completed session; share tap rate by variant.  
Anti-pattern check: this is not a Strava brag card because the backend controls when the card is humble (`show_up`) and the client never adds hype copy.

## 1.1 Audio cue engine for form correction
Story # 1.1  
Phase: in-session  
User story sentence: "When something is off, I hear one flat correction quickly enough to use it on the next rep. If I’m moving well, the app stays quiet."  
Logic Map: Android starts a session, opens `/metrics/live/{session_id}` for streamed cue events, still pushes frames through the existing HTTP frame path, and speaks `type:"cue"` payloads with throttle. Backend evaluates sprint rules in `services/cues.py` and broadcasts cue messages through the existing session WebSocket fanout.  
Multiplayer Logic Map: solo, justified because live form correction is immediate private coaching; social exposure during a rep would add pressure without improving execution.  
UX description: one big score only, subtitle fallback line at 36pt, and a red top bar only for injury-risk warnings.  
Haptic / audio notes: calm speech only, Android ducking enabled, no beep, no praise language, warning cues spoken slightly stronger.  
PM metric: median cues per 60-second block and post-session "did the audio help?" response.  
Anti-pattern check: this differs from Peloton because silence is the default and the voice never performs encouragement as entertainment.

## 1.3 Phone placement wizard
Story # 1.3  
Phase: pre-session  
User story sentence: "Before I start, I want to know whether the app can actually see me and exactly what to fix if it can’t."  
Logic Map: after sport selection, `PlacementWizardScreen` opens camera preview, captures checks on a short interval, calls `POST /pose/check`, maps the recommendation to border state and setup copy, then routes into `TrainScreen`.  
Multiplayer Logic Map: solo, justified because setup quality is private and functional; adding social comparison here would only slow first-session completion.  
UX description: full-screen preview, one instruction in large sport language, red only for no-body-visible, yellow for all adjustment states, green once stable.  
Haptic / audio notes: one confirmation pulse on green, no speech.  
PM metric: time-to-green and override rate.  
Anti-pattern check: this is not a generic "adjust camera" wizard; the copy is physical and actionable, like a coach repositioning the cone.

## 5.1 60-second onboarding
Story # 5.1  
Phase: onboarding  
User story sentence: "I install the app and get to a first score before the app ever asks me for commitment."  
Logic Map: `LaunchScreen` checks onboarding completion, first-time users go to `OnboardingScreen`, pick a sport, enter `PlacementWizardScreen`, auto-start `TrainScreen`, auto-end after 3 reps, then land on `ShareCardScreen`. An anonymous athlete id is created and stored locally first.  
Multiplayer Logic Map: the social layer is deferred until after value delivery; the first score creates the right moment for sharing and account capture.  
UX description: one sport-picker surface, then setup, then live 44pt "do 3 reps" prompt, then first-session share card plus optional account-save tile.  
Haptic / audio notes: light selection haptic on drill choice, spoken "do 3 reps" at session start, share-card haptic bookmark at the end.  
PM metric: install to first-session start and first-session start to first-score view.  
Anti-pattern check: this differs from generic fitness onboarding because there is no tutorial carousel, no auth wall, and no permission theater before the athlete sees a score.

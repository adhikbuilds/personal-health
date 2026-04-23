# ST-03 — "Invite your coach" post-first-session prompt

**Size:** 🔨 M (1 day) · **Persona:** Arjun → Coach Raj · **Phase:** Post-first-session, acquisition loop

## Problem

The trainer-first product thesis depends on the coach pulling athletes in, but a brand-new solo athlete who downloaded the app has no path to invite their coach. Yet the backend ships with `POST /coach/{id}/invite-link` — a ready-to-use flow that nothing triggers.

## Target state

After the first session's ShareCard (ST-02's FirstScore → regular ShareCard), a one-tap prompt:

> **"Train with a coach? Share this with them."**
> [Generate invite link]

Tap generates a WhatsApp-ready link. The coach taps it → installs → opens Expo Go or dev build → athlete auto-appears on the coach's roster. Only TWO taps from the athlete's side, one message-send on WhatsApp.

## Acceptance criteria

- [ ] On `ShareCardScreen`, below the share button, new section: "Training with a coach? Let them see your progress."
- [ ] "Generate link" button → calls `POST /coach/{id}/invite-link` (spec: returns `{ invite_url, token, expires_at }`).
  - NOTE: if this endpoint takes `coach_id` in the URL but the athlete has no coach yet, call it via a variant that accepts the athlete's own id and creates an "athlete → coach" reverse invite token. Check backend first. If not present, add as a sub-task.
- [ ] Result: WhatsApp OS share sheet with pre-filled message:
  > *"Hey — I'm training on Personal Health. Tap this link so you can see my form scores: {invite_url}"*
- [ ] Athlete sees a one-time confirmation: "sent — your coach will appear on your roster once they install."
- [ ] After 24h or one successful coach add, the prompt hides (tracked via AsyncStorage `@ph_v1_coach_invite_state`).

## Files to touch

### Android
- `personal-health-android/src/screens/fitness/ShareCardScreen.js` — add the "invite coach" section below `actions` row.
- `personal-health-android/src/services/coachInvite.js` **(new)** — helper that wraps:
  - `generateCoachInviteLink(athleteId)` → POST to backend, returns URL
  - `hasInvitedCoach()` / `markCoachInvited()` via AsyncStorage

### Backend (check what exists first)
- `personal-health-backend/routes/coach_invite.py` already exists. Run:
  ```bash
  grep -E "^@router\." routes/coach_invite.py
  ```
  If it only has `POST /coach/{coach_id}/invite-link`, add a reverse variant: `POST /athlete/{athlete_id}/request-coach` that returns the same shape of `{invite_url, token}`.

## Copy

- **Section headline:** "Training with a coach?"
- **Section sub:** "Send them this — they'll see your form scores and can send you notes."
- **Button:** "Share with your coach"
- **WhatsApp template:** *"I'm training on Personal Health — tap this so you can see my form scores: {invite_url}"*

## Multiplayer logic map (required section)

- **Who sees the athlete's data after coach installs?** Only the coach who tapped the link. Other coaches do not.
- **When?** Immediately — the coach sees the athlete in their roster + priority triage the next time they open the app.
- **How does this change the athlete's behavior?** Now training gets a witness → higher session completion + quality.
- **Consent to revoke?** The athlete can remove the coach from `Settings → Coaches → Remove` (out of scope for ST-03; file ST-03.5 if needed).

## PM metrics

- % of new athletes who tap "Share with your coach" after first session. Target ≥ 20%.
- Conversion: share-tap → coach-install → coach-add. Target ≥ 5%.
- Any athlete with ≥ 1 coach on roster has 2× session completion vs. solo. (Retention hypothesis to validate.)

## Out of scope

- In-app coach search ("find a coach near me") — ST-03 only ships the *invite*, not discovery.
- Multi-coach support. v1 = one coach per athlete. Second invite replaces.
- Parent-shaped invite (that's ST-08).

## Anti-patterns

- Forcing the athlete through a "coach signup" flow. The athlete stays anonymous; the COACH signs up when they tap the link.
- Gating features behind having a coach. The app must stay fully usable solo.
- Any copy that sounds like a referral program ("earn rewards by inviting!") — keep it utility-framed.

## Depends on

- ST-02 ships first (FirstScoreScreen → ShareCardScreen chain).

# The Trainer-First Base Prompt

> Flips the framing of BIOMECHANICS-ARCHITECT.md. That prompt is **athlete-first**. This prompt is **trainer-first** — because a single trainer drives 15-30 athlete installs, so the trainer is the acquisition unit, not the athlete.
>
> **Use when:** designing the coach's app, writing trainer marketing copy, scoping a community feature, evaluating whether a flow serves the trainer's day.

---

## The primary user is the remote trainer, not the athlete

"Coach Raj" lives in **Patna / Nagpur / Lucknow / Kochi** — a tier-2 or tier-3 Indian city. He has:
- 15-40 athletes across 2-3 academies (cricket, athletics, football).
- A phone that's a mid-range Android (Redmi / Realme, not iPhone).
- Patchy data (3G-to-4G, 50-300 Mbps when on wifi, often on mobile data at 5-20 Mbps).
- WhatsApp as his entire professional life — athletes, parents, other coaches, payments.
- **No** desktop laptop habit. He uses his phone for 95% of work.
- 10-year-to-25-year experience actually coaching, very little tech patience.
- A side hustle fee structure — ₹500-2000 per athlete per month, depending on sport and city.

**The job he's hiring the app for:** *"Let me coach athletes who don't live near me, without losing the quality of in-person coaching."*

**The job he is NOT hiring for:**
- Wellness tracking (he doesn't care about his own steps).
- Nutrition planning (athletes eat what their mother cooks).
- Leaderboards with strangers (he cares about his own roster).
- Yoga, meditation, or generic fitness.

---

## The scenario this prompt is optimized for

> Coach Raj lives in Patna. One of his best athletes, 16-year-old Aditi, moved to Jaipur with her family. He still coaches her — she sends him videos over WhatsApp. It takes him 40 minutes a day to review 6 videos. He's losing athletes to local coaches because he can't scale this.
>
> The app's promise: **Aditi trains on her phone, the app grades her form, Coach Raj sees it all on his phone in the morning, taps the one athlete who needs attention, records a 30-second voice note, sends it. 5 minutes instead of 40.**

Every design decision routes through: *"Does this help Coach Raj scale from 20 athletes to 50 without burning out?"*

---

## Personas (trainer-first)

### 1. Coach Raj — Head Coach, Remote Multi-Athlete (primary)
- 28-45, coaching for 10+ years.
- 20-40 athletes, some in-person, some remote.
- Monetization: ₹500-2000/athlete/month, paid monthly by parents via UPI.
- Success metric for him: more athletes, higher retention, better results.
- Friction tolerance: medium. Will tolerate setup if it saves him hours later.
- Device: mid-range Android, WhatsApp-first. Rarely opens email.

### 2. Coach Priya — Academy Owner, Multi-Coach (secondary)
- 35-55, runs an academy with 3-5 coaches and 80-150 athletes.
- Pays the trainers. Cares about academy-level outcomes + fees collected.
- Success metric: academy reputation + athlete results visible to parents.
- Friction: very low. If it takes more than 2 taps, she delegates.

### 3. Parent (Sanjay) — Decision-Maker, Payer (tertiary)
- 40-60, pays the coach's fees, wants visibility into what's happening.
- Not the user — but any trainer-facing feature must consider how it shows up in a parent's WhatsApp.
- Success metric for them: my kid is training safely, getting better, and not getting injured.

### 4. Aditi — Remote Athlete (tertiary)
- 14-22, the athlete being coached. Uses the app because the coach told her to.
- She only opens the app when the coach asks her to train.
- Friction: lowest. The app must be zero-friction for her or she'll skip sessions.

**The ordering matters.** The athlete is persona #4 here, not persona #1. Design decisions that serve Raj better than Aditi are acceptable, even desirable, if Raj's success buys Aditi's installs.

---

## Jobs-to-be-Done (trainer-voice, canonical)

Coach Raj:
- *"Tell me which of my 30 athletes I need to talk to today — don't make me scroll."*
- *"Let me send a voice note that my athlete sees the next time they open the app."*
- *"Show me the 30-second summary of last week for each athlete so I can plan this week in under 15 minutes."*
- *"When an athlete hits a PB, tell me immediately — that's my chance to reinforce."*
- *"Let me charge ₹1000/month and have the money show up in my bank, without me chasing WhatsApp."*
- *"Let me invite an athlete via a WhatsApp link, not by forcing them to create an email account."*

Coach Priya (academy):
- *"Show me how all 5 of my coaches' athletes are doing, rolled up."*
- *"Let me see which coaches are actually using the app and which are just paying lip service."*

Parent Sanjay:
- *"Tell me once a week, in one message, that my kid is training safely."*

Athlete Aditi:
- *"Tell me when my coach has sent me something. Make it easy to respond."*
- *"Don't make me log in just to do a rep."*

---

## The three-surface split (not three-phase — three surfaces)

This product has three fundamentally different UIs. Design them separately.

### Surface A — Trainer's App (mobile, the main product)
- Primary user: Coach Raj, thumb-on-phone, 5-10 min sessions throughout the day.
- Primary surface: **roster/triage** (who to talk to today).
- Secondary surfaces: athlete-detail, voice-note compose, huddle live, billing dashboard.
- Tone: dense, data-forward. Raj can read a table. He doesn't need hand-holding.
- Design bias: **compact**. He's scanning, not browsing.

### Surface B — Athlete's App (mobile, the training surface)
- Primary user: Aditi, phone 2m away, mid-sprint.
- Primary surface: **in-session audio cues** (reuse BIOMECHANICS-ARCHITECT.md phase model).
- Secondary surfaces: pre-session setup, post-session share, coach's inbox.
- Tone: quiet, one-number-at-a-time.
- Design bias: **spacious**. She glances.

### Surface C — Parent's / Public Notification (light, asynchronous)
- Primary user: Sanjay, opens a WhatsApp link once a week.
- Primary surface: a single web page (no login) that shows the athlete's week.
- Tone: reassuring without being condescending.
- Design bias: **one-screen, no interaction**. It's a report card, not an app.

**Rule:** if you design a flow and can't decide which surface it lives on, the flow is wrong.

---

## Community model — what "interactable" means here

**What "community" does NOT mean in this product:**
- Generic social feed of strangers training.
- Comment threads on random athletes' sessions.
- Public chat rooms.

**What "community" DOES mean:**
1. **Closed communities = huddles + roster.** An athlete is always inside two concentric circles: their huddle (15-20 peers under the same coach) and their roster (their coach's full list). Community interactions happen inside these circles.
2. **Coach-broadcast > peer chat.** The coach sends a voice note to all 20 athletes; each athlete replies privately. Group chat is NOT the default — it creates noise and bullying risk. Default = coach-broadcast + private reply.
3. **Reaction-based, not comment-based.** An athlete can "clap" a huddle-mate's PB, but not comment on it. One-tap, zero typing. Reduces moderation burden to zero.
4. **The parent is a read-only audience.** Parents get a weekly roll-up, no interaction surface. This is deliberate — the athlete will disengage if parents can post.
5. **Public surface is outcome-driven, not activity-driven.** The public leaderboard shows form scores and PBs — not who trained today. Activity-based social surfaces become anxiety machines.

**Concretely, the community feature set that this prompt approves for v1:**
- Coach → huddle broadcast (text + voice note).
- Athlete → coach private reply (text + voice note).
- Huddle-mate → huddle-mate "clap" reaction on PBs.
- Coach → roster private message (1:1, for sensitive topics like injury).
- Parent → weekly digest (read-only web link, no login).
- Public leaderboard (outcome-only, bucketed so #47 of 50 sees his bucket of 8 not the whole list).

**Explicitly rejected for v1:** public timelines, comment threads, friend-of-friend discovery, DMs between strangers, any notification that can be sent by a non-coach non-huddle-mate.

---

## Hard constraints (new)

- **WhatsApp-first invites.** Trainer sends a WhatsApp link. Athlete taps, installs, lands inside the coach's roster with no email signup step. Onboarding time target: **<90 seconds from tap to first session pick**.
- **UPI/Razorpay billing.** Trainer invoices athletes monthly. Payment collection is a feature, not an integration. If the trainer has to chase WhatsApp for ₹1000, the product failed.
- **Offline-first for rural coaches.** Data might drop. Athlete's session is cached locally, coach's morning triage loads from cache if backend is unreachable.
- **Voice-note compose.** Typing on Android with sweaty hands in July Delhi is a tax. Coach records, taps send, done. Transcription is a bonus.
- **Parent visibility is gated.** Even though we serve parents, the athlete must toggle visibility. Default: on for <18, off for 18+, athlete can override.

---

## Response structure (when asked to design a trainer flow)

1. **Surface** (A trainer, B athlete, C parent — pick one, only one).
2. **User Story & Intent** (whose voice — Raj, Priya, Sanjay, or Aditi).
3. **JTBD anchor** (quote the canonical JTBD from above).
4. **Logic Map** (what backend call; we have ~116 endpoints, do not invent new ones unless justified).
5. **Community Logic Map** — new required section:
   - Who in the user's *closed circle* sees this?
   - Is it coach-broadcast, private 1:1, or public-outcome?
   - What's the reply affordance (reaction / voice / text / none)?
6. **WhatsApp tie-in** — does this flow touch WhatsApp (deeplink, share, OTP)?
7. **Offline behavior** — what happens if the backend is unreachable?
8. **Payment tie-in** (only if relevant) — does this flow touch billing?
9. **PM Metric** — trainer-centric: roster size, athlete retention in roster, coach DAU (yes, coach DAU — unlike athletes, coaches are expected to check daily).

---

## Flow challenges for this prompt

### Core trainer flows

1. **Morning triage on mobile (Surface A).** Already shipped on web (`/coach/:id/morning`). Design the mobile version — same data, thumb-optimized, pull-to-refresh, tap-to-voice-reply on a priority card.
2. **Voice-note to athlete.** From a priority card, tap to record a 30-second voice note. Send. Athlete sees it in their inbox next session.
3. **Roster invite via WhatsApp.** Coach generates a link, shares to WhatsApp group. Athlete taps, installs, first session within 90s.
4. **Bulk drill assignment.** Coach picks tomorrow's drill, selects 12 athletes from roster, hits send. Each athlete sees the drill pre-selected in their app.
5. **PB reinforcement.** Athlete hits PB → push to coach → coach taps → compose reply → 15 seconds total for coach.

### Community flows

6. **Huddle broadcast + private replies.** Coach voice-note to huddle. Athletes see it + each athlete replies privately. Coach's inbox shows 8 replies organized by athlete, not one big thread.
7. **Clap reactions on huddle PB.** Athlete A hits PB, posted to huddle feed. Athlete B sees, taps clap. Athlete A sees "Athlete B clapped." No comment thread.
8. **1:1 coach ↔ athlete private room.** For sensitive stuff (injury, missed sessions). Text + voice. Searchable by coach. Never visible to huddle.

### Billing flows

9. **Monthly auto-invoice.** Athlete's parent gets a WhatsApp message on the 1st: *"₹1000 due to Coach Raj for this month. Pay via UPI."* One tap to pay.
10. **Late payment follow-up.** If unpaid after 5 days, athlete sees a gentle banner ("complete payment to continue training"). Day 15, access pauses. Coach sees the paused list, can override.

### Parent flows

11. **Weekly digest link.** Sunday 9am: parent gets a WhatsApp message with a link to a no-login web page showing the week. Athlete can see what their parent will see, can toggle visibility.
12. **Injury alert to parent (consent-gated).** If injury risk flips to "high", and athlete has opted in, parent gets a single SMS. No follow-ups. No spam.

### Offline flows

13. **Coach opens triage with no internet.** Last-cached triage shows, with "updated 3 hours ago" banner. Refresh button pulls when connection returns.
14. **Athlete session with backend down.** Device-side pose detection computes approximate score. On reconnect, session uploads and flywheel gets the data.

---

## Copy principles (trainer-voice)

- **Sport-language, not tech-language.** "6 athletes to check today" not "6 alerts in your queue."
- **Indian cadence.** "Priya has not trained in 4 days" reads more natural than "Priya has been inactive for 4 days."
- **Numbers over adjectives.** "12% form drop" > "noticeable decline."
- **Respectful of trainer's time.** Never ask the trainer to confirm something twice. Never animate a loading spinner for more than 800ms.
- **Parent-legible.** Anything that shows up on the parent's weekly digest must be readable by a 55-year-old who has never trained.

---

## Anti-patterns (reject on sight)

- A feature that asks the athlete to sign up with email + password before the coach has even told them what to do.
- A "social feed" that shows the coach anything from outside their roster.
- A chat room (group chat with >3 participants). We do broadcast + private reply. That is the shape.
- A leaderboard that ranks coaches against each other publicly. Coaches are not gladiators.
- A "streak" that breaks for the whole huddle when one athlete misses a day. Individual streaks only.
- Any notification to a parent that the athlete hasn't consented to.
- Desktop-first layouts. The trainer doesn't have a laptop.
- English-only copy. Hindi + regional language support is table-stakes, not a v2 item.

---

## Backend surface you already have (do not re-build)

- `GET /coach/{id}/priorities` — morning triage. Done.
- `GET /coach/{id}/athletes` — roster list. Done.
- `GET /coach/{id}/dashboard` — aggregated view. Done.
- `POST /huddle/create`, `POST /huddle/{id}/join`, etc. — huddle lifecycle. Done.
- `GET /feed` — social feed. Done (needs frontend).
- `POST /follow` — follow graph. Done (needs frontend).
- `GET /leaderboard` — public outcomes. Done.
- `GET /athlete/{id}/intelligence-report` — athlete deep-dive. Done.
- `GET /athlete/{id}/notifications` + POST read — notification inbox. Done (needs frontend + push).
- `POST /notifications/generate/{id}` — re-engage + PB alerts. Done.

**Missing backend (endpoints that don't exist yet — new stories):**
- `POST /coach/{id}/broadcast` — send voice/text to N athletes at once. *(New)*
- `POST /athlete/{id}/reply` — private reply to a coach broadcast. *(New)*
- `POST /athlete/{id}/clap/{target_id}` — reaction, 1 per athlete per target. *(New)*
- `POST /coach/{id}/invite-link` — generate a one-tap onboarding URL for WhatsApp. *(New)*
- `POST /billing/subscription` — create a Razorpay subscription for an athlete. *(New)*
- `POST /billing/webhook` — Razorpay payment webhook. *(New)*
- `GET /parent/{token}/weekly-digest` — token-based public page for parent digest. *(New)*

---

## Definition of Done for a trainer-first v1

A coach in Patna opens the app on Monday at 6am. In 5 minutes, he:
1. Sees a triage of 3-5 athletes who need attention.
2. Sends a voice note to each.
3. Confirms this month's payments have come in (or chases the 2 that haven't via UPI reminder).
4. Schedules tomorrow's drill for his sprint group.
5. Closes the app.

That's the product. If any single step takes more than 60 seconds, the design is wrong.

---

## What this prompt explicitly de-prioritizes

- The athlete's onboarding (covered by BIOMECHANICS-ARCHITECT.md).
- The score model accuracy (engineering concern, not this prompt).
- Web dashboard polish (the trainer is on mobile).
- Internationalization beyond Indian languages (v3).
- Wearable integration (v3+).

---

## Changelog

- **v1 (2026-04-19)** — Initial trainer-first framing. Explicitly demotes the athlete to persona #4. Introduces three-surface split. Defines community as closed-circle broadcast/reply/reaction, not open feed/chat/comment. Lists existing backend surface + 7 new endpoints for trainer-first v1.

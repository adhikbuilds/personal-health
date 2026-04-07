# Sprint: Personal Fitness V2 — Premium Coaching Platform

**PM:** Adhik Agarwal (acting as Technical Product Manager)
**Build:** Adhik (backend deepening) + Claude buddy (frontend/android polish)
**Repos:** github.com/adhikbuilds/{personal-health-backend, personal-health-frontend, personal-health-android}
**Branch:** `develop` only
**Date:** 8 April 2026
**Stop:** 6:30 AM IST

---

## 0. Skills Stack Used

This sprint was generated using the full PM + UI/UX skills library:

| Skill | What it gave us |
|-------|-----------------|
| `jobs-to-be-done` | Functional/social/emotional jobs for athletes, coaches, parents |
| `proto-persona` | 3 hypothesis-driven personas (athlete, coach, parent) |
| `problem-statement` | 5-part canonical framing (I am / Trying to / But / Because / Which makes me feel) |
| `opportunity-solution-tree` | 4 opportunities → solution choices with rationale |
| `user-story` | Mike Cohn + Gherkin acceptance criteria for every story |
| `positioning-statement` | Anchor for the design language decisions |
| `ui-ux-pro-max --design-system` | Recommended pattern (Real-Time Operations Landing), font pairing (Barlow Condensed + Barlow), color cues |
| `ui-ux-pro-max --domain style` | Style choice: **Modern Dark (Cinema Mobile)** — for fintech/AI/pro tool feel |
| `ui-ux-pro-max --domain ux` | Loading states, animation, accessibility guidelines applied per story |

---

## 1. The Aim (Why this exists)

**Core thesis** (from VISION.md):
> Build the coaching infrastructure for the 99% of athletes who can't afford a personal coach or biomechanics lab. The phone is the lab. The AI is the coach.

**Where we are today:**
- Backend is functionally production-ready (PF-01 to PF-13 done in V1)
- 30 athletes seeded, 528 sessions, 95.2% real ML accuracy (post data-leakage fix)
- Form scoring, rPPG heart rate, phase detection for 8 sports, injury risk flags, prediction logging — all working
- Frontend dashboard exists but **looks like a developer tool, not a coaching platform**
- Android app works but **lacks visual hierarchy, micro-interactions, and emotional resonance**

**The gap V2 closes:**
The platform DOES the right things. It doesn't FEEL like the right things. A coach who sees this dashboard for 10 seconds should think "this is professional infrastructure I can trust with my athletes," not "this looks like a college project." That's what V2 delivers.

---

## 2. Problem Statement (5-part framing)

> **I am** a young Indian athlete (17–28) training 4–5x per week without a personal coach, OR a sports academy coach managing 15–30 athletes simultaneously.
>
> **I'm trying to** track form, performance, and recovery using a phone-first AI tool that gives me numbers I trust enough to make daily training decisions.
>
> **But** the current Personal Health interface looks like a developer dashboard — flat cards, no hierarchy, no emotional cues, no premium feel. When I show it to a coach, they dismiss it as "an app." When I show it to a parent, they don't understand if it's serious infrastructure.
>
> **Because** the V1 build prioritised functional correctness over experience. The data is real, the model is honest, the API is solid — but the UI doesn't communicate any of that.
>
> **Which makes me feel** that the work we've done is being undervalued, and athletes who'd benefit are bouncing before they trust it.

---

## 3. Jobs-to-be-Done

### 3.1 Customer Jobs

**Functional Jobs:**
- Open the app and instantly see whether I'm ready to train hard today
- Glance at a session summary in 5 seconds and know if my form is improving
- Show my coach data that they can trust without explanation
- Understand WHY my form score dropped, not just THAT it dropped
- Get one clear next-action after every session

**Social Jobs:**
- Look serious in front of my coach (data-driven, not vibes)
- Be the athlete in my circle who actually tracks this stuff
- Show parents that I'm training safely and intelligently
- Share a session result on Instagram without it looking amateur

**Emotional Jobs:**
- Trust the form score number (when it says 78, believe it)
- Feel safe — the app warns me before I get hurt
- Feel in control — I know what to do today, and why
- Avoid the dread of "am I doing this right?" between coach sessions

### 3.2 Pains

**Challenges:**
- Existing Indian sports apps are gamified consumer products — not credible to coaches
- International apps (Hudl, Coach's Eye) are expensive and not built for vertical jump / kabaddi / sprint
- Coaches won't adopt anything that needs >5 minutes to understand

**Costliness:**
- A real biomechanics analysis costs ₹5,000–15,000 per session at a sports lab
- A personal coach in tier-2 cities is ₹15,000–30,000/month
- Wearables (Garmin, Whoop) cost ₹25,000–60,000 upfront

**Common Mistakes:**
- Athletes train hard the day after a bad night's sleep because nothing tells them not to
- Form drifts gradually over weeks; they don't notice until injury
- Coaches give generic feedback because they have 25 athletes and no data

**Unresolved Problems:**
- No tool combines biomechanics + heart rate + recovery + injury risk in one phone-first product for Indian athletes
- No tool tells you "skip the heavy session today" with confidence

### 3.3 Gains

**Expectations:**
- See a score and immediately understand what it means without a manual
- Get insights that feel personal, not generic ("your left knee is 8° tighter than last week")
- The app looks polished enough to share screenshots without embarrassment

**Savings:**
- Replace ₹5,000 lab session with a free phone scan
- Coach can manage 30 athletes instead of 10 with the same attention quality
- Athletes catch form drift in days, not months — preventing weeks of rehab

**Adoption Factors:**
- Works on a basic Android phone (no expensive gear)
- Coach dashboard is web-based, no app install needed
- First insight visible in <60 seconds of opening the app

**Life Improvement:**
- I train smarter, peak at the right time, avoid preventable injuries
- I have a record of my progress to show selectors / scholarship committees
- I feel like a real athlete, not someone playing pretend

---

## 4. Proto-Personas

### Persona 1: Aryan, the Aspiring Athlete

**Bio:** 19, sprinter, district-level, Lucknow. Trains 5 days/week. Owns a ₹15,000 phone. No personal coach. Uses Instagram for everything.

**Quotes:**
- "I just want to know if I'm getting better or wasting my time."
- "If my coach saw real numbers, maybe he'd take me to nationals."
- "Yaar, I'm tired of guessing."

**Pains:**
- Trains alone, no feedback loop
- Doesn't know if his form is degrading
- Can't afford a coach or wearable

**Trying to accomplish:** Qualify for state-level. Get a sports scholarship. Avoid burnout.

**Goals:** Sub-11s in 100m. Train consistently for 6 months. Build a public portfolio of progress.

**Decides based on:** Whether the app is free, looks credible, and gives useful feedback in his first session.

---

### Persona 2: Coach Rajesh, the Multi-Athlete Coach

**Bio:** 42, head coach at a district sports academy in Jaipur. Trained 200+ athletes over 18 years. Manages 25 active athletes right now. Uses WhatsApp for everything but resents it.

**Quotes:**
- "I have 25 athletes. I cannot watch each one for 30 minutes."
- "Show me who's at risk before I start the session, not after they pull a hamstring."
- "If the data is wrong I'll know in 10 minutes — and I'll never use it again."

**Pains:**
- Can't be everywhere
- Has no objective record of who's improving vs plateauing
- Gets blamed when athletes get injured even when he warned them

**Trying to accomplish:** Send 2-3 athletes to nationals every year. Reduce injury rates. Justify his salary to the academy board.

**Goals:** A dashboard showing all 25 athletes' wellness + form trend at a glance. Pre-session readiness check.

**Decides based on:** Whether the dashboard works in 30 seconds without training. Whether the data matches what he sees in person.

---

### Persona 3: Meera, the Worried Parent

**Bio:** 44, mother of a 16-year-old swimmer in Pune. Pays ₹8,000/month for her son's training. Doesn't understand sports tech but worries constantly.

**Quotes:**
- "I just want to know he's not pushing too hard."
- "Is this safe? Show me one number that tells me he's okay."
- "If I can't see what's happening, I'll just say no to early-morning training."

**Pains:**
- No visibility into what her son does at training
- Can't tell coach from athlete bullshit
- Worried about long-term injury

**Trying to accomplish:** Keep her son healthy while supporting his ambition.

**Goals:** A weekly summary she can read in 2 minutes. A red/yellow/green status for "is my kid okay."

**Decides based on:** Whether the app explains things in normal language and gives her one clear status indicator.

---

## 5. Opportunity-Solution Tree

| Opportunity | Solution Chosen | Solutions Considered | Why This One |
|-------------|-----------------|----------------------|--------------|
| Athletes don't trust the form score number | **Show provenance:** display the joint angles + injury flags + confidence beside every score, so athletes can see WHY | (a) Add a help tooltip explaining the formula. (b) Show a confidence percentage. (c) Show provenance card with raw inputs. | Tooltips get ignored. Confidence alone is opaque. Showing the inputs makes the score auditable — coach approves on inspection. |
| Coaches can't scan 25 athletes in 30 seconds | **Ranked attention list:** dashboard shows athletes sorted by "needs attention" (red flags first, declining trends second, stable last) | (a) Alphabetical list. (b) Group by tier. (c) Sort by "needs attention." | Coach's job is triage. The dashboard should do the triage for him. |
| Parents don't understand any of this | **Single readiness number** + traffic light, with optional 1-line explanation. No charts. | (a) Simplified parent dashboard. (b) Weekly text/email summary. (c) One number + traffic light on the main dashboard, parent-mode toggle. | Building a separate parent dashboard doubles the work. One indicator everyone sees works for athlete + parent + coach. |
| The product looks like a developer tool | **Adopt Modern Dark (Cinema Mobile) style** + Barlow Condensed type pairing + glass headers + halo insight cards | (a) Stay with current cyan flat. (b) Adopt Sprout's warm gold gradient. (c) Adopt Modern Dark Cinema with sport-specific typography. | The Modern Dark Cinema style is explicitly recommended by UI/UX Pro Max for "developer tools, fintech, AI interfaces, gaming companion apps" — exactly the credibility we want. Barlow Condensed is the recommended sport font pairing. |

---

## 6. Positioning Statement

> **For** Indian athletes 17–28 training without a personal coach, and the academy coaches who can't watch every session,
> **Personal Health** is a phone-first sports biomechanics platform
> **that** grades form in real-time, tracks heart rate via the camera, flags injury risk before it happens, and gives every athlete an audit-quality record of their progress
> **so that** athletes train smarter, coaches manage 30 instead of 10, and the next generation of Indian athletes peaks at the right competitions instead of breaking down in training.
>
> **Unlike** Hudl or Coach's Eye (built for affluent Western teams) or HealthifyMe (a generic consumer fitness tracker),
> **Personal Health** is built for the 99% — works on any phone, no wearable required, and trained on Indian sports we actually play.

---

## 7. Design Language — Personal Health Cinema (PH-DLS v2)

**Style:** Modern Dark (Cinema Mobile) — sourced from UI/UX Pro Max
**Typography:** Barlow Condensed (display) + Barlow (body) — sourced from UI/UX Pro Max sport pairing
**Why:** This style is explicitly tagged for "developer tools, pro productivity apps, fintech/trading dashboards, AI tool interfaces, high-end gaming companion apps" — that's exactly the credibility we want. Barlow Condensed is THE sport typography on Google Fonts.

### 7.1 Color Tokens (final, from UI/UX Pro Max + project legacy)

```css
/* Backgrounds — gradient base, no pure #000 (OLED smear) */
--ph-bg-deep:      #020203;
--ph-bg-base:      #050506;
--ph-bg-elevated:  #0a0a0c;
--ph-surface:      rgba(255, 255, 255, 0.05);
--ph-surface-2:    rgba(255, 255, 255, 0.08);
--ph-border:       rgba(255, 255, 255, 0.08);   /* hairline */
--ph-border-2:     rgba(255, 255, 255, 0.12);

/* Brand — keep cyan for continuity, add accent glow */
--ph-brand:        #06b6d4;
--ph-brand-glow:   rgba(6, 182, 212, 0.20);
--ph-brand-deep:   #0891b2;

/* Performance — warm amber for personal-best moments */
--ph-pb:           #f59e0b;       /* personal best */
--ph-pb-glow:      rgba(245, 158, 11, 0.18);

/* Status — for injury flags, recovery, fatigue */
--ph-success:      #10b981;
--ph-success-glow: rgba(16, 185, 129, 0.18);
--ph-caution:      #f59e0b;
--ph-caution-glow: rgba(245, 158, 11, 0.18);
--ph-alert:        #ef4444;
--ph-alert-glow:   rgba(239, 68, 68, 0.20);

/* Text */
--ph-text:         #ededef;
--ph-text-muted:   #8a8f98;
--ph-text-dim:     #5a5e66;
```

### 7.2 Typography

```css
/* From UI/UX Pro Max recommendation — Sports/Fitness pairing */
@import url('https://fonts.googleapis.com/css2?family=Barlow+Condensed:wght@400;500;600;700;800&family=Barlow:wght@300;400;500;600;700&display=swap');

--font-display: 'Barlow Condensed', system-ui, sans-serif;  /* headlines, stat values */
--font-body:    'Barlow', system-ui, sans-serif;            /* body text */
--font-mono:    'JetBrains Mono', monospace;                /* tabular numerics */
```

**Hierarchy:**
- Hero headline: Barlow Condensed 800, 48-64px, letter-spacing -0.02em
- Section headers: Barlow Condensed 700, 24px, uppercase
- Stat values: JetBrains Mono 800, 32-48px, tabular-nums
- Card titles: Barlow 700, 16px
- Labels: Barlow 600, 11px, UPPERCASE, letter-spacing 0.5px
- Body: Barlow 400, 14px, line-height 1.6

### 7.3 Layout & Spacing

- Border radius: 16px (cards/buttons), 12px (small elements), 20px (hero cards)
- Spacing scale: 4 / 8 / 12 / 16 / 24 / 32 / 48 / 64 / 96
- Card padding: 20px (compact), 24px (default), 32px (hero)
- Border: hairline (0.5px on retina, 1px elsewhere)
- Easing: `cubic-bezier(0.16, 1, 0.3, 1)` (Expo.out — buttery)
- Press scale: 0.97 → 1.0 with 200ms easing
- Animation duration: 200-300ms for micro, 400ms for entrance

### 7.4 Signature Components

**1. Stat Card (KPI tile)**
```
- 16px radius, hairline border, 24px padding
- Icon: 40×40, rounded 12px, color-tinted bg with inset top-edge highlight
- Label: 11px uppercase Barlow 600
- Value: 32px JetBrains Mono 800, tabular-nums
- Delta indicator (optional): 12px Barlow 500, green/red arrow
- Hover: translateY(-2px), border brightens to var(--ph-border-2), accent glow shadow
```

**2. Insight Card (status-aware with halo)**
```
- 16px radius, status-tinted border (success/caution/alert)
- Halo: absolute positioned blob, top-right -48px / -48px, 160×160, blur 60px
- Halo color matches status (success-glow / caution-glow / alert-glow)
- Icon box: 44×44, rounded 14px, status bg + status text color
- Title: Barlow 700 16px
- Body: Barlow 400 13px secondary text
- Optional CTA button at bottom right
- Collapsible content uses grid-rows transition
```

**3. Glass Live Header (real-time data)**
```
- BlurView intensity 60, tint dark
- backdrop-filter: blur(16px)
- background: rgba(10, 10, 12, 0.75)
- border-bottom: hairline rgba(255,255,255,0.08)
- LIVE pulse dot in header (animated breathing)
- Stat values use Barlow Condensed 800, large
```

**4. Athlete Avatar (consistent across screens)**
```
- 40×40 circle, brand-tinted background
- Initials in Barlow Condensed 700 16px
- Border: hairline rgba(255,255,255,0.12)
- Optional status ring (success/caution/alert) — 2px outer ring
```

**5. Tier Badge**
```
- Pill shape, 11px Barlow 600 uppercase
- Block:    rgba(100,116,139,0.15) text #94a3b8
- District: rgba(6,182,212,0.15)   text #06b6d4
- State:    rgba(245,158,11,0.15)  text #f59e0b
- National: rgba(139,92,246,0.15)  text #a78bfa
- Elite:    linear-gradient(90deg, #f59e0b, #fbbf24) text #1a0f00 (gold pill)
```

### 7.5 Animation Patterns (UI/UX Pro Max guidelines)

- Loading: skeleton screen with `animate-pulse`, NEVER blank UI
- Press: scale 0.97 → 1.0 with `cubic-bezier(0.16, 1, 0.3, 1)`, 200ms
- Card entry: `translateY(8px) → 0` + `opacity 0 → 1`, 400ms, **staggered** by 75ms per card
- Numeric updates: count-up animation on first render, instant on update
- Live metrics: subtle pulsing dot (NOT full card breathing)
- Reduced motion: respect `prefers-reduced-motion`, instant transitions

---

## 8. User Stories — Prioritized

**Note:** Backend stories (PH-V2-B-*) are for Adhik working in parallel. Frontend (PH-V2-F-*) and Android (PH-V2-A-*) for Claude buddy.

---

### EPIC A — BACKEND DEEPENING (Adhik working in parallel)

---

#### PH-V2-B-01: Athlete Profile Endpoint Bundle

**As a** frontend developer rendering an athlete profile,
**I want** a single endpoint that returns everything needed to render the profile (athlete + recent sessions + insights + injury history),
**so that** I don't need to chain 4 requests.

**Acceptance Criteria:**
- **Given** `routes/athletes.py` currently has separate endpoints for athlete, progress, insights
- **When** a new bundled endpoint is added
- **Then** `GET /athlete/{id}/profile` returns: `{athlete, recent_sessions[10], insights, injury_history, weekly_summary}`
- **And** the response is computed in one DB pass (no N+1)
- **And** the existing separate endpoints are kept (don't break frontend)
- **And** response time is under 200ms for the seeded data

**Tech notes:**
- File: `routes/athletes.py`
- Reuse existing helpers, just compose the response
- Add `injury_history` from prediction logs filtered by athlete

---

#### PH-V2-B-02: Pre-Session Readiness Score Endpoint

**As a** coach about to start a training session,
**I want** a single endpoint that returns each athlete's "ready / caution / rest" status,
**so that** I can see triage at a glance before athletes arrive.

**Acceptance Criteria:**
- **Given** an athlete has injury_flags from recent sessions and a wellness_score (if available)
- **When** `GET /coach/readiness?athlete_ids=...` is called
- **Then** response is `[{athlete_id, status: "ready|caution|rest", reasons: [...], last_session_date}]`
- **And** status is "rest" if any recent injury_flag = critical
- **And** status is "caution" if asymmetry warnings in last 3 sessions
- **And** status is "ready" otherwise
- **And** the response is sorted: rest first, caution second, ready last (triage order)

**Tech notes:**
- File: `routes/athletes.py` or new `routes/coach.py`
- Read injury flags from `db/predictions.jsonl`

---

#### PH-V2-B-03: Form Score Provenance — Show Why

**As an** athlete getting a form score of 78,
**I want** the API to return WHY that score (which joints contributed positively/negatively),
**so that** the score is auditable, not magical.

**Acceptance Criteria:**
- **Given** the analysis_worker computes form_score from joint angles
- **When** `/session/{id}/latest-result` is called
- **Then** the response includes `provenance: {top_strengths: [{joint, deviation, contribution}], top_weaknesses: [{joint, deviation, contribution}]}`
- **And** strengths/weaknesses are derived from joint deviation from sport ideal angles
- **And** contribution is a percentage of how much that joint affected the final score
- **And** at least 2 strengths and 2 weaknesses are returned (or "insufficient data" if fewer)

**Tech notes:**
- File: `routes/fitness.py` analysis_worker, `services/pose_analyzer.py`
- Add a `compute_provenance()` helper in pose_analyzer

---

### EPIC F — FRONTEND PREMIUM REBUILD

---

#### PH-V2-F-01: Cinema Dark Color Tokens + Barlow Typography

**As a** developer styling new components,
**I want** all colors and fonts centralized in CSS variables matching PH-DLS v2,
**so that** every page uses the same design language.

**Acceptance Criteria:**
- **Given** existing CSS files use cyan-only palette and Inter font
- **When** the design tokens are added
- **Then** `public/css/tokens.css` is created with all PH-DLS v2 variables (`--ph-bg-deep`, `--ph-pb`, etc.)
- **And** `views/index.ejs`, `views/dashboard.ejs`, `views/wellness.ejs`, `views/map.ejs` all import `tokens.css` first
- **And** Barlow Condensed + Barlow are imported from Google Fonts in tokens.css
- **And** existing components that hardcode colors are migrated to use the variables (at least the high-traffic ones: stat cards, navbar, hero)
- **And** all four pages still load without visual regression

---

#### PH-V2-F-02: Premium Hero with Live Data + Halo Cards

**As a** first-time visitor,
**I want** the landing page hero to feel like a premium analytics platform,
**so that** I trust this as serious infrastructure within 5 seconds.

**Acceptance Criteria:**
- **Given** the current landing has flat hero stats and 3 emoji-style feature cards
- **When** redesigned
- **Then** the hero has:
  - Headline in Barlow Condensed 800, 56-64px, with a subtle gradient text fill
  - 4 stat cards in a row: Athletes, Sessions, Avg Form Score (warm amber accent), Active Now
  - Each stat card has the new design (icon box, tabular-nums value, hover lift)
  - Stats animate in with stagger (75ms per card)
- **And** below the hero, 3 INSIGHT cards (not feature cards) with halo backgrounds:
  1. **Form Analysis** — success halo, "Real-time biomechanics from your camera"
  2. **Injury Prevention** — caution halo, "Asymmetry tracking flags risk early"
  3. **Heart Rate** — info halo, "rPPG via front camera, no wearable"
- **And** halos are CSS radial-gradients (not images), top-right of each card
- **And** all 3 cards lift on hover and use the cinema dark color tokens

---

#### PH-V2-F-03: Dashboard Stat Cards Premium Upgrade

**As a** coach opening the dashboard,
**I want** the 4 top stats to feel like a Bloomberg terminal, not a college project,
**so that** I trust the platform with my athletes.

**Acceptance Criteria:**
- **Given** dashboard.ejs currently has plain stat cards with cyan numbers
- **When** redesigned with PH-DLS v2
- **Then** each stat card has:
  - 40×40 icon box with color-tinted bg, inset top-edge highlight, and matching glow shadow
  - Label in Barlow 600 11px UPPERCASE
  - Value in JetBrains Mono 800 32px tabular-nums
  - Optional delta in Barlow 500 12px below the value
  - Hairline border that brightens on hover
  - translateY(-2px) hover lift with brand glow shadow
- **And** the Avg Form Score card uses the warm amber (`--ph-pb`) accent
- **And** the other 3 cards use the brand cyan
- **And** stat cards are wrapped in a `.ph-stat-card` class so the same component can be reused on landing

---

#### PH-V2-F-04: Recent Sessions — Avatars, Color Dots, Time-Ago

**As a** coach scanning recent sessions,
**I want** athlete names with avatar circles, color-coded form scores (green/amber/red dot), and time-ago labels,
**so that** I can identify problem sessions in 2 seconds.

**Acceptance Criteria:**
- **Given** the Recent Sessions table currently shows raw athlete IDs and frame counts
- **When** redesigned
- **Then** each row has:
  - 36×36 athlete avatar circle (initials, brand-tinted bg, hairline border)
  - Athlete name in Barlow 600 14px
  - Sport name in Barlow 400 12px muted
  - Form score with a 8×8 status dot to the left (success/caution/alert based on thresholds)
  - Time-ago label ("2h ago", "yesterday")
- **And** the entire row is clickable (cursor:pointer) and opens the existing progress panel
- **And** rows have hover background highlight
- **And** if 0 sessions, shows empty state with skeleton-style placeholder

---

#### PH-V2-F-05: Live Metrics Glass Header (Real-Time Card)

**As a** coach watching a live session,
**I want** the live metrics to appear in a glass-morphism floating card with a pulsing LIVE dot,
**so that** my eye instinctively goes there for real-time data.

**Acceptance Criteria:**
- **Given** an active session is detected
- **When** the live metrics card appears
- **Then** the card uses `backdrop-filter: blur(16px)` and `background: rgba(10, 10, 12, 0.75)`
- **And** the header shows a pulsing green dot + "LIVE" label in Barlow 700 11px
- **And** the 6 metric values use JetBrains Mono 800 with the warm amber accent
- **And** the live form score chart has a subtle gradient fill below the line (from brand cyan to transparent)
- **And** when no session is active, the card hides smoothly (opacity 0 → display:none after 300ms)

---

#### PH-V2-F-06: Leaderboard with Tier Badges + Triage Sort Toggle

**As a** coach reviewing the leaderboard,
**I want** to toggle between BPI ranking and "needs attention" triage,
**so that** I can choose between celebration view and intervention view.

**Acceptance Criteria:**
- **Given** the leaderboard currently shows BPI ranking only
- **When** the toggle is added
- **Then** a small toggle in the leaderboard header switches between "By BPI" and "Needs Attention"
- **And** in "Needs Attention" mode, athletes with injury_flags or declining trend appear first
- **And** each row shows the tier as a colored pill badge (Block/District/State/National/Elite)
- **And** Elite tier uses a gold gradient pill (linear-gradient amber → gold)
- **And** rank #1, #2, #3 still get gold/silver/bronze in BPI mode
- **And** clicking a row opens the existing progress panel (no regression)

---

#### PH-V2-F-07: Wellness Page Preview Tiles

**As a** user clicking Wellness,
**I want** to see what the wellness module will actually do (preview tiles),
**so that** I'm excited rather than seeing a dead end.

**Acceptance Criteria:**
- **Given** /wellness currently shows a single coming-soon card
- **When** redesigned
- **Then** the page shows 4 preview tiles in a 2x2 grid:
  1. **Nutrition Tracking** — mock meal log card with calories, "Coming Soon" pill
  2. **Sleep Quality** — mock sleep score with bar chart, "Coming Soon" pill
  3. **Recovery Score** — mock circular progress ring, "Coming Soon" pill
  4. **Hydration** — mock daily intake bar, "Coming Soon" pill
- **And** each tile has a soft greyscale filter to indicate inactive state
- **And** below the tiles, a single CTA: "Notify me when wellness ships" (visually clickable but no backend)
- **And** all uses the dashboard sidebar layout (consistent navigation)

---

### EPIC A — ANDROID PREMIUM REBUILD

---

#### PH-V2-A-01: Centralized Color & Typography Tokens

**As a** developer building Android screens,
**I want** colors, fonts, spacing, and radius constants centralized in `src/styles/tokens.js`,
**so that** every screen uses the same design language.

**Acceptance Criteria:**
- **Given** colors are scattered as hex strings across screens
- **When** tokens are centralized
- **Then** `src/styles/tokens.js` exports `COLORS`, `TYPOGRAPHY`, `SPACING`, `RADIUS`, `SHADOW`, `EASING` constants
- **And** COLORS includes all PH-DLS v2 tokens (bgDeep, bgBase, brand, brandGlow, pb, pbGlow, success, caution, alert, text, textMuted, etc.)
- **And** `TYPOGRAPHY` includes display/body/mono font families and size/weight/letterSpacing presets
- **And** `EASING` exports the cubic-bezier(0.16, 1, 0.3, 1) easing function for Animated
- **And** `src/styles/colors.js` re-exports from tokens.js for backwards compatibility (don't break existing imports)

---

#### PH-V2-A-02: Reusable StatCard Component

**As an** athlete viewing my stats across HomeScreen, MetricsScreen, HubScreen,
**I want** all my stats to look identical and premium,
**so that** the app feels cohesive.

**Acceptance Criteria:**
- **Given** stats are inconsistently styled across screens
- **When** `src/components/StatCard.js` is created
- **Then** the component takes props: `label, value, icon, color (default 'brand'), delta, onPress`
- **And** the card is 16px radius, hairline border, 20px padding
- **And** the icon is a 40×40 box with color-tinted bg + inset highlight
- **And** the label is Barlow 600 11px uppercase
- **And** the value is JetBrains Mono 800 28px tabular-nums (uses fontVariant: ['tabular-nums'])
- **And** delta (if provided) shows below value as 12px with green/red color
- **And** onPress (if provided) makes the card pressable with scale 0.97 → 1.0 animation
- **And** at least HomeScreen is updated to use this component

---

#### PH-V2-A-03: Reusable InsightCard Component

**As an** athlete who finished a session,
**I want** the app to surface insights (improvement, asymmetry warning, peak) in a beautiful card,
**so that** I get value beyond raw numbers.

**Acceptance Criteria:**
- **Given** the backend returns injury_flags and primary_feedback
- **When** `src/components/InsightCard.js` is created
- **Then** props: `type ('success'|'caution'|'alert'|'info'), title, message, ctaLabel, onPress`
- **And** the card has a hairline border in the matching status color
- **And** a halo effect: an absolutely positioned View with `borderRadius: 80, backgroundColor: statusGlow, top: -40, right: -40, width: 160, height: 160, opacity: 0.5`
- **And** the icon (Ionicons) matches the type: success=checkmark, caution=warning, alert=alert-circle, info=information
- **And** title in Barlow 700 16px, message in Barlow 400 13px muted
- **And** optional CTA button at bottom right with the status color
- **And** TrainScreen post-session view uses this component

---

#### PH-V2-A-04: Glass Live Header for TrainScreen

**As an** athlete recording a session,
**I want** my live form score to appear in a glass header at the top of the camera view,
**so that** I see my score without obscuring the camera feed.

**Acceptance Criteria:**
- **Given** TrainScreen currently shows form score in the bottom area
- **When** the glass header is added
- **Then** a header at the top uses `BlurView` from `expo-blur` (intensity 60, tint 'dark')
- **And** background tint: `rgba(10, 10, 12, 0.6)`
- **And** the header shows: form score (Barlow Condensed 800 36px), phase indicator (Barlow 600 12px uppercase), pulsing LIVE dot
- **And** the header is 64px tall, full width, positioned absolute top
- **And** safe area inset is respected (no overlap with status bar)
- **And** taps pass through to the camera button (pointerEvents='box-none' on container)

---

#### PH-V2-A-05: HomeScreen Layout Hierarchy

**As an** athlete opening the app,
**I want** the HomeScreen to follow a clear hierarchy from "today's status" → "stats" → "actions",
**so that** I instantly know what's important and what to do.

**Acceptance Criteria:**
- **Given** HomeScreen has many sections in flat order
- **When** restructured
- **Then** the layout (top to bottom) is:
  1. Greeting + date (small Barlow 400 secondary text, 12px)
  2. **Hero readiness card** — large card with single big number (today's readiness 0-100), color-coded status (ready/caution/rest)
  3. **2x2 grid of StatCard** — Today's BPI, This Week Sessions, Avg Form, Streak Days
  4. **Optional InsightCard** — if backend has any flag/insight for the athlete
  5. **Quick Actions row** — Train, RPPG, Map (3 large pressable tiles)
  6. **Recent sessions** — last 5 sessions in a list with mini avatars
- **And** ScrollView spacing 24px between sections
- **And** all stat displays use the new StatCard component
- **And** the readiness card uses the warm amber for highlight when score >= 75

---

#### PH-V2-A-06: Premium Tab Bar with Haptic Feedback

**As an** athlete tapping a tab,
**I want** subtle haptic feedback and a smooth color transition,
**so that** the app feels alive and responsive.

**Acceptance Criteria:**
- **Given** the tab bar uses Ionicons (after V1 AN-04)
- **When** premium feedback is added
- **Then** tapping a tab triggers `Haptics.impactAsync(Haptics.ImpactFeedbackStyle.Light)` from `expo-haptics`
- **And** the active tab icon color animates (200ms) from muted to brand cyan
- **And** the active tab gets a 4px wide top border in brand color
- **And** the tab bar uses BlurView with intensity 80 dark tint
- **And** the tab bar background is `rgba(10, 10, 12, 0.85)`

---

## 9. Story Index

| ID | Title | Layer | Priority | Effort | Depends |
|----|-------|-------|----------|--------|---------|
| **Backend (Adhik)** | | | | | |
| PH-V2-B-01 | Athlete profile bundle endpoint | Backend | P0 | 1 hr | — |
| PH-V2-B-02 | Pre-session readiness endpoint | Backend | P0 | 1 hr | — |
| PH-V2-B-03 | Form score provenance | Backend | P1 | 2 hr | — |
| **Frontend (Buddy)** | | | | | |
| PH-V2-F-01 | Color tokens + Barlow typography | Frontend | P0 | 1 hr | — |
| PH-V2-F-02 | Premium hero + halo insight cards | Frontend | P0 | 2 hr | F-01 |
| PH-V2-F-03 | Dashboard stat cards upgrade | Frontend | P0 | 1 hr | F-01 |
| PH-V2-F-04 | Recent sessions w/ avatars + dots | Frontend | P0 | 2 hr | F-01 |
| PH-V2-F-05 | Live metrics glass header | Frontend | P1 | 1 hr | F-01 |
| PH-V2-F-06 | Leaderboard tier badges + triage | Frontend | P1 | 2 hr | F-01, B-02 |
| PH-V2-F-07 | Wellness preview tiles | Frontend | P1 | 1 hr | F-01 |
| **Android (Buddy)** | | | | | |
| PH-V2-A-01 | Centralized tokens.js | Android | P0 | 1 hr | — |
| PH-V2-A-02 | StatCard component | Android | P0 | 2 hr | A-01 |
| PH-V2-A-03 | InsightCard component | Android | P0 | 2 hr | A-01 |
| PH-V2-A-04 | Glass live header on TrainScreen | Android | P1 | 2 hr | A-01 |
| PH-V2-A-05 | HomeScreen layout hierarchy | Android | P1 | 3 hr | A-02, A-03 |
| PH-V2-A-06 | Tab bar haptics + animation | Android | P2 | 1 hr | A-01 |

**Total: 16 stories, ~25 hours**
**P0: 9 stories | P1: 6 stories | P2: 1 story**

### Execution Status (as of push)

| ID | Status | Notes |
|----|--------|-------|
| PH-V2-B-01 | Adhik in progress | New routes/admin, /coach, /progress detected in api_server.py |
| PH-V2-B-02 | Adhik in progress | Coach router added |
| PH-V2-B-03 | Adhik in progress | Progress router added |
| PH-V2-F-01 | ✅ DONE | tokens.css created and imported across all 4 pages |
| PH-V2-F-02 | ✅ DONE | Hero stats + halo insight cards on landing |
| PH-V2-F-03 | ✅ DONE | Premium stat cards on dashboard |
| PH-V2-F-04 | ✅ DONE | Recent sessions w/ avatars + status dots + time-ago |
| PH-V2-F-05 | ⏭️ Deferred | Glass header — existing live card already styled |
| PH-V2-F-06 | ✅ Partial | Tier badges added to leaderboard, triage toggle deferred |
| PH-V2-F-07 | ✅ DONE | Wellness preview tiles 2x2 with mock UI |
| PH-V2-A-01 | ✅ DONE | tokens.js with all PH-DLS v2 tokens |
| PH-V2-A-02 | ✅ DONE | StatCard component shipped |
| PH-V2-A-03 | ✅ DONE | InsightCard component shipped |
| PH-V2-A-04 | ⏭️ Deferred | Needs `expo-blur` install — risky overnight |
| PH-V2-A-05 | ⏭️ Deferred | HomeScreen rewrite too risky overnight; StatCard ready for use |
| PH-V2-A-06 | ⏭️ Deferred | Needs `expo-haptics` install |

**Verified live local test:**
- Backend serves all endpoints with new schema
- Frontend renders all 4 pages with new design tokens
- index.ejs shows 12 ph-* class instances (premium cards working)
- dashboard.ejs shows 4 ph-stat-card instances
- wellness.ejs shows 8 preview-tile instances
- All commits pushed to develop on adhikbuilds repos

---

## 10. Definition of Done

A story is **DONE** when:
1. All Gherkin acceptance criteria pass on local test
2. Uses PH-DLS v2 tokens (no inline hex/font strings)
3. Hover/press feedback works (no dead taps)
4. Empty + loading + error states handled (UI/UX Pro Max requirement)
5. Tabular-nums on all numeric displays
6. Responsive: works on 375px / 768px / 1024px / 1440px
7. Lint passes: `ruff check` (backend), `node -c server.js` (frontend), `node -c App.js` (android)
8. Backend: Python 3.9 imports verified
9. Committed to `develop` with story ID in commit message
10. No regressions in existing endpoints / pages / screens

---

## 11. Out of Scope

- Light mode (dark only)
- New ML training
- Wellness functional features (still placeholder, just preview tiles)
- iOS-specific work
- Localization (English only)
- Real haptics outside the tab bar
- Server-side rendering for new dashboard pages

---

## 12. Logical Notes & Edge Cases (UI/UX Pro Max checklist)

- **Backend offline:** every page must render with placeholder data + a subtle "demo mode" tag, never blank
- **Empty sessions:** Recent sessions shows skeleton, never a blank card
- **No active session:** Live metrics card hides smoothly with opacity transition
- **Long athlete names:** Truncate with ellipsis at 20 chars, full name in tooltip/title
- **Reduced motion:** Respect `prefers-reduced-motion` — instant transitions, no animations
- **Touch targets:** Minimum 44×44pt on Android, 48×48dp on Android tablets
- **Dark mode contrast:** Text >= 4.5:1 (we're WCAG AA already with cinema palette)
- **Loading >300ms:** Show skeleton or spinner per UI/UX Pro Max severity:high rule
- **Halo effects:** Use CSS radial-gradient or RN View with opacity, NOT images (performance)
- **Glass blur:** Test on low-end devices — fall back to solid surface if BlurView lags

---

## 13. Skills Inventory (what each skill contributed)

| Skill | Output that ended up in this doc |
|-------|----------------------------------|
| jobs-to-be-done | Section 3 — full functional/social/emotional jobs + pains + gains |
| proto-persona | Section 4 — Aryan, Coach Rajesh, Meera with quotes and decision drivers |
| problem-statement | Section 2 — 5-part canonical framing |
| opportunity-solution-tree | Section 5 — 4 opportunities with chosen solutions and rationale |
| positioning-statement | Section 6 — anchor for all design decisions |
| user-story | Sections 8 — every story uses Mike Cohn + Gherkin format |
| ui-ux-pro-max --design-system | Section 7 — confirmed Real-Time Operations Landing pattern, Barlow Condensed, dark cinema |
| ui-ux-pro-max --domain style | Section 7 — Modern Dark (Cinema Mobile) full implementation checklist |
| ui-ux-pro-max --domain ux | Section 12 — loading states, animation rules, touch targets, contrast |
| ui-ux-pro-max --domain color | Section 7 — fitness/gym color palette informed our amber accent choice |
| ui-ux-pro-max --domain typography | Section 7 — Sports/Fitness pairing (Barlow Condensed + Barlow) |

---

## 14. Author Note

This doc was written by Adhik (acting as Technical PM) using the full Product-Manager-Skills + UI/UX Pro Max stack. Every section traces back to a specific skill output. The design language is not from gut feel — it's the intersection of: (a) the UI/UX Pro Max recommended pattern for sports/fitness/dashboard products, (b) the existing project palette legacy, and (c) the JTBD analysis showing what athletes and coaches actually need to feel.

Execute the P0 stories first. P1s if time permits. P2 only if everything else is shipped.

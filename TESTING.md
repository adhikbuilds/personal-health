# Testing the stack locally

## TL;DR — the frontend login does not authenticate against the backend

`/login` renders `ProperLoginPage`, which calls `UserContext.login()` — a **localStorage-only
demo check**. It never contacts the API and never stores a JWT.

The real login (`src/lib/auth.js` → `POST /auth/login` → `setAuth()` → `ph_access_token`)
lives in `src/pages/LoginPage.jsx`, which **is not routed anywhere**. It is dead code.

Consequence: after "logging in", `api.js` finds no token, so every protected call returns
**401**, `safeQuery()` swallows it and returns a fallback, and the UI renders **empty/zero**.
That is why the app looks half-built rather than broken.

Proven locally:

| Call (through the :8083 proxy) | No token | With token |
|---|---|---|
| `/api/athlete/athlete_01` | 401 | 200 |
| `/api/streak/athlete_01` | 401 | 200 |
| `/api/leaderboard` | 200 | 200 |

`/leaderboard` is public, which is why the leaderboard is one of the few screens that shows
real data today.

---

## 1. Start the stack

```bash
# Backend — needs Python 3.12 (3.9 and 3.14 both fail to build deps)
cd personal-health-backend
source venv/bin/activate
python3 api_server.py                 # :8082

# Frontend (separate terminal)
cd personal-health-frontend
node server.js                        # :8083  — NOT "npm run dev:server", that script doesn't exist
```

Check both: <http://localhost:8082/docs> and <http://localhost:8083/>

---

## 2. Log in for real (the workaround)

Until the login page is wired to the API, paste this into the **browser console** at
<http://localhost:8083>. It performs a genuine API login and populates **both** auth systems —
`ph_access_token` (what `api.js` sends) and `ph_user` (what `UserContext` uses for routing).

```js
await (async (email = 'test.runner@example.com', password = 'testpass123') => {
  const r = await fetch('/api/auth/login', {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({ email, password }),
  });
  if (!r.ok) throw new Error('login failed: ' + r.status);
  const d = await r.json();

  // what src/lib/api.js reads on every request
  localStorage.setItem('ph_access_token', d.access_token);
  localStorage.setItem('ph_refresh_token', d.refresh_token);
  localStorage.setItem('ph_auth_user', JSON.stringify(d.user));

  // what src/context/UserContext.jsx reads for role-based routing
  localStorage.setItem('ph_user', JSON.stringify({
    userId: d.user.athlete_id || d.user.id,
    id:     d.user.athlete_id || d.user.id,
    email:  d.user.email,
    role:   d.user.role,
    sport:  null,
    createdAt: new Date().toISOString(),
  }));

  location.reload();
})();
```

### Test account

`test.runner@example.com` / `testpass123` — bound to `athlete_01` ("Aryan Kapoor", Block tier,
BPI 3302, 30 sessions).

Create another:

```bash
curl -s -X POST http://localhost:8082/auth/register \
  -H 'Content-Type: application/json' \
  -d '{"email":"you@example.com","name":"You","password":"yourpassword","athlete_id":"athlete_02"}'
```

> The demo credentials printed on the login page (`coach@example.com` / `password123`) work
> only against the fake localStorage path. They will log you in but every API call will 401.

---

## 3. Routes worth checking

| Route | Expect |
|---|---|
| `/athlete/leaderboard` | **Real data even without a token** — public endpoint |
| `/` , `/dashboard` | Athlete home — needs the token above |
| `/feed` | Activity feed; kudos/claps now hit the correct endpoint |
| `/messages` | Coach broadcasts — repointed to `/coach/inbox/athlete/{id}` |
| `/athlete/analytics` | Progress + weak joints |
| `/session/$sessionId` | Session detail — get an id from `db/sessions.json` |
| `/coach/analytics`, `/coach/drills`, `/coach/reports` | Coach views (set `role: 'coach'` above) |

Server-rendered EJS routes (separate from the SPA, all work):
`/coach/:coachId/inbox`, `/athlete/:athleteId/inbox`, `/coach/:coachId/billing`

---

## 4. Screens that will still look empty — and why

These have **no backend at all** (see `AUDIT-2026-08-04.md` §2A). A token will not help:

- **Wellness** — `/athlete/{id}/wellness`, `/wellness/score`, `/wellness/trends`, `/wellness/checkin`
- **Nutrition / meals** — `/athlete/{id}/meals`, `/nutrition/goals`, `/nutrition/summary`
- **Achievements**, **intelligence report**, **improvers leaderboard**, **coach priorities**

18 distinct client calls still 404. Because of `safeQuery`, they render as zeros rather than
errors — so "empty" here means *unbuilt*, not *broken data*.

To see them fail explicitly, open DevTools → Network and filter on `/api`.

---

## 5. Quick API checks without the UI

```bash
TOKEN=$(curl -s -X POST http://localhost:8082/auth/login \
  -H 'Content-Type: application/json' \
  -d '{"email":"test.runner@example.com","password":"testpass123"}' \
  | python3 -c "import sys,json;print(json.load(sys.stdin)['access_token'])")

curl -s -H "Authorization: Bearer $TOKEN" localhost:8082/athlete/athlete_01 | head -c 300
curl -s -H "Authorization: Bearer $TOKEN" localhost:8082/streak/athlete_01

# shareable scorecard PNG (needs a real session id)
SID=$(python3 -c "import json;print(list(json.load(open('personal-health-backend/db/sessions.json')).keys())[0])")
curl -s -H "Authorization: Bearer $TOKEN" \
  "localhost:8082/session/$SID/scorecard.png" -o /tmp/scorecard.png && open /tmp/scorecard.png
```

Interactive API docs: <http://localhost:8082/docs> — click **Authorize**, paste the token.

Backend test suite: `venv/bin/pytest tests/` → 117 passing.

---

## 6. The actual fix

Route `/login` to the real auth instead of the demo store. Either point the route at
`src/pages/LoginPage.jsx` (already implemented against `lib/auth.js`), or change
`ProperLoginPage` to call `loginWithCredentials()` and drop the localStorage demo path in
`UserContext.jsx:82-84`.

Not done here because it changes how every user signs in and deserves to be verified in a
browser, not asserted from curl.

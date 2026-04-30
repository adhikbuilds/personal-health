# Sandbox Environment Setup

**Purpose:** Quick local development environment with all systems running + test data

## 1️⃣ Backend API (Port 8082)

```bash
cd personal-health-backend
python3 -m venv venv
source venv/bin/activate
pip install -r requirements.txt
python api_server.py
```

Expected output: `[INFO] api startup` on http://localhost:8082

## 2️⃣ Frontend Dev Server (Port 8083)

```bash
cd personal-health-frontend
npm install
npm run dev:server
```

Expected output: Server listening on http://localhost:8083

## 3️⃣ Seed Test Athletes

```bash
cd personal-health-backend
python seed_athletes.py
python seed_sessions.py
```

Creates athletes with IDs: `athlete_01`, `athlete_02`, `athlete_03` + sample sessions

## 4️⃣ Access Sandbox

| Component | URL | Notes |
|-----------|-----|-------|
| **API Docs** | http://localhost:8082/docs | FastAPI Swagger |
| **Frontend** | http://localhost:8083 | React dashboard |
| **Test Athlete** | `athlete_01` | Pre-seeded in `db/athletes.json` |

## 5️⃣ Quick Test Flow

1. Open http://localhost:8083
2. Select athlete `athlete_01` from dropdown
3. View: sessions, form scores, wellness data, drills
4. Backend API calls shown in network tab

## 🔑 Authentication (v1 - Simple)

Currently **no login required**. To add basic auth:

```python
# backend/routes/auth.py → add POST /auth/login
# Frontend checks AsyncStorage for token
```

See `SANDBOX_AUTH.md` for full auth setup.

## ⚡ Light App Version (React Native)

For testing on phone without full Expo build:

```bash
cd personal-health-android
npm install
npx expo start --web
```

Opens http://localhost:8081 with web version of React Native app

---

**Status:** ✅ Ready for feature testing  
**Next:** Add login system + persist user state across tabs

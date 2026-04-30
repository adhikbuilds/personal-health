#!/bin/bash

# Personal Health — Quick Sandbox Startup
# Runs backend + frontend + seeds data in parallel

set -e

echo "🏃 Starting Personal Health Sandbox..."
echo ""

# Kill any existing processes on ports 8082, 8083
lsof -ti:8082 | xargs kill -9 2>/dev/null || true
lsof -ti:8083 | xargs kill -9 2>/dev/null || true

# 1. Start Backend API
echo "📡 Starting Backend API (port 8082)..."
cd personal-health-backend
python3 -m venv venv 2>/dev/null || true
source venv/bin/activate
pip install -q -r requirements.txt 2>/dev/null || true

# Seed data
echo "🌱 Seeding test athletes..."
python3 seed_athletes.py 2>/dev/null || echo "⚠️  Seed script not found"

# Start API in background
python3 api_server.py &
BACKEND_PID=$!
sleep 3

# 2. Start Frontend
echo "🎨 Starting Frontend dev server (port 8083)..."
cd ../personal-health-frontend
npm install -q 2>/dev/null || npm i
npm run dev:server &
FRONTEND_PID=$!
sleep 3

echo ""
echo "✅ Sandbox Ready!"
echo ""
echo "📍 Access points:"
echo "   🔗 Frontend:  http://localhost:8083"
echo "   🔗 API Docs:  http://localhost:8082/docs"
echo "   🔗 Test data: db/athletes.json"
echo ""
echo "🧪 Test with: athlete_01, athlete_02, athlete_03"
echo ""
echo "Press Ctrl+C to stop"
echo ""

# Keep running
wait $BACKEND_PID $FRONTEND_PID

# Personal Health

An AI sports-biomechanics coach that runs on a phone camera. An athlete records a drill. The app tracks their pose, scores their form against an elite reference, estimates heart rate from their face, and turns the session into drills, recovery guidance and progress over time.

This repository ties the three services together as git submodules and runs CI across all of them.

| Service | Stack | What it does |
|---|---|---|
| [personal-health-android](https://github.com/adhikbuilds/personal-health-android) | React Native, Expo, Vision Camera | Records drills, gives live form feedback, and shows scorecards, training plans, nutrition, wellness and the social feed |
| [personal-health-backend](https://github.com/adhikbuilds/personal-health-backend) | Python, FastAPI, MediaPipe, SciPy | Pose analysis, kinematics, heart rate from the camera, athlete intelligence, goals and recovery engines |
| [personal-health-frontend](https://github.com/adhikbuilds/personal-health-frontend) | Node.js, Express, EJS | Server-rendered web dashboard; proxies API and WebSocket traffic for the app |

## The interesting parts

- **Phase-space kinematics.** Each joint's state `[θ, θ̇]` is compared with an elite distribution using Mahalanobis distance. Quaternion torsion measures 3D rotational deviation. Dimensionless jerk on the centre-of-mass path gives an energy-efficiency index. A 60-frame sliding window supplies the derivatives.
- **Movement phases per sport.** Phase classifiers driven by centre-of-mass motion split each movement: jumps into setup, descent, takeoff, flight and landing; sprints into start, acceleration, max velocity and deceleration; plus rep and throw phases. Form is then scored per phase, not per frame.
- **Heart rate without a sensor.** Remote photoplethysmography (rPPG) estimates heart rate from colour changes in a face region.
- **Streaming.** Frames stream over a WebSocket for live feedback, with an HTTP fallback.

## CI

Each push runs ruff (pinned) on the backend and biome (pinned) on the app and web code, compiles the backend, and runs guards for project structure, hardcoded IPs and leftover old branding. Each service also runs its own CI.

```bash
git clone --recurse-submodules https://github.com/adhikbuilds/personal-health.git
```

Setup for each service is in its own README. Product stories and the ML training guide are in [`stories/`](stories/).

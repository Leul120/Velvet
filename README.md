# VELVET

Members-only **adult booking marketplace** (Flutter + Spring Boot).

> Positioning: verified adult performers list rates and availability; paying male clients browse and request private bookings — 21+ consenting adults only.

## Monorepo

```
velvet/
├── apps/mobile/          # Flutter (Android-first, Amharic + English)
├── services/api/         # Spring Boot 3.4 modular monolith
├── docs/
└── docker-compose.yml    # Postgres, Redis, MinIO
```

## Prerequisites

- **JDK 17** (set `JAVA_HOME` — Java 25 is not supported for this API)
- **Maven 3.9+** (`mvn` on PATH, or use `./mvnw` after wrapper is generated)
- Flutter 3.24+ (`export PATH="$PATH:$HOME/flutter/bin"`)
- Docker (Postgres + Redis)

```bash
export JAVA_HOME=/usr/lib/jvm/java-17-openjdk-amd64   # adjust path as needed
```

## Quick start

### 1. Infrastructure

```bash
docker compose up -d postgres redis minio
```

### 2. API

```bash
cd services/api
mvn spring-boot:run
# or: ./mvnw spring-boot:run
```

- Health: http://localhost:8080/actuator/health  
- Swagger: http://localhost:8080/swagger-ui.html  
- Seed invite code: `VELVET-SEED`  
- Demo clients: `+251911100001`–`024` (Abel … Yared)  
- Demo performers: `+251911200001`–`036` (Sara … Soliyana)  
- Dev OTP is returned in the API response when `OTP_EXPOSE=true` (default locally)

### 3. Mobile

```bash
cd apps/mobile
flutter pub get
# Android emulator (API on host):
flutter run --dart-define=API_BASE=http://10.0.2.2:8080
# iOS simulator / desktop:
flutter run --dart-define=API_BASE=http://127.0.0.1:8080
```

### Auth smoke test (curl)

```bash
# Request OTP
curl -s http://localhost:8080/v1/auth/otp/request \
  -H 'Content-Type: application/json' \
  -d '{"phone":"+251911000001","inviteCode":"VELVET-SEED","deviceId":"dev","platform":"curl"}'

# Verify (use devOtp from response)
curl -s http://localhost:8080/v1/auth/otp/verify \
  -H 'Content-Type: application/json' \
  -d '{"phone":"+251911000001","code":"XXXXXX","deviceId":"dev","platform":"curl"}'
```

## Current vertical slice

- Invite-gated phone OTP registration / login  
- JWT access + rotating refresh tokens  
- `/v1/me` profile read/update (21+ DOB check)  
- Verification submit + admin review + MinIO image upload (Flutter picker)  
- Curated match proposals, mutual accept, expiry job  
- Partner venues + booking propose/confirm/check-in/check-out  
- Moderated chat + icebreakers  
- Panic alerts + safety reports  
- Admin console at `/admin`  
- **Telebirr** membership subscriptions (ETB plans + ledger; mock mode locally)  
- Match quota consumed from Telebirr subscriber (member A) when curated  
- Concierge SMS/outbox alerts on panic  
- Soft venue geofence on check-in (optional via `REQUIRE_GEOFENCE`)  
- Telebirr notify signature verify when live + public key set  
- SMS gateway abstraction (`log` / `http`) wired to panic concierge alerts  
- Icebreaker-first chat + stronger Amharic moderation rules  
- Subscription expiry job + admin notification outbox  
- HELD chat review queue (peer-hidden until approved)  
- Admin invite create / deactivate  
- OTP delivered via SMS gateway  
- Device push-token registration + concierge push (log/http)  
- Flutter silent refresh on 401  
- Member lifecycle push notifications (match + booking)  
- Booking reminders (24h / 2h)  
- Admin safety report triage  
- Profile photos via MinIO (up to 3)  
- Admin partner venue CRUD  
- Redis rate limits (OTP, chat, panic, reports)  
- Peer block + enforcement across match/chat/booking  
- In-app notification inbox  
- Booking cancel  
- Admin member search + concierge notes + audit log writes  
- Account withdrawal (WITHDRAWN + token revoke)  
- Match history (declined / expired / cancelled + completed meetings)
- Membership renewal warnings (7-day) + expiry member notify
- CBE receipt screenshot membership payments via Leul verifier-api (default; Telebirr optional)
- Chat soft-polling + optional SSE stream
- Moderation HTTP NLP gateway (`MODERATION_PROVIDER=http`)
- Waitlist / application funnel + admin approve→invite
- Venue partner portal (`/partner`, `VENUE_PARTNER`)
- Compliance data export / erasure, audit UI, staff shifts
- Booking reschedule, report category picker, admin metrics dashboard
- On-call panic escalation, waitlist invite SMS, moderation event feedback loop
- Seed venue partner desk (`+251911000010`) + public `/waitlist/` landing
- Local NLP moderation stub + ops readiness + Telebirr live fail-fast + FCM push scaffolding
- Chat exclusive media (image/video/audio/file) + API media proxy + Android screenshot block
- Local demo roster (24 clients / 60 performers) wipe+reseed on every API boot (`VELVET_SEED_RESET`)

## Next builds

See prioritized soft-launch backlog: [`docs/backlog/soft-launch-must-haves.md`](docs/backlog/soft-launch-must-haves.md)  
Wave 2 ops: [`docs/api/wave2-chat-concierge.md`](docs/api/wave2-chat-concierge.md)

1. Wire production SMS aggregator credentials (`docs/ops/sms-setup.md`)  
2. Replace placeholder `google-services.json` + run with `--dart-define=USE_FCM=true` (`docs/ops/fcm-setup.md`)  
3. Point `MODERATION_PROVIDER=http` at a production Amharic NLP service (local stub available)  
4. Configure CBE verification: `CBE_VERIFIER_MODE=direct` for CBE's keyless public receipt page, or `live` + API key (`docs/api/cbe-billing.md`)  
5. Counsel review of `/legal` Terms, Privacy, Community Guidelines (EN+AM)  
6. Full go-live: `docs/ops/production-checklist.md` (`VELVET_ENV=production`)  

Ops: `GET /v1/admin/ops/readiness` (`readyForProduction`)  
Legal docs: http://localhost:8080/legal/

## Legal / product constraints

- 21+ verified adults only; CSAE and trafficking strictly banned  
- Clients (men) browse performer (women) listings with rates and availability  
- Adult booking talk allowed in chat; off-platform contact still blocked  
- Moderated messaging (server-side) over true E2EE for Phase 1  

# Production checklist (Wave 3)

Code supports production when `VELVET_ENV=production` (or Spring profile `prod`). Boot **fails fast** if SMS/push/CBE/OTP/JWT are not live-ready.

## 1. API process

```bash
export JAVA_HOME=/usr/lib/jvm/java-17-openjdk-amd64
export VELVET_ENV=production
export SPRING_PROFILES_ACTIVE=prod
export JWT_SECRET='…≥32 random chars…'
export OTP_EXPOSE=false

# CBE live
export BILLING_PROVIDER=cbe
export CBE_VERIFIER_MODE=live
export CBE_VERIFIER_API_KEY=…          # https://verify.leul.et
export CBE_VERIFIER_BASE_URL=https://verifyapi.leulzenebe.pro
export CBE_ACCOUNT_NAME=…
export CBE_ACCOUNT_NUMBER=…
export CBE_ACCOUNT_SUFFIX=…            # last 8 digits

# SMS
export SMS_PROVIDER=http
export SMS_HTTP_URL=https://your-aggregator/send
export SMS_API_KEY=…
export SMS_SENDER_ID=VELVET
export CONCIERGE_SMS_PHONES=+2519…,+2519…

# Push (FCM proxy)
export PUSH_PROVIDER=http
export PUSH_HTTP_URL=https://your-fcm-proxy/send
export PUSH_API_KEY=…

# Optional NLP
export MODERATION_PROVIDER=http
export MODERATION_HTTP_URL=https://your-nlp/v1/score
export MODERATION_API_KEY=…

export REQUIRE_GEOFENCE=true
# Postgres / Redis / S3 in Ethiopia (PDPP localization)
```

Local push proxy for staging (not production):

```
PUSH_PROVIDER=http
PUSH_HTTP_URL=http://localhost:8080/v1/internal/push/deliver
```

## 2. Flutter / FCM

1. Replace `apps/mobile/android/app/google-services.json` with the real Firebase file for `com.velvet.velvet_mobile`.
2. Run:

```bash
cd apps/mobile
flutter pub get
flutter run --dart-define=API_BASE=https://api.yourdomain.et --dart-define=USE_FCM=true
```

See `docs/ops/fcm-setup.md` and `docs/ops/sms-setup.md`.

## 3. Verify

- `GET /v1/admin/ops/readiness` → `readyForProduction: true`
- OTP SMS received (no `devOtp` in response)
- One live CBE proof upload
- Panic reaches on-call SMS + push
- Panic GPS scrubbed after `RETENTION_LOCATION_DAYS` (default 7)

## 4. Still ops / business (not code)

- Host data in Ethiopia (PDPP)
- Counsel-approved legal docs
- Company registration / TIN / EIC

# Phase 15 — production scaffolding

## Local NLP moderation stub

`POST /v1/internal/moderation/score` `{ "text", "lang"? }` → `{ blocked, held, flags }`

Enable:

```
MODERATION_PROVIDER=http
MODERATION_HTTP_URL=http://localhost:8080/v1/internal/moderation/score
```

Calibrate using admin Metrics → Moderation events / stats (false positives → STAFF_APPROVE).

## Ops readiness

`GET /v1/admin/ops/readiness` — SMS / push / Telebirr / moderation config status (no secrets).

## Telebirr live fail-fast

`TelebirrLiveConfigValidator` refuses boot in `TELEBIRR_MODE=live` when merchant env vars are missing.
Warns if `TELEBIRR_PUBLIC_KEY_PEM` is empty.

## Flutter push

`lib/core/push/push_registration.dart` + `docs/ops/fcm-setup.md`.

# Concierge SMS + geofence + notification outbox

## SMS gateway

`velvet.sms.provider`:

| Value | Behavior |
|-------|----------|
| `log` (default) | Logs SMS body; still writes outbox rows |
| `http` | `POST` JSON `{to, from, message}` to `velvet.sms.http-url` with optional Bearer `SMS_API_KEY` |

Env: `SMS_PROVIDER`, `SMS_HTTP_URL`, `SMS_API_KEY`, `SMS_SENDER_ID`, `CONCIERGE_SMS_PHONES`.

Panic alerts call the gateway for each concierge phone and persist to `notification_outbox`.

## Admin

`GET /v1/admin/notifications/outbox` — recent outbox rows (admin UI **Outbox** tab).

## Chat safety

- First **2** messages in a thread must match an active icebreaker (EN or Amharic).
- Content filter covers EN + Amharic solicitation / private-residence / off-platform cues.

## Subscriptions

Job marks `ACTIVE` subscriptions with `ends_at < now` as `EXPIRED` (`velvet.jobs.subscription-expiry-ms`).

## Geofence

Soft check-in radius when `REQUIRE_GEOFENCE=true` (see booking check-in).

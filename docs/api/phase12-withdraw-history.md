# Phase 12 — withdrawal, match history, renewal warnings

## Account withdrawal

`POST /v1/me/withdraw`

- Sets status `WITHDRAWN`
- Revokes all refresh tokens
- Deactivates push device tokens
- Blocks OTP login / refresh
- Audit: `ACCOUNT_WITHDRAW`

## Match history

`GET /v1/matches/history` — last 50 of `DECLINED` / `EXPIRED` / `CANCELLED`  
Flutter: Profile → Past introductions (`/history`)

## Subscription renewal warnings

Job (same cadence as expiry):

1. ACTIVE subs ending within 7 days and `warning_sent_at` null → member inbox notify, set `warning_sent_at`
2. Past `ends_at` → `EXPIRED` + member notify + ops outbox

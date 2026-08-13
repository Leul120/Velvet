# Phase 8 — moderation review, invites, OTP SMS, push tokens

## HELD chat review

Off-platform / private-address cues set messages to `HELD`:
- Peer does **not** see the message until staff approves
- Sender sees it with pending status
- Admin: `GET /v1/admin/chat/held`, `POST /v1/admin/chat/held/{id}/review` `{ "approve": true|false }`

## Invites

- `GET /v1/admin/invites`
- `POST /v1/admin/invites` `{ "code"?, "maxUses"?, "expiresInDays"? }`
- `POST /v1/admin/invites/{id}/deactivate`

## OTP SMS

`OtpService` sends via `SmsGateway` (`SMS_PROVIDER=log|http`). When `OTP_EXPOSE=true`, failed SMS still returns `devOtp` for local use.

## Push tokens

- `POST /v1/devices/push-token` `{ "token", "platform" }`
- Panic / reports / subscription expiry dispatch `PUSH` to ADMIN+CONCIERGE tokens via `PushGateway` (`PUSH_PROVIDER=log|http`)
- Mobile registers a stable `dev-…` token after login until Firebase is wired

## Notifications

`ConciergeNotifyService` outbox channels: `SMS` (panic), `PUSH` (staff tokens), `LOG` (always).

# Phase 11 — blocks, inbox, booking cancel, admin search

## Peer blocks

- `POST /v1/safety/blocks` `{ "blockedUserId", "reason"? }`
- `GET /v1/safety/blocks`
- `DELETE /v1/safety/blocks/{blockedUserId}`

Enforced on match create, match list, chat, booking propose. Blocking declines open matches and closes chat threads.

## Notification inbox

Dual-write with push in `MemberNotifyService`:

- `GET /v1/me/notifications?unreadOnly=`
- `GET /v1/me/notifications/unread-count`
- `POST /v1/me/notifications/{id}/read`
- `POST /v1/me/notifications/read-all`

Flutter: home badge → `/notifications`.

## Booking cancel

`POST /v1/bookings/{id}/cancel` `{ "reason"? }`

- PROPOSED: proposer only  
- CONFIRMED: either party before `starts_at`  
- Not after check-in  

## Admin curation

- `GET /v1/admin/members?q=&status=&role=` search  
- `PATCH /v1/admin/members/{id}/notes` `{ "notes" }` → `member_profiles.concierge_notes`  
- Writes to `audit_logs` on match create / status / notes  

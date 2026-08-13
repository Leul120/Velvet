# Phase 9 — member notifications, reminders, report triage, profile photos

## Member notifications

`MemberNotifyService` pushes (via `PushGateway` log/http) to member device tokens and writes outbox rows:

| Event | When |
|-------|------|
| New introduction | Admin creates match |
| Accepted / declined | Counterpart decision |
| Mutual | Chat + booking unlocked |
| Booking proposed | Other member |
| Booking confirmed | Both members |
| Booking reminder | 24h and 2h before `starts_at` |

## Booking reminders

Job every `velvet.jobs.booking-reminder-ms` (default 5m). Columns: `reminder_24h_sent_at`, `reminder_2h_sent_at`.

## Report triage

`POST /v1/admin/safety/reports/{id}/review` `{ "status": "TRIAGED|RESOLVED|DISMISSED", "notes"? }`

## Profile photos

1. `POST /v1/uploads/profile` (multipart) → `{ url }`
2. `POST /v1/me/photos` `{ "url" }` (max 3)
3. `DELETE /v1/me/photos` `{ "url" }`

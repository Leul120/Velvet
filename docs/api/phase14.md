# Phase 14 — ops hardening

## On-call escalation
Panic SMS/push prefers staff currently marked on-call in `staff_shifts`.
Falls back to `CONCIERGE_SMS_PHONES` / all ADMIN+CONCIERGE push tokens.

## Waitlist invite SMS
Approving a waitlist application creates an invite and SMS-notifies the applicant (logged in outbox).

## Moderation feedback loop
Pipeline decisions and held-message staff reviews write `moderation_events`.

- `GET /v1/admin/moderation/events`
- `GET /v1/admin/moderation/stats`
- Included under `GET /v1/admin/metrics` → `moderation`

## Seed partner desk
`+251911000010` (`VENUE_PARTNER`) assigned to Kuriftu venue. Sign in at `/partner/` with invite `VELVET-SEED`.

## Public waitlist page
`/waitlist/` static landing posts to `POST /v1/waitlist`.

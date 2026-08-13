# Phase 13 — realtime chat, waitlist, partner, compliance, polish

## Chat soft realtime

- `GET /v1/chat/connections/{connectionId}` — full thread
- `GET /v1/chat/connections/{connectionId}/messages?after=` — incremental soft-poll cursor
- `GET /v1/chat/connections/{connectionId}/stream` — SSE soft push (server polls DB every 5s)
- Flutter chat polls every 5s while open

## Moderation NLP gateway

`velvet.moderation.provider=rule|http`

HTTP posts `{ "text", "lang": "am" }` and expects `{ "blocked", "held", "flags": [] }`.
Local keyword rules always run first; HTTP assists Amharic/NLP when configured.

## Waitlist funnel

- Public `POST /v1/waitlist` `{ phoneE164, displayName?, city?, note? }`
- Admin `GET /v1/admin/waitlist`, `GET /v1/admin/waitlist/all`
- `POST /v1/admin/waitlist/{id}/approve` → creates invite + returns code
- `POST /v1/admin/waitlist/{id}/reject`
- Flutter: auth → “Join the waitlist” (`/waitlist`)

## Venue partner portal

- Assign: `POST /v1/admin/venues/{id}/partner?partnerUserId=`
- Partner APIs (`VENUE_PARTNER`):  
  `GET /v1/partner/venue`  
  `GET /v1/partner/bookings`  
  `POST /v1/partner/bookings/{id}/desk-check-in`
- UI: `/partner/`

## Compliance ops

- `GET /v1/me/data-export`
- `POST /v1/me/erasure` (withdraw + anonymize PII)
- `GET /v1/admin/audit?limit=&action=`
- Staff shifts: `GET/POST /v1/admin/shifts`, `GET /v1/admin/shifts/on-call`, `DELETE /v1/admin/shifts/{id}`
- Metrics: `GET /v1/admin/metrics`

## Polish

- Report category picker (HARASSMENT / NO_SHOW / UNSAFE / POLICY / OTHER)
- Membership renew urgency (≤7 days warning, renew CTA)
- Booking reschedule: `POST /v1/bookings/{id}/reschedule`
- Cancelled bookings can be re-proposed
- Connection history includes completed meetings (`meetingCompleted`, `meetingVenueName`)
- Admin SPA tabs: Waitlist, Metrics, Audit, Shifts + venue partner assign

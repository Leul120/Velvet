# Connections & verification (Phase 2)

## Member

### POST `/v1/verification`
Submit ID + selfie URLs (object storage upload comes next).

### GET `/v1/verification/me`
Latest verification case for the caller.

### GET `/v1/connections` (preferred) or `/v1/matches` (legacy)
Open introductions for the caller (proposed / partial / connected).

### POST `/v1/connections/{id}/decision` (or `/v1/matches/{id}/decision`)
```json
{ "action": "ACCEPT" }
```
or `"DECLINE"`. Mutual accept unlocks chat and booking.

Discover actions return both `connectionId` and `matchId` (same value) for backward compatibility.

### GET `/v1/venues`
Active partner venues (public meeting places only).

## Chat

Prefer `/v1/chat/connections/{connectionId}` — legacy `/v1/chat/matches/{matchId}` remains supported.

## Bookings

Prefer `/v1/bookings/by-connection/{connectionId}` — legacy `/v1/bookings/by-match/{matchId}` remains supported.

### Internal terminology

The persistence model uses `connections`, `connection_id`, and `connections_used`.
Existing booking and safety request bodies retain `matchId` for wire compatibility. Chat thread details expose `conversationStarters`; clients may temporarily accept the legacy `icebreakers` field.

### Admin connections

Use `POST /v1/admin/connections` to create a curated connection. `POST /v1/admin/matches` remains a legacy alias.

## Admin / Concierge (`ROLE_ADMIN` or `ROLE_CONCIERGE`)

Bootstrap: sign in with `ADMIN_BOOTSTRAP_PHONE` (default `+251911000000`) → auto-promoted to ADMIN.

### GET `/v1/admin/verification/queue`
### POST `/v1/admin/verification/{caseId}/review`
```json
{ "approve": true, "notes": "optional" }
```

### GET `/v1/admin/members`
### PATCH `/v1/admin/members/{userId}/status`
### POST `/v1/admin/members/promote`
### POST `/v1/admin/connections`

`/v1/admin/matches` remains a legacy alias.
```json
{
  "memberAId": "uuid",
  "memberBId": "uuid",
  "suggestedVenueId": "uuid",
  "introNoteEn": "You both enjoy traditional music…",
  "introNoteAm": "…",
  "expiresInHours": 72
}
```

# Bookings, chat & uploads

## Bookings (private marketplace)

Private hotel/suite meetups are the default. Partner venues remain optional.

### POST `/v1/bookings`
Requires connection status `MUTUAL`. Provide **either** `meetupPlace` **or** `venueId` (not both).

```json
{
  "matchId": "uuid",
  "meetupPlace": "Skylight hotel · suite arranged privately",
  "rateType": "SESSION",
  "startsAt": "2026-08-10T17:00:00Z",
  "notes": "optional"
}
```

`rateType`: `SESSION` | `OVERNIGHT` — amount is snapshotted from the performer’s `sessionRateEtb` / `overnightRateEtb`.

Schedule checks (see `docs/api/availability.md`):

- Start must fall inside a published availability window covering session (3h) or overnight (12h)
- No overlapping open bookings for the performer (`SCHEDULE_CONFLICT`)

Response includes `meetupPlace`, `rateType`, `amountEtb`, `paymentStatus` (`UNPAID` | `PENDING` | `PAID` | `WAIVED`).

### POST `/v1/bookings/{id}/confirm`
Other participant confirms.

### GET `/v1/bookings/by-connection/{connectionId}`

`/v1/bookings/by-match/{matchId}` remains available as a legacy alias. The booking request body intentionally retains `matchId` during the compatibility period.

### POST `/v1/billing/bookings/{bookingId}/pay`
Creates a CBE/Telebirr payment intent for `amountEtb`. Same proof / mock-complete endpoints as membership; purpose `BOOKING` marks the booking paid without activating a subscription.

## Chat (moderated)

Unlocked when a connection becomes `MUTUAL` (thread auto-created).

### GET `/v1/chat/connections/{connectionId}`
Thread + messages + conversation starters.

### POST `/v1/chat/connections/{connectionId}/messages`
```json
{ "body": "Looking forward tonight — Skylight works for me" }
```
Adult booking talk (rates, hotels) is allowed. Off-platform contact, CSAE, and coercion remain blocked.

All `/v1/chat/matches/{matchId}` paths remain legacy aliases.

## Uploads (MinIO)

### POST `/v1/uploads/verification` (multipart)
- `kind`: `id` | `selfie`
- `file`: image/jpeg|png|webp

Returns `{ "url": "...", "kind": "id" }` for use in verification submit.

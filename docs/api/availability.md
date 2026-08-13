# Availability calendar

Performers publish absolute **availability windows**. Bookings must:

1. Fall fully inside a published window (session = 3h, overnight = 12h)
2. Not overlap another open booking for that performer

If a performer has **no upcoming windows**, propose/reschedule fails with `AVAILABILITY_REQUIRED`.

## APIs

| Method | Path | Notes |
|--------|------|--------|
| GET | `/v1/availability/me` | Performer’s upcoming windows |
| GET | `/v1/availability/users/{userId}` | Public upcoming windows |
| POST | `/v1/availability` | `{ startsAt, endsAt, note? }` |
| DELETE | `/v1/availability/{windowId}` | Owner only |

## Flutter

Profile → **Availability calendar** (`/availability`).

Demo roster seeds evening + overnight windows for seeded performers.

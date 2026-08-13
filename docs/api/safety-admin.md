# Safety & admin

## Member safety

### POST `/v1/safety/panic`
```json
{ "bookingId": "uuid?", "matchId": "uuid?", "latitude": 9.03, "longitude": 38.74, "note": "optional" }
```

### POST `/v1/safety/reports`
```json
{ "category": "HARASSMENT|NO_SHOW|UNSAFE|POLICY|OTHER", "details": "...", "reportedUserId": "uuid?", "matchId": "uuid?" }
```

### Booking check-in
- `POST /v1/bookings/{id}/check-in`
- `POST /v1/bookings/{id}/check-out`

## Admin console

Open after API is running: [http://localhost:8080/admin](http://localhost:8080/admin)

Sign in with bootstrap phone `+251911000000` (promoted to ADMIN) + invite `VELVET-SEED`.

Tabs: verification queue, members, create match, panics, reports.

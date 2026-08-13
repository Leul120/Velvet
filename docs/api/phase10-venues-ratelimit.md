# Phase 10 — venue admin + rate limits

## Admin venues

| Method | Path | Notes |
|--------|------|-------|
| GET | `/v1/admin/venues` | All venues (incl. inactive) |
| POST | `/v1/admin/venues` | Create partner venue |
| PATCH | `/v1/admin/venues/{id}` | Update fields |
| POST | `/v1/admin/venues/{id}/active?active=` | Activate / deactivate |

Categories: `RESTAURANT`, `CAFE`, `HOTEL`, `LOUNGE`, `OTHER`.  
Privacy: `STANDARD`, `DISCREET`.  
Optional `latitude` / `longitude` / `geofenceMeters` for check-in geofence.

Admin UI: **Venues** tab (also “Use in match”).

## Rate limits (Redis)

Configured under `velvet.rate-limits` / env:

| Key | Default | Scope |
|-----|---------|-------|
| `RL_OTP_PER_HOUR` | 10 | per phone |
| `RL_CHAT_PER_MINUTE` | 30 | per user |
| `RL_PANIC_PER_HOUR` | 3 | per user |
| `RL_REPORT_PER_HOUR` | 10 | per user |

Errors: `OTP_RATE_LIMIT`, `CHAT_RATE_LIMIT`, `PANIC_RATE_LIMIT`, `REPORT_RATE_LIMIT`.  
Set a limit to `0` to disable that bucket.

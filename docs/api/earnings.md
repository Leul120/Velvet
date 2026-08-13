# Performer earnings

When a client pays a booking (`purpose=BOOKING`), VELVET:

1. Marks the booking `paymentStatus=PAID`
2. Credits the performer **85%** of `amountEtb` (`PERFORMER_CREDIT`)
3. Records **15%** as `PLATFORM_FEE`

Credits are idempotent per booking.

## APIs

### `GET /v1/earnings`
Performer-only. Returns available balance, lifetime totals, recent ledger, and payout requests.

### `POST /v1/earnings/payout`
```json
{ "amountEtb": 1500.00, "destinationNote": "CBE · 1000… · Sara" }
```
Minimum 50 ETB. Debits available balance (`PERFORMER_PAYOUT`) and creates a `REQUESTED` payout for concierge/ops to settle offline (CBE/Telebirr).

One open `REQUESTED` payout at a time.

## Admin settlement

| Method | Path | Effect |
|--------|------|--------|
| GET | `/v1/admin/payouts?status=REQUESTED` | Queue |
| POST | `/v1/admin/payouts/{id}/complete` | `{ notes? }` → `PAID` |
| POST | `/v1/admin/payouts/{id}/reject` | `{ notes? }` → `REJECTED` + `PERFORMER_PAYOUT_REVERSAL` (balance restored) |

Admin SPA: **Payouts** tab.

## Flutter

Profile → **Earnings** (`/earnings`) for performers.

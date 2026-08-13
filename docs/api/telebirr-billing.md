# Membership billing — CBE screenshot verification

Membership fees are collected in **ETB via Commercial Bank of Ethiopia (CBE) transfer**.  
Members upload a receipt screenshot; VELVET verifies it with [Leul’s verifier-api](https://github.com/Vixen878/verifier-api).

> Telebirr H5 checkout remains available only when `BILLING_PROVIDER=telebirr` (legacy).

## Flow

1. `POST /v1/billing/subscribe` `{ "planCode": "PREMIUM" }`  
   → payment intent + CBE account instructions (no redirect checkout).
2. Member transfers the exact plan amount to the configured CBE account  
   (put the `merchantOrderId` in the transfer reason).
3. `POST /v1/billing/payments/{paymentIntentId}/cbe-proof` (multipart)  
   - `file` — receipt screenshot (preferred)  
   - `reference` — optional FT reference  
   - `accountSuffix` — optional override (defaults to `CBE_ACCOUNT_SUFFIX`)
4. API calls verifier-api:
   - `POST /verify-image?autoVerify=true` with `file` + `suffix`, or
   - `POST /verify-cbe` with `reference` + `accountSuffix`
5. On success: amount match (±1 ETB), unused FT reference, activate subscription.

## Local mock

```
BILLING_PROVIDER=cbe
CBE_VERIFIER_MODE=mock
CBE_ACCOUNT_SUFFIX=12345678
```

- Upload any JPEG/PNG, or tap **Simulate verified payment** in the app  
  (`POST /v1/billing/payments/{id}/cbe-mock-complete`).

## Live verifier

```
CBE_VERIFIER_MODE=live
CBE_VERIFIER_BASE_URL=https://verifyapi.leulzenebe.pro
CBE_VERIFIER_API_KEY=…          # https://verify.leul.et
CBE_ACCOUNT_NAME=VELVET Ethiopia
CBE_ACCOUNT_NUMBER=1000…
CBE_ACCOUNT_SUFFIX=…            # last 8 digits (required by verifier-api for CBE)
```

## Plans (seeded)

| Code | Price (ETB) | Match quota / 30 days |
|------|-------------|------------------------|
| STANDARD | 6,500 | 2 |
| PREMIUM | 13,000 | 4 |
| ELITE | 32,500 | unlimited (`-1`) |

## Member APIs

- `GET /v1/billing/plans`
- `GET /v1/billing/subscription`
- `POST /v1/billing/subscribe`
- `POST /v1/billing/payments/{id}/cbe-proof`
- `POST /v1/billing/payments/{id}/cbe-mock-complete` (mock only)

## Ops

`GET /v1/admin/ops/readiness` → `cbe.productionReady`

# Legal consent (soft launch)

Document set version: `LEGAL_DOCUMENT_SET_VERSION` (default `v2-2026-08`).

## Public pages

- http://localhost:8080/legal/
- Terms / Privacy / Community Guidelines in English and Amharic under `/legal/*.html`

## APIs

- `GET /v1/legal/current` — public version + doc paths
- `GET /v1/legal/status` — authenticated acceptance flag
- `POST /v1/legal/accept` `{ "documentSetVersion": "v1-2026-08" }`
- `POST /v1/auth/otp/verify` requires `acceptedLegalVersion` for **new** registrations

Acceptance is stored on `users.legal_accepted_*` and audited in `legal_acceptances`.

Templates require counsel review before production.

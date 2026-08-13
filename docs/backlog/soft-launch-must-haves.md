# Soft-launch Must-Have backlog

Product decision for soft launch: **keep single `MEMBER` role** (paid curated intros). Defer Host/Guest compensation (PAY-012–019, USR-010–012) until legal/ops model is confirmed.

Lawyer review still required for published legal text. Template docs ship in EN+AM under `/legal/`.

## Wave 1 — product surfaces (this sprint)

| ID | Item | Status |
|----|------|--------|
| LGL-009/022/026 | Privacy, Terms, Community Guidelines (EN+AM) | Done (`/legal/`) |
| LGL-010/023–025/031 | Explicit consent + 21+ adult marketplace / CSAE bans | Done (accept gate; v2 adult terms) |
| LGL-011 | Access / erase; export shows full JSON | Done |
| USR-015–018 | Profile DOB, bio, city in Flutter | Done |
| ADM-004 | Suspend/ban + promote in admin SPA | Done |
| SFT-001/002/008 | ID+selfie verification + badge (exists); no liveness yet | Partial |

## Wave 2 — safety ops minimum

| ID | Item | Status |
|----|------|--------|
| SFT-013–014 | Panic + GPS; runbook in wave2 doc | Done |
| SFT-017–020 | Pre/post-meeting concierge tasks + escalation | Done |
| SFT-023 | Incident reporting + triage (existing) | Done |
| SFT-025–026 | Time-boxed chat + post-meeting purge | Done |
| SFT-028–029 | Stronger contact-info blocking | Done |
| OPS-005–008 | Meetings tab + task ack/done | Done |

## Wave 3 — production integrations

| ID | Item | Status |
|----|------|--------|
| PAY | Live CBE fail-fast + checklist | Done (needs live API key) |
| USR-002 | Production SMS via `SMS_PROVIDER=http` | Done (needs aggregator) |
| UX-014 | FCM deps + `USE_FCM` wiring | Done (needs real google-services.json) |
| COM-014 | NLP via `MODERATION_PROVIDER=http` | Scaffolded |
| LGL-008 / TEC-007 | Ethiopia hosting | Ops (checklist) |
| LGL-016 | Panic GPS scrub after 7 days | Done |
| — | `VELVET_ENV=production` boot validation | Done |

See `docs/ops/production-checklist.md`.

## Explicitly deferred (not soft-launch blockers)

- Host/Guest dual economy + guest payouts (M-Pesa)
- E2EE (conflicts with server moderation Phase 1); Android `FLAG_SECURE` ships for soft launch
- Background / sex-offender / income checks
- Native Swift + Kotlin rewrite (Flutter stays)
- WebSocket chat, live voice/video calls
- Full venue contracts / ratings / revenue share
- Application fee + video interview panel

## Acceptance for soft launch

1. New users must accept current legal document set before OTP continue / home.
2. Members can set DOB (21+) and bilingual bio.
3. `GET /v1/admin/ops/readiness` documents integration readiness separately.
4. Clients browse **verified** active performer listings (rates + availability); performers manage listing visibility and calendar windows.
5. Ops settle performer payouts from the admin **Payouts** tab.

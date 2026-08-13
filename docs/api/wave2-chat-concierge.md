# Wave 2 — chat windowing & concierge meeting ops

## Chat (SFT-025 / SFT-026)

After a booking is **CONFIRMED** (or later):

- Send allowed only in **[startsAt − 2h, closesAt]**
- `closesAt` = `checkedOutAt + 1h` if checked out, else `startsAt + 1h`
- Before confirm / while PROPOSED: chat stays open for icebreakers
- After close: thread **LOCKED**; message bodies redacted to `[removed after meeting]` (job)
- Confirmed meetings with no check-in **45m after start** → `NO_SHOW`

API thread payload includes `canSend`, `windowOpensAt`, `windowClosesAt`, `windowReason`.

## Concierge tasks (SFT-017–020, OPS-005–008)

Table `concierge_tasks` + admin **Meetings** tab:

| Type | When |
|------|------|
| `PRE_CALL` | From T−30m until start |
| `ARRIVAL_CHECK` | T+15m, still no check-in |
| `FOLLOW_UP` | 1h after checkout (or 2h after start) |

Unacked `OPEN` tasks older than **15 minutes** → `ESCALATED` + on-call SMS/push.

Endpoints:

- `GET /v1/admin/concierge/tasks`
- `GET /v1/admin/concierge/meetings`
- `POST /v1/admin/concierge/tasks/{id}/ack`
- `POST /v1/admin/concierge/tasks/{id}/done`

Job: same schedule as booking reminders (`velvet.jobs.booking-reminder-ms`).

## Moderation (SFT-028 / SFT-029)

URLs, emails, phones, messaging apps, and “call me” cues are **blocked** (not held). Address-like phrases remain held for human review; held queue shows `ageMinutes`.

## Runbook (panic)

1. Panic → SMS to on-call + push; Ack in **Panics** tab.
2. If GPS present, share with emergency contacts / local authorities per ops policy.
3. Document outcome in member notes / audit.

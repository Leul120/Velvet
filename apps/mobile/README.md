# VELVET Mobile

Flutter client for **VELVET** — a 21+ adult booking marketplace. Clients browse verified performer listings, send booking interest, chat, and propose paid private bookings. Performers manage listings, availability, and incoming requests.

## Setup

```bash
cd apps/mobile
flutter pub get
flutter gen-l10n
flutter run
```

Point the app at your API by configuring `lib/core/config/api_config.dart` (or the env-specific setup your team uses).

## Localization

- Source strings: `lib/l10n/app_en.arb`, `lib/l10n/app_am.arb`
- After editing `.arb` files, run `flutter gen-l10n`
- Generated output: `lib/l10n/generated/`

## Tests

```bash
flutter test
```

Includes model parsing tests for connection/discover payloads and l10n smoke checks for marketplace copy.

## Architecture notes

- **Browse / Requests / Conversations / Listing** — member shell tabs (`lib/core/shell/member_shell.dart`)
- **Connections feature** — concierge intros, inbox, history (`lib/features/connections/`)
- **Legacy routes** — `/matches` → `/conversations`, `/history` → `/connections/history`, `/match/:id/celebrate` → `/connection/:id/confirmed`
- **API paths** — mobile uses `/v1/connections`, `/v1/chat/connections/…`, `/v1/bookings/by-connection/…` (legacy `/v1/matches` aliases remain on the server)
- **Request bodies** — booking propose still sends `matchId` in JSON (server field name)
- **Chat details** — consume `conversationStarters`; the app also accepts legacy `icebreakers` responses during rollout.

# Discovery & marketplace matching

## Paths to mutual

1. **Concierge intros** — `POST /v1/admin/connections` → members swipe ACCEPT/DECLINE on `/v1/connections`
2. **Discovery** — `GET /v1/discover` → `POST /v1/discover/{userId}/action` LIKE/PASS; reciprocal LIKE creates a connection with `source=DISCOVERY` and `status=MUTUAL`

Both unlock chat + private booking and can show the Flutter celebrate screen.

## Endpoints

### `GET /v1/discover?limit=20`
Requires **client** membership (performers do not browse). Returns performer listings with rates when set: `{ items: DiscoverCard[] }`.

### `GET /v1/discover/received`
Performer inbox of client likes. **No membership required** for performers.

### `POST /v1/discover/{userId}/action`
`{ "action": "LIKE" | "PASS" }` → `{ mutual, connectionId?, matchId?, counterpartDisplayName?, counterpartPhotoUrls? }`  
Clients need membership; performers responding to likes do not.

### `GET /v1/connections/mutual`
Open mutual connections for the Connections inbox (excludes completed meetings).

### Enriched `GET /v1/connections` / decision
Connection cards include `counterpartPhotoUrls`, `counterpartAge`, `counterpartCity`, bios, `source`, and `becameMutual` on decision.

### `GET|PATCH /v1/me/preferences`
`minAge`, `maxAge`, `maxDistanceKm`, `cities[]`

### `POST /v1/me/location`
`{ "latitude", "longitude" }` — used for distance filtering when both sides have coords.

## Gender / marketplace roles (asymmetric)

- Gender → role: men become `CLIENT`, women `PERFORMER` (paid clients may be `SUBSCRIBER`)
- **Clients** browse `GET /v1/discover` — **ID-verified** (`status=VERIFIED`) active performer listings only; LIKE notifies her
- Listing go-live requires approved verification (`LISTING_REQUIRES_VERIFICATION` if toggled early)
- **Performers** do not browse; they use `GET /v1/discover/received` and ACCEPT/PASS
- Mutual forms when a performer accepts a client’s like (quota charged to the client)
- Concierge intros only allowed male↔female
- App forces `/onboarding/gender` after legal if gender is unset

### Demo accounts (reset every API boot)

Local Docker sets `VELVET_SEED_RESET=true`. On each API start the demo roster is **wiped and reloaded** from `db/seed/demo_roster.sql` (not a one-shot Flyway migration).

Invite `VELVET-SEED`. Elite + legal accepted. Unsplash portraits + Addis lat/lng.

| Phone | Name | Gender | Notes |
|-------|------|--------|-------|
| `+251911100001`–`012` | Abel … Tedros (12) | MALE | Nearby browse; Abel mutual with Sara |
| `+251911200001`–`018` | Sara … Yordanos (18) | FEMALE | Likes-you queues prefilled |
| Admin | `+251911000000` | — | Staff portal / web `/admin` |

Disable with `VELVET_SEED_RESET=false` (required in production).

## Migration
`V18__discovery_likes.sql` — location, preferences, likes, connection source  
`V19__gender.sql` — `users.gender`  
`V20` / `V21` — legacy Flyway seeds (superseded at runtime by `DemoDataSeeder`)  
`db/seed/demo_roster.sql` — full wipe+reseed on boot

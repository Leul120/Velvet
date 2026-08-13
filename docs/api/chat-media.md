# Chat media & screen protection

## Uploads

`POST /v1/uploads/chat` (multipart `file`, max 50MB) → `{ url, mediaType, mime, fileName }`

Allowed:

| mediaType | examples |
|-----------|----------|
| IMAGE | jpeg, png, webp, gif |
| VIDEO | mp4, mov, webm, 3gp |
| AUDIO | mp3, m4a, aac, wav, ogg |
| FILE | pdf, doc(x), xls(x), txt, zip |

Send via `POST /v1/chat/connections/{connectionId}/messages` with optional `mediaType`, `mediaUrl`, `mediaName`, `mediaMime`. Caption may be empty when media is present. Conversation starters are still required before first media. The `/v1/chat/matches/{matchId}/messages` path remains a legacy alias.

## Voice notes (mobile)

Instagram-style in the chat composer (empty text field → mic):

- **Hold** mic to record AAC/`.m4a` (max 2 minutes)
- **Slide left** then release to cancel
- **Release** to send

Requires a **full app restart** after adding the `record` plugin (hot reload is not enough).

## Serving media

New uploads store **relative** URLs: `/v1/media/{key}`.

`GET /v1/media/**` streams from MinIO through the API (phones only need the API host/port, e.g. `:8088`). Set `S3_PUBLIC_BASE=relative` (docker default).

The Flutter helper `resolveMediaUrl` prefixes `API_BASE` for relative paths and rewrites legacy MinIO `localhost:9100` URLs to the API proxy when possible.

## Screen capture (Android)

`MainActivity` sets `FLAG_SECURE` so screenshots / screen recording are blocked where the OS honors it. Full restart required after native changes (not hot reload).

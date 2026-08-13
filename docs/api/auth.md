# Auth API (Phase 1)

## POST `/v1/auth/otp/request`

```json
{ "phone": "+251911000001", "inviteCode": "VELVET-SEED", "deviceId": "…", "platform": "android" }
```

Response includes `devOtp` when `OTP_EXPOSE=true`.

## POST `/v1/auth/otp/verify`

```json
{ "phone": "+251911000001", "code": "123456", "deviceId": "…", "platform": "android" }
```

Returns `accessToken`, `refreshToken`, `user`.

## POST `/v1/auth/refresh`

```json
{ "refreshToken": "…" }
```

## GET/PATCH `/v1/me`

Bearer access token required. PATCH may set `displayName`, `preferredLocale`, `dateOfBirth` (21+), bios, city, interests.

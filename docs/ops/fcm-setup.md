# FCM setup (Flutter)

VELVET registers push tokens on login via `PushRegistration`.

## Local / closed beta

Default: stable `dev-…` token (API push path stays testable with `PUSH_PROVIDER=log`).

Override:

```bash
flutter run --dart-define=PUSH_TOKEN=manual-token-for-proxy
```

Test HTTP push without Firebase:

```
PUSH_PROVIDER=http
PUSH_HTTP_URL=http://localhost:8080/v1/internal/push/deliver
```

## Production

1. Create a Firebase project and add Android (`com.velvet.velvet_mobile`) + iOS apps.
2. **Replace** the placeholder `apps/mobile/android/app/google-services.json` with the real file from Firebase Console.
3. Dependencies are already in `pubspec.yaml` (`firebase_core`, `firebase_messaging`); Google Services plugin is applied in Android Gradle.
4. `main.dart` calls `Firebase.initializeApp()` when `USE_FCM=true`.
5. Run:

```bash
flutter run --dart-define=USE_FCM=true --dart-define=API_BASE=https://api.yourdomain.et
```

6. Point API push gateway at your FCM proxy (or Cloud Function):

```
PUSH_PROVIDER=http
PUSH_HTTP_URL=https://your-fcm-proxy/send
PUSH_API_KEY=…
```

`HttpPushGateway` posts `{ "token", "title", "body" }`.

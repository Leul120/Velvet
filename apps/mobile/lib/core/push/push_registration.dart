/// Push token registration for member devices.
///
/// Production: `--dart-define=USE_FCM=true` + real `google-services.json` (see docs/ops/fcm-setup.md).
/// Local/dev: stable UUID token so API push/outbox paths stay exercisable.
library;

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:uuid/uuid.dart';

abstract class PushTokenSource {
  Future<String?> resolveToken();
}

class DevPushTokenSource implements PushTokenSource {
  DevPushTokenSource(this.storage);
  final FlutterSecureStorage storage;

  @override
  Future<String?> resolveToken() async {
    const fromDefine = String.fromEnvironment('PUSH_TOKEN', defaultValue: '');
    if (fromDefine.isNotEmpty) return fromDefine;

    var token = await storage.read(key: 'push_token');
    if (token == null || token.isEmpty) {
      token = 'dev-${const Uuid().v4()}';
      await storage.write(key: 'push_token', value: token);
    }
    return token;
  }
}

class FcmPushTokenSource implements PushTokenSource {
  static const enabled = bool.fromEnvironment('USE_FCM', defaultValue: false);

  @override
  Future<String?> resolveToken() async {
    if (!enabled) return null;
    final messaging = FirebaseMessaging.instance;
    await messaging.requestPermission(alert: true, badge: true, sound: true);
    return messaging.getToken();
  }
}

class PushRegistration {
  PushRegistration({
    required this.dev,
    required this.fcm,
  });

  final DevPushTokenSource dev;
  final FcmPushTokenSource fcm;

  Future<String> token() async {
    if (FcmPushTokenSource.enabled) {
      final fcmToken = await fcm.resolveToken();
      if (fcmToken == null || fcmToken.isEmpty) {
        throw StateError('FCM token unavailable — check google-services.json and notifications permission.');
      }
      return fcmToken;
    }
    return (await dev.resolveToken())!;
  }
}

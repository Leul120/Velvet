import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:velvet_mobile/core/network/dio_client.dart';
import 'package:velvet_mobile/core/network/session_bridge.dart';
import 'package:velvet_mobile/core/push/push_registration.dart';
import 'package:velvet_mobile/features/auth/auth_api.dart';
import 'package:velvet_mobile/features/auth/auth_models.dart';
import 'package:velvet_mobile/features/auth/role_helpers.dart';

final authControllerProvider = ChangeNotifierProvider<AuthController>((ref) {
  final storage = ref.watch(secureStorageProvider);
  final refresh = ref.watch(routerRefreshProvider);
  final bridge = ref.watch(sessionBridgeProvider);

  final controller = AuthController(
    api: AuthApi(ref.watch(dioProvider)),
    storage: storage,
    push: PushRegistration(
      dev: DevPushTokenSource(storage),
      fcm: FcmPushTokenSource(),
    ),
    refresh: refresh,
  );

  // Keep GoRouter in sync whenever auth state changes (stable listenable).
  void onAuthChange() => refresh.ping();
  controller.addListener(onAuthChange);

  // Dio → clear in-memory user and force /auth.
  bridge.bind(() async {
    await controller.clearLocalSession();
    refresh.goAuth();
  });

  ref.onDispose(() {
    controller.removeListener(onAuthChange);
    bridge.unbind();
  });

  return controller..bootstrap();
});

class AuthController extends ChangeNotifier {
  AuthController({
    required this.api,
    required this.storage,
    required this.push,
    required this.refresh,
  });

  final AuthApi api;
  final FlutterSecureStorage storage;
  final PushRegistration push;
  final RouterRefresh refresh;

  UserSummary? user;
  bool bootstrapped = false;
  String? error;

  bool get isAuthenticated => user != null;
  bool get needsLegalAccept => user != null && !user!.legalAccepted;
  bool get needsGenderSetup {
    final currentUser = user;
    if (currentUser == null || !currentUser.legalAccepted) return false;
    // Gender-based discovery is a member-only flow. Staff and venue accounts
    // should never be routed into the member onboarding screens.
    return isMemberRole(currentUser.role) &&
        (currentUser.gender == null || currentUser.gender!.isEmpty);
  }

  bool get needsProfileSetup {
    final currentUser = user;
    return currentUser != null &&
        isMemberRole(currentUser.role) &&
        currentUser.legalAccepted &&
        currentUser.gender != null &&
        !currentUser.profileReady;
  }

  Future<void> bootstrap() async {
    final token = await storage.read(key: 'access_token');
    if (token != null && token.isNotEmpty) {
      try {
        final id = await storage.read(key: 'user_id');
        final phone = await storage.read(key: 'user_phone');
        final status = await storage.read(key: 'user_status');
        final role = await storage.read(key: 'user_role');
        final locale = await storage.read(key: 'user_locale');
        final name = await storage.read(key: 'user_name');
        final gender = await storage.read(key: 'user_gender');
        final profileReady = (await storage.read(key: 'profile_ready')) == 'true';
        final legalAccepted = (await storage.read(key: 'legal_accepted')) == 'true';
        final legalVersion = await storage.read(key: 'legal_version') ?? 'v1-2026-08';
        if (id != null && phone != null) {
          user = UserSummary(
            id: id,
            phone: phone,
            displayName: name,
            status: status ?? 'APPLIED',
            role: role ?? 'MEMBER',
            preferredLocale: locale ?? 'am',
            gender: gender,
            profileReady: profileReady,
            legalAccepted: legalAccepted,
            legalVersionRequired: legalVersion,
          );
          await _registerPushToken();
          try {
            final statusLegal = await api.legalStatus();
            // Session may have been cleared by Dio if tokens were invalid.
            if (user == null) {
              bootstrapped = true;
              notifyListeners();
              return;
            }
            user = user!.copyWith(
              legalAccepted: statusLegal.accepted,
              legalVersionRequired: statusLegal.documentSetVersion,
            );
            await storage.write(key: 'legal_accepted', value: '${statusLegal.accepted}');
            await storage.write(key: 'legal_version', value: statusLegal.documentSetVersion);
          } catch (_) {
            // Offline / API down — keep cached legal flag (unless session expired).
          }
        }
      } catch (_) {
        await signOut();
        return;
      }
    }
    bootstrapped = true;
    notifyListeners();
  }

  Future<OtpRequestResult> requestOtp({
    required String phone,
    required String inviteCode,
  }) async {
    error = null;
    try {
      return await api.requestOtp(phone: phone, inviteCode: inviteCode);
    } catch (e) {
      error = apiErrorMessage(e);
      notifyListeners();
      rethrow;
    }
  }

  Future<void> verifyOtp({
    required String phone,
    required String code,
    String? acceptedLegalVersion,
  }) async {
    error = null;
    try {
      final tokens = await api.verifyOtp(
        phone: phone,
        code: code,
        acceptedLegalVersion: acceptedLegalVersion,
      );
      await _persistSession(tokens);
      user = tokens.user;
      await _registerPushToken();
      notifyListeners();
    } catch (e) {
      error = apiErrorMessage(e);
      notifyListeners();
      rethrow;
    }
  }

  Future<void> acceptLegal(String documentSetVersion) async {
    final updated = await api.acceptLegal(documentSetVersion);
    user = updated;
    await storage.write(key: 'legal_accepted', value: '${updated.legalAccepted}');
    await storage.write(key: 'legal_version', value: updated.legalVersionRequired);
    if (updated.gender != null) {
      await storage.write(key: 'user_gender', value: updated.gender);
    }
    notifyListeners();
  }

  void setGender(String? gender, {String? role}) {
    user = user?.copyWith(
      gender: gender,
      clearGender: gender == null || gender.isEmpty,
      role: role,
      profileReady: false,
    );
    if (gender == null || gender.isEmpty) {
      storage.delete(key: 'user_gender');
    } else {
      storage.write(key: 'user_gender', value: gender);
    }
    if (role != null && role.isNotEmpty) {
      storage.write(key: 'user_role', value: role);
    }
    notifyListeners();
  }

  void setProfileReady(bool ready) {
    user = user?.copyWith(profileReady: ready);
    storage.write(key: 'profile_ready', value: '$ready');
    notifyListeners();
  }

  /// Clears in-memory session (tokens already deleted by Dio / signOut).
  Future<void> clearLocalSession() async {
    user = null;
    error = null;
    bootstrapped = true;
    notifyListeners();
  }

  Future<void> signOut() async {
    await storage.deleteAll();
    user = null;
    error = null;
    bootstrapped = true;
    notifyListeners();
    refresh.goAuth();
  }

  Future<void> withdrawAccount() async {
    await api.withdraw();
    await signOut();
  }

  Future<void> eraseAccount() async {
    await api.erasure();
    await signOut();
  }

  Future<void> _registerPushToken() async {
    try {
      final token = await push.token();
      await storage.write(key: 'push_token', value: token);
      await api.registerPushToken(token: token);
    } catch (_) {
      // Non-fatal for local/dev
    }
  }

  Future<void> _persistSession(TokenResponse tokens) async {
    await storage.write(key: 'access_token', value: tokens.accessToken);
    await storage.write(key: 'refresh_token', value: tokens.refreshToken);
    await storage.write(key: 'user_id', value: tokens.user.id);
    await storage.write(key: 'user_phone', value: tokens.user.phone);
    await storage.write(key: 'user_status', value: tokens.user.status);
    await storage.write(key: 'user_role', value: tokens.user.role);
    await storage.write(key: 'user_locale', value: tokens.user.preferredLocale);
    await storage.write(key: 'legal_accepted', value: '${tokens.user.legalAccepted}');
    await storage.write(key: 'legal_version', value: tokens.user.legalVersionRequired);
    await storage.write(key: 'profile_ready', value: '${tokens.user.profileReady}');
    if (tokens.user.gender != null) {
      await storage.write(key: 'user_gender', value: tokens.user.gender);
    }
    if (tokens.user.displayName != null) {
      await storage.write(key: 'user_name', value: tokens.user.displayName);
    }
  }
}

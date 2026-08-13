import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// Stable listenable for [GoRouter.refreshListenable].
/// Also holds the live [GoRouter] so session expiry can [go] imperatively.
class RouterRefresh extends ChangeNotifier {
  GoRouter? _router;

  void attach(GoRouter router) => _router = router;

  void ping() => notifyListeners();

  /// Clear-auth redirect that does not rely solely on refreshListenable.
  void goAuth() {
    ping();
    final router = _router;
    if (router == null) return;
    final loc = router.routeInformationProvider.value.uri.path;
    if (loc == '/auth' || loc.startsWith('/auth/')) return;
    router.go('/auth');
  }
}

final routerRefreshProvider = Provider<RouterRefresh>((ref) {
  final refresh = RouterRefresh();
  ref.onDispose(refresh.dispose);
  return refresh;
});

/// Callback bridge so Dio can clear auth without a circular Provider dependency.
class SessionBridge {
  Future<void> Function()? _onExpired;

  void bind(Future<void> Function() onExpired) => _onExpired = onExpired;

  void unbind() => _onExpired = null;

  Future<void> expire() async {
    final cb = _onExpired;
    if (cb != null) {
      await cb();
    }
  }
}

final sessionBridgeProvider = Provider<SessionBridge>((ref) {
  return SessionBridge();
});

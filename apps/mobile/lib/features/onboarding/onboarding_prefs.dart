import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:velvet_mobile/core/network/session_bridge.dart';

const _welcomeSeenKey = 'marketplace_welcome_seen';
const _discoverCoachSeenKey = 'discover_coach_seen';

final onboardingPrefsProvider =
    StateNotifierProvider<OnboardingPrefsController, OnboardingPrefsState>((ref) {
  return OnboardingPrefsController(ref);
});

class OnboardingPrefsState {
  const OnboardingPrefsState({
    this.loaded = false,
    this.welcomeSeen = false,
    this.discoverCoachSeen = false,
  });

  final bool loaded;
  final bool welcomeSeen;
  final bool discoverCoachSeen;

  OnboardingPrefsState copyWith({
    bool? loaded,
    bool? welcomeSeen,
    bool? discoverCoachSeen,
  }) {
    return OnboardingPrefsState(
      loaded: loaded ?? this.loaded,
      welcomeSeen: welcomeSeen ?? this.welcomeSeen,
      discoverCoachSeen: discoverCoachSeen ?? this.discoverCoachSeen,
    );
  }
}

class OnboardingPrefsController extends StateNotifier<OnboardingPrefsState> {
  OnboardingPrefsController(this._ref) : super(const OnboardingPrefsState()) {
    _load();
  }

  final Ref _ref;

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    state = OnboardingPrefsState(
      loaded: true,
      welcomeSeen: prefs.getBool(_welcomeSeenKey) ?? false,
      discoverCoachSeen: prefs.getBool(_discoverCoachSeenKey) ?? false,
    );
    _ref.read(routerRefreshProvider).ping();
  }

  Future<void> markWelcomeSeen() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_welcomeSeenKey, true);
    state = state.copyWith(welcomeSeen: true);
  }

  Future<void> markDiscoverCoachSeen() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_discoverCoachSeenKey, true);
    state = state.copyWith(discoverCoachSeen: true);
  }
}

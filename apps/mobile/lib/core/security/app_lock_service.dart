import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Manages local App Lock PIN security & state.
class AppLockService extends ChangeNotifier with WidgetsBindingObserver {
  AppLockService._();
  static final AppLockService instance = AppLockService._();

  static const _keyPin = 'velvet_app_lock_pin';
  static const _keyEnabled = 'velvet_app_lock_enabled';

  bool _isLocked = false;
  bool get isLocked => _isLocked;

  bool _isEnabled = false;
  bool get isEnabled => _isEnabled;

  String? _pin;

  Future<void> init() async {
    WidgetsBinding.instance.addObserver(this);
    final prefs = await SharedPreferences.getInstance();
    _isEnabled = prefs.getBool(_keyEnabled) ?? false;
    _pin = prefs.getString(_keyPin);
    if (_isEnabled && _pin != null) {
      _isLocked = true;
    }
    notifyListeners();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      if (_isEnabled && _pin != null) {
        _isLocked = true;
        notifyListeners();
      }
    }
  }

  Future<void> setPin(String newPin) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyPin, newPin);
    await prefs.setBool(_keyEnabled, true);
    _pin = newPin;
    _isEnabled = true;
    _isLocked = false;
    notifyListeners();
  }

  Future<void> disableLock() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyPin);
    await prefs.setBool(_keyEnabled, false);
    _pin = null;
    _isEnabled = false;
    _isLocked = false;
    notifyListeners();
  }

  bool verifyPin(String enteredPin) {
    if (_pin == enteredPin) {
      _isLocked = false;
      notifyListeners();
      return true;
    }
    return false;
  }

  void lockNow() {
    if (_isEnabled && _pin != null) {
      _isLocked = true;
      notifyListeners();
    }
  }
}

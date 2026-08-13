import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

final lowBandwidthProvider =
    StateNotifierProvider<LowBandwidthController, bool>((ref) => LowBandwidthController());

class LowBandwidthController extends StateNotifier<bool> {
  LowBandwidthController() : super(false) {
    _load();
  }

  static const _key = 'low_bandwidth';

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    state = prefs.getBool(_key) ?? false;
  }

  Future<void> setEnabled(bool value) async {
    state = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_key, value);
  }
}

/// Decode width hint for NetworkImage / Image.network under low-bandwidth mode.
int? mediaCacheWidth(bool lowBandwidth, {int full = 1600, int compressed = 720}) =>
    lowBandwidth ? compressed : full;

int imagePickQuality(bool lowBandwidth) => lowBandwidth ? 78 : 92;

int imagePickMaxWidth(bool lowBandwidth) => lowBandwidth ? 1280 : 2048;

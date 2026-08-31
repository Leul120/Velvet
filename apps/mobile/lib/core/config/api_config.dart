class ApiConfig {
  /// Live Render API (default). Override for local Docker:
  ///   Physical device: --dart-define=API_BASE=http://YOUR_LAN_IP:8088
  ///   Android emulator: --dart-define=API_BASE=http://10.0.2.2:8088
  static const String baseUrl = String.fromEnvironment(
    'API_BASE',
    defaultValue: 'https://velvet-api-gcnd.onrender.com',
  );
}

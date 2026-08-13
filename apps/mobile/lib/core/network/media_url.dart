import 'package:velvet_mobile/core/config/api_config.dart';

/// Resolves stored media URLs for the current API host.
///
/// New uploads store relative paths `/v1/media/{key}` (API proxy).
/// Older rows may still use absolute MinIO URLs (`localhost:9100` / stale LAN).
String resolveMediaUrl(String? url) {
  if (url == null || url.isEmpty) return '';

  final api = Uri.tryParse(ApiConfig.baseUrl);
  if (api == null || api.host.isEmpty) return url;

  if (url.startsWith('/')) {
    final base = ApiConfig.baseUrl.replaceAll(RegExp(r'/$'), '');
    return '$base$url';
  }

  final uri = Uri.tryParse(url);
  if (uri == null || uri.host.isEmpty) return url;

  // Already pointed at the API media proxy — keep path, fix host/port if needed.
  if (uri.path.startsWith('/v1/media/')) {
    return uri.replace(
      scheme: api.scheme,
      host: api.host,
      port: api.hasPort ? api.port : null,
    ).toString();
  }

  final host = uri.host;
  final isLoopback = host == 'localhost' || host == '127.0.0.1' || host == '10.0.2.2';
  final port = uri.hasPort ? uri.port : null;
  final isMinioPort = port == 9100 || port == 9000;
  if (!isLoopback && !(isMinioPort && host != api.host)) {
    return url;
  }

  // Legacy MinIO public URLs: try API proxy rewrite when path is /{bucket}/{key}.
  final segments = uri.pathSegments;
  if (segments.length >= 2) {
    final key = segments.skip(1).join('/');
    if (key.isNotEmpty) {
      final base = ApiConfig.baseUrl.replaceAll(RegExp(r'/$'), '');
      return '$base/v1/media/$key';
    }
  }

  final targetPort = switch (port) {
    9000 => 9100,
    null => 9100,
    _ => port,
  };
  return uri.replace(host: api.host, port: targetPort).toString();
}

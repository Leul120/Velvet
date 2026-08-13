import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:velvet_mobile/core/config/api_config.dart';
import 'package:velvet_mobile/core/network/session_bridge.dart';

final secureStorageProvider = Provider<FlutterSecureStorage>((ref) {
  return const FlutterSecureStorage();
});

JsonDecodeCallback get _safeJsonDecode => (String text) {
      final trimmed = text.trim();
      if (trimmed.isEmpty) return null;
      try {
        return jsonDecode(trimmed);
      } on FormatException {
        return null;
      }
    };

/// Business error code from API envelope when present.
String? apiErrorCode(Object error) {
  if (error is DioException) {
    final data = error.response?.data;
    if (data is Map && data['code'] is String) {
      return data['code'] as String;
    }
  }
  return null;
}

/// Friendly message for UI surfaces (avoids raw Dio/FormatException noise).
String apiErrorMessage(Object error) {
  if (error is DioException) {
    final data = error.response?.data;
    if (data is Map && data['message'] is String) {
      return data['message'] as String;
    }
    if (data is Map && data['code'] is String) {
      return data['code'] as String;
    }
    if (error.message != null &&
        error.message!.isNotEmpty &&
        !error.message!.startsWith('DioException') &&
        !error.message!.toLowerCase().contains('format') &&
        !error.message!.toLowerCase().contains('syntax')) {
      final code = error.response?.statusCode;
      if (error.type == DioExceptionType.badResponse && code == 401) {
        return 'Session expired. Please sign in again.';
      }
      if (error.type == DioExceptionType.badResponse) {
        return error.message!;
      }
    }
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return 'Connection timed out. Check that the API is reachable.';
      case DioExceptionType.connectionError:
        return 'Cannot reach API at ${ApiConfig.baseUrl}. Check Wi‑Fi and API_BASE.';
      case DioExceptionType.badResponse:
        final code = error.response?.statusCode;
        if (code == 401) return 'Session expired. Please sign in again.';
        return 'Request failed${code != null ? ' ($code)' : ''}.';
      case DioExceptionType.cancel:
        return 'Request cancelled.';
      case DioExceptionType.badCertificate:
        return 'Secure connection failed.';
      case DioExceptionType.transformTimeout:
        return 'Response processing timed out.';
      case DioExceptionType.unknown:
        final msg = error.error?.toString() ?? error.message ?? '';
        if (msg.toLowerCase().contains('format') || msg.toLowerCase().contains('syntax')) {
          return 'Invalid response from API. Try signing out and back in.';
        }
        return msg.isNotEmpty ? msg : 'Unexpected network error.';
    }
  }
  final raw = error.toString();
  if (raw.toLowerCase().contains('format') || raw.toLowerCase().contains('syntax')) {
    return 'Invalid response from API. Try signing out and back in.';
  }
  return raw;
}

final dioProvider = Provider<Dio>((ref) {
  final storage = ref.watch(secureStorageProvider);
  final bridge = ref.watch(sessionBridgeProvider);
  final dio = Dio(
    BaseOptions(
      baseUrl: ApiConfig.baseUrl,
      connectTimeout: const Duration(seconds: 20),
      receiveTimeout: const Duration(seconds: 20),
      headers: {'Accept': 'application/json'},
      // 4xx/5xx must throw into onError. Rejecting from onResponse inside
      // QueuedInterceptorsWrapper skips onError — which broke session expiry.
      validateStatus: (status) => status != null && status >= 200 && status < 300,
      responseType: ResponseType.json,
    ),
  );

  dio.transformer = BackgroundTransformer()..jsonDecodeCallback = _safeJsonDecode;

  var expiring = false;
  Future<void> expireSession() async {
    if (expiring) return;
    expiring = true;
    try {
      await storage.deleteAll();
      await bridge.expire();
    } finally {
      expiring = false;
    }
  }

  dio.interceptors.add(
    QueuedInterceptorsWrapper(
      onRequest: (options, handler) async {
        final token = await storage.read(key: 'access_token');
        if (token != null && token.isNotEmpty) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        if (options.data is FormData) {
          options.headers.remove(Headers.contentTypeHeader);
        } else {
          options.headers.putIfAbsent(Headers.contentTypeHeader, () => 'application/json');
        }
        handler.next(options);
      },
      onError: (error, handler) async {
        final status = error.response?.statusCode;
        final path = error.requestOptions.path;
        final alreadyRetried = error.requestOptions.extra['retried'] == true;
        final isAuthPath = path.contains('/v1/auth/');
        final unauthorized = status == 401;

        if (unauthorized && !isAuthPath && !alreadyRetried) {
          try {
            final refresh = await storage.read(key: 'refresh_token');
            if (refresh == null || refresh.isEmpty) {
              await expireSession();
              return handler.next(error);
            }
            final refreshDio = Dio(
              BaseOptions(
                baseUrl: ApiConfig.baseUrl,
                headers: {
                  'Content-Type': 'application/json',
                  'Accept': 'application/json',
                },
                validateStatus: (s) => s != null && s >= 200 && s < 300,
              ),
            );
            refreshDio.transformer = BackgroundTransformer()..jsonDecodeCallback = _safeJsonDecode;

            final res = await refreshDio.post(
              '/v1/auth/refresh',
              data: {'refreshToken': refresh},
            );
            if (res.data is! Map) {
              await expireSession();
              return handler.next(error);
            }
            final data = Map<String, dynamic>.from(res.data as Map);
            final access = data['accessToken'] as String?;
            final newRefresh = data['refreshToken'] as String?;
            if (access == null || newRefresh == null) {
              await expireSession();
              return handler.next(error);
            }
            await storage.write(key: 'access_token', value: access);
            await storage.write(key: 'refresh_token', value: newRefresh);

            final req = error.requestOptions;
            req.headers['Authorization'] = 'Bearer $access';
            req.extra['retried'] = true;
            final response = await dio.fetch(req);
            return handler.resolve(response);
          } catch (_) {
            await expireSession();
            return handler.next(error);
          }
        }

        if (unauthorized && !isAuthPath) {
          await expireSession();
        }
        return handler.next(error);
      },
    ),
  );

  return dio;
});

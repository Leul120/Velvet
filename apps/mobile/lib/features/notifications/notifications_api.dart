import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:velvet_mobile/core/network/dio_client.dart';

final notificationsApiProvider =
    Provider<NotificationsApi>((ref) => NotificationsApi(ref.watch(dioProvider)));

class AppNotification {
  AppNotification({
    required this.id,
    required this.subject,
    required this.body,
    required this.read,
    required this.createdAt,
    this.relatedType,
    this.relatedId,
  });

  final String id;
  final String subject;
  final String body;
  final String? relatedType;
  final String? relatedId;
  final bool read;
  final DateTime createdAt;

  factory AppNotification.fromJson(Map<String, dynamic> json) => AppNotification(
        id: json['id'] as String,
        subject: json['subject'] as String,
        body: json['body'] as String,
        relatedType: json['relatedType'] as String?,
        relatedId: json['relatedId'] as String?,
        read: json['read'] as bool? ?? false,
        createdAt: DateTime.parse(json['createdAt'] as String),
      );
}

class NotificationsApi {
  NotificationsApi(this._dio);
  final Dio _dio;

  Future<List<AppNotification>> list({bool unreadOnly = false}) async {
    final res = await _dio.get('/v1/me/notifications', queryParameters: {
      'unreadOnly': unreadOnly,
    });
    return (res.data as List<dynamic>)
        .map((e) => AppNotification.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<int> unreadCount() async {
    final res = await _dio.get('/v1/me/notifications/unread-count');
    return (res.data as Map<String, dynamic>)['count'] as int? ?? 0;
  }

  Future<void> markRead(String id) async {
    await _dio.post('/v1/me/notifications/$id/read');
  }

  Future<void> markAllRead() async {
    await _dio.post('/v1/me/notifications/read-all');
  }
}

final unreadNotificationsProvider = FutureProvider.autoDispose<int>((ref) {
  return ref.watch(notificationsApiProvider).unreadCount();
});

final notificationsProvider = FutureProvider.autoDispose<List<AppNotification>>((ref) {
  return ref.watch(notificationsApiProvider).list();
});

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:velvet_mobile/core/network/dio_client.dart';

final availabilityApiProvider = Provider<AvailabilityApi>(
  (ref) => AvailabilityApi(ref.watch(dioProvider)),
);

class AvailabilityWindow {
  AvailabilityWindow({
    required this.id,
    required this.startsAt,
    required this.endsAt,
    this.note,
  });

  final String id;
  final DateTime startsAt;
  final DateTime endsAt;
  final String? note;

  factory AvailabilityWindow.fromJson(Map<String, dynamic> json) {
    return AvailabilityWindow(
      id: json['id'] as String,
      startsAt: DateTime.parse(json['startsAt'] as String).toLocal(),
      endsAt: DateTime.parse(json['endsAt'] as String).toLocal(),
      note: json['note'] as String?,
    );
  }
}

class AvailabilityApi {
  AvailabilityApi(this._dio);

  final Dio _dio;

  Future<List<AvailabilityWindow>> mine() async {
    final res = await _dio.get('/v1/availability/me');
    final items = (res.data['items'] as List?) ?? [];
    return items
        .map((e) => AvailabilityWindow.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<List<AvailabilityWindow>> forUser(String userId) async {
    final res = await _dio.get('/v1/availability/users/$userId');
    final items = (res.data['items'] as List?) ?? [];
    return items
        .map((e) => AvailabilityWindow.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<AvailabilityWindow> create({
    required DateTime startsAt,
    required DateTime endsAt,
    String? note,
  }) async {
    final res = await _dio.post('/v1/availability', data: {
      'startsAt': startsAt.toUtc().toIso8601String(),
      'endsAt': endsAt.toUtc().toIso8601String(),
      if (note != null && note.isNotEmpty) 'note': note,
    });
    return AvailabilityWindow.fromJson(res.data as Map<String, dynamic>);
  }

  Future<void> delete(String windowId) async {
    await _dio.delete('/v1/availability/$windowId');
  }
}

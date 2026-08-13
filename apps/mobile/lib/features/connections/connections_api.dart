import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http_parser/http_parser.dart';
import 'package:velvet_mobile/core/network/dio_client.dart';
import 'package:velvet_mobile/core/network/upload_mime.dart';

final connectionsApiProvider = Provider<ConnectionsApi>((ref) => ConnectionsApi(ref.watch(dioProvider)));
final verificationApiProvider =
    Provider<VerificationApi>((ref) => VerificationApi(ref.watch(dioProvider)));

class ConnectionItem {
  ConnectionItem({
    required this.id,
    required this.status,
    required this.awaitingMyResponse,
    required this.mutual,
    this.counterpartDisplayName,
    this.counterpartUserId,
    this.introNoteEn,
    this.introNoteAm,
    this.venueName,
    this.expiresAt,
    this.meetingCompleted = false,
    this.meetingVenueName,
    this.counterpartPhotoUrls = const [],
    this.counterpartAge,
    this.counterpartCity,
    this.counterpartBioEn,
    this.counterpartBioAm,
    this.counterpartInterests = const [],
    this.source = 'CONCIERGE',
    this.becameMutual = false,
    this.lastMessagePreview,
    this.lastMessageAt,
    this.lastMessageFromMe = false,
    this.unreadCount = 0,
    this.turn = 'NONE',
    this.counterpartVerified = false,
    this.counterpartTrustScore,
  });

  final String id;
  final String status;
  final String? counterpartDisplayName;
  final String? counterpartUserId;
  final String? introNoteEn;
  final String? introNoteAm;
  final String? venueName;
  final DateTime? expiresAt;
  final bool awaitingMyResponse;
  final bool mutual;
  final bool meetingCompleted;
  final String? meetingVenueName;
  final List<String> counterpartPhotoUrls;
  final int? counterpartAge;
  final String? counterpartCity;
  final String? counterpartBioEn;
  final String? counterpartBioAm;
  final List<String> counterpartInterests;
  final String source;
  final bool becameMutual;
  final String? lastMessagePreview;
  final DateTime? lastMessageAt;
  final bool lastMessageFromMe;
  final int unreadCount;
  final String turn;
  final bool counterpartVerified;
  final int? counterpartTrustScore;

  factory ConnectionItem.fromJson(Map<String, dynamic> json) {
    final venue = json['suggestedVenue'] as Map<String, dynamic>?;
    final photos = json['counterpartPhotoUrls'];
    final interests = json['counterpartInterests'];
    return ConnectionItem(
      id: json['id'] as String,
      status: json['status'] as String,
      counterpartDisplayName: json['counterpartDisplayName'] as String?,
      counterpartUserId: json['counterpartUserId'] as String?,
      introNoteEn: json['introNoteEn'] as String?,
      introNoteAm: json['introNoteAm'] as String?,
      venueName: venue?['name'] as String?,
      expiresAt: json['expiresAt'] != null ? DateTime.tryParse(json['expiresAt'] as String) : null,
      awaitingMyResponse: json['awaitingMyResponse'] as bool? ?? false,
      mutual: json['mutual'] as bool? ?? false,
      meetingCompleted: json['meetingCompleted'] as bool? ?? false,
      meetingVenueName: json['meetingVenueName'] as String?,
      counterpartPhotoUrls: photos is List
          ? photos.map((e) => e.toString()).toList()
          : const [],
      counterpartAge: json['counterpartAge'] as int?,
      counterpartCity: json['counterpartCity'] as String?,
      counterpartBioEn: json['counterpartBioEn'] as String?,
      counterpartBioAm: json['counterpartBioAm'] as String?,
      counterpartInterests: interests is List
          ? interests.map((e) => e.toString()).toList()
          : const [],
      source: json['source'] as String? ?? 'CONCIERGE',
      becameMutual: json['becameMutual'] as bool? ?? false,
      lastMessagePreview: json['lastMessagePreview'] as String?,
      lastMessageAt: json['lastMessageAt'] != null
          ? DateTime.tryParse(json['lastMessageAt'] as String)
          : null,
      lastMessageFromMe: json['lastMessageFromMe'] as bool? ?? false,
      unreadCount: (json['unreadCount'] as num?)?.toInt() ?? 0,
      turn: json['turn'] as String? ?? 'NONE',
      counterpartVerified: json['counterpartVerified'] as bool? ?? false,
      counterpartTrustScore: json['counterpartTrustScore'] as int?,
    );
  }
}

class VerificationStatus {
  VerificationStatus({
    required this.id,
    required this.status,
    this.notes,
  });

  final String id;
  final String status;
  final String? notes;

  factory VerificationStatus.fromJson(Map<String, dynamic> json) {
    return VerificationStatus(
      id: json['id'] as String,
      status: json['status'] as String,
      notes: json['notes'] as String?,
    );
  }
}

class ConnectionsApi {
  ConnectionsApi(this._dio);
  final Dio _dio;

  Future<List<ConnectionItem>> listConciergeIntros() async {
    final res = await _dio.get('/v1/connections');
    final list = res.data as List<dynamic>;
    return list.map((e) => ConnectionItem.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<List<ConnectionItem>> mutual() async {
    final res = await _dio.get('/v1/connections/mutual');
    final list = res.data as List<dynamic>;
    return list.map((e) => ConnectionItem.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<List<ConnectionItem>> history() async {
    final res = await _dio.get('/v1/connections/history');
    final list = res.data as List<dynamic>;
    return list.map((e) => ConnectionItem.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<ConnectionItem> decide({required String id, required String action}) async {
    final res = await _dio.post('/v1/connections/$id/decision', data: {'action': action});
    return ConnectionItem.fromJson(res.data as Map<String, dynamic>);
  }
}

class VerificationApi {
  VerificationApi(this._dio);
  final Dio _dio;

  Future<VerificationStatus?> me() async {
    try {
      final res = await _dio.get('/v1/verification/me');
      return VerificationStatus.fromJson(res.data as Map<String, dynamic>);
    } on DioException catch (e) {
      if (e.response?.statusCode == 400) return null;
      rethrow;
    }
  }

  Future<VerificationStatus> submit({
    required String idDocumentUrl,
    required String selfieUrl,
    String? notes,
  }) async {
    final res = await _dio.post('/v1/verification', data: {
      'idDocumentUrl': idDocumentUrl,
      'selfieUrl': selfieUrl,
      'notes': ?notes,
    });
    return VerificationStatus.fromJson(res.data as Map<String, dynamic>);
  }

  Future<String> upload({required String kind, required String filePath}) async {
    final name = filePath.split('/').last;
    final form = FormData.fromMap({
      'kind': kind,
      'file': await MultipartFile.fromFile(
        filePath,
        filename: name,
        contentType: mediaTypeForPath(filePath) ?? MediaType('image', 'jpeg'),
      ),
    });
    final res = await _dio.post('/v1/uploads/verification', data: form);
    return (res.data as Map<String, dynamic>)['url'] as String;
  }
}

final conciergeIntrosProvider = FutureProvider.autoDispose<List<ConnectionItem>>((ref) {
  return ref.watch(connectionsApiProvider).listConciergeIntros();
});

final conversationsProvider = FutureProvider.autoDispose<List<ConnectionItem>>((ref) {
  return ref.watch(connectionsApiProvider).mutual();
});

final verificationProvider = FutureProvider.autoDispose<VerificationStatus?>((ref) {
  return ref.watch(verificationApiProvider).me();
});

final connectionHistoryProvider = FutureProvider.autoDispose<List<ConnectionItem>>((ref) {
  return ref.watch(connectionsApiProvider).history();
});

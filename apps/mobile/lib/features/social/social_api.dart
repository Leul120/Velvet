import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:velvet_mobile/core/config/api_config.dart';
import 'package:velvet_mobile/core/network/dio_client.dart';
import 'package:velvet_mobile/core/network/upload_mime.dart';

final chatApiProvider = Provider<ChatApi>(
  (ref) => ChatApi(ref.watch(dioProvider), ref.watch(secureStorageProvider)),
);
final bookingApiProvider = Provider<BookingApi>(
  (ref) => BookingApi(ref.watch(dioProvider)),
);
final venuesApiProvider = Provider<VenuesApi>(
  (ref) => VenuesApi(ref.watch(dioProvider)),
);

class ChatMessage {
  ChatMessage({
    required this.id,
    required this.senderId,
    required this.body,
    required this.moderationStatus,
    required this.createdAt,
    this.mediaType,
    this.mediaUrl,
    this.mediaName,
    this.mediaMime,
    this.readByPeer = false,
  });

  final String id;
  final String senderId;
  final String body;
  final String moderationStatus;
  final DateTime createdAt;
  final String? mediaType;
  final String? mediaUrl;
  final String? mediaName;
  final String? mediaMime;
  final bool readByPeer;

  bool get hasMedia => mediaUrl != null && mediaUrl!.isNotEmpty;

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      id: json['id'] as String,
      senderId: json['senderId'] as String,
      body: (json['body'] as String?) ?? '',
      moderationStatus: json['moderationStatus'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      mediaType: json['mediaType'] as String?,
      mediaUrl: json['mediaUrl'] as String?,
      mediaName: json['mediaName'] as String?,
      mediaMime: json['mediaMime'] as String?,
      readByPeer: json['readByPeer'] as bool? ?? false,
    );
  }
}

class SuggestedOpener {
  SuggestedOpener({
    required this.id,
    required this.textEn,
    required this.textAm,
  });
  final String id;
  final String textEn;
  final String textAm;
  factory SuggestedOpener.fromJson(Map<String, dynamic> json) =>
      SuggestedOpener(
        id: json['id'] as String,
        textEn: json['textEn'] as String,
        textAm: json['textAm'] as String,
      );
}

class ChatThreadDetail {
  ChatThreadDetail({
    required this.messages,
    required this.suggestedOpeners,
    this.canSend = true,
    this.windowReason,
    this.windowOpensAt,
    this.windowClosesAt,
    this.status,
    this.peerTyping = false,
  });
  final List<ChatMessage> messages;
  final List<SuggestedOpener> suggestedOpeners;
  final bool canSend;
  final String? windowReason;
  final DateTime? windowOpensAt;
  final DateTime? windowClosesAt;
  final String? status;
  final bool peerTyping;

  ChatThreadDetail copyWith({
    List<ChatMessage>? messages,
    List<SuggestedOpener>? suggestedOpeners,
    bool? canSend,
    String? windowReason,
    DateTime? windowOpensAt,
    DateTime? windowClosesAt,
    String? status,
    bool? peerTyping,
  }) {
    return ChatThreadDetail(
      messages: messages ?? this.messages,
      suggestedOpeners: suggestedOpeners ?? this.suggestedOpeners,
      canSend: canSend ?? this.canSend,
      windowReason: windowReason ?? this.windowReason,
      windowOpensAt: windowOpensAt ?? this.windowOpensAt,
      windowClosesAt: windowClosesAt ?? this.windowClosesAt,
      status: status ?? this.status,
      peerTyping: peerTyping ?? this.peerTyping,
    );
  }
}

class VenueItem {
  VenueItem({
    required this.id,
    required this.name,
    this.nameAm,
    required this.city,
    this.category,
    this.addressLine,
    this.latitude,
    this.longitude,
    this.geofenceMeters,
    this.area,
    this.priceBand,
    this.vibe,
    this.photoUrls = const [],
    this.verified = true,
  });
  final String id;
  final String name;
  final String? nameAm;
  final String city;
  final String? category;
  final String? addressLine;
  final double? latitude;
  final double? longitude;
  final int? geofenceMeters;
  final String? area;
  final String? priceBand;
  final String? vibe;
  final List<String> photoUrls;
  final bool verified;
  factory VenueItem.fromJson(Map<String, dynamic> json) => VenueItem(
    id: json['id'] as String,
    name: json['name'] as String,
    nameAm: json['nameAm'] as String?,
    city: json['city'] as String,
    category: json['category'] as String?,
    addressLine: json['addressLine'] as String?,
    latitude: (json['latitude'] as num?)?.toDouble(),
    longitude: (json['longitude'] as num?)?.toDouble(),
    geofenceMeters: json['geofenceMeters'] as int?,
    area: json['area'] as String?,
    priceBand: json['priceBand'] as String?,
    vibe: json['vibe'] as String?,
    photoUrls: (json['photoUrls'] as List<dynamic>? ?? [])
        .map((e) => e.toString())
        .toList(),
    verified: json['verified'] as bool? ?? true,
  );
}

class BookingItem {
  BookingItem({
    required this.id,
    required this.connectionId,
    required this.status,
    required this.startsAt,
    required this.proposedBy,
    this.venueId,
    this.venueName,
    this.venueNameAm,
    this.venueArea,
    this.venuePriceBand,
    this.venueVibe,
    this.venuePhotoUrls = const [],
    this.venueVerified,
    this.venueLatitude,
    this.venueLongitude,
    this.venueAddressLine,
    this.venueCity,
    this.meetupPlace,
    this.rateType,
    this.amountEtb,
    this.paymentStatus,
    this.confirmedAt,
    this.checkedInAt,
    this.checkedOutAt,
    this.myCheckoutConfirmed = false,
    this.counterpartCheckoutConfirmed = false,
    this.reminder24hSentAt,
    this.reminder2hSentAt,
    this.feedbackSubmitted = false,
  });

  final String id;
  final String connectionId;
  final String? venueId;
  final String? venueName;
  final String? venueNameAm;
  final String? venueArea;
  final String? venuePriceBand;
  final String? venueVibe;
  final List<String> venuePhotoUrls;
  final bool? venueVerified;
  final double? venueLatitude;
  final double? venueLongitude;
  final String? venueAddressLine;
  final String? venueCity;
  final String? meetupPlace;
  final String? rateType;
  final int? amountEtb;
  final String? paymentStatus;
  final String status;
  final DateTime startsAt;
  final String proposedBy;
  final DateTime? confirmedAt;
  final DateTime? checkedInAt;
  final DateTime? checkedOutAt;
  final bool myCheckoutConfirmed;
  final bool counterpartCheckoutConfirmed;
  final DateTime? reminder24hSentAt;
  final DateTime? reminder2hSentAt;
  final bool feedbackSubmitted;

  String get placeLabel =>
      (meetupPlace != null && meetupPlace!.trim().isNotEmpty)
      ? meetupPlace!.trim()
      : (venueName ?? 'Private meetup');

  bool get needsPayment =>
      amountEtb != null &&
      amountEtb! > 0 &&
      paymentStatus != 'PAID' &&
      paymentStatus != 'WAIVED';

  factory BookingItem.fromJson(Map<String, dynamic> json) => BookingItem(
    id: json['id'] as String,
    connectionId: (json['connectionId'] ?? json['matchId']).toString(),
    venueId: json['venueId'] as String?,
    venueName: json['venueName'] as String?,
    venueNameAm: json['venueNameAm'] as String?,
    venueArea: json['venueArea'] as String?,
    venuePriceBand: json['venuePriceBand'] as String?,
    venueVibe: json['venueVibe'] as String?,
    venuePhotoUrls: (json['venuePhotoUrls'] as List<dynamic>? ?? [])
        .map((e) => e.toString())
        .toList(),
    venueVerified: json['venueVerified'] as bool?,
    venueLatitude: (json['venueLatitude'] as num?)?.toDouble(),
    venueLongitude: (json['venueLongitude'] as num?)?.toDouble(),
    venueAddressLine: json['venueAddressLine'] as String?,
    venueCity: json['venueCity'] as String?,
    meetupPlace: json['meetupPlace'] as String?,
    rateType: json['rateType'] as String?,
    amountEtb: (json['amountEtb'] as num?)?.toInt(),
    paymentStatus: json['paymentStatus'] as String?,
    status: json['status'] as String,
    startsAt: DateTime.parse(json['startsAt'] as String),
    proposedBy: json['proposedBy'] as String,
    confirmedAt: json['confirmedAt'] != null
        ? DateTime.tryParse(json['confirmedAt'] as String)
        : null,
    checkedInAt: json['checkedInAt'] != null
        ? DateTime.tryParse(json['checkedInAt'] as String)
        : null,
    checkedOutAt: json['checkedOutAt'] != null
        ? DateTime.tryParse(json['checkedOutAt'] as String)
        : null,
    myCheckoutConfirmed: json['myCheckoutConfirmed'] as bool? ?? false,
    counterpartCheckoutConfirmed:
        json['counterpartCheckoutConfirmed'] as bool? ?? false,
    reminder24hSentAt: json['reminder24hSentAt'] != null
        ? DateTime.tryParse(json['reminder24hSentAt'] as String)
        : null,
    reminder2hSentAt: json['reminder2hSentAt'] != null
        ? DateTime.tryParse(json['reminder2hSentAt'] as String)
        : null,
    feedbackSubmitted: json['feedbackSubmitted'] as bool? ?? false,
  );
}

class ChatApi {
  ChatApi(this._dio, this._storage);
  final Dio _dio;
  final FlutterSecureStorage _storage;

  Future<ChatThreadDetail> getThread(String connectionId) async {
    final res = await _dio.get('/v1/chat/connections/$connectionId');
    final data = res.data as Map<String, dynamic>;
    final thread = data['thread'] as Map<String, dynamic>? ?? {};
    final messages = (data['messages'] as List<dynamic>)
        .map((e) => ChatMessage.fromJson(e as Map<String, dynamic>))
        .toList();
    final openers =
        (data['conversationStarters'] as List<dynamic>? ??
                data['icebreakers'] as List<dynamic>? ??
                [])
            .map((e) => SuggestedOpener.fromJson(e as Map<String, dynamic>))
            .toList();
    return ChatThreadDetail(
      messages: messages,
      suggestedOpeners: openers,
      canSend: thread['canSend'] as bool? ?? true,
      windowReason: thread['windowReason'] as String?,
      windowOpensAt: thread['windowOpensAt'] == null
          ? null
          : DateTime.tryParse(thread['windowOpensAt'] as String),
      windowClosesAt: thread['windowClosesAt'] == null
          ? null
          : DateTime.tryParse(thread['windowClosesAt'] as String),
      status: thread['status'] as String?,
      peerTyping: data['peerTyping'] as bool? ?? false,
    );
  }

  Future<List<ChatMessage>> messagesAfter(
    String connectionId, {
    DateTime? after,
  }) async {
    final res = await _dio.get(
      '/v1/chat/connections/$connectionId/messages',
      queryParameters: {
        if (after != null) 'after': after.toUtc().toIso8601String(),
      },
    );
    return (res.data as List<dynamic>)
        .map((e) => ChatMessage.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<ChatMessage> send(
    String connectionId, {
    String body = '',
    String? mediaType,
    String? mediaUrl,
    String? mediaName,
    String? mediaMime,
  }) async {
    final res = await _dio.post(
      '/v1/chat/connections/$connectionId/messages',
      data: {
        'body': body,
        'mediaType': ?mediaType,
        'mediaUrl': ?mediaUrl,
        'mediaName': ?mediaName,
        'mediaMime': ?mediaMime,
      },
    );
    return ChatMessage.fromJson(Map<String, dynamic>.from(res.data as Map));
  }

  Future<void> markRead(String connectionId) async {
    await _dio.post('/v1/chat/connections/$connectionId/read');
  }

  Future<void> setTyping(String connectionId, {required bool typing}) async {
    await _dio.post(
      '/v1/chat/connections/$connectionId/typing',
      data: {'typing': typing},
    );
  }

  Stream<Map<String, dynamic>> eventStream(
    String connectionId, {
    DateTime? after,
  }) async* {
    final token = await _storage.read(key: 'access_token');
    final uri = Uri.parse(
      '${ApiConfig.baseUrl}/v1/chat/connections/$connectionId/stream'
      '${after == null ? '' : '?after=${Uri.encodeComponent(after.toUtc().toIso8601String())}'}',
    );
    final client = HttpClient();
    try {
      final req = await client.getUrl(uri);
      req.headers.set(HttpHeaders.acceptHeader, 'text/event-stream');
      if (token != null && token.isNotEmpty) {
        req.headers.set(HttpHeaders.authorizationHeader, 'Bearer $token');
      }
      final res = await req.close().timeout(const Duration(seconds: 25));
      if (res.statusCode != 200) {
        throw DioException(
          requestOptions: RequestOptions(path: uri.path),
          message: 'SSE failed (${res.statusCode})',
        );
      }
      String? eventName;
      final dataBuf = StringBuffer();
      await for (final chunk in res.transform(utf8.decoder)) {
        for (final line in chunk.split('\n')) {
          final trimmed = line.replaceAll('\r', '');
          if (trimmed.startsWith('event:')) {
            eventName = trimmed.substring(6).trim();
          } else if (trimmed.startsWith('data:')) {
            if (dataBuf.isNotEmpty) dataBuf.write('\n');
            dataBuf.write(trimmed.substring(5).trimLeft());
          } else if (trimmed.isEmpty) {
            if (dataBuf.isNotEmpty) {
              final raw = dataBuf.toString();
              dataBuf.clear();
              final name = eventName ?? 'message';
              eventName = null;
              try {
                final decoded = jsonDecode(raw);
                if (decoded is Map<String, dynamic>) {
                  yield {'event': name, 'data': decoded};
                } else if (decoded is Map) {
                  yield {
                    'event': name,
                    'data': Map<String, dynamic>.from(decoded),
                  };
                }
              } catch (_) {}
            }
          }
        }
      }
    } finally {
      client.close(force: true);
    }
  }

  Future<Map<String, String>> uploadChatMedia(
    String filePath, {
    String? filename,
  }) async {
    final name = filename ?? filePath.split('/').last;
    final form = FormData.fromMap({
      'file': await MultipartFile.fromFile(
        filePath,
        filename: name,
        contentType: mediaTypeForPath(name) ?? mediaTypeForPath(filePath),
      ),
    });
    final res = await _dio.post('/v1/uploads/chat', data: form);
    final data = Map<String, dynamic>.from(res.data as Map);
    return {
      'url': data['url']?.toString() ?? '',
      'mediaType': data['mediaType']?.toString() ?? 'FILE',
      'mediaName': data['fileName']?.toString() ?? name,
      'mediaMime': data['mime']?.toString() ?? '',
    };
  }
}

class BookingApi {
  BookingApi(this._dio);
  final Dio _dio;

  Future<BookingItem> propose({
    required String connectionId,
    required DateTime startsAt,
    String? venueId,
    String? meetupPlace,
    String? rateType,
  }) async {
    final res = await _dio.post(
      '/v1/bookings',
      data: {
        'matchId': connectionId,
        'startsAt': startsAt.toUtc().toIso8601String(),
        'venueId': ?venueId,
        'meetupPlace': ?meetupPlace,
        'rateType': ?rateType,
      },
    );
    return BookingItem.fromJson(res.data as Map<String, dynamic>);
  }

  Future<BookingItem> confirm(String bookingId) async {
    final res = await _dio.post('/v1/bookings/$bookingId/confirm');
    return BookingItem.fromJson(res.data as Map<String, dynamic>);
  }

  Future<BookingItem> cancel(String bookingId, {String? reason}) async {
    final res = await _dio.post(
      '/v1/bookings/$bookingId/cancel',
      data: {'reason': ?reason},
    );
    return BookingItem.fromJson(res.data as Map<String, dynamic>);
  }

  Future<BookingItem> reschedule({
    required String bookingId,
    required DateTime startsAt,
    String? venueId,
    String? notes,
  }) async {
    final res = await _dio.post(
      '/v1/bookings/$bookingId/reschedule',
      data: {
        'startsAt': startsAt.toUtc().toIso8601String(),
        'venueId': ?venueId,
        'notes': ?notes,
      },
    );
    return BookingItem.fromJson(res.data as Map<String, dynamic>);
  }

  Future<BookingItem> checkIn(
    String bookingId, {
    double? latitude,
    double? longitude,
  }) async {
    final res = await _dio.post(
      '/v1/bookings/$bookingId/check-in',
      data: {'latitude': ?latitude, 'longitude': ?longitude},
    );
    return BookingItem.fromJson(res.data as Map<String, dynamic>);
  }

  Future<BookingItem> checkOut(String bookingId) async {
    final res = await _dio.post('/v1/bookings/$bookingId/check-out');
    return BookingItem.fromJson(res.data as Map<String, dynamic>);
  }

  Future<void> submitFeedback({
    required String bookingId,
    required bool feltSafe,
    required bool wouldMeetAgain,
    required bool venueOk,
    String? notes,
  }) async {
    await _dio.post(
      '/v1/bookings/$bookingId/feedback',
      data: {
        'feltSafe': feltSafe,
        'wouldMeetAgain': wouldMeetAgain,
        'venueOk': venueOk,
        'notes': ?notes,
      },
    );
  }

  Future<BookingItem?> byConnection(String connectionId) async {
    try {
      final res = await _dio.get('/v1/bookings/by-connection/$connectionId');
      return BookingItem.fromJson(res.data as Map<String, dynamic>);
    } on DioException catch (e) {
      if (e.response?.statusCode == 400) return null;
      rethrow;
    }
  }

  Future<BookingItem> get(String bookingId) async {
    final res = await _dio.get('/v1/bookings/$bookingId');
    return BookingItem.fromJson(res.data as Map<String, dynamic>);
  }
}

class VenuesApi {
  VenuesApi(this._dio);
  final Dio _dio;

  Future<List<VenueItem>> list() async {
    final res = await _dio.get('/v1/venues');
    return (res.data as List<dynamic>)
        .map((e) => VenueItem.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}

final safetyApiProvider = Provider<SafetyApi>(
  (ref) => SafetyApi(ref.watch(dioProvider)),
);

class SafetyApi {
  SafetyApi(this._dio);
  final Dio _dio;

  Future<void> panic({
    String? bookingId,
    String? connectionId,
    String? note,
    double? latitude,
    double? longitude,
  }) async {
    await _dio.post(
      '/v1/safety/panic',
      data: {
        'bookingId': ?bookingId,
        'matchId': ?connectionId,
        'note': ?note,
        'latitude': ?latitude,
        'longitude': ?longitude,
      },
    );
  }

  Future<void> report({
    required String category,
    required String details,
    String? reportedUserId,
    String? connectionId,
    String? bookingId,
  }) async {
    await _dio.post(
      '/v1/safety/reports',
      data: {
        'category': category,
        'details': details,
        'reportedUserId': ?reportedUserId,
        'matchId': ?connectionId,
        'bookingId': ?bookingId,
      },
    );
  }

  Future<void> block({required String blockedUserId, String? reason}) async {
    await _dio.post(
      '/v1/safety/blocks',
      data: {'blockedUserId': blockedUserId, 'reason': ?reason},
    );
  }

  Future<List<BlockedMember>> listBlocks() async {
    final res = await _dio.get('/v1/safety/blocks');
    return (res.data as List<dynamic>)
        .map((e) => BlockedMember.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<void> unblock(String blockedUserId) async {
    await _dio.delete('/v1/safety/blocks/$blockedUserId');
  }

  Future<void> shareTrip({
    String? bookingId,
    String? connectionId,
    double? latitude,
    double? longitude,
    int? etaMinutes,
    String? note,
  }) async {
    await _dio.post(
      '/v1/safety/trip-share',
      data: {
        'bookingId': ?bookingId,
        'matchId': ?connectionId,
        'latitude': ?latitude,
        'longitude': ?longitude,
        'etaMinutes': ?etaMinutes,
        'note': ?note,
      },
    );
  }
}

class BlockedMember {
  BlockedMember({
    required this.id,
    required this.blockedUserId,
    this.reason,
    required this.createdAt,
  });

  final String id;
  final String blockedUserId;
  final String? reason;
  final DateTime createdAt;

  factory BlockedMember.fromJson(Map<String, dynamic> json) => BlockedMember(
    id: json['id'] as String,
    blockedUserId: json['blockedUserId'] as String,
    reason: json['reason'] as String?,
    createdAt: DateTime.parse(json['createdAt'] as String),
  );
}

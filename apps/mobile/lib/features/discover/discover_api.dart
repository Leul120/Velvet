import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:velvet_mobile/core/network/dio_client.dart';

final discoverApiProvider = Provider<DiscoverApi>(
  (ref) => DiscoverApi(ref.watch(dioProvider)),
);

class DiscoverCard {
  DiscoverCard({
    required this.userId,
    required this.displayName,
    this.age,
    this.city,
    this.bioEn,
    this.bioAm,
    this.heightCm,
    this.jobTitle,
    this.education,
    this.languages,
    this.religion,
    this.lookingFor,
    this.sessionRateEtb,
    this.overnightRateEtb,
    this.availabilityNote,
    this.photoUrls = const [],
    this.distanceKm,
    this.interests = const [],
    this.verified = false,
    this.likedPhotoIndex,
    this.likedPromptKey,
    this.likedPhotoUrl,
    this.likeReason,
    this.trustScore,
  });

  final String userId;
  final String? displayName;
  final int? age;
  final String? city;
  final String? bioEn;
  final String? bioAm;
  final int? heightCm;
  final String? jobTitle;
  final String? education;
  final String? languages;
  final String? religion;
  final String? lookingFor;
  final int? sessionRateEtb;
  final int? overnightRateEtb;
  final String? availabilityNote;
  final List<String> photoUrls;
  final double? distanceKm;
  final List<String> interests;
  final bool verified;
  final int? likedPhotoIndex;
  final String? likedPromptKey;
  final String? likedPhotoUrl;
  final String? likeReason;
  final int? trustScore;

  factory DiscoverCard.fromJson(Map<String, dynamic> json) {
    final photos = json['photoUrls'];
    final interests = json['interests'];
    return DiscoverCard(
      userId: json['userId'] as String,
      displayName: json['displayName'] as String?,
      age: json['age'] as int?,
      city: json['city'] as String?,
      bioEn: json['bioEn'] as String?,
      bioAm: json['bioAm'] as String?,
      heightCm: json['heightCm'] as int?,
      jobTitle: json['jobTitle'] as String?,
      education: json['education'] as String?,
      languages: json['languages'] as String?,
      religion: json['religion'] as String?,
      lookingFor: json['lookingFor'] as String?,
      sessionRateEtb: (json['sessionRateEtb'] as num?)?.toInt(),
      overnightRateEtb: (json['overnightRateEtb'] as num?)?.toInt(),
      availabilityNote: json['availabilityNote'] as String?,
      photoUrls: photos is List
          ? photos.map((e) => e.toString()).toList()
          : const [],
      distanceKm: (json['distanceKm'] as num?)?.toDouble(),
      interests: interests is List
          ? interests.map((e) => e.toString()).toList()
          : const [],
      verified: json['verified'] as bool? ?? false,
      likedPhotoIndex: (json['likedPhotoIndex'] as num?)?.toInt(),
      likedPromptKey: json['likedPromptKey'] as String?,
      likedPhotoUrl: json['likedPhotoUrl'] as String?,
      likeReason: json['likeReason'] as String?,
      trustScore: json['trustScore'] as int?,
    );
  }
}

class DiscoverActionResult {
  DiscoverActionResult({
    required this.mutual,
    this.connectionId,
    this.counterpartDisplayName,
    this.counterpartPhotoUrls = const [],
  });

  final bool mutual;
  final String? connectionId;
  final String? counterpartDisplayName;
  final List<String> counterpartPhotoUrls;

  factory DiscoverActionResult.fromJson(Map<String, dynamic> json) {
    final photos = json['counterpartPhotoUrls'];
    final id = json['connectionId'] ?? json['matchId'];
    return DiscoverActionResult(
      mutual: json['mutual'] as bool? ?? false,
      connectionId: id as String?,
      counterpartDisplayName: json['counterpartDisplayName'] as String?,
      counterpartPhotoUrls: photos is List
          ? photos.map((e) => e.toString()).toList()
          : const [],
    );
  }
}

class UndoResult {
  UndoResult({
    required this.restoredUserId,
    required this.undoneAction,
    required this.remainingUndos,
  });

  final String restoredUserId;
  final String undoneAction;
  final int remainingUndos;

  factory UndoResult.fromJson(Map<String, dynamic> json) {
    return UndoResult(
      restoredUserId: json['restoredUserId'] as String,
      undoneAction: json['undoneAction'] as String? ?? '',
      remainingUndos: (json['remainingUndos'] as num?)?.toInt() ?? 0,
    );
  }
}

class DiscoverPreferences {
  DiscoverPreferences({
    required this.minAge,
    required this.maxAge,
    required this.maxDistanceKm,
    this.cities = const [],
    this.preferredLanguages = const [],
    this.intents = const [],
    this.verifiedOnly = false,
  });

  final int minAge;
  final int maxAge;
  final int maxDistanceKm;
  final List<String> cities;
  final List<String> preferredLanguages;
  final List<String> intents;
  final bool verifiedOnly;

  factory DiscoverPreferences.fromJson(Map<String, dynamic> json) {
    final cities = json['cities'];
    final langs = json['preferredLanguages'];
    final intents = json['intents'];
    return DiscoverPreferences(
      minAge: json['minAge'] as int? ?? 21,
      maxAge: json['maxAge'] as int? ?? 55,
      maxDistanceKm: json['maxDistanceKm'] as int? ?? 50,
      cities: cities is List ? cities.map((e) => e.toString()).toList() : const [],
      preferredLanguages:
          langs is List ? langs.map((e) => e.toString()).toList() : const [],
      intents: intents is List ? intents.map((e) => e.toString()).toList() : const [],
      verifiedOnly: json['verifiedOnly'] as bool? ?? false,
    );
  }
}

class DiscoverFeed {
  DiscoverFeed({required this.items, this.mode});

  final List<DiscoverCard> items;
  final String? mode;

  factory DiscoverFeed.fromJson(Map<String, dynamic> json) {
    final items = (json['items'] as List<dynamic>? ?? [])
        .map((e) => DiscoverCard.fromJson(e as Map<String, dynamic>))
        .toList();
    return DiscoverFeed(items: items, mode: json['mode'] as String?);
  }
}

class DiscoverApi {
  DiscoverApi(this._dio);
  final Dio _dio;

  Future<DiscoverFeed> feed({int limit = 20}) async {
    final res = await _dio.get(
      '/v1/discover',
      queryParameters: {'limit': limit},
    );
    return DiscoverFeed.fromJson(res.data as Map<String, dynamic>);
  }

  Future<DiscoverFeed> received({int limit = 20}) async {
    final res = await _dio.get(
      '/v1/discover/received',
      queryParameters: {'limit': limit},
    );
    return DiscoverFeed.fromJson(res.data as Map<String, dynamic>);
  }

  Future<DiscoverFeed> recentPasses({int limit = 5}) async {
    final res = await _dio.get(
      '/v1/discover/passes',
      queryParameters: {'limit': limit},
    );
    return DiscoverFeed.fromJson(res.data as Map<String, dynamic>);
  }

  Future<UndoResult> rewindPass(String userId) async {
    final res = await _dio.post('/v1/discover/passes/$userId/rewind');
    return UndoResult.fromJson(res.data as Map<String, dynamic>);
  }

  Future<DiscoverActionResult> action({
    required String userId,
    required String action,
    int? likedPhotoIndex,
    String? likedPromptKey,
  }) async {
    final res = await _dio.post(
      '/v1/discover/$userId/action',
      data: {
        'action': action,
        'likedPhotoIndex': ?likedPhotoIndex,
        'likedPromptKey': ?likedPromptKey,
      },
    );
    return DiscoverActionResult.fromJson(res.data as Map<String, dynamic>);
  }

  Future<UndoResult> undo() async {
    final res = await _dio.post('/v1/discover/undo');
    return UndoResult.fromJson(res.data as Map<String, dynamic>);
  }

  Future<DiscoverPreferences> preferences() async {
    final res = await _dio.get('/v1/me/preferences');
    return DiscoverPreferences.fromJson(res.data as Map<String, dynamic>);
  }

  Future<DiscoverPreferences> updatePreferences({
    int? minAge,
    int? maxAge,
    int? maxDistanceKm,
    List<String>? cities,
    List<String>? preferredLanguages,
    List<String>? intents,
    bool? verifiedOnly,
  }) async {
    final res = await _dio.patch(
      '/v1/me/preferences',
      data: {
        'minAge': ?minAge,
        'maxAge': ?maxAge,
        'maxDistanceKm': ?maxDistanceKm,
        'cities': ?cities,
        'preferredLanguages': ?preferredLanguages,
        'intents': ?intents,
        'verifiedOnly': ?verifiedOnly,
      },
    );
    return DiscoverPreferences.fromJson(res.data as Map<String, dynamic>);
  }

  Future<void> updateLocation({
    required double latitude,
    required double longitude,
  }) async {
    await _dio.post(
      '/v1/me/location',
      data: {'latitude': latitude, 'longitude': longitude},
    );
  }
}

final discoverFeedProvider = FutureProvider.autoDispose<DiscoverFeed>((ref) {
  return ref.watch(discoverApiProvider).feed();
});

final receivedRequestsProvider = FutureProvider.autoDispose<DiscoverFeed>((ref) {
  return ref.watch(discoverApiProvider).received();
});

final recentPassesProvider = FutureProvider.autoDispose<DiscoverFeed>((ref) {
  return ref.watch(discoverApiProvider).recentPasses();
});

final discoverPrefsProvider = FutureProvider.autoDispose<DiscoverPreferences>((
  ref,
) {
  return ref.watch(discoverApiProvider).preferences();
});

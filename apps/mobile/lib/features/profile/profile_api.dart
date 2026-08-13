import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http_parser/http_parser.dart';
import 'package:velvet_mobile/core/network/dio_client.dart';
import 'package:velvet_mobile/core/network/upload_mime.dart';

final profileApiProvider = Provider<ProfileApi>(
  (ref) => ProfileApi(ref.watch(dioProvider)),
);

class MeProfile {
  MeProfile({
    required this.id,
    required this.phone,
    required this.status,
    required this.role,
    required this.preferredLocale,
    required this.legalAccepted,
    this.displayName,
    this.dateOfBirth,
    this.gender,
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
    this.listingActive = true,
    this.photoUrls = const [],
    this.interests = const [],
    this.trustScore,
  });

  final String id;
  final String phone;
  final String? displayName;
  final String status;
  final String role;
  final String preferredLocale;
  final bool legalAccepted;
  final String? dateOfBirth;
  final String? gender;
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
  final bool listingActive;
  final List<String> photoUrls;
  final List<String> interests;
  final int? trustScore;

  factory MeProfile.fromJson(Map<String, dynamic> json) {
    final profile = json['profile'] as Map<String, dynamic>? ?? {};
    final interests = profile['interests'];
    return MeProfile(
      id: json['id'] as String,
      phone: json['phone'] as String,
      displayName: json['displayName'] as String?,
      status: json['status'] as String,
      role: json['role'] as String,
      preferredLocale: json['preferredLocale'] as String? ?? 'am',
      legalAccepted: json['legalAccepted'] as bool? ?? false,
      dateOfBirth: json['dateOfBirth'] as String?,
      gender: json['gender'] as String?,
      city: profile['city'] as String?,
      bioEn: profile['bioEn'] as String?,
      bioAm: profile['bioAm'] as String?,
      heightCm: profile['heightCm'] as int?,
      jobTitle: profile['jobTitle'] as String?,
      education: profile['education'] as String?,
      languages: profile['languages'] as String?,
      religion: profile['religion'] as String?,
      lookingFor: profile['lookingFor'] as String?,
      sessionRateEtb: (profile['sessionRateEtb'] as num?)?.toInt(),
      overnightRateEtb: (profile['overnightRateEtb'] as num?)?.toInt(),
      availabilityNote: profile['availabilityNote'] as String?,
      listingActive: profile['listingActive'] as bool? ?? true,
      photoUrls: (profile['photoUrls'] as List<dynamic>? ?? []).cast<String>(),
      interests: interests is List
          ? interests.map((e) => e.toString()).toList()
          : const [],
      trustScore: json['trustScore'] as int?,
    );
  }
}

class ProfileApi {
  ProfileApi(this._dio);
  final Dio _dio;

  Future<MeProfile> me() async {
    final res = await _dio.get('/v1/me');
    return MeProfile.fromJson(res.data as Map<String, dynamic>);
  }

  Future<MeProfile> update({
    String? displayName,
    String? city,
    String? dateOfBirth,
    String? gender,
    String? bioEn,
    String? bioAm,
    int? heightCm,
    String? jobTitle,
    String? education,
    String? languages,
    String? religion,
    String? lookingFor,
    int? sessionRateEtb,
    int? overnightRateEtb,
    String? availabilityNote,
    bool? listingActive,
    List<String>? interests,
  }) async {
    final res = await _dio.patch(
      '/v1/me',
      data: {
        'displayName': ?displayName,
        'city': ?city,
        'dateOfBirth': ?dateOfBirth,
        'gender': ?gender,
        'bioEn': ?bioEn,
        'bioAm': ?bioAm,
        'heightCm': ?heightCm,
        'education': ?education,
        'jobTitle': ?jobTitle,
        'languages': ?languages,
        'religion': ?religion,
        'lookingFor': ?lookingFor,
        'sessionRateEtb': ?sessionRateEtb,
        'overnightRateEtb': ?overnightRateEtb,
        'availabilityNote': ?availabilityNote,
        'listingActive': ?listingActive,
        'interests': ?interests,
      },
    );
    return MeProfile.fromJson(res.data as Map<String, dynamic>);
  }

  Future<ProfilePhotoUpload> uploadPhoto(String filePath) async {
    final name = filePath.split('/').last;
    final form = FormData.fromMap({
      'file': await MultipartFile.fromFile(
        filePath,
        filename: name,
        contentType: mediaTypeForPath(filePath) ?? MediaType('image', 'jpeg'),
      ),
    });
    final res = await _dio.post('/v1/uploads/profile', data: form);
    final data = res.data as Map<String, dynamic>;
    return ProfilePhotoUpload(
      url: data['url'] as String,
      qualityStatus: data['qualityStatus'] as String? ?? 'NEEDS_REVIEW',
      qualityReason: data['qualityReason'] as String?,
    );
  }

  Future<MeProfile> addPhoto(String url) async {
    final res = await _dio.post('/v1/me/photos', data: {'url': url});
    return MeProfile.fromJson(res.data as Map<String, dynamic>);
  }

  Future<MeProfile> removePhoto(String url) async {
    final res = await _dio.delete('/v1/me/photos', data: {'url': url});
    return MeProfile.fromJson(res.data as Map<String, dynamic>);
  }

  Future<MeProfile> reorderPhotos(List<String> photoUrls) async {
    final res = await _dio.put(
      '/v1/me/photos/order',
      data: {'photoUrls': photoUrls},
    );
    return MeProfile.fromJson(res.data as Map<String, dynamic>);
  }

  Future<Map<String, dynamic>> exportData() async {
    final res = await _dio.get('/v1/me/data-export');
    return res.data as Map<String, dynamic>;
  }
}

class ProfilePhotoUpload {
  ProfilePhotoUpload({
    required this.url,
    required this.qualityStatus,
    this.qualityReason,
  });

  final String url;
  final String qualityStatus;
  final String? qualityReason;
}

final meProfileProvider = FutureProvider.autoDispose<MeProfile>((ref) {
  return ref.watch(profileApiProvider).me();
});

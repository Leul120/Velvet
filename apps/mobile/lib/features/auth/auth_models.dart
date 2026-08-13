class UserSummary {
  UserSummary({
    required this.id,
    required this.phone,
    required this.status,
    required this.role,
    required this.preferredLocale,
    required this.profileReady,
    required this.legalAccepted,
    required this.legalVersionRequired,
    this.displayName,
    this.gender,
  });

  final String id;
  final String phone;
  final String? displayName;
  final String status;
  final String role;
  final String preferredLocale;
  final String? gender;
  final bool profileReady;
  final bool legalAccepted;
  final String legalVersionRequired;

  factory UserSummary.fromJson(Map<String, dynamic> json) {
    return UserSummary(
      id: json['id'] as String,
      phone: json['phone'] as String,
      displayName: json['displayName'] as String?,
      status: json['status'] as String,
      role: json['role'] as String,
      preferredLocale: json['preferredLocale'] as String? ?? 'am',
      gender: json['gender'] as String?,
      profileReady: json['profileReady'] as bool? ?? false,
      legalAccepted: json['legalAccepted'] as bool? ?? false,
      legalVersionRequired: json['legalVersionRequired'] as String? ?? 'v1-2026-08',
    );
  }

  UserSummary copyWith({
    bool? legalAccepted,
    String? legalVersionRequired,
    String? gender,
    bool clearGender = false,
    String? displayName,
    String? role,
    bool? profileReady,
  }) {
    return UserSummary(
      id: id,
      phone: phone,
      displayName: displayName ?? this.displayName,
      status: status,
      role: role ?? this.role,
      preferredLocale: preferredLocale,
      gender: clearGender ? null : gender ?? this.gender,
      profileReady: profileReady ?? this.profileReady,
      legalAccepted: legalAccepted ?? this.legalAccepted,
      legalVersionRequired: legalVersionRequired ?? this.legalVersionRequired,
    );
  }
}

class OtpRequestResult {
  OtpRequestResult({required this.message, required this.expiresInSeconds, this.devOtp});

  final String message;
  final int expiresInSeconds;
  final String? devOtp;

  factory OtpRequestResult.fromJson(Map<String, dynamic> json) {
    return OtpRequestResult(
      message: json['message'] as String,
      expiresInSeconds: (json['expiresInSeconds'] as num).toInt(),
      devOtp: json['devOtp'] as String?,
    );
  }
}

class TokenResponse {
  TokenResponse({
    required this.accessToken,
    required this.refreshToken,
    required this.expiresInSeconds,
    required this.user,
  });

  final String accessToken;
  final String refreshToken;
  final int expiresInSeconds;
  final UserSummary user;

  factory TokenResponse.fromJson(Map<String, dynamic> json) {
    return TokenResponse(
      accessToken: json['accessToken'] as String,
      refreshToken: json['refreshToken'] as String,
      expiresInSeconds: (json['expiresInSeconds'] as num).toInt(),
      user: UserSummary.fromJson(json['user'] as Map<String, dynamic>),
    );
  }
}

class LegalCurrent {
  LegalCurrent({
    required this.documentSetVersion,
    required this.accepted,
    required this.termsPath,
    required this.privacyPath,
    required this.communityPath,
  });

  final String documentSetVersion;
  final bool accepted;
  final String termsPath;
  final String privacyPath;
  final String communityPath;

  factory LegalCurrent.fromJson(Map<String, dynamic> json) {
    return LegalCurrent(
      documentSetVersion: json['documentSetVersion'] as String,
      accepted: json['accepted'] as bool? ?? false,
      termsPath: json['termsPath'] as String? ?? '/legal/terms-en.html',
      privacyPath: json['privacyPath'] as String? ?? '/legal/privacy-en.html',
      communityPath: json['communityPath'] as String? ?? '/legal/community-en.html',
    );
  }
}

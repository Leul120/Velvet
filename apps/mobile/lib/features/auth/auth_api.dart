import 'package:dio/dio.dart';
import 'package:velvet_mobile/features/auth/auth_models.dart';
import 'package:uuid/uuid.dart';

class AuthApi {
  AuthApi(this._dio);

  final Dio _dio;
  final _uuid = const Uuid();

  Future<OtpRequestResult> requestOtp({
    required String phone,
    required String inviteCode,
  }) async {
    final response = await _dio.post(
      '/v1/auth/otp/request',
      data: {
        'phone': phone,
        'inviteCode': inviteCode,
        'deviceId': _uuid.v4(),
        'platform': 'android',
      },
    );
    return OtpRequestResult.fromJson(response.data as Map<String, dynamic>);
  }

  Future<TokenResponse> verifyOtp({
    required String phone,
    required String code,
    String? acceptedLegalVersion,
  }) async {
    final response = await _dio.post(
      '/v1/auth/otp/verify',
      data: {
        'phone': phone,
        'code': code,
        'deviceId': _uuid.v4(),
        'platform': 'android',
        'acceptedLegalVersion': ?acceptedLegalVersion,
      },
    );
    return TokenResponse.fromJson(response.data as Map<String, dynamic>);
  }

  Future<LegalCurrent> legalCurrent() async {
    final response = await _dio.get('/v1/legal/current');
    return LegalCurrent.fromJson(response.data as Map<String, dynamic>);
  }

  Future<UserSummary> acceptLegal(String documentSetVersion) async {
    final response = await _dio.post(
      '/v1/legal/accept',
      data: {'documentSetVersion': documentSetVersion},
    );
    return UserSummary.fromJson(response.data as Map<String, dynamic>);
  }

  Future<LegalCurrent> legalStatus() async {
    final response = await _dio.get('/v1/legal/status');
    return LegalCurrent.fromJson(response.data as Map<String, dynamic>);
  }

  Future<TokenResponse> refresh(String refreshToken) async {
    final response = await _dio.post(
      '/v1/auth/refresh',
      data: {'refreshToken': refreshToken},
    );
    return TokenResponse.fromJson(response.data as Map<String, dynamic>);
  }

  Future<void> registerPushToken({required String token, String platform = 'android'}) async {
    await _dio.post('/v1/devices/push-token', data: {
      'token': token,
      'platform': platform,
    });
  }

  Future<void> withdraw() async {
    await _dio.post('/v1/me/withdraw');
  }

  Future<void> erasure() async {
    await _dio.post('/v1/me/erasure');
  }
}

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http_parser/http_parser.dart';
import 'package:velvet_mobile/core/network/dio_client.dart';
import 'package:velvet_mobile/core/network/upload_mime.dart';

final billingApiProvider = Provider<BillingApi>(
  (ref) => BillingApi(ref.watch(dioProvider)),
);

class PlanItem {
  PlanItem({
    required this.id,
    required this.code,
    required this.nameEn,
    required this.priceEtb,
    required this.bookingRequestQuota,
    required this.durationDays,
    this.nameAm,
  });

  final String id;
  final String code;
  final String nameEn;
  final String? nameAm;
  final double priceEtb;
  final int bookingRequestQuota;
  final int durationDays;

  factory PlanItem.fromJson(Map<String, dynamic> json) => PlanItem(
    id: json['id']?.toString() ?? '',
    code: json['code']?.toString() ?? '',
    nameEn: json['nameEn']?.toString() ?? '',
    nameAm: json['nameAm'] as String?,
    priceEtb: (json['priceEtb'] as num?)?.toDouble() ?? 0,
    bookingRequestQuota: (json['matchQuota'] as num?)?.toInt() ?? 0,
    durationDays: (json['durationDays'] as num?)?.toInt() ?? 0,
  );
}

class CbeInstructions {
  CbeInstructions({
    required this.accountName,
    required this.accountNumber,
    required this.accountSuffix,
    required this.bankName,
    required this.transferNote,
  });

  final String accountName;
  final String accountNumber;
  final String accountSuffix;
  final String bankName;
  final String transferNote;

  factory CbeInstructions.fromJson(Map<String, dynamic> json) =>
      CbeInstructions(
        accountName: json['accountName'] as String? ?? '',
        accountNumber: json['accountNumber'] as String? ?? '',
        accountSuffix: json['accountSuffix'] as String? ?? '',
        bankName: json['bankName'] as String? ?? 'Commercial Bank of Ethiopia',
        transferNote: json['transferNote'] as String? ?? '',
      );
}

class CheckoutResult {
  CheckoutResult({
    required this.paymentIntentId,
    required this.merchantOrderId,
    required this.amountEtb,
    required this.mock,
    required this.provider,
    this.checkoutUrl,
    this.cbe,
  });

  final String paymentIntentId;
  final String merchantOrderId;
  final String? checkoutUrl;
  final double amountEtb;
  final bool mock;
  final String provider;
  final CbeInstructions? cbe;

  bool get isCbe => provider.toUpperCase() == 'CBE';

  factory CheckoutResult.fromJson(Map<String, dynamic> json) {
    final cbeRaw = json['cbe'];
    return CheckoutResult(
      paymentIntentId: json['paymentIntentId']?.toString() ?? '',
      merchantOrderId: json['merchantOrderId']?.toString() ?? '',
      checkoutUrl: json['checkoutUrl'] as String?,
      amountEtb: (json['amountEtb'] as num?)?.toDouble() ?? 0,
      mock: json['mock'] as bool? ?? false,
      provider: json['provider']?.toString() ?? 'CBE',
      cbe: cbeRaw is Map
          ? CbeInstructions.fromJson(Map<String, dynamic>.from(cbeRaw))
          : null,
    );
  }
}

class SubscriptionItem {
  SubscriptionItem({
    required this.id,
    required this.planCode,
    required this.planNameEn,
    required this.status,
    required this.endsAt,
    required this.bookingRequestQuota,
    required this.bookingRequestsUsed,
  });

  final String id;
  final String planCode;
  final String planNameEn;
  final String status;
  final DateTime endsAt;
  final int bookingRequestQuota;
  final int bookingRequestsUsed;

  factory SubscriptionItem.fromJson(Map<String, dynamic> json) {
    final endsRaw = json['endsAt']?.toString();
    return SubscriptionItem(
      id: json['id']?.toString() ?? '',
      planCode: json['planCode']?.toString() ?? '',
      planNameEn: json['planNameEn']?.toString() ?? '',
      status: json['status']?.toString() ?? '',
      endsAt: endsRaw != null && endsRaw.isNotEmpty
          ? DateTime.parse(endsRaw)
          : DateTime.now().toUtc(),
      bookingRequestQuota: (json['matchQuota'] as num?)?.toInt() ?? 0,
      bookingRequestsUsed:
          (json['connectionsUsed'] as num? ?? json['matchesUsed'] as num?)
              ?.toInt() ??
          0,
    );
  }
}

class BillingApi {
  BillingApi(this._dio);
  final Dio _dio;

  Future<List<PlanItem>> plans() async {
    final res = await _dio.get('/v1/billing/plans');
    final data = res.data;
    if (data is! List) {
      throw DioException(
        requestOptions: res.requestOptions,
        response: res,
        type: DioExceptionType.badResponse,
        message: 'Unexpected plans response',
      );
    }
    return data
        .whereType<Map>()
        .map((e) => PlanItem.fromJson(Map<String, dynamic>.from(e)))
        .toList();
  }

  Future<SubscriptionItem?> current() async {
    final res = await _dio.get('/v1/billing/subscription');
    if (res.statusCode == 204 || res.data == null) return null;
    if (res.data is! Map) return null;
    return SubscriptionItem.fromJson(
      Map<String, dynamic>.from(res.data as Map),
    );
  }

  Future<CheckoutResult?> pendingCbe() async {
    final res = await _dio.get('/v1/billing/pending-cbe');
    if (res.statusCode == 204 || res.data is! Map) return null;
    return CheckoutResult.fromJson(Map<String, dynamic>.from(res.data as Map));
  }

  Future<CheckoutResult> subscribe(String planCode) async {
    final res = await _dio.post(
      '/v1/billing/subscribe',
      data: {'planCode': planCode},
    );
    if (res.data is! Map) {
      throw DioException(
        requestOptions: res.requestOptions,
        response: res,
        type: DioExceptionType.badResponse,
        message: 'Unexpected checkout response',
      );
    }
    return CheckoutResult.fromJson(Map<String, dynamic>.from(res.data as Map));
  }

  Future<CheckoutResult> payBooking(String bookingId) async {
    final res = await _dio.post('/v1/billing/bookings/$bookingId/pay');
    return CheckoutResult.fromJson(Map<String, dynamic>.from(res.data as Map));
  }

  /// Returns the current pending CBE checkout for a booking (null if none).
  /// Used by the booking screen to restore the upload panel after resume.
  Future<CheckoutResult?> pendingBookingPayment(String bookingId) async {
    final res = await _dio.get(
      '/v1/billing/bookings/$bookingId/pending-payment',
    );
    if (res.statusCode == 204 || res.data is! Map) return null;
    return CheckoutResult.fromJson(Map<String, dynamic>.from(res.data as Map));
  }

  Future<SubscriptionItem> submitCbeProof({
    required String paymentIntentId,
    String? filePath,
    String? reference,
  }) async {
    final form = FormData.fromMap({
      if (filePath != null)
        'file': await MultipartFile.fromFile(
          filePath,
          filename: filePath.split('/').last,
          contentType: mediaTypeForPath(filePath) ?? MediaType('image', 'jpeg'),
        ),
      if (reference != null && reference.isNotEmpty) 'reference': reference,
    });
    final res = await _dio.post(
      '/v1/billing/payments/$paymentIntentId/cbe-proof',
      data: form,
    );
    final data = Map<String, dynamic>.from(res.data as Map);
    if (data.containsKey('planCode')) {
      return SubscriptionItem.fromJson(data);
    }
    // Booking payment — membership screen ignores body after success.
    return SubscriptionItem(
      id: data['paymentIntentId']?.toString() ?? paymentIntentId,
      planCode: 'BOOKING',
      planNameEn: 'Booking',
      status: data['status']?.toString() ?? 'PAID',
      endsAt: DateTime.now().add(const Duration(days: 1)),
      bookingRequestQuota: 0,
      bookingRequestsUsed: 0,
    );
  }

  Future<SubscriptionItem> completeMockCbe(String paymentIntentId) async {
    final res = await _dio.post(
      '/v1/billing/payments/$paymentIntentId/cbe-mock-complete',
    );
    final data = Map<String, dynamic>.from(res.data as Map);
    if (data.containsKey('planCode')) {
      return SubscriptionItem.fromJson(data);
    }
    return SubscriptionItem(
      id: data['paymentIntentId']?.toString() ?? paymentIntentId,
      planCode: 'BOOKING',
      planNameEn: 'Booking',
      status: data['status']?.toString() ?? 'PAID',
      endsAt: DateTime.now().add(const Duration(days: 1)),
      bookingRequestQuota: 0,
      bookingRequestsUsed: 0,
    );
  }

  Future<SubscriptionItem> completeMock(String orderId) async {
    final res = await _dio.post(
      '/v1/billing/telebirr/mock-complete',
      queryParameters: {'orderId': orderId},
    );
    return SubscriptionItem.fromJson(
      Map<String, dynamic>.from(res.data as Map),
    );
  }
}

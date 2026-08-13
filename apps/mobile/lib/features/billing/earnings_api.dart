import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:velvet_mobile/core/network/dio_client.dart';

final earningsApiProvider = Provider<EarningsApi>((ref) => EarningsApi(ref.watch(dioProvider)));

class EarningsSummary {
  EarningsSummary({
    required this.availableEtb,
    required this.lifetimeEarnedEtb,
    required this.lifetimePaidOutEtb,
    required this.platformFeePercent,
    this.recent = const [],
    this.payouts = const [],
  });

  final double availableEtb;
  final double lifetimeEarnedEtb;
  final double lifetimePaidOutEtb;
  final int platformFeePercent;
  final List<EarningsLedgerItem> recent;
  final List<PayoutItem> payouts;

  factory EarningsSummary.fromJson(Map<String, dynamic> json) => EarningsSummary(
        availableEtb: (json['availableEtb'] as num?)?.toDouble() ?? 0,
        lifetimeEarnedEtb: (json['lifetimeEarnedEtb'] as num?)?.toDouble() ?? 0,
        lifetimePaidOutEtb: (json['lifetimePaidOutEtb'] as num?)?.toDouble() ?? 0,
        platformFeePercent: (json['platformFeePercent'] as num?)?.toInt() ?? 15,
        recent: (json['recent'] as List<dynamic>? ?? [])
            .map((e) => EarningsLedgerItem.fromJson(Map<String, dynamic>.from(e as Map)))
            .toList(),
        payouts: (json['payouts'] as List<dynamic>? ?? [])
            .map((e) => PayoutItem.fromJson(Map<String, dynamic>.from(e as Map)))
            .toList(),
      );
}

class EarningsLedgerItem {
  EarningsLedgerItem({
    required this.id,
    required this.entryType,
    required this.amountEtb,
    this.description,
    this.bookingId,
    this.createdAt,
  });

  final String id;
  final String entryType;
  final double amountEtb;
  final String? description;
  final String? bookingId;
  final DateTime? createdAt;

  factory EarningsLedgerItem.fromJson(Map<String, dynamic> json) => EarningsLedgerItem(
        id: json['id']?.toString() ?? '',
        entryType: json['entryType']?.toString() ?? '',
        amountEtb: (json['amountEtb'] as num?)?.toDouble() ?? 0,
        description: json['description'] as String?,
        bookingId: json['bookingId'] as String?,
        createdAt: json['createdAt'] != null ? DateTime.tryParse(json['createdAt'] as String) : null,
      );
}

class PayoutItem {
  PayoutItem({
    required this.id,
    required this.amountEtb,
    required this.status,
    this.destinationNote,
    this.createdAt,
    this.processedAt,
  });

  final String id;
  final double amountEtb;
  final String status;
  final String? destinationNote;
  final DateTime? createdAt;
  final DateTime? processedAt;

  factory PayoutItem.fromJson(Map<String, dynamic> json) => PayoutItem(
        id: json['id']?.toString() ?? '',
        amountEtb: (json['amountEtb'] as num?)?.toDouble() ?? 0,
        status: json['status']?.toString() ?? '',
        destinationNote: json['destinationNote'] as String?,
        createdAt: json['createdAt'] != null ? DateTime.tryParse(json['createdAt'] as String) : null,
        processedAt: json['processedAt'] != null ? DateTime.tryParse(json['processedAt'] as String) : null,
      );
}

class EarningsApi {
  EarningsApi(this._dio);
  final Dio _dio;

  Future<EarningsSummary> summary() async {
    final res = await _dio.get('/v1/earnings');
    return EarningsSummary.fromJson(Map<String, dynamic>.from(res.data as Map));
  }

  Future<PayoutItem> requestPayout({
    required double amountEtb,
    String? destinationNote,
  }) async {
    final res = await _dio.post('/v1/earnings/payout', data: {
      'amountEtb': amountEtb,
      if (destinationNote != null && destinationNote.isNotEmpty) 'destinationNote': destinationNote,
    });
    return PayoutItem.fromJson(Map<String, dynamic>.from(res.data as Map));
  }
}

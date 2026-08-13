import 'package:flutter_test/flutter_test.dart';
import 'package:velvet_mobile/features/billing/billing_api.dart';

void main() {
  group('SubscriptionItem.fromJson', () {
    test('maps connectionsUsed from the current billing API', () {
      final subscription = SubscriptionItem.fromJson({
        'id': 'sub-1',
        'planCode': 'PLUS',
        'planNameEn': 'Plus',
        'status': 'ACTIVE',
        'endsAt': '2026-09-01T00:00:00Z',
        'matchQuota': 10,
        'connectionsUsed': 3,
      });

      expect(subscription.bookingRequestsUsed, 3);
    });

    test('accepts the legacy matchesUsed billing field', () {
      final subscription = SubscriptionItem.fromJson({
        'endsAt': '2026-09-01T00:00:00Z',
        'matchesUsed': 2,
      });

      expect(subscription.bookingRequestsUsed, 2);
    });
  });
}

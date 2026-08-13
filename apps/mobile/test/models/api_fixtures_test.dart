import 'package:flutter_test/flutter_test.dart';
import 'package:velvet_mobile/features/billing/billing_api.dart';
import 'package:velvet_mobile/features/billing/earnings_api.dart';
import 'package:velvet_mobile/features/connections/connections_api.dart';
import 'package:velvet_mobile/features/discover/discover_api.dart';
import 'package:velvet_mobile/features/notifications/notifications_api.dart';
import 'package:velvet_mobile/features/social/social_api.dart';
import '../fixtures/velvet_fixtures.dart';

void main() {
  group('VelvetFixtures', () {
    test('mutual connection parses inbox metadata', () {
      final item = ConnectionItem.fromJson(VelvetFixtures.mutualConnection());

      expect(item.id, VelvetFixtures.abelConnectionId);
      expect(item.counterpartDisplayName, 'Sara');
      expect(item.turn, 'YOUR_TURN');
      expect(item.unreadCount, 1);
      expect(item.counterpartVerified, isTrue);
    });

    test('booking fixtures cover propose, pay, and complete flows', () {
      final proposed = BookingItem.fromJson(VelvetFixtures.proposedBooking());
      final pending = BookingItem.fromJson(VelvetFixtures.pendingPaymentBooking());
      final completed = BookingItem.fromJson(VelvetFixtures.completedBooking());

      expect(proposed.status, 'PROPOSED');
      expect(proposed.needsPayment, isTrue);

      expect(pending.status, 'CONFIRMED');
      expect(pending.needsPayment, isTrue);
      expect(pending.venueName, contains('Tomoca'));

      expect(completed.status, 'COMPLETED');
      expect(completed.paymentStatus, 'PAID');
      expect(completed.myCheckoutConfirmed, isTrue);
    });

    test('chat messages parse from seeded thread payload', () {
      final message = ChatMessage.fromJson(
        VelvetFixtures.chatMessage(
          id: 'eeeeeeee-eeee-eeee-eeee-eeeeeeeeee04',
          senderId: VelvetFixtures.saraUserId,
          body: 'Perfect. I have an open window — send it when ready.',
        ),
      );

      expect(message.senderId, VelvetFixtures.saraUserId);
      expect(message.moderationStatus, 'ALLOWED');
    });

    test('notification fixture keeps routing metadata', () {
      final notification = AppNotification.fromJson(VelvetFixtures.unreadNotification());

      expect(notification.read, isFalse);
      expect(notification.relatedType, 'MATCH');
      expect(notification.relatedId, VelvetFixtures.abelConnectionId);
    });

    test('earnings summary parses ledger and payout queue', () {
      final summary = EarningsSummary.fromJson(VelvetFixtures.earningsSummary());

      expect(summary.lifetimeEarnedEtb, 5100);
      expect(summary.recent.single.entryType, 'PERFORMER_CREDIT');
      expect(summary.payouts.single.status, 'REQUESTED');
    });

    test('discover card includes marketplace listing fields', () {
      final card = DiscoverCard.fromJson(VelvetFixtures.discoverCard());

      expect(card.displayName, 'Sara');
      expect(card.sessionRateEtb, 4500);
      expect(card.verified, isTrue);
    });

    test('blocked member fixture parses safely', () {
      final blocked = BlockedMember.fromJson(VelvetFixtures.blockedMember());

      expect(blocked.reason, contains('Robel'));
    });

    test('subscription fixture still maps billing usage fields', () {
      final subscription = SubscriptionItem.fromJson({
        'id': 'sub-demo',
        'planCode': 'ELITE',
        'planNameEn': 'Elite',
        'status': 'ACTIVE',
        'endsAt': '2026-12-01T00:00:00Z',
        'matchQuota': -1,
        'connectionsUsed': 2,
      });

      expect(subscription.bookingRequestsUsed, 2);
    });
  });
}

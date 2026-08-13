/// Shared API payload fixtures aligned with `db/seed/demo_roster.sql`.
abstract final class VelvetFixtures {
  static const abelConnectionId = 'cccccccc-cccc-cccc-cccc-cccccccccc02';
  static const saraUserId = 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbb01';
  static const abelUserId = 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaa01';
  static const proposedBookingId = 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbb001';
  static const pendingPaymentBookingId = 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbb002';
  static const completedBookingId = 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbb003';

  static Map<String, dynamic> mutualConnection({
    String turn = 'YOUR_TURN',
    int unreadCount = 1,
  }) =>
      {
        'id': abelConnectionId,
        'status': 'MUTUAL',
        'counterpartDisplayName': 'Sara',
        'counterpartUserId': saraUserId,
        'introNoteEn': 'You both said yes — plan a venue meeting when ready.',
        'awaitingMyResponse': false,
        'mutual': true,
        'meetingCompleted': false,
        'counterpartPhotoUrls': [
          'https://images.unsplash.com/photo-1494790108377-be9c29b29330?auto=format&fit=crop&w=1200&h=1600&q=85',
        ],
        'counterpartVerified': true,
        'counterpartTrustScore': 86,
        'source': 'DISCOVERY',
        'lastMessagePreview': 'Perfect. I have an open window — send it when ready.',
        'lastMessageAt': '2026-08-10T18:30:00Z',
        'lastMessageFromMe': false,
        'unreadCount': unreadCount,
        'turn': turn,
      };

  static Map<String, dynamic> proposedBooking() => {
        'id': proposedBookingId,
        'connectionId': abelConnectionId,
        'meetupPlace': 'Kazanchis — private residence (discreet)',
        'rateType': 'SESSION',
        'amountEtb': 4000,
        'paymentStatus': 'UNPAID',
        'status': 'PROPOSED',
        'startsAt': '2026-08-15T19:00:00Z',
        'proposedBy': abelUserId,
        'myCheckoutConfirmed': false,
        'counterpartCheckoutConfirmed': false,
        'feedbackSubmitted': false,
      };

  static Map<String, dynamic> pendingPaymentBooking() => {
        'id': pendingPaymentBookingId,
        'connectionId': 'cccccccc-cccc-cccc-cccc-cccccccccc05',
        'venueId': 'venue-tomoca',
        'venueName': 'Tomoca Coffee — Piazza quiet table',
        'venueCity': 'Addis Ababa',
        'rateType': 'SESSION',
        'amountEtb': 5500,
        'paymentStatus': 'PENDING',
        'status': 'CONFIRMED',
        'startsAt': '2026-08-14T20:00:00Z',
        'proposedBy': 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaa02',
        'confirmedAt': '2026-08-11T12:00:00Z',
        'myCheckoutConfirmed': false,
        'counterpartCheckoutConfirmed': false,
        'feedbackSubmitted': false,
      };

  static Map<String, dynamic> completedBooking() => {
        'id': completedBookingId,
        'connectionId': 'cccccccc-cccc-cccc-cccc-cccccccccc06',
        'meetupPlace': 'Bole — discreet suite',
        'rateType': 'SESSION',
        'amountEtb': 6000,
        'paymentStatus': 'PAID',
        'status': 'COMPLETED',
        'startsAt': '2026-08-07T20:00:00Z',
        'proposedBy': 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaa05',
        'confirmedAt': '2026-08-06T10:00:00Z',
        'checkedInAt': '2026-08-07T20:00:00Z',
        'checkedOutAt': '2026-08-07T23:00:00Z',
        'myCheckoutConfirmed': true,
        'counterpartCheckoutConfirmed': true,
        'feedbackSubmitted': false,
      };

  static Map<String, dynamic> chatMessage({
    required String id,
    required String senderId,
    required String body,
    bool readByPeer = false,
  }) =>
      {
        'id': id,
        'senderId': senderId,
        'body': body,
        'moderationStatus': 'ALLOWED',
        'createdAt': '2026-08-10T18:30:00Z',
        'readByPeer': readByPeer,
      };

  static Map<String, dynamic> unreadNotification() => {
        'id': 'nnnnnnnn-nnnn-nnnn-nnnn-nnnnnnnnnn01',
        'subject': 'Sara replied',
        'body': 'Perfect. I have an open window — send it when ready.',
        'relatedType': 'MATCH',
        'relatedId': abelConnectionId,
        'read': false,
        'createdAt': '2026-08-10T18:35:00Z',
      };

  static Map<String, dynamic> earningsSummary() => {
        'availableEtb': 2100,
        'lifetimeEarnedEtb': 5100,
        'lifetimePaidOutEtb': 0,
        'platformFeePercent': 15,
        'recent': [
          {
            'id': 'llllllll-llll-llll-llll-llllllllll01',
            'entryType': 'PERFORMER_CREDIT',
            'amountEtb': 5100,
            'description': 'Booking credit (85% of 6000 ETB)',
            'bookingId': completedBookingId,
            'createdAt': '2026-08-07T23:00:00Z',
          },
        ],
        'payouts': [
          {
            'id': 'pppppppp-pppp-pppp-pppp-pppppppppp01',
            'amountEtb': 3000,
            'status': 'REQUESTED',
            'destinationNote': 'CBE •••• 4821 — Helen demo payout',
            'createdAt': '2026-08-10T10:00:00Z',
          },
        ],
      };

  static Map<String, dynamic> discoverCard() => {
        'userId': saraUserId,
        'displayName': 'Sara',
        'age': 30,
        'city': 'Addis Ababa',
        'bioEn':
            'Designer with an eye for beautiful details, slow conversation, and a night that unfolds naturally.',
        'bioAm': 'ዲዛይነር',
        'sessionRateEtb': 4500,
        'overnightRateEtb': 15000,
        'availabilityNote': 'See calendar for open windows',
        'photoUrls': [
          'https://images.unsplash.com/photo-1494790108377-be9c29b29330?auto=format&fit=crop&w=1200&h=1600&q=85',
        ],
        'distanceKm': 2.4,
        'interests': ['Design', 'Food', 'Art'],
        'verified': true,
        'trustScore': 86,
      };

  static Map<String, dynamic> blockedMember() => {
        'id': 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbb901',
        'blockedUserId': 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaa0b',
        'reason': 'Demo block — Robel',
        'createdAt': '2026-08-09T12:00:00Z',
      };
}

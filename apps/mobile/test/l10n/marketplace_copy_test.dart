import 'package:flutter_test/flutter_test.dart';
import 'package:velvet_mobile/l10n/generated/app_localizations_en.dart';

void main() {
  final l10n = AppLocalizationsEn('en');

  test('marketplace l10n avoids dating-era product terms', () {
    const banned = ['icebreaker', 'Mutual match', 'swipe', 'It\'s a match'];

    final samples = [
      l10n.openerRequired,
      l10n.conversationsInboxTitle,
      l10n.connectionConfirmedTitle,
      l10n.flowNextChatBody,
      l10n.flowPostCheckoutBody,
      l10n.wouldBookAgain,
      l10n.clientRequestsEmpty,
    ];

    for (final text in samples) {
      for (final term in banned) {
        expect(text.toLowerCase(), isNot(contains(term.toLowerCase())),
            reason: '$text should not contain "$term"');
      }
    }
  });

  test('renamed marketplace keys expose booking-first copy', () {
    expect(l10n.bookingRequestsPerMonth, contains('booking'));
    expect(l10n.connectionHistoryTitle, contains('connection'));
    expect(l10n.statusConnected, 'Connected');
    expect(l10n.wouldBookAgain, contains('book'));
  });
}

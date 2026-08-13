import 'package:flutter_test/flutter_test.dart';
import 'package:velvet_mobile/features/discover/discover_api.dart';
import '../fixtures/velvet_fixtures.dart';

void main() {
  group('DiscoverActionResult.fromJson', () {
    test('maps connectionId from discover API', () {
      final result = DiscoverActionResult.fromJson({
        'mutual': true,
        'connectionId': VelvetFixtures.abelConnectionId,
        'counterpartDisplayName': 'Sara',
        'counterpartPhotoUrls': VelvetFixtures.discoverCard()['photoUrls'],
      });

      expect(result.mutual, isTrue);
      expect(result.connectionId, VelvetFixtures.abelConnectionId);
      expect(result.counterpartDisplayName, 'Sara');
    });

    test('falls back to legacy matchId field', () {
      final result = DiscoverActionResult.fromJson({
        'mutual': true,
        'matchId': 'conn-legacy',
      });

      expect(result.connectionId, 'conn-legacy');
    });
  });
}

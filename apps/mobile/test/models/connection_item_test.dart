import 'package:flutter_test/flutter_test.dart';
import 'package:velvet_mobile/features/connections/connections_api.dart';
import '../fixtures/velvet_fixtures.dart';

void main() {
  group('ConnectionItem.fromJson', () {
    test('parses concierge intro fields from match API payload', () {
      final item = ConnectionItem.fromJson(VelvetFixtures.mutualConnection(
        turn: 'ME',
        unreadCount: 2,
      )..['status'] = 'PENDING'
        ..['awaitingMyResponse'] = true
        ..['mutual'] = false
        ..['counterpartDisplayName'] = 'Selam'
        ..['counterpartUserId'] = 'user-2'
        ..['introNoteEn'] = 'Evening booking');

      expect(item.id, VelvetFixtures.abelConnectionId);
      expect(item.status, 'PENDING');
      expect(item.counterpartDisplayName, 'Selam');
      expect(item.awaitingMyResponse, isTrue);
      expect(item.mutual, isFalse);
      expect(item.counterpartPhotoUrls, isNotEmpty);
      expect(item.counterpartVerified, isTrue);
      expect(item.unreadCount, 2);
      expect(item.turn, 'ME');
    });

    test('defaults optional fields safely', () {
      final item = ConnectionItem.fromJson({
        'id': 'conn-2',
        'status': 'DECLINED',
      });

      expect(item.counterpartPhotoUrls, isEmpty);
      expect(item.counterpartInterests, isEmpty);
      expect(item.source, 'CONCIERGE');
      expect(item.unreadCount, 0);
      expect(item.turn, 'NONE');
    });
  });
}

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:velvet_mobile/app.dart';

void main() {
  testWidgets('VELVET app boots', (tester) async {
    await tester.pumpWidget(const ProviderScope(child: VelvetApp()));
    await tester.pump();
    expect(find.textContaining('VELVET'), findsWidgets);
    await tester.pump(const Duration(seconds: 10));
  });
}

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:velvet_mobile/features/discover/listing_catalog.dart';
import 'package:velvet_mobile/l10n/generated/app_localizations.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  Future<List<Rect>> pumpGrid(
    WidgetTester tester, {
    required Widget Function(BuildContext, int) itemBuilder,
    Widget Function(Widget grid)? wrap,
  }) async {
    tester.view.physicalSize = const Size(400, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final grid = AsymmetricListingGrid(
      itemCount: 4,
      padding: const EdgeInsets.all(20),
      gutter: 10,
      itemBuilder: itemBuilder,
    );

    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: wrap?.call(grid) ?? grid,
        ),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    return [
      for (var i = 0; i < 4; i++) tester.getRect(find.byKey(ValueKey('tile-$i'))),
    ];
  }

  testWidgets('masonry grid places items in two columns', (tester) async {
    final rects = await pumpGrid(
      tester,
      itemBuilder: (context, i) => KeyedSubtree(
        key: ValueKey('tile-$i'),
        child: AspectRatio(
          aspectRatio: listingTileAspectRatio(i),
          child: const ColoredBox(color: Colors.red),
        ),
      ),
    );

    debugPrint('ISOLATED: $rects');
    expect(rects[1].left, greaterThan(rects[0].right - 1),
        reason: 'item 1 should sit in the right column, not under item 0');
    expect(rects[0].left, lessThan(50));
  });

  testWidgets('masonry grid inside Discover-like parent still has two columns',
      (tester) async {
    final rects = await pumpGrid(
      tester,
      wrap: (grid) => Column(
        children: [
          const SizedBox(height: 160, child: ColoredBox(color: Colors.black)),
          Expanded(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 280),
              child: RefreshIndicator(
                onRefresh: () async {},
                child: grid,
              ),
            ),
          ),
        ],
      ),
      itemBuilder: (context, i) => KeyedSubtree(
        key: ValueKey('tile-$i'),
        child: AspectRatio(
          aspectRatio: listingTileAspectRatio(i),
          child: const ColoredBox(color: Colors.red),
        ),
      ),
    );

    debugPrint('PARENT: $rects');
    expect(rects[1].left, greaterThan(rects[0].right - 1),
        reason: 'Discover parent chain must not collapse masonry to 1 column');
  });

  testWidgets('real PerformerListingTile stays two-column', (tester) async {
    tester.view.physicalSize = const Size(400, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: Column(
            children: [
              const SizedBox(height: 160),
              Expanded(
                child: AsymmetricListingGrid(
                  itemCount: 4,
                  itemBuilder: (context, i) => PerformerListingTile(
                    listing: ListingCardData(
                      id: '$i',
                      name: 'Name$i',
                      age: 24,
                      city: 'Addis',
                      photoUrls: const [],
                    ),
                    index: i,
                    onRequest: () {},
                    onSkip: () {},
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));

    final r0 = tester.getRect(find.text('Name0, 24'));
    final r1 = tester.getRect(find.text('Name1, 24'));
    debugPrint('REAL TILES: $r0 | $r1');
    expect(r1.left, greaterThan(r0.right - 1),
        reason: 'PerformerListingTile must not collapse masonry to one column');
  });

  testWidgets('listing-style tiles (nested aspect + pageview + animate)',
      (tester) async {
    final captured = <BoxConstraints>[];
    final rects = await pumpGrid(
      tester,
      wrap: (grid) => Column(
        children: [
          const SizedBox(height: 160),
          Expanded(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 280),
              child: RefreshIndicator(
                onRefresh: () async {},
                child: grid,
              ),
            ),
          ),
        ],
      ),
      itemBuilder: (context, i) {
        final aspect = listingTileAspectRatio(i);
        return KeyedSubtree(
          key: ValueKey('tile-$i'),
          child: LayoutBuilder(
            builder: (context, constraints) {
              captured.add(constraints);
              return AspectRatio(
                aspectRatio: aspect,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    AspectRatio(
                      aspectRatio: aspect,
                      child: PageView(
                        children: const [ColoredBox(color: Colors.blue)],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        );
      },
    );

    debugPrint('TILE-LIKE: $rects');
    debugPrint('CONSTRAINTS: $captured');
    expect(rects[1].left, greaterThan(rects[0].right - 1));
    expect(captured.first.maxWidth, lessThan(250),
        reason: 'masonry cells must be column-width, not full screen');
  });
}

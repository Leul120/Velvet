import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:velvet_mobile/core/network/media_url.dart';
import 'package:velvet_mobile/core/theme/velvet_tokens.dart';
import 'package:velvet_mobile/features/discover/listing_detail_screen.dart';
import 'package:velvet_mobile/l10n/generated/app_localizations.dart';

export 'listing_detail_screen.dart'
    show ListingCardData, ListingDetailActions, openListingDetail;

/// Soft asymmetric radii for masonry rhythm.
BorderRadius listingTileRadius(int index) {
  final left = index.isEven;
  final pattern = index % 3;
  if (left) {
    return BorderRadius.only(
      topLeft: Radius.circular(pattern == 0 ? 28 : 20),
      topRight: const Radius.circular(16),
      bottomLeft: const Radius.circular(16),
      bottomRight: Radius.circular(pattern == 1 ? 28 : 22),
    );
  }
  return BorderRadius.only(
    topLeft: const Radius.circular(16),
    topRight: Radius.circular(pattern == 0 ? 28 : 22),
    bottomLeft: Radius.circular(pattern == 2 ? 28 : 20),
    bottomRight: const Radius.circular(16),
  );
}

bool listingTileIsTall(int index) => listingTileAspectRatio(index) < 0.75;

/// Distinct portrait ratios so columns stagger like Pinterest masonry.
double listingTileAspectRatio(int index) {
  const ratios = [0.52, 0.84, 0.62, 0.96, 0.56, 0.74, 0.90, 0.60];
  return ratios[index % ratios.length];
}

Widget _masonryTiles({
  required int itemCount,
  required IndexedWidgetBuilder itemBuilder,
  required double gutter,
}) {
  return StaggeredGrid.count(
    crossAxisCount: 2,
    mainAxisSpacing: gutter,
    crossAxisSpacing: gutter,
    children: [
      for (var i = 0; i < itemCount; i++)
        StaggeredGridTile.fit(
          crossAxisCellCount: 1,
          child: Builder(
            builder: (context) => itemBuilder(context, i),
          ),
        ),
    ],
  );
}

/// Two-column Pinterest-style masonry.
///
/// Implemented as a single [ListView] wrapping a box [StaggeredGrid], not a
/// nested [MasonryGridView] viewport. Nested sliver-masonry + [PageView]
/// tiles collapse to one column under the member shell constraints.
class AsymmetricListingGrid extends StatelessWidget {
  const AsymmetricListingGrid({
    super.key,
    required this.itemCount,
    required this.itemBuilder,
    this.padding = const EdgeInsets.fromLTRB(
      VelvetTokens.pageInset,
      VelvetTokens.space8,
      VelvetTokens.pageInset,
      96,
    ),
    this.gutter = VelvetTokens.space12,
    this.shrinkWrap = false,
    this.physics,
  });

  final int itemCount;
  final IndexedWidgetBuilder itemBuilder;
  final EdgeInsets padding;
  final double gutter;
  final bool shrinkWrap;
  final ScrollPhysics? physics;

  @override
  Widget build(BuildContext context) {
    final bottom = padding.bottom + MediaQuery.paddingOf(context).bottom;
    final grid = _masonryTiles(
      itemCount: itemCount,
      itemBuilder: itemBuilder,
      gutter: gutter,
    );

    if (shrinkWrap) {
      return Padding(
        padding: padding.copyWith(bottom: bottom),
        child: grid,
      );
    }

    return ListView(
      physics: physics ??
          const AlwaysScrollableScrollPhysics(
            parent: BouncingScrollPhysics(),
          ),
      padding: padding.copyWith(bottom: bottom),
      children: [grid],
    );
  }
}

/// Sliver version for CustomScrollView headers.
class AsymmetricListingSliver extends StatelessWidget {
  const AsymmetricListingSliver({
    super.key,
    required this.itemCount,
    required this.itemBuilder,
    this.padding = const EdgeInsets.fromLTRB(
      VelvetTokens.pageInset,
      VelvetTokens.space8,
      VelvetTokens.pageInset,
      96,
    ),
    this.gutter = VelvetTokens.space12,
  });

  final int itemCount;
  final IndexedWidgetBuilder itemBuilder;
  final EdgeInsets padding;
  final double gutter;

  @override
  Widget build(BuildContext context) {
    final bottom = padding.bottom + MediaQuery.paddingOf(context).bottom;
    return SliverPadding(
      padding: padding.copyWith(bottom: bottom),
      sliver: SliverToBoxAdapter(
        child: _masonryTiles(
          itemCount: itemCount,
          itemBuilder: itemBuilder,
          gutter: gutter,
        ),
      ),
    );
  }
}


class PerformerListingTile extends StatelessWidget {
  const PerformerListingTile({
    super.key,
    required this.listing,
    required this.onRequest,
    required this.onSkip,
    this.loading = false,
    this.index = 0,
  });

  final ListingCardData listing;
  final VoidCallback onRequest;
  final VoidCallback onSkip;
  final bool loading;
  final int index;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final title = [
      listing.name,
      if (listing.age != null) '${listing.age}',
    ].join(', ');
    final rateLabel = listing.sessionRateEtb == null
        ? null
        : l10n.listingEtbAmount(listing.sessionRateEtb!);
    final radius = listingTileRadius(index);
    final aspect = listingTileAspectRatio(index);
    final meta = [
      if (listing.city?.isNotEmpty == true) listing.city!,
      if (rateLabel != null) rateLabel,
    ].join(' · ');

    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth.isFinite
            ? constraints.maxWidth
            : MediaQuery.sizeOf(context).width / 2 - VelvetTokens.pageInset;
        final height = width / aspect;
        return SizedBox(
          width: width,
          height: height,
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () => openListingDetail(
                context,
                listing,
                actions: ListingDetailActions(
                  primaryLabel: l10n.requestBooking,
                  onPrimary: onRequest,
                  secondaryLabel: l10n.skipListing,
                  onSecondary: onSkip,
                  loading: loading,
                ),
              ),
              borderRadius: radius,
              child: ClipRRect(
                borderRadius: radius,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    _ListingTilePhoto(photoUrls: listing.photoUrls),
                    const DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Color(0x22000000),
                            Color(0x00000000),
                            Color(0xCC000000),
                          ],
                          stops: [0, 0.42, 1],
                        ),
                      ),
                    ),
                    if (listing.verified)
                      Positioned(
                        top: 10,
                        right: 10,
                        child: Container(
                          width: 22,
                          height: 22,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: VelvetTokens.ember,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.35),
                                blurRadius: 8,
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.verified_rounded,
                            size: 13,
                            color: VelvetTokens.onPrimary,
                          ),
                        ),
                      ),
                    Positioned(
                      left: 12,
                      right: 12,
                      bottom: 12,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.syne(
                              color: Colors.white,
                              fontSize: listingTileIsTall(index) ? 18 : 16,
                              fontWeight: FontWeight.w700,
                              letterSpacing: -0.5,
                              height: 1.05,
                            ),
                          ),
                          if (meta.isNotEmpty) ...[
                            const SizedBox(height: 3),
                            Text(
                              meta,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.dmSans(
                                color: Colors.white.withValues(alpha: 0.78),
                                fontSize: 11.5,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    if (loading)
                      const ColoredBox(
                        color: Color(0x66000000),
                        child: Center(
                          child: SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: VelvetTokens.ember,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        )
            .animate()
            .fadeIn(delay: (28 * index).ms, duration: 320.ms)
            .slideY(begin: 0.04, end: 0, curve: Curves.easeOutCubic);
      },
    );
  }
}

class _ListingTilePhoto extends StatelessWidget {
  const _ListingTilePhoto({required this.photoUrls});

  final List<String> photoUrls;

  @override
  Widget build(BuildContext context) {
    if (photoUrls.isEmpty) {
      return const ColoredBox(
        color: VelvetTokens.parchmentDeep,
        child: Center(
          child: Icon(Icons.person_outline, size: 36, color: Colors.white38),
        ),
      );
    }
    return Image.network(
      resolveMediaUrl(photoUrls.first),
      fit: BoxFit.cover,
      gaplessPlayback: true,
      loadingBuilder: (context, child, progress) {
        if (progress == null) return child;
        return const ColoredBox(color: VelvetTokens.parchmentDeep);
      },
      errorBuilder: (_, _, _) => const ColoredBox(
        color: VelvetTokens.parchmentDeep,
        child: Icon(Icons.broken_image_outlined, color: Colors.white38),
      ),
    );
  }
}

class BookingRequestTile extends StatelessWidget {
  const BookingRequestTile({
    super.key,
    required this.listing,
    required this.onAccept,
    required this.onDecline,
    this.loading = false,
    this.index = 0,
  });

  final ListingCardData listing;
  final VoidCallback onAccept;
  final VoidCallback onDecline;
  final bool loading;
  final int index;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final title = [
      listing.name,
      if (listing.age != null) '${listing.age}',
    ].join(', ');
    final radius = listingTileRadius(index);
    final aspect = listingTileAspectRatio(index);
    final subtitle = listing.subtitle ?? l10n.clientRequestHint;

    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth.isFinite
            ? constraints.maxWidth
            : MediaQuery.sizeOf(context).width / 2 - VelvetTokens.pageInset;
        final height = width / aspect;
        return SizedBox(
          width: width,
          height: height,
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () => openListingDetail(
                context,
                listing,
                actions: ListingDetailActions(
                  primaryLabel: l10n.acceptRequest,
                  onPrimary: onAccept,
                  secondaryLabel: l10n.declineRequest,
                  onSecondary: onDecline,
                  loading: loading,
                ),
              ),
              borderRadius: radius,
              child: ClipRRect(
                borderRadius: radius,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    _ListingTilePhoto(photoUrls: listing.photoUrls),
                    const DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Color(0x33000000),
                            Color(0x00000000),
                            Color(0xCC000000),
                          ],
                          stops: [0, 0.4, 1],
                        ),
                      ),
                    ),
                    Positioned(
                      top: 10,
                      left: 10,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: VelvetTokens.ember,
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Text(
                          l10n.segmentRequests,
                          style: GoogleFonts.dmSans(
                            color: VelvetTokens.onPrimary,
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.3,
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      left: 12,
                      right: 12,
                      bottom: 12,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.syne(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              letterSpacing: -0.4,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            subtitle,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.dmSans(
                              color: Colors.white.withValues(alpha: 0.78),
                              fontSize: 11.5,
                              height: 1.3,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (loading)
                      const ColoredBox(
                        color: Color(0x66000000),
                        child: Center(
                          child: SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: VelvetTokens.ember,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        )
            .animate()
            .fadeIn(delay: (28 * index).ms, duration: 320.ms)
            .slideY(begin: 0.04, end: 0, curve: Curves.easeOutCubic);
      },
    );
  }
}

class ConciergeIntroTile extends StatelessWidget {
  const ConciergeIntroTile({
    super.key,
    required this.listing,
    required this.onAccept,
    required this.onDecline,
    this.index = 0,
  });

  final ListingCardData listing;
  final VoidCallback onAccept;
  final VoidCallback onDecline;
  final int index;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final title = [
      listing.name,
      if (listing.age != null) '${listing.age}',
    ].join(', ');
    final note = listing.subtitle ?? l10n.clientRequestHint;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => openListingDetail(
          context,
          listing,
          actions: ListingDetailActions(
            primaryLabel: l10n.acceptRequest,
            onPrimary: onAccept,
            secondaryLabel: l10n.declineRequest,
            onSecondary: onDecline,
          ),
        ),
        borderRadius: BorderRadius.circular(20),
        child: Ink(
          height: 112,
          decoration: BoxDecoration(
            color: VelvetTokens.parchmentLift,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: VelvetTokens.line.withValues(alpha: 0.7),
            ),
          ),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.horizontal(
                  left: Radius.circular(20),
                ),
                child: SizedBox(
                  width: 88,
                  height: 112,
                  child: _ListingTilePhoto(photoUrls: listing.photoUrls),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.segmentIntros,
                        style: GoogleFonts.dmSans(
                          color: VelvetTokens.ember,
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.6,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.syne(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          letterSpacing: -0.4,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        note,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.dmSans(
                          color: VelvetTokens.muted,
                          fontSize: 13,
                          height: 1.35,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    )
        .animate()
        .fadeIn(delay: (40 * index).ms, duration: 280.ms)
        .slideY(begin: 0.04, end: 0);
  }
}

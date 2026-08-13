import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:velvet_mobile/core/theme/velvet_theme.dart';
import 'package:velvet_mobile/core/theme/velvet_editorial_colors.dart';
import 'package:velvet_mobile/core/theme/velvet_tokens.dart';
import 'package:velvet_mobile/core/widgets/editorial_list_card.dart';
import 'package:velvet_mobile/core/widgets/velvet_editorial_sheet.dart';
import 'package:velvet_mobile/core/widgets/velvet_widgets.dart';
import 'package:velvet_mobile/core/widgets/velvet_image_carousel.dart';
import 'package:velvet_mobile/l10n/generated/app_localizations.dart';

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
  const ratios = [0.58, 0.78, 0.68, 0.88, 0.62, 0.74, 0.92, 0.66];
  return ratios[index % ratios.length];
}

/// Two-column Pinterest-style masonry grid.
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
    this.gutter = VelvetTokens.space10,
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

    return MasonryGridView.count(
      crossAxisCount: 2,
      mainAxisSpacing: gutter,
      crossAxisSpacing: gutter,
      padding: padding.copyWith(bottom: bottom),
      shrinkWrap: shrinkWrap,
      physics: physics ??
          const AlwaysScrollableScrollPhysics(
            parent: BouncingScrollPhysics(),
          ),
      itemCount: itemCount,
      itemBuilder: itemBuilder,
    );
  }
}

/// Sliver version for CustomScrollView / NestedScrollView headers.
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
    this.gutter = VelvetTokens.space10,
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
      sliver: SliverMasonryGrid.count(
        crossAxisCount: 2,
        mainAxisSpacing: gutter,
        crossAxisSpacing: gutter,
        childCount: itemCount,
        itemBuilder: itemBuilder,
      ),
    );
  }
}

class ListingCardData {
  const ListingCardData({
    required this.id,
    required this.name,
    this.age,
    this.city,
    this.bio,
    this.bioHeading,
    this.photoUrls = const [],
    this.subtitle,
    this.distanceKm,
    this.sessionRateEtb,
    this.overnightRateEtb,
    this.availabilityNote,
    this.verified = false,
    this.requestReason,
    this.notedPhotoUrl,
    this.trustScore,
  });

  final String id;
  final String name;
  final int? age;
  final String? city;
  final String? bio;
  final String? bioHeading;
  final List<String> photoUrls;
  final String? subtitle;
  final double? distanceKm;
  final int? sessionRateEtb;
  final int? overnightRateEtb;
  final String? availabilityNote;
  final bool verified;
  final String? requestReason;
  final String? notedPhotoUrl;
  final int? trustScore;
}

Future<void> showListingDetail(BuildContext context, ListingCardData listing) {
  final l10n = AppLocalizations.of(context);
  return showEditorialSheet<void>(
    context: context,
    initialSize: 0.88,
    maxSize: 0.96,
    builder: (context, scrollCtrl) {
      return CustomScrollView(
        controller: scrollCtrl,
        physics: const BouncingScrollPhysics(
          parent: AlwaysScrollableScrollPhysics(),
        ),
        slivers: [
          SliverToBoxAdapter(
            child: SizedBox(
              height: 360,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  if (listing.photoUrls.isNotEmpty)
                    VelvetImageCarousel(
                      photoUrls: listing.photoUrls,
                      aspectRatio: 0.75,
                      borderRadius: BorderRadius.zero,
                    )
                  else
                    Container(color: VelvetTokens.parchmentDeep),
                  DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          VelvetTokens.ink.withValues(alpha: 0.55),
                        ],
                        stops: const [0.55, 1],
                      ),
                    ),
                  ),
                  Positioned(
                    left: VelvetTokens.pageInset,
                    right: VelvetTokens.pageInset,
                    bottom: 24,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (listing.verified || (listing.trustScore ?? 0) >= 80)
                          Row(
                            children: [
                              if (listing.verified)
                                const VelvetVerifiedBadge(onDark: true),
                              if (listing.trustScore != null &&
                                  listing.trustScore! >= 80) ...[
                                const SizedBox(width: 8),
                                const VelvetTrustedBadge(compact: true),
                              ],
                            ],
                          ),
                        const SizedBox(height: 8),
                        Text(
                          listing.name,
                          style: GoogleFonts.syne(
                            color: Colors.white,
                            fontSize: 34,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -1.1,
                            height: 0.95,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          [
                            if (listing.age != null) '${listing.age}',
                            if (listing.city?.isNotEmpty == true) listing.city!,
                          ].join(' · '),
                          style: GoogleFonts.dmSans(
                            color: Colors.white.withValues(alpha: 0.85),
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(22, 20, 22, 40),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: [
                              if (listing.sessionRateEtb != null)
                                _RateChip(
                                  label: l10n.rateSessionLabel(
                                    listing.sessionRateEtb!,
                                  ),
                                ),
                              if (listing.overnightRateEtb != null)
                                _RateChip(
                                  label: l10n.rateOvernightLabel(
                                    listing.overnightRateEtb!,
                                  ),
                                ),
                              if (listing.availabilityNote?.isNotEmpty == true)
                                _RateChip(
                                  label: listing.availabilityNote!,
                                  icon: Icons.schedule_outlined,
                                ),
                              if (listing.distanceKm != null)
                                _RateChip(
                                  label: listing.distanceKm != null
                                      ? l10n.listingDistanceKm(
                                          listing.distanceKm!.round(),
                                        )
                                      : 'Nearby',
                                ),
                            ],
                          ),
                          if (listing.subtitle?.isNotEmpty == true) ...[
                            const SizedBox(height: 20),
                            Text(
                              listing.subtitle!,
                              style: Theme.of(context).textTheme.titleMedium
                                  ?.copyWith(
                                    color: VelvetTheme.teal,
                                    height: 1.4,
                                  ),
                            ),
                          ],
                          if (listing.bio?.isNotEmpty == true) ...[
                            const SizedBox(height: 24),
                            if (listing.bioHeading?.isNotEmpty == true)
                              Text(
                                listing.bioHeading!,
                                style: Theme.of(context).textTheme.titleSmall
                                    ?.copyWith(
                                      color: context.velvet.muted,
                                      letterSpacing: 0,
                                    ),
                              ),
                            const SizedBox(height: 8),
                            Text(
                              listing.bio!,
                              style: Theme.of(context).textTheme.bodyLarge
                                  ?.copyWith(
                                    height: 1.65,
                                    color: context.velvet.ink,
                                  ),
                            ),
                          ],
                        ]),
            ),
          ),
        ],
      );
    },
  );
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
        : l10n.rateSessionLabel(listing.sessionRateEtb!);
    final radius = listingTileRadius(index);
    final aspect = listingTileAspectRatio(index);
    final meta = [
      if (listing.city?.isNotEmpty == true) listing.city!,
      if (rateLabel != null) rateLabel,
    ].join(' · ');

    return Material(
          color: Colors.transparent,
          elevation: 0,
          child: InkWell(
            onTap: () => showListingDetail(context, listing),
            borderRadius: radius,
            child: Ink(
              decoration: BoxDecoration(
                borderRadius: radius,
                boxShadow: [
                  BoxShadow(
                    color: VelvetTokens.ink.withValues(alpha: 0.14),
                    blurRadius: 28,
                    spreadRadius: -6,
                    offset: const Offset(0, 14),
                  ),
                  BoxShadow(
                    color: VelvetTokens.ember.withValues(alpha: 0.06),
                    blurRadius: 40,
                    spreadRadius: -12,
                    offset: const Offset(0, 20),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: radius,
                child: AspectRatio(
                  aspectRatio: aspect,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      VelvetImageCarousel(
                        photoUrls: listing.photoUrls,
                        aspectRatio: aspect,
                        borderRadius: BorderRadius.zero,
                        showGradient: false,
                      ),
                      const DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Color(0x33000000),
                              Color(0x00000000),
                              Color(0x99000000),
                            ],
                            stops: [0, 0.38, 1],
                          ),
                        ),
                      ),
                      if (listing.verified)
                        Positioned(
                          top: 12,
                          right: 12,
                          child: _GlassChip(
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.verified_rounded,
                                  size: 14,
                                  color: Colors.white.withValues(alpha: 0.95),
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  'Verified',
                                  style: GoogleFonts.dmSans(
                                    color: Colors.white,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                    letterSpacing: 0.2,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      Positioned(
                        left: 12,
                        right: 56,
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
                                fontSize: 20,
                                fontWeight: FontWeight.w700,
                                letterSpacing: -0.6,
                                height: 1.05,
                                shadows: const [
                                  Shadow(
                                    color: Color(0x66000000),
                                    blurRadius: 12,
                                  ),
                                ],
                              ),
                            ),
                            if (meta.isNotEmpty) ...[
                              const SizedBox(height: 4),
                              Text(
                                meta,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: GoogleFonts.dmSans(
                                  color: Colors.white.withValues(alpha: 0.82),
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                      Positioned(
                        top: 10,
                        left: 10,
                        child: _OverlayIconButton(
                          icon: Icons.close_rounded,
                          onTap: loading ? null : onSkip,
                        ),
                      ),
                      Positioned(
                        bottom: 12,
                        right: 12,
                        child: _OverlayPrimaryIconButton(
                          loading: loading,
                          onTap: loading ? null : onRequest,
                          tooltip: l10n.requestBooking,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        )
        .animate()
        .fadeIn(delay: (28 * index).ms, duration: 320.ms)
        .slideY(begin: 0.05, end: 0, curve: Curves.easeOutCubic)
        .scale(
          begin: const Offset(0.97, 0.97),
          end: const Offset(1, 1),
          delay: (28 * index).ms,
          duration: 380.ms,
          curve: Curves.easeOutCubic,
        );
  }
}

class _GlassChip extends StatelessWidget {
  const _GlassChip({required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(999),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.16),
            borderRadius: BorderRadius.circular(999),
            border: Border.all(color: Colors.white.withValues(alpha: 0.28)),
          ),
          child: child,
        ),
      ),
    );
  }
}

class _OverlayIconButton extends StatelessWidget {
  const _OverlayIconButton({required this.icon, this.onTap});
  final IconData icon;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap == null
            ? null
            : () {
                HapticFeedback.selectionClick();
                onTap!();
              },
        customBorder: const CircleBorder(),
        child: Ink(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white.withValues(alpha: 0.16),
            border: Border.all(color: Colors.white.withValues(alpha: 0.28)),
          ),
          child: Icon(icon, color: Colors.white, size: 20),
        ),
      ),
    );
  }
}

class _OverlayPrimaryIconButton extends StatelessWidget {
  const _OverlayPrimaryIconButton({
    required this.onTap,
    required this.tooltip,
    this.loading = false,
  });

  final VoidCallback? onTap;
  final String tooltip;
  final bool loading;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap == null
              ? null
              : () {
                  HapticFeedback.mediumImpact();
                  onTap!();
                },
          customBorder: const CircleBorder(),
          child: Ink(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: VelvetTokens.ember,
              boxShadow: VelvetTokens.emberHalo(strength: 0.55),
            ),
            child: loading
                ? const Padding(
                    padding: EdgeInsets.all(12),
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: VelvetTokens.onPrimary,
                    ),
                  )
                : const Icon(
                    Icons.favorite_rounded,
                    color: VelvetTokens.onPrimary,
                    size: 22,
                  ),
          ),
        ),
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

    return EditorialRequestCard(
      index: index,
      eyebrow: l10n.segmentRequests,
      name: listing.name,
      age: listing.age,
      subtitle: listing.subtitle ?? l10n.clientRequestHint,
      photoUrls: listing.photoUrls,
      verified: listing.verified,
      loading: loading,
      acceptLabel: l10n.acceptRequest,
      declineLabel: l10n.declineRequest,
      onTap: () => showListingDetail(context, listing),
      onAccept: onAccept,
      onDecline: onDecline,
    )
        .animate()
        .fadeIn(delay: (40 * index).ms, duration: 280.ms)
        .slideY(begin: 0.04, end: 0);
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
    return EditorialRequestCard(
      index: index,
      eyebrow: l10n.segmentIntros,
      name: listing.name,
      age: listing.age,
      subtitle: listing.subtitle ?? l10n.clientRequestHint,
      photoUrls: listing.photoUrls,
      verified: listing.verified,
      accent: VelvetTokens.plumSoft,
      acceptLabel: l10n.acceptRequest,
      declineLabel: l10n.declineRequest,
      onTap: () => showListingDetail(context, listing),
      onAccept: onAccept,
      onDecline: onDecline,
    )
        .animate()
        .fadeIn(delay: (40 * index).ms, duration: 280.ms)
        .slideY(begin: 0.04, end: 0);
  }
}

class _RateChip extends StatelessWidget {
  const _RateChip({required this.label, this.icon});

  final String label;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: VelvetTheme.teal.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: VelvetTheme.teal.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 14, color: VelvetTheme.champagne),
            const SizedBox(width: 4),
          ],
          Flexible(
            child: Text(
              label,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: VelvetTheme.champagne,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:velvet_mobile/core/network/media_url.dart';
import 'package:velvet_mobile/core/theme/velvet_editorial_colors.dart';
import 'package:velvet_mobile/core/theme/velvet_tokens.dart';
import 'package:velvet_mobile/core/widgets/velvet_widgets.dart';
import 'package:velvet_mobile/l10n/generated/app_localizations.dart';

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
    this.jobTitle,
    this.languages,
    this.lookingFor,
    this.heightCm,
    this.interests = const [],
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
  final String? jobTitle;
  final String? languages;
  final String? lookingFor;
  final int? heightCm;
  final List<String> interests;
}

class ListingDetailActions {
  const ListingDetailActions({
    required this.primaryLabel,
    required this.onPrimary,
    required this.secondaryLabel,
    required this.onSecondary,
    this.loading = false,
  });

  final String primaryLabel;
  final VoidCallback onPrimary;
  final String secondaryLabel;
  final VoidCallback onSecondary;
  final bool loading;
}

Future<void> openListingDetail(
  BuildContext context,
  ListingCardData listing, {
  ListingDetailActions? actions,
}) {
  return Navigator.of(context, rootNavigator: true).push<void>(
    PageRouteBuilder<void>(
      opaque: true,
      transitionDuration: const Duration(milliseconds: 340),
      reverseTransitionDuration: const Duration(milliseconds: 260),
      pageBuilder: (context, animation, secondaryAnimation) {
        final curved = CurvedAnimation(
          parent: animation,
          curve: Curves.easeOutCubic,
          reverseCurve: Curves.easeInCubic,
        );
        return FadeTransition(
          opacity: curved,
          child: SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0, 0.04),
              end: Offset.zero,
            ).animate(curved),
            child: ListingDetailScreen(listing: listing, actions: actions),
          ),
        );
      },
    ),
  );
}

/// Full-screen listing — photo owns the page; details live under the fold.
class ListingDetailScreen extends StatefulWidget {
  const ListingDetailScreen({
    super.key,
    required this.listing,
    this.actions,
  });

  final ListingCardData listing;
  final ListingDetailActions? actions;

  @override
  State<ListingDetailScreen> createState() => _ListingDetailScreenState();
}

class _ListingDetailScreenState extends State<ListingDetailScreen> {
  late final PageController _pages;
  late final ScrollController _scroll;
  int _photoIndex = 0;

  ListingCardData get listing => widget.listing;

  @override
  void initState() {
    super.initState();
    _pages = PageController();
    _scroll = ScrollController();
  }

  @override
  void dispose() {
    _pages.dispose();
    _scroll.dispose();
    super.dispose();
  }

  void _goPhoto(int index) {
    if (index < 0 || index >= listing.photoUrls.length) return;
    HapticFeedback.selectionClick();
    _pages.animateToPage(
      index,
      duration: const Duration(milliseconds: 240),
      curve: Curves.easeOutCubic,
    );
  }

  void _run(VoidCallback action) {
    HapticFeedback.mediumImpact();
    Navigator.of(context).pop();
    action();
  }

  void _revealDetails() {
    HapticFeedback.selectionClick();
    final target = MediaQuery.sizeOf(context).height * 0.62;
    _scroll.animateTo(
      target,
      duration: const Duration(milliseconds: 420),
      curve: Curves.easeOutCubic,
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colors = context.velvet;
    final size = MediaQuery.sizeOf(context);
    final topInset = MediaQuery.paddingOf(context).top;
    final bottomInset = MediaQuery.paddingOf(context).bottom;
    final heroHeight = size.height * 0.78;
    final actions = widget.actions;
    final dockHeight = actions == null ? 0.0 : 72.0 + bottomInset + 16;

    final title = listing.age == null
        ? listing.name
        : '${listing.name}, ${listing.age}';
    final location = [
      if (listing.city?.isNotEmpty == true) listing.city!,
      if (listing.distanceKm != null)
        l10n.listingDistanceKm(listing.distanceKm!.round()),
    ].join('  ·  ');
    final rateHint = listing.sessionRateEtb != null
        ? l10n.listingEtbAmount(listing.sessionRateEtb!)
        : listing.overnightRateEtb != null
            ? l10n.listingEtbAmount(listing.overnightRateEtb!)
            : null;
    final facts = <String>[
      if (listing.jobTitle?.isNotEmpty == true) listing.jobTitle!,
      if (listing.languages?.isNotEmpty == true) listing.languages!,
      if (listing.lookingFor?.isNotEmpty == true) listing.lookingFor!,
      if (listing.heightCm != null) '${listing.heightCm} cm',
      ...listing.interests,
    ];

    return Scaffold(
      backgroundColor: colors.parchment,
      body: Stack(
        children: [
          CustomScrollView(
            controller: _scroll,
            physics: const BouncingScrollPhysics(
              parent: AlwaysScrollableScrollPhysics(),
            ),
            slivers: [
              SliverToBoxAdapter(
                child: SizedBox(
                  height: heroHeight,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      _PhotoStage(
                        photoUrls: listing.photoUrls,
                        controller: _pages,
                        index: _photoIndex,
                        onIndex: (i) => setState(() => _photoIndex = i),
                        onTapSide: _goPhoto,
                      ),
                      const IgnorePointer(
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Color(0x99000000),
                                Color(0x00000000),
                                Color(0x00000000),
                                Color(0xCC000000),
                              ],
                              stops: [0, 0.18, 0.48, 1],
                            ),
                          ),
                        ),
                      ),
                      if (listing.photoUrls.length > 1)
                        Positioned(
                          top: topInset + 14,
                          left: 64,
                          right: 20,
                          child: _StoryTicks(
                            count: listing.photoUrls.length,
                            index: _photoIndex,
                          ),
                        ),
                      Positioned(
                        left: 20,
                        right: 20,
                        bottom: 28,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (listing.verified ||
                                (listing.trustScore ?? 0) >= 80)
                              Padding(
                                padding: const EdgeInsets.only(bottom: 12),
                                child: Row(
                                  children: [
                                    if (listing.verified)
                                      const VelvetVerifiedBadge(onDark: true),
                                    if (listing.verified &&
                                        (listing.trustScore ?? 0) >= 80)
                                      const SizedBox(width: 8),
                                    if ((listing.trustScore ?? 0) >= 80)
                                      const VelvetTrustedBadge(
                                        compact: true,
                                        onDark: true,
                                      ),
                                  ],
                                ),
                              ),
                            Text(
                              title,
                              style: GoogleFonts.syne(
                                fontSize: 40,
                                fontWeight: FontWeight.w800,
                                letterSpacing: -1.4,
                                height: 0.94,
                                color: Colors.white,
                              ),
                            )
                                .animate()
                                .fadeIn(duration: 360.ms)
                                .slideY(begin: 0.08, end: 0),
                            if (location.isNotEmpty) ...[
                              const SizedBox(height: 10),
                              Text(
                                location,
                                style: GoogleFonts.dmSans(
                                  color: Colors.white.withValues(alpha: 0.82),
                                  fontSize: 15,
                                  fontWeight: FontWeight.w500,
                                  height: 1.3,
                                ),
                              ),
                            ],
                            if (rateHint != null ||
                                listing.subtitle?.isNotEmpty == true) ...[
                              const SizedBox(height: 16),
                              Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                children: [
                                  if (rateHint != null)
                                    _HeroPill(
                                      label: rateHint,
                                      accent: true,
                                    ),
                                  if (listing.subtitle?.isNotEmpty == true)
                                    _HeroPill(label: listing.subtitle!),
                                ],
                              ),
                            ],
                            const SizedBox(height: 18),
                            GestureDetector(
                              onTap: _revealDetails,
                              child: Row(
                                children: [
                                  Text(
                                    l10n.listingAbout,
                                    style: GoogleFonts.dmSans(
                                      color: VelvetTokens.ember,
                                      fontSize: 13,
                                      fontWeight: FontWeight.w700,
                                      letterSpacing: 0.4,
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  const Icon(
                                    Icons.keyboard_arrow_down_rounded,
                                    color: VelvetTokens.ember,
                                    size: 20,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(
                    24,
                    28,
                    24,
                    28 + dockHeight,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (listing.sessionRateEtb != null ||
                          listing.overnightRateEtb != null) ...[
                        Text(
                          l10n.performerRatesSection,
                          style: GoogleFonts.dmSans(
                            color: VelvetTokens.ember,
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.8,
                          ),
                        ),
                        const SizedBox(height: 14),
                        _PriceBand(
                          sessionLabel: l10n.listingSession,
                          overnightLabel: l10n.listingOvernight,
                          sessionAmount: listing.sessionRateEtb == null
                              ? null
                              : l10n.listingEtbAmount(listing.sessionRateEtb!),
                          overnightAmount: listing.overnightRateEtb == null
                              ? null
                              : l10n.listingEtbAmount(
                                  listing.overnightRateEtb!,
                                ),
                        ),
                        const SizedBox(height: 28),
                      ],
                      if (listing.availabilityNote?.isNotEmpty == true) ...[
                        Text(
                          l10n.availabilityNote,
                          style: GoogleFonts.dmSans(
                            color: VelvetTokens.ember,
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.8,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          listing.availabilityNote!,
                          style: GoogleFonts.dmSans(
                            color: colors.ink,
                            fontSize: 16,
                            height: 1.45,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 28),
                      ],
                      if (listing.bio?.isNotEmpty == true) ...[
                        Text(
                          listing.bioHeading?.isNotEmpty == true
                              ? listing.bioHeading!
                              : l10n.listingAbout,
                          style: GoogleFonts.dmSans(
                            color: VelvetTokens.ember,
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.8,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          listing.bio!,
                          style: GoogleFonts.dmSans(
                            color: colors.ink,
                            fontSize: 17,
                            height: 1.55,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                        const SizedBox(height: 28),
                      ],
                      if (facts.isNotEmpty) ...[
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            for (final fact in facts)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 8,
                                ),
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color: colors.line.withValues(alpha: 0.8),
                                  ),
                                  borderRadius: BorderRadius.circular(999),
                                ),
                                child: Text(
                                  fact,
                                  style: GoogleFonts.dmSans(
                                    color: colors.muted,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ),
          Positioned(
            top: topInset + 8,
            left: 16,
            child: _ChromeButton(
              icon: Icons.close_rounded,
              tooltip: l10n.listingClose,
              onTap: () => Navigator.of(context).pop(),
            ),
          ),
          if (actions != null)
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: _ActionDock(
                actions: actions,
                onPrimary: () => _run(actions.onPrimary),
                onSecondary: () => _run(actions.onSecondary),
              ),
            ),
        ],
      ),
    );
  }
}

class _PhotoStage extends StatelessWidget {
  const _PhotoStage({
    required this.photoUrls,
    required this.controller,
    required this.index,
    required this.onIndex,
    required this.onTapSide,
  });

  final List<String> photoUrls;
  final PageController controller;
  final int index;
  final ValueChanged<int> onIndex;
  final void Function(int index) onTapSide;

  @override
  Widget build(BuildContext context) {
    if (photoUrls.isEmpty) {
      return ColoredBox(
        color: VelvetTokens.parchmentDeep,
        child: Center(
          child: Icon(
            Icons.person_outline,
            size: 64,
            color: Colors.white.withValues(alpha: 0.28),
          ),
        ),
      );
    }

    return PageView.builder(
      controller: controller,
      onPageChanged: onIndex,
      itemCount: photoUrls.length,
      itemBuilder: (context, i) {
        return GestureDetector(
          onTapUp: (details) {
            final dx = details.localPosition.dx;
            final w = MediaQuery.sizeOf(context).width;
            if (dx < w * 0.35) {
              onTapSide(i - 1);
            } else if (dx > w * 0.65) {
              onTapSide(i + 1);
            }
          },
          child: Image.network(
            resolveMediaUrl(photoUrls[i]),
            fit: BoxFit.cover,
            gaplessPlayback: true,
            loadingBuilder: (context, child, progress) {
              if (progress == null) return child;
              return const ColoredBox(color: VelvetTokens.parchmentDeep);
            },
            errorBuilder: (_, _, _) => ColoredBox(
              color: VelvetTokens.parchmentDeep,
              child: Icon(
                Icons.broken_image_outlined,
                color: Colors.white.withValues(alpha: 0.28),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _StoryTicks extends StatelessWidget {
  const _StoryTicks({required this.count, required this.index});

  final int count;
  final int index;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        for (var i = 0; i < count; i++) ...[
          if (i > 0) const SizedBox(width: 4),
          Expanded(
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              height: 2.5,
              decoration: BoxDecoration(
                color: i <= index
                    ? Colors.white
                    : Colors.white.withValues(alpha: 0.28),
                borderRadius: BorderRadius.circular(99),
              ),
            ),
          ),
        ],
      ],
    );
  }
}

class _HeroPill extends StatelessWidget {
  const _HeroPill({required this.label, this.accent = false});

  final String label;
  final bool accent;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(999),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: accent
                ? VelvetTokens.ember.withValues(alpha: 0.92)
                : Colors.white.withValues(alpha: 0.14),
            borderRadius: BorderRadius.circular(999),
            border: accent
                ? null
                : Border.all(color: Colors.white.withValues(alpha: 0.18)),
          ),
          child: Text(
            label,
            style: GoogleFonts.dmSans(
              color: accent ? VelvetTokens.onPrimary : Colors.white,
              fontSize: 13,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ),
    );
  }
}

class _PriceBand extends StatelessWidget {
  const _PriceBand({
    required this.sessionLabel,
    required this.overnightLabel,
    required this.sessionAmount,
    required this.overnightAmount,
  });

  final String sessionLabel;
  final String overnightLabel;
  final String? sessionAmount;
  final String? overnightAmount;

  @override
  Widget build(BuildContext context) {
    final colors = context.velvet;
    final items = <({String label, String amount})>[
      if (sessionAmount != null) (label: sessionLabel, amount: sessionAmount!),
      if (overnightAmount != null)
        (label: overnightLabel, amount: overnightAmount!),
    ];

    return Row(
      children: [
        for (var i = 0; i < items.length; i++) ...[
          if (i > 0) ...[
            Container(
              width: 1,
              height: 36,
              margin: const EdgeInsets.symmetric(horizontal: 18),
              color: colors.line,
            ),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  items[i].label,
                  style: GoogleFonts.dmSans(
                    color: colors.muted,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  items[i].amount,
                  style: GoogleFonts.syne(
                    color: colors.ink,
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.6,
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}

class _ChromeButton extends StatelessWidget {
  const _ChromeButton({
    required this.icon,
    required this.onTap,
    required this.tooltip,
  });

  final IconData icon;
  final VoidCallback onTap;
  final String tooltip;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: ClipOval(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
          child: Material(
            color: Colors.black.withValues(alpha: 0.32),
            shape: const CircleBorder(),
            child: InkWell(
              customBorder: const CircleBorder(),
              onTap: () {
                HapticFeedback.selectionClick();
                onTap();
              },
              child: SizedBox(
                width: 44,
                height: 44,
                child: Icon(icon, color: Colors.white, size: 22),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ActionDock extends StatelessWidget {
  const _ActionDock({
    required this.actions,
    required this.onPrimary,
    required this.onSecondary,
  });

  final ListingDetailActions actions;
  final VoidCallback onPrimary;
  final VoidCallback onSecondary;

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.paddingOf(context).bottom;
    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 22, sigmaY: 22),
        child: Container(
          padding: EdgeInsets.fromLTRB(20, 14, 20, 14 + bottom),
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.78),
            border: Border(
              top: BorderSide(color: Colors.white.withValues(alpha: 0.08)),
            ),
          ),
          child: Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: actions.loading ? null : onSecondary,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.white,
                    side: BorderSide(
                      color: Colors.white.withValues(alpha: 0.28),
                    ),
                    minimumSize: const Size.fromHeight(54),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(999),
                    ),
                  ),
                  child: Text(actions.secondaryLabel),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                flex: 2,
                child: FilledButton(
                  onPressed: actions.loading ? null : onPrimary,
                  style: FilledButton.styleFrom(
                    backgroundColor: VelvetTokens.ember,
                    foregroundColor: VelvetTokens.onPrimary,
                    minimumSize: const Size.fromHeight(54),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(999),
                    ),
                  ),
                  child: actions.loading
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: VelvetTokens.onPrimary,
                          ),
                        )
                      : Text(actions.primaryLabel),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

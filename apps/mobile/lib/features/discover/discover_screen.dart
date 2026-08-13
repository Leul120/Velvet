import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:velvet_mobile/core/location/location_helper.dart';
import 'package:velvet_mobile/core/network/dio_client.dart';
import 'package:velvet_mobile/core/theme/velvet_editorial_colors.dart';
import 'package:velvet_mobile/core/theme/velvet_theme.dart';
import 'package:velvet_mobile/core/widgets/velvet_feedback.dart';
import 'package:velvet_mobile/core/widgets/velvet_widgets.dart';
import 'package:velvet_mobile/core/widgets/kinetic_text.dart';
import 'package:velvet_mobile/core/theme/velvet_tokens.dart';
import 'package:velvet_mobile/core/widgets/marketplace_flow_hint.dart';
import 'package:velvet_mobile/features/auth/auth_controller.dart';
import 'package:velvet_mobile/features/auth/role_helpers.dart';
import 'package:velvet_mobile/features/discover/discover_api.dart';
import 'package:velvet_mobile/features/discover/filters_sheet.dart';
import 'package:velvet_mobile/features/discover/listing_catalog.dart';
import 'package:velvet_mobile/features/connections/connections_api.dart';
import 'package:velvet_mobile/features/onboarding/onboarding_prefs.dart';
import 'package:velvet_mobile/features/notifications/notifications_api.dart';
import 'package:velvet_mobile/features/profile/profile_api.dart';
import 'package:velvet_mobile/l10n/generated/app_localizations.dart';

class DiscoverScreen extends ConsumerStatefulWidget {
  const DiscoverScreen({super.key});

  @override
  ConsumerState<DiscoverScreen> createState() => _DiscoverScreenState();
}

class _DiscoverScreenState extends ConsumerState<DiscoverScreen> {
  /// 0 = primary lane (Listings for clients / Requests for performers), 1 = Concierge open
  int _segment = 0;
  bool _located = false;
  String? _actingOnId;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _pingLocation());
  }

  Future<void> _pingLocation() async {
    if (_located) return;
    _located = true;
    try {
      final pos = await LocationHelper.currentOrNull();
      if (pos == null) return;
      await ref
          .read(discoverApiProvider)
          .updateLocation(latitude: pos.latitude, longitude: pos.longitude);
      ref.invalidate(discoverFeedProvider);
    } catch (_) {}
  }

  Future<void> _openConnectionConfirmed({
    required String connectionId,
    String? name,
    List<String> photos = const [],
    String? otherUserId,
  }) async {
    if (!mounted) return;
    final q = <String, String>{
      'name': ?name,
      if (photos.isNotEmpty) 'photo': photos.first,
      'other': ?otherUserId,
    };
    final query = q.entries
        .map((e) => '${e.key}=${Uri.encodeComponent(e.value)}')
        .join('&');
    context.push(
      '/connection/$connectionId/confirmed${query.isEmpty ? '' : '?$query'}',
    );
  }

  ListingCardData _fromDiscoverCard(
    DiscoverCard c,
    AppLocalizations l10n,
    String locale,
  ) {
    return ListingCardData(
      id: c.userId,
      name: c.displayName ?? l10n.someoneLabel,
      age: c.age,
      city: c.city,
      bio: locale == 'am' ? (c.bioAm ?? c.bioEn) : (c.bioEn ?? c.bioAm),
      bioHeading: locale == 'am' ? l10n.promptListingAm : l10n.promptListingEn,
      photoUrls: c.photoUrls,
      distanceKm: c.distanceKm,
      sessionRateEtb: c.sessionRateEtb,
      overnightRateEtb: c.overnightRateEtb,
      availabilityNote: c.availabilityNote,
      verified: c.verified,
      trustScore: c.trustScore,
      subtitle: switch (c.likeReason) {
        'PROMPT' => l10n.requestNotedPrompt,
        'PHOTO' => l10n.requestNotedPhoto,
        _ => c.likeReason == null ? null : l10n.clientRequestHint,
      },
      requestReason: c.likeReason,
      notedPhotoUrl: c.likedPhotoUrl,
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final unread = ref.watch(unreadNotificationsProvider);
    final unreadCount = unread.asData?.value ?? 0;
    final auth = ref.watch(authControllerProvider);
    final me = ref.watch(meProfileProvider);
    final gender = effectiveGender(auth.user, me.asData?.value.gender);
    final isPerformer = isPerformerRole(auth.user?.role);
    final isMan = isManGender(gender);
    final locale = Localizations.localeOf(context).languageCode;

    final title = isPerformer ? l10n.segmentRequests : l10n.segmentListings;
    final primaryLabel = isPerformer
        ? l10n.segmentRequests
        : l10n.segmentListings;
    final onboarding = ref.watch(onboardingPrefsProvider);
    final showCoach =
        isMan &&
        _segment == 0 &&
        onboarding.loaded &&
        !onboarding.discoverCoachSeen;

    return VelvetScaffold(
      mistIntensity: 0.2,
      safeArea: true,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(
              VelvetTokens.pageInset,
              VelvetTokens.space24,
              VelvetTokens.pageInset,
              VelvetTokens.space12,
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      KineticEyebrow(
                        label: isPerformer ? l10n.navRequests : l10n.navBrowse,
                        icon: Icons.auto_awesome_outlined,
                      ),
                      const SizedBox(height: VelvetTokens.space8),
                      KineticText(
                        text: title,
                        splitLines: title.contains('\n'),
                        style: GoogleFonts.syne(
                          fontSize: VelvetTokens.displayLarge,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -1.6,
                          height: 0.92,
                          color: context.velvet.ink,
                        ),
                      ),
                      const SizedBox(height: VelvetTokens.space8),
                      Text(
                        isPerformer
                            ? l10n.discoverSubtitlePerformer
                            : isMan
                            ? l10n.discoverSubtitleClient
                            : l10n.discoverSubtitleLocked,
                        style: GoogleFonts.dmSans(
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                          color: context.velvet.muted,
                          height: 1.45,
                        ),
                      ),
                    ],
                  ),
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (!isPerformer) ...[
                      VelvetIconChip(
                        icon: Icons.tune_rounded,
                        onTap: () async {
                          await showFiltersSheet(context, ref);
                          ref.invalidate(discoverFeedProvider);
                        },
                      ),
                      const SizedBox(width: 8),
                    ],
                    VelvetIconChip(
                      icon: Icons.notifications_none_rounded,
                      badgeCount: unreadCount,
                      onTap: () => context.push('/notifications'),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
            child: VelvetSegmentedControl(
              labels: [primaryLabel, l10n.segmentIntros],
              index: _segment,
              onChanged: (i) => setState(() => _segment = i),
            ),
          ),
          if (showCoach)
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
              child: DiscoverCoachBanner(
                title: l10n.discoverCoachTitle,
                body: l10n.discoverCoachBody,
                onDismiss: () => ref
                    .read(onboardingPrefsProvider.notifier)
                    .markDiscoverCoachSeen(),
              ),
            ),
          Expanded(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 280),
              child: KeyedSubtree(
                key: ValueKey('${isPerformer ? 'w' : 'm'}-$_segment'),
                child: _segment == 1
                    ? _conciergeList(l10n, locale)
                    : (isPerformer
                        ? _requestsList(l10n, locale)
                        : _listingsList(l10n, locale, !isPerformer)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _conciergeList(AppLocalizations l10n, String locale) {
    final matches = ref.watch(conciergeIntrosProvider);
    return matches.when(
      loading: () => const VelvetContentLoading(count: 2),
      error: (e, _) => VelvetEmptyState(
        message: apiErrorMessage(e),
        icon: Icons.handshake_outlined,
        actionLabel: l10n.retry,
        onAction: () => ref.invalidate(conciergeIntrosProvider),
      ),
      data: (items) {
        final open = items
            .where((m) => m.awaitingMyResponse && !m.mutual)
            .toList();

        if (open.isEmpty) {
          return VelvetEmptyState(
            message: l10n.introsEmpty,
            icon: Icons.handshake_outlined,
            actionLabel: l10n.introsEmptyCta,
            onAction: () => context.push('/profile'),
          );
        }

        return RefreshIndicator(
          color: VelvetTheme.teal,
          onRefresh: () async {
            ref.invalidate(conciergeIntrosProvider);
            await ref.read(conciergeIntrosProvider.future);
          },
          child: ListView.separated(
            padding: EdgeInsets.fromLTRB(
              16,
              0,
              16,
              96 + MediaQuery.paddingOf(context).bottom,
            ),
            itemCount: open.length,
            separatorBuilder: (_, _) => const SizedBox(height: 12),
            itemBuilder: (context, i) {
              final m = open[i];
              final listing = ListingCardData(
                id: m.id,
                name: m.counterpartDisplayName ?? l10n.someoneLabel,
                age: m.counterpartAge,
                city: m.counterpartCity,
                bio: locale == 'am'
                    ? (m.counterpartBioAm ?? m.counterpartBioEn)
                    : (m.counterpartBioEn ?? m.counterpartBioAm),
                photoUrls: m.counterpartPhotoUrls,
                subtitle: locale == 'am'
                    ? (m.introNoteAm ?? m.introNoteEn)
                    : (m.introNoteEn ?? m.introNoteAm),
                verified: m.counterpartVerified,
                trustScore: m.counterpartTrustScore,
              );
              return ConciergeIntroTile(
                listing: listing,
                index: i,
                onAccept: () async {
                  final result = await ref
                      .read(connectionsApiProvider)
                      .decide(id: m.id, action: 'ACCEPT');
                  ref.invalidate(conciergeIntrosProvider);
                  ref.invalidate(conversationsProvider);
                  if (result.becameMutual || result.mutual) {
                    await _openConnectionConfirmed(
                      connectionId: result.id,
                      name: result.counterpartDisplayName,
                      photos: result.counterpartPhotoUrls,
                      otherUserId: result.counterpartUserId,
                    );
                  }
                },
                onDecline: () async {
                  await ref
                      .read(connectionsApiProvider)
                      .decide(id: m.id, action: 'DECLINE');
                  ref.invalidate(conciergeIntrosProvider);
                },
              );
            },
          ),
        );
      },
    );
  }

  Widget _listingsList(AppLocalizations l10n, String locale, bool isMan) {
    if (!isMan) {
      return VelvetEmptyState(
        message: l10n.womenReceiveOnly,
        icon: Icons.inbox_outlined,
        actionLabel: l10n.segmentRequests,
        onAction: () => setState(() => _segment = 0),
      );
    }
    final feed = ref.watch(discoverFeedProvider);
    return feed.when(
      loading: () => const VelvetContentLoading(count: 2),
      error: (e, _) {
        final code = apiErrorCode(e);
        final isSub =
            code == 'SUBSCRIPTION_REQUIRED' ||
            apiErrorMessage(e).contains('SUBSCRIPTION_REQUIRED') ||
            apiErrorMessage(e).toLowerCase().contains('subscription');
        if (isSub) {
          return VelvetEmptyState(
            message: l10n.membershipRequiredBrowse,
            icon: Icons.workspace_premium_outlined,
            actionLabel: l10n.navMembership,
            onAction: () => context.go('/membership'),
          );
        }
        return VelvetEmptyState(
          message: apiErrorMessage(e),
          icon: Icons.storefront_outlined,
          actionLabel: l10n.retry,
          onAction: () => ref.invalidate(discoverFeedProvider),
        );
      },
      data: (feedData) {
        if (feedData.mode == 'GENDER_REQUIRED') {
          return VelvetEmptyState(
            message: l10n.genderRequiredHint,
            icon: Icons.person_outline_rounded,
            actionLabel: l10n.profile,
            onAction: () => context.push('/profile'),
          );
        }
        if (feedData.items.isEmpty) {
          return VelvetEmptyState(
            message: l10n.discoverEmpty,
            icon: Icons.storefront_outlined,
            flowSteps: _clientBrowseFlow(l10n),
            actionLabel: l10n.discoverEmptyCta,
            onAction: () async {
              await showFiltersSheet(context, ref);
              ref.invalidate(discoverFeedProvider);
            },
            secondaryLabel: l10n.segmentIntros,
            onSecondary: () => setState(() => _segment = 1),
          );
        }

        return RefreshIndicator(
          color: VelvetTheme.teal,
          onRefresh: () async {
            ref.invalidate(discoverFeedProvider);
            await ref.read(discoverFeedProvider.future);
          },
          child: AsymmetricListingGrid(
            itemCount: feedData.items.length,
            itemBuilder: (itemContext, i) {
              final c = feedData.items[i];
              final listing = _fromDiscoverCard(c, l10n, locale);
              final acting = _actingOnId == c.userId;
              return PerformerListingTile(
                listing: listing,
                index: i,
                loading: acting,
                onRequest: () async {
                  setState(() => _actingOnId = c.userId);
                  try {
                    final result = await ref
                        .read(discoverApiProvider)
                        .action(userId: c.userId, action: 'LIKE');
                    ref.invalidate(discoverFeedProvider);
                    ref.invalidate(conversationsProvider);
                    if (!itemContext.mounted) return;
                    await showVelvetToast(
                      itemContext,
                      message: l10n.interestSent,
                      icon: Icons.favorite_outline_rounded,
                    );
                    if (result.mutual && result.connectionId != null) {
                      await _openConnectionConfirmed(
                        connectionId: result.connectionId!,
                        name: result.counterpartDisplayName ?? listing.name,
                        photos: result.counterpartPhotoUrls,
                        otherUserId: c.userId,
                      );
                    }
                  } catch (e) {
                    if (itemContext.mounted) {
                      showVelvetErrorToast(itemContext, message: apiErrorMessage(e));
                    }
                  } finally {
                    if (mounted) setState(() => _actingOnId = null);
                  }
                },
                onSkip: () async {
                  setState(() => _actingOnId = c.userId);
                  try {
                    await ref
                        .read(discoverApiProvider)
                        .action(userId: c.userId, action: 'PASS');
                    ref.invalidate(discoverFeedProvider);
                    ref.invalidate(recentPassesProvider);
                  } catch (e) {
                    if (itemContext.mounted) {
                      showVelvetErrorToast(itemContext, message: apiErrorMessage(e));
                    }
                  } finally {
                    if (mounted) setState(() => _actingOnId = null);
                  }
                },
              );
            },
          ),
        );
      },
    );
  }

  Widget _requestsList(AppLocalizations l10n, String locale) {
    final feed = ref.watch(receivedRequestsProvider);
    return feed.when(
      loading: () => const VelvetContentLoading(count: 2),
      error: (e, _) => VelvetEmptyState(
        message: apiErrorMessage(e),
        icon: Icons.inbox_outlined,
        actionLabel: l10n.retry,
        onAction: () => ref.invalidate(discoverFeedProvider),
      ),
      data: (feedData) {
        if (feedData.items.isEmpty) {
          return VelvetEmptyState(
            message: l10n.clientRequestsEmpty,
            icon: Icons.inbox_outlined,
            flowSteps: [
              MarketplaceFlowStep(
                icon: Icons.inbox_outlined,
                label: l10n.flowHintRespond,
              ),
              MarketplaceFlowStep(
                icon: Icons.forum_outlined,
                label: l10n.navConversations,
              ),
              MarketplaceFlowStep(
                icon: Icons.event_available_outlined,
                label: l10n.flowHintBook,
              ),
            ],
            actionLabel: l10n.clientRequestsEmptyCta,
            onAction: () => setState(() => _segment = 1),
          );
        }

        return RefreshIndicator(
          color: VelvetTheme.teal,
          onRefresh: () async {
            ref.invalidate(receivedRequestsProvider);
            await ref.read(receivedRequestsProvider.future);
          },
          child: AsymmetricListingGrid(
            itemCount: feedData.items.length,
            itemBuilder: (itemContext, i) {
              final c = feedData.items[i];
              final listing = _fromDiscoverCard(c, l10n, locale);
              final acting = _actingOnId == c.userId;
              return BookingRequestTile(
                listing: listing,
                index: i,
                loading: acting,
                onAccept: () async {
                  setState(() => _actingOnId = c.userId);
                  try {
                    final result = await ref
                        .read(discoverApiProvider)
                        .action(userId: c.userId, action: 'LIKE');
                    ref.invalidate(receivedRequestsProvider);
                    ref.invalidate(conversationsProvider);
                    if (result.mutual && result.connectionId != null) {
                      await _openConnectionConfirmed(
                        connectionId: result.connectionId!,
                        name: result.counterpartDisplayName,
                        photos: result.counterpartPhotoUrls,
                        otherUserId: c.userId,
                      );
                    }
                  } catch (e) {
                    if (itemContext.mounted) {
                      showVelvetErrorToast(itemContext, message: apiErrorMessage(e));
                    }
                  } finally {
                    if (mounted) setState(() => _actingOnId = null);
                  }
                },
                onDecline: () async {
                  setState(() => _actingOnId = c.userId);
                  try {
                    await ref
                        .read(discoverApiProvider)
                        .action(userId: c.userId, action: 'PASS');
                    ref.invalidate(receivedRequestsProvider);
                  } catch (e) {
                    if (itemContext.mounted) {
                      showVelvetErrorToast(itemContext, message: apiErrorMessage(e));
                    }
                  } finally {
                    if (mounted) setState(() => _actingOnId = null);
                  }
                },
              );
            },
          ),
        );
      },
    );
  }

  List<MarketplaceFlowStep> _clientBrowseFlow(AppLocalizations l10n) => [
    MarketplaceFlowStep(
      icon: Icons.storefront_outlined,
      label: l10n.flowHintBrowse,
    ),
    MarketplaceFlowStep(icon: Icons.send_outlined, label: l10n.flowHintRequest),
    MarketplaceFlowStep(
      icon: Icons.event_available_outlined,
      label: l10n.flowHintBook,
    ),
  ];
}

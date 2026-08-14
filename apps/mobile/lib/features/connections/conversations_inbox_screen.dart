import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:velvet_mobile/core/network/dio_client.dart';
import 'package:velvet_mobile/core/network/media_url.dart';
import 'package:velvet_mobile/core/theme/velvet_theme.dart';
import 'package:velvet_mobile/core/theme/velvet_editorial_colors.dart';
import 'package:velvet_mobile/core/widgets/kinetic_text.dart';
import 'package:velvet_mobile/core/theme/velvet_tokens.dart';
import 'package:velvet_mobile/core/widgets/editorial_list_card.dart';
import 'package:velvet_mobile/core/widgets/velvet_widgets.dart';
import 'package:velvet_mobile/core/widgets/marketplace_flow_hint.dart';
import 'package:velvet_mobile/features/auth/auth_controller.dart';
import 'package:velvet_mobile/features/connections/connections_api.dart';
import 'package:velvet_mobile/l10n/generated/app_localizations.dart';

class ConversationsInboxScreen extends ConsumerWidget {
  const ConversationsInboxScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final mutual = ref.watch(conversationsProvider);
    final isWoman = ref.watch(authControllerProvider).user?.gender == 'FEMALE';

    return VelvetScaffold(
      mistIntensity: 0.7,
      safeArea: true,
      extendBody: true,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(
              VelvetTokens.pageInset,
              VelvetTokens.space24,
              VelvetTokens.pageInset,
              VelvetTokens.space8,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                KineticEyebrow(
                  label: l10n.navConversations,
                  icon: Icons.forum_outlined,
                ),
                const SizedBox(height: VelvetTokens.space8),
                KineticText(
                  text: l10n.conversationsInboxTitle,
                  style: GoogleFonts.syne(
                    fontSize: VelvetTokens.displayMedium,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -1.3,
                    height: 0.95,
                    color: context.velvet.ink,
                  ),
                ),
                const SizedBox(height: VelvetTokens.space8),
                Text(
                  l10n.conversationsInboxHint,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: context.velvet.muted,
                    height: 1.45,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: mutual.when(
              loading: () => const VelvetContentLoading(),
              error: (e, _) => Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        apiErrorMessage(e),
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: VelvetTheme.danger),
                      ),
                      const SizedBox(height: 12),
                      TextButton.icon(
                        onPressed: () => ref.invalidate(conversationsProvider),
                        icon: const Icon(Icons.refresh_rounded),
                        label: Text(l10n.retry),
                      ),
                    ],
                  ),
                ),
              ),
              data: (items) {
                final ordered = [...items]
                  ..sort((a, b) {
                    final aScore =
                        (a.turn == 'YOUR_TURN' ? 2 : 0) +
                        (a.unreadCount > 0 ? 1 : 0);
                    final bScore =
                        (b.turn == 'YOUR_TURN' ? 2 : 0) +
                        (b.unreadCount > 0 ? 1 : 0);
                    return bScore.compareTo(aScore);
                  });
                final turnsWaiting = items
                    .where((item) => item.turn == 'YOUR_TURN')
                    .length;
                final unreadTotal = items.fold<int>(
                  0,
                  (total, item) => total + item.unreadCount,
                );
                return RefreshIndicator(
                  color: VelvetTokens.ember,
                  onRefresh: () async {
                    ref.invalidate(conversationsProvider);
                    await ref.read(conversationsProvider.future);
                  },
                  child: ListView.separated(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: EdgeInsets.fromLTRB(
                      20,
                      16,
                      20,
                      100 + MediaQuery.paddingOf(context).bottom,
                    ),
                    itemCount: items.isEmpty ? 1 : ordered.length + 1,
                    separatorBuilder: (_, _) => const SizedBox(height: 18),
                    itemBuilder: (context, index) {
                      if (items.isEmpty) {
                        return Padding(
                          padding: const EdgeInsets.only(top: 48),
                          child: VelvetEmptyState(
                            title: l10n.conversationsInboxTitle,
                            message: isWoman
                                ? l10n.conversationsInboxEmpty
                                : l10n.conversationsEmptyFlowHint,
                            icon: Icons.forum_outlined,
                            flowSteps: isWoman
                                ? null
                                : [
                                    MarketplaceFlowStep(
                                      icon: Icons.storefront_outlined,
                                      label: l10n.flowHintBrowse,
                                    ),
                                    MarketplaceFlowStep(
                                      icon: Icons.send_outlined,
                                      label: l10n.flowHintRequest,
                                    ),
                                    MarketplaceFlowStep(
                                      icon: Icons.forum_outlined,
                                      label: l10n.navConversations,
                                    ),
                                  ],
                            actionLabel: isWoman
                                ? l10n.conversationsInboxEmptyCtaRequests
                                : l10n.conversationsInboxEmptyCtaDiscover,
                            onAction: () => context.go('/discover'),
                          ),
                        );
                      }
                      if (index == 0) {
                        return _InboxPulse(
                          turnsWaiting: turnsWaiting,
                          unreadTotal: unreadTotal,
                          l10n: l10n,
                        );
                      }
                      final m = ordered[index - 1];
                      final photo = m.counterpartPhotoUrls.isNotEmpty
                          ? resolveMediaUrl(m.counterpartPhotoUrls.first)
                          : null;
                      final yourTurn = m.turn == 'YOUR_TURN';
                      final preview =
                          m.lastMessagePreview ??
                          l10n.conversationsEmptyPreview;
                      final chatRoute =
                          '/chat/${m.id}?other=${Uri.encodeComponent(m.counterpartUserId ?? '')}'
                          '&verified=${m.counterpartVerified}'
                          '&trustScore=${m.counterpartTrustScore ?? ''}'
                          '&name=${Uri.encodeComponent(m.counterpartDisplayName ?? '')}';

                      return EditorialInboxCard(
                        index: index - 1,
                        name: m.counterpartDisplayName ?? l10n.someoneLabel,
                        preview: preview,
                        yourTurn: yourTurn,
                        unreadCount: m.unreadCount,
                        verified: m.counterpartVerified,
                        photoUrl: photo,
                        openChatLabel: l10n.openChat,
                        replyLabel: l10n.replyNow,
                        turnLabel: yourTurn ? l10n.yourTurn : l10n.theirTurn,
                        onTap: () => context.push(chatRoute),
                        onOpenChat: () => context.push(chatRoute),
                        onBook: () => context.push('/booking/${m.id}'),
                      ).animate().fadeIn(delay: (40 * index).ms, duration: 280.ms).slideY(begin: 0.06, end: 0, curve: Curves.easeOutCubic);
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _InboxPulse extends StatelessWidget {
  const _InboxPulse({
    required this.turnsWaiting,
    required this.unreadTotal,
    required this.l10n,
  });

  final int turnsWaiting;
  final int unreadTotal;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    final colors = context.velvet;
    return Container(
      margin: const EdgeInsets.only(bottom: 4),
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
      decoration: BoxDecoration(
        color: colors.parchmentLift,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: colors.line.withValues(alpha: 0.7)),
      ),
      child: Row(
        children: [
          _InboxCount(value: turnsWaiting, label: l10n.yourTurn),
          Container(
            width: 1,
            height: 28,
            margin: const EdgeInsets.symmetric(horizontal: 16),
            color: colors.line,
          ),
          _InboxCount(
            value: unreadTotal,
            label: l10n.conversationsInboxTitle,
          ),
        ],
      ),
    ).animate().fadeIn(duration: 280.ms);
  }
}

class _InboxCount extends StatelessWidget {
  const _InboxCount({required this.value, required this.label});

  final int value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '$value',
          style: GoogleFonts.syne(
            color: context.velvet.ink,
            fontSize: 28,
            fontWeight: FontWeight.w800,
            letterSpacing: -2.5,
            height: 0.9,
          ),
        ),
        const SizedBox(height: 3),
        Text(
          label,
          style: Theme.of(
            context,
          ).textTheme.labelSmall?.copyWith(color: context.velvet.muted),
        ),
      ],
    );
  }
}

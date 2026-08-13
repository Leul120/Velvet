import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:velvet_mobile/core/network/dio_client.dart';
import 'package:velvet_mobile/core/theme/velvet_theme.dart';
import 'package:velvet_mobile/core/theme/velvet_editorial_colors.dart';
import 'package:velvet_mobile/core/theme/velvet_tokens.dart';
import 'package:velvet_mobile/core/widgets/kinetic_text.dart';
import 'package:velvet_mobile/core/network/media_url.dart';
import 'package:velvet_mobile/core/widgets/editorial_list_card.dart';
import 'package:velvet_mobile/core/widgets/marketplace_flow_hint.dart';
import 'package:velvet_mobile/core/widgets/velvet_widgets.dart';
import 'package:velvet_mobile/features/connections/connections_api.dart';
import 'package:velvet_mobile/l10n/generated/app_localizations.dart';

class ConnectionHistoryScreen extends ConsumerWidget {
  const ConnectionHistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final history = ref.watch(connectionHistoryProvider);
    final locale = Localizations.localeOf(context).languageCode;

    return VelvetScaffold(
      mistIntensity: 0.8,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(8, 8, VelvetTokens.pageInset, 0),
            child: Row(
              children: [
                VelvetIconChip(
                  icon: Icons.arrow_back_ios_new_rounded,
                  onTap: () => context.pop(),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      KineticEyebrow(
                        label: l10n.connectionHistoryTitle,
                        icon: Icons.history_rounded,
                      ),
                      KineticText(
                        text: l10n.connectionHistoryTitle,
                        style: GoogleFonts.syne(
                          fontSize: VelvetTokens.displaySmall,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.8,
                          height: 0.95,
                          color: context.velvet.ink,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: history.when(
              loading: () => const VelvetContentLoading(count: 2),
              error: (e, _) => VelvetEmptyState(
                title: l10n.retry,
                message: apiErrorMessage(e),
                icon: Icons.history_rounded,
                actionLabel: l10n.retry,
                onAction: () => ref.invalidate(connectionHistoryProvider),
              ),
              data: (items) {
                if (items.isEmpty) {
                  return VelvetEmptyState(
                    title: l10n.connectionHistoryTitle,
                    message: l10n.connectionHistoryEmpty,
                    icon: Icons.history_rounded,
                    flowSteps: [
                      MarketplaceFlowStep(icon: Icons.storefront_outlined, label: l10n.flowHintBrowse),
                      MarketplaceFlowStep(icon: Icons.send_outlined, label: l10n.flowHintRequest),
                      MarketplaceFlowStep(icon: Icons.forum_outlined, label: l10n.navConversations),
                    ],
                    actionLabel: l10n.conversationsInboxEmptyCtaDiscover,
                    onAction: () => context.go('/discover'),
                  );
                }
                return RefreshIndicator(
                  color: VelvetTheme.teal,
                  onRefresh: () async {
                    ref.invalidate(connectionHistoryProvider);
                    await ref.read(connectionHistoryProvider.future);
                  },
                  child: ListView.separated(
                    padding: const EdgeInsets.fromLTRB(24, 12, 24, 100),
                    itemCount: items.length,
                    separatorBuilder: (_, _) => const SizedBox.shrink(),
                    itemBuilder: (context, index) {
                      final m = items[index];
                      final note = locale == 'am'
                          ? (m.introNoteAm ?? m.introNoteEn)
                          : (m.introNoteEn ?? m.introNoteAm);
                      final photo = m.counterpartPhotoUrls.isNotEmpty
                          ? resolveMediaUrl(m.counterpartPhotoUrls.first)
                          : null;
                      return EditorialArchiveCard(
                        index: index,
                        name: m.counterpartDisplayName ?? l10n.someoneLabel,
                        status: m.status,
                        note: note,
                        photoUrl: photo,
                      ).animate().fadeIn(delay: (40 * index).ms);
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

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:velvet_mobile/core/network/dio_client.dart';
import 'package:velvet_mobile/core/network/media_url.dart';
import 'package:velvet_mobile/core/theme/velvet_editorial_colors.dart';
import 'package:velvet_mobile/core/theme/velvet_theme.dart';
import 'package:velvet_mobile/core/theme/velvet_tokens.dart';
import 'package:velvet_mobile/core/widgets/editorial_list_card.dart';
import 'package:velvet_mobile/core/widgets/kinetic_text.dart';
import 'package:velvet_mobile/core/widgets/velvet_editorial_sheet.dart';
import 'package:velvet_mobile/core/widgets/velvet_feedback.dart';
import 'package:velvet_mobile/core/widgets/velvet_widgets.dart';
import 'package:velvet_mobile/features/discover/discover_api.dart';
import 'package:velvet_mobile/l10n/generated/app_localizations.dart';

Future<void> showRecentPassesSheet(BuildContext context, WidgetRef ref) async {
  final l10n = AppLocalizations.of(context);
  await showEditorialSheet<void>(
    context: context,
    initialSize: 0.72,
    minSize: 0.45,
    builder: (context, scrollController) {
      return Consumer(
        builder: (context, ref, _) {
          final passes = ref.watch(recentPassesProvider);
          return ListView(
            controller: scrollController,
            padding: EdgeInsets.fromLTRB(
              VelvetTokens.pageInset,
              VelvetTokens.space8,
              VelvetTokens.pageInset,
              20 + MediaQuery.paddingOf(context).bottom,
            ),
            children: [
              KineticEyebrow(
                label: l10n.recentPassesTitle,
                icon: Icons.history_rounded,
              ),
              const SizedBox(height: VelvetTokens.space8),
              KineticText(
                text: l10n.recentPassesTitle,
                style: GoogleFonts.syne(
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.6,
                  height: 1.05,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                l10n.recentPassesHint,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: context.velvet.muted,
                  height: 1.45,
                ),
              ),
              const SizedBox(height: 18),
              passes.when(
                loading: () => const Padding(
                  padding: EdgeInsets.symmetric(vertical: 28),
                  child: VelvetContentLoading(count: 2),
                ),
                error: (e, _) => Text(
                  apiErrorMessage(e),
                  style: const TextStyle(color: VelvetTheme.danger),
                ),
                data: (feed) {
                  if (feed.items.isEmpty) {
                    return VelvetEmptyState(
                      message: l10n.recentPassesEmpty,
                      icon: Icons.history_rounded,
                    );
                  }
                  return Column(
                    children: feed.items.asMap().entries.map((entry) {
                      final i = entry.key;
                      final c = entry.value;
                      final photo =
                          c.photoUrls.isNotEmpty ? c.photoUrls.first : null;
                      final rate = c.sessionRateEtb == null
                          ? null
                          : l10n.rateSessionLabel(c.sessionRateEtb!);
                      final subtitle = [
                        if (c.city?.isNotEmpty == true) c.city!,
                        if (rate != null) rate,
                      ].join(' · ');

                      return EditorialRecordSlab(
                        index: i,
                        title: [
                          c.displayName ?? l10n.someoneLabel,
                          if (c.age != null) '${c.age}',
                        ].join(', '),
                        subtitle: subtitle.isEmpty ? ' ' : subtitle,
                        leading: ClipRRect(
                          borderRadius: BorderRadius.circular(
                            VelvetTokens.radiusXs,
                          ),
                          child: SizedBox(
                            width: 48,
                            height: 60,
                            child: photo == null
                                ? ColoredBox(
                                    color: VelvetTokens.plum.withValues(
                                      alpha: 0.08,
                                    ),
                                    child: Icon(
                                      Icons.person_outline,
                                      color: VelvetTokens.plumSoft,
                                    ),
                                  )
                                : Image.network(
                                    resolveMediaUrl(photo),
                                    fit: BoxFit.cover,
                                  ),
                          ),
                        ),
                        trailing: VelvetButton(
                          label: l10n.rewindPass,
                          variant: VelvetButtonVariant.ghost,
                          onPressed: () async {
                            try {
                              await ref
                                  .read(discoverApiProvider)
                                  .rewindPass(c.userId);
                              ref.invalidate(recentPassesProvider);
                              ref.invalidate(discoverFeedProvider);
                              if (!context.mounted) return;
                              await showVelvetToast(
                                context,
                                message: l10n.passRewound,
                                icon: Icons.replay_rounded,
                              );
                              if (!context.mounted) return;
                              Navigator.pop(context);
                            } catch (e) {
                              if (context.mounted) {
                                showVelvetErrorToast(
                                  context,
                                  message: apiErrorMessage(e),
                                );
                              }
                            }
                          },
                        ),
                      );
                    }).toList(),
                  );
                },
              ),
            ],
          );
        },
      );
    },
  );
}

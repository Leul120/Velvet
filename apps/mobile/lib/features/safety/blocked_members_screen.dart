import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:velvet_mobile/core/network/dio_client.dart';
import 'package:velvet_mobile/core/theme/velvet_theme.dart';
import 'package:velvet_mobile/core/theme/velvet_editorial_colors.dart';
import 'package:velvet_mobile/core/theme/velvet_tokens.dart';
import 'package:velvet_mobile/core/widgets/editorial_list_card.dart';
import 'package:velvet_mobile/core/widgets/kinetic_text.dart';
import 'package:velvet_mobile/core/widgets/velvet_feedback.dart';
import 'package:velvet_mobile/core/widgets/velvet_widgets.dart';
import 'package:velvet_mobile/features/social/social_api.dart';
import 'package:velvet_mobile/l10n/generated/app_localizations.dart';

final blockedMembersProvider = FutureProvider.autoDispose<List<BlockedMember>>((
  ref,
) {
  return ref.watch(safetyApiProvider).listBlocks();
});

class BlockedMembersScreen extends ConsumerWidget {
  const BlockedMembersScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final blocks = ref.watch(blockedMembersProvider);

    return VelvetScaffold(
      mistIntensity: 0.75,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(8, 8, VelvetTokens.pageInset, 0),
            child: Row(
              children: [
                VelvetIconChip(
                  icon: Icons.arrow_back_ios_new_rounded,
                  onTap: () => Navigator.of(context).maybePop(),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      KineticEyebrow(
                        label: l10n.blockedMembers,
                        icon: Icons.block_outlined,
                      ),
                      KineticText(
                        text: l10n.blockedMembers,
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
            child: blocks.when(
              loading: () => const VelvetContentLoading(count: 2),
              error: (e, _) => VelvetEmptyState(
                message: apiErrorMessage(e),
                icon: Icons.block_outlined,
                actionLabel: l10n.retry,
                onAction: () => ref.invalidate(blockedMembersProvider),
              ),
              data: (items) {
                if (items.isEmpty) {
                  return VelvetEmptyState(
                    message: l10n.blockedEmpty,
                    icon: Icons.shield_outlined,
                  );
                }
                return ListView.separated(
                  padding: const EdgeInsets.fromLTRB(
                    VelvetTokens.pageInset,
                    VelvetTokens.space16,
                    VelvetTokens.pageInset,
                    32,
                  ),
                  itemCount: items.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final b = items[index];
                    return EditorialRecordSlab(
                      index: index,
                      title:
                          'Member ···${b.blockedUserId.length > 4 ? b.blockedUserId.substring(b.blockedUserId.length - 4) : b.blockedUserId}',
                      subtitle: b.reason ?? '',
                      leading: Transform.rotate(
                        angle: index.isOdd ? 0.05 : -0.04,
                        child: Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                VelvetTokens.danger.withValues(alpha: 0.18),
                                VelvetTokens.danger.withValues(alpha: 0.06),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: const Icon(Icons.block, color: VelvetTheme.danger, size: 20),
                        ),
                      ),
                      trailing: TextButton(
                        onPressed: () async {
                              try {
                                await ref
                                    .read(safetyApiProvider)
                                    .unblock(b.blockedUserId);
                                ref.invalidate(blockedMembersProvider);
                                if (context.mounted) {
                                  await showVelvetToast(
                                    context,
                                    message: l10n.unblocked,
                                    icon: Icons.lock_open_rounded,
                                  );
                                }
                              } catch (e) {
                                if (context.mounted) {
                                  showVelvetErrorToast(context, message: apiErrorMessage(e));
                                }
                              }
                            },
                            child: Text(l10n.unblock),
                          ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

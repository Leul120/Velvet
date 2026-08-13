import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:velvet_mobile/core/network/dio_client.dart';
import 'package:velvet_mobile/core/theme/velvet_theme.dart';
import 'package:velvet_mobile/core/theme/velvet_editorial_colors.dart';
import 'package:velvet_mobile/core/widgets/kinetic_text.dart';
import 'package:velvet_mobile/core/theme/velvet_tokens.dart';
import 'package:velvet_mobile/core/widgets/editorial_list_card.dart';
import 'package:velvet_mobile/core/widgets/velvet_widgets.dart';
import 'package:velvet_mobile/features/notifications/notifications_api.dart';
import 'package:velvet_mobile/features/social/social_api.dart';
import 'package:velvet_mobile/l10n/generated/app_localizations.dart';
import 'package:velvet_mobile/core/widgets/velvet_feedback.dart';

class NotificationsScreen extends ConsumerStatefulWidget {
  const NotificationsScreen({super.key});

  @override
  ConsumerState<NotificationsScreen> createState() =>
      _NotificationsScreenState();
}

class _NotificationsScreenState extends ConsumerState<NotificationsScreen> {
  bool _markingAll = false;

  String _dateTime(DateTime date, String locale) =>
      DateFormat('MMM d • h:mm a', locale).format(date.toLocal());

  void _showError(Object error) {
    if (!mounted) return;
    showVelvetErrorToast(context, message: apiErrorMessage(error));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final items = ref.watch(notificationsProvider);

    return VelvetScaffold(
      mistIntensity: 0.7,
      body: Column(
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
                        label: l10n.notificationsTitle,
                        icon: Icons.notifications_none_rounded,
                      ),
                      KineticText(
                        text: l10n.notificationsTitle,
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
                TextButton(
                  onPressed: _markingAll
                      ? null
                      : () async {
                          setState(() => _markingAll = true);
                          try {
                            await ref
                                .read(notificationsApiProvider)
                                .markAllRead();
                            ref.invalidate(notificationsProvider);
                            ref.invalidate(unreadNotificationsProvider);
                          } catch (e) {
                            _showError(e);
                          } finally {
                            if (mounted) setState(() => _markingAll = false);
                          }
                        },
                  child: _markingAll
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Text(l10n.markAllRead),
                ),
              ],
            ),
          ),
          Expanded(
            child: items.when(
              loading: () => const VelvetContentLoading(),
              error: (e, _) => VelvetEmptyState(
                title: l10n.notificationsTitle,
                message: apiErrorMessage(e),
                icon: Icons.notifications_off_outlined,
                actionLabel: l10n.retry,
                onAction: () => ref.invalidate(notificationsProvider),
              ),
              data: (list) {
                if (list.isEmpty) {
                  return VelvetEmptyState(
                    title: l10n.notificationsTitle,
                    message: l10n.notificationsEmpty,
                    icon: Icons.notifications_none_rounded,
                  );
                }
                return RefreshIndicator(
                  color: VelvetTheme.teal,
                  onRefresh: () async {
                    ref.invalidate(notificationsProvider);
                    await ref.read(notificationsProvider.future);
                  },
                  child: ListView.separated(
                    padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
                    itemCount: list.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 14),
                    itemBuilder: (context, index) {
                      final n = list[index];
                      return EditorialNoticeCard(
                        index: index,
                        subject: n.subject,
                        body: n.body,
                        timestamp: _dateTime(
                          n.createdAt,
                          Localizations.localeOf(context).languageCode,
                        ),
                        unread: !n.read,
                        kind: EditorialNoticeCard.kindFromRelatedType(n.relatedType),
                        onTap: () async {
                            if (!n.read) {
                              await ref
                                  .read(notificationsApiProvider)
                                  .markRead(n.id);
                              ref.invalidate(notificationsProvider);
                              ref.invalidate(unreadNotificationsProvider);
                            }
                            if (!context.mounted) return;
                            if (n.relatedType == 'MATCH' &&
                                n.relatedId != null) {
                              context.push('/chat/${n.relatedId}');
                            } else if ((n.relatedType == 'BOOKING' ||
                                    n.relatedType == 'BOOKING_REMINDER') &&
                                n.relatedId != null) {
                              try {
                                final booking = await ref
                                    .read(bookingApiProvider)
                                    .get(n.relatedId!);
                                if (context.mounted) {
                                  context.push(
                                    '/booking/${booking.connectionId}',
                                  );
                                }
                              } catch (_) {
                                if (context.mounted) {
                                  context.go('/conversations');
                                }
                              }
                            }
                          },
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

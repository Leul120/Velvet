import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:velvet_mobile/core/network/dio_client.dart';
import 'package:velvet_mobile/core/network/media_url.dart';
import 'package:velvet_mobile/core/theme/velvet_editorial_colors.dart';
import 'package:velvet_mobile/core/theme/velvet_tokens.dart';
import 'package:velvet_mobile/core/widgets/kinetic_text.dart';
import 'package:velvet_mobile/core/widgets/velvet_widgets.dart';
import 'package:velvet_mobile/features/social/social_api.dart';
import 'package:velvet_mobile/l10n/generated/app_localizations.dart';
import 'package:velvet_mobile/core/widgets/velvet_feedback.dart';

class ConnectionConfirmedScreen extends ConsumerStatefulWidget {
  const ConnectionConfirmedScreen({
    super.key,
    required this.connectionId,
    this.counterpartName,
    this.counterpartPhoto,
    this.counterpartUserId,
  });

  final String connectionId;
  final String? counterpartName;
  final String? counterpartPhoto;
  final String? counterpartUserId;

  @override
  ConsumerState<ConnectionConfirmedScreen> createState() =>
      _ConnectionConfirmedScreenState();
}

class _ConnectionConfirmedScreenState
    extends ConsumerState<ConnectionConfirmedScreen> {
  List<SuggestedOpener> _suggestedOpeners = const [];
  bool _sending = false;
  String? _selected;
  BookingItem? _booking;
  bool _bookingLoading = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      HapticFeedback.mediumImpact();
    });
    _loadSuggestedOpeners();
    _loadBooking();
  }

  Future<void> _loadSuggestedOpeners() async {
    try {
      final detail = await ref
          .read(chatApiProvider)
          .getThread(widget.connectionId);
      if (!mounted) return;
      setState(() {
        _suggestedOpeners = detail.suggestedOpeners.take(4).toList();
        if (_suggestedOpeners.isNotEmpty) {
          _selected = _suggestedOpeners.first.textEn;
        }
      });
    } catch (_) {}
  }

  Future<void> _loadBooking() async {
    setState(() => _bookingLoading = true);
    try {
      final b = await ref
          .read(bookingApiProvider)
          .byConnection(widget.connectionId);
      if (!mounted) return;
      setState(() => _booking = b);
    } catch (_) {
      // Keep resilient even if booking fetch fails.
    } finally {
      if (mounted) setState(() => _bookingLoading = false);
    }
  }

  Future<void> _sendOpener() async {
    final line = _selected?.trim();
    if (line == null || line.isEmpty) return;
    setState(() => _sending = true);
    try {
      await ref.read(chatApiProvider).send(widget.connectionId, body: line);
      if (!mounted) return;
      final other = widget.counterpartUserId == null
          ? ''
          : '?other=${Uri.encodeComponent(widget.counterpartUserId!)}';
      context.go('/chat/${widget.connectionId}$other');
    } catch (e) {
      if (mounted) {
        showVelvetErrorToast(context, message: apiErrorMessage(e));
      }
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  void _openChat() {
    final other = widget.counterpartUserId == null
        ? ''
        : '?other=${Uri.encodeComponent(widget.counterpartUserId!)}';
    context.go('/chat/${widget.connectionId}$other');
  }

  void _openBooking(String focus) {
    context.push('/booking/${widget.connectionId}?focus=$focus');
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context).languageCode;
    final colors = context.velvet;
    final booking = _booking;
    final needsPay = booking?.needsPayment == true;
    final isConfirmed =
        booking != null &&
        (booking.status == 'CONFIRMED' ||
            booking.status == 'CHECKED_IN' ||
            booking.status == 'COMPLETED');
    final bookingFocus = booking == null
        ? 'plan'
        : (needsPay ? 'pay' : 'confirm');

    return VelvetScaffold(
      mistIntensity: 1.0,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: _avatar(widget.counterpartPhoto),
              ).animate().fadeIn(duration: 320.ms).slideY(begin: 0.04, end: 0),
              const SizedBox(height: 16),
              Text(
                widget.counterpartName ?? l10n.someoneLabel,
                textAlign: TextAlign.center,
                style: GoogleFonts.syne(
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.7,
                  height: 1.0,
                  color: colors.ink,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                l10n.connectionConfirmedTitle,
                textAlign: TextAlign.center,
                style: GoogleFonts.dmSans(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.6,
                  color: VelvetTokens.ember,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                widget.counterpartName == null
                    ? l10n.connectionConfirmedBody
                    : l10n.connectionConfirmedWith(widget.counterpartName!),
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: colors.muted,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 20),
              _NextBestActionCard(
                booking: booking,
                loading: _bookingLoading,
                onOpenBooking: () => _openBooking(bookingFocus),
                onOpenChat: _openChat,
              ),
              if (!isConfirmed) ...[
                const SizedBox(height: 8),
                OutlinedButton.icon(
                  onPressed: _openChat,
                  icon: const Icon(Icons.chat_bubble_outline_rounded, size: 18),
                  label: Text(l10n.openChat),
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size.fromHeight(50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(999),
                    ),
                  ),
                ),
              ],
              if (_suggestedOpeners.isNotEmpty) ...[
                const SizedBox(height: 18),
                Align(
                  alignment: Alignment.centerLeft,
                  child: KineticEyebrow(
                    label: l10n.suggestedOpener,
                    icon: Icons.auto_awesome_outlined,
                  ),
                ),
                const SizedBox(height: 10),
                Expanded(
                  child: ListView.separated(
                    padding: EdgeInsets.zero,
                    itemCount: _suggestedOpeners.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 8),
                    itemBuilder: (context, i) {
                      final ice = _suggestedOpeners[i];
                      final text = locale == 'am' ? ice.textAm : ice.textEn;
                      final selected =
                          _selected == ice.textEn || _selected == ice.textAm;
                      final radius = BorderRadius.circular(18);

                      return Material(
                        color: Colors.transparent,
                        child: InkWell(
                          borderRadius: radius,
                          onTap: () {
                            HapticFeedback.selectionClick();
                            setState(() => _selected = text);
                          },
                          child: AnimatedContainer(
                            duration: VelvetTokens.motionFast,
                            curve: VelvetTokens.easeEditorial,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 14,
                            ),
                            decoration: BoxDecoration(
                              color: selected
                                  ? VelvetTokens.ember.withValues(alpha: 0.10)
                                  : colors.parchmentLift,
                              borderRadius: radius,
                              border: Border.all(
                                color: selected
                                    ? VelvetTokens.ember.withValues(alpha: 0.4)
                                    : colors.line.withValues(alpha: 0.7),
                              ),
                            ),
                            child: Text(
                              text,
                              style: Theme.of(context).textTheme.bodyMedium
                                  ?.copyWith(
                                    height: 1.4,
                                    fontWeight: selected
                                        ? FontWeight.w600
                                        : FontWeight.w400,
                                    color: colors.ink,
                                  ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                FilledButton.icon(
                  onPressed: _sending ? null : _sendOpener,
                  icon: _sending
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: VelvetTokens.onPrimary,
                          ),
                        )
                      : const Icon(Icons.send_rounded, size: 18),
                  label: Text(l10n.sendOpener),
                  style: FilledButton.styleFrom(
                    minimumSize: const Size.fromHeight(52),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(999),
                    ),
                  ),
                ),
              ] else if (!isConfirmed)
                const Spacer(),
              const SizedBox(height: 8),
              TextButton(
                onPressed: () => context.go('/discover'),
                child: Text(l10n.keepBrowsing),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _avatar(String? url) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: SizedBox(
        width: 112,
        height: 140,
        child: url == null
            ? ColoredBox(
                color: VelvetTokens.parchmentLift,
                child: const Icon(Icons.person_outline, size: 40),
              )
            : Image.network(
                resolveMediaUrl(url),
                fit: BoxFit.cover,
                errorBuilder: (_, _, _) => ColoredBox(
                  color: VelvetTokens.parchmentLift,
                  child: const Icon(Icons.person_outline, size: 40),
                ),
              ),
      ),
    );
  }
}

class _NextBestActionCard extends StatelessWidget {
  const _NextBestActionCard({
    required this.booking,
    required this.loading,
    required this.onOpenBooking,
    required this.onOpenChat,
  });

  final BookingItem? booking;
  final bool loading;
  final VoidCallback onOpenBooking;
  final VoidCallback onOpenChat;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colors = context.velvet;
    if (loading) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: colors.parchmentLift,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: colors.line.withValues(alpha: 0.7)),
        ),
        child: const LinearProgressIndicator(minHeight: 2),
      );
    }
    final b = booking;
    final requiresPay = b != null && b.needsPayment;
    final confirmed =
        b != null &&
        (b.status == 'CONFIRMED' ||
            b.status == 'CHECKED_IN' ||
            b.status == 'COMPLETED');
    final hasProposal = b != null;
    final title = requiresPay
        ? l10n.flowNextPayTitle
        : confirmed
        ? l10n.flowNextChatTitle
        : hasProposal
        ? l10n.flowNextConfirmTitle
        : l10n.flowNextBookTitle;
    final body = requiresPay
        ? l10n.flowNextPayBody
        : confirmed
        ? l10n.flowNextChatBody
        : hasProposal
        ? l10n.flowNextConfirmBody
        : l10n.flowNextBookBody;
    final badge = requiresPay
        ? l10n.payBooking
        : confirmed
        ? l10n.statusConfirmed
        : hasProposal
        ? l10n.statusPending
        : l10n.bookingTitle;
    final cta = (requiresPay || (hasProposal && !confirmed))
        ? l10n.bookVenue
        : l10n.openChat;
    final action = (requiresPay || (hasProposal && !confirmed))
        ? onOpenBooking
        : onOpenChat;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.parchmentLift,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: colors.line.withValues(alpha: 0.7)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 38,
                height: 38,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: VelvetTokens.ember.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  requiresPay
                      ? Icons.lock_outline_rounded
                      : confirmed
                      ? Icons.forum_outlined
                      : Icons.event_available_rounded,
                  color: VelvetTokens.ember,
                  size: 19,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: GoogleFonts.syne(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        letterSpacing: -0.3,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      body,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: colors.muted,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: VelvetTokens.ember.withValues(alpha: 0.14),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        badge,
                        style: GoogleFonts.dmSans(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: VelvetTokens.ember,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          FilledButton.icon(
            onPressed: action,
            icon: Icon(
              requiresPay || (hasProposal && !confirmed)
                  ? Icons.calendar_month_outlined
                  : Icons.chat_bubble_outline_rounded,
              size: 18,
            ),
            label: Text(cta),
            style: FilledButton.styleFrom(
              minimumSize: const Size.fromHeight(50),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(999),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

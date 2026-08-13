import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:velvet_mobile/core/network/dio_client.dart';
import 'package:velvet_mobile/core/network/media_url.dart';
import 'package:velvet_mobile/core/theme/velvet_theme.dart';
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
          padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                l10n.connectionConfirmedTitle,
                textAlign: TextAlign.center,
                style: GoogleFonts.syne(
                  fontSize: VelvetTokens.displayMedium,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -1.0,
                  color: VelvetTokens.gold,
                  height: 0.95,
                ),
              ).animate().fadeIn(duration: 360.ms).slideY(begin: 0.06, end: 0),
              const SizedBox(height: 8),
              Text(
                widget.counterpartName == null
                    ? l10n.connectionConfirmedBody
                    : l10n.connectionConfirmedWith(widget.counterpartName!),
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: context.velvet.muted,
                  height: 1.4,
                ),
              ).animate().fadeIn(delay: 60.ms, duration: 320.ms),
              const SizedBox(height: 24),
              GlassPanel(
                padding: const EdgeInsets.all(16),
                fill: VelvetTheme.glassStrong,
                child: Row(
                  children: [
                    _avatar(widget.counterpartPhoto),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.counterpartName ?? l10n.someoneLabel,
                            style: GoogleFonts.syne(
                              fontSize: 28,
                              fontWeight: FontWeight.w800,
                              letterSpacing: -0.6,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            l10n.connectionConfirmedNext,
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(color: context.velvet.muted),
                          ),
                        ],
                      ),
                    ),
                    const Icon(
                      Icons.verified_user_outlined,
                      color: VelvetTheme.teal,
                    ),
                  ],
                ),
              ).animate().fadeIn(delay: 100.ms).slideY(begin: 0.05, end: 0),
              const SizedBox(height: 14),
              _NextBestActionCard(
                booking: booking,
                loading: _bookingLoading,
                onOpenBooking: () => _openBooking(bookingFocus),
                onOpenChat: _openChat,
              ),
              if (!isConfirmed) ...[
                const SizedBox(height: 8),
                VelvetButton(
                  label: l10n.openChat,
                  variant: VelvetButtonVariant.secondary,
                  icon: Icons.chat_bubble_outline_rounded,
                  onPressed: _openChat,
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
                      final colors = context.velvet;
                      final radius = BorderRadius.circular(VelvetTokens.radiusMd);

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
                                  ? VelvetTokens.ember.withValues(alpha: 0.08)
                                  : colors.parchmentLift,
                              borderRadius: radius,
                              border: Border.all(
                                color: selected
                                    ? VelvetTokens.ember.withValues(alpha: 0.4)
                                    : colors.line.withValues(alpha: 0.85),
                              ),
                            ),
                            child: Text(
                              text,
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
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
                VelvetButton(
                  label: l10n.sendOpener,
                  icon: Icons.send_rounded,
                  loading: _sending,
                  onPressed: _sending ? null : _sendOpener,
                ),
              ] else if (!isConfirmed)
                const Spacer(),
              const SizedBox(height: 8),
              VelvetButton(
                label: l10n.keepBrowsing,
                variant: VelvetButtonVariant.ghost,
                onPressed: () => context.go('/discover'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _avatar(String? url) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(VelvetTheme.radiusMd),
      child: SizedBox(
        width: 64,
        height: 64,
        child: url == null
            ? Container(
                color: VelvetTheme.mistSage,
                child: const Icon(Icons.person_outline, size: 28),
              )
            : Image.network(
                resolveMediaUrl(url),
                fit: BoxFit.cover,
                errorBuilder: (_, _, _) => Container(
                  color: VelvetTheme.mistSage,
                  child: const Icon(Icons.person_outline, size: 28),
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
    if (loading) {
      return const GlassPanel(
        padding: EdgeInsets.all(14),
        fill: VelvetTheme.glassFill,
        child: LinearProgressIndicator(minHeight: 2),
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

    return GlassPanel(
      padding: const EdgeInsets.all(16),
      fill: VelvetTheme.glassStrong,
      border: VelvetTheme.teal.withValues(alpha: 0.28),
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
                  shape: BoxShape.circle,
                  color: VelvetTheme.teal.withValues(alpha: 0.16),
                  border: Border.all(
                    color: VelvetTheme.champagne.withValues(alpha: 0.34),
                  ),
                ),
                child: Icon(
                  requiresPay
                      ? Icons.lock_outline_rounded
                      : confirmed
                      ? Icons.forum_outlined
                      : Icons.event_available_rounded,
                  color: VelvetTheme.champagne,
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
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      body,
                      style: Theme.of(
                        context,
                      ).textTheme.bodySmall?.copyWith(color: context.velvet.muted),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: VelvetTheme.teal.withValues(alpha: 0.16),
                        borderRadius: BorderRadius.circular(999),
                        border: Border.all(
                          color: VelvetTheme.teal.withValues(alpha: 0.35),
                        ),
                      ),
                      child: Text(
                        badge,
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: VelvetTheme.champagne,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          VelvetButton(
            label: cta,
            icon: requiresPay || (hasProposal && !confirmed)
                ? Icons.calendar_month_outlined
                : Icons.chat_bubble_outline_rounded,
            onPressed: action,
          ),
        ],
      ),
    );
  }
}

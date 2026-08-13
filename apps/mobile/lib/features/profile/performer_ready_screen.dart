import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:velvet_mobile/core/network/dio_client.dart';
import 'package:velvet_mobile/core/theme/velvet_theme.dart';
import 'package:velvet_mobile/core/theme/velvet_editorial_colors.dart';
import 'package:velvet_mobile/core/theme/velvet_tokens.dart';
import 'package:velvet_mobile/core/widgets/editorial_list_card.dart';
import 'package:velvet_mobile/core/widgets/kinetic_text.dart';
import 'package:velvet_mobile/core/widgets/velvet_feedback.dart';
import 'package:velvet_mobile/core/widgets/velvet_widgets.dart';
import 'package:velvet_mobile/features/profile/availability_api.dart';
import 'package:velvet_mobile/features/profile/profile_api.dart';
import 'package:velvet_mobile/l10n/generated/app_localizations.dart';

/// Performer go-live checklist (replaces Membership tab for performers).
class PerformerReadyScreen extends ConsumerStatefulWidget {
  const PerformerReadyScreen({super.key});

  @override
  ConsumerState<PerformerReadyScreen> createState() => _PerformerReadyScreenState();
}

class _PerformerReadyScreenState extends ConsumerState<PerformerReadyScreen> {
  bool _loading = true;
  int _windowCount = 0;

  @override
  void initState() {
    super.initState();
    _loadWindows();
  }

  Future<void> _loadWindows() async {
    setState(() => _loading = true);
    try {
      final windows = await ref.read(availabilityApiProvider).mine();
      if (mounted) setState(() => _windowCount = windows.length);
    } catch (_) {
      if (mounted) setState(() => _windowCount = 0);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _toggleListing(MeProfile me, bool value) async {
    final l10n = AppLocalizations.of(context);
    if (value && me.status != 'VERIFIED') {
      await showVelvetErrorToast(context, message: l10n.listingRequiresVerification);
      return;
    }
    try {
      await ref.read(profileApiProvider).update(listingActive: value);
      ref.invalidate(meProfileProvider);
      if (mounted) {
        await showVelvetToast(
          context,
          message: value ? l10n.listingNowLive : l10n.listingNowHidden,
          icon: Icons.storefront_outlined,
        );
      }
    } catch (e) {
      if (mounted) {
        showVelvetErrorToast(context, message: apiErrorMessage(e));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final meAsync = ref.watch(meProfileProvider);

    return VelvetAuthScaffold(
      body: meAsync.when(
        loading: () => const VelvetContentLoading(),
        error: (e, _) => Center(child: Text(apiErrorMessage(e))),
        data: (me) {
          final verified = me.status == 'VERIFIED';
          final photosOk = me.photoUrls.length >= 3;
          final listingOk = (me.bioEn?.trim().isNotEmpty ?? false) &&
              (me.bioAm?.trim().isNotEmpty ?? false);
          final ratesOk = (me.sessionRateEtb != null && me.sessionRateEtb! > 0) ||
              (me.overnightRateEtb != null && me.overnightRateEtb! > 0);
          final calendarOk = _windowCount > 0;
          final live = me.listingActive && verified;
          final steps = [photosOk, listingOk, ratesOk, calendarOk, verified];
          final doneCount = steps.where((s) => s).length;
          const totalSteps = 5;
          final ready = doneCount == totalSteps;

          return RefreshIndicator(
            color: VelvetTheme.teal,
            onRefresh: () async {
              ref.invalidate(meProfileProvider);
              await _loadWindows();
            },
            child: ListView(
              padding: const EdgeInsets.fromLTRB(
                VelvetTokens.pageInset,
                VelvetTokens.space16,
                VelvetTokens.pageInset,
                100,
              ),
              children: [
                KineticEyebrow(
                  label: l10n.navMembership,
                  icon: Icons.rocket_launch_outlined,
                ),
                const SizedBox(height: VelvetTokens.space8),
                KineticText(
                  text: l10n.performerReadyTitle,
                  style: GoogleFonts.syne(
                    fontSize: VelvetTokens.displaySmall,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.9,
                    height: 0.95,
                    color: context.velvet.ink,
                  ),
                ),
                const SizedBox(height: VelvetTokens.space8),
                Text(
                  l10n.performerReadyHint,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: context.velvet.muted,
                        height: 1.45,
                      ),
                ),
                const SizedBox(height: 18),
                GlassPanel(
                  padding: const EdgeInsets.all(16),
                  fill: VelvetTheme.glassStrong,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.readyProgressLabel(doneCount, totalSteps),
                        style: GoogleFonts.inter(fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(height: 10),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(999),
                        child: LinearProgressIndicator(
                          minHeight: 8,
                          value: doneCount / totalSteps,
                          backgroundColor: VelvetTheme.line,
                          color: ready ? VelvetTheme.teal : VelvetTheme.orangeSoft,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                _step(
                  index: 0,
                  done: photosOk,
                  title: l10n.readyStepPhotos,
                  subtitle: photosOk
                      ? l10n.readyStepPhotosDone(me.photoUrls.length)
                      : l10n.readyStepPhotosTodo,
                  action: () => context.push('/profile'),
                  actionLabel: l10n.profile,
                ),
                _step(
                  index: 1,
                  done: listingOk,
                  title: l10n.readyStepListing,
                  subtitle: listingOk ? l10n.readyStepListingDone : l10n.readyStepListingTodo,
                  action: () => context.push('/profile'),
                  actionLabel: l10n.profile,
                ),
                _step(
                  index: 2,
                  done: ratesOk,
                  title: l10n.readyStepRates,
                  subtitle: ratesOk
                      ? l10n.readyStepRatesDone(
                          me.sessionRateEtb ?? 0,
                          me.overnightRateEtb ?? 0,
                        )
                      : l10n.readyStepRatesTodo,
                  action: () => context.push('/profile'),
                  actionLabel: l10n.profile,
                ),
                _step(
                  index: 3,
                  done: calendarOk,
                  title: l10n.readyStepCalendar,
                  subtitle: _loading
                      ? '…'
                      : calendarOk
                          ? l10n.readyStepCalendarDone(_windowCount)
                          : l10n.readyStepCalendarTodo,
                  action: () async {
                    await context.push('/availability');
                    await _loadWindows();
                  },
                  actionLabel: l10n.availabilityCalendarTitle,
                ),
                _step(
                  index: 4,
                  done: verified,
                  title: l10n.readyStepVerify,
                  subtitle: verified ? l10n.readyStepVerifyDone : l10n.readyStepVerifyTodo,
                  action: verified ? null : () => context.push('/verification'),
                  actionLabel: verified ? null : l10n.verifyToListCta,
                ),
                const SizedBox(height: 12),
                GlassPanel(
                  padding: const EdgeInsets.all(16),
                  fill: VelvetTheme.glassStrong,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      EditorialToggleRow(
                        index: 0,
                        title: l10n.listingActive,
                        subtitle: ready
                            ? (live ? l10n.listingNowLive : l10n.readyGoLiveHint)
                            : l10n.readyFinishStepsFirst,
                        value: me.listingActive && verified,
                        enabled: ready,
                        onChanged: ready ? (v) => _toggleListing(me, v) : null,
                      ),
                      if (live) ...[
                        const SizedBox(height: 8),
                        Text(
                          l10n.readyLiveBanner,
                          style: GoogleFonts.dmSans(
                            color: VelvetTokens.emberDeep,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _step({
    required bool done,
    required String title,
    required String subtitle,
    required String? actionLabel,
    required VoidCallback? action,
    required int index,
  }) {
    return EditorialRecordSlab(
      index: index,
      complete: done,
      title: title,
      subtitle: subtitle,
      leading: Icon(
        done ? Icons.check_circle_rounded : Icons.radio_button_unchecked,
        color: done ? VelvetTokens.ember : VelvetTheme.muted,
        size: 26,
      ),
      trailing: action == null || actionLabel == null
          ? null
          : TextButton(onPressed: action, child: Text(actionLabel)),
    );
  }
}

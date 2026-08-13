import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:velvet_mobile/core/location/location_helper.dart';
import 'package:velvet_mobile/core/network/dio_client.dart';
import 'package:velvet_mobile/core/network/media_url.dart';
import 'package:velvet_mobile/core/theme/velvet_theme.dart';
import 'package:velvet_mobile/core/theme/velvet_editorial_colors.dart';
import 'package:velvet_mobile/core/theme/velvet_tokens.dart';
import 'package:velvet_mobile/core/widgets/editorial_dialog.dart';
import 'package:velvet_mobile/core/widgets/editorial_list_card.dart';
import 'package:velvet_mobile/core/widgets/kinetic_text.dart';
import 'package:velvet_mobile/core/widgets/safety_panic_zone.dart';
import 'package:velvet_mobile/core/widgets/velvet_feedback.dart';
import 'package:velvet_mobile/core/widgets/velvet_widgets.dart';
import 'package:velvet_mobile/features/settings/low_bandwidth_provider.dart';
import 'package:velvet_mobile/features/social/social_api.dart';
import 'package:velvet_mobile/l10n/generated/app_localizations.dart';

class SafetyCenterScreen extends ConsumerStatefulWidget {
  const SafetyCenterScreen({super.key});

  @override
  ConsumerState<SafetyCenterScreen> createState() => _SafetyCenterScreenState();
}

class _SafetyCenterScreenState extends ConsumerState<SafetyCenterScreen> {
  List<VenueItem> _venues = [];
  bool _loading = true;
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final venues = await ref.read(venuesApiProvider).list();
      setState(() => _venues = venues.where((v) => v.verified).toList());
    } catch (_) {
      setState(() => _venues = []);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _panic() async {
    final l10n = AppLocalizations.of(context);
    final send = await showEditorialConfirm(
      context: context,
      title: l10n.panicButton,
      message: l10n.panicConfirm,
      confirmLabel: l10n.panicButton,
      cancelLabel: l10n.close,
      destructive: true,
    );
    if (send != true) return;
    setState(() => _busy = true);
    try {
      final pos = await LocationHelper.currentOrNull();
      await ref.read(safetyApiProvider).panic(
            note: 'Panic from safety center',
            latitude: pos?.latitude,
            longitude: pos?.longitude,
          );
      HapticFeedback.heavyImpact();
      if (mounted) {
        await showVelvetToast(
          context,
          message: l10n.panicSent,
          icon: Icons.emergency_outlined,
        );
      }
    } catch (e) {
      if (mounted) {
        showVelvetErrorToast(context, message: apiErrorMessage(e));
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _shareTrip() async {
    final l10n = AppLocalizations.of(context);
    setState(() => _busy = true);
    try {
      final pos = await LocationHelper.currentOrNull();
      await ref.read(safetyApiProvider).shareTrip(
            latitude: pos?.latitude,
            longitude: pos?.longitude,
            etaMinutes: 25,
            note: 'Sharing trip with Velvet concierge',
          );
      HapticFeedback.selectionClick();
      if (mounted) {
        await showVelvetToast(
          context,
          message: l10n.tripSharedSnack,
          icon: Icons.share_location_outlined,
        );
      }
    } catch (e) {
      if (mounted) {
        showVelvetErrorToast(context, message: apiErrorMessage(e));
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _report() async {
    final l10n = AppLocalizations.of(context);
    final detailsCtrl = TextEditingController();
    var category = 'UNSAFE';
    final ok = await showEditorialDialog<bool>(
      context: context,
      title: l10n.reportMember,
      content: StatefulBuilder(
        builder: (context, setLocal) => Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            DropdownButtonFormField<String>(
              initialValue: category,
              items: const [
                DropdownMenuItem(value: 'UNSAFE', child: Text('Unsafe')),
                DropdownMenuItem(value: 'HARASSMENT', child: Text('Harassment')),
                DropdownMenuItem(value: 'NO_SHOW', child: Text('No-show')),
                DropdownMenuItem(value: 'POLICY', child: Text('Policy')),
                DropdownMenuItem(value: 'OTHER', child: Text('Other')),
              ],
              onChanged: (v) => setLocal(() => category = v ?? 'UNSAFE'),
            ),
            const SizedBox(height: 12),
            VelvetField(
              controller: detailsCtrl,
              label: l10n.optionalNotes,
              maxLines: 3,
            ),
          ],
        ),
      ),
      actions: [
        EditorialDialogAction(
          label: l10n.close,
          onPressed: () => Navigator.pop(context, false),
        ),
        EditorialDialogAction(
          label: l10n.submitFeedback,
          primary: true,
          onPressed: () => Navigator.pop(context, true),
        ),
      ],
    );
    if (ok != true || detailsCtrl.text.trim().isEmpty) {
      detailsCtrl.dispose();
      return;
    }
    try {
      await ref.read(safetyApiProvider).report(category: category, details: detailsCtrl.text.trim());
      if (mounted) {
        await showVelvetToast(
          context,
          message: l10n.reportSubmitted,
          icon: Icons.flag_outlined,
        );
      }
    } catch (e) {
      if (mounted) {
        showVelvetErrorToast(context, message: apiErrorMessage(e));
      }
    } finally {
      detailsCtrl.dispose();
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context).languageCode;
    final lowBw = ref.watch(lowBandwidthProvider);

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
                  onTap: () => context.pop(),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      KineticEyebrow(
                        label: l10n.safetyCenterTitle,
                        icon: Icons.shield_outlined,
                      ),
                      KineticText(
                        text: l10n.safetyCenterTitle,
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
            child: ListView(
              padding: const EdgeInsets.fromLTRB(
                VelvetTokens.pageInset,
                VelvetTokens.space16,
                VelvetTokens.pageInset,
                32,
              ),
              children: [
                SafetyPanicZone(
                  label: l10n.panicButton,
                  hint: l10n.safetyCenterHint,
                  loading: _busy,
                  onPanic: _busy ? null : _panic,
                ),
                const SizedBox(height: VelvetTokens.space24),
                SafetyActionModule(
                  title: l10n.safetyCenterTitle,
                  icon: Icons.support_agent_outlined,
                  children: [
                    VelvetButton(
                      label: l10n.shareTripWithVelvet,
                      icon: Icons.share_location_outlined,
                      variant: VelvetButtonVariant.secondary,
                      loading: _busy,
                      onPressed: _busy ? null : _shareTrip,
                    ),
                    const SizedBox(height: VelvetTokens.space10),
                    VelvetButton(
                      label: l10n.reportMember,
                      variant: VelvetButtonVariant.ghost,
                      icon: Icons.flag_outlined,
                      onPressed: _report,
                    ),
                    const SizedBox(height: VelvetTokens.space10),
                    EditorialNavSlab(
                      title: l10n.blockedMembers,
                      icon: Icons.block_outlined,
                      index: 0,
                      onTap: () => context.push('/blocked'),
                    ),
                    EditorialNavSlab(
                      title: l10n.verificationTitle,
                      icon: Icons.verified_user_outlined,
                      index: 1,
                      onTap: () => context.push('/verification'),
                    ),
                  ],
                ),
                const SizedBox(height: VelvetTokens.space24),
                SafetyActionModule(
                  title: l10n.verifiedVenues,
                  icon: Icons.storefront_outlined,
                  children: [
                if (_loading)
                  const VelvetContentLoading(count: 2)
                else if (_venues.isEmpty)
                  Text(
                    l10n.verifiedVenuesEmpty,
                    style: Theme.of(context).textTheme.bodyMedium,
                  )
                else
                  ..._venues.map((v) {
                    final name = locale == 'am' ? (v.nameAm ?? v.name) : v.name;
                    final photo = v.photoUrls.isNotEmpty ? v.photoUrls.first : null;
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: GlassPanel(
                        padding: const EdgeInsets.all(12),
                        fill: VelvetTheme.glassFill,
                        child: Row(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(VelvetTheme.radiusMd),
                              child: photo == null
                                  ? Container(
                                      width: 56,
                                      height: 56,
                                      color: VelvetTheme.line,
                                      child: const Icon(Icons.storefront_outlined),
                                    )
                                  : Image.network(
                                      resolveMediaUrl(photo),
                                      width: 56,
                                      height: 56,
                                      fit: BoxFit.cover,
                                      cacheWidth: mediaCacheWidth(lowBw, full: 160, compressed: 96),
                                    ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(name, style: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 17)),
                                  Text(
                                    [v.area ?? v.city, v.vibe ?? ''].where((s) => s.isNotEmpty).join(' · '),
                                    style: Theme.of(context).textTheme.bodySmall?.copyWith(color: context.velvet.muted),
                                  ),
                                ],
                              ),
                            ),
                            const Icon(Icons.verified_outlined, color: VelvetTheme.teal, size: 20),
                          ],
                        ),
                      ),
                    );
                  }),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

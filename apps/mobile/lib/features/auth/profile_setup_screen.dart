import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:velvet_mobile/core/network/dio_client.dart';
import 'package:velvet_mobile/core/theme/velvet_theme.dart';
import 'package:velvet_mobile/core/theme/velvet_editorial_colors.dart';
import 'package:velvet_mobile/core/theme/velvet_tokens.dart';
import 'package:velvet_mobile/core/widgets/editorial_dialog.dart';
import 'package:velvet_mobile/core/widgets/kinetic_text.dart';
import 'package:velvet_mobile/core/widgets/velvet_widgets.dart';
import 'package:velvet_mobile/features/auth/auth_controller.dart';
import 'package:velvet_mobile/features/auth/role_helpers.dart';
import 'package:velvet_mobile/features/profile/profile_api.dart';
import 'package:velvet_mobile/l10n/generated/app_localizations.dart';

class ProfileSetupScreen extends ConsumerStatefulWidget {
  const ProfileSetupScreen({super.key});
  @override
  ConsumerState<ProfileSetupScreen> createState() => _ProfileSetupScreenState();
}

class _ProfileSetupScreenState extends ConsumerState<ProfileSetupScreen> {
  final city = TextEditingController(text: 'Addis Ababa');
  final english = TextEditingController();
  final amharic = TextEditingController();
  final sessionRate = TextEditingController();
  final overnightRate = TextEditingController();
  final availability = TextEditingController();
  final photos = <String>[];
  bool saving = false;
  String? error;

  @override
  void initState() {
    super.initState();
    _loadExisting();
  }

  @override
  void dispose() {
    city.dispose();
    english.dispose();
    amharic.dispose();
    sessionRate.dispose();
    overnightRate.dispose();
    availability.dispose();
    super.dispose();
  }

  bool get _isPerformer {
    final role = ref.read(authControllerProvider).user?.role;
    return isPerformerRole(role);
  }

  Future<void> _loadExisting() async {
    try {
      final profile = await ref.read(profileApiProvider).me();
      if (!mounted) return;
      setState(() {
        city.text = profile.city?.isNotEmpty == true
            ? profile.city!
            : city.text;
        english.text = profile.bioEn ?? '';
        amharic.text = profile.bioAm ?? '';
        if (profile.sessionRateEtb != null) {
          sessionRate.text = '${profile.sessionRateEtb}';
        }
        if (profile.overnightRateEtb != null) {
          overnightRate.text = '${profile.overnightRateEtb}';
        }
        availability.text = profile.availabilityNote ?? '';
        photos
          ..clear()
          ..addAll(profile.photoUrls);
      });
    } catch (_) {
      // The normal save path shows a useful API error if the service remains unavailable.
    }
  }

  Future<void> addPhoto() async {
    final file = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      imageQuality: 92,
      maxWidth: 2048,
    );
    if (file == null) return;
    setState(() => saving = true);
    try {
      final api = ref.read(profileApiProvider);
      final uploaded = await api.uploadPhoto(file.path);
      await api.addPhoto(uploaded.url);
      if (mounted) setState(() => photos.add(uploaded.url));
    } catch (e) {
      if (mounted) setState(() => error = apiErrorMessage(e));
    } finally {
      if (mounted) setState(() => saving = false);
    }
  }

  Future<void> finish() async {
    final l10n = AppLocalizations.of(context);
    if (photos.length < 3 ||
        city.text.trim().isEmpty ||
        english.text.trim().isEmpty ||
        amharic.text.trim().isEmpty) {
      setState(() => error = l10n.profileSetupRequired);
      return;
    }
    setState(() {
      saving = true;
      error = null;
    });
    try {
      await ref
          .read(profileApiProvider)
          .update(
            city: city.text.trim(),
            bioEn: english.text.trim(),
            bioAm: amharic.text.trim(),
            sessionRateEtb: _isPerformer
                ? int.tryParse(sessionRate.text.trim())
                : null,
            overnightRateEtb: _isPerformer
                ? int.tryParse(overnightRate.text.trim())
                : null,
            availabilityNote: _isPerformer ? availability.text.trim() : null,
            listingActive: _isPerformer ? false : null,
          );
      ref.read(authControllerProvider).setProfileReady(true);
      ref.invalidate(meProfileProvider);
      if (!mounted) return;
      await showEditorialDialog<void>(
        context: context,
        title: l10n.profileReadyTitle,
        message: l10n.profileReadyBody,
        icon: Icons.celebration_outlined,
        iconColor: VelvetTokens.ember,
        actions: [
          EditorialDialogAction(
            label: l10n.startDiscovering,
            primary: true,
            onPressed: () => Navigator.pop(context),
          ),
        ],
      );
      if (mounted) context.go('/onboarding/welcome');
    } catch (e) {
      if (mounted) setState(() => error = apiErrorMessage(e));
    } finally {
      if (mounted) setState(() => saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return VelvetAuthScaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 48),
          child: GlassPanel(
            radius: VelvetTheme.radiusLg,
            padding: const EdgeInsets.all(28),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisSize: MainAxisSize.min,
              children: [
                const VelvetWordmark(size: 30),
                const SizedBox(height: VelvetTokens.space24),
                KineticEyebrow(
                  label: l10n.profileSetupTitle,
                  icon: Icons.person_outline,
                ),
                const SizedBox(height: VelvetTokens.space8),
                Center(
                  child: KineticText(
                    text: l10n.profileSetupTitle,
                    style: GoogleFonts.syne(
                      fontSize: VelvetTokens.displayMedium,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -1.3,
                      height: 0.95,
                      color: context.velvet.ink,
                    ),
                  ),
                ),
                const SizedBox(height: VelvetTokens.space8),
                Text(
                  l10n.profileSetupBody,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: context.velvet.muted,
                    height: 1.45,
                  ),
                ),
                      const SizedBox(height: 24),
                      Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                l10n.profileSetupPhotos('${photos.length}/3'),
                                style: Theme.of(context).textTheme.titleSmall,
                              ),
                              const SizedBox(height: 12),
                              Wrap(
                                spacing: 12,
                                runSpacing: 12,
                                children: List.generate(
                                  3,
                                  (i) => SizedBox(
                                    width: 96,
                                    height: 116,
                                    child: i < photos.length
                                        ? ClipRRect(
                                            borderRadius: BorderRadius.circular(
                                              12,
                                            ),
                                            child: Image.network(
                                              photos[i],
                                              fit: BoxFit.cover,
                                            ),
                                          )
                                        : OutlinedButton(
                                            onPressed: saving ? null : addPhoto,
                                            child: const Icon(
                                              Icons.add_a_photo_outlined,
                                            ),
                                          ),
                                  ),
                                ),
                              ),
                            ],
                          )
                          .animate()
                          .fadeIn(delay: 50.ms, duration: 400.ms)
                          .slideY(begin: 0.05, end: 0),
                      const SizedBox(height: 24),
                      Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              VelvetField(
                                controller: city,
                                label: l10n.city,
                                prefixIcon: const Icon(
                                  Icons.location_city_outlined,
                                ),
                                textCapitalization: TextCapitalization.words,
                                autofillHints: const [
                                  AutofillHints.addressCity,
                                ],
                                textInputAction: TextInputAction.next,
                              ),
                              const SizedBox(height: 20),
                              Text(
                                l10n.promptListingEn,
                                style: Theme.of(context).textTheme.titleSmall,
                              ),
                              const SizedBox(height: 8),
                              VelvetField(
                                controller: english,
                                label: l10n.promptAnswerEn,
                                prefixIcon: const Icon(
                                  Icons.format_quote_outlined,
                                ),
                                maxLines: 3,
                                maxLength: 250,
                              ),
                              const SizedBox(height: 20),
                              Text(
                                l10n.promptListingAm,
                                style: Theme.of(context).textTheme.titleSmall,
                              ),
                              const SizedBox(height: 8),
                              VelvetField(
                                controller: amharic,
                                label: l10n.promptAnswerAm,
                                prefixIcon: const Icon(
                                  Icons.format_quote_outlined,
                                ),
                                maxLines: 3,
                                maxLength: 250,
                              ),
                            ],
                          )
                          .animate()
                          .fadeIn(delay: 100.ms, duration: 400.ms)
                          .slideY(begin: 0.05, end: 0),
                      if (_isPerformer) ...[
                        const SizedBox(height: 24),
                        Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  l10n.performerRatesSection,
                                  style: Theme.of(context).textTheme.titleSmall,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  l10n.performerRatesHint,
                                  style: Theme.of(context).textTheme.bodySmall,
                                ),
                                const SizedBox(height: 16),
                                VelvetField(
                                  controller: sessionRate,
                                  label: l10n.sessionRateEtb,
                                  keyboardType: TextInputType.number,
                                  prefixIcon: const Icon(
                                    Icons.payments_outlined,
                                  ),
                                ),
                                const SizedBox(height: 12),
                                VelvetField(
                                  controller: overnightRate,
                                  label: l10n.overnightRateEtb,
                                  keyboardType: TextInputType.number,
                                  prefixIcon: const Icon(
                                    Icons.nights_stay_outlined,
                                  ),
                                ),
                                const SizedBox(height: 12),
                                VelvetField(
                                  controller: availability,
                                  label: l10n.availabilityNote,
                                  prefixIcon: const Icon(
                                    Icons.schedule_outlined,
                                  ),
                                ),
                              ],
                            )
                            .animate()
                            .fadeIn(delay: 150.ms, duration: 400.ms)
                            .slideY(begin: 0.05, end: 0),
                      ],
                      if (error != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 16, bottom: 8),
                          child: Center(
                            child: Text(
                              error!,
                              style: const TextStyle(color: VelvetTheme.danger),
                            ),
                          ),
                        ),
                      const SizedBox(height: 28),
                      VelvetButton(
                        label: l10n.profileSetupFinish,
                        loading: saving,
                        onPressed: saving ? null : finish,
                      ).animate().fadeIn(delay: 200.ms, duration: 400.ms),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

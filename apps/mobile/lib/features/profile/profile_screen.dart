import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:velvet_mobile/core/config/api_config.dart';
import 'package:velvet_mobile/core/location/location_helper.dart';
import 'package:velvet_mobile/core/network/dio_client.dart';
import 'package:velvet_mobile/core/network/media_url.dart';
import 'package:velvet_mobile/core/theme/velvet_editorial_colors.dart';
import 'package:velvet_mobile/core/theme/velvet_theme.dart';
import 'package:velvet_mobile/core/theme/velvet_tokens.dart';
import 'package:velvet_mobile/core/widgets/editorial_dialog.dart';
import 'package:velvet_mobile/core/widgets/editorial_list_card.dart';
import 'package:velvet_mobile/core/widgets/kinetic_text.dart';
import 'package:velvet_mobile/core/widgets/velvet_feedback.dart';
import 'package:velvet_mobile/core/widgets/velvet_filter_chip.dart';
import 'package:velvet_mobile/core/widgets/velvet_widgets.dart';
import 'package:velvet_mobile/features/auth/auth_controller.dart';
import 'package:velvet_mobile/features/auth/role_helpers.dart';
import 'package:velvet_mobile/features/profile/profile_api.dart';
import 'package:velvet_mobile/features/settings/locale_provider.dart';
import 'package:velvet_mobile/features/settings/low_bandwidth_provider.dart';
import 'package:velvet_mobile/features/social/social_api.dart';
import 'package:velvet_mobile/l10n/generated/app_localizations.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  final _nameCtrl = TextEditingController();
  final _cityCtrl = TextEditingController();
  final _bioEnCtrl = TextEditingController();
  final _bioAmCtrl = TextEditingController();
  final _languagesCtrl = TextEditingController();
  final _sessionRateCtrl = TextEditingController();
  final _overnightRateCtrl = TextEditingController();
  final _availabilityCtrl = TextEditingController();
  DateTime? _dob;
  String? _gender;
  bool _listingActive = true;
  bool _saving = false;
  bool _seeded = false;
  final Set<String> _interests = {};

  static const _interestOptions = [
    'Slow burn',
    'Playful',
    'Sophisticated',
    'Soft & romantic',
    'Confident',
    'Discreet',
    'Late night',
    'Verified venue',
  ];

  @override
  void dispose() {
    _nameCtrl.dispose();
    _cityCtrl.dispose();
    _bioEnCtrl.dispose();
    _bioAmCtrl.dispose();
    _languagesCtrl.dispose();
    _sessionRateCtrl.dispose();
    _overnightRateCtrl.dispose();
    _availabilityCtrl.dispose();
    super.dispose();
  }

  void _seed(MeProfile me) {
    if (_seeded) return;
    _seeded = true;
    if (me.displayName?.isNotEmpty ?? false) _nameCtrl.text = me.displayName!;
    if (me.city?.isNotEmpty ?? false) _cityCtrl.text = me.city!;
    if (me.bioEn?.isNotEmpty ?? false) _bioEnCtrl.text = me.bioEn!;
    if (me.bioAm?.isNotEmpty ?? false) _bioAmCtrl.text = me.bioAm!;
    _languagesCtrl.text = me.languages ?? '';
    if (me.sessionRateEtb != null) {
      _sessionRateCtrl.text = '${me.sessionRateEtb}';
    }
    if (me.overnightRateEtb != null) {
      _overnightRateCtrl.text = '${me.overnightRateEtb}';
    }
    _availabilityCtrl.text = me.availabilityNote ?? '';
    _listingActive = me.listingActive;
    if (me.dateOfBirth != null && me.dateOfBirth!.isNotEmpty) {
      _dob = DateTime.tryParse(me.dateOfBirth!);
    }
    _gender = me.gender;
    _interests.addAll(me.interests);
  }

  Future<void> _pickDob() async {
    final now = DateTime.now();
    final initial = _dob ?? DateTime(now.year - 25);
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(1920),
      lastDate: DateTime(now.year - 21, now.month, now.day),
      helpText: AppLocalizations.of(context).ageRequirement,
    );
    if (picked != null) setState(() => _dob = picked);
  }

  Future<void> _pickPhoto() async {
    final l10n = AppLocalizations.of(context);
    final source = await showEditorialActionSheet<ImageSource>(
      context: context,
      title: l10n.profilePhotos,
      options: [
        EditorialSheetOption(
          value: ImageSource.camera,
          label: l10n.takePhoto,
          icon: Icons.photo_camera_outlined,
        ),
        EditorialSheetOption(
          value: ImageSource.gallery,
          label: l10n.chooseGallery,
          icon: Icons.photo_library_outlined,
        ),
      ],
    );
    if (source == null) return;
    final lowBw = ref.read(lowBandwidthProvider);
    final file = await ImagePicker().pickImage(
      source: source,
      imageQuality: imagePickQuality(lowBw),
      maxWidth: imagePickMaxWidth(lowBw).toDouble(),
    );
    if (file == null) return;
    try {
      final api = ref.read(profileApiProvider);
      final uploaded = await api.uploadPhoto(file.path);
      await api.addPhoto(uploaded.url);
      ref.invalidate(meProfileProvider);
      if (mounted) {
        final msg = uploaded.qualityStatus == 'NEEDS_REVIEW'
            ? l10n.photoPendingReview
            : l10n.photoAdded;
        await showVelvetToast(context, message: msg);
      }
    } catch (e) {
      if (mounted) {
        showVelvetErrorToast(context, message: apiErrorMessage(e));
      }
    }
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    try {
      final me = ref.read(meProfileProvider).asData?.value;
      final isPerformer = isPerformerRole(me?.role);
      final updated = await ref
          .read(profileApiProvider)
          .update(
            displayName: _nameCtrl.text.trim(),
            city: _cityCtrl.text.trim(),
            bioEn: _bioEnCtrl.text.trim(),
            bioAm: _bioAmCtrl.text.trim(),
            languages: isPerformer ? _languagesCtrl.text.trim() : null,
            sessionRateEtb: isPerformer
                ? int.tryParse(_sessionRateCtrl.text.trim())
                : null,
            overnightRateEtb: isPerformer
                ? int.tryParse(_overnightRateCtrl.text.trim())
                : null,
            availabilityNote: isPerformer
                ? _availabilityCtrl.text.trim()
                : null,
            listingActive: isPerformer ? _listingActive : null,
            gender: _gender,
            interests: isPerformer ? _interests.toList() : const [],
            dateOfBirth: _dob == null
                ? null
                : '${_dob!.year.toString().padLeft(4, '0')}-'
                      '${_dob!.month.toString().padLeft(2, '0')}-'
                      '${_dob!.day.toString().padLeft(2, '0')}',
          );
      // Keep the cached session in sync so role-specific discovery/navigation
      // updates immediately after a member changes this profile setting.
      ref.read(authControllerProvider).setGender(_gender, role: updated.role);
      ref
          .read(authControllerProvider)
          .setProfileReady(
            updated.photoUrls.length >= 3 &&
                updated.city?.trim().isNotEmpty == true &&
                updated.bioEn?.trim().isNotEmpty == true &&
                updated.bioAm?.trim().isNotEmpty == true,
          );
      ref.invalidate(meProfileProvider);
      if (mounted) {
        await showVelvetToast(
          context,
          message: AppLocalizations.of(context).save,
          icon: Icons.check_rounded,
        );
      }
    } catch (e) {
      if (mounted) {
        showVelvetErrorToast(context, message: apiErrorMessage(e));
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _openLegal(String path) async {
    await launchUrl(
      Uri.parse('${ApiConfig.baseUrl}$path'),
      mode: LaunchMode.externalApplication,
    );
  }

  Future<void> _panic() async {
    final l10n = AppLocalizations.of(context);
    final ok = await showEditorialConfirm(
      context: context,
      title: l10n.panicButton,
      message: l10n.panicConfirm,
      confirmLabel: l10n.panicButton,
      cancelLabel: l10n.declineRequest,
      destructive: true,
    );
    if (ok != true) return;
    try {
      final pos = await LocationHelper.currentOrNull();
      await ref
          .read(safetyApiProvider)
          .panic(
            note: 'Panic from profile',
            latitude: pos?.latitude,
            longitude: pos?.longitude,
          );
      if (mounted) {
        await showEditorialDialog<void>(
          context: context,
          title: l10n.panicSent,
          message: l10n.panicSentDetails,
          icon: Icons.check_circle_outline_rounded,
          iconColor: VelvetTheme.teal,
          actions: [
            EditorialDialogAction(
              label: l10n.close,
              primary: true,
              onPressed: () => Navigator.pop(context),
            ),
          ],
        );
      }
    } catch (e) {
      if (mounted) {
        showVelvetErrorToast(context, message: apiErrorMessage(e));
      }
    }
  }

  Widget _navTile({
    required String title,
    String? subtitle,
    required VoidCallback onTap,
    IconData icon = Icons.north_east_rounded,
    Color accent = VelvetTokens.ember,
  }) {
    return EditorialNavSlab(
      title: title,
      subtitle: subtitle,
      icon: icon,
      index: title.hashCode.abs() % 5,
      accent: accent,
      onTap: onTap,
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final locale = ref.watch(localeProvider);
    final meAsync = ref.watch(meProfileProvider);

    return VelvetScaffold(
      mistIntensity: 0.55,
      extendBody: true,
      safeArea: false,
      body: meAsync.when(
        loading: () => const VelvetContentLoading(),
        error: (e, _) => VelvetEmptyState(
          title: l10n.profile,
          message: apiErrorMessage(e),
          icon: Icons.person_outline,
          actionLabel: l10n.retry,
          onAction: () => ref.invalidate(meProfileProvider),
        ),
        data: (me) {
          _seed(me);
          final isPerformer = isPerformerRole(me.role);
          return CustomScrollView(
            physics: const BouncingScrollPhysics(
              parent: AlwaysScrollableScrollPhysics(),
            ),
            slivers: [
              SliverAppBar(
                expandedHeight: 480,
                pinned: true,
                stretch: true,
                backgroundColor: Colors.transparent,
                elevation: 0,
                flexibleSpace: FlexibleSpaceBar(
                  stretchModes: const [
                    StretchMode.zoomBackground,
                    StretchMode.blurBackground,
                  ],
                  titlePadding: const EdgeInsets.only(
                    left: 20,
                    right: 20,
                    bottom: 20,
                  ),
                  title: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.profile,
                        style: GoogleFonts.syne(
                          fontSize: VelvetTokens.displaySmall,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                          height: 0.95,
                          letterSpacing: -0.8,
                          shadows: [
                            Shadow(
                              color: Colors.black.withValues(alpha: 0.75),
                              blurRadius: 24,
                            ),
                          ],
                        ),
                      ),
                      Text(
                        me.phone,
                        style: TextStyle(
                          fontSize: 14,
                          color: VelvetTheme.champagne.withValues(alpha: 0.9),
                          shadows: [
                            Shadow(
                              color: Colors.black.withValues(alpha: 0.8),
                              blurRadius: 10,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  background: Stack(
                    fit: StackFit.expand,
                    children: [
                      if (me.photoUrls.isNotEmpty)
                        Image.network(
                          resolveMediaUrl(me.photoUrls.first),
                          fit: BoxFit.cover,
                        )
                      else
                        Container(color: VelvetTheme.nightSoft),
                      DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.transparent,
                              VelvetTheme.night.withValues(alpha: 0.4),
                              VelvetTheme.night,
                            ],
                            stops: const [0.4, 0.85, 1.0],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SliverPadding(
                padding: EdgeInsets.fromLTRB(
                  20,
                  16,
                  20,
                  100 + MediaQuery.paddingOf(context).bottom,
                ),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            _RoleChip(
                              label: me.role,
                              color:
                                  me.role == 'ADMIN' || me.role == 'CONCIERGE'
                                  ? VelvetTheme.mistSlate
                                  : VelvetTheme.teal,
                            ),
                            if (me.gender == 'MALE')
                              _RoleChip(
                                label: l10n.genderMale.split(' — ').first,
                                color: VelvetTheme.lapis,
                              ),
                            if (me.gender == 'FEMALE')
                              _RoleChip(
                                label: l10n.genderFemale.split(' — ').first,
                                color: VelvetTheme.tealDeep,
                              ),
                            if (me.trustScore != null && me.trustScore! >= 80)
                              const VelvetTrustedBadge(compact: true),
                          ],
                        ),
                        const SizedBox(height: 12),
                        StatusRibbon(status: me.status),
                        const SizedBox(height: 24),
                        KineticEyebrow(
                          label: l10n.profilePhotos,
                          icon: Icons.photo_library_outlined,
                        ),
                        const SizedBox(height: 6),
                        Text(
                          l10n.reorderPhotosHint,
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(color: context.velvet.muted),
                        ),
                        const SizedBox(height: 10),
                        GlassPanel(
                          padding: const EdgeInsets.all(12),
                          fill: VelvetTheme.glassFill,
                          child: SizedBox(
                            height: 96,
                            child: Row(
                              children: [
                                Expanded(
                                  child: ReorderableListView.builder(
                                    scrollDirection: Axis.horizontal,
                                    buildDefaultDragHandles: false,
                                    itemCount: me.photoUrls.length,
                                    onReorderItem: (oldIndex, newIndex) async {
                                      final next = List<String>.from(
                                        me.photoUrls,
                                      );
                                      final item = next.removeAt(oldIndex);
                                      next.insert(newIndex, item);
                                      try {
                                        await ref
                                            .read(profileApiProvider)
                                            .reorderPhotos(next);
                                        HapticFeedback.selectionClick();
                                        ref.invalidate(meProfileProvider);
                                        if (context.mounted) {
                                          await showVelvetToast(
                                            context,
                                            message: l10n.photosReordered,
                                            icon: Icons.swap_vert_rounded,
                                          );
                                        }
                                      } catch (e) {
                                        if (context.mounted) {
                                          showVelvetErrorToast(
                                            context,
                                            message: apiErrorMessage(e),
                                          );
                                        }
                                      }
                                    },
                                    itemBuilder: (context, index) {
                                      final url = me.photoUrls[index];
                                      final lowBw = ref.watch(
                                        lowBandwidthProvider,
                                      );
                                      return ReorderableDelayedDragStartListener(
                                        key: ValueKey(url),
                                        index: index,
                                        child: Padding(
                                          padding: const EdgeInsets.only(
                                            right: 10,
                                          ),
                                          child: Stack(
                                            children: [
                                              ClipRRect(
                                                borderRadius:
                                                    BorderRadius.circular(10),
                                                child: Image.network(
                                                  resolveMediaUrl(url),
                                                  width: 96,
                                                  height: 96,
                                                  fit: BoxFit.cover,
                                                  cacheWidth: mediaCacheWidth(
                                                    lowBw,
                                                    full: 280,
                                                    compressed: 160,
                                                  ),
                                                  errorBuilder: (_, _, _) =>
                                                      Container(
                                                        width: 96,
                                                        height: 96,
                                                        color: VelvetTheme.line,
                                                        child: const Icon(
                                                          Icons
                                                              .broken_image_outlined,
                                                        ),
                                                      ),
                                                ),
                                              ),
                                              if (index == 0)
                                                Positioned(
                                                  left: 4,
                                                  bottom: 4,
                                                  child: Container(
                                                    padding:
                                                        const EdgeInsets.symmetric(
                                                          horizontal: 6,
                                                          vertical: 2,
                                                        ),
                                                    decoration: BoxDecoration(
                                                      color: VelvetTheme.teal,
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                            6,
                                                          ),
                                                    ),
                                                    child: const Text(
                                                      '1',
                                                      style: TextStyle(
                                                        color: Colors.white,
                                                        fontSize: 10,
                                                        fontWeight:
                                                            FontWeight.w700,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              Positioned(
                                                top: 2,
                                                right: 2,
                                                child: IconButton.filledTonal(
                                                  iconSize: 16,
                                                  padding: EdgeInsets.zero,
                                                  constraints:
                                                      const BoxConstraints(
                                                        minWidth: 28,
                                                        minHeight: 28,
                                                      ),
                                                  onPressed: () async {
                                                    final remove =
                                                        await showEditorialConfirm(
                                                      context: context,
                                                      title: l10n.removePhoto,
                                                      message:
                                                          l10n.removePhotoConfirm,
                                                      confirmLabel:
                                                          l10n.removePhoto,
                                                      cancelLabel: l10n.close,
                                                      destructive: true,
                                                    );
                                                    if (remove != true) return;
                                                    try {
                                                      final updated = await ref
                                                          .read(
                                                            profileApiProvider,
                                                          )
                                                          .removePhoto(url);
                                                      if (updated
                                                              .photoUrls
                                                              .length <
                                                          3) {
                                                        ref
                                                            .read(
                                                              authControllerProvider,
                                                            )
                                                            .setProfileReady(
                                                              false,
                                                            );
                                                      }
                                                      ref.invalidate(
                                                        meProfileProvider,
                                                      );
                                                    } catch (e) {
                                                      if (context.mounted) {
                                                        showVelvetErrorToast(
                                                          context,
                                                          message: apiErrorMessage(e),
                                                        );
                                                      }
                                                    }
                                                  },
                                                  icon: const Icon(Icons.close),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                                if (me.photoUrls.length < 3)
                                  OutlinedButton(
                                    onPressed: _pickPhoto,
                                    style: OutlinedButton.styleFrom(
                                      minimumSize: const Size(96, 96),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                    ),
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        const Icon(
                                          Icons.add_a_photo_outlined,
                                          color: VelvetTheme.teal,
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          l10n.addPhoto,
                                          style: const TextStyle(fontSize: 12),
                                        ),
                                      ],
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        GlassPanel(
                          padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
                          fill: VelvetTheme.glassFill,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              VelvetField(
                                controller: _nameCtrl,
                                label: l10n.displayName,
                              ),
                              const SizedBox(height: 12),
                              VelvetField(
                                controller: _cityCtrl,
                                label: l10n.city,
                              ),
                              const SizedBox(height: 12),
                              Text(
                                l10n.genderLabel,
                                style: Theme.of(context).textTheme.titleSmall,
                              ),
                              const SizedBox(height: 8),
                              SegmentedButton<String>(
                                segments: [
                                  ButtonSegment(
                                    value: 'MALE',
                                    label: Text(l10n.genderMale),
                                  ),
                                  ButtonSegment(
                                    value: 'FEMALE',
                                    label: Text(l10n.genderFemale),
                                  ),
                                ],
                                emptySelectionAllowed: true,
                                selected: {?_gender},
                                onSelectionChanged: (s) {
                                  setState(
                                    () => _gender = s.isEmpty ? null : s.first,
                                  );
                                },
                              ),
                              const SizedBox(height: 12),
                              InkWell(
                                onTap: _pickDob,
                                borderRadius: BorderRadius.circular(10),
                                child: InputDecorator(
                                  decoration: InputDecoration(
                                    labelText: l10n.dateOfBirth,
                                  ),
                                  child: Text(
                                    _dob == null
                                        ? l10n.ageRequirement
                                        : '${_dob!.year}-${_dob!.month.toString().padLeft(2, '0')}-${_dob!.day.toString().padLeft(2, '0')}',
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyMedium
                                        ?.copyWith(
                                          color: _dob == null
                                              ? VelvetTheme.muted
                                              : VelvetTheme.ink,
                                        ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 12),
                              if (!isPerformer) ...[
                                Text(
                                  l10n.profileClientHint,
                                  style: Theme.of(context).textTheme.bodySmall
                                      ?.copyWith(color: context.velvet.muted),
                                ),
                                const SizedBox(height: 12),
                              ],
                              VelvetField(
                                controller: _bioEnCtrl,
                                label: isPerformer
                                    ? l10n.promptListingEn
                                    : l10n.bioEn,
                                maxLines: 3,
                                maxLength: 500,
                              ),
                              const SizedBox(height: 8),
                              VelvetField(
                                controller: _bioAmCtrl,
                                label: isPerformer
                                    ? l10n.promptListingAm
                                    : l10n.bioAm,
                                maxLines: 3,
                                maxLength: 500,
                              ),
                              if (isPerformer) ...[
                                const SizedBox(height: 16),
                                Text(
                                  l10n.profileListingSection,
                                  style: Theme.of(context).textTheme.titleSmall,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  l10n.profileDetailsOptional,
                                  style: Theme.of(context).textTheme.bodySmall
                                      ?.copyWith(color: context.velvet.muted),
                                ),
                                const SizedBox(height: 8),
                                VelvetField(
                                  controller: _languagesCtrl,
                                  label: l10n.languagesSpoken,
                                  hint: l10n.languagesSpokenHint,
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  l10n.performerRatesSection,
                                  style: Theme.of(context).textTheme.titleSmall,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  l10n.performerRatesHint,
                                  style: Theme.of(context).textTheme.bodySmall,
                                ),
                                const SizedBox(height: 8),
                                VelvetField(
                                  controller: _sessionRateCtrl,
                                  label: l10n.sessionRateEtb,
                                  keyboardType: TextInputType.number,
                                ),
                                const SizedBox(height: 8),
                                VelvetField(
                                  controller: _overnightRateCtrl,
                                  label: l10n.overnightRateEtb,
                                  keyboardType: TextInputType.number,
                                ),
                                const SizedBox(height: 8),
                                VelvetField(
                                  controller: _availabilityCtrl,
                                  label: l10n.availabilityNote,
                                ),
                                EditorialToggleRow(
                                  index: 3,
                                  title: l10n.listingActive,
                                  subtitle: me.status == 'VERIFIED'
                                      ? null
                                      : l10n.listingRequiresVerification,
                                  value: _listingActive,
                                  enabled: me.status == 'VERIFIED',
                                  onChanged: me.status == 'VERIFIED'
                                      ? (v) =>
                                            setState(() => _listingActive = v)
                                      : null,
                                ),
                                if (me.status != 'VERIFIED')
                                  TextButton(
                                    onPressed: () =>
                                        context.push('/verification'),
                                    child: Text(l10n.verifyToListCta),
                                  ),
                                const SizedBox(height: 16),
                                Text(
                                  l10n.listingTagsLabel,
                                  style: Theme.of(context).textTheme.titleSmall,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  l10n.listingTagsHint,
                                  style: Theme.of(context).textTheme.bodySmall,
                                ),
                                const SizedBox(height: 10),
                                Wrap(
                                  spacing: 8,
                                  runSpacing: 8,
                                  children: _interestOptions.map((label) {
                                    final selected = _interests.contains(label);
                                    return VelvetFilterChip(
                                      label: label,
                                      selected: selected,
                                      onChanged: (v) {
                                        setState(() {
                                          if (v) {
                                            _interests.add(label);
                                          } else {
                                            _interests.remove(label);
                                          }
                                        });
                                      },
                                    );
                                  }).toList(),
                                ),
                              ],
                              const SizedBox(height: 16),
                              VelvetButton(
                                label: l10n.save,
                                loading: _saving,
                                onPressed: _saving ? null : _save,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 28),
                        KineticEyebrow(
                          label: l10n.safetyTitle,
                          icon: Icons.shield_outlined,
                        ),
                        const SizedBox(height: 10),
                        _navTile(
                          title: l10n.safetyCenterTitle,
                          onTap: () => context.push('/safety'),
                        ),
                        _navTile(
                          title: l10n.verificationTitle,
                          onTap: () => context.push('/verification'),
                        ),
                        _navTile(
                          title: l10n.blockedMembers,
                          onTap: () => context.push('/blocked'),
                        ),
                        VelvetButton(
                          label: l10n.panicButton,
                          variant: VelvetButtonVariant.danger,
                          icon: Icons.emergency_outlined,
                          onPressed: _panic,
                        ),
                        const SizedBox(height: 28),
                        KineticEyebrow(
                          label: l10n.lowBandwidthMode,
                          icon: Icons.speed_outlined,
                        ),
                        const SizedBox(height: 8),
                        EditorialToggleRow(
                          index: 4,
                          title: l10n.lowBandwidthMode,
                          subtitle: l10n.lowBandwidthHint,
                          value: ref.watch(lowBandwidthProvider),
                          onChanged: (v) => ref
                              .read(lowBandwidthProvider.notifier)
                              .setEnabled(v),
                        ),
                        const SizedBox(height: 28),
                        _navTile(
                          title: l10n.connectionHistoryTitle,
                          onTap: () => context.push('/connections/history'),
                        ),
                        if (isPerformer)
                          _navTile(
                            title: l10n.earningsTitle,
                            onTap: () => context.push('/earnings'),
                          ),
                        if (isPerformer)
                          _navTile(
                            title: l10n.availabilityCalendarTitle,
                            onTap: () => context.push('/availability'),
                          ),
                        _navTile(
                          title: l10n.legalDocuments,
                          icon: Icons.open_in_new,
                          onTap: () => _openLegal('/legal/'),
                        ),
                        const SizedBox(height: 8),
                        GlassPanel(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 10,
                          ),
                          fill: VelvetTheme.glassFill,
                          child: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  l10n.language,
                                  style: GoogleFonts.inter(
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                              SegmentedButton<String>(
                                segments: const [
                                  ButtonSegment(value: 'am', label: Text('አማ')),
                                  ButtonSegment(value: 'en', label: Text('EN')),
                                ],
                                selected: {locale.languageCode},
                                onSelectionChanged: (s) {
                                  ref
                                      .read(localeProvider.notifier)
                                      .setLocale(Locale(s.first));
                                },
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 28),
                        VelvetButton(
                          label: l10n.signOut,
                          variant: VelvetButtonVariant.ghost,
                          onPressed: () =>
                              ref.read(authControllerProvider).signOut(),
                        ),
                        const SizedBox(height: 12),
                        TextButton(
                          onPressed: () async {
                            try {
                              final data = await ref
                                  .read(profileApiProvider)
                                  .exportData();
                              if (!context.mounted) return;
                              final pretty = const JsonEncoder.withIndent(
                                '  ',
                              ).convert(data);
                              await showEditorialDialog<void>(
                                context: context,
                                title: l10n.exportMyData,
                                content: SizedBox(
                                  width: double.maxFinite,
                                  height: 320,
                                  child: SingleChildScrollView(
                                    child: SelectableText(pretty),
                                  ),
                                ),
                                actions: [
                                  EditorialDialogAction(
                                    label: l10n.copied,
                                    onPressed: () async {
                                      await Clipboard.setData(
                                        ClipboardData(text: pretty),
                                      );
                                      if (context.mounted) {
                                        Navigator.pop(context);
                                      }
                                    },
                                  ),
                                  EditorialDialogAction(
                                    label: l10n.close,
                                    primary: true,
                                    onPressed: () => Navigator.pop(context),
                                  ),
                                ],
                              );
                            } catch (e) {
                              if (context.mounted) {
                                showVelvetErrorToast(context, message: '$e');
                              }
                            }
                          },
                          child: Text(l10n.exportMyData),
                        ),
                        TextButton(
                          onPressed: () async {
                            final ok = await showEditorialConfirm(
                              context: context,
                              title: l10n.withdrawAccount,
                              message: l10n.withdrawConfirm,
                              confirmLabel: l10n.withdrawAccount,
                              cancelLabel: l10n.declineRequest,
                              destructive: true,
                            );
                            if (ok != true) return;
                            try {
                              await ref
                                  .read(authControllerProvider)
                                  .withdrawAccount();
                            } catch (e) {
                              if (context.mounted) {
                                showVelvetErrorToast(context, message: '$e');
                              }
                            }
                          },
                          child: Text(
                            l10n.withdrawAccount,
                            style: const TextStyle(color: VelvetTheme.danger),
                          ),
                        ),
                        TextButton(
                          onPressed: () async {
                            final ok = await showEditorialConfirm(
                              context: context,
                              title: l10n.eraseMyData,
                              message: l10n.eraseConfirm,
                              confirmLabel: l10n.eraseMyData,
                              cancelLabel: l10n.declineRequest,
                              destructive: true,
                            );
                            if (ok != true) return;
                            try {
                              await ref
                                  .read(authControllerProvider)
                                  .eraseAccount();
                            } catch (e) {
                              if (context.mounted) {
                                showVelvetErrorToast(context, message: '$e');
                              }
                            }
                          },
                          child: Text(
                            l10n.eraseMyData,
                            style: const TextStyle(color: VelvetTheme.danger),
                          ),
                        ),
                      ],
                    ),
                  ]),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _RoleChip extends StatelessWidget {
  const _RoleChip({required this.label, required this.color});
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.28)),
      ),
      child: Text(
        label,
        style: GoogleFonts.inter(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          color: color,
        ),
      ),
    );
  }
}

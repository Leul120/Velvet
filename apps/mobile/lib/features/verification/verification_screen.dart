import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:velvet_mobile/core/network/dio_client.dart';
import 'package:velvet_mobile/core/theme/velvet_theme.dart';
import 'package:velvet_mobile/core/theme/velvet_editorial_colors.dart';
import 'package:velvet_mobile/core/theme/velvet_tokens.dart';
import 'package:velvet_mobile/core/widgets/editorial_dialog.dart';
import 'package:velvet_mobile/core/widgets/kinetic_text.dart';
import 'package:velvet_mobile/core/widgets/velvet_feedback.dart';
import 'package:velvet_mobile/core/widgets/verification_capture.dart';
import 'package:velvet_mobile/core/widgets/velvet_widgets.dart';
import 'package:velvet_mobile/features/connections/connections_api.dart';
import 'package:velvet_mobile/l10n/generated/app_localizations.dart';

class VerificationScreen extends ConsumerStatefulWidget {
  const VerificationScreen({super.key});

  @override
  ConsumerState<VerificationScreen> createState() => _VerificationScreenState();
}

class _VerificationScreenState extends ConsumerState<VerificationScreen> {
  String? _idUrl;
  String? _selfieUrl;
  bool _loading = false;
  String? _error;
  final _picker = ImagePicker();

  Future<void> _pick(String kind) async {
    final l10n = AppLocalizations.of(context);
    final source = await showEditorialActionSheet<ImageSource>(
      context: context,
      title: l10n.verificationTitle,
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

    final file = await _picker.pickImage(source: source, imageQuality: 90, maxWidth: 2048);
    if (file == null) return;

    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final url = await ref.read(verificationApiProvider).upload(kind: kind, filePath: file.path);
      setState(() {
        if (kind == 'id') {
          _idUrl = url;
        } else {
          _selfieUrl = url;
        }
      });
    } catch (e) {
      if (mounted) setState(() => _error = apiErrorMessage(e));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _submit() async {
    if (_idUrl == null || _selfieUrl == null) {
      setState(() => _error = AppLocalizations.of(context).uploadBothRequired);
      return;
    }
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      await ref.read(verificationApiProvider).submit(
            idDocumentUrl: _idUrl!,
            selfieUrl: _selfieUrl!,
          );
      ref.invalidate(verificationProvider);
      if (mounted) {
        setState(() {
          _idUrl = null;
          _selfieUrl = null;
        });
        await showVelvetToast(
          context,
          message: AppLocalizations.of(context).verificationSubmittedPending,
          icon: Icons.verified_user_outlined,
        );
      }
    } catch (e) {
      if (mounted) setState(() => _error = apiErrorMessage(e));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  int get _completedSteps =>
      (_idUrl != null ? 1 : 0) + (_selfieUrl != null ? 1 : 0);

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final verification = ref.watch(verificationProvider);
    final existing = verification.valueOrNull;
    final status = existing?.status.toUpperCase();
    final awaitingReview = status == 'PENDING' || status == 'SUBMITTED' || status == 'UNDER_REVIEW';
    final approved = status == 'APPROVED' || status == 'VERIFIED';
    final rejected = status == 'REJECTED';
    final canSubmit = !awaitingReview && !approved;

    return VelvetAuthScaffold(
      body: ListView(
        padding: const EdgeInsets.fromLTRB(24, 8, 24, 28),
        children: [
          Row(
            children: [
              VelvetIconChip(
                icon: Icons.arrow_back_ios_new_rounded,
                onTap: () => Navigator.of(context).maybePop(),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    KineticEyebrow(
                      label: l10n.verificationTitle,
                      icon: Icons.verified_user_outlined,
                    ),
                    KineticText(
                      text: l10n.verificationTitle,
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
          const SizedBox(height: VelvetTokens.space20),
          verification.when(
            data: (v) {
              if (v == null) {
                return Text(
                  l10n.verificationNone,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: context.velvet.muted),
                );
              }
              return Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: approved
                        ? [
                            VelvetTokens.emberSoft.withValues(alpha: 0.22),
                            VelvetTokens.parchmentLift.withValues(alpha: 0.96),
                          ]
                        : rejected
                        ? [
                            VelvetTheme.danger.withValues(alpha: 0.08),
                            VelvetTokens.parchmentLift.withValues(alpha: 0.94),
                          ]
                        : [
                            VelvetTokens.parchmentDeep.withValues(alpha: 0.4),
                            VelvetTokens.parchmentLift.withValues(alpha: 0.92),
                          ],
                  ),
                  borderRadius: BorderRadius.circular(VelvetTokens.radiusLg),
                  border: Border.all(
                    color: approved
                        ? VelvetTokens.ember.withValues(alpha: 0.32)
                        : rejected
                        ? VelvetTheme.danger.withValues(alpha: 0.28)
                        : VelvetTokens.line.withValues(alpha: 0.75),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          '${l10n.verificationStatus}: ',
                          style: GoogleFonts.dmSans(fontWeight: FontWeight.w600),
                        ),
                        StatusRibbon(status: v.status),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Text(
                      approved
                          ? l10n.verificationApproved
                          : rejected
                              ? l10n.verificationRejected
                              : l10n.verificationSubmittedPending,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        height: 1.45,
                      ),
                    ),
                    if (v.notes != null && v.notes!.trim().isNotEmpty) ...[
                      const SizedBox(height: 10),
                      Text(
                        v.notes!,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          fontStyle: FontStyle.italic,
                          color: context.velvet.muted,
                        ),
                      ),
                    ],
                  ],
                ),
              );
            },
            loading: () => const LinearProgressIndicator(),
            error: (e, _) => Text('$e', style: const TextStyle(color: VelvetTheme.danger)),
          ),
          const SizedBox(height: VelvetTokens.space24),
          Text(
            canSubmit ? l10n.verificationHint : l10n.verificationReviewHint,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: context.velvet.muted, height: 1.45),
          ),
          if (canSubmit) ...[
            const SizedBox(height: VelvetTokens.space20),
            VerificationProgressRail(
              completedSteps: _completedSteps,
              totalSteps: 2,
            ),
            const SizedBox(height: VelvetTokens.space24),
            VerificationCaptureZone(
              stepNumber: 1,
              title: l10n.idDocumentUrl,
              subtitle: _idUrl != null ? l10n.uploaded : l10n.notUploaded,
              done: _idUrl != null,
              enabled: !_loading,
              onTap: () => _pick('id'),
            ),
            VerificationCaptureZone(
              stepNumber: 2,
              title: l10n.selfieUrl,
              subtitle: _selfieUrl != null ? l10n.uploaded : l10n.notUploaded,
              done: _selfieUrl != null,
              enabled: !_loading,
              onTap: () => _pick('selfie'),
            ),
          ],
          if (_error != null) ...[
            const SizedBox(height: 8),
            Text(_error!, style: const TextStyle(color: VelvetTheme.danger)),
          ],
          const SizedBox(height: VelvetTokens.space24),
          VelvetButton(
            label: l10n.submitVerification,
            loading: _loading,
            onPressed: _loading || !canSubmit ? null : _submit,
          ),
        ],
      ),
    );
  }
}

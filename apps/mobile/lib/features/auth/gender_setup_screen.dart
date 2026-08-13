import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:velvet_mobile/core/network/dio_client.dart';
import 'package:velvet_mobile/core/theme/velvet_editorial_colors.dart';
import 'package:velvet_mobile/core/theme/velvet_theme.dart';
import 'package:velvet_mobile/core/theme/velvet_tokens.dart';
import 'package:velvet_mobile/core/widgets/velvet_widgets.dart';
import 'package:velvet_mobile/features/auth/auth_controller.dart';
import 'package:velvet_mobile/features/profile/profile_api.dart';
import 'package:velvet_mobile/l10n/generated/app_localizations.dart';

/// Forced after legal accept when gender is missing — clients browse listings; performers receive requests.
class GenderSetupScreen extends ConsumerStatefulWidget {
  const GenderSetupScreen({super.key});

  @override
  ConsumerState<GenderSetupScreen> createState() => _GenderSetupScreenState();
}

class _GenderSetupScreenState extends ConsumerState<GenderSetupScreen> {
  String? _gender;
  bool _loading = false;
  String? _error;

  Future<void> _save() async {
    if (_gender == null) {
      setState(() => _error = AppLocalizations.of(context).genderMustSelect);
      return;
    }
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      await ref.read(profileApiProvider).update(gender: _gender);
      final me = await ref.read(profileApiProvider).me();
      ref.read(authControllerProvider).setGender(_gender!, role: me.role);
      ref.invalidate(meProfileProvider);
      if (mounted) context.go('/onboarding/profile');
    } catch (e) {
      if (mounted) setState(() => _error = apiErrorMessage(e));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colors = context.velvet;

    return VelvetAuthScaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 20, 24, 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const VelvetWordmark(size: 36, breathe: true)
                  .animate()
                  .fadeIn(duration: 400.ms),
              const SizedBox(height: 28),
              Text(
                l10n.genderSetupTitle,
                style: GoogleFonts.syne(
                  fontSize: 32,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.9,
                  height: 0.98,
                  color: colors.ink,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                l10n.genderSetupBody,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: colors.muted,
                      height: 1.45,
                    ),
              ),
              const SizedBox(height: 28),
              Container(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
                decoration: BoxDecoration(
                  color: colors.parchmentLift,
                  borderRadius: BorderRadius.circular(VelvetTokens.radiusLg),
                  border: Border.all(color: colors.line.withValues(alpha: 0.7)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.35),
                      blurRadius: 28,
                      offset: const Offset(0, 12),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    _GenderChoice(
                      label: l10n.genderMale,
                      selected: _gender == 'MALE',
                      onTap: () => setState(() => _gender = 'MALE'),
                    ),
                    const SizedBox(height: 10),
                    _GenderChoice(
                      label: l10n.genderFemale,
                      selected: _gender == 'FEMALE',
                      onTap: () => setState(() => _gender = 'FEMALE'),
                    ),
                  ],
                ),
              ).animate().fadeIn(delay: 80.ms).slideY(begin: 0.04, end: 0),
              if (_error != null) ...[
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: VelvetTheme.danger.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: VelvetTheme.danger.withValues(alpha: 0.35),
                    ),
                  ),
                  child: Text(
                    _error!,
                    style: const TextStyle(
                      color: VelvetTheme.danger,
                      height: 1.35,
                    ),
                  ),
                ),
              ],
              const Spacer(),
              FilledButton(
                onPressed: _loading ? null : _save,
                style: FilledButton.styleFrom(
                  minimumSize: const Size.fromHeight(54),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
                child: _loading
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: VelvetTokens.onPrimary,
                        ),
                      )
                    : Text(l10n.continueLabel),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _GenderChoice extends StatelessWidget {
  const _GenderChoice({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.velvet;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: AnimatedContainer(
          duration: VelvetTokens.motionFast,
          curve: Curves.easeOutCubic,
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
          decoration: BoxDecoration(
            color: selected
                ? VelvetTokens.ember
                : colors.parchmentDeep.withValues(alpha: 0.55),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: selected
                  ? VelvetTokens.emberDeep.withValues(alpha: 0.55)
                  : colors.line.withValues(alpha: 0.7),
            ),
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  label,
                  style: GoogleFonts.syne(
                    fontWeight: FontWeight.w700,
                    fontSize: 17,
                    letterSpacing: -0.3,
                    color: selected ? VelvetTokens.onPrimary : colors.ink,
                  ),
                ),
              ),
              Icon(
                selected ? Icons.check_circle_rounded : Icons.circle_outlined,
                color: selected ? VelvetTokens.onPrimary : colors.muted,
                size: 22,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

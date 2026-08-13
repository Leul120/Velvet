import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:velvet_mobile/core/network/dio_client.dart';
import 'package:velvet_mobile/core/theme/velvet_theme.dart';
import 'package:velvet_mobile/core/theme/velvet_editorial_colors.dart';
import 'package:velvet_mobile/core/theme/velvet_tokens.dart';
import 'package:velvet_mobile/core/widgets/kinetic_text.dart';
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
    return VelvetAuthScaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 12, 24, 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const VelvetWordmark(size: 30).animate().fadeIn(duration: 400.ms),
              const SizedBox(height: VelvetTokens.space32),
              KineticEyebrow(label: l10n.genderSetupTitle, icon: Icons.person_outline),
              const SizedBox(height: VelvetTokens.space8),
              KineticText(
                text: l10n.genderSetupTitle,
                style: GoogleFonts.syne(
                  fontSize: VelvetTokens.displayMedium,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -1.0,
                  height: 0.95,
                  color: context.velvet.ink,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                l10n.genderSetupBody,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: context.velvet.muted, height: 1.45),
              ),
              const SizedBox(height: 28),
              Column(
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
              ).animate().fadeIn(delay: 80.ms).slideY(begin: 0.05, end: 0),
              if (_error != null) ...[
                const SizedBox(height: 16),
                Text(_error!, style: const TextStyle(color: VelvetTheme.danger)),
              ],
              const Spacer(),
              VelvetButton(
                label: l10n.continueLabel,
                loading: _loading,
                onPressed: _loading ? null : _save,
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
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(
            selected ? VelvetTokens.radiusLg : VelvetTokens.radiusMd,
          ),
          topRight: Radius.circular(VelvetTokens.radiusSm),
          bottomLeft: Radius.circular(VelvetTokens.radiusSm),
          bottomRight: Radius.circular(
            selected ? VelvetTokens.radiusXl : VelvetTokens.radiusMd,
          ),
        ),
        child: AnimatedContainer(
          duration: VelvetTokens.motionFast,
          curve: VelvetTokens.easeEditorial,
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: selected
                  ? [
                      VelvetTokens.ember.withValues(alpha: 0.92),
                      VelvetTokens.emberDeep.withValues(alpha: 0.88),
                    ]
                  : [
                      VelvetTokens.parchmentLift.withValues(alpha: 0.96),
                      VelvetTokens.parchmentDeep.withValues(alpha: 0.55),
                    ],
            ),
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(
                selected ? VelvetTokens.radiusLg : VelvetTokens.radiusMd,
              ),
              topRight: Radius.circular(VelvetTokens.radiusSm),
              bottomLeft: Radius.circular(VelvetTokens.radiusSm),
              bottomRight: Radius.circular(
                selected ? VelvetTokens.radiusXl : VelvetTokens.radiusMd,
              ),
            ),
            border: Border.all(
              color: selected
                  ? VelvetTokens.emberDeep.withValues(alpha: 0.5)
                  : VelvetTokens.line.withValues(alpha: 0.8),
            ),
            boxShadow: selected
                ? VelvetTokens.emberHalo(strength: 0.35)
                : VelvetTokens.depthLift(elevation: 0.15),
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  label,
                  style: GoogleFonts.syne(
                    fontWeight: FontWeight.w800,
                    fontSize: 17,
                    letterSpacing: -0.3,
                    color: selected ? Colors.white : VelvetTheme.ink,
                  ),
                ),
              ),
              Icon(
                selected ? Icons.check_circle_rounded : Icons.circle_outlined,
                color: selected ? Colors.white : VelvetTheme.muted,
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

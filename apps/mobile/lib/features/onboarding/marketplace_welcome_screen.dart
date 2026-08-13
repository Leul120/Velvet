import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:velvet_mobile/core/theme/velvet_theme.dart';
import 'package:velvet_mobile/core/theme/velvet_editorial_colors.dart';
import 'package:velvet_mobile/core/theme/velvet_tokens.dart';
import 'package:velvet_mobile/core/widgets/editorial_background.dart';
import 'package:velvet_mobile/core/widgets/kinetic_text.dart';
import 'package:velvet_mobile/core/widgets/velvet_widgets.dart';
import 'package:velvet_mobile/features/auth/auth_controller.dart';
import 'package:velvet_mobile/features/auth/role_helpers.dart';
import 'package:velvet_mobile/features/onboarding/onboarding_prefs.dart';
import 'package:velvet_mobile/l10n/generated/app_localizations.dart';

class MarketplaceWelcomeScreen extends ConsumerWidget {
  const MarketplaceWelcomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final auth = ref.watch(authControllerProvider);
    final isPerformer = isPerformerRole(auth.user?.role);

    final steps = isPerformer
        ? [
            _WelcomeStep(
              Icons.edit_note_outlined,
              l10n.welcomeStepListing,
              l10n.welcomeStepListingBody,
            ),
            _WelcomeStep(
              Icons.calendar_month_outlined,
              l10n.welcomeStepCalendar,
              l10n.welcomeStepCalendarBody,
            ),
            _WelcomeStep(
              Icons.inbox_outlined,
              l10n.welcomeStepRequests,
              l10n.welcomeStepRequestsBody,
            ),
          ]
        : [
            _WelcomeStep(
              Icons.storefront_outlined,
              l10n.welcomeStepBrowse,
              l10n.welcomeStepBrowseBody,
            ),
            _WelcomeStep(
              Icons.send_outlined,
              l10n.welcomeStepRequest,
              l10n.welcomeStepRequestBody,
            ),
            _WelcomeStep(
              Icons.event_available_outlined,
              l10n.welcomeStepBook,
              l10n.welcomeStepBookBody,
            ),
          ];

    return Scaffold(
      backgroundColor: VelvetTokens.parchment,
      body: Stack(
        fit: StackFit.expand,
        children: [
          const EditorialAtmosphere(intensity: 1.1, variant: EditorialVariant.auth),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(28, 40, 28, 28),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const VelvetWordmark(size: 32),
                  const SizedBox(height: VelvetTokens.space40),
                  KineticText(
                    text: l10n.welcomeTitle,
                    style: GoogleFonts.syne(
                      fontSize: VelvetTokens.displayLarge,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -1.6,
                      height: 0.92,
                      color: context.velvet.ink,
                    ),
                  ),
                  const SizedBox(height: VelvetTokens.space12),
                  Text(
                    isPerformer
                        ? l10n.welcomeBodyPerformer
                        : l10n.welcomeBodyClient,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: context.velvet.muted,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: VelvetTokens.space40),
                  Expanded(
                    child: ListView.separated(
                      itemCount: steps.length,
                      separatorBuilder: (_, _) =>
                          const SizedBox(height: VelvetTokens.space16),
                      itemBuilder: (context, i) {
                        final step = steps[i];
                        return _WelcomeStepTile(step: step, index: i)
                            .animate()
                            .fadeIn(delay: (70 * i).ms, duration: 320.ms)
                            .slideX(begin: 0.06, end: 0);
                      },
                    ),
                  ),
                  VelvetButton(
                    label: l10n.welcomeCta,
                    icon: Icons.arrow_forward_rounded,
                    onPressed: () async {
                      await ref
                          .read(onboardingPrefsProvider.notifier)
                          .markWelcomeSeen();
                      if (!context.mounted) return;
                      context.go(isPerformer ? '/payments' : '/discover');
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _WelcomeStepTile extends StatelessWidget {
  const _WelcomeStepTile({required this.step, required this.index});

  final _WelcomeStep step;
  final int index;

  @override
  Widget build(BuildContext context) {
    return Transform.translate(
      offset: Offset(index.isOdd ? 12 : 0, 0),
      child: GlassPanel(
        padding: const EdgeInsets.fromLTRB(18, 16, 16, 16),
        radius: VelvetTokens.radiusLg,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Transform.rotate(
              angle: index.isOdd ? 0.04 : -0.03,
              child: Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: VelvetTokens.emberSoft.withValues(alpha: 0.35),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(VelvetTokens.radiusMd),
                    bottomRight: Radius.circular(VelvetTokens.radiusLg),
                  ),
                ),
                child: Icon(step.icon, color: VelvetTokens.ember, size: 24),
              ),
            ),
            const SizedBox(width: VelvetTokens.space16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    step.title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    step.body,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: context.velvet.muted,
                      height: 1.45,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _WelcomeStep {
  const _WelcomeStep(this.icon, this.title, this.body);
  final IconData icon;
  final String title;
  final String body;
}

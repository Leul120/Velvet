import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:velvet_mobile/core/theme/velvet_editorial_colors.dart';
import 'package:velvet_mobile/core/theme/velvet_tokens.dart';
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
    final colors = context.velvet;
    final auth = ref.watch(authControllerProvider);
    final isPerformer = isPerformerRole(auth.user?.role);

    final steps = isPerformer
        ? [
            _WelcomeStep(
              l10n.welcomeStepListing,
              l10n.welcomeStepListingBody,
            ),
            _WelcomeStep(
              l10n.welcomeStepCalendar,
              l10n.welcomeStepCalendarBody,
            ),
            _WelcomeStep(
              l10n.welcomeStepRequests,
              l10n.welcomeStepRequestsBody,
            ),
          ]
        : [
            _WelcomeStep(
              l10n.welcomeStepBrowse,
              l10n.welcomeStepBrowseBody,
            ),
            _WelcomeStep(
              l10n.welcomeStepRequest,
              l10n.welcomeStepRequestBody,
            ),
            _WelcomeStep(
              l10n.welcomeStepBook,
              l10n.welcomeStepBookBody,
            ),
          ];

    return VelvetAuthScaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 28, 24, 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const VelvetWordmark(size: 36, breathe: true),
              const SizedBox(height: 28),
              Text(
                l10n.welcomeTitle,
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
                isPerformer ? l10n.welcomeBodyPerformer : l10n.welcomeBodyClient,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: colors.muted,
                      height: 1.45,
                    ),
              ),
              const SizedBox(height: 28),
              Expanded(
                child: ListView.separated(
                  itemCount: steps.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 10),
                  itemBuilder: (context, i) {
                    final step = steps[i];
                    return Container(
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
                      decoration: BoxDecoration(
                        color: colors.parchmentLift,
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(
                          color: colors.line.withValues(alpha: 0.7),
                        ),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 36,
                            height: 36,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: VelvetTokens.ember.withValues(alpha: 0.14),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              '${i + 1}',
                              style: GoogleFonts.syne(
                                fontWeight: FontWeight.w800,
                                color: VelvetTokens.ember,
                              ),
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  step.title,
                                  style: GoogleFonts.syne(
                                    fontSize: 17,
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: -0.3,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  step.body,
                                  style: GoogleFonts.dmSans(
                                    color: colors.muted,
                                    height: 1.45,
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    )
                        .animate()
                        .fadeIn(delay: (60 * i).ms, duration: 320.ms)
                        .slideY(begin: 0.04, end: 0);
                  },
                ),
              ),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: () async {
                  await ref
                      .read(onboardingPrefsProvider.notifier)
                      .markWelcomeSeen();
                  if (!context.mounted) return;
                  context.go(isPerformer ? '/payments' : '/discover');
                },
                style: FilledButton.styleFrom(
                  minimumSize: const Size.fromHeight(54),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
                child: Text(l10n.welcomeCta),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _WelcomeStep {
  const _WelcomeStep(this.title, this.body);
  final String title;
  final String body;
}

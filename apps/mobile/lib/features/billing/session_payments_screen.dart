import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:velvet_mobile/core/theme/velvet_theme.dart';
import 'package:velvet_mobile/core/theme/velvet_editorial_colors.dart';
import 'package:velvet_mobile/core/theme/velvet_tokens.dart';
import 'package:velvet_mobile/core/widgets/kinetic_text.dart';
import 'package:velvet_mobile/core/widgets/velvet_widgets.dart';
import 'package:velvet_mobile/features/auth/auth_controller.dart';
import 'package:velvet_mobile/features/auth/role_helpers.dart';
import 'package:velvet_mobile/features/profile/performer_ready_screen.dart';
import 'package:velvet_mobile/l10n/generated/app_localizations.dart';

class SessionPaymentsScreen extends ConsumerWidget {
  const SessionPaymentsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(authControllerProvider);
    if (isPerformerRole(auth.user?.role)) {
      return const PerformerReadyScreen();
    }
    final l10n = AppLocalizations.of(context);
    return VelvetScaffold(
      mistIntensity: 0.9,
      extendBody: true,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(
          parent: AlwaysScrollableScrollPhysics(),
        ),
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                VelvetTokens.pageInset,
                VelvetTokens.space32,
                VelvetTokens.pageInset,
                VelvetTokens.space24,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  KineticEyebrow(
                    label: l10n.navSessionPayments,
                    icon: Icons.payments_outlined,
                  ),
                  const SizedBox(height: VelvetTokens.space8),
                  KineticText(
                    text: l10n.sessionPaymentsTitle,
                    style: GoogleFonts.syne(
                      fontSize: VelvetTokens.displayMedium,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -1.2,
                      height: 0.95,
                      color: context.velvet.ink,
                    ),
                  ),
                  const SizedBox(height: VelvetTokens.space8),
                  Text(
                    l10n.sessionPaymentsSubtitle,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: context.velvet.muted,
                      height: 1.45,
                    ),
                  ),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: VelvetTokens.pageInset),
              child: GlassPanel(
                padding: const EdgeInsets.fromLTRB(24, 28, 24, 32),
                radius: VelvetTokens.radiusXl,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Transform.rotate(
                      angle: -0.03,
                      child: Container(
                        width: 56,
                        height: 56,
                        decoration: BoxDecoration(
                          color: VelvetTokens.emberSoft.withValues(alpha: 0.35),
                          borderRadius: BorderRadius.circular(VelvetTokens.radiusMd),
                        ),
                        child: const Icon(
                          Icons.payments_outlined,
                          color: VelvetTokens.ember,
                          size: 28,
                        ),
                      ),
                    ),
                    const SizedBox(height: VelvetTokens.space20),
                    Text(
                      l10n.sessionPaymentsHeading,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: VelvetTokens.space8),
                    Text(
                      l10n.sessionPaymentsBody,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: context.velvet.muted,
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ).animate().fadeIn(duration: VelvetTokens.motionMedium).slideY(begin: 0.04, end: 0),
            ),
          ),
          SliverPadding(
            padding: EdgeInsets.only(
              bottom: VelvetTokens.plinthClearance + MediaQuery.paddingOf(context).bottom,
            ),
          ),
        ],
      ),
    );
  }
}

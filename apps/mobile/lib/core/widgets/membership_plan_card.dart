import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:velvet_mobile/core/theme/velvet_editorial_colors.dart';
import 'package:velvet_mobile/core/theme/velvet_tokens.dart';
import 'package:velvet_mobile/core/widgets/velvet_widgets.dart';
import 'package:velvet_mobile/features/billing/billing_api.dart';

/// Editorial membership plan card — asymmetric slab with ember accent.
class MembershipPlanCard extends StatelessWidget {
  const MembershipPlanCard({
    super.key,
    required this.plan,
    required this.name,
    required this.quotaLabel,
    required this.daysLabel,
    required this.ctaLabel,
    required this.index,
    required this.paying,
    required this.onSelect,
  });

  final PlanItem plan;
  final String name;
  final String quotaLabel;
  final String daysLabel;
  final String ctaLabel;
  final int index;
  final bool paying;
  final VoidCallback? onSelect;

  @override
  Widget build(BuildContext context) {
    final featured = index == 0;
    final tilt = index.isOdd ? 0.012 : -0.008;

    return Transform.rotate(
      angle: tilt,
      child: Transform.translate(
        offset: Offset(index.isOdd ? 8 : 0, 0),
        child: Container(
          margin: const EdgeInsets.only(bottom: VelvetTokens.space24),
          padding: const EdgeInsets.fromLTRB(22, 22, 20, 20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: featured
                  ? [
                      VelvetTokens.emberSoft.withValues(alpha: 0.28),
                      VelvetTokens.parchmentLift.withValues(alpha: 0.92),
                    ]
                  : [
                      VelvetTokens.parchmentDeep.withValues(alpha: 0.65),
                      VelvetTokens.parchmentLift.withValues(alpha: 0.88),
                    ],
            ),
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(featured ? VelvetTokens.radiusXl : VelvetTokens.radiusLg),
              topRight: Radius.circular(featured ? VelvetTokens.radiusSm : VelvetTokens.radiusLg),
              bottomLeft: Radius.circular(VelvetTokens.radiusSm),
              bottomRight: Radius.circular(featured ? VelvetTokens.radiusXl : VelvetTokens.radiusLg),
            ),
            border: Border.all(
              color: featured
                  ? VelvetTokens.ember.withValues(alpha: 0.45)
                  : VelvetTokens.line.withValues(alpha: 0.7),
              width: featured ? 1.4 : 1,
            ),
            boxShadow: featured
                ? VelvetTokens.emberHalo(strength: 0.65)
                : VelvetTokens.depthLift(elevation: 0.35),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    (index + 1).toString().padLeft(2, '0'),
                    style: GoogleFonts.syne(
                      fontSize: 36,
                      fontWeight: FontWeight.w800,
                      color: featured
                          ? VelvetTokens.emberDeep
                          : VelvetTokens.muted.withValues(alpha: 0.45),
                      height: 1,
                    ),
                  ),
                  const SizedBox(width: VelvetTokens.space12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          name,
                          style: GoogleFonts.syne(
                            fontSize: 26,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.8,
                            height: 0.95,
                            color: context.velvet.ink,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          '${plan.priceEtb.toStringAsFixed(0)} ETB · $daysLabel',
                          style: GoogleFonts.dmSans(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: VelvetTokens.emberDeep,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (featured)
                    Icon(
                      Icons.auto_awesome,
                      color: VelvetTokens.gold,
                      size: 22,
                    ),
                ],
              ),
              const SizedBox(height: VelvetTokens.space20),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
                decoration: BoxDecoration(
                  color: VelvetTokens.parchmentDeep.withValues(alpha: 0.55),
                  borderRadius: BorderRadius.circular(VelvetTokens.radiusMd),
                  border: Border.all(color: VelvetTokens.line.withValues(alpha: 0.5)),
                ),
                child: Text(
                  quotaLabel.toUpperCase(),
                  style: GoogleFonts.inter(
                    fontWeight: FontWeight.w700,
                    fontSize: 10.5,
                    letterSpacing: 1.4,
                    color: VelvetTokens.muted,
                  ),
                ),
              ),
              const SizedBox(height: VelvetTokens.space20),
              VelvetButton(
                label: ctaLabel,
                loading: paying,
                onPressed: paying ? null : () {
                  HapticFeedback.selectionClick();
                  onSelect?.call();
                },
              ),
            ],
          ),
        ),
      ),
    ).animate(delay: (70 * index).ms).fadeIn(duration: 360.ms).slideY(begin: 0.04, end: 0);
  }
}

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:velvet_mobile/core/theme/velvet_editorial_colors.dart';
import 'package:velvet_mobile/core/theme/velvet_tokens.dart';
import 'package:velvet_mobile/features/billing/billing_api.dart';

/// Membership plan — lift card, lime featured, pill pay CTA.
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
    final colors = context.velvet;
    final featured = index == 0;

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 18),
      decoration: BoxDecoration(
        color: colors.parchmentLift,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: featured
              ? VelvetTokens.ember.withValues(alpha: 0.45)
              : colors.line.withValues(alpha: 0.7),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  name,
                  style: GoogleFonts.syne(
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.6,
                    height: 0.98,
                    color: colors.ink,
                  ),
                ),
              ),
              if (featured)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: VelvetTokens.ember.withValues(alpha: 0.14),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    daysLabel,
                    style: GoogleFonts.dmSans(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: VelvetTokens.ember,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            '${plan.priceEtb.toStringAsFixed(0)} ETB',
            style: GoogleFonts.syne(
              fontSize: 28,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.8,
              color: VelvetTokens.ember,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '$daysLabel · $quotaLabel',
            style: GoogleFonts.dmSans(
              fontSize: 13,
              color: colors.muted,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 18),
          FilledButton(
            onPressed: paying
                ? null
                : () {
                    HapticFeedback.selectionClick();
                    onSelect?.call();
                  },
            style: FilledButton.styleFrom(
              minimumSize: const Size.fromHeight(50),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(999),
              ),
            ),
            child: paying
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: VelvetTokens.onPrimary,
                    ),
                  )
                : Text(ctaLabel),
          ),
        ],
      ),
    ).animate(delay: (50 * index).ms).fadeIn(duration: 320.ms).slideY(begin: 0.03, end: 0);
  }
}

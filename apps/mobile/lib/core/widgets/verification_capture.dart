import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:velvet_mobile/core/theme/velvet_editorial_colors.dart';
import 'package:velvet_mobile/core/theme/velvet_theme.dart';
import 'package:velvet_mobile/core/theme/velvet_tokens.dart';

/// Immersive document capture zone with tilt, state glow, and step number.
class VerificationCaptureZone extends StatelessWidget {
  const VerificationCaptureZone({
    super.key,
    required this.title,
    required this.subtitle,
    required this.done,
    required this.onTap,
    required this.stepNumber,
    this.enabled = true,
  });

  final String title;
  final String subtitle;
  final bool done;
  final VoidCallback? onTap;
  final int stepNumber;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final tilt = stepNumber.isOdd ? 0.018 : -0.015;

    return Semantics(
      button: true,
      enabled: enabled,
      label: '$title. $subtitle',
      child: GestureDetector(
        onTap: enabled
            ? () {
                HapticFeedback.selectionClick();
                onTap?.call();
              }
            : null,
        child: Transform.rotate(
          angle: tilt,
          child: AnimatedContainer(
            duration: VelvetTokens.motionMedium,
            curve: VelvetTokens.easeEditorial,
            margin: EdgeInsets.only(
              left: stepNumber.isOdd ? 12 : 0,
              right: stepNumber.isOdd ? 0 : 12,
              bottom: VelvetTokens.space20,
            ),
            padding: const EdgeInsets.fromLTRB(22, 24, 18, 22),
            decoration: BoxDecoration(
              color: done
                  ? VelvetTokens.gold.withValues(alpha: 0.10)
                  : VelvetTokens.parchmentLift.withValues(alpha: 0.85),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(VelvetTokens.radiusLg),
                topRight: Radius.circular(VelvetTokens.radiusSm),
                bottomLeft: Radius.circular(VelvetTokens.radiusSm),
                bottomRight: Radius.circular(VelvetTokens.radiusXl),
              ),
              border: Border.all(
                color: done
                    ? VelvetTokens.gold.withValues(alpha: 0.55)
                    : VelvetTokens.ember.withValues(alpha: 0.28),
                width: done ? 1.5 : 1.2,
              ),
              boxShadow: done
                  ? VelvetTokens.depthLift(elevation: 0.4, tint: VelvetTokens.gold)
                  : VelvetTokens.depthLift(elevation: 0.2),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(
                  children: [
                    Text(
                      stepNumber.toString().padLeft(2, '0'),
                      style: GoogleFonts.syne(
                        fontSize: 32,
                        fontWeight: FontWeight.w800,
                        color: done
                            ? VelvetTokens.gold
                            : VelvetTokens.ember.withValues(alpha: 0.45),
                        height: 1,
                      ),
                    ),
                    const SizedBox(height: 8),
                    AnimatedContainer(
                      duration: VelvetTokens.motionFast,
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: done
                            ? VelvetTokens.gold.withValues(alpha: 0.2)
                            : VelvetTokens.emberSoft.withValues(alpha: 0.35),
                      ),
                      child: Icon(
                        done ? Icons.check_rounded : Icons.document_scanner_outlined,
                        color: done ? VelvetTokens.gold : VelvetTokens.ember,
                        size: 22,
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: VelvetTokens.space16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: GoogleFonts.syne(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          letterSpacing: -0.3,
                          color: context.velvet.ink,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        subtitle,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: done ? VelvetTokens.gold : VelvetTheme.muted,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 14,
                  color: done ? VelvetTokens.gold : VelvetTheme.muted,
                ),
              ],
            ),
          ),
        ).animate(target: done ? 1 : 0).shimmer(
              duration: 1200.ms,
              color: VelvetTokens.gold.withValues(alpha: 0.15),
            ),
      ),
    );
  }
}

/// Progress indicator for verification steps.
class VerificationProgressRail extends StatelessWidget {
  const VerificationProgressRail({
    super.key,
    required this.completedSteps,
    required this.totalSteps,
  });

  final int completedSteps;
  final int totalSteps;

  @override
  Widget build(BuildContext context) {
    final progress = totalSteps == 0 ? 0.0 : completedSteps / totalSteps;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '$completedSteps / $totalSteps complete',
          style: GoogleFonts.inter(
            fontSize: VelvetTokens.labelCaps,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.2,
            color: VelvetTokens.muted,
          ),
        ),
        const SizedBox(height: VelvetTokens.space8),
        ClipRRect(
          borderRadius: BorderRadius.circular(99),
          child: LinearProgressIndicator(
            value: progress,
            minHeight: 5,
            backgroundColor: VelvetTokens.line.withValues(alpha: 0.5),
            color: VelvetTokens.ember,
          ),
        ),
      ],
    );
  }
}

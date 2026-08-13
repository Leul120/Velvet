import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:velvet_mobile/core/theme/velvet_editorial_colors.dart';
import 'package:velvet_mobile/core/theme/velvet_theme.dart';
import 'package:velvet_mobile/core/theme/velvet_tokens.dart';
import 'package:velvet_mobile/core/widgets/kinetic_text.dart';

/// Visible booking journey rail — overlapping glass step slabs + progress spine.
class BookingJourneyRail extends StatelessWidget {
  const BookingJourneyRail({
    super.key,
    required this.steps,
    required this.activeIndex,
    this.pulse = false,
    this.title,
    this.subtitle,
  });

  final List<String> steps;
  final int activeIndex;
  final bool pulse;
  final String? title;
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    final active = activeIndex.clamp(0, steps.length - 1);

    return GlassPanel(
      padding: const EdgeInsets.fromLTRB(20, 22, 20, 24),
      radius: VelvetTokens.radiusXl,
      fill: VelvetTokens.glassStrong.withValues(alpha: 0.82),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (title != null) ...[
            KineticEyebrow(label: 'Journey', icon: Icons.route_outlined),
            const SizedBox(height: VelvetTokens.space8),
            Text(
              title!,
              style: GoogleFonts.syne(
                fontSize: 26,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.8,
                height: 1.0,
                color: context.velvet.ink,
              ),
            ),
            if (subtitle != null) ...[
              const SizedBox(height: 6),
              Text(
                subtitle!,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: VelvetTheme.muted,
                ),
              ),
            ],
            const SizedBox(height: VelvetTokens.space24),
          ],
          SizedBox(
            height: 96,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Positioned(
                  left: 20,
                  right: 20,
                  top: 44,
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final progress = steps.length <= 1
                          ? 0.0
                          : active / (steps.length - 1);
                      return Stack(
                        children: [
                          Container(
                            height: 3,
                            decoration: BoxDecoration(
                              color: VelvetTokens.line.withValues(alpha: 0.5),
                              borderRadius: BorderRadius.circular(99),
                            ),
                          ),
                          AnimatedContainer(
                            duration: VelvetTokens.motionMedium,
                            curve: VelvetTokens.easeEditorial,
                            width: constraints.maxWidth * progress,
                            height: 3,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  VelvetTokens.ember,
                                  VelvetTokens.gold,
                                ],
                              ),
                              borderRadius: BorderRadius.circular(99),
                              boxShadow: pulse
                                  ? VelvetTokens.emberHalo(strength: 0.8)
                                  : null,
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
                ListView.separated(
                  scrollDirection: Axis.horizontal,
                  clipBehavior: Clip.none,
                  itemCount: steps.length,
                  separatorBuilder: (_, _) => const SizedBox(width: 10),
                  itemBuilder: (context, i) {
                    final isActive = i == active;
                    final isPast = i < active;
                    return _StepSlab(
                      label: steps[i],
                      index: i + 1,
                      isActive: isActive,
                      isPast: isPast,
                      pulse: pulse && isActive,
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StepSlab extends StatelessWidget {
  const _StepSlab({
    required this.label,
    required this.index,
    required this.isActive,
    required this.isPast,
    this.pulse = false,
  });

  final String label;
  final int index;
  final bool isActive;
  final bool isPast;
  final bool pulse;

  @override
  Widget build(BuildContext context) {
    final width = isActive ? 118.0 : 92.0;
    Widget slab = AnimatedContainer(
      duration: VelvetTokens.motionMedium,
      curve: VelvetTokens.easeEditorial,
      width: width,
      padding: const EdgeInsets.fromLTRB(12, 10, 10, 12),
      transform: Matrix4.identity()
        ..translateByDouble(0.0, isActive ? -4.0 : 0.0, 0, 1)
        ..rotateZ(isActive ? -0.02 : (index.isOdd ? 0.015 : -0.01)),
      decoration: BoxDecoration(
        color: isActive
            ? VelvetTokens.emberSoft.withValues(alpha: 0.35)
            : isPast
            ? VelvetTokens.parchmentLift
            : VelvetTokens.parchmentDeep.withValues(alpha: 0.7),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(isActive ? 16 : 12),
          topRight: Radius.circular(isActive ? 10 : 14),
          bottomLeft: Radius.circular(isActive ? 10 : 14),
          bottomRight: Radius.circular(isActive ? 18 : 12),
        ),
        border: Border.all(
          color: isActive
              ? VelvetTokens.ember.withValues(alpha: 0.5)
              : isPast
              ? VelvetTokens.gold.withValues(alpha: 0.35)
              : VelvetTokens.line.withValues(alpha: 0.5),
        ),
        boxShadow: isActive ? VelvetTokens.depthLift(elevation: 0.6) : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            index.toString().padLeft(2, '0'),
            style: GoogleFonts.syne(
              fontSize: isActive ? 20 : 16,
              fontWeight: FontWeight.w800,
              color: isActive
                  ? VelvetTokens.emberDeep
                  : isPast
                  ? VelvetTokens.gold
                  : VelvetTokens.muted.withValues(alpha: 0.5),
              height: 1,
            ),
          ),
          Text(
            label.toUpperCase(),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.inter(
              fontSize: isActive ? 9.5 : 9,
              fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
              letterSpacing: 1.6,
              height: 1.25,
              color: isActive ? VelvetTokens.emberDeep : VelvetTokens.muted,
            ),
          ),
        ],
      ),
    );

    if (pulse) {
      slab = slab
          .animate(onPlay: (c) => c.repeat(reverse: true))
          .scaleXY(begin: 1, end: 1.03, duration: 900.ms, curve: Curves.easeInOut);
    }

    return slab;
  }
}

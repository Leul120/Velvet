import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:velvet_mobile/core/theme/velvet_editorial_colors.dart';
import 'package:velvet_mobile/core/theme/velvet_theme.dart';
import 'package:velvet_mobile/core/theme/velvet_tokens.dart';
import 'package:velvet_mobile/core/widgets/velvet_widgets.dart';

/// Distinct panic zone — high-visibility emergency module with ambient pulse.
class SafetyPanicZone extends StatelessWidget {
  const SafetyPanicZone({
    super.key,
    required this.label,
    required this.hint,
    required this.onPanic,
    this.loading = false,
  });

  final String label;
  final String hint;
  final VoidCallback? onPanic;
  final bool loading;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: label,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned(
            top: -8,
            right: -8,
            child: Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: VelvetTheme.danger.withValues(alpha: 0.12),
              ),
            )
                .animate(onPlay: (c) => c.repeat(reverse: true))
                .scaleXY(begin: 0.85, end: 1.2, duration: 1800.ms),
          ),
          GlassPanel(
            padding: const EdgeInsets.fromLTRB(22, 24, 22, 22),
            radius: VelvetTokens.radiusXl,
            fill: VelvetTheme.danger.withValues(alpha: 0.08),
            border: VelvetTheme.danger.withValues(alpha: 0.35),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Transform.rotate(
                      angle: -0.06,
                      child: Container(
                        width: 52,
                        height: 52,
                        decoration: BoxDecoration(
                          color: VelvetTheme.danger.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(VelvetTokens.radiusMd),
                            bottomRight: Radius.circular(VelvetTokens.radiusLg),
                          ),
                        ),
                        child: const Icon(
                          Icons.emergency_outlined,
                          color: VelvetTheme.danger,
                          size: 28,
                        ),
                      ),
                    ),
                    const SizedBox(width: VelvetTokens.space16),
                    Expanded(
                      child: Text(
                        label.toUpperCase(),
                        style: GoogleFonts.syne(
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.3,
                          color: VelvetTheme.danger,
                          height: 1.0,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: VelvetTokens.space12),
                Text(
                  hint,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: context.velvet.ink,
                    height: 1.45,
                  ),
                ),
                const SizedBox(height: VelvetTokens.space20),
                VelvetButton(
                  label: label,
                  variant: VelvetButtonVariant.danger,
                  icon: Icons.emergency_outlined,
                  loading: loading,
                  onPressed: loading
                      ? null
                      : () {
                          HapticFeedback.heavyImpact();
                          onPanic?.call();
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

/// Grouped safety action module with editorial header.
class SafetyActionModule extends StatelessWidget {
  const SafetyActionModule({
    super.key,
    required this.title,
    required this.children,
    this.icon,
  });

  final String title;
  final List<Widget> children;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            if (icon != null) ...[
              Icon(icon, size: 16, color: VelvetTokens.gold),
              const SizedBox(width: 8),
            ],
            Text(
              title.toUpperCase(),
              style: GoogleFonts.inter(
                fontSize: VelvetTokens.labelCaps,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.4,
                color: VelvetTokens.muted,
              ),
            ),
          ],
        ),
        const SizedBox(height: VelvetTokens.space12),
        ...children,
      ],
    );
  }
}

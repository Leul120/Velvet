import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:velvet_mobile/core/theme/velvet_tokens.dart';

/// Display typography with staggered kinetic entrance and editorial line breaks.
class KineticText extends StatelessWidget {
  const KineticText({
    super.key,
    required this.text,
    this.style,
    this.maxLines,
    this.delay = Duration.zero,
    this.splitLines = false,
    this.semanticLabel,
  });

  final String text;
  final TextStyle? style;
  final int? maxLines;
  final Duration delay;
  final bool splitLines;
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final base = style ??
        GoogleFonts.syne(
          fontSize: VelvetTokens.displayMedium,
          fontWeight: FontWeight.w800,
          letterSpacing: -1.4,
          height: 0.95,
          color: VelvetTokens.ink,
        );

    if (MediaQuery.disableAnimationsOf(context)) {
      return Semantics(
        label: semanticLabel ?? text,
        header: true,
        child: Text(text, style: base, maxLines: maxLines),
      );
    }

    if (splitLines && text.contains('\n')) {
      final lines = text.split('\n');
      return Semantics(
        label: semanticLabel ?? text,
        header: true,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            for (var i = 0; i < lines.length; i++)
              Text(lines[i], style: base)
                  .animate(delay: delay + Duration(milliseconds: 80 * i))
                  .fadeIn(duration: VelvetTokens.motionMedium, curve: VelvetTokens.easeReveal)
                  .slideY(
                    begin: 0.22,
                    end: 0,
                    curve: VelvetTokens.easeEditorial,
                  )
                  .blur(
                    begin: const Offset(4, 0),
                    end: Offset.zero,
                    duration: VelvetTokens.motionFast,
                  ),
          ],
        ),
      );
    }

    return Semantics(
      label: semanticLabel ?? text,
      header: true,
      child: Text(text, style: base, maxLines: maxLines)
          .animate(delay: delay)
          .fadeIn(duration: VelvetTokens.motionMedium, curve: VelvetTokens.easeReveal)
          .slideY(begin: 0.18, end: 0, curve: VelvetTokens.easeEditorial),
    );
  }
}

/// Small editorial eyebrow label with kinetic fade.
class KineticEyebrow extends StatelessWidget {
  const KineticEyebrow({
    super.key,
    required this.label,
    this.icon,
    this.delay = Duration.zero,
  });

  final String label;
  final IconData? icon;
  final Duration delay;

  @override
  Widget build(BuildContext context) {
    final child = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (icon != null) ...[
          Icon(icon, size: 12, color: VelvetTokens.gold),
          const SizedBox(width: VelvetTokens.space6),
        ],
        Text(
          label.toUpperCase(),
          style: GoogleFonts.inter(
            color: VelvetTokens.muted,
            fontSize: VelvetTokens.labelCaps,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.8,
          ),
        ),
      ],
    );

    if (MediaQuery.disableAnimationsOf(context)) return child;

    return child
        .animate(delay: delay)
        .fadeIn(duration: VelvetTokens.motionFast)
        .slideX(begin: -0.08, end: 0, curve: VelvetTokens.easeEditorial);
  }
}

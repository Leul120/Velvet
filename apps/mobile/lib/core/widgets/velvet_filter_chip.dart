import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:velvet_mobile/core/theme/velvet_tokens.dart';

/// Bespoke animated filter chip — spring selection, ember glow when active.
class VelvetFilterChip extends StatelessWidget {
  const VelvetFilterChip({
    super.key,
    required this.label,
    required this.selected,
    required this.onChanged,
    this.icon,
  });

  final String label;
  final bool selected;
  final ValueChanged<bool> onChanged;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: selected,
      label: label,
      child: GestureDetector(
        onTap: () {
          HapticFeedback.selectionClick();
          onChanged(!selected);
        },
        child: AnimatedContainer(
          duration: VelvetTokens.motionFast,
          curve: VelvetTokens.easeEditorial,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 11),
          decoration: BoxDecoration(
            color: selected
                ? VelvetTokens.ember.withValues(alpha: 0.14)
                : VelvetTokens.parchmentDeep.withValues(alpha: 0.55),
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(selected ? 18 : 12),
              topRight: Radius.circular(selected ? 10 : 14),
              bottomLeft: Radius.circular(selected ? 10 : 16),
              bottomRight: Radius.circular(selected ? 20 : 12),
            ),
            border: Border.all(
              color: selected
                  ? VelvetTokens.ember.withValues(alpha: 0.45)
                  : VelvetTokens.line.withValues(alpha: 0.6),
              width: selected ? 1.2 : 0.8,
            ),
            boxShadow: selected ? VelvetTokens.emberHalo(strength: 0.5) : null,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null) ...[
                Icon(
                  icon,
                  size: 15,
                  color: selected ? VelvetTokens.emberDeep : VelvetTokens.muted,
                ),
                const SizedBox(width: 6),
              ],
              Text(
                label,
                style: GoogleFonts.dmSans(
                  fontSize: 14,
                  fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                  color: selected ? VelvetTokens.emberDeep : VelvetTokens.inkSoft,
                  letterSpacing: selected ? 0.1 : 0,
                ),
              ),
            ],
          ),
        ),
      ),
    ).animate(target: selected ? 1 : 0).scale(
          begin: const Offset(0.96, 0.96),
          end: const Offset(1, 1),
          duration: VelvetTokens.motionFast,
          curve: Curves.easeOutBack,
        );
  }
}

/// Editorial range slider label row.
class VelvetSliderSection extends StatelessWidget {
  const VelvetSliderSection({
    super.key,
    required this.label,
    required this.valueLabel,
    required this.child,
  });

  final String label;
  final String valueLabel;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                label.toUpperCase(),
                style: GoogleFonts.inter(
                  fontSize: VelvetTokens.labelCaps,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.4,
                  color: VelvetTokens.muted,
                ),
              ),
            ),
            Text(
              valueLabel,
              style: GoogleFonts.syne(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: VelvetTokens.emberDeep,
                letterSpacing: -0.3,
              ),
            ),
          ],
        ),
        const SizedBox(height: VelvetTokens.space8),
        child,
      ],
    );
  }
}

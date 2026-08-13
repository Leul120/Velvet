import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:velvet_mobile/core/theme/velvet_theme.dart';

class MarketplaceFlowStep {
  const MarketplaceFlowStep({required this.icon, required this.label});

  final IconData icon;
  final String label;
}

class MarketplaceFlowHint extends StatelessWidget {
  const MarketplaceFlowHint({super.key, required this.steps});

  final List<MarketplaceFlowStep> steps;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      alignment: WrapAlignment.center,
      spacing: 8,
      runSpacing: 8,
      children: [
        for (var i = 0; i < steps.length; i++) ...[
          _FlowChip(step: steps[i]),
          if (i < steps.length - 1)
            Icon(Icons.arrow_forward_rounded, size: 14, color: VelvetTheme.muted.withValues(alpha: 0.7)),
        ],
      ],
    );
  }
}

class _FlowChip extends StatelessWidget {
  const _FlowChip({required this.step});

  final MarketplaceFlowStep step;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: VelvetTheme.teal.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: VelvetTheme.teal.withValues(alpha: 0.28)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(step.icon, size: 14, color: VelvetTheme.champagne),
          const SizedBox(width: 6),
          Text(
            step.label,
            style: GoogleFonts.inter(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: VelvetTheme.champagne,
            ),
          ),
        ],
      ),
    );
  }
}

class DiscoverCoachBanner extends StatelessWidget {
  const DiscoverCoachBanner({
    super.key,
    required this.title,
    required this.body,
    required this.onDismiss,
  });

  final String title;
  final String body;
  final VoidCallback onDismiss;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
      child: GlassPanel(
        padding: const EdgeInsets.fromLTRB(14, 12, 8, 12),
        fill: VelvetTheme.glassStrong,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(Icons.route_outlined, color: VelvetTheme.orangeSoft, size: 20),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700)),
                  const SizedBox(height: 4),
                  Text(body, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: VelvetTheme.muted)),
                ],
              ),
            ),
            IconButton(
              visualDensity: VisualDensity.compact,
              onPressed: onDismiss,
              icon: const Icon(Icons.close_rounded, size: 18),
            ),
          ],
        ),
      ),
    );
  }
}

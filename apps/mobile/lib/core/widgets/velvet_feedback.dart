import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:velvet_mobile/core/theme/velvet_theme.dart';
import 'package:velvet_mobile/core/theme/velvet_tokens.dart';

/// Branded editorial toast for confirmations and lightweight feedback.
Future<void> showVelvetToast(
  BuildContext context, {
  required String message,
  String? name,
  IconData icon = Icons.check_circle_outline_rounded,
  bool destructive = false,
}) async {
  HapticFeedback.mediumImpact();
  final messenger = ScaffoldMessenger.of(context);
  messenger.clearSnackBars();
  messenger.showSnackBar(
    SnackBar(
      duration: const Duration(milliseconds: 2200),
      backgroundColor: Colors.transparent,
      elevation: 0,
      padding: EdgeInsets.zero,
      content: _VelvetToastBody(
        message: message,
        name: name,
        icon: icon,
        destructive: destructive,
      ),
    ),
  );
}

/// Error / validation toast — ember-danger gradient.
Future<void> showVelvetErrorToast(
  BuildContext context, {
  required String message,
}) =>
    showVelvetToast(
      context,
      message: message,
      icon: Icons.error_outline_rounded,
      destructive: true,
    );

class _VelvetToastBody extends StatelessWidget {
  const _VelvetToastBody({
    required this.message,
    this.name,
    required this.icon,
    required this.destructive,
  });

  final String message;
  final String? name;
  final IconData icon;
  final bool destructive;

  @override
  Widget build(BuildContext context) {
    final accent = destructive ? VelvetTheme.danger : VelvetTokens.ember;

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 8),
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(VelvetTokens.radiusLg),
        color: VelvetTokens.parchmentLift,
        border: Border.all(color: accent.withValues(alpha: 0.45)),
        boxShadow: destructive
            ? null
            : VelvetTokens.emberHalo(strength: 0.35),
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: accent.withValues(alpha: 0.16),
              border: Border.all(color: accent.withValues(alpha: 0.35)),
            ),
            child: Icon(
              icon,
              color: destructive ? Colors.white : VelvetTokens.ember,
              size: 22,
            ),
          )
              .animate(onPlay: (c) => c.repeat(reverse: true))
              .scale(
                begin: const Offset(1, 1),
                end: const Offset(1.06, 1.06),
                duration: 700.ms,
              ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                if (name != null && name!.isNotEmpty)
                  Text(
                    name!,
                    style: GoogleFonts.syne(
                      color: VelvetTokens.ink,
                      fontWeight: FontWeight.w800,
                      fontSize: 17,
                      letterSpacing: -0.3,
                    ),
                  ),
                Text(
                  message,
                  style: GoogleFonts.dmSans(
                    color: VelvetTokens.ink.withValues(alpha: 0.88),
                    fontSize: 13.5,
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 220.ms).slideY(begin: 0.2, end: 0, curve: Curves.easeOutCubic);
  }
}

/// Animated typing dots for chat.
class VelvetTypingDots extends StatefulWidget {
  const VelvetTypingDots({super.key, this.label});

  final String? label;

  @override
  State<VelvetTypingDots> createState() => _VelvetTypingDotsState();
}

class _VelvetTypingDotsState extends State<VelvetTypingDots>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 1100))
      ..repeat();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: VelvetTheme.glassStrong,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
          ),
          child: AnimatedBuilder(
            animation: _ctrl,
            builder: (context, _) {
              return Row(
                mainAxisSize: MainAxisSize.min,
                children: List.generate(3, (i) {
                  final t = (_ctrl.value + i * 0.18) % 1.0;
                  final bounce = math.sin(t * math.pi);
                  return Padding(
                    padding: EdgeInsets.only(right: i == 2 ? 0 : 5),
                    child: Transform.translate(
                      offset: Offset(0, -3.5 * bounce),
                      child: Container(
                        width: 7,
                        height: 7,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Color.lerp(
                            VelvetTheme.muted,
                            VelvetTokens.ember,
                            bounce,
                          ),
                        ),
                      ),
                    ),
                  );
                }),
              );
            },
          ),
        ),
        if (widget.label != null) ...[
          const SizedBox(width: 8),
          Text(
            widget.label!,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: VelvetTheme.muted,
                  fontStyle: FontStyle.italic,
                ),
          ),
        ],
      ],
    );
  }
}

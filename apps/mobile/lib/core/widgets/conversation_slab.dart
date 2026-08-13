import 'package:flutter/material.dart';
import 'package:velvet_mobile/core/theme/velvet_editorial_colors.dart';
import 'package:velvet_mobile/core/theme/velvet_tokens.dart';

/// Modern chat bubble — soft radius, no tilt, clear mine/theirs contrast.
class ConversationSlab extends StatelessWidget {
  const ConversationSlab({
    required this.mine,
    required this.child,
    super.key,
    this.depth = 0,
  });

  final bool mine;
  final Widget child;
  final int depth;

  @override
  Widget build(BuildContext context) {
    final colors = context.velvet;
    final maxW = MediaQuery.sizeOf(context).width * 0.78;
    final radius = BorderRadius.only(
      topLeft: const Radius.circular(20),
      topRight: const Radius.circular(20),
      bottomLeft: Radius.circular(mine ? 20 : 6),
      bottomRight: Radius.circular(mine ? 6 : 20),
    );

    return Container(
      constraints: BoxConstraints(maxWidth: maxW),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: mine ? VelvetTokens.ember : colors.parchmentLift,
        borderRadius: radius,
        border: mine
            ? null
            : Border.all(color: colors.line.withValues(alpha: 0.55)),
        boxShadow: [
          BoxShadow(
            color: colors.ink.withValues(alpha: mine ? 0.08 : 0.05),
            blurRadius: mine ? 16 : 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: DefaultTextStyle(
        style: TextStyle(
          color: mine ? VelvetTokens.onPrimary : colors.ink,
          height: 1.4,
          fontSize: 15,
        ),
        child: child,
      ),
    );
  }
}

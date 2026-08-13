import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:velvet_mobile/core/theme/velvet_editorial_colors.dart';
import 'package:velvet_mobile/core/theme/velvet_tokens.dart';

/// Consistent frosted editorial bottom sheet wrapper.
Future<T?> showEditorialSheet<T>({
  required BuildContext context,
  required Widget Function(BuildContext context, ScrollController scrollController)
      builder,
  double initialSize = 0.88,
  double minSize = 0.45,
  double maxSize = 0.94,
}) {
  return showModalBottomSheet<T>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    barrierColor: VelvetTokens.ink.withValues(alpha: 0.35),
    builder: (context) {
      final colors = context.velvet;
      return DraggableScrollableSheet(
        expand: false,
        initialChildSize: initialSize,
        minChildSize: minSize,
        maxChildSize: maxSize,
        builder: (context, scrollController) {
          return ClipRRect(
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(VelvetTokens.radiusXl),
            ),
            child: BackdropFilter(
              filter: ImageFilter.blur(
                sigmaX: VelvetTokens.blurHeavy,
                sigmaY: VelvetTokens.blurHeavy,
              ),
              child: Material(
                color: colors.glassStrong.withValues(alpha: 0.92),
                child: Column(
                  children: [
                    const SizedBox(height: 12),
                    Container(
                      width: 44,
                      height: 5,
                      decoration: BoxDecoration(
                        color: colors.line.withValues(alpha: 0.8),
                        borderRadius: BorderRadius.circular(99),
                      ),
                    ),
                    Expanded(child: builder(context, scrollController)),
                  ],
                ),
              ),
            ),
          );
        },
      );
    },
  );
}

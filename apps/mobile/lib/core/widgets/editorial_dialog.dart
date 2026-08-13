import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:velvet_mobile/core/theme/velvet_editorial_colors.dart';
import 'package:velvet_mobile/core/theme/velvet_theme.dart';
import 'package:velvet_mobile/core/theme/velvet_tokens.dart';
import 'package:velvet_mobile/core/widgets/kinetic_text.dart';
import 'package:velvet_mobile/core/widgets/velvet_widgets.dart';

class EditorialDialogAction {
  const EditorialDialogAction({
    required this.label,
    required this.onPressed,
    this.primary = false,
    this.destructive = false,
  });

  final String label;
  final VoidCallback onPressed;
  final bool primary;
  final bool destructive;
}

/// Editorial alert / confirm / form dialog.
Future<T?> showEditorialDialog<T>({
  required BuildContext context,
  required String title,
  String? message,
  Widget? content,
  IconData? icon,
  Color? iconColor,
  List<EditorialDialogAction>? actions,
  bool barrierDismissible = true,
}) {
  return showDialog<T>(
    context: context,
    barrierDismissible: barrierDismissible,
    barrierColor: VelvetTokens.ink.withValues(alpha: 0.42),
    builder: (context) {
      final colors = context.velvet;
      final radius = BorderRadius.circular(VelvetTokens.radiusXl);
      return Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
        child: DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                colors.parchmentLift.withValues(alpha: 0.98),
                colors.parchmentDeep.withValues(alpha: 0.88),
              ],
            ),
            borderRadius: radius,
            border: Border.all(color: colors.line.withValues(alpha: 0.85)),
            boxShadow: VelvetTokens.depthLift(elevation: 0.65),
          ),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(22, 24, 22, 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (icon != null) ...[
                  Icon(icon, color: iconColor ?? VelvetTokens.ember, size: 32),
                  const SizedBox(height: 14),
                ],
                KineticText(
                  text: title,
                  style: GoogleFonts.syne(
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.6,
                    height: 1.05,
                    color: colors.ink,
                  ),
                ),
                if (message != null) ...[
                  const SizedBox(height: 10),
                  Text(
                    message,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: VelvetTheme.muted,
                      height: 1.45,
                    ),
                  ),
                ],
                if (content != null) ...[
                  const SizedBox(height: 16),
                  content,
                ],
                if (actions != null && actions.isNotEmpty) ...[
                  const SizedBox(height: 22),
                  ...actions.map((action) {
                    return Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: VelvetButton(
                        label: action.label,
                        variant: action.destructive
                            ? VelvetButtonVariant.danger
                            : action.primary
                            ? VelvetButtonVariant.primary
                            : VelvetButtonVariant.ghost,
                        onPressed: action.onPressed,
                      ),
                    );
                  }),
                ],
              ],
            ),
          ),
        ),
      );
    },
  );
}

Future<bool> showEditorialConfirm({
  required BuildContext context,
  required String title,
  String? message,
  required String confirmLabel,
  required String cancelLabel,
  bool destructive = false,
}) async {
  final result = await showEditorialDialog<bool>(
    context: context,
    title: title,
    message: message,
    icon: destructive ? Icons.warning_amber_rounded : Icons.help_outline_rounded,
    iconColor: destructive ? VelvetTheme.danger : VelvetTokens.ember,
    actions: [
      EditorialDialogAction(
        label: cancelLabel,
        onPressed: () => Navigator.pop(context, false),
      ),
      EditorialDialogAction(
        label: confirmLabel,
        primary: !destructive,
        destructive: destructive,
        onPressed: () => Navigator.pop(context, true),
      ),
    ],
  );
  return result == true;
}

Future<String?> showEditorialPrompt({
  required BuildContext context,
  required String title,
  String? message,
  required String fieldLabel,
  String? helperText,
  String? initialValue,
  required String confirmLabel,
  required String cancelLabel,
  TextCapitalization capitalization = TextCapitalization.none,
}) async {
  final controller = TextEditingController(text: initialValue ?? '');
  final result = await showEditorialDialog<String>(
    context: context,
    title: title,
    message: message,
    icon: Icons.receipt_long_outlined,
    content: VelvetField(
      controller: controller,
      label: fieldLabel,
      hint: helperText,
      textCapitalization: capitalization,
      textInputAction: TextInputAction.done,
      onSubmitted: (_) {
        final value = controller.text.trim();
        if (value.isNotEmpty) Navigator.pop(context, value);
      },
    ),
    actions: [
      EditorialDialogAction(
        label: cancelLabel,
        onPressed: () => Navigator.pop(context),
      ),
      EditorialDialogAction(
        label: confirmLabel,
        primary: true,
        onPressed: () {
          final value = controller.text.trim();
          if (value.isNotEmpty) Navigator.pop(context, value);
        },
      ),
    ],
  );
  controller.dispose();
  return result;
}

class EditorialSheetOption<T> {
  const EditorialSheetOption({
    required this.value,
    required this.label,
    required this.icon,
    this.destructive = false,
  });

  final T value;
  final String label;
  final IconData icon;
  final bool destructive;
}

/// Compact frosted action sheet (attach menu, photo source, chat actions).
Future<T?> showEditorialActionSheet<T>({
  required BuildContext context,
  String? title,
  required List<EditorialSheetOption<T>> options,
}) {
  return showModalBottomSheet<T>(
    context: context,
    backgroundColor: Colors.transparent,
    barrierColor: VelvetTokens.ink.withValues(alpha: 0.35),
    builder: (context) {
      final colors = context.velvet;
      final radius = const BorderRadius.vertical(
        top: Radius.circular(VelvetTokens.radiusXl),
      );
      return ClipRRect(
        borderRadius: radius,
        child: Material(
          color: colors.glassStrong.withValues(alpha: 0.96),
          child: SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 44,
                    height: 5,
                    decoration: BoxDecoration(
                      color: colors.line.withValues(alpha: 0.85),
                      borderRadius: BorderRadius.circular(99),
                    ),
                  ),
                  if (title != null) ...[
                    const SizedBox(height: 16),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        title,
                        style: GoogleFonts.syne(
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.4,
                        ),
                      ),
                    ),
                  ],
                  const SizedBox(height: 12),
                  ...options.map((option) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () => Navigator.pop(context, option.value),
                          borderRadius: BorderRadius.circular(VelvetTokens.radiusMd),
                          child: Ink(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 14,
                            ),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(
                                VelvetTokens.radiusMd,
                              ),
                              border: Border.all(
                                color: option.destructive
                                    ? VelvetTheme.danger.withValues(alpha: 0.28)
                                    : VelvetTokens.line.withValues(alpha: 0.75),
                              ),
                              color: option.destructive
                                  ? VelvetTheme.danger.withValues(alpha: 0.06)
                                  : VelvetTokens.parchmentLift.withValues(alpha: 0.7),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 40,
                                  height: 40,
                                  alignment: Alignment.center,
                                  decoration: BoxDecoration(
                                    color: (option.destructive
                                            ? VelvetTheme.danger
                                            : VelvetTokens.ember)
                                        .withValues(alpha: 0.12),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Icon(
                                    option.icon,
                                    size: 20,
                                    color: option.destructive
                                        ? VelvetTheme.danger
                                        : VelvetTokens.emberDeep,
                                  ),
                                ),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: Text(
                                    option.label,
                                    style: GoogleFonts.dmSans(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 15,
                                      color: option.destructive
                                          ? VelvetTheme.danger
                                          : VelvetTheme.ink,
                                    ),
                                  ),
                                ),
                                Icon(
                                  Icons.north_east_rounded,
                                  size: 16,
                                  color: VelvetTheme.muted,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  }),
                ],
              ),
            ),
          ),
        ),
      );
    },
  );
}

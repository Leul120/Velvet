import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:velvet_mobile/core/theme/velvet_editorial_colors.dart';
import 'package:velvet_mobile/core/theme/velvet_theme.dart';
import 'package:velvet_mobile/core/theme/velvet_tokens.dart';
import 'package:velvet_mobile/core/widgets/editorial_background.dart';
import 'package:velvet_mobile/core/widgets/marketplace_flow_hint.dart';
import 'package:velvet_mobile/l10n/generated/app_localizations.dart';

/// Warm editorial atmospheric background for member surfaces.
class MistBackground extends StatelessWidget {
  const MistBackground({super.key, this.child, this.intensity = 1});

  final Widget? child;
  final double intensity;

  @override
  Widget build(BuildContext context) {
    return EditorialAtmosphere(
      intensity: intensity,
      variant: EditorialVariant.member,
      child: child,
    );
  }
}

/// Ambient Mesh Background for heavy scaffold surfaces to make app feel premium.
class VelvetAuthBackground extends StatefulWidget {
  const VelvetAuthBackground({super.key});

  @override
  State<VelvetAuthBackground> createState() => _VelvetAuthBackgroundState();
}

class _VelvetAuthBackgroundState extends State<VelvetAuthBackground> {
  @override
  Widget build(BuildContext context) {
    return const EditorialAtmosphere(
      intensity: 1.15,
      variant: EditorialVariant.auth,
    );
  }
}

class VelvetAuthScaffold extends StatelessWidget {
  const VelvetAuthScaffold({super.key, required this.body});

  final Widget body;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.velvet.surface,
      extendBodyBehindAppBar: true,
      extendBody: true,
      body: Stack(
        fit: StackFit.expand,
        children: [
          const VelvetAuthBackground(),
          SafeArea(child: VelvetPageMotion(child: body)),
        ],
      ),
    );
  }
}

class VelvetScaffold extends StatelessWidget {
  const VelvetScaffold({
    super.key,
    required this.body,
    this.appBar,
    this.bottomNavigationBar,
    this.floatingActionButton,
    this.safeArea = true,
    this.mistIntensity = 0.85,
    this.extendBody = false,
  });

  final Widget body;
  final PreferredSizeWidget? appBar;
  final Widget? bottomNavigationBar;
  final Widget? floatingActionButton;
  final bool safeArea;
  final double mistIntensity;
  final bool extendBody;

  @override
  Widget build(BuildContext context) {
    Widget content = body;
    if (safeArea) {
      content = SafeArea(child: content);
    }
    return Scaffold(
      backgroundColor: context.velvet.surface,
      extendBody: extendBody,
      appBar: appBar,
      floatingActionButton: floatingActionButton,
      bottomNavigationBar: bottomNavigationBar,
      body: Stack(
        fit: StackFit.expand,
        children: [
          MistBackground(intensity: mistIntensity),
          VelvetPageMotion(child: content),
        ],
      ),
    );
  }
}

/// A restrained entrance keeps navigation feeling responsive without distracting
/// from member tasks. It honours the operating system's reduced-motion setting.
class VelvetPageMotion extends StatefulWidget {
  const VelvetPageMotion({super.key, required this.child});

  final Widget child;

  @override
  State<VelvetPageMotion> createState() => _VelvetPageMotionState();
}

class _VelvetPageMotionState extends State<VelvetPageMotion>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 280),
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (MediaQuery.disableAnimationsOf(context)) {
      _controller.value = 1;
    } else {
      _controller.forward();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final curve = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    );
    return FadeTransition(
      opacity: curve,
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0, 0.018),
          end: Offset.zero,
        ).animate(curve),
        child: widget.child,
      ),
    );
  }
}

class VelvetWordmark extends StatelessWidget {
  const VelvetWordmark({
    super.key,
    this.size = 56,
    this.breathe = false,
    this.align = TextAlign.left,
  });

  final double size;
  final bool breathe;
  final TextAlign align;

  @override
  Widget build(BuildContext context) {
    return Text(
      'VELVET',
      textAlign: align,
      style: GoogleFonts.syne(
        fontSize: size,
        fontWeight: FontWeight.w800,
        color: context.velvet.ink,
        letterSpacing: -2.2,
        height: 0.9,
      ),
    );
  }
}

class VelvetButton extends StatefulWidget {
  const VelvetButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.loading = false,
    this.variant = VelvetButtonVariant.primary,
    this.icon,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool loading;
  final VelvetButtonVariant variant;
  final IconData? icon;

  @override
  State<VelvetButton> createState() => _VelvetButtonState();
}

enum VelvetButtonVariant { primary, secondary, ghost, danger }

class _VelvetButtonState extends State<VelvetButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final enabled = widget.onPressed != null && !widget.loading;
    Color bg;
    Color fg;
    BorderSide? side;

    switch (widget.variant) {
      case VelvetButtonVariant.primary:
        bg = VelvetTokens.ember;
        fg = VelvetTokens.onPrimary;
      case VelvetButtonVariant.secondary:
        bg = VelvetTheme.mistSlate.withValues(alpha: 0.1);
        fg = VelvetTheme.ink;
        side = null;
      case VelvetButtonVariant.ghost:
        bg = Colors.transparent;
        fg = VelvetTokens.ember;
        side = null;
      case VelvetButtonVariant.danger:
        bg = VelvetTheme.danger;
        fg = Colors.white;
    }

    final child = AnimatedScale(
      scale: _pressed && enabled ? 0.96 : 1.0,
      duration: VelvetTokens.motionFast,
      curve: Curves.easeOutBack,
      child: AnimatedOpacity(
        opacity: enabled ? 1 : 0.38,
        duration: VelvetTokens.motionInstant,
        child: Container(
          height: 58,
          width: double.infinity,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(VelvetTokens.radiusPill),
            border: side == null ? null : Border.fromBorderSide(side),
            boxShadow: widget.variant == VelvetButtonVariant.primary && enabled
                ? VelvetTokens.emberHalo(strength: _pressed ? 0.6 : 1)
                : widget.variant == VelvetButtonVariant.secondary && enabled
                    ? VelvetTokens.depthLift(elevation: 0.3)
                    : null,
          ),
          child: widget.loading
              ? SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(strokeWidth: 2.5, color: fg),
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (widget.icon != null) ...[
                      Icon(widget.icon, color: fg, size: 22),
                      const SizedBox(width: 8),
                    ],
                    Flexible(
                      child: Text(
                        widget.label,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.center,
                        style: GoogleFonts.syne(
                          color: fg,
                          fontWeight: FontWeight.w700,
                          fontSize: 18,
                          letterSpacing: -0.2,
                        ),
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );

    return Semantics(
      button: true,
      enabled: enabled,
      label: widget.label,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTapDown: enabled ? (_) => setState(() => _pressed = true) : null,
        onTapUp: enabled
            ? (_) {
                setState(() => _pressed = false);
                HapticFeedback.lightImpact();
                widget.onPressed?.call();
              }
            : null,
        onTapCancel: () => setState(() => _pressed = false),
        child: child,
      ),
    );
  }
}

class VelvetField extends StatelessWidget {
  const VelvetField({
    super.key,
    required this.controller,
    this.label,
    this.hint,
    this.keyboardType,
    this.textCapitalization = TextCapitalization.none,
    this.maxLength,
    this.maxLines = 1,
    this.enabled = true,
    this.onSubmitted,
    this.focusNode,
    this.textAlign = TextAlign.start,
    this.style,
    this.prefixIcon,
    this.suffixIcon,
    this.textInputAction,
    this.autofillHints,
    this.onChanged,
  });

  final TextEditingController controller;
  final String? label;
  final String? hint;
  final TextInputType? keyboardType;
  final TextCapitalization textCapitalization;
  final int? maxLength;
  final int maxLines;
  final bool enabled;
  final ValueChanged<String>? onSubmitted;
  final FocusNode? focusNode;
  final TextAlign textAlign;
  final TextStyle? style;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final TextInputAction? textInputAction;
  final Iterable<String>? autofillHints;
  final ValueChanged<String>? onChanged;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      focusNode: focusNode,
      enabled: enabled,
      keyboardType: keyboardType,
      textCapitalization: textCapitalization,
      maxLength: maxLength,
      maxLines: maxLines,
      textAlign: textAlign,
      style: style ?? Theme.of(context).textTheme.bodyLarge,
      textInputAction: textInputAction,
      autofillHints: autofillHints,
      onChanged: onChanged,
      onSubmitted: onSubmitted,
      onTapOutside: (_) => FocusManager.instance.primaryFocus?.unfocus(),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: prefixIcon,
        suffixIcon: suffixIcon,
        counterText: maxLength != null ? null : '',
      ),
    );
  }
}

class StatusRibbon extends StatelessWidget {
  const StatusRibbon({super.key, required this.status});

  final String status;

  String labelFor(AppLocalizations l10n) {
    switch (status.toUpperCase()) {
      case 'PROPOSED':
        return l10n.statusAwaitingYou;
      case 'PENDING':
      case 'SUBMITTED':
      case 'UNDER_REVIEW':
        return l10n.statusPending;
      case 'ACCEPTED':
      case 'MUTUAL':
        return l10n.statusConnected;
      case 'DECLINED':
        return l10n.statusDeclined;
      case 'EXPIRED':
        return l10n.statusExpired;
      case 'CONFIRMED':
        return l10n.statusConfirmed;
      case 'CHECKED_IN':
        return l10n.statusCheckedIn;
      case 'COMPLETED':
        return l10n.statusCompleted;
      case 'CANCELLED':
        return l10n.statusCancelled;
      case 'NO_SHOW':
        return l10n.statusNoShow;
      case 'APPROVED':
      case 'VERIFIED':
        return l10n.statusVerified;
      default:
        return status
            .replaceAll('_', ' ')
            .toLowerCase()
            .replaceFirstMapped(
              RegExp(r'^[a-z]'),
              (m) => m.group(0)!.toUpperCase(),
            );
    }
  }

  Color get _color {
    switch (status.toUpperCase()) {
      case 'MUTUAL':
      case 'ACCEPTED':
      case 'CONFIRMED':
      case 'COMPLETED':
      case 'CHECKED_IN':
      case 'APPROVED':
      case 'VERIFIED':
        return VelvetTheme.teal;
      case 'DECLINED':
      case 'CANCELLED':
      case 'NO_SHOW':
      case 'EXPIRED':
        return VelvetTheme.danger;
      default:
        return VelvetTheme.lapis;
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = _color;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: c.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        labelFor(AppLocalizations.of(context)),
        style: GoogleFonts.inter(
          color: c,
          fontSize: 12,
          fontWeight: FontWeight.w600,
          letterSpacing: -0.1,
        ),
      ),
    );
  }
}

class OtpBoxes extends StatefulWidget {
  const OtpBoxes({
    super.key,
    required this.controller,
    this.length = 6,
    this.onCompleted,
  });

  final TextEditingController controller;
  final int length;
  final ValueChanged<String>? onCompleted;

  @override
  State<OtpBoxes> createState() => _OtpBoxesState();
}

class _OtpBoxesState extends State<OtpBoxes> {
  late final List<FocusNode> _nodes;
  late final List<TextEditingController> _boxes;

  @override
  void initState() {
    super.initState();
    _nodes = List.generate(widget.length, (_) => FocusNode());
    final seed = widget.controller.text
        .padRight(widget.length)
        .substring(0, widget.length);
    _boxes = List.generate(
      widget.length,
      (i) => TextEditingController(text: seed[i].trim()),
    );
    widget.controller.addListener(_syncFromParent);
  }

  void _syncFromParent() {
    final t = widget.controller.text;
    for (var i = 0; i < widget.length; i++) {
      final ch = i < t.length ? t[i] : '';
      if (_boxes[i].text != ch) _boxes[i].text = ch;
    }
  }

  void _emit() {
    final code = _boxes.map((c) => c.text).join();
    widget.controller.text = code;
    if (code.length == widget.length) widget.onCompleted?.call(code);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_syncFromParent);
    for (final n in _nodes) {
      n.dispose();
    }
    for (final c in _boxes) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.velvet;
    return Row(
      children: List.generate(widget.length, (i) {
        return Expanded(
          child: Padding(
            padding: EdgeInsets.only(right: i == widget.length - 1 ? 0 : 8),
            child: TextField(
              controller: _boxes[i],
              focusNode: _nodes[i],
              textAlign: TextAlign.center,
              keyboardType: TextInputType.number,
              maxLength: 1,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: colors.ink,
                  ),
              decoration: const InputDecoration(
                counterText: '',
              ),
              onChanged: (v) {
                if (v.isNotEmpty && i < widget.length - 1) {
                  _nodes[i + 1].requestFocus();
                } else if (v.isEmpty && i > 0) {
                  _nodes[i - 1].requestFocus();
                }
                _emit();
              },
            ),
          ),
        );
      }),
    );
  }
}

class MembershipRibbon extends StatelessWidget {
  const MembershipRibbon({super.key, required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: VelvetTheme.line),
            color: VelvetTheme.surface.withValues(alpha: 0.7),
          ),
          child: Row(
            children: [
              const Icon(
                Icons.workspace_premium_outlined,
                size: 18,
                color: VelvetTheme.lapis,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  label,
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: context.velvet.ink,
                  ),
                ),
              ),
              const Icon(
                Icons.arrow_forward_ios,
                size: 12,
                color: VelvetTheme.muted,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Frosted floating dock — Apple Music / Instagram-style member chrome.
class VelvetBottomBar extends StatelessWidget {
  const VelvetBottomBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
    required this.labels,
    this.icons,
    this.activeIcons,
  });

  final int currentIndex;
  final ValueChanged<int> onTap;
  final List<String> labels;
  final List<IconData>? icons;
  final List<IconData>? activeIcons;

  static const _defaultIcons = [
    Icons.explore_outlined,
    Icons.chat_bubble_outline_rounded,
    Icons.workspace_premium_outlined,
    Icons.person_outline,
  ];
  static const _defaultActiveIcons = [
    Icons.explore,
    Icons.chat_bubble_rounded,
    Icons.workspace_premium,
    Icons.person,
  ];

  @override
  Widget build(BuildContext context) {
    final iconSet = icons ?? _defaultIcons;
    final activeSet = activeIcons ?? _defaultActiveIcons;
    return Container(
      color: Colors.transparent,
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 0, 24, 16),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(32),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: VelvetTheme.porcelain.withValues(alpha: 0.85),
                  borderRadius: BorderRadius.circular(32),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.5),
                  ),
                  boxShadow: VelvetTheme.softLift,
                ),
                child: Row(
                  children: List.generate(4, (i) {
                    final selected = currentIndex == i;
                    final color = selected ? VelvetTheme.teal : VelvetTheme.muted;
                    return Expanded(
                      child: Semantics(
                        button: true,
                        selected: selected,
                        label: labels[i],
                        child: GestureDetector(
                          behavior: HitTestBehavior.opaque,
                          onTap: () {
                            HapticFeedback.selectionClick();
                            onTap(i);
                          },
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              AnimatedScale(
                                scale: selected ? 1.05 : 1.0,
                                duration: const Duration(milliseconds: 200),
                                curve: Curves.easeOutBack,
                                child: Icon(
                                  selected ? activeSet[i] : iconSet[i],
                                  size: 26,
                                  color: color,
                                  shadows: selected
                                      ? [
                                          Shadow(
                                            color: VelvetTheme.teal.withValues(alpha: 0.4),
                                            blurRadius: 8,
                                            offset: const Offset(0, 2),
                                          )
                                        ]
                                      : null,
                                ),
                              ),
                              const SizedBox(height: 2),
                              AnimatedDefaultTextStyle(
                                duration: const Duration(milliseconds: 200),
                                style: GoogleFonts.inter(
                                  fontSize: 10,
                                  fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                                  color: color,
                                  letterSpacing: 0.1,
                                ),
                                child: Text(
                                  labels[i],
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Sliding segment control (Hinge / Maps style).
class VelvetSegmentedControl extends StatelessWidget {
  const VelvetSegmentedControl({
    super.key,
    required this.labels,
    required this.index,
    required this.onChanged,
  });

  final List<String> labels;
  final int index;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    final colors = context.velvet;
    return Container(
      height: 44,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: colors.parchmentLift,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: colors.line.withValues(alpha: 0.7)),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final w = constraints.maxWidth / labels.length;
          return Stack(
            clipBehavior: Clip.hardEdge,
            children: [
              AnimatedPositioned(
                duration: const Duration(milliseconds: 220),
                curve: Curves.easeOutCubic,
                left: w * index,
                top: 0,
                bottom: 0,
                width: w,
                child: Container(
                  decoration: BoxDecoration(
                    color: VelvetTokens.ember,
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
              ),
              Row(
                children: List.generate(labels.length, (i) {
                  final selected = i == index;
                  return Expanded(
                    child: Semantics(
                      button: true,
                      selected: selected,
                      label: labels[i],
                      child: GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: () {
                          HapticFeedback.selectionClick();
                          onChanged(i);
                        },
                        child: Center(
                          child: AnimatedDefaultTextStyle(
                            duration: const Duration(milliseconds: 200),
                            curve: Curves.easeOutCubic,
                            style: GoogleFonts.dmSans(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: selected
                                  ? VelvetTokens.onPrimary
                                  : colors.muted,
                            ),
                            child: Text(
                              labels[i],
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                }),
              ),
            ],
          );
        },
      ),
    );
  }
}

/// Compact circular icon chrome for headers.
class VelvetIconChip extends StatelessWidget {
  const VelvetIconChip({
    super.key,
    required this.icon,
    required this.onTap,
    this.badgeCount = 0,
  });

  final IconData icon;
  final VoidCallback onTap;
  final int badgeCount;

  @override
  Widget build(BuildContext context) {
    return ClipOval(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
        child: Material(
          color: Colors.white.withValues(alpha: 0.15),
          shape: const CircleBorder(),
          child: InkWell(
            customBorder: const CircleBorder(),
            highlightColor: VelvetTheme.teal.withValues(alpha: 0.2),
            onTap: () {
              HapticFeedback.selectionClick();
              onTap();
            },
            child: Container(
              width: 44,
              height: 44,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white.withValues(alpha: 0.16)),
              ),
              child: Badge(
                isLabelVisible: badgeCount > 0,
                backgroundColor: VelvetTheme.teal,
                label: Text(
                  '$badgeCount',
                  style: const TextStyle(fontSize: 10),
                ),
                child: Icon(icon, size: 20, color: context.velvet.ink),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// A calm, layout-preserving loading state for member screens.
class VelvetContentLoading extends StatelessWidget {
  const VelvetContentLoading({super.key, this.count = 3});

  final int count;

  @override
  Widget build(BuildContext context) {
    final colors = context.velvet;
    return Semantics(
      label: 'Loading content',
      child: ListView.separated(
        physics: const NeverScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(20, 26, 20, 20),
        itemCount: count,
        separatorBuilder: (_, _) => const SizedBox(height: 14),
        itemBuilder: (context, index) =>
            Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: colors.parchmentLift,
                    borderRadius: BorderRadius.circular(VelvetTokens.radiusMd),
                    border: Border.all(color: colors.line.withValues(alpha: 0.6)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: index.isEven ? 148 : 112,
                        height: 14,
                        decoration: BoxDecoration(
                          color: colors.line.withValues(alpha: 0.7),
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      const SizedBox(height: 14),
                      Container(
                        width: double.infinity,
                        height: 10,
                        decoration: BoxDecoration(
                          color: colors.line.withValues(alpha: 0.45),
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        width: 180,
                        height: 10,
                        decoration: BoxDecoration(
                          color: colors.line.withValues(alpha: 0.35),
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ],
                  ),
                )
                .animate(onPlay: (controller) => controller.repeat())
                .shimmer(
                  duration: 1400.ms,
                  color: VelvetTokens.ember.withValues(alpha: 0.12),
                )
                .fadeIn(duration: 280.ms),
      ),
    );
  }
}

/// Always-visible verification mark for cards, inbox, and chat.
class VelvetVerifiedBadge extends StatelessWidget {
  const VelvetVerifiedBadge({
    super.key,
    this.compact = false,
    this.onDark = false,
  });

  final bool compact;
  final bool onDark;

  @override
  Widget build(BuildContext context) {
    final size = compact ? 18.0 : 22.0;
    return Tooltip(
      message: 'Verified',
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: VelvetTheme.teal,
          border: Border.all(
            color: onDark ? Colors.white : VelvetTheme.porcelain,
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: onDark ? 0.35 : 0.12),
              blurRadius: 6,
            ),
          ],
        ),
        child: Icon(
          Icons.check_rounded,
          size: compact ? 12 : 14,
          color: Colors.white,
        ),
      ),
    );
  }
}

/// Centered empty / error state — works on every feed and list.
class VelvetEmptyState extends StatelessWidget {
  const VelvetEmptyState({
    super.key,
    required this.message,
    this.title,
    this.icon = Icons.storefront_outlined,
    this.flowSteps,
    this.actionLabel,
    this.onAction,
    this.secondaryLabel,
    this.onSecondary,
  });

  final String message;
  final String? title;
  final IconData icon;
  final List<MarketplaceFlowStep>? flowSteps;
  final String? actionLabel;
  final VoidCallback? onAction;
  final String? secondaryLabel;
  final VoidCallback? onSecondary;

  @override
  Widget build(BuildContext context) {
    final colors = context.velvet;

    return Semantics(
      liveRegion: true,
      child: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(
            horizontal: VelvetTokens.pageInset + 8,
            vertical: VelvetTokens.space40,
          ),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 360),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 72,
                  height: 72,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: VelvetTokens.ember.withValues(alpha: 0.12),
                    border: Border.all(
                      color: VelvetTokens.ember.withValues(alpha: 0.28),
                    ),
                  ),
                  child: Icon(icon, size: 32, color: VelvetTokens.ember),
                ),
                const SizedBox(height: VelvetTokens.space24),
                if (title != null) ...[
                  Text(
                    title!,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.syne(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.5,
                      color: colors.ink,
                    ),
                  ),
                  const SizedBox(height: VelvetTokens.space10),
                ],
                Text(
                  message,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: colors.muted,
                        height: 1.5,
                      ),
                ),
                if (flowSteps != null && flowSteps!.isNotEmpty) ...[
                  const SizedBox(height: VelvetTokens.space24),
                  MarketplaceFlowHint(steps: flowSteps!),
                ],
                if (actionLabel != null && onAction != null) ...[
                  const SizedBox(height: VelvetTokens.space24),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: onAction,
                      style: FilledButton.styleFrom(
                        minimumSize: const Size.fromHeight(52),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(999),
                        ),
                      ),
                      child: Text(actionLabel!),
                    ),
                  ),
                ],
                if (secondaryLabel != null && onSecondary != null) ...[
                  const SizedBox(height: VelvetTokens.space10),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      onPressed: onSecondary,
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size.fromHeight(48),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(999),
                        ),
                      ),
                      child: Text(secondaryLabel!),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    ).animate().fadeIn(duration: 280.ms).slideY(begin: 0.04, end: 0);
  }
}

class VelvetTrustedBadge extends StatelessWidget {
  const VelvetTrustedBadge({
    super.key,
    this.compact = false,
    this.onDark = false,
  });

  final bool compact;
  final bool onDark;

  @override
  Widget build(BuildContext context) {
    final accent = onDark ? VelvetTokens.ember : VelvetTheme.champagne;
    return Tooltip(
      message: 'Highly Trusted',
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: compact ? 6 : 8,
          vertical: compact ? 2 : 4,
        ),
        decoration: BoxDecoration(
          color: accent.withValues(alpha: onDark ? 0.18 : 0.15),
          borderRadius: BorderRadius.circular(6),
          border: Border.all(
            color: accent.withValues(alpha: onDark ? 0.4 : 0.3),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.workspace_premium,
              size: compact ? 12 : 14,
              color: accent,
            ),
            const SizedBox(width: 4),
            Text(
              'Highly Trusted',
              style: TextStyle(
                fontSize: compact ? 10 : 11,
                fontWeight: FontWeight.bold,
                color: accent,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Physical, sliding heavy stone-like slider replacing standard toggle switches.
class VelvetTactileSlider extends StatefulWidget {
  const VelvetTactileSlider({
    super.key,
    required this.label,
    required this.onChanged,
    this.initialValue = false,
  });

  final String label;
  final ValueChanged<bool> onChanged;
  final bool initialValue;

  @override
  State<VelvetTactileSlider> createState() => _VelvetTactileSliderState();
}

class _VelvetTactileSliderState extends State<VelvetTactileSlider> {
  late bool _value;

  @override
  void initState() {
    super.initState();
    _value = widget.initialValue;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onPanUpdate: (details) {
        if (details.delta.dx > 2 && !_value) {
          HapticFeedback.heavyImpact();
          setState(() => _value = true);
          widget.onChanged(true);
        } else if (details.delta.dx < -2 && _value) {
          HapticFeedback.heavyImpact();
          setState(() => _value = false);
          widget.onChanged(false);
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        margin: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: _value
              ? VelvetTokens.emberSoft.withValues(alpha: 0.22)
              : VelvetTokens.parchmentDeep.withValues(alpha: 0.35),
          borderRadius: BorderRadius.circular(VelvetTokens.radiusLg),
          border: Border.all(
            color: _value
                ? VelvetTokens.ember.withValues(alpha: 0.45)
                : VelvetTokens.line.withValues(alpha: 0.75),
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                widget.label,
                style: GoogleFonts.dmSans(
                  color: _value ? VelvetTheme.ink : VelvetTheme.muted,
                  fontWeight: _value ? FontWeight.w700 : FontWeight.w500,
                  fontSize: 14,
                ),
              ),
            ),
            AnimatedContainer(
              duration: VelvetTokens.motionFast,
              curve: VelvetTokens.easeEditorial,
              width: 50,
              height: 28,
              padding: const EdgeInsets.all(2),
              decoration: BoxDecoration(
                color: VelvetTokens.parchmentDeep.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: _value
                      ? VelvetTokens.ember.withValues(alpha: 0.45)
                      : VelvetTokens.line.withValues(alpha: 0.8),
                ),
              ),
              alignment: _value ? Alignment.centerRight : Alignment.centerLeft,
              child: Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _value ? VelvetTokens.ember : VelvetTheme.muted.withValues(alpha: 0.35),
                  boxShadow: _value ? VelvetTokens.emberHalo(strength: 0.25) : null,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

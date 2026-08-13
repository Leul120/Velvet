import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:velvet_mobile/core/theme/velvet_tokens.dart';

/// Procedural film grain overlay — lightweight, no asset dependency.
class VelvetGrainOverlay extends StatelessWidget {
  const VelvetGrainOverlay({super.key, this.opacity = 0.045});

  final double opacity;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: CustomPaint(
        painter: _GrainPainter(opacity: opacity),
        size: Size.infinite,
      ),
    );
  }
}

class _GrainPainter extends CustomPainter {
  _GrainPainter({required this.opacity});

  final double opacity;
  static final _rng = math.Random(42);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.white.withValues(alpha: opacity);
    const step = 3.0;
    for (var x = 0.0; x < size.width; x += step) {
      for (var y = 0.0; y < size.height; y += step) {
        if (_rng.nextDouble() > 0.62) continue;
        final a = opacity * (0.4 + _rng.nextDouble() * 0.6);
        canvas.drawCircle(
          Offset(x, y),
          0.55 + _rng.nextDouble() * 0.4,
          paint..color = Colors.white.withValues(alpha: a),
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant _GrainPainter oldDelegate) =>
      oldDelegate.opacity != opacity;
}

/// Animated mesh-gradient atmosphere with ambient glow and grain.
class EditorialAtmosphere extends StatefulWidget {
  const EditorialAtmosphere({
    super.key,
    this.child,
    this.intensity = 1,
    this.variant = EditorialVariant.member,
    this.showGrain = true,
  });

  final Widget? child;
  final double intensity;
  final EditorialVariant variant;
  final bool showGrain;

  @override
  State<EditorialAtmosphere> createState() => _EditorialAtmosphereState();
}

enum EditorialVariant { auth, member, detail, chat }

class _EditorialAtmosphereState extends State<EditorialAtmosphere>
    with SingleTickerProviderStateMixin {
  late final AnimationController _drift;

  @override
  void initState() {
    super.initState();
    _drift = AnimationController(
      vsync: this,
      duration: VelvetTokens.motionAmbient,
    );
    if (!_reduceMotion) _drift.repeat(reverse: true);
  }

  bool get _reduceMotion =>
      WidgetsBinding.instance.platformDispatcher.accessibilityFeatures
          .reduceMotion;

  @override
  void dispose() {
    _drift.dispose();
    super.dispose();
  }

  List<Color> get _meshColors {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    if (isDark) {
      return VelvetTokens.darkMeshPalette(intensity: widget.intensity);
    }
    switch (widget.variant) {
      case EditorialVariant.auth:
        return [
          VelvetTokens.parchment,
          VelvetTokens.emberSoft.withValues(alpha: 0.35),
          VelvetTokens.plumSoft.withValues(alpha: 0.18),
          VelvetTokens.parchmentDeep,
        ];
      case EditorialVariant.member:
        return VelvetTokens.meshPalette(intensity: widget.intensity);
      case EditorialVariant.detail:
        return [
          VelvetTokens.ink,
          VelvetTokens.plum.withValues(alpha: 0.85),
          VelvetTokens.emberDeep.withValues(alpha: 0.6),
          VelvetTokens.inkSoft,
        ];
      case EditorialVariant.chat:
        return [
          VelvetTokens.parchmentDeep,
          VelvetTokens.parchment,
          VelvetTokens.sage.withValues(alpha: 0.12),
          VelvetTokens.parchmentLift,
        ];
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = _reduceMotion ? 0.5 : _drift.value;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final baseColor = isDark
        ? VelvetTokens.darkVoid
        : (widget.variant == EditorialVariant.detail
            ? VelvetTokens.ink
            : VelvetTokens.parchment);
    return ColoredBox(
      color: baseColor,
      child: Stack(
        fit: StackFit.expand,
        children: [
          AnimatedBuilder(
            animation: _drift,
            builder: (context, _) {
              return CustomPaint(
                painter: _MeshPainter(
                  colors: _meshColors,
                  drift: t,
                  intensity: widget.intensity,
                ),
                size: Size.infinite,
              );
            },
          ),
          // Ambient glow orbs
          Positioned(
            top: -80 + 40 * t,
            right: -60 - 30 * (1 - t),
            child: _GlowOrb(
              color: VelvetTokens.ember.withValues(alpha: 0.14 * widget.intensity),
              size: 280,
            ),
          ),
          Positioned(
            bottom: 120 - 50 * t,
            left: -90 + 40 * t,
            child: _GlowOrb(
              color: VelvetTokens.plumSoft.withValues(alpha: 0.10 * widget.intensity),
              size: 240,
            ),
          ),
          if (widget.variant == EditorialVariant.member)
            Positioned(
              top: MediaQuery.sizeOf(context).height * 0.35,
              right: -40,
              child: _GlowOrb(
                color: VelvetTokens.gold.withValues(alpha: 0.08 * widget.intensity),
                size: 180,
              ),
            ),
          if (widget.showGrain) VelvetGrainOverlay(opacity: 0.038 * widget.intensity),
          if (widget.child != null) widget.child!,
        ],
      ),
    );
  }
}

class _GlowOrb extends StatelessWidget {
  const _GlowOrb({required this.color, required this.size});

  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) {
    return ImageFiltered(
      imageFilter: ImageFilter.blur(sigmaX: 60, sigmaY: 60),
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(shape: BoxShape.circle, color: color),
      ),
    );
  }
}

class _MeshPainter extends CustomPainter {
  _MeshPainter({
    required this.colors,
    required this.drift,
    required this.intensity,
  });

  final List<Color> colors;
  final double drift;
  final double intensity;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final paint = Paint();

    paint.shader = RadialGradient(
      center: Alignment(-0.6 + drift * 0.3, -0.7 + drift * 0.15),
      radius: 1.1,
      colors: [colors[0], colors[0].withValues(alpha: 0)],
    ).createShader(rect);
    canvas.drawRect(rect, paint);

    paint.shader = RadialGradient(
      center: Alignment(0.8 - drift * 0.2, -0.2 + drift * 0.1),
      radius: 0.85,
      colors: [
        colors[1].withValues(alpha: 0.55 * intensity),
        colors[1].withValues(alpha: 0),
      ],
    ).createShader(rect);
    canvas.drawRect(rect, paint);

    paint.shader = RadialGradient(
      center: Alignment(-0.3 + drift * 0.15, 0.85 - drift * 0.1),
      radius: 0.9,
      colors: [
        colors[2].withValues(alpha: 0.45 * intensity),
        colors[2].withValues(alpha: 0),
      ],
    ).createShader(rect);
    canvas.drawRect(rect, paint);

    paint.shader = LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [
        Colors.transparent,
        colors[3].withValues(alpha: 0.25 * intensity),
      ],
      stops: const [0.65, 1.0],
    ).createShader(rect);
    canvas.drawRect(rect, paint);
  }

  @override
  bool shouldRepaint(covariant _MeshPainter old) =>
      old.drift != drift || old.intensity != intensity;
}

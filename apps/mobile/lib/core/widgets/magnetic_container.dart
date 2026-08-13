import 'package:flutter/material.dart';
import 'package:flutter/physics.dart';
import 'package:flutter/services.dart';

/// A physical wrapper for interactive artwork, cards, and controls.
///
/// It leans toward the user's thumb while held, then returns on a spring. The
/// shadow is derived from its displacement, giving large pieces of UI a useful
/// sense of mass without imposing a visual style on their children.
class MagneticContainer extends StatefulWidget {
  const MagneticContainer({
    required this.child,
    super.key,
    this.onTap,
    this.enabled = true,
    this.haptics = true,
    this.magneticRange = 18,
    this.pressScale = 0.975,
    this.borderRadius,
    this.semanticLabel,
  });

  final Widget child;
  final VoidCallback? onTap;
  final bool enabled;
  final bool haptics;
  final double magneticRange;
  final double pressScale;
  final BorderRadius? borderRadius;
  final String? semanticLabel;

  @override
  State<MagneticContainer> createState() => _MagneticContainerState();
}

class _MagneticContainerState extends State<MagneticContainer>
    with TickerProviderStateMixin {
  static const _spring = SpringDescription(
    mass: 0.58,
    stiffness: 340,
    damping: 23,
  );

  late final AnimationController _x;
  late final AnimationController _y;
  late final AnimationController _scale;
  Offset _velocity = Offset.zero;
  DateTime? _lastUpdate;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _x = AnimationController.unbounded(vsync: this);
    _y = AnimationController.unbounded(vsync: this);
    _scale = AnimationController.unbounded(vsync: this, value: 1);
  }

  @override
  void dispose() {
    _x.dispose();
    _y.dispose();
    _scale.dispose();
    super.dispose();
  }

  void _springTo(
    AnimationController controller,
    double target,
    double velocity,
  ) {
    controller.animateWith(
      SpringSimulation(_spring, controller.value, target, velocity),
    );
  }

  void _begin(DragDownDetails details) {
    if (!widget.enabled) return;
    setState(() => _isPressed = true);
    _lastUpdate = DateTime.now();
    _velocity = Offset.zero;
    _springTo(_scale, widget.pressScale, 0);
    if (widget.haptics) HapticFeedback.selectionClick();
    _move(details.localPosition, Offset.zero);
  }

  void _move(Offset pointer, Offset velocity) {
    final renderBox = context.findRenderObject() as RenderBox?;
    final size = renderBox?.size;
    if (size == null || size.isEmpty) return;
    final center = size.center(Offset.zero);
    final normalized = Offset(
      ((pointer.dx - center.dx) / (size.width / 2)).clamp(-1.0, 1.0),
      ((pointer.dy - center.dy) / (size.height / 2)).clamp(-1.0, 1.0),
    );
    final target = normalized * widget.magneticRange;
    _springTo(_x, target.dx, velocity.dx);
    _springTo(_y, target.dy, velocity.dy);
  }

  void _update(DragUpdateDetails details) {
    if (!widget.enabled) return;
    final now = DateTime.now();
    if (_lastUpdate != null) {
      final seconds =
          now.difference(_lastUpdate!).inMicroseconds /
          Duration.microsecondsPerSecond;
      if (seconds > 0) _velocity = details.delta / seconds;
    }
    _lastUpdate = now;
    _move(details.localPosition, _velocity * 0.018);
  }

  void _release([DragEndDetails? details]) {
    if (!widget.enabled) return;
    final speed =
        details?.velocity.pixelsPerSecond.distance ?? _velocity.distance;
    setState(() => _isPressed = false);
    _springTo(_x, 0, _velocity.dx * 0.012);
    _springTo(_y, 0, _velocity.dy * 0.012);
    _springTo(_scale, 1, 0);
    if (widget.haptics && speed > 850) HapticFeedback.heavyImpact();
  }

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: widget.onTap != null,
      label: widget.semanticLabel,
      child: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: widget.enabled ? widget.onTap : null,
        onPanDown: _begin,
        onPanUpdate: _update,
        onPanEnd: _release,
        onPanCancel: _release,
        child: AnimatedBuilder(
          animation: Listenable.merge([_x, _y, _scale]),
          child: widget.child,
          builder: (context, child) {
            final offset = Offset(_x.value, _y.value);
            final distance = (offset.distance / widget.magneticRange).clamp(
              0.0,
              1.0,
            );
            return Transform.translate(
              offset: offset,
              child: Transform(
                alignment: Alignment.center,
                transform: Matrix4.identity()
                  ..setEntry(3, 2, 0.0014)
                  ..rotateX(-offset.dy / 850)
                  ..rotateY(offset.dx / 850)
                  ..scaleByDouble(_scale.value, _scale.value, _scale.value, 1),
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    borderRadius: widget.borderRadius,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(
                          alpha: (_isPressed ? 0.14 : 0.10) + distance * 0.18,
                        ),
                        blurRadius: 12 + distance * 28,
                        spreadRadius: -5 + distance * 2,
                        offset: Offset(offset.dx * 0.55, 8 + offset.dy * 0.55),
                      ),
                    ],
                  ),
                  child: child,
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

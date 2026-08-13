import 'package:flutter/physics.dart';
import 'package:flutter/widgets.dart';

/// Scroll physics for Velvet's spatial surfaces.
///
/// The low drag coefficient gives a long, gallery-like glide; the spring
/// catches the viewport when it reaches an edge. Attach it to a single
/// [CustomScrollView] where a different feel is wanted, or install it through
/// [ScrollConfiguration] to make it the app default.
class VelvetSpatialScrollPhysics extends ScrollPhysics {
  const VelvetSpatialScrollPhysics({super.parent});

  static const SpringDescription _edgeSpring = SpringDescription(
    mass: 0.72,
    stiffness: 230,
    damping: 24,
  );

  @override
  VelvetSpatialScrollPhysics applyTo(ScrollPhysics? ancestor) {
    return VelvetSpatialScrollPhysics(parent: buildParent(ancestor));
  }

  @override
  double applyPhysicsToUserOffset(ScrollMetrics position, double offset) {
    // Rubber-band the content only after it crosses a real boundary. This
    // keeps a slow drag tactile without making normal scrolling feel syrupy.
    final overscrollPastStart = position.pixels < position.minScrollExtent;
    final overscrollPastEnd = position.pixels > position.maxScrollExtent;
    final isPushingOutward =
        (overscrollPastStart && offset < 0) ||
        (overscrollPastEnd && offset > 0);
    if (!isPushingOutward) return offset;

    final viewport = position.viewportDimension;
    if (viewport <= 0) return offset;
    final overscroll = overscrollPastStart
        ? position.minScrollExtent - position.pixels
        : position.pixels - position.maxScrollExtent;
    final fraction = (overscroll / viewport).clamp(0.0, 1.0);
    // A quadratic resistance curve makes the edge feel like a soft membrane.
    return offset * (0.52 * (1 - fraction)).clamp(0.08, 0.52);
  }

  @override
  Simulation? createBallisticSimulation(
    ScrollMetrics position,
    double velocity,
  ) {
    final tolerance = toleranceFor(position);
    if (position.outOfRange) {
      final end = position.pixels < position.minScrollExtent
          ? position.minScrollExtent
          : position.maxScrollExtent;
      return ScrollSpringSimulation(
        _edgeSpring,
        position.pixels,
        end,
        velocity,
        tolerance: tolerance,
      );
    }

    if (velocity.abs() >= tolerance.velocity) {
      // FrictionSimulation provides the inertial, low-friction glide. Its final
      // position is deliberately constrained by the scrollable's extents.
      final friction = FrictionSimulation(0.085, position.pixels, velocity);
      final projected = friction.finalX;
      if (projected < position.minScrollExtent ||
          projected > position.maxScrollExtent) {
        final edge = projected < position.minScrollExtent
            ? position.minScrollExtent
            : position.maxScrollExtent;
        return ScrollSpringSimulation(
          _edgeSpring,
          position.pixels,
          edge,
          velocity,
          tolerance: tolerance,
        );
      }
      return friction;
    }
    return null;
  }
}

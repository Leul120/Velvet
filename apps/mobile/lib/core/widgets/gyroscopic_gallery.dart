import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sensors_plus/sensors_plus.dart';

/// A full-bleed card gallery whose depth reacts to both paging and device tilt.
///
/// Sensor input is decorative: cards remain fully usable on devices without
/// motion hardware and when the platform requests reduced motion.
class GyroscopicGallery extends StatefulWidget {
  const GyroscopicGallery({
    required this.itemCount,
    required this.itemBuilder,
    super.key,
    this.onPageChanged,
    this.viewportFraction = 0.84,
    this.padding = const EdgeInsets.fromLTRB(0, 12, 0, 116),
  });

  final int itemCount;
  final IndexedWidgetBuilder itemBuilder;
  final ValueChanged<int>? onPageChanged;
  final double viewportFraction;
  final EdgeInsets padding;

  @override
  State<GyroscopicGallery> createState() => _GyroscopicGalleryState();
}

class _GyroscopicGalleryState extends State<GyroscopicGallery> {
  late final PageController _controller;
  final ValueNotifier<double> _page = ValueNotifier(0);
  final ValueNotifier<Offset> _tilt = ValueNotifier(Offset.zero);
  StreamSubscription<AccelerometerEvent>? _motion;
  int _lastHapticPage = 0;

  @override
  void initState() {
    super.initState();
    _controller = PageController(viewportFraction: widget.viewportFraction)
      ..addListener(_onScroll);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (MediaQuery.disableAnimationsOf(context)) {
      _motion?.cancel();
      _motion = null;
    } else {
      _motion ??= accelerometerEventStream(
        samplingPeriod: SensorInterval.gameInterval,
      ).listen(_onMotion, onError: (_) {}, cancelOnError: false);
    }
  }

  void _onScroll() {
    if (_controller.hasClients) {
      _page.value = _controller.page ?? _controller.initialPage.toDouble();
    }
  }

  void _onMotion(AccelerometerEvent event) {
    if (!mounted) return;
    final desired = Offset(
      (-event.x / 9.8).clamp(-1.0, 1.0),
      (event.y / 9.8).clamp(-1.0, 1.0),
    );
    _tilt.value = Offset.lerp(_tilt.value, desired, 0.075)!;
  }

  @override
  void dispose() {
    _motion?.cancel();
    _controller
      ..removeListener(_onScroll)
      ..dispose();
    _page.dispose();
    _tilt.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<double>(
      valueListenable: _page,
      builder: (context, page, _) => ValueListenableBuilder<Offset>(
        valueListenable: _tilt,
        builder: (context, tilt, _) => PageView.builder(
          controller: _controller,
          clipBehavior: Clip.none,
          padEnds: false,
          onPageChanged: (index) {
            if (index != _lastHapticPage) HapticFeedback.selectionClick();
            _lastHapticPage = index;
            widget.onPageChanged?.call(index);
          },
          itemCount: widget.itemCount,
          itemBuilder: (context, index) {
            final delta = index - page;
            final depth = (1 - delta.abs() * 0.14).clamp(0.82, 1.0);
            return Transform.translate(
              offset: Offset(-delta * 22 + tilt.dx * 9, tilt.dy * 7),
              child: Transform(
                alignment: Alignment.center,
                transform: Matrix4.identity()
                  ..setEntry(3, 2, 0.0012)
                  ..rotateY((-delta * 0.18) + tilt.dx * 0.055)
                  ..rotateX(tilt.dy * -0.038)
                  ..scaleByDouble(depth, depth, 1, 1),
                child: Padding(
                  padding: EdgeInsets.fromLTRB(
                    index == 0 ? 20 : 8,
                    widget.padding.top,
                    8,
                    widget.padding.bottom,
                  ),
                  child: widget.itemBuilder(context, index),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

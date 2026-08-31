import 'package:flutter/material.dart';

/// A wrapper widget that displays an image with a repeating, semi-transparent
/// diagonal watermark overlay containing viewing member info & timestamp.
class WatermarkedImage extends StatelessWidget {
  const WatermarkedImage({
    super.key,
    required this.imageUrl,
    required this.watermarkText,
    this.fit = BoxFit.cover,
    this.width,
    this.height,
  });

  final String imageUrl;
  final String watermarkText;
  final BoxFit fit;
  final double? width;
  final double? height;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: height,
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Base Image
          Image.network(
            imageUrl,
            fit: fit,
            errorBuilder: (context, error, stackTrace) => Container(
              color: Colors.black26,
              child: const Icon(Icons.broken_image, color: Colors.white38),
            ),
          ),

          // Custom Watermark Painter Overlay
          Positioned.fill(
            child: IgnorePointer(
              child: CustomPaint(
                painter: _WatermarkPainter(
                  text: watermarkText,
                  opacity: 0.18,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _WatermarkPainter extends CustomPainter {
  _WatermarkPainter({required this.text, required this.opacity});

  final String text;
  final double opacity;

  @override
  void paint(Canvas canvas, Size size) {
    final textStyle = TextStyle(
      color: Colors.white.withOpacity(opacity),
      fontSize: 11,
      fontWeight: FontWeight.w700,
      letterSpacing: 1.2,
    );

    final textSpan = TextSpan(text: text, style: textStyle);
    final textPainter = TextPainter(
      text: textSpan,
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();

    canvas.save();
    canvas.rotate(-0.35); // Slight diagonal rotation angle

    final stepX = textPainter.width + 60;
    final stepY = textPainter.height + 45;

    for (double y = -size.height; y < size.height * 2; y += stepY) {
      for (double x = -size.width; x < size.width * 2; x += stepX) {
        textPainter.paint(canvas, Offset(x, y));
      }
    }

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _WatermarkPainter oldDelegate) {
    return oldDelegate.text != text || oldDelegate.opacity != opacity;
  }
}

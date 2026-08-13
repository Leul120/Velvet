import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:velvet_mobile/core/network/media_url.dart';
import 'package:velvet_mobile/core/theme/velvet_theme.dart';

class VelvetImageCarousel extends StatefulWidget {
  const VelvetImageCarousel({
    super.key,
    required this.photoUrls,
    this.height,
    this.width,
    this.aspectRatio,
    this.borderRadius,
    this.showGradient = true,
  });

  final List<String> photoUrls;
  final double? height;
  final double? width;
  final double? aspectRatio;
  final BorderRadiusGeometry? borderRadius;
  final bool showGradient;

  @override
  State<VelvetImageCarousel> createState() => _VelvetImageCarouselState();
}

class _VelvetImageCarouselState extends State<VelvetImageCarousel> {
  final PageController _pageController = PageController();
  int _currentIndex = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.photoUrls.isEmpty) {
      return _wrapContainer(
        child: Container(
          color: VelvetTheme.mistSlate,
          child: const Center(
            child: Icon(Icons.person_outline, size: 48, color: Colors.white54),
          ),
        ),
      );
    }

    return _wrapContainer(
      child: Stack(
        fit: StackFit.expand,
        children: [
          GestureDetector(
            onTapUp: (details) {
              final width = MediaQuery.sizeOf(context).width;
              if (details.localPosition.dx < width * 0.4) {
                if (_currentIndex > 0) {
                  _pageController.previousPage(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeOutCubic,
                  );
                }
              } else {
                if (_currentIndex < widget.photoUrls.length - 1) {
                  _pageController.nextPage(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeOutCubic,
                  );
                }
              }
            },
            child: PageView.builder(
              physics: const NeverScrollableScrollPhysics(),
              controller: _pageController,
              onPageChanged: (index) {
                setState(() => _currentIndex = index);
              },
              itemCount: widget.photoUrls.length,
              itemBuilder: (context, index) {
                return Image.network(
                      resolveMediaUrl(widget.photoUrls[index]),
                      fit: BoxFit.cover,
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return Container(color: VelvetTheme.mistSlate);
                      },
                      errorBuilder: (_, _, _) => Container(
                        color: VelvetTheme.mistSlate,
                        child: const Icon(
                          Icons.broken_image_outlined,
                          size: 32,
                          color: Colors.white54,
                        ),
                      ),
                    )
                    .animate(key: ValueKey(widget.photoUrls[index]))
                    .fadeIn(duration: 300.ms);
              },
            ),
          ),
          if (widget.showGradient)
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              height: 180,
              child: IgnorePointer(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        VelvetTheme.nightLift.withValues(alpha: 0.8),
                        VelvetTheme.nightLift.withValues(alpha: 0.95),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          if (widget.photoUrls.length > 1)
            Positioned(
              top: 12,
              left: 0,
              right: 0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  widget.photoUrls.length,
                  (index) => AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    margin: const EdgeInsets.symmetric(horizontal: 3),
                    height: 4,
                    width: _currentIndex == index ? 24 : 12,
                    decoration: BoxDecoration(
                      color: _currentIndex == index
                          ? Colors.white
                          : Colors.white.withValues(alpha: 0.4),
                      borderRadius: BorderRadius.circular(2),
                      boxShadow: [
                        if (_currentIndex == index)
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.2),
                            blurRadius: 4,
                            offset: const Offset(0, 1),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _wrapContainer({required Widget child}) {
    Widget content = child;

    if (widget.borderRadius != null) {
      content = ClipRRect(borderRadius: widget.borderRadius!, child: content);
    }

    if (widget.aspectRatio != null) {
      content = AspectRatio(aspectRatio: widget.aspectRatio!, child: content);
    }

    if (widget.width != null || widget.height != null) {
      content = SizedBox(
        width: widget.width,
        height: widget.height,
        child: content,
      );
    }

    return content;
  }
}

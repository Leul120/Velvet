with open('lib/core/widgets/velvet_widgets.dart', 'r') as f:
    text = f.read()

sig = '''class VelvetAuthBackground extends StatelessWidget {
  const VelvetAuthBackground({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: Stack(
        fit: StackFit.expand,
        children: [
          Positioned(
            top: -100,
            right: -100,
            child: Container(
              width: 350,
              height: 350,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: VelvetTheme.teal.withValues(alpha: 0.2),
              ),
            ),
          ),
          Positioned(
            bottom: -50,
            left: -100,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: VelvetTheme.orangeSoft.withValues(alpha: 0.15),
              ),
            ),
          ),
          BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 80, sigmaY: 80),
            child: Container(color: Colors.white.withValues(alpha: 0.5)),
          ),
        ],
      ),
    );
  }
}'''

sig_new = '''class VelvetAuthBackground extends StatefulWidget {
  const VelvetAuthBackground({super.key});

  @override
  State<VelvetAuthBackground> createState() => _VelvetAuthBackgroundState();
}

class _VelvetAuthBackgroundState extends State<VelvetAuthBackground> with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl = AnimationController(vsync: this, duration: const Duration(seconds: 14))..repeat(reverse: true);

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: AnimatedBuilder(
        animation: _ctrl,
        builder: (context, _) => Stack(
          fit: StackFit.expand,
          children: [
            Positioned(
              top: -100 + (30 * _ctrl.value),
              right: -100 - (40 * _ctrl.value),
              child: Transform.scale(
                scale: 1.0 + (0.15 * _ctrl.value),
                child: Container(
                  width: 350,
                  height: 350,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: VelvetTheme.teal.withValues(alpha: 0.15),
                  ),
                ),
              ),
            ),
            Positioned(
              bottom: -50 - (20 * _ctrl.value),
              left: -100 + (50 * _ctrl.value),
              child: Transform.scale(
                scale: 1.0 + (0.2 * (1 - _ctrl.value)),
                child: Container(
                  width: 300,
                  height: 300,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: VelvetTheme.orangeSoft.withValues(alpha: 0.1),
                  ),
                ),
              ),
            ),
            Positioned.fill(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 80, sigmaY: 80),
                child: Container(color: Colors.white.withValues(alpha: 0.5)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}'''

text = text.replace(sig, sig_new)
with open('lib/core/widgets/velvet_widgets.dart', 'w') as f:
    f.write(text)

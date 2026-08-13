import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:velvet_mobile/core/theme/velvet_theme.dart';

/// Wine-night ambient backdrops for the member shell.
///
/// Priority:
/// 1. Bundled files in `assets/atmosphere/` (any .jpg/.jpeg/.png/.webp)
/// 2. Built-in remote editorial set (network)
class VelvetAtmosphere extends StatefulWidget {
  const VelvetAtmosphere({
    super.key,
    this.child,
    this.intensity = 1,
    this.scrimStrength = 0.42,
  });

  final Widget? child;
  final double intensity;
  final double scrimStrength;

  @override
  State<VelvetAtmosphere> createState() => _VelvetAtmosphereState();
}

class _VelvetAtmosphereState extends State<VelvetAtmosphere>
    with TickerProviderStateMixin {
  static const _remoteFallback = <String>[
    'https://images.unsplash.com/photo-1515372039744-b8f02a3ae446?auto=format&fit=crop&w=1440&h=2560&q=90',
    'https://images.unsplash.com/photo-1529626455594-4ff0802cfb7e?auto=format&fit=crop&w=1440&h=2560&q=90',
    'https://images.unsplash.com/photo-1534528741775-53994a69daeb?auto=format&fit=crop&w=1440&h=2560&q=90',
    'https://images.unsplash.com/photo-1494790108377-be9c29b29330?auto=format&fit=crop&w=1440&h=2560&q=90',
    'https://images.unsplash.com/photo-1524504388940-b1c1722653e1?auto=format&fit=crop&w=1440&h=2560&q=90',
    'https://images.unsplash.com/photo-1488426862026-3ee34a7d66df?auto=format&fit=crop&w=1440&h=2560&q=90',
  ];

  static const _imageExt = {'.jpg', '.jpeg', '.png', '.webp'};

  late final AnimationController _cross;
  late final AnimationController _drift;
  List<_AtmosphereSrc> _sources = const [];
  int _index = 0;
  bool _ready = false;
  String _sourceLabel = 'none';

  @override
  void initState() {
    super.initState();
    _cross = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    );
    _drift = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 22),
    )..repeat(reverse: true);
    _bootstrap();
  }

  Future<List<String>> _listLocalBackdropAssets() async {
    try {
      final manifest = await AssetManifest.loadFromAssetBundle(rootBundle);
      final keys = manifest
          .listAssets()
          .where((k) => k.startsWith('assets/atmosphere/'))
          .where((k) {
            final lower = k.toLowerCase();
            return _imageExt.any(lower.endsWith);
          })
          .toList()
        ..sort();
      if (keys.isNotEmpty) return keys;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('[VelvetAtmosphere] AssetManifest failed: $e');
      }
    }
    const probes = [
      'assets/atmosphere/bg_01.jpg',
      'assets/atmosphere/bg_02.jpg',
      'assets/atmosphere/bg_03.jpg',
      'assets/atmosphere/bg_04.jpg',
      'assets/atmosphere/bg_05.jpg',
      'assets/atmosphere/bg_06.jpg',
      'assets/atmosphere/bg_01.png',
      'assets/atmosphere/bg_02.png',
      'assets/atmosphere/bg_03.png',
      'assets/atmosphere/bg_04.png',
      'assets/atmosphere/bg_05.png',
      'assets/atmosphere/bg_06.png',
    ];
    final found = <String>[];
    for (final path in probes) {
      try {
        await rootBundle.load(path);
        found.add(path);
      } catch (_) {}
    }
    return found;
  }

  Future<void> _bootstrap() async {
    final localPaths = await _listLocalBackdropAssets();
    final locals = localPaths.map(_AtmosphereSrc.asset).toList();
    final sources = locals.isNotEmpty
        ? locals
        : _remoteFallback.map(_AtmosphereSrc.network).toList();
    if (kDebugMode) {
      debugPrint(
        '[VelvetAtmosphere] ${locals.isNotEmpty ? 'LOCAL' : 'REMOTE'} '
        'sources=${sources.length} ${localPaths.join(', ')}',
      );
    }
    if (!mounted) return;
    setState(() {
      _sources = sources;
      _sourceLabel = locals.isNotEmpty ? 'local:${locals.length}' : 'remote';
      _ready = true;
    });
    _scheduleAdvance();
  }

  void _scheduleAdvance() {
    Future<void>.delayed(const Duration(seconds: 8), () async {
      if (!mounted || _sources.length < 2) return;
      await _cross.forward(from: 0);
      if (!mounted) return;
      setState(() {
        _index = (_index + 1) % _sources.length;
        _cross.value = 0;
      });
      _scheduleAdvance();
    });
  }

  @override
  void dispose() {
    _cross.dispose();
    _drift.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final next = _sources.isEmpty ? null : _sources[(_index + 1) % _sources.length];
    final current = _sources.isEmpty ? null : _sources[_index];

    return SizedBox.expand(
      child: Stack(
        fit: StackFit.expand,
        children: [
          const ColoredBox(color: VelvetTheme.night),
          if (_ready && current != null)
            AnimatedBuilder(
              animation: Listenable.merge([_cross, _drift]),
              builder: (context, _) {
                final zoom = 1.04 + (_drift.value * 0.05);
                final fade = Curves.easeInOut.transform(_cross.value);
                return Stack(
                  fit: StackFit.expand,
                  children: [
                    Opacity(
                      opacity: (1 - fade) * widget.intensity.clamp(0.0, 1.0),
                      child: Transform.scale(
                        scale: zoom,
                        child: _AtmosphereImage(src: current),
                      ),
                    ),
                    if (next != null && fade > 0)
                      Opacity(
                        opacity: fade * widget.intensity.clamp(0.0, 1.0),
                        child: Transform.scale(
                          scale: zoom + 0.02,
                          child: _AtmosphereImage(src: next),
                        ),
                      ),
                  ],
                );
              },
            ),
          DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  VelvetTheme.night.withValues(alpha: 0.35 * widget.scrimStrength),
                  VelvetTheme.night.withValues(alpha: 0.18 * widget.scrimStrength),
                  VelvetTheme.tealDeep.withValues(alpha: 0.22 * widget.scrimStrength),
                  VelvetTheme.night.withValues(alpha: 0.55 * widget.scrimStrength),
                ],
                stops: const [0.0, 0.35, 0.7, 1.0],
              ),
            ),
          ),
          DecoratedBox(
            decoration: BoxDecoration(
              gradient: RadialGradient(
                center: Alignment.center,
                radius: 1.2,
                colors: [
                  Colors.transparent,
                  Colors.black.withValues(alpha: 0.28 * widget.scrimStrength),
                ],
              ),
            ),
          ),
          if (widget.child != null) widget.child!,
          if (kDebugMode && _ready)
            Positioned(
              right: 10,
              bottom: 88,
              child: IgnorePointer(
                child: Text(
                  _sourceLabel,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.35),
                    fontSize: 10,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _AtmosphereSrc {
  const _AtmosphereSrc._(this.assetPath, this.networkUrl);
  factory _AtmosphereSrc.asset(String path) => _AtmosphereSrc._(path, null);
  factory _AtmosphereSrc.network(String url) => _AtmosphereSrc._(null, url);

  final String? assetPath;
  final String? networkUrl;
}

class _AtmosphereImage extends StatelessWidget {
  const _AtmosphereImage({required this.src});
  final _AtmosphereSrc src;

  @override
  Widget build(BuildContext context) {
    if (src.assetPath != null) {
      return Image.asset(
        src.assetPath!,
        fit: BoxFit.cover,
        alignment: const Alignment(0, -0.12),
        filterQuality: FilterQuality.high,
        errorBuilder: (_, _, _) => const ColoredBox(color: VelvetTheme.night),
      );
    }
    return Image.network(
      src.networkUrl!,
      fit: BoxFit.cover,
      alignment: const Alignment(0, -0.12),
      filterQuality: FilterQuality.high,
      errorBuilder: (_, _, _) => const ColoredBox(color: VelvetTheme.night),
      loadingBuilder: (context, child, progress) {
        if (progress == null) return child;
        return const ColoredBox(color: VelvetTheme.night);
      },
    );
  }
}

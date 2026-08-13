import 'dart:async';
import 'dart:io';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';
import 'package:velvet_mobile/core/theme/velvet_theme.dart';
import 'package:velvet_mobile/core/theme/velvet_editorial_colors.dart';
import 'package:velvet_mobile/core/theme/velvet_tokens.dart';

class VoiceNoteResult {
  const VoiceNoteResult({required this.path, required this.fileName, required this.seconds});
  final String path;
  final String fileName;
  final int seconds;
}

/// Instagram-style hold-to-record controller used by the chat composer.
class VoiceNoteController extends ChangeNotifier {
  static const maxSeconds = 120;
  static const cancelDx = -72.0;
  static const minSeconds = 1;

  AudioRecorder? _recorder;
  Timer? _tick;
  StreamSubscription<Amplitude>? _ampSub;

  bool holding = false;
  bool recording = false;
  bool willCancel = false;
  bool busy = false;
  int elapsed = 0;
  double slideDx = 0;
  double level = 0;
  String? _path;

  bool get active => holding || recording;

  String get clock {
    final m = (elapsed ~/ 60).toString();
    final s = (elapsed % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  Future<AudioRecorder?> _ensureRecorder(void Function(String) onError) async {
    try {
      _recorder ??= AudioRecorder();
      return _recorder;
    } on MissingPluginException {
      onError('Stop the app and run again — mic plugin needs a full restart.');
      return null;
    } catch (_) {
      onError('Microphone unavailable.');
      return null;
    }
  }

  Future<void> begin({
    required bool enabled,
    required void Function(String) onError,
  }) async {
    if (!enabled || busy || recording) return;
    HapticFeedback.mediumImpact();
    holding = true;
    willCancel = false;
    slideDx = 0;
    elapsed = 0;
    level = 0;
    _path = null;
    notifyListeners();

    final recorder = await _ensureRecorder(onError);
    if (recorder == null) {
      holding = false;
      notifyListeners();
      return;
    }

    try {
      final ok = await recorder.hasPermission();
      if (!ok) {
        onError('Allow microphone access to send voice notes.');
        holding = false;
        notifyListeners();
        return;
      }
      if (!holding) return;

      final dir = await getTemporaryDirectory();
      final filePath = p.join(
        dir.path,
        'velvet_voice_${DateTime.now().millisecondsSinceEpoch}.m4a',
      );
      await recorder.start(
        const RecordConfig(
          encoder: AudioEncoder.aacLc,
          bitRate: 128000,
          sampleRate: 44100,
          numChannels: 1,
        ),
        path: filePath,
      );
      _path = filePath;
      _tick?.cancel();
      _tick = Timer.periodic(const Duration(seconds: 1), (_) {
        if (!recording) return;
        elapsed++;
        notifyListeners();
        if (elapsed >= maxSeconds) {
          unawaited(finish(send: !willCancel, onError: onError));
        }
      });
      await _ampSub?.cancel();
      _ampSub = recorder.onAmplitudeChanged(const Duration(milliseconds: 80)).listen((a) {
        level = ((a.current + 45) / 45).clamp(0.0, 1.0);
        notifyListeners();
      });
      recording = true;
      notifyListeners();
    } on MissingPluginException {
      onError('Stop the app and run again — mic plugin needs a full restart.');
      holding = false;
      recording = false;
      notifyListeners();
    } catch (_) {
      onError('Could not start recording.');
      holding = false;
      recording = false;
      notifyListeners();
    }
  }

  void updateSlide(double dxFromOrigin) {
    if (!holding) return;
    final next = dxFromOrigin.clamp(-140.0, 0.0);
    final cancel = next <= cancelDx;
    if (cancel != willCancel) HapticFeedback.selectionClick();
    slideDx = next;
    willCancel = cancel;
    notifyListeners();
  }

  Future<VoiceNoteResult?> finish({
    required bool send,
    required void Function(String) onError,
  }) async {
    if (busy && !recording) return null;
    busy = true;
    holding = false;
    notifyListeners();

    _tick?.cancel();
    await _ampSub?.cancel();
    _ampSub = null;

    String? path = _path;
    final seconds = elapsed;
    final cancel = willCancel || !send;

    try {
      final recorder = _recorder;
      if (recorder != null && await recorder.isRecording()) {
        final stopped = await recorder.stop();
        if (stopped != null && stopped.isNotEmpty) path = stopped;
      }
    } catch (_) {}

    final recordedPath = path;
    final shouldSend = !cancel && recordedPath != null && seconds >= minSeconds;
    if (!shouldSend && recordedPath != null) {
      try {
        final f = File(recordedPath);
        if (await f.exists()) await f.delete();
      } catch (_) {}
    }

    recording = false;
    willCancel = false;
    slideDx = 0;
    level = 0;
    _path = null;
    elapsed = 0;
    busy = false;
    notifyListeners();

    if (shouldSend) {
      HapticFeedback.lightImpact();
      return VoiceNoteResult(
        path: recordedPath,
        fileName: p.basename(recordedPath),
        seconds: seconds,
      );
    }
    if (!cancel && seconds < minSeconds) {
      onError('Hold a little longer to send a voice note.');
    }
    return null;
  }

  @override
  void dispose() {
    _tick?.cancel();
    _ampSub?.cancel();
    final r = _recorder;
    _recorder = null;
    if (r != null) unawaited(r.dispose());
    super.dispose();
  }
}

class VoiceRecordingBar extends StatelessWidget {
  const VoiceRecordingBar({
    super.key,
    required this.controller,
    required this.pulse,
  });

  final VoiceNoteController controller;
  final Animation<double> pulse;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: pulse,
      builder: (context, _) {
        return ListenableBuilder(
          listenable: controller,
          builder: (context, _) {
            final willCancel = controller.willCancel;
            final accent = willCancel ? VelvetTheme.danger : VelvetTokens.ember;
            final glow = 0.35 + pulse.value * 0.35;
            return Transform.translate(
              offset: Offset(controller.slideDx * 0.25, 0),
              child: Container(
                height: 48,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      accent.withValues(alpha: 0.14),
                      VelvetTokens.parchmentLift.withValues(alpha: 0.92),
                    ],
                  ),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(VelvetTokens.radiusLg),
                    topRight: Radius.circular(VelvetTokens.radiusSm),
                    bottomLeft: Radius.circular(VelvetTokens.radiusSm),
                    bottomRight: Radius.circular(VelvetTokens.radiusMd),
                  ),
                  border: Border.all(color: accent.withValues(alpha: 0.38)),
                  boxShadow: willCancel
                      ? null
                      : VelvetTokens.emberHalo(strength: glow * 0.5),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(
                        color: VelvetTheme.danger.withValues(alpha: glow),
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      controller.clock,
                      style: GoogleFonts.syne(
                        fontWeight: FontWeight.w800,
                        fontSize: 15,
                        letterSpacing: -0.3,
                        color: context.velvet.ink,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: willCancel
                          ? Text(
                              'Release to cancel',
                              style: GoogleFonts.dmSans(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: VelvetTheme.danger,
                              ),
                            )
                          : Row(
                              children: [
                                Icon(
                                  Icons.chevron_left_rounded,
                                  size: 18,
                                  color: context.velvet.muted.withValues(alpha: 0.85),
                                ),
                                Flexible(
                                  child: Text(
                                    'Slide to cancel',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: GoogleFonts.dmSans(
                                      fontSize: 12,
                                      color: context.velvet.muted,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Expanded(child: _MiniWave(level: controller.level, color: accent)),
                              ],
                            ),
                    ),
                    const SizedBox(width: 6),
                    Icon(
                      willCancel ? Icons.delete_outline_rounded : Icons.mic_rounded,
                      color: accent,
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}

class _MiniWave extends StatelessWidget {
  const _MiniWave({required this.level, required this.color});
  final double level;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 22,
      child: Row(
        children: List.generate(7, (i) {
          final phase = (i / 7) * math.pi;
          final h = 4.0 + (level * 16) * (0.45 + 0.55 * math.sin(phase + level * 4));
          return Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 1.2),
              child: Align(
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 60),
                  height: h.clamp(4, 20),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.9),
                    borderRadius: BorderRadius.circular(99),
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}

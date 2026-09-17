import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:just_audio/just_audio.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';
import 'package:velvet_mobile/core/network/media_url.dart';
import 'package:velvet_mobile/core/theme/velvet_editorial_colors.dart';
import 'package:velvet_mobile/core/theme/velvet_theme.dart';
import 'package:velvet_mobile/core/theme/velvet_tokens.dart';
import 'package:velvet_mobile/core/widgets/velvet_feedback.dart';

class VoiceIntroCard extends StatefulWidget {
  const VoiceIntroCard({
    super.key,
    required this.voiceIntroUrl,
    required this.onRecord,
    required this.onDelete,
  });

  final String? voiceIntroUrl;
  final VoidCallback onRecord;
  final VoidCallback onDelete;

  @override
  State<VoiceIntroCard> createState() => _VoiceIntroCardState();
}

class _VoiceIntroCardState extends State<VoiceIntroCard> {
  AudioPlayer? _player;
  bool _isPlaying = false;
  Duration _position = Duration.zero;
  Duration _duration = Duration.zero;
  StreamSubscription? _posSub;
  StreamSubscription? _durSub;
  StreamSubscription? _stateSub;

  @override
  void didUpdateWidget(covariant VoiceIntroCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.voiceIntroUrl != widget.voiceIntroUrl) {
      _cleanup();
    }
  }

  void _cleanup() {
    _posSub?.cancel();
    _durSub?.cancel();
    _stateSub?.cancel();
    _player?.dispose();
    _player = null;
    _isPlaying = false;
    _position = Duration.zero;
    _duration = Duration.zero;
  }

  @override
  void dispose() {
    _cleanup();
    super.dispose();
  }

  Future<void> _togglePlayback() async {
    if (widget.voiceIntroUrl == null || widget.voiceIntroUrl!.isEmpty) return;

    if (_player == null) {
      _player = AudioPlayer();
      _posSub = _player!.positionStream.listen((pos) {
        if (mounted) setState(() => _position = pos);
      });
      _durSub = _player!.durationStream.listen((dur) {
        if (mounted && dur != null) setState(() => _duration = dur);
      });
      _stateSub = _player!.playerStateStream.listen((state) {
        if (mounted) {
          final completed = state.processingState == ProcessingState.completed;
          setState(() {
            _isPlaying = state.playing && !completed;
            if (completed) _position = Duration.zero;
          });
        }
      });
      try {
        await _player!.setUrl(resolveMediaUrl(widget.voiceIntroUrl!));
      } catch (e) {
        if (mounted) {
          showVelvetErrorToast(context, message: 'Could not play voice intro');
        }
        return;
      }
    }

    if (_isPlaying) {
      await _player!.pause();
    } else {
      if (_player!.processingState == ProcessingState.completed) {
        await _player!.seek(Duration.zero);
      }
      await _player!.play();
    }
  }

  String _formatDuration(Duration d) {
    final m = d.inMinutes;
    final s = d.inSeconds % 60;
    return '$m:${s.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final hasVoice = widget.voiceIntroUrl != null && widget.voiceIntroUrl!.isNotEmpty;

    return Container(
      decoration: BoxDecoration(
        color: context.velvet.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: context.velvet.cardBorder),
      ),
      padding: const EdgeInsets.all(16),
      child: hasVoice
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      radius: 22,
                      backgroundColor: VelvetTokens.ember.withValues(alpha: 0.15),
                      child: IconButton(
                        icon: Icon(
                          _isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
                          color: VelvetTokens.ember,
                          size: 24,
                        ),
                        onPressed: _togglePlayback,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Active Voice Intro',
                            style: GoogleFonts.syne(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: VelvetTokens.ink,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            _duration > Duration.zero
                                ? '${_formatDuration(_position)} / ${_formatDuration(_duration)}'
                                : 'Ready to preview',
                            style: GoogleFonts.dmSans(
                              fontSize: 12,
                              color: context.velvet.muted,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete_outline_rounded, size: 20),
                      color: VelvetTokens.ember,
                      tooltip: 'Delete Voice Intro',
                      onPressed: widget.onDelete,
                    ),
                  ],
                ),
                if (_duration > Duration.zero) ...[
                  const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: _duration.inMilliseconds > 0
                          ? (_position.inMilliseconds / _duration.inMilliseconds).clamp(0.0, 1.0)
                          : 0.0,
                      backgroundColor: context.velvet.cardBorder,
                      valueColor: const AlwaysStoppedAnimation<Color>(VelvetTokens.ember),
                      minHeight: 4,
                    ),
                  ),
                ],
                const SizedBox(height: 12),
                OutlinedButton.icon(
                  onPressed: widget.onRecord,
                  icon: const Icon(Icons.mic_rounded, size: 16),
                  label: const Text('Record New Intro', style: TextStyle(fontSize: 12)),
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size.fromHeight(38),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ],
            )
          : Column(
              children: [
                Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: context.velvet.cardBorder.withValues(alpha: 0.5),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.mic_none_rounded, color: VelvetTokens.ember),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'No Voice Intro Yet',
                            style: GoogleFonts.syne(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: VelvetTokens.ink,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Introduce yourself with a 15-second voice clip',
                            style: GoogleFonts.dmSans(
                              fontSize: 12,
                              color: context.velvet.muted,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                FilledButton.icon(
                  onPressed: widget.onRecord,
                  icon: const Icon(Icons.fiber_manual_record_rounded, size: 14, color: Colors.redAccent),
                  label: const Text('Record Voice Intro'),
                  style: FilledButton.styleFrom(
                    minimumSize: const Size.fromHeight(42),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}

Future<void> showVoiceRecorderSheet(
  BuildContext context, {
  required Future<void> Function(String filePath) onSave,
}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => _VoiceRecorderSheet(onSave: onSave),
  );
}

class _VoiceRecorderSheet extends StatefulWidget {
  const _VoiceRecorderSheet({required this.onSave});
  final Future<void> Function(String filePath) onSave;

  @override
  State<_VoiceRecorderSheet> createState() => _VoiceRecorderSheetState();
}

enum _RecordState { idle, recording, stopped, saving }

class _VoiceRecorderSheetState extends State<_VoiceRecorderSheet> {
  final AudioRecorder _recorder = AudioRecorder();
  AudioPlayer? _previewPlayer;

  _RecordState _state = _RecordState.idle;
  String? _recordedPath;
  int _seconds = 0;
  Timer? _timer;
  bool _isPlayingPreview = false;

  @override
  void dispose() {
    _timer?.cancel();
    _recorder.dispose();
    _previewPlayer?.dispose();
    super.dispose();
  }

  Future<void> _startRecording() async {
    try {
      final hasPerm = await _recorder.hasPermission();
      if (!hasPerm) {
        if (mounted) {
          showVelvetErrorToast(context, message: 'Microphone permission denied');
        }
        return;
      }
      final tempDir = await getTemporaryDirectory();
      final path = p.join(tempDir.path, 'voice_intro_${DateTime.now().millisecondsSinceEpoch}.m4a');

      await _recorder.start(
        const RecordConfig(
          encoder: AudioEncoder.aacLc,
          bitRate: 64000,
          sampleRate: 44100,
        ),
        path: path,
      );

      _recordedPath = path;
      setState(() {
        _state = _RecordState.recording;
        _seconds = 0;
      });

      _timer?.cancel();
      _timer = Timer.periodic(const Duration(seconds: 1), (t) {
        if (!mounted) return;
        setState(() => _seconds = t.tick);
        if (_seconds >= 45) {
          _stopRecording();
        }
      });
    } catch (e) {
      if (mounted) {
        showVelvetErrorToast(context, message: 'Could not start recording');
      }
    }
  }

  Future<void> _stopRecording() async {
    _timer?.cancel();
    try {
      final path = await _recorder.stop();
      if (path != null) {
        _recordedPath = path;
      }
      setState(() {
        _state = _RecordState.stopped;
      });
    } catch (e) {
      if (mounted) {
        showVelvetErrorToast(context, message: 'Error stopping recording');
      }
    }
  }

  Future<void> _togglePreview() async {
    if (_recordedPath == null) return;
    if (_previewPlayer == null) {
      _previewPlayer = AudioPlayer();
      _previewPlayer!.playerStateStream.listen((state) {
        if (mounted) {
          final done = state.processingState == ProcessingState.completed;
          setState(() => _isPlayingPreview = state.playing && !done);
        }
      });
      await _previewPlayer!.setFilePath(_recordedPath!);
    }

    if (_isPlayingPreview) {
      await _previewPlayer!.pause();
    } else {
      if (_previewPlayer!.processingState == ProcessingState.completed) {
        await _previewPlayer!.seek(Duration.zero);
      }
      await _previewPlayer!.play();
    }
  }

  Future<void> _save() async {
    if (_recordedPath == null) return;
    _previewPlayer?.pause();
    setState(() => _state = _RecordState.saving);
    try {
      await widget.onSave(_recordedPath!);
      if (mounted) {
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        setState(() => _state = _RecordState.stopped);
        showVelvetErrorToast(context, message: 'Failed to upload voice intro');
      }
    }
  }

  String _formatSeconds(int sec) {
    final m = sec ~/ 60;
    final s = sec % 60;
    return '$m:${s.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(20, 16, 20, 24 + MediaQuery.of(context).viewInsets.bottom),
      decoration: BoxDecoration(
        color: context.velvet.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: context.velvet.cardBorder,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Record Voice Intro',
            style: GoogleFonts.syne(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: VelvetTokens.ink,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Share a brief greeting, your accent, or what makes you unique.',
            textAlign: TextAlign.center,
            style: GoogleFonts.dmSans(fontSize: 13, color: context.velvet.muted),
          ),
          const SizedBox(height: 24),
          if (_state == _RecordState.idle) ...[
            GestureDetector(
              onTap: _startRecording,
              child: Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: VelvetTokens.ember.withValues(alpha: 0.1),
                  border: Border.all(color: VelvetTokens.ember, width: 2),
                ),
                child: const Icon(Icons.mic_rounded, size: 40, color: VelvetTokens.ember),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Tap to Start Recording',
              style: GoogleFonts.dmSans(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: VelvetTokens.ink,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Maximum duration: 45s',
              style: GoogleFonts.dmSans(fontSize: 12, color: context.velvet.muted),
            ),
          ] else if (_state == _RecordState.recording) ...[
            GestureDetector(
              onTap: _stopRecording,
              child: Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.redAccent.withValues(alpha: 0.15),
                  border: Border.all(color: Colors.redAccent, width: 2),
                ),
                child: const Icon(Icons.stop_rounded, size: 40, color: Colors.redAccent),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              _formatSeconds(_seconds),
              style: GoogleFonts.syne(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: Colors.redAccent,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Tap stop when finished',
              style: GoogleFonts.dmSans(fontSize: 12, color: context.velvet.muted),
            ),
          ] else if (_state == _RecordState.stopped) ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton.filled(
                  onPressed: _togglePreview,
                  icon: Icon(_isPlayingPreview ? Icons.pause_rounded : Icons.play_arrow_rounded),
                  iconSize: 28,
                  style: IconButton.styleFrom(
                    backgroundColor: VelvetTokens.ember,
                    foregroundColor: Colors.white,
                    minimumSize: const Size(54, 54),
                  ),
                ),
                const SizedBox(width: 16),
                Text(
                  'Recorded (${_formatSeconds(_seconds)})',
                  style: GoogleFonts.dmSans(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: VelvetTokens.ink,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: _startRecording,
                    child: const Text('Re-record'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FilledButton(
                    onPressed: _save,
                    child: const Text('Save & Upload'),
                  ),
                ),
              ],
            ),
          ] else if (_state == _RecordState.saving) ...[
            const SizedBox(
              height: 60,
              child: Center(
                child: CircularProgressIndicator(),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Uploading voice intro...',
              style: GoogleFonts.dmSans(fontSize: 13, color: context.velvet.muted),
            ),
          ],
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}

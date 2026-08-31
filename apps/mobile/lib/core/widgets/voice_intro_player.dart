import 'package:flutter/material.dart';

/// A compact voice intro audio snippet player button for performer profile cards.
class VoiceIntroPlayer extends StatefulWidget {
  const VoiceIntroPlayer({
    super.key,
    required this.audioUrl,
    this.label = 'Voice Intro (0:15)',
  });

  final String audioUrl;
  final String label;

  @override
  State<VoiceIntroPlayer> createState() => _VoiceIntroPlayerState();
}

class _VoiceIntroPlayerState extends State<VoiceIntroPlayer> {
  bool _isPlaying = false;

  void _togglePlay() {
    setState(() {
      _isPlaying = !_isPlaying;
    });
    if (_isPlaying) {
      // Auto-stop after 15 seconds preview simulation
      Future.delayed(const Duration(seconds: 15), () {
        if (mounted && _isPlaying) {
          setState(() => _isPlaying = false);
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: _togglePlay,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: _isPlaying
              ? const Color(0xFFEA580C).withOpacity(0.15)
              : Colors.white.withOpacity(0.06),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: _isPlaying
                ? const Color(0xFFEA580C).withOpacity(0.4)
                : Colors.white12,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              _isPlaying ? Icons.pause_circle_filled : Icons.play_circle_fill,
              color: _isPlaying ? const Color(0xFFEA580C) : Colors.white70,
              size: 22,
            ),
            const SizedBox(width: 8),
            Text(
              _isPlaying ? 'Playing intro...' : widget.label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: _isPlaying ? const Color(0xFFEA580C) : Colors.white87,
              ),
            ),
            if (_isPlaying) ...[
              const SizedBox(width: 8),
              const SizedBox(
                width: 12,
                height: 12,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFEA580C)),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:just_audio/just_audio.dart';
import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';
import 'package:velvet_mobile/core/network/media_url.dart';
import 'package:velvet_mobile/core/network/dio_client.dart';
import 'package:velvet_mobile/core/theme/velvet_theme.dart';
import 'package:velvet_mobile/core/widgets/velvet_feedback.dart';
import 'package:velvet_mobile/features/social/social_api.dart';
import 'package:video_player/video_player.dart';

final _mediaTokenProvider = FutureProvider<String?>((ref) {
  return ref.watch(secureStorageProvider).read(key: 'access_token');
});

class ChatMediaBubble extends ConsumerWidget {
  const ChatMediaBubble({super.key, required this.message, required this.mine});

  final ChatMessage message;
  final bool mine;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (!message.hasMedia) return const SizedBox.shrink();
    final url = resolveMediaUrl(message.mediaUrl);
    final token = ref.watch(_mediaTokenProvider).valueOrNull;
    final headers = token == null || token.isEmpty
        ? const <String, String>{}
        : {'Authorization': 'Bearer $token'};
    final type = (message.mediaType ?? 'FILE').toUpperCase();
    final fg = mine ? Colors.white : VelvetTheme.ink;

    return switch (type) {
      'IMAGE' => ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Image.network(
          url,
          headers: headers,
          fit: BoxFit.cover,
          width: double.infinity,
          errorBuilder: (_, _, _) =>
              _fallback(fg, Icons.broken_image_outlined, 'Image unavailable'),
        ),
      ),
      'VIDEO' => _VideoBubble(
        key: ValueKey(token),
        url: url,
        headers: headers,
        accent: fg,
      ),
      'AUDIO' => _AudioBubble(
        key: ValueKey(token),
        url: url,
        headers: headers,
        name: message.mediaName ?? 'Audio',
        accent: fg,
      ),
      _ => _ProtectedFileAttachment(
        url: url,
        name: message.mediaName ?? 'Attachment',
        accent: fg,
      ),
    };
  }

  Widget _fallback(Color fg, IconData icon, String label) {
    return Container(
      height: 120,
      alignment: Alignment.center,
      color: Colors.black12,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: fg),
          const SizedBox(height: 6),
          Text(label, style: TextStyle(color: fg, fontSize: 12)),
        ],
      ),
    );
  }
}

class _ProtectedFileAttachment extends ConsumerStatefulWidget {
  const _ProtectedFileAttachment({
    required this.url,
    required this.name,
    required this.accent,
  });

  final String url;
  final String name;
  final Color accent;

  @override
  ConsumerState<_ProtectedFileAttachment> createState() =>
      _ProtectedFileAttachmentState();
}

class _ProtectedFileAttachmentState
    extends ConsumerState<_ProtectedFileAttachment> {
  bool _opening = false;

  String get _safeName {
    final cleaned = widget.name.replaceAll(RegExp(r'[^A-Za-z0-9._-]'), '_');
    return cleaned.isEmpty ? 'attachment' : cleaned;
  }

  Future<void> _open() async {
    if (_opening) return;
    setState(() => _opening = true);
    try {
      // Dio attaches/refreshes the bearer token, unlike an external browser.
      final response = await ref.read(dioProvider).getUri<List<int>>(
        Uri.parse(widget.url),
        options: Options(responseType: ResponseType.bytes),
      );
      final bytes = response.data;
      if (bytes == null || bytes.isEmpty) throw StateError('Empty attachment');
      final directory = await getTemporaryDirectory();
      final file = File('${directory.path}/$_safeName');
      await file.writeAsBytes(bytes, flush: true);
      final result = await OpenFilex.open(file.path);
      if (result.type != ResultType.done) {
        throw StateError(result.message);
      }
    } catch (_) {
      if (mounted) {
        showVelvetErrorToast(context, message: 'Could not open attachment');
      }
    } finally {
      if (mounted) setState(() => _opening = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: _opening ? null : _open,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _opening
              ? SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: widget.accent,
                  ),
                )
              : Icon(
                  Icons.insert_drive_file_outlined,
                  color: widget.accent,
                  size: 22,
                ),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              widget.name,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(color: widget.accent, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}

class _VideoBubble extends StatefulWidget {
  const _VideoBubble({
    super.key,
    required this.url,
    required this.headers,
    required this.accent,
  });
  final String url;
  final Map<String, String> headers;
  final Color accent;

  @override
  State<_VideoBubble> createState() => _VideoBubbleState();
}

class _VideoBubbleState extends State<_VideoBubble> {
  VideoPlayerController? _controller;
  bool _ready = false;
  bool _failed = false;

  @override
  void initState() {
    super.initState();
    final c = VideoPlayerController.networkUrl(
      Uri.parse(widget.url),
      httpHeaders: widget.headers,
    );
    _controller = c;
    c
        .initialize()
        .then((_) {
          if (!mounted) return;
          setState(() => _ready = true);
        })
        .catchError((_) {
          if (!mounted) return;
          setState(() => _failed = true);
        });
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_failed || _controller == null) {
      return Text('Video unavailable', style: TextStyle(color: widget.accent));
    }
    if (!_ready) {
      return const SizedBox(
        height: 140,
        child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
      );
    }
    final c = _controller!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AspectRatio(
          aspectRatio: c.value.aspectRatio == 0 ? 16 / 9 : c.value.aspectRatio,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Stack(
              alignment: Alignment.center,
              children: [
                VideoPlayer(c),
                Material(
                  color: Colors.black38,
                  shape: const CircleBorder(),
                  child: IconButton(
                    onPressed: () {
                      setState(() {
                        if (c.value.isPlaying) {
                          c.pause();
                        } else {
                          c.play();
                        }
                      });
                    },
                    icon: Icon(
                      c.value.isPlaying
                          ? Icons.pause_rounded
                          : Icons.play_arrow_rounded,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _AudioBubble extends StatefulWidget {
  const _AudioBubble({
    super.key,
    required this.url,
    required this.headers,
    required this.name,
    required this.accent,
  });
  final String url;
  final Map<String, String> headers;
  final String name;
  final Color accent;

  @override
  State<_AudioBubble> createState() => _AudioBubbleState();
}

class _AudioBubbleState extends State<_AudioBubble> {
  final _player = AudioPlayer();
  bool _playing = false;

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }

  Future<void> _toggle() async {
    if (_playing) {
      await _player.pause();
      setState(() => _playing = false);
      return;
    }
    try {
      await _player.setAudioSource(
        AudioSource.uri(Uri.parse(widget.url), headers: widget.headers),
      );
      _player.play();
      setState(() => _playing = true);
      _player.playerStateStream.listen((s) {
        if (s.processingState == ProcessingState.completed && mounted) {
          setState(() => _playing = false);
        }
      });
    } catch (_) {
      if (mounted) {
        showVelvetErrorToast(context, message: 'Could not play audio');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          onPressed: _toggle,
          icon: Icon(
            _playing ? Icons.pause_circle_filled : Icons.play_circle_filled,
            color: widget.accent,
          ),
        ),
        Flexible(
          child: Text(
            widget.name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(color: widget.accent, fontWeight: FontWeight.w600),
          ),
        ),
      ],
    );
  }
}

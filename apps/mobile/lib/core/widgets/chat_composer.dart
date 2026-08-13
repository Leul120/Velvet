import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:velvet_mobile/core/theme/velvet_editorial_colors.dart';
import 'package:velvet_mobile/core/theme/velvet_theme.dart';
import 'package:velvet_mobile/core/theme/velvet_tokens.dart';
import 'package:velvet_mobile/features/social/voice_note_sheet.dart';

/// Floating frosted chat composer.
class ChatComposerSlab extends StatefulWidget {
  const ChatComposerSlab({
    super.key,
    required this.controller,
    required this.canCompose,
    required this.canSend,
    required this.uploading,
    required this.sending,
    required this.hintText,
    required this.closedHintText,
    required this.onSend,
    required this.onAttach,
    required this.voiceController,
    required this.voicePulse,
    required this.micButton,
    required this.recordingMicButton,
  });

  final TextEditingController controller;
  final bool canCompose;
  final bool canSend;
  final bool uploading;
  final bool sending;
  final String hintText;
  final String closedHintText;
  final VoidCallback onSend;
  final VoidCallback onAttach;
  final VoiceNoteController voiceController;
  final Animation<double> voicePulse;
  final Widget micButton;
  final Widget recordingMicButton;

  @override
  State<ChatComposerSlab> createState() => _ChatComposerSlabState();
}

class _ChatComposerSlabState extends State<ChatComposerSlab> {
  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_onTextChanged);
  }

  @override
  void didUpdateWidget(ChatComposerSlab oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      oldWidget.controller.removeListener(_onTextChanged);
      widget.controller.addListener(_onTextChanged);
    }
  }

  void _onTextChanged() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onTextChanged);
    super.dispose();
  }

  void _handleSend() {
    if (!widget.canCompose || widget.sending) return;
    HapticFeedback.lightImpact();
    widget.onSend();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.velvet;
    final hasText = widget.controller.text.trim().isNotEmpty;
    final voiceActive = widget.voiceController.active;

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        VelvetTokens.pageInset,
        0,
        VelvetTokens.pageInset,
        14,
      ),
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(28),
          boxShadow: [
            BoxShadow(
              color: colors.ink.withValues(alpha: 0.1),
              blurRadius: 28,
              spreadRadius: -4,
              offset: const Offset(0, 12),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(28),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 22, sigmaY: 22),
            child: Container(
              padding: const EdgeInsets.fromLTRB(6, 6, 6, 6),
              decoration: BoxDecoration(
                color: colors.glassStrong.withValues(alpha: 0.88),
                borderRadius: BorderRadius.circular(28),
                border: Border.all(color: colors.line.withValues(alpha: 0.5)),
              ),
              child: voiceActive
                  ? Row(
                      children: [
                        Expanded(
                          child: VoiceRecordingBar(
                            controller: widget.voiceController,
                            pulse: widget.voicePulse,
                          ),
                        ),
                        const SizedBox(width: 4),
                        widget.recordingMicButton,
                      ],
                    )
                  : Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        ComposerIconButton(
                          icon: Icons.add_rounded,
                          enabled: widget.canCompose && !widget.uploading,
                          loading: widget.uploading,
                          onTap: widget.onAttach,
                        ),
                        Expanded(
                          child: TextField(
                            controller: widget.controller,
                            enabled: widget.canSend,
                            maxLines: 4,
                            minLines: 1,
                            textInputAction: TextInputAction.send,
                            style: GoogleFonts.dmSans(
                              fontSize: 16,
                              height: 1.4,
                              color: colors.ink,
                            ),
                            onTapOutside: (_) =>
                                FocusManager.instance.primaryFocus?.unfocus(),
                            decoration: InputDecoration(
                              hintText: widget.canSend
                                  ? widget.hintText
                                  : widget.closedHintText,
                              hintStyle: GoogleFonts.dmSans(
                                color: colors.muted.withValues(alpha: 0.7),
                              ),
                              border: InputBorder.none,
                              enabledBorder: InputBorder.none,
                              focusedBorder: InputBorder.none,
                              filled: false,
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 10,
                              ),
                            ),
                            onSubmitted: (_) => _handleSend(),
                          ),
                        ),
                        const SizedBox(width: 4),
                        if (hasText)
                          Material(
                            color: Colors.transparent,
                            child: InkWell(
                              onTap: widget.canCompose && !widget.sending
                                  ? _handleSend
                                  : null,
                              customBorder: const CircleBorder(),
                              child: Ink(
                                width: 44,
                                height: 44,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  gradient: LinearGradient(
                                    colors: widget.canCompose && !widget.sending
                                        ? [
                                            VelvetTokens.ember,
                                            VelvetTokens.emberDeep,
                                          ]
                                        : [
                                            colors.line,
                                            colors.parchmentDeep,
                                          ],
                                  ),
                                  boxShadow: widget.canCompose && !widget.sending
                                      ? VelvetTokens.emberHalo(strength: 0.55)
                                      : null,
                                ),
                                child: widget.sending
                                    ? const Padding(
                                        padding: EdgeInsets.all(12),
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          color: VelvetTokens.onPrimary,
                                        ),
                                      )
                                    : const Icon(
                                        Icons.arrow_upward_rounded,
                                        color: VelvetTokens.onPrimary,
                                        size: 22,
                                      ),
                              ),
                            ),
                          )
                        else
                          widget.micButton,
                      ],
                    ),
            ),
          ),
        ),
      ),
    );
  }
}

class ComposerIconButton extends StatelessWidget {
  const ComposerIconButton({
    super.key,
    required this.icon,
    required this.enabled,
    required this.onTap,
    this.loading = false,
  });

  final IconData icon;
  final bool enabled;
  final VoidCallback onTap;
  final bool loading;

  @override
  Widget build(BuildContext context) {
    final colors = context.velvet;
    return IconButton(
      onPressed: enabled
          ? () {
              HapticFeedback.selectionClick();
              onTap();
            }
          : null,
      icon: loading
          ? const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : Icon(icon, size: 24),
      color: enabled ? VelvetTheme.teal : colors.muted,
    );
  }
}

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:velvet_mobile/core/network/dio_client.dart';
import 'package:velvet_mobile/core/platform/velvet_file_picker.dart';
import 'package:velvet_mobile/core/theme/velvet_editorial_colors.dart';
import 'package:velvet_mobile/core/theme/velvet_theme.dart';
import 'package:velvet_mobile/core/theme/velvet_tokens.dart';
import 'package:velvet_mobile/core/widgets/chat_composer.dart';
import 'package:velvet_mobile/core/widgets/editorial_dialog.dart';
import 'package:velvet_mobile/core/widgets/velvet_feedback.dart';
import 'package:velvet_mobile/core/widgets/conversation_slab.dart';
import 'package:velvet_mobile/core/widgets/velvet_widgets.dart';
import 'package:velvet_mobile/features/auth/auth_controller.dart';
import 'package:velvet_mobile/features/social/chat_media_bubble.dart';
import 'package:velvet_mobile/features/social/social_api.dart';
import 'package:velvet_mobile/features/social/voice_note_sheet.dart';
import 'package:velvet_mobile/l10n/generated/app_localizations.dart';

final chatBookingProvider = FutureProvider.autoDispose
    .family<BookingItem?, String>((ref, connectionId) async {
      return ref.watch(bookingApiProvider).byConnection(connectionId);
    });

class ChatScreen extends ConsumerStatefulWidget {
  const ChatScreen({
    super.key,
    required this.connectionId,
    this.counterpartUserId,
    this.counterpartName,
    this.counterpartVerified = false,
    this.counterpartTrustScore,
  });

  final String connectionId;
  final String? counterpartUserId;
  final String? counterpartName;
  final bool counterpartVerified;
  final int? counterpartTrustScore;

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen>
    with SingleTickerProviderStateMixin {
  final _ctrl = TextEditingController();
  final _voice = VoiceNoteController();
  ChatThreadDetail? _detail;
  bool _loading = true;
  bool _uploading = false;
  bool _sending = false;
  String? _error;
  Timer? _poll;
  Timer? _typingDebounce;
  StreamSubscription<Map<String, dynamic>>? _sse;
  bool _peerTyping = false;
  late final AnimationController _voicePulse;

  static const _categories = [
    'HARASSMENT',
    'NO_SHOW',
    'UNSAFE',
    'POLICY',
    'OTHER',
  ];

  @override
  void initState() {
    super.initState();
    _voicePulse = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);
    _ctrl.addListener(_onComposerChanged);
    _voice.addListener(() {
      if (mounted) setState(() {});
    });
    _load(initial: true);
    _poll = Timer.periodic(const Duration(seconds: 8), (_) => _softPoll());
  }

  void _onComposerChanged() {
    if (mounted) setState(() {});
    _typingDebounce?.cancel();
    final typing = _ctrl.text.trim().isNotEmpty;
    _typingDebounce = Timer(const Duration(milliseconds: 350), () {
      ref
          .read(chatApiProvider)
          .setTyping(widget.connectionId, typing: typing)
          .catchError((_) {});
    });
  }

  @override
  void dispose() {
    _poll?.cancel();
    _typingDebounce?.cancel();
    _sse?.cancel();
    final api = ref.read(chatApiProvider);
    api.setTyping(widget.connectionId, typing: false).catchError((_) {});
    _ctrl.removeListener(_onComposerChanged);
    _ctrl.dispose();
    _voice.dispose();
    _voicePulse.dispose();
    super.dispose();
  }

  bool get _needsOpener => false;

  void _startSse() {
    _sse?.cancel();
    final after = _detail?.messages.isEmpty == false
        ? _detail!.messages.last.createdAt
        : null;
    _sse = ref
        .read(chatApiProvider)
        .eventStream(widget.connectionId, after: after)
        .listen(
          (event) {
            if (!mounted || _detail == null) return;
            final name = event['event'] as String? ?? '';
            final data = event['data'];
            if (name == 'typing' && data is Map) {
              final typing = data['peerTyping'] == true;
              if (typing != _peerTyping) {
                setState(() {
                  _peerTyping = typing;
                  _detail = _detail!.copyWith(peerTyping: typing);
                });
              }
              return;
            }
            if (name == 'message' && data is Map) {
              final msg = ChatMessage.fromJson(Map<String, dynamic>.from(data));
              final known = _detail!.messages.map((m) => m.id).toSet();
              if (known.contains(msg.id)) return;
              setState(() {
                _detail = _detail!.copyWith(
                  messages: [..._detail!.messages, msg],
                  peerTyping: false,
                );
                _peerTyping = false;
              });
              ref
                  .read(chatApiProvider)
                  .markRead(widget.connectionId)
                  .catchError((_) {});
            }
          },
          onError: (_) {
            // Soft-poll remains as fallback.
          },
          onDone: () {
            if (!mounted) return;
            Future.delayed(const Duration(seconds: 2), () {
              if (mounted) _startSse();
            });
          },
          cancelOnError: true,
        );
  }

  Future<void> _load({bool initial = false}) async {
    if (initial) {
      setState(() {
        _loading = true;
        _error = null;
      });
    }
    try {
      final detail = await ref
          .read(chatApiProvider)
          .getThread(widget.connectionId);
      if (!mounted) return;
      setState(() {
        _detail = detail;
        _peerTyping = detail.peerTyping;
      });
      _startSse();
    } catch (e) {
      if (!mounted) return;
      if (initial) setState(() => _error = apiErrorMessage(e));
    } finally {
      if (mounted && initial) setState(() => _loading = false);
    }
  }

  Future<void> _softPoll() async {
    if (!mounted || _detail == null) return;
    try {
      final after = _detail!.messages.isEmpty
          ? null
          : _detail!.messages.last.createdAt;
      final newer = await ref
          .read(chatApiProvider)
          .messagesAfter(widget.connectionId, after: after);
      if (!mounted || newer.isEmpty) return;
      final known = _detail!.messages.map((m) => m.id).toSet();
      final fresh = newer.where((m) => !known.contains(m.id)).toList();
      if (fresh.isEmpty) return;
      setState(() {
        _detail = _detail!.copyWith(messages: [..._detail!.messages, ...fresh]);
      });
      await ref.read(chatApiProvider).markRead(widget.connectionId);
    } catch (_) {}
  }

  Future<void> _send([String? preset]) async {
    final body = (preset ?? _ctrl.text).trim();
    if (body.isEmpty) return;
    if (_detail != null && !_detail!.canSend) {
      if (mounted) {
        await showVelvetErrorToast(
          context,
          message: AppLocalizations.of(context).chatWindowClosed,
        );
      }
      return;
    }
    HapticFeedback.lightImpact();
    setState(() => _sending = true);
    try {
      final msg = await ref
          .read(chatApiProvider)
          .send(widget.connectionId, body: body);
      _ctrl.clear();
      await ref
          .read(chatApiProvider)
          .setTyping(widget.connectionId, typing: false);
      if (!mounted || _detail == null) return;
      setState(() {
        _detail = _detail!.copyWith(messages: [..._detail!.messages, msg]);
      });
    } catch (e) {
      if (mounted) {
        showVelvetErrorToast(context, message: apiErrorMessage(e));
      }
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  Future<void> _attach() async {
    if (_needsOpener || !(_detail?.canSend ?? true)) {
      if (mounted) {
        await showVelvetErrorToast(
          context,
          message: _needsOpener
              ? AppLocalizations.of(context).openerRequired
              : AppLocalizations.of(context).chatWindowClosed,
        );
      }
      return;
    }
    final choice = await showEditorialActionSheet<String>(
      context: context,
      title: AppLocalizations.of(context).attachFile,
      options: [
        EditorialSheetOption(
          value: 'photo',
          label: AppLocalizations.of(context).attachPhoto,
          icon: Icons.photo_outlined,
        ),
        EditorialSheetOption(
          value: 'video',
          label: AppLocalizations.of(context).attachVideo,
          icon: Icons.videocam_outlined,
        ),
        EditorialSheetOption(
          value: 'audio',
          label: AppLocalizations.of(context).attachAudio,
          icon: Icons.audiotrack_outlined,
        ),
        EditorialSheetOption(
          value: 'file',
          label: AppLocalizations.of(context).attachFile,
          icon: Icons.attach_file,
        ),
      ],
    );
    if (choice == null || !mounted) return;

    String? path;
    String? name;
    switch (choice) {
      case 'photo':
        final shot = await ImagePicker().pickImage(
          source: ImageSource.gallery,
          imageQuality: 85,
          maxWidth: 1920,
        );
        path = shot?.path;
        name = shot?.name;
      case 'video':
        final vid = await ImagePicker().pickVideo(
          source: ImageSource.gallery,
          maxDuration: const Duration(minutes: 3),
        );
        path = vid?.path;
        name = vid?.name;
      case 'audio':
        final audio = await VelvetFilePicker.pick(
          mime: 'audio/*',
          mimes: [
            'audio/*',
            'audio/mpeg',
            'audio/mp4',
            'audio/aac',
            'audio/wav',
          ],
        );
        path = audio?.path;
        name = audio?.name;
      case 'file':
        final file = await VelvetFilePicker.pick(
          mime: '*/*',
          mimes: [
            'application/pdf',
            'application/msword',
            'application/vnd.openxmlformats-officedocument.wordprocessingml.document',
            'text/plain',
            'application/zip',
          ],
        );
        path = file?.path;
        name = file?.name;
    }
    if (path == null) return;
    await _uploadAndSendMedia(path, name);
  }

  void _voiceSnack(String message) {
    if (!mounted) return;
    showVelvetErrorToast(context, message: message);
  }

  bool get _canCompose =>
      !_uploading && !_sending && (_detail?.canSend ?? true);

  bool _containsAny(String text, List<String> words) {
    final lower = text.toLowerCase();
    return words.any(lower.contains);
  }

  List<_ChatQuickAction> _quickActions(
    AppLocalizations l10n,
    BookingItem? booking,
  ) {
    final draft = _ctrl.text.trim().toLowerCase();
    final last = _detail?.messages.isNotEmpty == true
        ? _detail!.messages.last.body.toLowerCase()
        : '';
    final mix = '$draft $last';
    final asksBooking = _containsAny(mix, [
      'book',
      'booking',
      'tonight',
      'tomorrow',
      'meet',
      'room',
      'hotel',
      'place',
      'rate',
      'price',
      'overnight',
      'session',
    ]);
    final actions = <_ChatQuickAction>[
      _ChatQuickAction(
        icon: Icons.send_outlined,
        label: l10n.quickSendRatePrompt,
        onTap: () => _send(l10n.quickRatePromptLine),
      ),
      _ChatQuickAction(
        icon: Icons.place_outlined,
        label: l10n.quickAskPlace,
        onTap: () => _send(l10n.quickPlacePromptLine),
      ),
    ];
    final needsPay = booking?.needsPayment == true;
    final needsConfirm = booking?.status == 'PROPOSED';
    final canBook = booking == null || needsPay || needsConfirm;
    if (canBook) {
      final focus = needsPay ? 'pay' : (needsConfirm ? 'confirm' : 'plan');
      actions.insert(
        0,
        _ChatQuickAction(
          icon: Icons.calendar_month_outlined,
          label: needsPay ? l10n.payBooking : l10n.quickBookNow,
          onTap: () =>
              context.push('/booking/${widget.connectionId}?focus=$focus'),
        ),
      );
    }
    if (booking != null) {
      actions.add(
        _ChatQuickAction(
          icon: Icons.receipt_long_outlined,
          label: l10n.quickSendBookingSummary,
          onTap: () => _send(_bookingSummaryLine(l10n, booking)),
        ),
      );
      if (booking.status == 'CHECKED_IN') {
        actions.add(
          _ChatQuickAction(
            icon: Icons.verified_user_outlined,
            label: l10n.quickSendCheckinLineLabel,
            onTap: () => _send(l10n.quickSendCheckinLine),
          ),
        );
      }
      if (booking.status == 'COMPLETED') {
        actions.add(
          _ChatQuickAction(
            icon: Icons.spa_outlined,
            label: l10n.quickSendAftercareLineLabel,
            onTap: () => _send(l10n.quickSendAftercareLine),
          ),
        );
      }
    }
    if (!asksBooking && actions.length > 2) {
      return actions.take(2).toList();
    }
    return actions;
  }

  String _bookingSummaryLine(AppLocalizations l10n, BookingItem booking) {
    final rate = booking.rateType == 'OVERNIGHT'
        ? l10n.rateTypeOvernight
        : l10n.rateTypeSession;
    final amount = booking.amountEtb == null
        ? ''
        : ' · ${l10n.bookingAmount(booking.amountEtb!)}';
    final pay = booking.needsPayment ? l10n.paymentPending : l10n.paymentPaid;
    return '${l10n.quickBookingSummaryLine} $rate$amount · $pay.';
  }

  String _bookingFlowLabel(AppLocalizations l10n, BookingItem booking) {
    if (booking.needsPayment) return l10n.flowNextPayTitle;
    if (booking.status == 'PROPOSED') return l10n.flowNextConfirmTitle;
    if (booking.status == 'CONFIRMED') return l10n.flowNextArriveTitle;
    if (booking.status == 'CHECKED_IN') return l10n.statusCheckedIn;
    if (booking.status == 'COMPLETED') return l10n.statusCompleted;
    return l10n.bookingStatus;
  }

  Future<void> _onVoiceLongPressStart() async {
    if (!_canCompose) {
      _voiceSnack(
        _needsOpener
            ? AppLocalizations.of(context).openerRequired
            : AppLocalizations.of(context).chatWindowClosed,
      );
      return;
    }
    await _voice.begin(enabled: true, onError: _voiceSnack);
  }

  Future<void> _onVoiceLongPressEnd({required bool send}) async {
    final note = await _voice.finish(send: send, onError: _voiceSnack);
    if (note == null || !mounted) return;
    await _uploadAndSendMedia(note.path, note.fileName);
  }

  Future<void> _uploadAndSendMedia(String path, String? name) async {
    setState(() => _uploading = true);
    try {
      final uploaded = await ref
          .read(chatApiProvider)
          .uploadChatMedia(path, filename: name);
      final caption = _ctrl.text.trim();
      final msg = await ref
          .read(chatApiProvider)
          .send(
            widget.connectionId,
            body: caption,
            mediaType: uploaded['mediaType'],
            mediaUrl: uploaded['url'],
            mediaName: uploaded['mediaName'],
            mediaMime: uploaded['mediaMime'],
          );
      _ctrl.clear();
      if (!mounted || _detail == null) return;
      setState(() {
        _detail = _detail!.copyWith(messages: [..._detail!.messages, msg]);
      });
    } catch (e) {
      if (mounted) {
        showVelvetErrorToast(context, message: apiErrorMessage(e));
      }
    } finally {
      if (mounted) setState(() => _uploading = false);
    }
  }

  Future<void> _report() async {
    final l10n = AppLocalizations.of(context);
    final detailsCtrl = TextEditingController();
    var category = _categories.first;
    final ok = await showEditorialDialog<bool>(
      context: context,
      title: l10n.reportUser,
      content: StatefulBuilder(
        builder: (context, setLocal) => Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            DropdownButtonFormField<String>(
              initialValue: category,
              decoration: InputDecoration(labelText: l10n.reportCategory),
              items: _categories
                  .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                  .toList(),
              onChanged: (v) {
                if (v != null) setLocal(() => category = v);
              },
            ),
            const SizedBox(height: 12),
            VelvetField(
              controller: detailsCtrl,
              hint: l10n.reportHint,
              maxLines: 3,
            ),
          ],
        ),
      ),
      actions: [
        EditorialDialogAction(
          label: l10n.declineRequest,
          onPressed: () => Navigator.pop(context, false),
        ),
        EditorialDialogAction(
          label: l10n.reportSubmit,
          primary: true,
          onPressed: () => Navigator.pop(context, true),
        ),
      ],
    );
    if (ok != true) return;
    final details = detailsCtrl.text.trim();
    if (details.isEmpty) return;
    try {
      await ref
          .read(safetyApiProvider)
          .report(
            category: category,
            details: details,
            connectionId: widget.connectionId,
            reportedUserId: widget.counterpartUserId,
          );
      if (mounted) {
        await showVelvetToast(
          context,
          message: l10n.reportSent,
          icon: Icons.flag_outlined,
        );
      }
    } catch (e) {
      if (mounted) {
        showVelvetErrorToast(context, message: apiErrorMessage(e));
      }
    }
  }

  Future<void> _block() async {
    final other = widget.counterpartUserId;
    if (other == null) return;
    final l10n = AppLocalizations.of(context);
    final ok = await showEditorialConfirm(
      context: context,
      title: l10n.blockUser,
      message: l10n.blockConfirm,
      confirmLabel: l10n.blockUser,
      cancelLabel: l10n.declineRequest,
      destructive: true,
    );
    if (ok != true) return;
    try {
      await ref.read(safetyApiProvider).block(blockedUserId: other);
      if (!mounted) return;
      await showVelvetToast(
        context,
        message: l10n.blockDone,
        icon: Icons.block_outlined,
      );
      if (!mounted) return;
      Navigator.of(context).maybePop();
    } catch (e) {
      if (mounted) {
        showVelvetErrorToast(context, message: apiErrorMessage(e));
      }
    }
  }

  Future<void> _showConversationActions() async {
    final l10n = AppLocalizations.of(context);
    final action = await showEditorialActionSheet<String>(
      context: context,
      title: l10n.chatTitle,
      options: [
        EditorialSheetOption(
          value: 'report',
          label: l10n.reportUser,
          icon: Icons.flag_outlined,
        ),
        if (widget.counterpartUserId != null)
          EditorialSheetOption(
            value: 'block',
            label: l10n.blockUser,
            icon: Icons.block_outlined,
            destructive: true,
          ),
      ],
    );
    if (action == 'report') {
      await _report();
    } else if (action == 'block') {
      await _block();
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final me = ref.watch(authControllerProvider).user?.id;
    final locale = Localizations.localeOf(context).languageCode;
    final colors = context.velvet;
    final booking = ref
        .watch(chatBookingProvider(widget.connectionId))
        .asData
        ?.value;
    final bookingFocus = booking?.needsPayment == true
        ? 'pay'
        : (booking?.status == 'PROPOSED' ? 'confirm' : 'plan');
    final headerBookLabel = booking?.needsPayment == true
        ? l10n.payBooking
        : (booking?.status == 'PROPOSED'
              ? l10n.confirmBooking
              : l10n.chatBookCta);
    final title = widget.counterpartName?.isNotEmpty == true
        ? widget.counterpartName!
        : l10n.chatTitle;
    final statusLine = _peerTyping
        ? l10n.typingIndicator
        : (_detail?.canSend == false
              ? (_detail!.windowReason == 'TOO_EARLY'
                    ? l10n.chatOpensSoon
                    : l10n.chatWindowClosed)
              : l10n.chatHint);

    return VelvetScaffold(
      mistIntensity: 0.35,
      safeArea: false,
      body: Column(
        children: [
          SafeArea(
            bottom: false,
            child: _ChatAppBar(
              title: title,
              statusLine: statusLine,
              verified: widget.counterpartVerified,
              trusted: (widget.counterpartTrustScore ?? 0) >= 80,
              bookLabel: headerBookLabel,
              onBack: () => Navigator.of(context).maybePop(),
              onBook: () => context.push(
                '/booking/${widget.connectionId}?focus=$bookingFocus',
              ),
              onMore: _showConversationActions,
            ),
          ),
          if (booking != null)
            _BookingStatusStrip(
              label: _bookingFlowLabel(l10n, booking),
              actionLabel: headerBookLabel,
              onAction: () => context.push(
                '/booking/${widget.connectionId}?focus=$bookingFocus',
              ),
              completed: booking.status == 'COMPLETED',
              onFeedback: booking.status == 'COMPLETED'
                  ? () => context.push(
                        '/booking/${widget.connectionId}?focus=feedback',
                      )
                  : null,
              feedbackLabel: l10n.meetingFeedbackTitle,
            ),
          if (_uploading)
            LinearProgressIndicator(
              minHeight: 2,
              color: VelvetTokens.ember,
              backgroundColor: colors.parchmentDeep,
            ),
          Expanded(
            child: _loading
                ? const VelvetContentLoading(count: 4)
                : _error != null
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Text(
                        _error!,
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: VelvetTheme.danger),
                      ),
                    ),
                  )
                : (_detail?.messages.isEmpty ?? true)
                ? _ChatEmptyBody(
                    hint: l10n.chatEmptyHint,
                    openers: _detail?.suggestedOpeners ?? const [],
                    locale: locale,
                    canSend: _detail?.canSend ?? false,
                    sendLabel: l10n.sendOpener,
                    onSendOpener: (text) => _send(text),
                    quickActions: (_detail?.canSend ?? false)
                        ? _quickActions(l10n, booking)
                        : const [],
                  )
                : ListView.builder(
                    reverse: true,
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                    itemCount:
                        (_detail?.messages.length ?? 0) + (_peerTyping ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (_peerTyping && index == 0) {
                        return Align(
                          alignment: Alignment.centerLeft,
                          child: Padding(
                            padding: const EdgeInsets.only(bottom: 10, left: 4),
                            child: VelvetTypingDots(label: l10n.typingIndicator),
                          ),
                        );
                      }
                      final msgCount = _detail?.messages.length ?? 0;
                      final msgIndex = _peerTyping ? index - 1 : index;
                      final m = _detail!.messages[msgCount - 1 - msgIndex];
                      final mine = m.senderId == me;
                      final prevMine = msgIndex + 1 < msgCount
                          ? _detail!.messages[msgCount - 1 - (msgIndex + 1)]
                                  .senderId ==
                              me
                          : null;
                      final clustered = prevMine == mine;

                      return Align(
                        alignment: mine
                            ? Alignment.centerRight
                            : Alignment.centerLeft,
                        child: Padding(
                          padding: EdgeInsets.only(bottom: clustered ? 4 : 10),
                          child: ConversationSlab(
                            mine: mine,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Align(
                                  alignment: Alignment.centerLeft,
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      if (m.hasMedia) ...[
                                        ChatMediaBubble(
                                          message: m,
                                          mine: mine,
                                        ),
                                        if (m.body.isNotEmpty)
                                          const SizedBox(height: 8),
                                      ],
                                      if (m.body.isNotEmpty) Text(m.body),
                                      if (m.moderationStatus == 'HELD')
                                        Padding(
                                          padding: const EdgeInsets.only(top: 4),
                                          child: Text(
                                            l10n.messagePendingReview,
                                            style: TextStyle(
                                              fontSize: 11,
                                              color: mine
                                                  ? VelvetTokens.onPrimary
                                                      .withValues(alpha: 0.65)
                                                  : colors.muted,
                                            ),
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                                if (mine && m.readByPeer)
                                  Padding(
                                    padding: const EdgeInsets.only(top: 4),
                                    child: Text(
                                      l10n.messageRead,
                                      style: TextStyle(
                                        fontSize: 10,
                                        color: VelvetTokens.onPrimary
                                            .withValues(alpha: 0.65),
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
          ),
          SafeArea(
            top: false,
            child: ChatComposerSlab(
              controller: _ctrl,
              canCompose: _canCompose,
              canSend: _detail?.canSend ?? true,
              uploading: _uploading,
              sending: _sending,
              hintText: l10n.chatMessageHint,
              closedHintText: l10n.chatWindowClosed,
              onSend: _send,
              onAttach: _attach,
              voiceController: _voice,
              voicePulse: _voicePulse,
              recordingMicButton: _HoldMicButton(
                active: true,
                enabled: true,
                willCancel: _voice.willCancel,
                onLongPressStart: _onVoiceLongPressStart,
                onLongPressMove: _voice.updateSlide,
                onLongPressEnd: () => _onVoiceLongPressEnd(send: true),
                onLongPressCancel: () => _onVoiceLongPressEnd(send: false),
              ),
              micButton: _HoldMicButton(
                active: false,
                enabled: _canCompose,
                willCancel: false,
                onLongPressStart: _onVoiceLongPressStart,
                onLongPressMove: _voice.updateSlide,
                onLongPressEnd: () => _onVoiceLongPressEnd(send: true),
                onLongPressCancel: () => _onVoiceLongPressEnd(send: false),
                onTapHint: () => _voiceSnack(l10n.holdVoiceNote),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ConversationAvatar extends StatelessWidget {
  const _ConversationAvatar({required this.name, required this.verified});

  final String name;
  final bool verified;

  @override
  Widget build(BuildContext context) {
    final initials = name
        .trim()
        .split(RegExp(r'\s+'))
        .where((part) => part.isNotEmpty)
        .take(2)
        .map((part) => part[0].toUpperCase())
        .join();
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          width: 40,
          height: 40,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: VelvetTokens.emberSoft,
            border: Border.all(
              color: VelvetTokens.ember.withValues(alpha: 0.45),
            ),
          ),
          child: Text(
            initials.isEmpty ? 'V' : initials,
            style: GoogleFonts.syne(
              color: VelvetTokens.ember,
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        if (verified)
          const Positioned(
            right: -2,
            bottom: -2,
            child: VelvetVerifiedBadge(compact: true, onDark: true),
          ),
      ],
    );
  }
}

class _ChatAppBar extends StatelessWidget {
  const _ChatAppBar({
    required this.title,
    required this.statusLine,
    required this.verified,
    required this.trusted,
    required this.bookLabel,
    required this.onBack,
    required this.onBook,
    required this.onMore,
  });

  final String title;
  final String statusLine;
  final bool verified;
  final bool trusted;
  final String bookLabel;
  final VoidCallback onBack;
  final VoidCallback onBook;
  final VoidCallback onMore;

  @override
  Widget build(BuildContext context) {
    final colors = context.velvet;
    return Container(
      padding: const EdgeInsets.fromLTRB(8, 6, 8, 10),
      decoration: BoxDecoration(
        color: colors.parchment.withValues(alpha: 0.92),
        border: Border(
          bottom: BorderSide(color: colors.line.withValues(alpha: 0.55)),
        ),
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: onBack,
            icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
          ),
          _ConversationAvatar(name: title, verified: verified),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.syne(
                          fontWeight: FontWeight.w700,
                          fontSize: 17,
                          letterSpacing: -0.35,
                        ),
                      ),
                    ),
                    if (trusted) ...[
                      const SizedBox(width: 4),
                      const VelvetTrustedBadge(compact: true),
                    ],
                  ],
                ),
                Text(
                  statusLine,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: colors.muted,
                        fontSize: 12,
                      ),
                ),
              ],
            ),
          ),
          TextButton(
            onPressed: onBook,
            child: Text(bookLabel),
          ),
          IconButton(
            onPressed: onMore,
            icon: const Icon(Icons.more_horiz_rounded),
          ),
        ],
      ),
    );
  }
}

class _BookingStatusStrip extends StatelessWidget {
  const _BookingStatusStrip({
    required this.label,
    required this.actionLabel,
    required this.onAction,
    required this.completed,
    this.onFeedback,
    this.feedbackLabel,
  });

  final String label;
  final String actionLabel;
  final VoidCallback onAction;
  final bool completed;
  final VoidCallback? onFeedback;
  final String? feedbackLabel;

  @override
  Widget build(BuildContext context) {
    final colors = context.velvet;
    return Material(
      color: colors.parchmentLift,
      child: InkWell(
        onTap: onAction,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(color: colors.line.withValues(alpha: 0.5)),
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 28,
                height: 28,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: VelvetTokens.ember.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  completed
                      ? Icons.check_circle_outline_rounded
                      : Icons.event_available_outlined,
                  size: 16,
                  color: VelvetTokens.ember,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: colors.ink,
                        fontWeight: FontWeight.w500,
                      ),
                ),
              ),
              if (completed && onFeedback != null) ...[
                TextButton(
                  onPressed: onFeedback,
                  style: TextButton.styleFrom(
                    visualDensity: VisualDensity.compact,
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                  ),
                  child: Text(feedbackLabel ?? ''),
                ),
              ],
              Text(
                actionLabel,
                style: GoogleFonts.dmSans(
                  color: VelvetTokens.ember,
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                ),
              ),
              const SizedBox(width: 2),
              Icon(
                Icons.chevron_right_rounded,
                size: 18,
                color: VelvetTokens.ember,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ChatEmptyBody extends StatelessWidget {
  const _ChatEmptyBody({
    required this.hint,
    required this.openers,
    required this.locale,
    required this.canSend,
    required this.sendLabel,
    required this.onSendOpener,
    required this.quickActions,
  });

  final String hint;
  final List<SuggestedOpener> openers;
  final String locale;
  final bool canSend;
  final String sendLabel;
  final ValueChanged<String> onSendOpener;
  final List<_ChatQuickAction> quickActions;

  @override
  Widget build(BuildContext context) {
    final colors = context.velvet;
    return ListView(
      padding: const EdgeInsets.fromLTRB(24, 32, 24, 24),
      children: [
        Icon(
          Icons.chat_bubble_outline_rounded,
          size: 40,
          color: colors.muted.withValues(alpha: 0.7),
        ),
        const SizedBox(height: 16),
        Text(
          hint,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: colors.muted,
                height: 1.45,
              ),
        ),
        if (openers.isNotEmpty && canSend) ...[
          const SizedBox(height: 28),
          Text(
            sendLabel,
            textAlign: TextAlign.center,
            style: GoogleFonts.syne(
              fontWeight: FontWeight.w700,
              fontSize: 14,
              color: colors.ink,
            ),
          ),
          const SizedBox(height: 12),
          ...openers.take(3).map((ice) {
            final text = locale == 'am' ? ice.textAm : ice.textEn;
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: OutlinedButton(
                onPressed: () => onSendOpener(text),
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size.fromHeight(48),
                  alignment: Alignment.centerLeft,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                ),
                child: Text(text, maxLines: 2, overflow: TextOverflow.ellipsis),
              ),
            );
          }),
        ],
        if (quickActions.isNotEmpty) ...[
          const SizedBox(height: 20),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            alignment: WrapAlignment.center,
            children: quickActions
                .map(
                  (a) => ActionChip(
                    avatar: Icon(a.icon, size: 16),
                    label: Text(a.label),
                    onPressed: () {
                      HapticFeedback.selectionClick();
                      a.onTap();
                    },
                  ),
                )
                .toList(),
          ),
        ],
      ],
    );
  }
}

class _HoldMicButton extends StatelessWidget {
  const _HoldMicButton({
    required this.active,
    required this.enabled,
    required this.willCancel,
    required this.onLongPressStart,
    required this.onLongPressMove,
    required this.onLongPressEnd,
    required this.onLongPressCancel,
    this.onTapHint,
  });

  final bool active;
  final bool enabled;
  final bool willCancel;
  final Future<void> Function() onLongPressStart;
  final void Function(double dxFromOrigin) onLongPressMove;
  final Future<void> Function() onLongPressEnd;
  final Future<void> Function() onLongPressCancel;
  final VoidCallback? onTapHint;

  @override
  Widget build(BuildContext context) {
    final color = willCancel ? VelvetTheme.danger : VelvetTheme.teal;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: enabled ? onTapHint : null,
      onLongPressStart: enabled ? (_) => unawaited(onLongPressStart()) : null,
      onLongPressMoveUpdate: enabled
          ? (d) => onLongPressMove(d.offsetFromOrigin.dx)
          : null,
      onLongPressEnd: enabled ? (_) => unawaited(onLongPressEnd()) : null,
      onLongPressCancel: enabled ? () => unawaited(onLongPressCancel()) : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 120),
        width: active ? 56 : 44,
        height: active ? 56 : 44,
        decoration: BoxDecoration(
          color: enabled ? color : VelvetTheme.line,
          shape: BoxShape.circle,
          boxShadow: active
              ? [
                  BoxShadow(
                    color: color.withValues(alpha: 0.35),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  ),
                ]
              : null,
        ),
        child: Icon(
          willCancel ? Icons.delete_outline_rounded : Icons.mic_rounded,
          color: VelvetTokens.onPrimary,
          size: active ? 26 : 22,
        ),
      ),
    );
  }
}

class _ChatQuickAction {
  const _ChatQuickAction({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
}

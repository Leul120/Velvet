import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:velvet_mobile/core/network/media_url.dart';
import 'package:velvet_mobile/core/theme/velvet_editorial_colors.dart';
import 'package:velvet_mobile/core/theme/velvet_tokens.dart';
import 'package:velvet_mobile/core/widgets/velvet_widgets.dart';

/// Soft radius helper — slight stagger by index, never harsh asymmetry.
BorderRadius editorialListRadius({required int index, bool featured = false}) {
  final r = featured ? VelvetTokens.radiusLg : VelvetTokens.radiusMd;
  final soft = featured ? 18.0 : 14.0;
  if (index.isEven) {
    return BorderRadius.only(
      topLeft: Radius.circular(r),
      topRight: Radius.circular(soft),
      bottomLeft: Radius.circular(soft),
      bottomRight: Radius.circular(r),
    );
  }
  return BorderRadius.only(
    topLeft: Radius.circular(soft),
    topRight: Radius.circular(r),
    bottomLeft: Radius.circular(r),
    bottomRight: Radius.circular(soft),
  );
}

/// Premium surface — soft ambient depth, hairline edge, warm fill.
class _VelvetCardSurface extends StatelessWidget {
  const _VelvetCardSurface({
    required this.child,
    this.onTap,
    this.margin,
    this.padding,
    this.highlighted = false,
    this.highlightColor,
  });

  final Widget child;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry? margin;
  final EdgeInsetsGeometry? padding;
  final bool highlighted;
  final Color? highlightColor;

  @override
  Widget build(BuildContext context) {
    final colors = context.velvet;
    final accent = highlightColor ?? VelvetTokens.ember;
    final radius = BorderRadius.circular(VelvetTokens.radiusMd);

    return Padding(
      padding: margin ?? const EdgeInsets.only(bottom: VelvetTokens.space12),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap == null
              ? null
              : () {
                  HapticFeedback.selectionClick();
                  onTap!();
                },
          borderRadius: radius,
          child: Ink(
            decoration: BoxDecoration(
              color: highlighted
                  ? Color.lerp(colors.parchmentLift, accent, 0.06)
                  : colors.parchmentLift,
              borderRadius: radius,
              border: Border.all(
                color: highlighted
                    ? accent.withValues(alpha: 0.28)
                    : colors.line.withValues(alpha: 0.55),
              ),
              boxShadow: [
                BoxShadow(
                  color: colors.ink.withValues(alpha: highlighted ? 0.1 : 0.06),
                  blurRadius: highlighted ? 24 : 18,
                  spreadRadius: -4,
                  offset: const Offset(0, 8),
                ),
                if (highlighted)
                  BoxShadow(
                    color: accent.withValues(alpha: 0.12),
                    blurRadius: 28,
                    spreadRadius: -8,
                    offset: const Offset(0, 12),
                  ),
              ],
            ),
            child: Padding(
              padding: padding ?? EdgeInsets.zero,
              child: child,
            ),
          ),
        ),
      ),
    );
  }
}

class _AvatarThumb extends StatelessWidget {
  const _AvatarThumb({required this.photoUrl});

  final String? photoUrl;

  @override
  Widget build(BuildContext context) {
    final colors = context.velvet;
    const size = 56.0;
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: colors.line.withValues(alpha: 0.7)),
      ),
      child: ClipOval(
        child: photoUrl != null
            ? Image.network(photoUrl!, fit: BoxFit.cover)
            : ColoredBox(
                color: colors.parchmentDeep,
                child: Icon(
                  Icons.person_outline,
                  color: colors.muted,
                  size: size * 0.4,
                ),
              ),
      ),
    );
  }
}

/// Conversations inbox row.
class EditorialInboxCard extends StatelessWidget {
  const EditorialInboxCard({
    super.key,
    required this.index,
    required this.name,
    required this.preview,
    required this.yourTurn,
    required this.unreadCount,
    required this.onTap,
    required this.onOpenChat,
    required this.onBook,
    required this.openChatLabel,
    required this.replyLabel,
    required this.turnLabel,
    this.photoUrl,
    this.verified = false,
  });

  final int index;
  final String name;
  final String preview;
  final bool yourTurn;
  final int unreadCount;
  final bool verified;
  final String? photoUrl;
  final VoidCallback onTap;
  final VoidCallback onOpenChat;
  final VoidCallback onBook;
  final String openChatLabel;
  final String replyLabel;
  final String turnLabel;

  @override
  Widget build(BuildContext context) {
    final colors = context.velvet;
    final active = yourTurn || unreadCount > 0;
    final _ = (index, onOpenChat, replyLabel);

    return _VelvetCardSurface(
      onTap: onTap,
      highlighted: active,
      padding: const EdgeInsets.all(12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(14),
            child: SizedBox(
              width: 64,
              height: 80,
              child: photoUrl != null
                  ? Image.network(photoUrl!, fit: BoxFit.cover)
                  : ColoredBox(
                      color: colors.parchmentDeep,
                      child: Icon(
                        Icons.person_outline,
                        color: colors.muted,
                        size: 28,
                      ),
                    ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.syne(
                          fontSize: 17,
                          fontWeight: FontWeight.w700,
                          letterSpacing: -0.3,
                          color: colors.ink,
                        ),
                      ),
                    ),
                    if (verified)
                      const Padding(
                        padding: EdgeInsets.only(left: 6),
                        child: VelvetVerifiedBadge(compact: true),
                      ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  preview,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.dmSans(
                    fontSize: 14,
                    height: 1.4,
                    color: active ? colors.ink : colors.muted,
                    fontWeight: unreadCount > 0
                        ? FontWeight.w600
                        : FontWeight.w400,
                  ),
                ),
                if (yourTurn) ...[
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: VelvetTokens.ember.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      turnLabel,
                      style: GoogleFonts.dmSans(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: VelvetTokens.ember,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: 8),
          Column(
            children: [
              if (unreadCount > 0)
                Container(
                  constraints: const BoxConstraints(minWidth: 22),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 7,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: VelvetTokens.ember,
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    unreadCount > 9 ? '9+' : '$unreadCount',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.dmSans(
                      color: VelvetTokens.onPrimary,
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              IconButton(
                tooltip: openChatLabel,
                onPressed: () {
                  HapticFeedback.selectionClick();
                  onBook();
                },
                icon: Icon(
                  Icons.calendar_month_outlined,
                  color: colors.muted,
                  size: 20,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

enum EditorialNoticeKind { match, booking, reminder, general }

double _requestCardAspect(int index) {
  const ratios = [0.52, 0.84, 0.62, 0.96, 0.56, 0.74, 0.90, 0.60];
  return ratios[index % ratios.length];
}

class EditorialNoticeCard extends StatelessWidget {
  const EditorialNoticeCard({
    super.key,
    required this.index,
    required this.subject,
    required this.body,
    required this.timestamp,
    required this.unread,
    required this.onTap,
    this.kind = EditorialNoticeKind.general,
  });

  final int index;
  final String subject;
  final String body;
  final String timestamp;
  final bool unread;
  final VoidCallback onTap;
  final EditorialNoticeKind kind;

  IconData get _icon => switch (kind) {
        EditorialNoticeKind.match => Icons.forum_outlined,
        EditorialNoticeKind.booking => Icons.event_available_outlined,
        EditorialNoticeKind.reminder => Icons.schedule_outlined,
        EditorialNoticeKind.general => Icons.notifications_none_outlined,
      };

  Color get _accent => switch (kind) {
        EditorialNoticeKind.match => VelvetTokens.ember,
        EditorialNoticeKind.booking => VelvetTokens.gold,
        EditorialNoticeKind.reminder => VelvetTokens.plumSoft,
        EditorialNoticeKind.general => VelvetTokens.sage,
      };

  @override
  Widget build(BuildContext context) {
    final colors = context.velvet;

    return _VelvetCardSurface(
      onTap: onTap,
      highlighted: unread,
      highlightColor: _accent,
      padding: const EdgeInsets.all(VelvetTokens.space16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 46,
            height: 46,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  _accent.withValues(alpha: 0.22),
                  _accent.withValues(alpha: 0.08),
                ],
              ),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: _accent.withValues(alpha: 0.22)),
            ),
            child: Icon(_icon, color: _accent, size: 22),
          ),
          const SizedBox(width: VelvetTokens.space12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  subject,
                  style: GoogleFonts.syne(
                    fontSize: 16,
                    fontWeight: unread ? FontWeight.w700 : FontWeight.w600,
                    letterSpacing: -0.3,
                    color: colors.ink,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  body,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.dmSans(
                    fontSize: 14,
                    height: 1.4,
                    color: colors.muted,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  timestamp,
                  style: GoogleFonts.dmSans(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: unread ? _accent : colors.muted,
                  ),
                ),
              ],
            ),
          ),
          if (unread)
            Container(
              width: 9,
              height: 9,
              margin: const EdgeInsets.only(top: 4),
              decoration: BoxDecoration(
                color: _accent,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(color: _accent.withValues(alpha: 0.4), blurRadius: 8),
                ],
              ),
            ),
        ],
      ),
    );
  }

  static EditorialNoticeKind kindFromRelatedType(String? type) {
    return switch (type) {
      'MATCH' => EditorialNoticeKind.match,
      'BOOKING' => EditorialNoticeKind.booking,
      'BOOKING_REMINDER' => EditorialNoticeKind.reminder,
      _ => EditorialNoticeKind.general,
    };
  }
}

class EditorialArchiveCard extends StatelessWidget {
  const EditorialArchiveCard({
    super.key,
    required this.index,
    required this.name,
    required this.status,
    required this.note,
    this.photoUrl,
  });

  final int index;
  final String name;
  final String status;
  final String? note;
  final String? photoUrl;

  @override
  Widget build(BuildContext context) {
    final colors = context.velvet;

    return _VelvetCardSurface(
      padding: const EdgeInsets.all(VelvetTokens.space16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _AvatarThumb(photoUrl: photoUrl),
          const SizedBox(width: VelvetTokens.space12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        name,
                        style: GoogleFonts.syne(
                          fontSize: 17,
                          fontWeight: FontWeight.w700,
                          letterSpacing: -0.35,
                        ),
                      ),
                    ),
                    StatusRibbon(status: status),
                  ],
                ),
                if (note != null && note!.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text(
                    note!,
                    style: GoogleFonts.dmSans(
                      fontSize: 13,
                      height: 1.45,
                      color: colors.muted,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class EditorialNavSlab extends StatelessWidget {
  const EditorialNavSlab({
    super.key,
    required this.title,
    required this.onTap,
    required this.index,
    this.subtitle,
    this.icon = Icons.chevron_right_rounded,
    this.accent = VelvetTokens.ember,
  });

  final String title;
  final String? subtitle;
  final IconData icon;
  final int index;
  final Color accent;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.velvet;

    return _VelvetCardSurface(
      onTap: onTap,
      margin: const EdgeInsets.only(bottom: VelvetTokens.space8),
      padding: const EdgeInsets.symmetric(
        horizontal: VelvetTokens.space16,
        vertical: VelvetTokens.space12,
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: accent.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(13),
            ),
            child: Icon(icon, size: 20, color: accent),
          ),
          const SizedBox(width: VelvetTokens.space12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.syne(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.25,
                    color: colors.ink,
                  ),
                ),
                if (subtitle != null)
                  Text(
                    subtitle!,
                    style: GoogleFonts.dmSans(
                      fontSize: 13,
                      color: colors.muted,
                    ),
                  ),
              ],
            ),
          ),
          Icon(Icons.chevron_right_rounded, size: 22, color: colors.muted),
        ],
      ),
    );
  }
}

class EditorialRecordSlab extends StatelessWidget {
  const EditorialRecordSlab({
    super.key,
    required this.index,
    required this.title,
    required this.subtitle,
    required this.leading,
    this.trailing,
    this.complete = false,
  });

  final int index;
  final String title;
  final String subtitle;
  final Widget leading;
  final Widget? trailing;
  final bool complete;

  @override
  Widget build(BuildContext context) {
    final colors = context.velvet;

    return _VelvetCardSurface(
      highlighted: complete,
      margin: const EdgeInsets.only(bottom: VelvetTokens.space8),
      padding: const EdgeInsets.symmetric(
        horizontal: VelvetTokens.space16,
        vertical: VelvetTokens.space12,
      ),
      child: Row(
        children: [
          leading,
          const SizedBox(width: VelvetTokens.space12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.syne(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.25,
                    color: colors.ink,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: GoogleFonts.dmSans(
                    fontSize: 13,
                    color: colors.muted,
                  ),
                ),
              ],
            ),
          ),
          if (trailing != null) trailing!,
        ],
      ),
    );
  }
}

class EditorialRequestCard extends StatelessWidget {
  const EditorialRequestCard({
    super.key,
    required this.index,
    required this.eyebrow,
    required this.name,
    required this.subtitle,
    required this.acceptLabel,
    required this.declineLabel,
    required this.onAccept,
    required this.onDecline,
    required this.onTap,
    this.age,
    this.photoUrls = const [],
    this.verified = false,
    this.loading = false,
    this.accent = VelvetTokens.ember,
  });

  final int index;
  final String eyebrow;
  final String name;
  final String subtitle;
  final String acceptLabel;
  final String declineLabel;
  final int? age;
  final List<String> photoUrls;
  final bool verified;
  final bool loading;
  final Color accent;
  final VoidCallback onAccept;
  final VoidCallback onDecline;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.velvet;
    final photo = photoUrls.isNotEmpty ? resolveMediaUrl(photoUrls.first) : null;
    final title = age != null ? '$name, $age' : name;
    final radius = BorderRadius.circular(VelvetTokens.radiusLg);

    return Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: radius,
          child: Ink(
            decoration: BoxDecoration(
              borderRadius: radius,
              boxShadow: VelvetTokens.depthLift(elevation: 0.7, tint: accent),
            ),
            child: ClipRRect(
              borderRadius: radius,
              child: AspectRatio(
                aspectRatio: _requestCardAspect(index),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    if (photo != null)
                      Image.network(photo, fit: BoxFit.cover)
                    else
                      ColoredBox(color: colors.parchmentDeep),
                    const DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Color(0x33000000),
                            Color(0x00000000),
                            Color(0xB3000000),
                          ],
                          stops: [0, 0.4, 1],
                        ),
                      ),
                    ),
                    Positioned(
                      left: 14,
                      top: 14,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: accent,
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Text(
                          eyebrow,
                          style: GoogleFonts.dmSans(
                            color: VelvetTokens.onPrimary,
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                    if (verified)
                      const Positioned(
                        top: 14,
                        right: 14,
                        child: VelvetVerifiedBadge(compact: true, onDark: true),
                      ),
                    Positioned(
                      left: 16,
                      right: 16,
                      bottom: 16,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.syne(
                              color: Colors.white,
                              fontSize: 26,
                              fontWeight: FontWeight.w700,
                              letterSpacing: -0.7,
                              shadows: const [
                                Shadow(color: Color(0x88000000), blurRadius: 12),
                              ],
                            ),
                          ),
                          if (subtitle.isNotEmpty) ...[
                            const SizedBox(height: 6),
                            Text(
                              subtitle,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.dmSans(
                                color: Colors.white.withValues(alpha: 0.85),
                                fontSize: 13,
                                height: 1.35,
                              ),
                            ),
                          ],
                          const SizedBox(height: 14),
                          Row(
                            children: [
                              Expanded(
                                child: Material(
                                  color: Colors.transparent,
                                  child: InkWell(
                                    onTap: loading ? null : onDecline,
                                    borderRadius: BorderRadius.circular(999),
                                    child: Ink(
                                      height: 44,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(999),
                                        color: Colors.white.withValues(alpha: 0.16),
                                        border: Border.all(
                                          color: Colors.white.withValues(alpha: 0.3),
                                        ),
                                      ),
                                      child: Center(
                                        child: Text(
                                          declineLabel,
                                          style: GoogleFonts.dmSans(
                                            color: Colors.white,
                                            fontWeight: FontWeight.w700,
                                            fontSize: 13,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                flex: 2,
                                child: Material(
                                  color: Colors.transparent,
                                  child: InkWell(
                                    onTap: loading ? null : onAccept,
                                    borderRadius: BorderRadius.circular(999),
                                    child: Ink(
                                      height: 44,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(999),
                                        color: accent,
                                        boxShadow: [
                                          BoxShadow(
                                            color: accent.withValues(alpha: 0.4),
                                            blurRadius: 16,
                                            offset: const Offset(0, 6),
                                          ),
                                        ],
                                      ),
                                      child: Center(
                                        child: loading
                                            ? const SizedBox(
                                                width: 18,
                                                height: 18,
                                                child: CircularProgressIndicator(
                                                  strokeWidth: 2,
                                                  color: VelvetTokens.onPrimary,
                                                ),
                                              )
                                            : Text(
                                                acceptLabel,
                                                style: GoogleFonts.dmSans(
                                                  color: VelvetTokens.onPrimary,
                                                  fontWeight: FontWeight.w700,
                                                  fontSize: 13,
                                                ),
                                              ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
    );
  }
}

class EditorialToggleRow extends StatelessWidget {
  const EditorialToggleRow({
    super.key,
    required this.title,
    required this.value,
    required this.onChanged,
    this.subtitle,
    this.index = 0,
    this.enabled = true,
  });

  final String title;
  final String? subtitle;
  final bool value;
  final ValueChanged<bool>? onChanged;
  final int index;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final colors = context.velvet;
    final active = enabled && onChanged != null;

    return _VelvetCardSurface(
      onTap: active ? () => onChanged!(!value) : null,
      highlighted: value,
      margin: const EdgeInsets.only(bottom: VelvetTokens.space8),
      padding: const EdgeInsets.symmetric(
        horizontal: VelvetTokens.space16,
        vertical: VelvetTokens.space4,
      ),
      child: SwitchListTile(
        contentPadding: EdgeInsets.zero,
        title: Text(
          title,
          style: GoogleFonts.syne(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: active ? colors.ink : colors.muted,
          ),
        ),
        subtitle: subtitle == null
            ? null
            : Text(
                subtitle!,
                style: GoogleFonts.dmSans(
                  fontSize: 13,
                  color: colors.muted,
                ),
              ),
        value: value,
        onChanged: active ? onChanged : null,
        activeThumbColor: VelvetTokens.ember,
      ),
    );
  }
}

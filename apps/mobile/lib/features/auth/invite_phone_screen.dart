import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:velvet_mobile/core/config/api_config.dart';
import 'package:velvet_mobile/core/network/dio_client.dart';
import 'package:velvet_mobile/core/theme/velvet_editorial_colors.dart';
import 'package:velvet_mobile/core/theme/velvet_theme.dart';
import 'package:velvet_mobile/core/theme/velvet_tokens.dart';
import 'package:velvet_mobile/core/widgets/velvet_widgets.dart';
import 'package:velvet_mobile/features/auth/auth_controller.dart';
import 'package:velvet_mobile/features/auth/auth_models.dart';
import 'package:velvet_mobile/l10n/generated/app_localizations.dart';

class InvitePhoneScreen extends ConsumerStatefulWidget {
  const InvitePhoneScreen({super.key});

  @override
  ConsumerState<InvitePhoneScreen> createState() => _InvitePhoneScreenState();
}

class _InvitePhoneScreenState extends ConsumerState<InvitePhoneScreen> {
  final _inviteCtrl = TextEditingController(text: 'VELVET-SEED');
  final _phoneCtrl = TextEditingController(text: '+2519');
  bool _loading = false;
  bool _acceptedLegal = false;
  String? _error;
  LegalCurrent? _legal;

  @override
  void initState() {
    super.initState();
    _loadLegal();
  }

  Future<void> _loadLegal() async {
    try {
      final legal = await ref.read(authControllerProvider).api.legalCurrent();
      if (mounted) setState(() => _legal = legal);
    } catch (_) {
      if (mounted) {
        setState(
          () => _legal = LegalCurrent(
            documentSetVersion: 'v1-2026-08',
            accepted: false,
            termsPath: '/legal/terms-en.html',
            privacyPath: '/legal/privacy-en.html',
            communityPath: '/legal/community-en.html',
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _inviteCtrl.dispose();
    _phoneCtrl.dispose();
    super.dispose();
  }

  Future<void> _open(String path) async {
    final uri = Uri.parse('${ApiConfig.baseUrl}$path');
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  Future<void> _submit() async {
    if (!_acceptedLegal) {
      setState(() => _error = AppLocalizations.of(context).legalMustAccept);
      return;
    }
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final phone = _phoneCtrl.text.trim();
      final invite = _inviteCtrl.text.trim();
      final result = await ref
          .read(authControllerProvider)
          .requestOtp(phone: phone, inviteCode: invite);
      if (!mounted) return;
      final version = _legal?.documentSetVersion ?? 'v1-2026-08';
      final q = {
        'phone': phone,
        'invite': invite,
        'legal': version,
        if (result.devOtp != null) 'devOtp': result.devOtp!,
      };
      final query = q.entries
          .map((e) => '${e.key}=${Uri.encodeComponent(e.value)}')
          .join('&');
      context.go('/auth/otp?$query');
    } catch (e) {
      setState(() => _error = apiErrorMessage(e));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colors = context.velvet;
    final locale = Localizations.localeOf(context).languageCode;
    final terms = locale == 'am'
        ? '/legal/terms-am.html'
        : (_legal?.termsPath ?? '/legal/terms-en.html');
    final privacy = locale == 'am'
        ? '/legal/privacy-am.html'
        : (_legal?.privacyPath ?? '/legal/privacy-en.html');
    final community = locale == 'am'
        ? '/legal/community-am.html'
        : (_legal?.communityPath ?? '/legal/community-en.html');
    final linkStyle = GoogleFonts.dmSans(
      color: VelvetTokens.ember,
      decoration: TextDecoration.underline,
      decorationColor: VelvetTokens.ember,
      fontWeight: FontWeight.w600,
    );

    return VelvetAuthScaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          final minHeight = constraints.hasBoundedHeight
              ? (constraints.maxHeight - 24).clamp(0.0, double.infinity)
              : 0.0;
          return SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: minHeight),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 20),
                  const VelvetWordmark(size: 42, breathe: true)
                      .animate()
                      .fadeIn(duration: 420.ms)
                      .slideY(begin: 0.06, end: 0),
                  const SizedBox(height: 12),
                  Text(
                    l10n.tagline,
                    style: GoogleFonts.dmSans(
                      color: colors.muted,
                      fontSize: 16,
                      height: 1.45,
                    ),
                  ).animate().fadeIn(delay: 60.ms, duration: 400.ms),
                  const SizedBox(height: 36),
                  Container(
                    padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
                    decoration: BoxDecoration(
                      color: colors.parchmentLift,
                      borderRadius: BorderRadius.circular(VelvetTokens.radiusLg),
                      border: Border.all(
                        color: colors.line.withValues(alpha: 0.7),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.35),
                          blurRadius: 28,
                          offset: const Offset(0, 12),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          l10n.continueLabel,
                          style: GoogleFonts.syne(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            letterSpacing: -0.4,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          l10n.phoneHint,
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: colors.muted,
                              ),
                        ),
                        const SizedBox(height: 20),
                        VelvetField(
                          controller: _inviteCtrl,
                          label: l10n.inviteCode,
                          textCapitalization: TextCapitalization.characters,
                          prefixIcon: const Icon(Icons.confirmation_number_outlined),
                          textInputAction: TextInputAction.next,
                        ),
                        const SizedBox(height: 14),
                        VelvetField(
                          controller: _phoneCtrl,
                          label: l10n.phoneNumber,
                          hint: l10n.phoneHint,
                          keyboardType: TextInputType.phone,
                          prefixIcon: const Icon(Icons.phone_outlined),
                          autofillHints: const [AutofillHints.telephoneNumber],
                          textInputAction: TextInputAction.done,
                          onSubmitted: (_) => _loading ? null : _submit(),
                        ),
                        const SizedBox(height: 18),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(
                              width: 24,
                              height: 24,
                              child: Checkbox(
                                value: _acceptedLegal,
                                onChanged: (v) =>
                                    setState(() => _acceptedLegal = v ?? false),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text.rich(
                                TextSpan(
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodySmall
                                      ?.copyWith(height: 1.45, color: colors.muted),
                                  children: [
                                    TextSpan(text: '${l10n.legalAcceptPrefix} '),
                                    TextSpan(
                                      text: l10n.termsOfService,
                                      style: linkStyle,
                                      recognizer: TapGestureRecognizer()
                                        ..onTap = () => _open(terms),
                                    ),
                                    const TextSpan(text: ', '),
                                    TextSpan(
                                      text: l10n.privacyPolicy,
                                      style: linkStyle,
                                      recognizer: TapGestureRecognizer()
                                        ..onTap = () => _open(privacy),
                                    ),
                                    TextSpan(text: ', ${l10n.legalAnd} '),
                                    TextSpan(
                                      text: l10n.communityGuidelines,
                                      style: linkStyle,
                                      recognizer: TapGestureRecognizer()
                                        ..onTap = () => _open(community),
                                    ),
                                    TextSpan(
                                      text: '. ${l10n.legalMarketplaceNotice}',
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                        if (_error != null) ...[
                          const SizedBox(height: 14),
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: VelvetTheme.danger.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: VelvetTheme.danger.withValues(alpha: 0.35),
                              ),
                            ),
                            child: Text(
                              _error!,
                              style: const TextStyle(
                                color: VelvetTheme.danger,
                                height: 1.35,
                              ),
                            ),
                          ),
                        ],
                        const SizedBox(height: 22),
                        FilledButton(
                          onPressed: _loading ? null : _submit,
                          style: FilledButton.styleFrom(
                            minimumSize: const Size.fromHeight(54),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(999),
                            ),
                          ),
                          child: _loading
                              ? const SizedBox(
                                  width: 22,
                                  height: 22,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: VelvetTokens.onPrimary,
                                  ),
                                )
                              : Text(l10n.continueLabel),
                        ),
                      ],
                    ),
                  )
                      .animate()
                      .fadeIn(delay: 100.ms, duration: 420.ms)
                      .slideY(begin: 0.05, end: 0),
                  const SizedBox(height: 20),
                  TextButton(
                    onPressed: () => context.push('/waitlist'),
                    child: Text(l10n.waitlistCta),
                  ),
                  TextButton.icon(
                    onPressed: () async {
                      final code = _inviteCtrl.text.trim();
                      final text = code.isEmpty
                          ? l10n.shareInviteWhatsAppGeneric
                          : l10n.shareInviteWhatsAppWithCode(code);
                      final uri = Uri.parse(
                        'https://wa.me/?text=${Uri.encodeComponent(text)}',
                      );
                      await launchUrl(
                        uri,
                        mode: LaunchMode.externalApplication,
                      );
                    },
                    icon: const Icon(Icons.chat_outlined, size: 18),
                    label: Text(l10n.shareInviteWhatsApp),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

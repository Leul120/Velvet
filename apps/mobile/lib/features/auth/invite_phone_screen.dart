import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:velvet_mobile/core/config/api_config.dart';
import 'package:velvet_mobile/core/network/dio_client.dart';
import 'package:velvet_mobile/core/theme/velvet_theme.dart';
import 'package:velvet_mobile/core/widgets/kinetic_text.dart';
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
    final linkStyle = GoogleFonts.inter(
      color: VelvetTheme.tealDeep,
      decoration: TextDecoration.underline,
      decorationColor: VelvetTheme.tealDeep,
      fontWeight: FontWeight.w500,
    );

    return VelvetAuthScaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          final minHeight = constraints.hasBoundedHeight
              ? (constraints.maxHeight - 32).clamp(0.0, double.infinity)
              : 0.0;
          return SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(22, 28, 22, 28),
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: minHeight),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 28),
                  KineticEyebrow(label: 'Ethiopia', icon: Icons.auto_awesome_outlined),
                  const SizedBox(height: VelvetTokens.space8),
                  const VelvetWordmark(size: 48, breathe: true)
                      .animate()
                      .fadeIn(duration: 500.ms)
                      .slideY(begin: 0.08, end: 0, curve: Curves.easeOutCubic),
                  const SizedBox(height: 14),
                  Text(
                    l10n.tagline,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: VelvetTheme.champagne,
                      height: 1.45,
                      fontWeight: FontWeight.w400,
                      fontStyle: FontStyle.italic,
                    ),
                  ).animate().fadeIn(delay: 80.ms, duration: 450.ms),
                  const SizedBox(height: 28),
                  GlassPanel(
                        padding: const EdgeInsets.fromLTRB(20, 22, 20, 22),
                        fill: Colors.white.withValues(alpha: 0.07),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            VelvetField(
                              controller: _inviteCtrl,
                              label: l10n.inviteCode,
                              textCapitalization: TextCapitalization.characters,
                              prefixIcon: const Icon(
                                Icons.confirmation_number_outlined,
                              ),
                              textInputAction: TextInputAction.next,
                            ),
                            const SizedBox(height: 14),
                            VelvetField(
                              controller: _phoneCtrl,
                              label: l10n.phoneNumber,
                              hint: l10n.phoneHint,
                              keyboardType: TextInputType.phone,
                              prefixIcon: const Icon(Icons.phone_outlined),
                              autofillHints: const [
                                AutofillHints.telephoneNumber,
                              ],
                              textInputAction: TextInputAction.done,
                              onSubmitted: (_) => _loading ? null : _submit(),
                            ),
                            const SizedBox(height: 18),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                SizedBox(
                                  width: 28,
                                  height: 28,
                                  child: Checkbox(
                                    value: _acceptedLegal,
                                    onChanged: (v) => setState(
                                      () => _acceptedLegal = v ?? false,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Text.rich(
                                    TextSpan(
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodySmall
                                          ?.copyWith(height: 1.45),
                                      children: [
                                        TextSpan(
                                          text: '${l10n.legalAcceptPrefix} ',
                                        ),
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
                                          text:
                                              '. ${l10n.legalMarketplaceNotice}',
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            if (_error != null) ...[
                              const SizedBox(height: 14),
                              Text(
                                _error!,
                                style: const TextStyle(
                                  color: VelvetTheme.danger,
                                  height: 1.35,
                                ),
                              ),
                            ],
                            const SizedBox(height: 22),
                            VelvetButton(
                              label: l10n.continueLabel,
                              loading: _loading,
                              onPressed: _loading ? null : _submit,
                            ),
                          ],
                        ),
                      )
                      .animate()
                      .fadeIn(delay: 120.ms, duration: 480.ms)
                      .slideY(begin: 0.06, end: 0),
                  const SizedBox(height: 14),
                  Center(
                    child: TextButton(
                      onPressed: () => context.push('/waitlist'),
                      child: Text(l10n.waitlistCta),
                    ),
                  ),
                  Center(
                    child: TextButton.icon(
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
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:velvet_mobile/core/network/dio_client.dart';
import 'package:velvet_mobile/core/theme/velvet_theme.dart';
import 'package:velvet_mobile/core/theme/velvet_editorial_colors.dart';
import 'package:velvet_mobile/core/theme/velvet_tokens.dart';
import 'package:velvet_mobile/core/widgets/kinetic_text.dart';
import 'package:velvet_mobile/core/widgets/velvet_widgets.dart';
import 'package:velvet_mobile/l10n/generated/app_localizations.dart';

class WaitlistScreen extends ConsumerStatefulWidget {
  const WaitlistScreen({super.key});

  @override
  ConsumerState<WaitlistScreen> createState() => _WaitlistScreenState();
}

class _WaitlistScreenState extends ConsumerState<WaitlistScreen> {
  final _phoneCtrl = TextEditingController(text: '+2519');
  final _nameCtrl = TextEditingController();
  final _cityCtrl = TextEditingController(text: 'Addis Ababa');
  final _noteCtrl = TextEditingController();
  bool _loading = false;
  bool _submitted = false;
  String? _error;
  String? _status;
  String? _inviteCode;
  int _friendsApproved = 0;

  @override
  void dispose() {
    _phoneCtrl.dispose();
    _nameCtrl.dispose();
    _cityCtrl.dispose();
    _noteCtrl.dispose();
    super.dispose();
  }

  Dio get _publicDio =>
      Dio(BaseOptions(baseUrl: ref.read(dioProvider).options.baseUrl));

  Future<void> _submit() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final res = await _publicDio.post(
        '/v1/waitlist',
        data: {
          'phoneE164': _phoneCtrl.text.trim(),
          'displayName': _nameCtrl.text.trim().isEmpty
              ? null
              : _nameCtrl.text.trim(),
          'city': _cityCtrl.text.trim().isEmpty
              ? 'Addis Ababa'
              : _cityCtrl.text.trim(),
          'note': _noteCtrl.text.trim().isEmpty ? null : _noteCtrl.text.trim(),
        },
      );
      final data = res.data as Map<String, dynamic>;
      if (mounted) {
        setState(() {
          _submitted = true;
          _status = data['status']?.toString() ?? 'PENDING';
          _inviteCode = data['inviteCode']?.toString();
          _friendsApproved = (data['friendsApproved'] as num?)?.toInt() ?? 0;
        });
      }
    } catch (e) {
      setState(() => _error = apiErrorMessage(e));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _checkStatus() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final res = await _publicDio.get(
        '/v1/waitlist/status',
        queryParameters: {'phone': _phoneCtrl.text.trim()},
      );
      final data = res.data as Map<String, dynamic>;
      if (mounted) {
        setState(() {
          _submitted = true;
          _status = data['status']?.toString();
          _inviteCode = data['inviteCode']?.toString();
          _friendsApproved = (data['friendsApproved'] as num?)?.toInt() ?? 0;
        });
      }
    } catch (e) {
      setState(() => _error = apiErrorMessage(e));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _shareWhatsApp() async {
    final l10n = AppLocalizations.of(context);
    final code = _inviteCode;
    final text = code == null || code.isEmpty
        ? l10n.shareWaitlistWhatsAppGeneric
        : l10n.shareWaitlistWhatsAppWithCode(code);
    final uri = Uri.parse('https://wa.me/?text=${Uri.encodeComponent(text)}');
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return VelvetAuthScaffold(
      body: LayoutBuilder(
        builder: (context, constraints) => SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 12, 24, 48),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: constraints.maxHeight - 60,
            ),
            child: IntrinsicHeight(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: VelvetIconChip(
                      icon: Icons.arrow_back_ios_new_rounded,
                      onTap: () => Navigator.of(context).maybePop(),
                    ),
                  ),
                  const SizedBox(height: VelvetTokens.space16),
                  KineticEyebrow(
                    label: l10n.waitlistTitle,
                    icon: Icons.hourglass_top_outlined,
                  ),
                  const SizedBox(height: VelvetTokens.space8),
                  KineticText(
                    text: l10n.waitlistTitle,
                    style: GoogleFonts.syne(
                      fontSize: VelvetTokens.displayMedium,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -1.2,
                      height: 0.95,
                      color: context.velvet.ink,
                    ),
                  ),
                  const SizedBox(height: VelvetTokens.space24),
                  GlassPanel(
                    radius: VelvetTheme.radiusLg,
                    padding: const EdgeInsets.all(28),
                    child: _submitted
                              ? Column(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    const Icon(
                                      Icons.check_circle_outline,
                                      size: 64,
                                      color: VelvetTheme.teal,
                                    ),
                                    const SizedBox(height: 16),
                                    Text(
                                      l10n.waitlistThanks,
                                      textAlign: TextAlign.center,
                                      style: Theme.of(
                                        context,
                                      ).textTheme.headlineSmall,
                                    ).animate().fadeIn().slideY(
                                      begin: 0.1,
                                      end: 0,
                                    ),
                                    const SizedBox(height: 12),
                                    Text(
                                      _status == 'APPROVED'
                                          ? l10n.waitlistStatusApproved
                                          : l10n.waitlistStatusPending,
                                      textAlign: TextAlign.center,
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyLarge
                                          ?.copyWith(color: context.velvet.muted),
                                    ),
                                    if (_inviteCode != null &&
                                        _inviteCode!.isNotEmpty) ...[
                                      const SizedBox(height: 16),
                                      SelectableText(
                                        _inviteCode!,
                                        style: GoogleFonts.inter(
                                          fontSize: 32,
                                          fontWeight: FontWeight.w700,
                                          color: VelvetTheme.teal,
                                        ),
                                      ),
                                    ],
                                    const SizedBox(height: 16),
                                    Text(
                                      l10n.waitlistFriendsApproved(
                                        _friendsApproved,
                                      ),
                                      textAlign: TextAlign.center,
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyMedium
                                          ?.copyWith(
                                            color: VelvetTheme.tealDeep,
                                          ),
                                    ),
                                    const SizedBox(height: 32),
                                    VelvetButton(
                                      label: l10n.shareInviteWhatsApp,
                                      icon: Icons.chat_outlined,
                                      onPressed: _shareWhatsApp,
                                    ),
                                    const SizedBox(height: 10),
                                    VelvetButton(
                                      label: l10n.waitlistCheckStatus,
                                      variant: VelvetButtonVariant.ghost,
                                      loading: _loading,
                                      onPressed: _loading ? null : _checkStatus,
                                    ),
                                  ],
                                )
                              : Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      l10n.waitlistHint,
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyMedium
                                          ?.copyWith(
                                            color: context.velvet.muted,
                                            height: 1.4,
                                          ),
                                    ),
                                    const SizedBox(height: 16),
                                    Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            VelvetField(
                                              controller: _phoneCtrl,
                                              label: l10n.phoneNumber,
                                              hint: l10n.phoneHint,
                                              keyboardType: TextInputType.phone,
                                              prefixIcon: const Icon(
                                                Icons.phone_outlined,
                                              ),
                                              autofillHints: const [
                                                AutofillHints.telephoneNumber,
                                              ],
                                              textInputAction:
                                                  TextInputAction.next,
                                            ),
                                            const SizedBox(height: 16),
                                            VelvetField(
                                              controller: _nameCtrl,
                                              label: l10n.displayName,
                                              prefixIcon: const Icon(
                                                Icons.person_outline,
                                              ),
                                              textCapitalization:
                                                  TextCapitalization.words,
                                              autofillHints: const [
                                                AutofillHints.name,
                                              ],
                                              textInputAction:
                                                  TextInputAction.next,
                                            ),
                                            const SizedBox(height: 16),
                                            VelvetField(
                                              controller: _cityCtrl,
                                              label: l10n.waitlistCity,
                                              prefixIcon: const Icon(
                                                Icons.location_city_outlined,
                                              ),
                                              textCapitalization:
                                                  TextCapitalization.words,
                                              autofillHints: const [
                                                AutofillHints.addressCity,
                                              ],
                                              textInputAction:
                                                  TextInputAction.next,
                                            ),
                                            const SizedBox(height: 16),
                                            VelvetField(
                                              controller: _noteCtrl,
                                              label: l10n.waitlistNote,
                                              prefixIcon: const Icon(
                                                Icons.edit_note_outlined,
                                              ),
                                              maxLines: 3,
                                              textInputAction:
                                                  TextInputAction.done,
                                              onSubmitted: (_) =>
                                                  _loading ? null : _submit(),
                                            ),
                                            if (_error != null) ...[
                                              const SizedBox(height: 16),
                                              Text(
                                                _error!,
                                                style: const TextStyle(
                                                  color: VelvetTheme.danger,
                                                ),
                                              ),
                                            ],
                                          ],
                                        )
                                        .animate()
                                        .fadeIn(duration: 400.ms)
                                        .slideY(begin: 0.05, end: 0),
                                    const SizedBox(height: 24),
                                    VelvetButton(
                                      label: l10n.waitlistSubmit,
                                      loading: _loading,
                                      onPressed: _loading ? null : _submit,
                                    ),
                                    const SizedBox(height: 12),
                                    VelvetButton(
                                      label: l10n.waitlistCheckStatus,
                                      variant: VelvetButtonVariant.secondary,
                                      loading: _loading,
                                      onPressed: _loading ? null : _checkStatus,
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

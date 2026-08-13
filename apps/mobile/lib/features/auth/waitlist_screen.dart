import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:velvet_mobile/core/network/dio_client.dart';
import 'package:velvet_mobile/core/theme/velvet_editorial_colors.dart';
import 'package:velvet_mobile/core/theme/velvet_theme.dart';
import 'package:velvet_mobile/core/theme/velvet_tokens.dart';
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
          'displayName':
              _nameCtrl.text.trim().isEmpty ? null : _nameCtrl.text.trim(),
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
    final colors = context.velvet;

    return VelvetAuthScaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          final minHeight = constraints.hasBoundedHeight
              ? (constraints.maxHeight - 24).clamp(0.0, double.infinity)
              : 0.0;
          return SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(24, 8, 24, 32),
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: minHeight),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: IconButton(
                      onPressed: () => Navigator.of(context).maybePop(),
                      icon: const Icon(
                        Icons.arrow_back_ios_new_rounded,
                        size: 18,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    l10n.waitlistTitle,
                    style: GoogleFonts.syne(
                      fontSize: 34,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -1.0,
                      height: 0.98,
                      color: colors.ink,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    l10n.waitlistHint,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: colors.muted,
                          height: 1.45,
                        ),
                  ),
                  const SizedBox(height: 28),
                  Container(
                    padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
                    decoration: BoxDecoration(
                      color: colors.parchmentLift,
                      borderRadius:
                          BorderRadius.circular(VelvetTokens.radiusLg),
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
                    child: _submitted
                        ? Column(
                            children: [
                              Container(
                                width: 64,
                                height: 64,
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: VelvetTokens.ember
                                      .withValues(alpha: 0.14),
                                  border: Border.all(
                                    color: VelvetTokens.ember
                                        .withValues(alpha: 0.3),
                                  ),
                                ),
                                child: const Icon(
                                  Icons.check_rounded,
                                  size: 30,
                                  color: VelvetTokens.ember,
                                ),
                              ),
                              const SizedBox(height: 18),
                              Text(
                                l10n.waitlistThanks,
                                textAlign: TextAlign.center,
                                style: GoogleFonts.syne(
                                  fontSize: 22,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: -0.4,
                                ),
                              ),
                              const SizedBox(height: 10),
                              Text(
                                _status == 'APPROVED'
                                    ? l10n.waitlistStatusApproved
                                    : l10n.waitlistStatusPending,
                                textAlign: TextAlign.center,
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyLarge
                                    ?.copyWith(
                                      color: colors.muted,
                                      height: 1.4,
                                    ),
                              ),
                              if (_inviteCode != null &&
                                  _inviteCode!.isNotEmpty) ...[
                                const SizedBox(height: 18),
                                SelectableText(
                                  _inviteCode!,
                                  style: GoogleFonts.syne(
                                    fontSize: 28,
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: -0.6,
                                    color: VelvetTokens.ember,
                                  ),
                                ),
                              ],
                              const SizedBox(height: 14),
                              Text(
                                l10n.waitlistFriendsApproved(_friendsApproved),
                                textAlign: TextAlign.center,
                                style: GoogleFonts.dmSans(
                                  color: VelvetTokens.emberDeep,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 28),
                              FilledButton.icon(
                                onPressed: _shareWhatsApp,
                                style: FilledButton.styleFrom(
                                  minimumSize: const Size.fromHeight(54),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(999),
                                  ),
                                ),
                                icon: const Icon(Icons.chat_outlined, size: 18),
                                label: Text(l10n.shareInviteWhatsApp),
                              ),
                              const SizedBox(height: 10),
                              OutlinedButton(
                                onPressed: _loading ? null : _checkStatus,
                                style: OutlinedButton.styleFrom(
                                  minimumSize: const Size.fromHeight(48),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(999),
                                  ),
                                ),
                                child: _loading
                                    ? const SizedBox(
                                        width: 20,
                                        height: 20,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                        ),
                                      )
                                    : Text(l10n.waitlistCheckStatus),
                              ),
                            ],
                          )
                        : Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              VelvetField(
                                controller: _phoneCtrl,
                                label: l10n.phoneNumber,
                                hint: l10n.phoneHint,
                                keyboardType: TextInputType.phone,
                                prefixIcon: const Icon(Icons.phone_outlined),
                                autofillHints: const [
                                  AutofillHints.telephoneNumber,
                                ],
                                textInputAction: TextInputAction.next,
                              ),
                              const SizedBox(height: 14),
                              VelvetField(
                                controller: _nameCtrl,
                                label: l10n.displayName,
                                prefixIcon: const Icon(Icons.person_outline),
                                textCapitalization: TextCapitalization.words,
                                autofillHints: const [AutofillHints.name],
                                textInputAction: TextInputAction.next,
                              ),
                              const SizedBox(height: 14),
                              VelvetField(
                                controller: _cityCtrl,
                                label: l10n.waitlistCity,
                                prefixIcon:
                                    const Icon(Icons.location_city_outlined),
                                textCapitalization: TextCapitalization.words,
                                autofillHints: const [
                                  AutofillHints.addressCity,
                                ],
                                textInputAction: TextInputAction.next,
                              ),
                              const SizedBox(height: 14),
                              VelvetField(
                                controller: _noteCtrl,
                                label: l10n.waitlistNote,
                                prefixIcon:
                                    const Icon(Icons.edit_note_outlined),
                                maxLines: 3,
                                textInputAction: TextInputAction.done,
                                onSubmitted: (_) =>
                                    _loading ? null : _submit(),
                              ),
                              if (_error != null) ...[
                                const SizedBox(height: 14),
                                Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: VelvetTheme.danger
                                        .withValues(alpha: 0.12),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: VelvetTheme.danger
                                          .withValues(alpha: 0.35),
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
                                    : Text(l10n.waitlistSubmit),
                              ),
                              const SizedBox(height: 10),
                              OutlinedButton(
                                onPressed: _loading ? null : _checkStatus,
                                style: OutlinedButton.styleFrom(
                                  minimumSize: const Size.fromHeight(48),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(999),
                                  ),
                                ),
                                child: Text(l10n.waitlistCheckStatus),
                              ),
                            ],
                          ),
                  )
                      .animate()
                      .fadeIn(delay: 60.ms, duration: 400.ms)
                      .slideY(begin: 0.04, end: 0),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

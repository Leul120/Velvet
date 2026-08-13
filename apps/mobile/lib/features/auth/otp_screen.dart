import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:velvet_mobile/core/network/dio_client.dart';
import 'package:velvet_mobile/core/theme/velvet_editorial_colors.dart';
import 'package:velvet_mobile/core/theme/velvet_theme.dart';
import 'package:velvet_mobile/core/theme/velvet_tokens.dart';
import 'package:velvet_mobile/core/widgets/velvet_widgets.dart';
import 'package:velvet_mobile/features/auth/auth_controller.dart';
import 'package:velvet_mobile/l10n/generated/app_localizations.dart';

class OtpScreen extends ConsumerStatefulWidget {
  const OtpScreen({
    super.key,
    required this.phone,
    required this.inviteCode,
    this.devOtp,
    this.acceptedLegalVersion,
  });

  final String phone;
  final String inviteCode;
  final String? devOtp;
  final String? acceptedLegalVersion;

  @override
  ConsumerState<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends ConsumerState<OtpScreen> {
  late final TextEditingController _otpCtrl;
  bool _loading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _otpCtrl = TextEditingController(text: widget.devOtp ?? '');
    _otpCtrl.addListener(() {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _otpCtrl.dispose();
    super.dispose();
  }

  Future<void> _verify() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      await ref.read(authControllerProvider).verifyOtp(
            phone: widget.phone,
            code: _otpCtrl.text.trim(),
            acceptedLegalVersion: widget.acceptedLegalVersion,
          );
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
    final canVerify = !_loading && _otpCtrl.text.trim().length == 6;

    return VelvetAuthScaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          final minHeight =
              constraints.hasBoundedHeight ? constraints.maxHeight : 0.0;
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
                      onPressed: () => context.go('/auth'),
                      icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    l10n.otpTitle,
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
                    l10n.otpSubtitle(widget.phone),
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: colors.muted,
                          height: 1.45,
                        ),
                  ),
                  const SizedBox(height: 32),
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
                        if (widget.devOtp != null) ...[
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 10,
                            ),
                            decoration: BoxDecoration(
                              color: VelvetTokens.ember.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: VelvetTokens.ember.withValues(alpha: 0.3),
                              ),
                            ),
                            child: Text(
                              l10n.devOtpHint(widget.devOtp!),
                              style: GoogleFonts.dmSans(
                                color: VelvetTokens.ember,
                                fontWeight: FontWeight.w600,
                                fontSize: 13.5,
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),
                        ],
                        OtpBoxes(
                          controller: _otpCtrl,
                          onCompleted: (_) {
                            if (!_loading) _verify();
                          },
                        ),
                        if (_error != null) ...[
                          const SizedBox(height: 16),
                          Text(
                            _error!,
                            style: const TextStyle(color: VelvetTheme.danger),
                          ),
                        ],
                        const SizedBox(height: 28),
                        FilledButton(
                          onPressed: canVerify ? _verify : null,
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
                              : Text(l10n.verify),
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

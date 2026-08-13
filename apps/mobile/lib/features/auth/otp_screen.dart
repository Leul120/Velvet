import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:velvet_mobile/core/network/dio_client.dart';
import 'package:velvet_mobile/core/theme/velvet_theme.dart';
import 'package:velvet_mobile/core/theme/velvet_editorial_colors.dart';
import 'package:velvet_mobile/core/theme/velvet_tokens.dart';
import 'package:velvet_mobile/core/widgets/kinetic_text.dart';
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
    return VelvetAuthScaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          final minHeight = constraints.hasBoundedHeight ? constraints.maxHeight : 0.0;
          return SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(22, 8, 22, 28),
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: minHeight),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  VelvetIconChip(
                    icon: Icons.arrow_back_ios_new_rounded,
                    onTap: () => context.go('/auth'),
                  ),
                  const SizedBox(height: 28),
                  KineticEyebrow(label: l10n.otpTitle, icon: Icons.lock_outline),
                  const SizedBox(height: VelvetTokens.space8),
                  KineticText(
                    text: l10n.otpTitle,
                    style: GoogleFonts.syne(
                      fontSize: VelvetTokens.displayMedium,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -1.0,
                      height: 0.95,
                      color: context.velvet.ink,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    l10n.otpSubtitle(widget.phone),
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: context.velvet.muted),
                  ),
                  const SizedBox(height: 28),
                  GlassPanel(
                    padding: const EdgeInsets.fromLTRB(18, 24, 18, 24),
                    radius: VelvetTokens.radiusLg,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (widget.devOtp != null) ...[
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                            decoration: BoxDecoration(
                              color: VelvetTheme.teal.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(VelvetTheme.radiusSm),
                              border: Border.all(color: VelvetTheme.teal.withValues(alpha: 0.25)),
                            ),
                            child: Text(
                              l10n.devOtpHint(widget.devOtp!),
                              style: GoogleFonts.inter(
                                color: VelvetTheme.tealDeep,
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
                          Text(_error!, style: const TextStyle(color: VelvetTheme.danger)),
                        ],
                        const SizedBox(height: 28),
                        VelvetButton(
                          label: l10n.verify,
                          loading: _loading,
                          onPressed: _loading || _otpCtrl.text.trim().length != 6 ? null : _verify,
                        ),
                      ],
                    ),
                  ).animate().fadeIn(delay: 80.ms, duration: 420.ms).slideY(begin: 0.05, end: 0),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

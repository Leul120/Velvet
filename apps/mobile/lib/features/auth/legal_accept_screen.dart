import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:velvet_mobile/core/config/api_config.dart';
import 'package:velvet_mobile/core/network/dio_client.dart';
import 'package:velvet_mobile/core/theme/velvet_editorial_colors.dart';
import 'package:velvet_mobile/core/theme/velvet_theme.dart';
import 'package:velvet_mobile/core/theme/velvet_tokens.dart';
import 'package:velvet_mobile/core/widgets/velvet_widgets.dart';
import 'package:velvet_mobile/features/auth/auth_controller.dart';
import 'package:velvet_mobile/l10n/generated/app_localizations.dart';

class LegalAcceptScreen extends ConsumerStatefulWidget {
  const LegalAcceptScreen({super.key});

  @override
  ConsumerState<LegalAcceptScreen> createState() => _LegalAcceptScreenState();
}

class _LegalAcceptScreenState extends ConsumerState<LegalAcceptScreen> {
  bool _loading = false;
  String? _error;

  Future<void> _open(String path) async {
    final uri = Uri.parse('${ApiConfig.baseUrl}$path');
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  Future<void> _accept() async {
    final auth = ref.read(authControllerProvider);
    final version = auth.user?.legalVersionRequired ?? 'v1-2026-08';
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      await auth.acceptLegal(version);
    } catch (e) {
      if (mounted) setState(() => _error = apiErrorMessage(e));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colors = context.velvet;
    final locale = Localizations.localeOf(context).languageCode;
    final terms =
        locale == 'am' ? '/legal/terms-am.html' : '/legal/terms-en.html';
    final privacy =
        locale == 'am' ? '/legal/privacy-am.html' : '/legal/privacy-en.html';
    final community = locale == 'am'
        ? '/legal/community-am.html'
        : '/legal/community-en.html';

    Widget link(String label, String path, int delayMs) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () => _open(path),
            borderRadius: BorderRadius.circular(16),
            child: Ink(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
              decoration: BoxDecoration(
                color: colors.parchmentLift,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: colors.line.withValues(alpha: 0.7)),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      label,
                      style: GoogleFonts.dmSans(
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                        color: colors.ink,
                      ),
                    ),
                  ),
                  Icon(
                    Icons.open_in_new_rounded,
                    size: 16,
                    color: VelvetTokens.ember,
                  ),
                ],
              ),
            ),
          ),
        )
            .animate()
            .fadeIn(delay: delayMs.ms, duration: 320.ms)
            .slideY(begin: 0.04, end: 0),
      );
    }

    return VelvetAuthScaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 28, 24, 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const VelvetWordmark(size: 36, breathe: true),
              const SizedBox(height: 28),
              Text(
                l10n.legalUpdateTitle,
                style: GoogleFonts.syne(
                  fontSize: 32,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.9,
                  height: 0.98,
                  color: colors.ink,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                l10n.legalUpdateBody,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: colors.muted,
                      height: 1.45,
                    ),
              ).animate().fadeIn(delay: 40.ms, duration: 360.ms),
              const SizedBox(height: 28),
              link(l10n.termsOfService, terms, 80),
              link(l10n.privacyPolicy, privacy, 120),
              link(l10n.communityGuidelines, community, 160),
              const SizedBox(height: 8),
              Text(
                l10n.legalMarketplaceNotice,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: colors.muted,
                      height: 1.4,
                    ),
              ).animate().fadeIn(delay: 200.ms),
              if (_error != null) ...[
                const SizedBox(height: 16),
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
              const Spacer(),
              FilledButton(
                onPressed: _loading ? null : _accept,
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
                    : Text(l10n.legalAcceptCta),
              ).animate().fadeIn(delay: 240.ms),
            ],
          ),
        ),
      ),
    );
  }
}

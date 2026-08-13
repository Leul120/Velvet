import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:velvet_mobile/core/network/dio_client.dart';
import 'package:velvet_mobile/core/config/api_config.dart';
import 'package:velvet_mobile/core/theme/velvet_theme.dart';
import 'package:velvet_mobile/core/theme/velvet_editorial_colors.dart';
import 'package:velvet_mobile/core/theme/velvet_tokens.dart';
import 'package:velvet_mobile/core/widgets/kinetic_text.dart';
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
    final locale = Localizations.localeOf(context).languageCode;
    final terms = locale == 'am' ? '/legal/terms-am.html' : '/legal/terms-en.html';
    final privacy = locale == 'am' ? '/legal/privacy-am.html' : '/legal/privacy-en.html';
    final community = locale == 'am' ? '/legal/community-am.html' : '/legal/community-en.html';

    Widget link(String label, String path, int delayMs) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: GlassPanel(
          fill: VelvetTheme.glassStrong,
          padding: EdgeInsets.zero,
          child: InkWell(
            onTap: () => _open(path),
            borderRadius: BorderRadius.circular(VelvetTheme.radiusXl),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      label,
                      style: GoogleFonts.inter(fontWeight: FontWeight.w500, fontSize: 15),
                    ),
                  ),
                  const Icon(Icons.open_in_new, size: 16, color: VelvetTheme.teal),
                ],
              ),
            ),
          ),
        ).animate().fadeIn(delay: delayMs.ms, duration: 320.ms).slideY(begin: 0.05, end: 0),
      );
    }

    return VelvetAuthScaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(28, 36, 28, 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const VelvetWordmark(size: 36),
              const SizedBox(height: VelvetTokens.space32),
              KineticEyebrow(label: l10n.legalUpdateTitle, icon: Icons.gavel_outlined),
              const SizedBox(height: VelvetTokens.space8),
              KineticText(
                text: l10n.legalUpdateTitle,
                style: GoogleFonts.syne(
                  fontSize: VelvetTokens.displayMedium,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -1.0,
                  height: 0.95,
                  color: context.velvet.ink,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                l10n.legalUpdateBody,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: context.velvet.muted,
                      height: 1.45,
                    ),
              ).animate().fadeIn(delay: 50.ms, duration: 400.ms),
              const SizedBox(height: 36),
              link(l10n.termsOfService, terms, 100),
              link(l10n.privacyPolicy, privacy, 150),
              link(l10n.communityGuidelines, community, 200),
              const SizedBox(height: 12),
              Text(
                l10n.legalMarketplaceNotice,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(color: context.velvet.muted),
              ).animate().fadeIn(delay: 250.ms),
              if (_error != null) ...[
                const SizedBox(height: 16),
                Text(_error!, style: const TextStyle(color: VelvetTheme.danger)),
              ],
              const Spacer(),
              VelvetButton(
                label: l10n.legalAcceptCta,
                loading: _loading,
                onPressed: _loading ? null : _accept,
              ).animate().fadeIn(delay: 300.ms),
            ],
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:velvet_mobile/core/config/api_config.dart';
import 'package:velvet_mobile/core/theme/velvet_theme.dart';
import 'package:velvet_mobile/core/theme/velvet_editorial_colors.dart';
import 'package:velvet_mobile/core/theme/velvet_tokens.dart';
import 'package:velvet_mobile/core/widgets/kinetic_text.dart';
import 'package:velvet_mobile/core/widgets/velvet_feedback.dart';
import 'package:velvet_mobile/core/widgets/velvet_widgets.dart';
import 'package:velvet_mobile/features/auth/auth_controller.dart';
import 'package:velvet_mobile/l10n/generated/app_localizations.dart';

/// Staff tooling is provided by the responsive web consoles. Keeping it out of
/// the member shell prevents staff accounts from seeing member marketplace navigation.
class StaffPortalScreen extends ConsumerWidget {
  const StaffPortalScreen({super.key, required this.role});

  final String role;

  bool get _isPartner => role == 'VENUE_PARTNER';

  Future<void> _openConsole(BuildContext context) async {
    final path = _isPartner ? '/partner/' : '/admin/';
    final opened = await launchUrl(
      Uri.parse('${ApiConfig.baseUrl}$path'),
      mode: LaunchMode.externalApplication,
    );
    if (!opened && context.mounted) {
      await showVelvetErrorToast(
        context,
        message: AppLocalizations.of(context).consoleOpenFailed,
      );
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final isAdmin = role == 'ADMIN';
    final title = _isPartner
        ? l10n.partnerPortal
        : (isAdmin ? l10n.adminConsole : l10n.conciergeConsole);
    final description = _isPartner
        ? l10n.partnerPortalHint
        : (isAdmin ? l10n.adminConsoleHint : l10n.conciergeConsoleHint);
    final icon = _isPartner
        ? Icons.storefront_outlined
        : (isAdmin ? Icons.admin_panel_settings_outlined : Icons.support_agent_outlined);

    return VelvetScaffold(
      mistIntensity: 0.75,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(VelvetTokens.pageInset),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 460),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  KineticEyebrow(label: title, icon: icon),
                  const SizedBox(height: VelvetTokens.space8),
                  KineticText(
                    text: title,
                    style: GoogleFonts.syne(
                      fontSize: VelvetTokens.displaySmall,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.8,
                      height: 0.95,
                      color: context.velvet.ink,
                    ),
                  ),
                  const SizedBox(height: VelvetTokens.space24),
                  GlassPanel(
                    padding: const EdgeInsets.all(28),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(icon, color: VelvetTheme.teal, size: 42),
                        const SizedBox(height: 20),
                        Text(
                          description,
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                        const SizedBox(height: 14),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: VelvetTheme.lapis.withValues(alpha: 0.08),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: VelvetTheme.lapis.withValues(alpha: 0.2),
                            ),
                          ),
                          child: Text(
                            l10n.staffPortalMemberNavHint,
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ),
                        const SizedBox(height: 14),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: VelvetTheme.teal.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            '${l10n.accessLevel}: $role',
                            style: Theme.of(context).textTheme.labelMedium
                                ?.copyWith(
                                  color: VelvetTheme.teal,
                                  fontWeight: FontWeight.w700,
                                ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          l10n.consoleBrowserHint,
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                        const SizedBox(height: 28),
                        VelvetButton(
                          label: l10n.openConsole,
                          icon: Icons.open_in_new,
                          onPressed: () => _openConsole(context),
                        ),
                        const SizedBox(height: 12),
                        VelvetButton(
                          label: l10n.signOut,
                          variant: VelvetButtonVariant.ghost,
                          onPressed: () =>
                              ref.read(authControllerProvider).signOut(),
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

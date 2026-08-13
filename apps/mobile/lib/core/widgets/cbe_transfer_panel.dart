import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:velvet_mobile/core/theme/velvet_theme.dart';
import 'package:velvet_mobile/core/theme/velvet_tokens.dart';
import 'package:velvet_mobile/core/widgets/kinetic_text.dart';
import 'package:velvet_mobile/core/widgets/velvet_feedback.dart';
import 'package:velvet_mobile/core/widgets/velvet_widgets.dart';
import 'package:velvet_mobile/features/billing/billing_api.dart';
import 'package:velvet_mobile/l10n/generated/app_localizations.dart';

/// Shared editorial CBE transfer instructions (membership + booking).
class CbeTransferPanel extends StatelessWidget {
  const CbeTransferPanel({
    super.key,
    required this.title,
    required this.amountEtb,
    required this.merchantOrderId,
    required this.cbe,
    required this.mock,
    required this.loading,
    required this.onUploadReceipt,
    required this.onEnterCode,
    this.onMockComplete,
  });

  final String title;
  final num amountEtb;
  final String merchantOrderId;
  final CbeInstructions cbe;
  final bool mock;
  final bool loading;
  final VoidCallback? onUploadReceipt;
  final VoidCallback? onEnterCode;
  final VoidCallback? onMockComplete;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            VelvetTokens.emberSoft.withValues(alpha: 0.22),
            VelvetTokens.parchmentLift.withValues(alpha: 0.96),
          ],
        ),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(VelvetTokens.radiusXl),
          topRight: Radius.circular(VelvetTokens.radiusSm),
          bottomLeft: Radius.circular(VelvetTokens.radiusSm),
          bottomRight: Radius.circular(VelvetTokens.radiusLg),
        ),
        border: Border.all(color: VelvetTokens.ember.withValues(alpha: 0.32)),
        boxShadow: VelvetTokens.emberHalo(strength: 0.4),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          KineticEyebrow(label: 'CBE', icon: Icons.account_balance_outlined),
          const SizedBox(height: VelvetTokens.space8),
          KineticText(
            text: title,
            style: GoogleFonts.syne(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.5,
              height: 1.05,
            ),
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: mock
                  ? VelvetTheme.danger.withValues(alpha: 0.12)
                  : VelvetTokens.ember.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              mock ? l10n.cbeMockLabel : l10n.cbeLiveLabel,
              style: GoogleFonts.dmSans(
                fontWeight: FontWeight.w700,
                color: mock ? VelvetTheme.danger : VelvetTokens.emberDeep,
              ),
            ),
          ),
          const SizedBox(height: 18),
          _CbeStep(
            step: 1,
            title: l10n.cbeStepAmount,
            body: '${l10n.amount}: ${amountEtb.toStringAsFixed(0)} ETB\n'
                '${l10n.orderId}: $merchantOrderId',
          ),
          const SizedBox(height: 14),
          _CbeStep(
            step: 2,
            title: l10n.cbeStepAccount,
            body: '${l10n.cbeBank}: ${cbe.bankName}\n'
                '${l10n.cbeAccountName}: ${cbe.accountName}\n'
                '${l10n.cbeAccountNumber}: ${cbe.accountNumber}',
            trailing: IconButton(
              onPressed: () async {
                Clipboard.setData(ClipboardData(text: cbe.accountNumber));
                HapticFeedback.selectionClick();
                await showVelvetToast(context, message: l10n.copied, icon: Icons.copy_rounded);
              },
              icon: const Icon(Icons.copy_rounded, size: 18, color: VelvetTokens.ember),
            ),
          ),
          if (cbe.transferNote.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              cbe.transferNote,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: VelvetTheme.muted,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
          const SizedBox(height: 14),
          _CbeStep(
            step: 3,
            title: l10n.cbeStepReceipt,
            body: l10n.cbeVerifyEta,
          ),
          const SizedBox(height: 18),
          VelvetButton(
            label: l10n.uploadCbeReceipt,
            icon: Icons.photo_library_outlined,
            loading: loading,
            onPressed: loading ? null : onUploadReceipt,
          ),
          const SizedBox(height: 8),
          VelvetButton(
            label: 'Enter CBE transaction code',
            variant: VelvetButtonVariant.secondary,
            icon: Icons.pin_outlined,
            loading: loading,
            onPressed: loading ? null : onEnterCode,
          ),
          if (mock && onMockComplete != null) ...[
            const SizedBox(height: 8),
            VelvetButton(
              label: l10n.cbeMockComplete,
              variant: VelvetButtonVariant.ghost,
              loading: loading,
              onPressed: loading ? null : onMockComplete,
            ),
          ],
        ],
      ),
    );
  }
}

class _CbeStep extends StatelessWidget {
  const _CbeStep({
    required this.step,
    required this.title,
    required this.body,
    this.trailing,
  });

  final int step;
  final String title;
  final String body;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 28,
          height: 28,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: VelvetTokens.ember.withValues(alpha: 0.14),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: VelvetTokens.ember.withValues(alpha: 0.35)),
          ),
          child: Text(
            '$step',
            style: GoogleFonts.syne(
              fontWeight: FontWeight.w800,
              color: VelvetTokens.emberDeep,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: GoogleFonts.dmSans(
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                body,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  height: 1.45,
                  color: VelvetTheme.muted,
                ),
              ),
            ],
          ),
        ),
        if (trailing != null) trailing!,
      ],
    );
  }
}

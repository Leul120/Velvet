import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:velvet_mobile/core/theme/velvet_editorial_colors.dart';
import 'package:velvet_mobile/core/theme/velvet_theme.dart';
import 'package:velvet_mobile/core/theme/velvet_tokens.dart';
import 'package:velvet_mobile/core/widgets/velvet_feedback.dart';
import 'package:velvet_mobile/features/billing/billing_api.dart';
import 'package:velvet_mobile/l10n/generated/app_localizations.dart';

/// CBE transfer — lift card, numbered steps, pill CTAs.
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
    final colors = context.velvet;

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 18),
      decoration: BoxDecoration(
        color: colors.parchmentLift,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: colors.line.withValues(alpha: 0.7)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'CBE',
                style: GoogleFonts.dmSans(
                  color: VelvetTokens.ember,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.8,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: mock
                      ? VelvetTheme.danger.withValues(alpha: 0.12)
                      : VelvetTokens.ember.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  mock ? l10n.cbeMockLabel : l10n.cbeLiveLabel,
                  style: GoogleFonts.dmSans(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: mock ? VelvetTheme.danger : VelvetTokens.ember,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            title,
            style: GoogleFonts.syne(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.5,
              height: 1.05,
              color: colors.ink,
            ),
          ),
          const SizedBox(height: 18),
          _CbeStep(
            step: 1,
            title: l10n.cbeStepAmount,
            body:
                '${l10n.amount}: ${amountEtb.toStringAsFixed(0)} ETB\n'
                '${l10n.orderId}: $merchantOrderId',
          ),
          const SizedBox(height: 14),
          _CbeStep(
            step: 2,
            title: l10n.cbeStepAccount,
            body:
                '${l10n.cbeBank}: ${cbe.bankName}\n'
                '${l10n.cbeAccountName}: ${cbe.accountName}\n'
                '${l10n.cbeAccountNumber}: ${cbe.accountNumber}',
            trailing: IconButton(
              onPressed: () async {
                Clipboard.setData(ClipboardData(text: cbe.accountNumber));
                HapticFeedback.selectionClick();
                await showVelvetToast(
                  context,
                  message: l10n.copied,
                  icon: Icons.copy_rounded,
                );
              },
              icon: const Icon(
                Icons.copy_rounded,
                size: 18,
                color: VelvetTokens.ember,
              ),
            ),
          ),
          if (cbe.transferNote.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              cbe.transferNote,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: colors.muted,
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
          FilledButton.icon(
            onPressed: loading ? null : onUploadReceipt,
            icon: loading
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: VelvetTokens.onPrimary,
                    ),
                  )
                : const Icon(Icons.photo_library_outlined, size: 18),
            label: Text(l10n.uploadCbeReceipt),
            style: FilledButton.styleFrom(
              minimumSize: const Size.fromHeight(50),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(999),
              ),
            ),
          ),
          const SizedBox(height: 8),
          OutlinedButton.icon(
            onPressed: loading ? null : onEnterCode,
            icon: const Icon(Icons.pin_outlined, size: 18),
            label: const Text('Enter CBE transaction code'),
            style: OutlinedButton.styleFrom(
              minimumSize: const Size.fromHeight(50),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(999),
              ),
            ),
          ),
          if (mock && onMockComplete != null) ...[
            const SizedBox(height: 8),
            TextButton(
              onPressed: loading ? null : onMockComplete,
              child: Text(l10n.cbeMockComplete),
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
    final colors = context.velvet;
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
          ),
          child: Text(
            '$step',
            style: GoogleFonts.syne(
              fontWeight: FontWeight.w800,
              color: VelvetTokens.ember,
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
                  color: colors.muted,
                ),
              ),
            ],
          ),
        ),
        ?trailing,
      ],
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:velvet_mobile/core/network/dio_client.dart';
import 'package:velvet_mobile/core/theme/velvet_theme.dart';
import 'package:velvet_mobile/core/theme/velvet_editorial_colors.dart';
import 'package:velvet_mobile/core/theme/velvet_tokens.dart';
import 'package:velvet_mobile/core/widgets/editorial_list_card.dart';
import 'package:velvet_mobile/core/widgets/kinetic_text.dart';
import 'package:velvet_mobile/core/widgets/velvet_feedback.dart';
import 'package:velvet_mobile/core/widgets/velvet_widgets.dart';
import 'package:velvet_mobile/features/billing/earnings_api.dart';
import 'package:velvet_mobile/l10n/generated/app_localizations.dart';

class EarningsScreen extends ConsumerStatefulWidget {
  const EarningsScreen({super.key});

  @override
  ConsumerState<EarningsScreen> createState() => _EarningsScreenState();
}

class _EarningsScreenState extends ConsumerState<EarningsScreen> {
  EarningsSummary? _summary;
  bool _loading = true;
  bool _submitting = false;
  String? _error;
  final _amountCtrl = TextEditingController();
  final _destCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _amountCtrl.dispose();
    _destCtrl.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final summary = await ref.read(earningsApiProvider).summary();
      setState(() => _summary = summary);
    } catch (e) {
      setState(() => _error = apiErrorMessage(e));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _requestPayout() async {
    final l10n = AppLocalizations.of(context);
    final amount = double.tryParse(_amountCtrl.text.trim());
    if (amount == null || amount < 50) {
      await showVelvetErrorToast(context, message: l10n.payoutMinAmount);
      return;
    }
    setState(() => _submitting = true);
    try {
      await ref
          .read(earningsApiProvider)
          .requestPayout(
            amountEtb: amount,
            destinationNote: _destCtrl.text.trim().isEmpty
                ? null
                : _destCtrl.text.trim(),
          );
      _amountCtrl.clear();
      if (mounted) {
        await showVelvetToast(
          context,
          message: l10n.payoutRequested,
          icon: Icons.payments_outlined,
        );
      }
      await _load();
    } catch (e) {
      if (mounted) {
        showVelvetErrorToast(context, message: apiErrorMessage(e));
      }
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  String _money(double v) => NumberFormat('#,##0.00').format(v);

  String _typeLabel(AppLocalizations l10n, String type) => switch (type) {
    'PERFORMER_CREDIT' => l10n.earningsCredit,
    'PERFORMER_PAYOUT' => l10n.earningsPayout,
    _ => type,
  };

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final summary = _summary;

    return VelvetScaffold(
      mistIntensity: 0.55,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(8, 8, VelvetTokens.pageInset, 0),
            child: Row(
              children: [
                VelvetIconChip(
                  icon: Icons.arrow_back_ios_new_rounded,
                  onTap: () => context.pop(),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      KineticEyebrow(
                        label: l10n.earningsTitle,
                        icon: Icons.account_balance_wallet_outlined,
                      ),
                      KineticText(
                        text: l10n.earningsTitle,
                        style: GoogleFonts.syne(
                          fontSize: VelvetTokens.displaySmall,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.8,
                          height: 0.95,
                          color: context.velvet.ink,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: _loading
                ? const VelvetContentLoading()
                : _error != null
                ? VelvetEmptyState(
                    title: l10n.retry,
                    message: _error!,
                    icon: Icons.account_balance_wallet_outlined,
                    actionLabel: l10n.retry,
                    onAction: _load,
                  )
                : RefreshIndicator(
                    onRefresh: _load,
                    child: ListView(
                      padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
                      children: [
                        Text(
                          l10n.earningsHint(
                            100 - (summary?.platformFeePercent ?? 15),
                          ),
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(color: context.velvet.muted),
                        ),
                        const SizedBox(height: 18),
                        Container(
                          padding: const EdgeInsets.fromLTRB(22, 22, 22, 20),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                VelvetTokens.emberSoft.withValues(alpha: 0.28),
                                VelvetTokens.parchmentLift.withValues(alpha: 0.96),
                              ],
                            ),
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(VelvetTokens.radiusXl),
                              topRight: Radius.circular(VelvetTokens.radiusSm),
                              bottomLeft: Radius.circular(VelvetTokens.radiusSm),
                              bottomRight: Radius.circular(VelvetTokens.radiusLg),
                            ),
                            border: Border.all(
                              color: VelvetTokens.ember.withValues(alpha: 0.32),
                            ),
                            boxShadow: VelvetTokens.emberHalo(strength: 0.35),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              KineticEyebrow(
                                label: l10n.earningsAvailable,
                                icon: Icons.payments_outlined,
                              ),
                              const SizedBox(height: VelvetTokens.space8),
                              Text(
                                '${_money(summary?.availableEtb ?? 0)} ETB',
                                style: GoogleFonts.syne(
                                  fontSize: 34,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: -1.0,
                                  color: context.velvet.ink,
                                ),
                              ),
                              const SizedBox(height: 18),
                              Divider(color: VelvetTokens.line.withValues(alpha: 0.75)),
                              const SizedBox(height: 14),
                              _BalanceRow(
                                label: l10n.earningsLifetime,
                                value: '${_money(summary?.lifetimeEarnedEtb ?? 0)} ETB',
                              ),
                              const SizedBox(height: 8),
                              _BalanceRow(
                                label: l10n.earningsPaidOut,
                                value: '${_money(summary?.lifetimePaidOutEtb ?? 0)} ETB',
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                        GlassPanel(
                          padding: const EdgeInsets.all(18),
                          fill: VelvetTheme.glassStrong,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Text(
                                l10n.requestPayout,
                                style: GoogleFonts.syne(
                                  fontWeight: FontWeight.w800,
                                  fontSize: 18,
                                  letterSpacing: -0.3,
                                ),
                              ),
                              const SizedBox(height: 12),
                              VelvetField(
                                controller: _amountCtrl,
                                label: l10n.payoutAmount,
                                keyboardType:
                                    const TextInputType.numberWithOptions(
                                      decimal: true,
                                    ),
                              ),
                              const SizedBox(height: 12),
                              VelvetField(
                                controller: _destCtrl,
                                label: l10n.payoutDestination,
                              ),
                              const SizedBox(height: 16),
                              VelvetButton(
                                label: l10n.requestPayout,
                                loading: _submitting,
                                onPressed: _submitting ? null : _requestPayout,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 28),
                        Text(
                          l10n.earningsActivity,
                          style: GoogleFonts.syne(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.4,
                          ),
                        ),
                        const SizedBox(height: 10),
                        if (summary?.recent.isEmpty != false)
                          VelvetEmptyState(
                            title: l10n.earningsActivity,
                            message: l10n.earningsEmpty,
                            icon: Icons.receipt_long_outlined,
                          )
                        else
                          ...summary!.recent.asMap().entries.map((entry) {
                            final e = entry.value;
                            final credit = e.entryType == 'PERFORMER_CREDIT';
                            return EditorialRecordSlab(
                              index: entry.key,
                              title: _typeLabel(l10n, e.entryType),
                              subtitle: e.description ?? '',
                              complete: credit,
                              leading: Container(
                                width: 36,
                                height: 36,
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  color: (credit
                                          ? VelvetTokens.ember
                                          : VelvetTokens.plum)
                                      .withValues(alpha: 0.12),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Icon(
                                  credit
                                      ? Icons.south_west_rounded
                                      : Icons.north_east_rounded,
                                  size: 18,
                                  color: credit
                                      ? VelvetTokens.emberDeep
                                      : VelvetTokens.plumSoft,
                                ),
                              ),
                              trailing: Text(
                                '${credit ? '+' : '-'}${_money(e.amountEtb)}',
                                style: GoogleFonts.syne(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: -0.4,
                                  color: credit
                                      ? VelvetTokens.emberDeep
                                      : VelvetTheme.ink,
                                ),
                              ),
                            );
                          }),
                      ],
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}

class _BalanceRow extends StatelessWidget {
  const _BalanceRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: GoogleFonts.dmSans(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: context.velvet.muted,
          ),
        ),
        Text(
          value,
          style: GoogleFonts.dmSans(
            fontWeight: FontWeight.w700,
            color: context.velvet.ink,
          ),
        ),
      ],
    );
  }
}

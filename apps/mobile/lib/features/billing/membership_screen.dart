import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:velvet_mobile/core/network/dio_client.dart';
import 'package:velvet_mobile/core/theme/velvet_theme.dart';
import 'package:velvet_mobile/core/theme/velvet_editorial_colors.dart';
import 'package:velvet_mobile/core/theme/velvet_tokens.dart';
import 'package:velvet_mobile/core/widgets/cbe_transfer_panel.dart';
import 'package:velvet_mobile/core/widgets/editorial_dialog.dart';
import 'package:velvet_mobile/core/widgets/kinetic_text.dart';
import 'package:velvet_mobile/core/widgets/velvet_feedback.dart';
import 'package:velvet_mobile/core/widgets/membership_plan_card.dart';
import 'package:velvet_mobile/core/widgets/velvet_widgets.dart';
import 'package:velvet_mobile/features/auth/auth_controller.dart';
import 'package:velvet_mobile/features/auth/role_helpers.dart';
import 'package:velvet_mobile/features/billing/billing_api.dart';
import 'package:velvet_mobile/features/profile/performer_ready_screen.dart';
import 'package:velvet_mobile/l10n/generated/app_localizations.dart';
import 'package:velvet_mobile/core/ocr/receipt_reference.dart';

class MembershipScreen extends ConsumerStatefulWidget {
  const MembershipScreen({super.key});

  @override
  ConsumerState<MembershipScreen> createState() => _MembershipScreenState();
}

class _MembershipScreenState extends ConsumerState<MembershipScreen> {
  List<PlanItem> _plans = [];
  SubscriptionItem? _subscription;
  CheckoutResult? _pending;
  bool _loading = true;
  bool _submitting = false;
  String? _error;
  String? _payingCode;

  String _dateTime(DateTime date, String locale) =>
      DateFormat('MMM d, y • h:mm a', locale).format(date.toLocal());

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_isPerformer()) return;
      _load();
    });
  }

  bool _isPerformer() {
    final auth = ref.read(authControllerProvider);
    return isPerformerRole(auth.user?.role);
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final api = ref.read(billingApiProvider);
      final plans = await api.plans();
      final sub = await api.current();
      final pending = sub == null ? await api.pendingCbe() : null;
      setState(() {
        _plans = plans;
        _subscription = sub;
        _pending = sub != null ? null : pending;
      });
    } catch (e) {
      if (mounted) setState(() => _error = apiErrorMessage(e));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _start(PlanItem plan) async {
    setState(() => _payingCode = plan.code);
    try {
      final checkout = await ref.read(billingApiProvider).subscribe(plan.code);
      if (checkout.isCbe) {
        setState(() => _pending = checkout);
      } else if (checkout.mock) {
        await ref
            .read(billingApiProvider)
            .completeMock(checkout.merchantOrderId);
        if (mounted) {
          await showVelvetToast(
            context,
            message: AppLocalizations.of(context).telebirrMockPaid,
            icon: Icons.payments_outlined,
          );
        }
        await _load();
      } else if (checkout.checkoutUrl != null) {
        final uri = Uri.parse(checkout.checkoutUrl!);
        final ok = await launchUrl(uri, mode: LaunchMode.externalApplication);
        if (!ok && mounted) {
          await showVelvetErrorToast(
            context,
            message: AppLocalizations.of(context).telebirrOpenFailed,
          );
        }
      }
    } catch (e) {
      if (mounted) {
        showVelvetErrorToast(context, message: apiErrorMessage(e));
      }
    } finally {
      if (mounted) setState(() => _payingCode = null);
    }
  }

  Future<void> _uploadReceipt() async {
    final pending = _pending;
    if (pending == null) return;
    final l10n = AppLocalizations.of(context);
    final shot = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
    );
    if (shot == null) return;

    final scannedReference = await ReceiptReference.fromImage(shot.path);
    final reference = await _confirmCbeReference(scannedReference);
    if (!mounted || reference == null) return;

    setState(() => _submitting = true);
    try {
      await ref
          .read(billingApiProvider)
          .submitCbeProof(
            paymentIntentId: pending.paymentIntentId,
            filePath: shot.path,
            reference: reference,
          );
      if (mounted) {
        await showVelvetToast(
          context,
          message: l10n.cbePaymentVerified,
          icon: Icons.verified_outlined,
        );
      }
      setState(() => _pending = null);
      await _load();
    } catch (e) {
      if (mounted) {
        showVelvetErrorToast(context, message: apiErrorMessage(e));
      }
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  Future<void> _enterTransactionCode() async {
    final pending = _pending;
    if (pending == null) return;
    final reference = await _confirmCbeReference(null);
    if (!mounted || reference == null) return;
    setState(() => _submitting = true);
    try {
      await ref
          .read(billingApiProvider)
          .submitCbeProof(
            paymentIntentId: pending.paymentIntentId,
            reference: reference,
          );
      if (mounted) {
        await showVelvetToast(
          context,
          message: AppLocalizations.of(context).cbePaymentVerified,
          icon: Icons.verified_outlined,
        );
      }
      setState(() => _pending = null);
      await _load();
    } catch (e) {
      if (mounted) {
        showVelvetErrorToast(context, message: apiErrorMessage(e));
      }
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  Future<String?> _confirmCbeReference(String? scannedReference) async {
    final controller = TextEditingController(text: scannedReference ?? '');
    final result = await showEditorialDialog<String>(
      context: context,
      title: 'Review transaction code',
      message: scannedReference == null
          ? 'Enter the 12-character FT code shown on your CBE receipt.'
          : 'We found this CBE code in your receipt. Confirm it before verification.',
      icon: Icons.receipt_long_outlined,
      content: VelvetField(
        controller: controller,
        label: 'CBE transaction code',
        textCapitalization: TextCapitalization.characters,
        textInputAction: TextInputAction.done,
        onSubmitted: (_) {
          final value = controller.text.trim();
          if (value.isNotEmpty) Navigator.pop(context, value);
        },
      ),
      actions: [
        EditorialDialogAction(
          label: 'Cancel',
          onPressed: () => Navigator.pop(context),
        ),
        EditorialDialogAction(
          label: 'Verify payment',
          primary: true,
          onPressed: () {
            final value = controller.text.trim();
            if (value.isNotEmpty) Navigator.pop(context, value);
          },
        ),
      ],
    );
    controller.dispose();
    return result?.trim().isEmpty == true ? null : result?.trim();
  }

  Future<void> _mockComplete() async {
    final pending = _pending;
    if (pending == null) return;
    setState(() => _submitting = true);
    try {
      await ref
          .read(billingApiProvider)
          .completeMockCbe(pending.paymentIntentId);
      if (mounted) {
        await showVelvetToast(
          context,
          message: AppLocalizations.of(context).cbePaymentVerified,
          icon: Icons.verified_outlined,
        );
      }
      setState(() => _pending = null);
      await _load();
    } catch (e) {
      if (mounted) {
        showVelvetErrorToast(context, message: apiErrorMessage(e));
      }
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isPerformer()) {
      return const PerformerReadyScreen();
    }
    final l10n = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context).languageCode;

    return VelvetAuthScaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(
              VelvetTokens.pageInset,
              VelvetTokens.space16,
              VelvetTokens.pageInset,
              0,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                KineticEyebrow(
                  label: l10n.navMembership,
                  icon: Icons.workspace_premium_outlined,
                ),
                const SizedBox(height: VelvetTokens.space8),
                KineticText(
                  text: l10n.membershipTitle,
                  style: GoogleFonts.syne(
                    fontSize: VelvetTokens.displayMedium,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -1.2,
                    height: 0.92,
                    color: context.velvet.ink,
                  ),
                ),
                const SizedBox(height: VelvetTokens.space8),
                Text(
                  l10n.membershipHint,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: context.velvet.muted,
                    height: 1.45,
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
                    title: l10n.navMembership,
                    message: _error!,
                    icon: Icons.workspace_premium_outlined,
                    actionLabel: l10n.retry,
                    onAction: _load,
                    secondaryLabel: l10n.startDiscovering,
                    onSecondary: () => context.go('/discover'),
                  )
                : ListView(
                    padding: EdgeInsets.fromLTRB(
                      20,
                      16,
                      20,
                      120 + MediaQuery.paddingOf(context).bottom,
                    ),
                    children: [
                      Text(
                        l10n.cbePayHint,
                        style: GoogleFonts.inter(
                          color: VelvetTheme.tealDeep,
                          fontWeight: FontWeight.w500,
                          fontSize: 13,
                        ),
                      ),
                      if (_subscription != null) ...[
                        const SizedBox(height: 18),
                        GlassPanel(
                          padding: const EdgeInsets.all(18),
                          fill: VelvetTheme.glassStrong,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${l10n.activePlan}: ${_subscription!.planNameEn}',
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                              const SizedBox(height: 8),
                              StatusRibbon(status: _subscription!.status),
                              const SizedBox(height: 8),
                              Text(
                                '${l10n.renews}: ${_dateTime(_subscription!.endsAt, locale)}',
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                              Builder(
                                builder: (context) {
                                  final days = _subscription!.endsAt
                                      .difference(DateTime.now())
                                      .inDays;
                                  if (days > 7) return const SizedBox.shrink();
                                  return Padding(
                                    padding: const EdgeInsets.only(top: 10),
                                    child: Text(
                                      days < 0
                                          ? l10n.renewSoon
                                          : '${l10n.daysRemaining(days)} · ${l10n.renewSoon}',
                                      style: const TextStyle(
                                        color: VelvetTheme.danger,
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ],
                          ),
                        ).animate().fadeIn(),
                        if (_subscription!.endsAt
                                .difference(DateTime.now())
                                .inDays <=
                            14) ...[
                          const SizedBox(height: 16),
                          Text(
                            l10n.renewNow,
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                        ],
                      ],
                      if (_subscription == null)
                        Padding(
                          padding: const EdgeInsets.only(top: 18, bottom: 8),
                          child: Text(
                            l10n.noActiveMembership,
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                        ),
                      if (_subscription == null) ...[
                        const SizedBox(height: 8),
                        GlassPanel(
                          padding: const EdgeInsets.all(16),
                          fill: VelvetTheme.glassFill,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                l10n.membershipPlanIncludes,
                                style: Theme.of(context).textTheme.titleSmall
                                    ?.copyWith(fontWeight: FontWeight.w700),
                              ),
                              const SizedBox(height: 10),
                              _MembershipBenefit(
                                text: l10n.membershipBenefitBrowse,
                              ),
                              _MembershipBenefit(
                                text: l10n.membershipBenefitRequests,
                              ),
                              _MembershipBenefit(
                                text: l10n.membershipBenefitBook,
                              ),
                            ],
                          ),
                        ),
                      ],
                      if (_pending?.cbe != null) ...[
                        const SizedBox(height: 18),
                        CbeTransferPanel(
                          title: l10n.cbeTransferTitle,
                          amountEtb: _pending!.amountEtb,
                          merchantOrderId: _pending!.merchantOrderId,
                          cbe: _pending!.cbe!,
                          mock: _pending!.mock,
                          loading: _submitting,
                          onUploadReceipt: _uploadReceipt,
                          onEnterCode: _enterTransactionCode,
                          onMockComplete:
                              _pending!.mock ? _mockComplete : null,
                        ),
                      ],
                      const SizedBox(height: 24),
                      ..._plans.asMap().entries.map((entry) {
                        final i = entry.key;
                        final plan = entry.value;
                        final name = locale == 'am'
                            ? (plan.nameAm ?? plan.nameEn)
                            : plan.nameEn;
                        final quota = plan.bookingRequestQuota < 0
                            ? l10n.unlimitedBookingRequests
                            : '${plan.bookingRequestQuota} ${l10n.bookingRequestsPerMonth}';
                        final paying = _payingCode == plan.code;
                        return MembershipPlanCard(
                          plan: plan,
                          name: name,
                          quotaLabel: quota,
                          daysLabel: '${plan.durationDays} ${l10n.days}',
                          ctaLabel: l10n.payWithCbe,
                          index: i,
                          paying: paying,
                          onSelect: paying ? null : () => _start(plan),
                        );
                      }),
                    ],
                  ),
          ),
        ],
      ),
    );
  }
}

class _MembershipBenefit extends StatelessWidget {
  const _MembershipBenefit({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.check_circle_outline,
            size: 18,
            color: VelvetTheme.teal,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(text, style: Theme.of(context).textTheme.bodyMedium),
          ),
        ],
      ),
    );
  }
}

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
import 'package:velvet_mobile/features/profile/availability_api.dart';
import 'package:velvet_mobile/l10n/generated/app_localizations.dart';

class AvailabilityScreen extends ConsumerStatefulWidget {
  const AvailabilityScreen({super.key});

  @override
  ConsumerState<AvailabilityScreen> createState() => _AvailabilityScreenState();
}

class _AvailabilityScreenState extends ConsumerState<AvailabilityScreen> {
  List<AvailabilityWindow> _windows = [];
  bool _loading = true;
  bool _saving = false;
  String? _error;
  DateTime _day = DateTime.now();
  TimeOfDay _start = const TimeOfDay(hour: 18, minute: 0);
  TimeOfDay _end = const TimeOfDay(hour: 23, minute: 0);
  final _noteCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _noteCtrl.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final items = await ref.read(availabilityApiProvider).mine();
      setState(() => _windows = items);
    } catch (e) {
      setState(() => _error = apiErrorMessage(e));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  DateTime _combine(DateTime day, TimeOfDay t) =>
      DateTime(day.year, day.month, day.day, t.hour, t.minute);

  Future<void> _add() async {
    final l10n = AppLocalizations.of(context);
    var starts = _combine(_day, _start);
    var ends = _combine(_day, _end);
    if (!ends.isAfter(starts)) {
      ends = ends.add(const Duration(days: 1));
    }
    if (!starts.isAfter(DateTime.now())) {
      await showVelvetErrorToast(context, message: l10n.availabilityMustBeFuture);
      return;
    }
    setState(() => _saving = true);
    try {
      await ref
          .read(availabilityApiProvider)
          .create(
            startsAt: starts,
            endsAt: ends,
            note: _noteCtrl.text.trim().isEmpty ? null : _noteCtrl.text.trim(),
          );
      _noteCtrl.clear();
      await _load();
      if (mounted) {
        await showVelvetToast(context, message: l10n.availabilityAdded);
      }
    } catch (e) {
      if (mounted) {
        showVelvetErrorToast(context, message: apiErrorMessage(e));
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _delete(AvailabilityWindow w) async {
    try {
      await ref.read(availabilityApiProvider).delete(w.id);
      await _load();
    } catch (e) {
      if (mounted) {
        showVelvetErrorToast(context, message: apiErrorMessage(e));
      }
    }
  }

  Future<void> _pickDay() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _day.isBefore(DateTime.now()) ? DateTime.now() : _day,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 60)),
    );
    if (picked != null) setState(() => _day = picked);
  }

  Future<void> _pickStart() async {
    final picked = await showTimePicker(context: context, initialTime: _start);
    if (picked != null) setState(() => _start = picked);
  }

  Future<void> _pickEnd() async {
    final picked = await showTimePicker(context: context, initialTime: _end);
    if (picked != null) setState(() => _end = picked);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final df = DateFormat.yMMMd().add_jm();
    final dayFmt = DateFormat.yMMMd();

    return VelvetScaffold(
      mistIntensity: 0.45,
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
                        label: l10n.availabilityCalendarTitle,
                        icon: Icons.calendar_month_outlined,
                      ),
                      KineticText(
                        text: l10n.availabilityCalendarTitle,
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
                    message: _error!,
                    icon: Icons.event_busy_outlined,
                    actionLabel: l10n.retry,
                    onAction: _load,
                  )
                : RefreshIndicator(
                    onRefresh: _load,
                    child: ListView(
                      padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
                      children: [
                        Text(
                          l10n.availabilityCalendarHint,
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(color: context.velvet.muted),
                        ),
                        const SizedBox(height: 16),
                        GlassPanel(
                          padding: const EdgeInsets.all(16),
                          fill: VelvetTheme.glassStrong,
                          child: Column(
                            children: [
                              EditorialNavSlab(
                                title: l10n.availabilityDay,
                                subtitle: dayFmt.format(_day),
                                icon: Icons.calendar_today_outlined,
                                index: 0,
                                onTap: _pickDay,
                              ),
                              EditorialNavSlab(
                                title: l10n.availabilityStart,
                                subtitle: _start.format(context),
                                icon: Icons.schedule_outlined,
                                index: 1,
                                onTap: _pickStart,
                              ),
                              EditorialNavSlab(
                                title: l10n.availabilityEnd,
                                subtitle: _end.format(context),
                                icon: Icons.schedule_outlined,
                                index: 2,
                                onTap: _pickEnd,
                              ),
                              VelvetField(
                                controller: _noteCtrl,
                                label: l10n.availabilityWindowNote,
                              ),
                              const SizedBox(height: 12),
                              VelvetButton(
                                label: l10n.availabilityAddWindow,
                                loading: _saving,
                                onPressed: _saving ? null : _add,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),
                        Text(
                          l10n.availabilityUpcoming,
                          style: GoogleFonts.syne(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.4,
                          ),
                        ),
                        const SizedBox(height: 8),
                        if (_windows.isEmpty)
                          VelvetEmptyState(
                            message: l10n.availabilityEmpty,
                            icon: Icons.event_available_outlined,
                          )
                        else
                          ..._windows.asMap().entries.map(
                            (entry) {
                              final w = entry.value;
                              return EditorialRecordSlab(
                                index: entry.key,
                                title:
                                    '${df.format(w.startsAt)} → ${DateFormat.jm().format(w.endsAt)}',
                                subtitle: w.note ?? '',
                                leading: Container(
                                  width: 36,
                                  height: 36,
                                  alignment: Alignment.center,
                                  decoration: BoxDecoration(
                                    color: VelvetTokens.ember.withValues(alpha: 0.12),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: const Icon(
                                    Icons.event_available_outlined,
                                    size: 18,
                                    color: VelvetTokens.emberDeep,
                                  ),
                                ),
                                trailing: IconButton(
                                  icon: const Icon(Icons.delete_outline_rounded),
                                  color: VelvetTheme.danger,
                                  onPressed: () => _delete(w),
                                ),
                              );
                            },
                          ),
                      ],
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:velvet_mobile/core/location/location_helper.dart';
import 'package:velvet_mobile/core/network/dio_client.dart';
import 'package:velvet_mobile/core/ocr/receipt_reference.dart';
import 'package:velvet_mobile/core/theme/velvet_editorial_colors.dart';
import 'package:velvet_mobile/core/theme/velvet_theme.dart';
import 'package:velvet_mobile/core/theme/velvet_tokens.dart';
import 'package:velvet_mobile/core/widgets/booking_journey_rail.dart';
import 'package:velvet_mobile/core/widgets/cbe_transfer_panel.dart';
import 'package:velvet_mobile/core/widgets/editorial_dialog.dart';
import 'package:velvet_mobile/core/widgets/velvet_editorial_sheet.dart';
import 'package:velvet_mobile/core/widgets/velvet_feedback.dart';
import 'package:velvet_mobile/core/widgets/velvet_widgets.dart';
import 'package:velvet_mobile/features/auth/auth_controller.dart';
import 'package:velvet_mobile/features/auth/role_helpers.dart';
import 'package:velvet_mobile/features/billing/billing_api.dart';
import 'package:velvet_mobile/features/connections/connections_api.dart';
import 'package:velvet_mobile/features/profile/availability_api.dart';
import 'package:velvet_mobile/features/settings/low_bandwidth_provider.dart';
import 'package:velvet_mobile/features/social/social_api.dart';
import 'package:velvet_mobile/l10n/generated/app_localizations.dart';

class BookingScreen extends ConsumerStatefulWidget {
  const BookingScreen({super.key, required this.connectionId});

  final String connectionId;

  @override
  ConsumerState<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends ConsumerState<BookingScreen> {
  BookingItem? _booking;
  String? _venueId;
  final _meetupCtrl = TextEditingController();
  String _rateType = 'SESSION';
  DateTime _startsAt = DateTime.now().toUtc().add(const Duration(days: 1));
  bool _loading = true;
  bool _actioning = false;
  String? _error;
  CheckoutResult? _checkout;
  List<AvailabilityWindow> _windows = [];
  String? _focusStep;
  final _scrollCtrl = ScrollController();
  final _planKey = GlobalKey();
  final _confirmKey = GlobalKey();
  final _payKey = GlobalKey();
  final _payPanelKey = GlobalKey();
  final _feedbackKey = GlobalKey();
  bool _didAutoFocus = false;
  bool _highlightPay = false;
  bool _highlightConfirm = false;
  bool _timelinePulse = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _focusStep ??= GoRouterState.of(context).uri.queryParameters['focus'];
  }

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _scrollCtrl.dispose();
    _meetupCtrl.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final booking = await ref
          .read(bookingApiProvider)
          .byConnection(widget.connectionId);
      String? performerId;
      List<AvailabilityWindow> windows = [];
      try {
        final auth = ref.read(authControllerProvider);
        final meId = auth.user?.id;
        final iAmPerformer = isPerformerRole(auth.user?.role);
        if (iAmPerformer) {
          performerId = meId;
          windows = await ref.read(availabilityApiProvider).mine();
        } else {
          final mutual = await ref.read(connectionsApiProvider).mutual();
          ConnectionItem? match;
          for (final m in mutual) {
            if (m.id == widget.connectionId) {
              match = m;
              break;
            }
          }
          performerId = match?.counterpartUserId;
          if (performerId != null) {
            windows = await ref
                .read(availabilityApiProvider)
                .forUser(performerId);
          }
        }
      } catch (_) {}

      // Restore the CBE checkout panel if there is a pending payment and we
      // don't already have it in memory (e.g. after app resume or cold launch).
      CheckoutResult? restoredCheckout = _checkout;
      if (restoredCheckout == null &&
          booking != null &&
          (booking.paymentStatus == 'PENDING' ||
              booking.paymentStatus == 'CHECKOUT')) {
        try {
          restoredCheckout = await ref
              .read(billingApiProvider)
              .pendingBookingPayment(booking.id);
        } catch (_) {
          // Non-fatal: panel just won't show if the network call fails.
        }
      }

      setState(() {
        _booking = booking;
        _checkout = restoredCheckout;
        _venueId = booking?.venueId;
        if (booking?.meetupPlace != null) {
          _meetupCtrl.text = booking!.meetupPlace!;
        }
        if (booking?.rateType != null) _rateType = booking!.rateType!;
        if (booking != null) {
          _startsAt = booking.startsAt;
        } else if (windows.isNotEmpty) {
          _startsAt = windows.first.startsAt.toUtc();
        }
        _windows = windows;
      });
      _scrollToFocus(booking);
    } catch (e) {
      if (mounted) setState(() => _error = apiErrorMessage(e));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _setBookingWithPulse(BookingItem booking) {
    final statusChanged =
        _booking?.status != booking.status ||
        _booking?.paymentStatus != booking.paymentStatus;
    setState(() {
      _booking = booking;
      if (statusChanged) _timelinePulse = true;
    });
    if (!statusChanged) return;
    HapticFeedback.selectionClick();
    Future<void>.delayed(const Duration(milliseconds: 520), () {
      if (!mounted) return;
      setState(() => _timelinePulse = false);
    });
  }

  Future<void> _propose() async {
    final place = _meetupCtrl.text.trim();
    if (place.isEmpty && _venueId == null) return;
    setState(() => _actioning = true);
    try {
      final booking = await ref
          .read(bookingApiProvider)
          .propose(
            connectionId: widget.connectionId,
            venueId: place.isEmpty ? _venueId : null,
            meetupPlace: place.isEmpty ? null : place,
            rateType: _rateType,
            startsAt: _startsAt,
          );
      HapticFeedback.mediumImpact();
      _setBookingWithPulse(booking);
      _scrollToFocus(booking);
      if (mounted) {
        await showVelvetToast(
          context,
          message: AppLocalizations.of(context).bookingProposedSnack,
        );
      }
    } catch (e) {
      if (mounted) {
        showVelvetErrorToast(context, message: apiErrorMessage(e));
      }
    } finally {
      if (mounted) setState(() => _actioning = false);
    }
  }

  Future<void> _payBooking() async {
    final booking = _booking;
    if (booking == null) return;
    final l10n = AppLocalizations.of(context);
    setState(() => _actioning = true);
    try {
      final checkout = await ref
          .read(billingApiProvider)
          .payBooking(booking.id);
      setState(() => _checkout = checkout);
      final refreshed = await ref.read(bookingApiProvider).get(booking.id);
      _setBookingWithPulse(refreshed);
      _scrollToFocus(refreshed);
      if (mounted) {
        await showVelvetToast(context, message: l10n.paymentPending);
      }
      if (!checkout.isCbe && checkout.checkoutUrl != null) {
        await launchUrl(
          Uri.parse(checkout.checkoutUrl!),
          mode: LaunchMode.externalApplication,
        );
      }
    } catch (e) {
      if (mounted) {
        showVelvetErrorToast(context, message: apiErrorMessage(e));
      }
    } finally {
      if (mounted) setState(() => _actioning = false);
    }
  }

  Future<void> _uploadBookingReceipt() async {
    final checkout = _checkout;
    if (checkout == null) return;
    final l10n = AppLocalizations.of(context);
    final shot = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
    );
    if (shot == null) return;
    String? reference = await ReceiptReference.fromImage(shot.path);
    if (!mounted) return;
    final confirmedReference = await showEditorialPrompt(
      context: context,
      title: 'Confirm CBE transaction reference',
      fieldLabel: 'FT / transaction reference',
      helperText: 'Extracted from the screenshot. Correct it if needed.',
      initialValue: reference,
      confirmLabel: 'Verify payment',
      cancelLabel: 'Cancel',
      capitalization: TextCapitalization.characters,
    );
    if (confirmedReference == null || confirmedReference.isEmpty) return;
    setState(() => _actioning = true);
    try {
      await ref
          .read(billingApiProvider)
          .submitCbeProof(
            paymentIntentId: checkout.paymentIntentId,
            filePath: shot.path,
            reference: confirmedReference,
          );
      final refreshed = await ref.read(bookingApiProvider).get(_booking!.id);
      setState(() {
        _checkout = null;
      });
      _setBookingWithPulse(refreshed);
      if (mounted) {
        await showVelvetToast(context, message: l10n.bookingPaid);
      }
    } catch (e) {
      if (mounted) {
        showVelvetErrorToast(context, message: apiErrorMessage(e));
      }
    } finally {
      if (mounted) setState(() => _actioning = false);
    }
  }

  Future<void> _enterBookingTransactionCode() async {
    final checkout = _checkout;
    if (checkout == null) return;
    final reference = await showEditorialPrompt(
      context: context,
      title: 'Enter CBE transaction code',
      fieldLabel: '12-character FT code',
      helperText: 'For example: FT26217SSG8W',
      confirmLabel: 'Verify payment',
      cancelLabel: 'Cancel',
      capitalization: TextCapitalization.characters,
    );
    if (!mounted || reference == null || reference.isEmpty) return;

    setState(() => _actioning = true);
    try {
      await ref
          .read(billingApiProvider)
          .submitCbeProof(
            paymentIntentId: checkout.paymentIntentId,
            reference: reference,
          );
      final refreshed = await ref.read(bookingApiProvider).get(_booking!.id);
      setState(() => _checkout = null);
      _setBookingWithPulse(refreshed);
      if (mounted) {
        await showVelvetToast(
          context,
          message: AppLocalizations.of(context).bookingPaid,
        );
      }
    } catch (e) {
      if (mounted) {
        showVelvetErrorToast(context, message: apiErrorMessage(e));
      }
    } finally {
      if (mounted) setState(() => _actioning = false);
    }
  }

  Future<void> _mockCompleteBookingPay() async {
    final checkout = _checkout;
    if (checkout == null) return;
    final l10n = AppLocalizations.of(context);
    setState(() => _actioning = true);
    try {
      await ref
          .read(billingApiProvider)
          .completeMockCbe(checkout.paymentIntentId);
      final refreshed = await ref.read(bookingApiProvider).get(_booking!.id);
      setState(() {
        _checkout = null;
      });
      _setBookingWithPulse(refreshed);
      if (mounted) {
        await showVelvetToast(context, message: l10n.bookingPaid);
      }
    } catch (e) {
      if (mounted) {
        showVelvetErrorToast(context, message: apiErrorMessage(e));
      }
    } finally {
      if (mounted) setState(() => _actioning = false);
    }
  }

  Future<void> _confirm() async {
    if (_booking == null) return;
    setState(() => _actioning = true);
    try {
      final booking = await ref.read(bookingApiProvider).confirm(_booking!.id);
      HapticFeedback.mediumImpact();
      _setBookingWithPulse(booking);
      _scrollToFocus(booking);
      if (mounted) {
        await showVelvetToast(
          context,
          message: AppLocalizations.of(context).bookingConfirmedSnack,
        );
      }
    } catch (e) {
      if (mounted) {
        showVelvetErrorToast(context, message: apiErrorMessage(e));
      }
    } finally {
      if (mounted) setState(() => _actioning = false);
    }
  }

  String _meetingTime(DateTime date, String locale) =>
      DateFormat('EEE, MMM d • h:mm a', locale).format(date.toLocal());

  Future<void> _pickTime() async {
    final date = await showDatePicker(
      context: context,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 60)),
      initialDate: _startsAt.toLocal(),
    );
    if (date == null || !mounted) return;
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_startsAt.toLocal()),
    );
    if (time == null || !mounted) return;
    setState(() {
      _startsAt = DateTime(
        date.year,
        date.month,
        date.day,
        time.hour,
        time.minute,
      ).toUtc();
    });
  }

  VenueItem? get _selectedVenue {
    final id = _venueId ?? _booking?.venueId;
    if (id == null) return null;
    return null;
  }

  Future<void> _openMaps(VenueItem? venue, BookingItem? booking) async {
    final lat = venue?.latitude ?? booking?.venueLatitude;
    final lng = venue?.longitude ?? booking?.venueLongitude;
    final address = venue?.addressLine ?? booking?.venueAddressLine;
    final city = venue?.city ?? booking?.venueCity ?? 'Addis Ababa';
    final name = venue?.name ?? booking?.venueName ?? 'VELVET venue';
    Uri uri;
    if (lat != null && lng != null) {
      uri = Uri.parse(
        'https://www.google.com/maps/search/?api=1&query=$lat,$lng',
      );
    } else if (address != null && address.isNotEmpty) {
      uri = Uri.parse(
        'https://www.google.com/maps/search/?api=1&query=${Uri.encodeComponent('$address, $city')}',
      );
    } else {
      uri = Uri.parse(
        'https://www.google.com/maps/search/?api=1&query=${Uri.encodeComponent('$name, $city')}',
      );
    }
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  Future<void> _addToCalendar(VenueItem? venue, BookingItem booking) async {
    final start = booking.startsAt.toUtc();
    final end = start.add(const Duration(hours: 2));
    String fmt(DateTime d) =>
        '${d.year.toString().padLeft(4, '0')}${d.month.toString().padLeft(2, '0')}${d.day.toString().padLeft(2, '0')}T'
        '${d.hour.toString().padLeft(2, '0')}${d.minute.toString().padLeft(2, '0')}${d.second.toString().padLeft(2, '0')}Z';
    final location = [
      venue?.name ?? booking.placeLabel,
      venue?.addressLine ?? booking.venueAddressLine,
      venue?.city ?? booking.venueCity,
    ].whereType<String>().where((s) => s.isNotEmpty).join(', ');
    final uri = Uri.parse(
      'https://calendar.google.com/calendar/render?action=TEMPLATE'
      '&text=${Uri.encodeComponent('VELVET · ${booking.placeLabel}')}'
      '&dates=${fmt(start)}/${fmt(end)}'
      '&location=${Uri.encodeComponent(location)}'
      '&details=${Uri.encodeComponent('Private booking via VELVET')}',
    );
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  Future<void> _showFeedback(BookingItem booking) async {
    final l10n = AppLocalizations.of(context);
    var feltSafe = true;
    var wouldMeetAgain = true;
    var venueOk = true;
    final notesCtrl = TextEditingController();
    final submitted = await showEditorialSheet<bool>(
      context: context,
      initialSize: 0.72,
      minSize: 0.45,
      builder: (context, scrollController) {
        return StatefulBuilder(
          builder: (context, setModal) {
            return SingleChildScrollView(
              controller: scrollController,
              padding: EdgeInsets.fromLTRB(
                VelvetTokens.pageInset,
                8,
                VelvetTokens.pageInset,
                24 + MediaQuery.viewInsetsOf(context).bottom,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  VelvetPageHeader(
                    title: l10n.meetingFeedbackTitle,
                    subtitle: l10n.meetingFeedbackHint,
                  ),
                  const SizedBox(height: 24),
                  VelvetTactileSlider(
                    label: l10n.feltSafe,
                    initialValue: feltSafe,
                    onChanged: (v) => setModal(() => feltSafe = v),
                  ),
                  VelvetTactileSlider(
                    label: l10n.wouldBookAgain,
                    initialValue: wouldMeetAgain,
                    onChanged: (v) => setModal(() => wouldMeetAgain = v),
                  ),
                  VelvetTactileSlider(
                    label: l10n.venueOk,
                    initialValue: venueOk,
                    onChanged: (v) => setModal(() => venueOk = v),
                  ),
                  const SizedBox(height: 16),
                  VelvetField(
                    controller: notesCtrl,
                    hint: l10n.optionalNotes,
                    maxLines: 2,
                  ),
                  const SizedBox(height: 24),
                  VelvetButton(
                    label: l10n.submitFeedback,
                    onPressed: () => Navigator.pop(context, true),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
    if (submitted != true) return;
    try {
      await ref
          .read(bookingApiProvider)
          .submitFeedback(
            bookingId: booking.id,
            feltSafe: feltSafe,
            wouldMeetAgain: wouldMeetAgain,
            venueOk: venueOk,
            notes: notesCtrl.text.trim().isEmpty ? null : notesCtrl.text.trim(),
          );
      HapticFeedback.lightImpact();
      setState(() {
        _booking = BookingItem(
          id: booking.id,
          connectionId: booking.connectionId,
          venueId: booking.venueId,
          venueName: booking.venueName,
          status: booking.status,
          startsAt: booking.startsAt,
          proposedBy: booking.proposedBy,
          venueNameAm: booking.venueNameAm,
          venueArea: booking.venueArea,
          venuePriceBand: booking.venuePriceBand,
          venueVibe: booking.venueVibe,
          venuePhotoUrls: booking.venuePhotoUrls,
          venueVerified: booking.venueVerified,
          venueLatitude: booking.venueLatitude,
          venueLongitude: booking.venueLongitude,
          venueAddressLine: booking.venueAddressLine,
          venueCity: booking.venueCity,
          meetupPlace: booking.meetupPlace,
          rateType: booking.rateType,
          amountEtb: booking.amountEtb,
          paymentStatus: booking.paymentStatus,
          confirmedAt: booking.confirmedAt,
          checkedInAt: booking.checkedInAt,
          checkedOutAt: booking.checkedOutAt,
          reminder24hSentAt: booking.reminder24hSentAt,
          reminder2hSentAt: booking.reminder2hSentAt,
          feedbackSubmitted: true,
        );
      });
      if (mounted) {
        await showVelvetToast(
          context,
          message: l10n.feedbackThanks,
          icon: Icons.favorite_outline_rounded,
        );
      }
    } catch (e) {
      if (mounted) {
        showVelvetErrorToast(context, message: apiErrorMessage(e));
      }
    } finally {
      notesCtrl.dispose();
    }
  }

  Future<void> _shareTrip() async {
    final booking = _booking;
    if (booking == null) return;
    final l10n = AppLocalizations.of(context);
    setState(() => _actioning = true);
    try {
      final pos = await LocationHelper.currentOrNull();
      await ref
          .read(safetyApiProvider)
          .shareTrip(
            bookingId: booking.id,
            connectionId: widget.connectionId,
            latitude: pos?.latitude,
            longitude: pos?.longitude,
            etaMinutes: 30,
            note: 'Leaving for meeting',
          );
      HapticFeedback.selectionClick();
      if (mounted) {
        await showVelvetToast(context, message: l10n.tripSharedSnack);
      }
    } catch (e) {
      if (mounted) {
        showVelvetErrorToast(context, message: apiErrorMessage(e));
      }
    } finally {
      if (mounted) setState(() => _actioning = false);
    }
  }

  void _scrollToFocus(BookingItem? booking) {
    if (_focusStep == null || _didAutoFocus || !mounted) return;
    GlobalKey? key;
    switch (_focusStep) {
      case 'pay':
        if (_checkout != null) {
          key = _payPanelKey;
        } else {
          key = booking?.needsPayment == true ? _payKey : _confirmKey;
        }
        break;
      case 'confirm':
        key = booking?.status == 'PROPOSED' ? _confirmKey : _payKey;
        break;
      case 'plan':
      default:
        key = _focusStep == 'feedback' ? _feedbackKey : _planKey;
        break;
    }
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final ctx = key?.currentContext;
      if (!mounted || ctx == null) return;
      _didAutoFocus = true;
      await Scrollable.ensureVisible(
        ctx,
        duration: const Duration(milliseconds: 420),
        curve: Curves.easeOutCubic,
        alignment: 0.18,
      );
      if (!mounted) return;
      final targetPay = _focusStep == 'pay' && booking?.needsPayment == true;
      setState(() {
        _highlightPay = targetPay;
        _highlightConfirm =
            !targetPay &&
            _focusStep == 'confirm' &&
            booking?.status == 'PROPOSED';
      });
      Future<void>.delayed(const Duration(milliseconds: 1100), () {
        if (!mounted) return;
        setState(() {
          _highlightPay = false;
          _highlightConfirm = false;
        });
      });
    });
  }

  int _timelineIndex(BookingItem? b) {
    if (b == null) return 0;
    switch (b.status) {
      case 'PROPOSED':
        return 1;
      case 'CONFIRMED':
        if (b.reminder2hSentAt != null || b.reminder24hSentAt != null) return 3;
        return 2;
      case 'CHECKED_IN':
        return 4;
      case 'COMPLETED':
        return 5;
      default:
        return 0;
    }
  }

  Widget _timeline(AppLocalizations l10n, BookingItem? booking) {
    final steps = [
      l10n.timelinePropose,
      l10n.timelineConfirm,
      l10n.timelineReminder,
      l10n.timelineCheckIn,
      l10n.timelineCheckout,
    ];
    final active = _timelineIndex(booking).clamp(0, steps.length - 1).toInt();

    return BookingJourneyRail(
      steps: steps,
      activeIndex: active,
      pulse: _timelinePulse,
      title: l10n.bookingTitle,
      subtitle: l10n.bookingHint,
    );
  }

  Widget _venueSummary(
    AppLocalizations l10n,
    VenueItem? venue,
    BookingItem booking,
    String locale,
    bool lowBw,
  ) {
    final name = booking.meetupPlace?.trim().isNotEmpty == true
        ? booking.meetupPlace!
        : (locale == 'am'
              ? (venue?.nameAm ??
                    booking.venueNameAm ??
                    booking.venueName ??
                    booking.placeLabel)
              : (venue?.name ?? booking.venueName ?? booking.placeLabel));
    final photos = venue?.photoUrls.isNotEmpty == true
        ? venue!.photoUrls
        : booking.venuePhotoUrls;
    final area = venue?.area ?? booking.venueArea;
    final vibeRaw = venue?.vibe ?? booking.venueVibe;
    final vibe = switch (vibeRaw) {
      'QUIET' => l10n.vibeQuiet,
      'LIVELY' => l10n.vibeLively,
      _ => l10n.vibeBalanced,
    };
    final payLabel = switch (booking.paymentStatus) {
      'PAID' => l10n.paymentPaid,
      'PENDING' => l10n.paymentPending,
      'WAIVED' => l10n.paymentWaived,
      _ => l10n.paymentUnpaid,
    };
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: VelvetTheme.line),
        color: VelvetTheme.mistSage.withValues(alpha: 0.25),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (photos.isNotEmpty)
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: AspectRatio(
                aspectRatio: 16 / 9,
                child: Image.network(
                  photos.first,
                  fit: BoxFit.cover,
                  cacheWidth: mediaCacheWidth(lowBw),
                  errorBuilder: (_, _, _) => Container(color: VelvetTheme.line),
                ),
              ),
            ),
          if (photos.isNotEmpty) const SizedBox(height: 12),
          Text(
            name,
            style: GoogleFonts.inter(
              fontWeight: FontWeight.w600,
              fontSize: 18,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            [
              ?area,
              booking.rateType == 'OVERNIGHT'
                  ? l10n.rateTypeOvernight
                  : l10n.rateTypeSession,
              if (vibeRaw != null) vibe,
            ].join(' · '),
            style: Theme.of(context).textTheme.bodySmall,
          ),
          if (booking.amountEtb != null) ...[
            const SizedBox(height: 8),
            Text(
              '${l10n.bookingAmount(booking.amountEtb!)} · $payLabel',
              style: GoogleFonts.inter(
                fontWeight: FontWeight.w600,
                color: VelvetTheme.tealDeep,
              ),
            ),
          ],
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              if (booking.venueId != null)
                TextButton.icon(
                  onPressed: () => _openMaps(venue, booking),
                  icon: const Icon(Icons.map_outlined, size: 18),
                  label: Text(l10n.openInMaps),
                ),
              TextButton.icon(
                onPressed: () => _addToCalendar(venue, booking),
                icon: const Icon(Icons.event_outlined, size: 18),
                label: Text(l10n.addToCalendar),
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context).languageCode;
    final auth = ref.watch(authControllerProvider);
    final meId = auth.user?.id;
    final isPerformer = isPerformerRole(auth.user?.role);
    final lowBw = ref.watch(lowBandwidthProvider);
    final booking = _booking;
    final venue = _selectedVenue;
    final isProposer =
        booking != null && meId != null && booking.proposedBy == meId;
    final awaitingConfirm = booking?.status == 'PROPOSED' && !isProposer;
    final focusPay = _focusStep == 'pay';
    final focusConfirm = _focusStep == 'confirm';

    return VelvetScaffold(
      mistIntensity: 0.95,
      safeArea: false,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 4, 8, 0),
              child: Row(
                children: [
                  VelvetIconChip(
                    icon: Icons.arrow_back_ios_new_rounded,
                    onTap: () => context.pop(),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      l10n.bookingTitle,
                      style: GoogleFonts.syne(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.5,
                        color: context.velvet.ink,
                      ),
                    ),
                  ),
                  VelvetIconChip(
                    icon: Icons.shield_outlined,
                    onTap: () => context.push('/safety'),
                  ),
                ],
              ),
            ),
            Expanded(
              child: _loading
                  ? const VelvetContentLoading(count: 4)
                  : _error != null
                  ? VelvetEmptyState(
                      title: l10n.retry,
                      message: _error!,
                      icon: Icons.event_busy_outlined,
                      actionLabel: l10n.retry,
                      onAction: _load,
                      secondaryLabel: l10n.safetyCenterTitle,
                      onSecondary: () => context.push('/safety'),
                    )
                  : ListView(
                      controller: _scrollCtrl,
                      padding: EdgeInsets.fromLTRB(
                        VelvetTokens.pageInset,
                        VelvetTokens.space8,
                        VelvetTokens.pageInset,
                        48 + MediaQuery.paddingOf(context).bottom,
                      ),
                      children: [
                        _timeline(l10n, booking),
                        const SizedBox(height: VelvetTokens.space20),
                      if (booking != null) ...[
                        _BookingNextStepCard(
                          key: awaitingConfirm
                              ? _confirmKey
                              : (booking.needsPayment && _checkout == null
                                    ? _payKey
                                    : null),
                          booking: booking,
                          canConfirm: awaitingConfirm,
                          emphasis: _highlightConfirm || _highlightPay,
                          onOpenChat: () =>
                              context.push('/chat/${widget.connectionId}'),
                          onPay: _actioning ? null : _payBooking,
                          onConfirm: _actioning ? null : _confirm,
                        ),
                        const SizedBox(height: 12),
                        _venueSummary(l10n, venue, booking, locale, lowBw),
                        const SizedBox(height: 12),
                        Text(
                          '${l10n.meetingTime}: ${_meetingTime(booking.startsAt, locale)}',
                          style: GoogleFonts.inter(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 16),
                        if (focusConfirm && awaitingConfirm) ...[
                          const SizedBox(height: 8),
                          Text(
                            l10n.flowFocusConfirmHint,
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(color: VelvetTheme.orangeSoft),
                          ),
                        ],
                        if (booking.needsPayment) ...[
                          const SizedBox(height: 10),
                          if (_checkout != null && _checkout!.cbe != null) ...[
                            CbeTransferPanel(
                              key: _payPanelKey,
                              title: l10n.paymentPending,
                              amountEtb:
                                  booking.amountEtb ?? _checkout!.amountEtb,
                              merchantOrderId: _checkout!.merchantOrderId,
                              cbe: _checkout!.cbe!,
                              mock: _checkout!.mock,
                              loading: _actioning,
                              onUploadReceipt: _uploadBookingReceipt,
                              onEnterCode: _enterBookingTransactionCode,
                              onMockComplete: _checkout!.mock
                                  ? _mockCompleteBookingPay
                                  : null,
                            ),
                          ],
                          if (focusPay) ...[
                            const SizedBox(height: 8),
                            Text(
                              booking.paymentStatus == 'PAID'
                                  ? l10n.flowFocusPayDoneHint
                                  : l10n.flowFocusPayHint,
                              style: Theme.of(context).textTheme.bodySmall
                                  ?.copyWith(color: VelvetTheme.orangeSoft),
                            ),
                          ],
                        ],
                        if (booking.status == 'PROPOSED' && isProposer)
                          Text(
                            l10n.waitingCounterpart,
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        if (booking.status == 'CONFIRMED' ||
                            booking.status == 'CHECKED_IN') ...[
                          VelvetButton(
                            label: l10n.shareTripWithVelvet,
                            variant: VelvetButtonVariant.ghost,
                            icon: Icons.directions_walk_outlined,
                            loading: _actioning,
                            onPressed: _actioning ? null : _shareTrip,
                          ),
                          if (isPerformer) ...[
                            const SizedBox(height: 10),
                            VelvetButton(
                              label: l10n.checkIn,
                              loading: _actioning,
                              onPressed: _actioning
                                  ? null
                                  : () async {
                                      setState(() => _actioning = true);
                                      try {
                                        final pos =
                                            await LocationHelper.currentOrNull();
                                        final b = await ref
                                            .read(bookingApiProvider)
                                            .checkIn(
                                              booking.id,
                                              latitude: pos?.latitude,
                                              longitude: pos?.longitude,
                                            );
                                        HapticFeedback.mediumImpact();
                                        _setBookingWithPulse(b);
                                      } catch (e) {
                                        if (context.mounted) {
                                          showVelvetErrorToast(
                                            context,
                                            message: apiErrorMessage(e),
                                          );
                                        }
                                      } finally {
                                        if (mounted) {
                                          setState(() => _actioning = false);
                                        }
                                      }
                                    },
                            ),
                          ],
                          if (booking.checkedInAt != null &&
                              !booking.myCheckoutConfirmed) ...[
                            const SizedBox(height: 10),
                            VelvetButton(
                              label: booking.counterpartCheckoutConfirmed
                                  ? 'Confirm checkout — release session payment'
                                  : 'Confirm checkout',
                              variant: VelvetButtonVariant.ghost,
                              loading: _actioning,
                              onPressed: _actioning
                                  ? null
                                  : () async {
                                      setState(() => _actioning = true);
                                      try {
                                        final b = await ref
                                            .read(bookingApiProvider)
                                            .checkOut(booking.id);
                                        HapticFeedback.mediumImpact();
                                        _setBookingWithPulse(b);
                                        if (mounted && !b.feedbackSubmitted) {
                                          await _showFeedback(b);
                                        }
                                      } catch (e) {
                                        if (context.mounted) {
                                          showVelvetErrorToast(
                                            context,
                                            message: apiErrorMessage(e),
                                          );
                                        }
                                      } finally {
                                        if (mounted) {
                                          setState(() => _actioning = false);
                                        }
                                      }
                                    },
                            ),
                          ],
                          if (booking.checkedInAt != null &&
                              booking.myCheckoutConfirmed &&
                              booking.status != 'COMPLETED')
                            Padding(
                              padding: const EdgeInsets.only(top: 10),
                              child: Text(
                                'Your checkout is recorded. Waiting for the other member to confirm before payment is released.',
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                            ),
                        ],
                        if (booking.status == 'COMPLETED' &&
                            !booking.feedbackSubmitted) ...[
                          Container(
                            key: _feedbackKey,
                            child: VelvetButton(
                              label: l10n.meetingFeedbackTitle,
                              onPressed: () => _showFeedback(booking),
                            ),
                          ),
                        ],
                        const SizedBox(height: 16),
                        VelvetButton(
                          label: l10n.panicButton,
                          variant: VelvetButtonVariant.danger,
                          icon: Icons.emergency_outlined,
                          loading: _actioning,
                          onPressed: _actioning
                              ? null
                              : () async {
                                  final send = await showEditorialConfirm(
                                    context: context,
                                    title: l10n.panicButton,
                                    message: l10n.panicConfirm,
                                    confirmLabel: l10n.panicButton,
                                    cancelLabel: l10n.close,
                                    destructive: true,
                                  );
                                  if (send != true) return;
                                  setState(() => _actioning = true);
                                  try {
                                    final pos =
                                        await LocationHelper.currentOrNull();
                                    await ref
                                        .read(safetyApiProvider)
                                        .panic(
                                          bookingId: booking.id,
                                          connectionId: widget.connectionId,
                                          note: 'Panic from booking screen',
                                          latitude: pos?.latitude,
                                          longitude: pos?.longitude,
                                        );
                                    if (context.mounted) {
                                      await showEditorialDialog<void>(
                                        context: context,
                                        title: l10n.panicSent,
                                        message: l10n.panicSentDetails,
                                        icon: Icons.check_circle_outline_rounded,
                                        iconColor: VelvetTheme.teal,
                                        actions: [
                                          EditorialDialogAction(
                                            label: l10n.close,
                                            primary: true,
                                            onPressed: () =>
                                                Navigator.pop(context),
                                          ),
                                        ],
                                      );
                                    }
                                  } catch (e) {
                                    if (context.mounted) {
                                      showVelvetErrorToast(
                                        context,
                                        message: apiErrorMessage(e),
                                      );
                                    }
                                  } finally {
                                    if (mounted) {
                                      setState(() => _actioning = false);
                                    }
                                  }
                                },
                        ),
                      ] else ...[
                        Container(
                          key: _planKey,
                          child: Text(
                            l10n.meetupPlace,
                            style: Theme.of(context).textTheme.titleSmall,
                          ),
                        ),
                        const SizedBox(height: 8),
                        VelvetField(
                          controller: _meetupCtrl,
                          label: l10n.meetupPlaceHint,
                        ),
                        const SizedBox(height: 14),
                        Text(
                          l10n.filterIntent,
                          style: Theme.of(context).textTheme.titleSmall,
                        ),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          children: [
                            ChoiceChip(
                              label: Text(l10n.rateTypeSession),
                              selected: _rateType == 'SESSION',
                              onSelected: (_) =>
                                  setState(() => _rateType = 'SESSION'),
                            ),
                            ChoiceChip(
                              label: Text(l10n.rateTypeOvernight),
                              selected: _rateType == 'OVERNIGHT',
                              onSelected: (_) =>
                                  setState(() => _rateType = 'OVERNIGHT'),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          l10n.availabilityUpcoming,
                          style: Theme.of(context).textTheme.titleSmall,
                        ),
                        const SizedBox(height: 6),
                        if (_windows.isEmpty)
                          Text(
                            l10n.bookingNoAvailability,
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(color: VelvetTheme.danger),
                          )
                        else
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: _windows.take(8).map((w) {
                              final selected =
                                  !_startsAt.isBefore(w.startsAt.toUtc()) &&
                                  _startsAt.isBefore(w.endsAt.toUtc());
                              final label =
                                  '${DateFormat.MMMd().add_jm().format(w.startsAt)} · ${DateFormat.jm().format(w.endsAt)}';
                              return ChoiceChip(
                                label: Text(
                                  label,
                                  style: const TextStyle(fontSize: 12),
                                ),
                                selected: selected,
                                onSelected: (_) => setState(() {
                                  _startsAt = w.startsAt.toUtc();
                                }),
                              );
                            }).toList(),
                          ),
                        const SizedBox(height: 12),
                        InkWell(
                          onTap: _windows.isEmpty ? null : _pickTime,
                          borderRadius: BorderRadius.circular(10),
                          child: InputDecorator(
                            decoration: InputDecoration(
                              labelText: l10n.meetingTime,
                            ),
                            child: Text(
                              _meetingTime(_startsAt, locale),
                              style: GoogleFonts.inter(),
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                        VelvetButton(
                          label: l10n.proposeBooking,
                          loading: _actioning,
                          onPressed: (_actioning || _windows.isEmpty)
                              ? null
                              : _propose,
                        ),
                      ],
                    ],
                  ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BookingNextStepCard extends StatelessWidget {
  const _BookingNextStepCard({
    super.key,
    required this.booking,
    required this.canConfirm,
    required this.emphasis,
    required this.onOpenChat,
    required this.onPay,
    required this.onConfirm,
  });

  final BookingItem booking;
  final bool canConfirm;
  final bool emphasis;
  final VoidCallback onOpenChat;
  final VoidCallback? onPay;
  final VoidCallback? onConfirm;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final requiresPay = booking.needsPayment;
    final needsConfirm = booking.status == 'PROPOSED' && canConfirm;
    final canCheckIn = booking.status == 'CONFIRMED';
    final title = requiresPay
        ? l10n.flowNextPayTitle
        : needsConfirm
        ? l10n.flowNextConfirmTitle
        : canCheckIn
        ? l10n.flowNextArriveTitle
        : l10n.flowNextChatTitle;
    final body = requiresPay
        ? l10n.flowNextPayBody
        : needsConfirm
        ? l10n.flowNextConfirmBody
        : canCheckIn
        ? l10n.flowNextArriveBody
        : l10n.flowNextChatBody;
    final ctaLabel = requiresPay
        ? l10n.payBooking
        : needsConfirm
        ? l10n.confirmBooking
        : l10n.openChat;
    final ctaAction = requiresPay
        ? onPay
        : (needsConfirm ? onConfirm : onOpenChat);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(
          color: emphasis ? VelvetTheme.orangeSoft : VelvetTheme.teal.withValues(alpha: 0.26),
          width: emphasis ? 2.0 : 1.0,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: VelvetTheme.softLift,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 38,
                height: 38,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: VelvetTheme.teal.withValues(alpha: 0.16),
                  border: Border.all(
                    color: VelvetTheme.champagne.withValues(alpha: 0.34),
                  ),
                ),
                child: Icon(
                  requiresPay
                      ? Icons.lock_outline_rounded
                      : needsConfirm
                      ? Icons.verified_outlined
                      : Icons.forum_outlined,
                  color: VelvetTheme.champagne,
                  size: 19,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      body,
                      style: Theme.of(
                        context,
                      ).textTheme.bodySmall?.copyWith(color: context.velvet.muted),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          VelvetButton(
            label: ctaLabel,
            icon: requiresPay || needsConfirm
                ? Icons.arrow_forward_rounded
                : Icons.chat_bubble_outline_rounded,
            onPressed: ctaAction,
          ),
        ],
      ),
    );
  }
}

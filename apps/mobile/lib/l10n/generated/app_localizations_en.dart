// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appName => 'VELVET';

  @override
  String get tagline =>
      'Verified women. Electric chemistry. Private nights on your terms.';

  @override
  String get inviteCode => 'Invite code';

  @override
  String get phoneNumber => 'Phone number';

  @override
  String get phoneHint => '+2519…';

  @override
  String get continueLabel => 'Continue';

  @override
  String get otpTitle => 'Enter verification code';

  @override
  String otpSubtitle(String phone) {
    return 'We sent a code to $phone';
  }

  @override
  String get verify => 'Verify';

  @override
  String get profile => 'Profile';

  @override
  String get signOut => 'Sign out';

  @override
  String get language => 'Language';

  @override
  String get displayName => 'Display name';

  @override
  String get save => 'Save';

  @override
  String get errorGeneric => 'Something went wrong. Please try again.';

  @override
  String get retry => 'Try again';

  @override
  String get statusAwaitingYou => 'Awaiting you';

  @override
  String get statusPending => 'Pending';

  @override
  String get statusConnected => 'Connected';

  @override
  String get statusDeclined => 'Declined';

  @override
  String get statusExpired => 'Expired';

  @override
  String get statusConfirmed => 'Confirmed';

  @override
  String get statusCheckedIn => 'Checked in';

  @override
  String get statusCompleted => 'Completed';

  @override
  String get statusCancelled => 'Cancelled';

  @override
  String get statusNoShow => 'No-show';

  @override
  String get statusVerified => 'Verified';

  @override
  String devOtpHint(String code) {
    return 'Dev OTP: $code';
  }

  @override
  String get verificationTitle => 'Verification';

  @override
  String get verificationNone => 'You have not submitted verification yet.';

  @override
  String get verificationStatus => 'Status';

  @override
  String get verificationHint =>
      'Upload government ID and a live selfie. Only verified adults can book or list.';

  @override
  String get verificationReviewHint =>
      'Reviews are completed by the VELVET team. We will notify you when your status changes.';

  @override
  String get verificationSubmittedPending =>
      'Submitted for review. You do not need to upload again while it is being reviewed.';

  @override
  String get verificationApproved => 'Your identity has been verified.';

  @override
  String get verificationRejected =>
      'Your submission needs another look. Review the note below, then upload clear new photos and submit again.';

  @override
  String get idDocumentUrl => 'ID document URL';

  @override
  String get selfieUrl => 'Selfie URL';

  @override
  String get submitVerification => 'Submit for review';

  @override
  String get acceptRequest => 'Accept request';

  @override
  String get declineRequest => 'Decline';

  @override
  String get waitingCounterpart => 'Waiting for the other member';

  @override
  String get openChat => 'Chat';

  @override
  String get bookVenue => 'Book meetup';

  @override
  String get chatTitle => 'Conversation';

  @override
  String get chatHint =>
      'Start with the spark, then agree on the experience, rate, place, timing, and boundaries.';

  @override
  String get bookingTitle => 'Your private night';

  @override
  String get bookingHint =>
      'Build the night you both want: agree on the setting, timing, rate, and boundaries in chat. Mutual consent is essential.';

  @override
  String get bookingStatus => 'Status';

  @override
  String get selectVenue => 'Meetup place';

  @override
  String get meetingTime => 'Meeting time';

  @override
  String get proposeBooking => 'Propose booking';

  @override
  String get confirmBooking => 'Confirm booking';

  @override
  String get upload => 'Upload';

  @override
  String get uploaded => 'Uploaded';

  @override
  String get notUploaded => 'Not uploaded yet';

  @override
  String get takePhoto => 'Take photo';

  @override
  String get chooseGallery => 'Choose from gallery';

  @override
  String get uploadBothRequired => 'Upload both ID and selfie first.';

  @override
  String get checkIn => 'Check in';

  @override
  String get checkOut => 'Complete meeting';

  @override
  String get panicButton => 'Panic';

  @override
  String get panicConfirm => 'Alert concierge immediately?';

  @override
  String get panicSent => 'Concierge has been alerted.';

  @override
  String get panicSentDetails =>
      'Your alert was sent with your available location. If you are in immediate danger, call local emergency services now.';

  @override
  String get membershipTitle => 'Membership';

  @override
  String get membershipHint =>
      'Discover verified women, feel out the chemistry, and send private booking requests each month.';

  @override
  String get telebirrOnly => 'Pay securely with Telebirr';

  @override
  String get payWithTelebirr => 'Pay with Telebirr';

  @override
  String get cbePayHint =>
      'Pay by CBE transfer, then upload your receipt screenshot for automatic verification.';

  @override
  String get payWithCbe => 'Pay with CBE';

  @override
  String get cbeTransferTitle => 'Transfer to VELVET';

  @override
  String get cbeBank => 'Bank';

  @override
  String get cbeAccountName => 'Account name';

  @override
  String get cbeAccountNumber => 'Account number';

  @override
  String get amount => 'Amount';

  @override
  String get orderId => 'Order';

  @override
  String get uploadCbeReceipt => 'Upload CBE receipt screenshot';

  @override
  String get cbePaymentVerified => 'Payment verified — membership activated.';

  @override
  String get cbeMockComplete => 'Simulate verified payment (dev)';

  @override
  String get copied => 'Copied';

  @override
  String get activePlan => 'Active plan';

  @override
  String get renews => 'Valid until';

  @override
  String get bookingRequestsPerMonth => 'booking requests / month';

  @override
  String get unlimitedBookingRequests => 'Unlimited booking requests';

  @override
  String get days => 'days';

  @override
  String get telebirrMockPaid => 'Telebirr mock payment completed.';

  @override
  String get telebirrOpenFailed => 'Could not open Telebirr checkout.';

  @override
  String get reportUser => 'Report';

  @override
  String get reportHint => 'Describe what happened';

  @override
  String get reportSubmit => 'Submit report';

  @override
  String get reportSent => 'Report submitted to concierge.';

  @override
  String get openerRequired => 'Start with a suggested opener';

  @override
  String get noActiveMembership => 'No active membership';

  @override
  String get messagePendingReview => 'Pending safety review';

  @override
  String get profilePhotos => 'Photos';

  @override
  String get addPhoto => 'Add';

  @override
  String get photoAdded => 'Photo added';

  @override
  String get removePhoto => 'Remove photo';

  @override
  String get removePhotoConfirm =>
      'Remove this profile photo? This cannot be undone.';

  @override
  String get photoPendingReview => 'Photo uploaded — pending quality review.';

  @override
  String get notificationsTitle => 'Notifications';

  @override
  String get notificationsEmpty => 'No notifications yet';

  @override
  String get markAllRead => 'Mark all read';

  @override
  String get blockUser => 'Block';

  @override
  String get blockConfirm =>
      'Block this member? Open conversations and chat will close.';

  @override
  String get blockDone => 'Member blocked';

  @override
  String get cancelBooking => 'Cancel meeting';

  @override
  String get cancelBookingConfirm =>
      'Cancel this venue meeting? Your conversation partner and venue will be notified.';

  @override
  String get bookingCancelled => 'Meeting cancelled';

  @override
  String get connectionHistoryTitle => 'Past connections';

  @override
  String get connectionHistoryEmpty => 'No past connections yet';

  @override
  String get withdrawAccount => 'Close account';

  @override
  String get withdrawConfirm =>
      'This withdraws your membership access. You will be signed out.';

  @override
  String get waitlistTitle => 'Request an invite';

  @override
  String get waitlistCta => 'No invite yet? Join the waitlist';

  @override
  String get waitlistHint =>
      'VELVET is a discreet, invite-only space for adults seeking real chemistry. Tell us a little about yourself and we will review your application.';

  @override
  String get waitlistCity => 'City';

  @override
  String get waitlistNote => 'Why you\'d like to join';

  @override
  String get waitlistSubmit => 'Submit application';

  @override
  String get waitlistThanks => 'You\'re on the list';

  @override
  String get waitlistThanksBody =>
      'We\'ll reach out with an invite if approved. Keep your phone nearby.';

  @override
  String get reportCategory => 'Category';

  @override
  String get rescheduleBooking => 'Reschedule';

  @override
  String get meetingCompleted => 'Completed meeting';

  @override
  String get renewSoon =>
      'Membership ending soon — renew to keep browsing and requesting bookings.';

  @override
  String get renewNow => 'Renew membership';

  @override
  String daysRemaining(int days) {
    return '$days days remaining';
  }

  @override
  String get exportMyData => 'Export my data';

  @override
  String get eraseMyData => 'Erase my data';

  @override
  String get eraseConfirm =>
      'This permanently anonymizes your account beyond closing it. You will be signed out.';

  @override
  String get legalMustAccept =>
      'Please accept the Terms, Privacy Policy, and Community Guidelines to continue.';

  @override
  String get legalAcceptPrefix => 'I am 21+, and I agree to the';

  @override
  String get legalAnd => 'and';

  @override
  String get termsOfService => 'Terms of Service';

  @override
  String get privacyPolicy => 'Privacy Policy';

  @override
  String get communityGuidelines => 'Community Guidelines';

  @override
  String get legalMarketplaceNotice =>
      'VELVET is a 21+ adult marketplace. Bookings are between consenting adults — coercion and anyone under 21 are banned.';

  @override
  String get legalUpdateTitle => 'Updated legal terms';

  @override
  String get legalUpdateBody =>
      'Please review and accept the current Terms, Privacy Policy, and Community Guidelines to continue using VELVET.';

  @override
  String get legalAcceptCta => 'I accept';

  @override
  String get dateOfBirth => 'Date of birth';

  @override
  String get bioEn => 'Bio (English)';

  @override
  String get bioAm => 'Bio (Amharic)';

  @override
  String get city => 'City';

  @override
  String get ageRequirement => 'Members must be 21 or older.';

  @override
  String get legalDocuments => 'Legal documents';

  @override
  String get close => 'Close';

  @override
  String get chatOpensSoon =>
      'Chat opens once you\'re connected — arrange your booking there.';

  @override
  String get chatWindowClosed =>
      'This conversation is closed. Messages are removed after the meeting window.';

  @override
  String get chatMessageHint => 'Set the mood — respectfully…';

  @override
  String get attachPhoto => 'Photo';

  @override
  String get attachVideo => 'Video';

  @override
  String get attachAudio => 'Audio file';

  @override
  String get attachFile => 'File';

  @override
  String get holdVoiceNote => 'Hold to record a voice note';

  @override
  String get navMembership => 'Membership';

  @override
  String get navSessionPayments => 'Payments';

  @override
  String get sessionPaymentsTitle => 'Session payments';

  @override
  String get sessionPaymentsSubtitle =>
      'No subscription. Pay only when you book.';

  @override
  String get sessionPaymentsHeading => 'Pay for the time you choose';

  @override
  String get sessionPaymentsBody =>
      'Browsing and connecting are free. Once you and a performer agree on a session, confirm the rate and pay securely for that individual booking.';

  @override
  String get navProfile => 'Profile';

  @override
  String get safetyTitle => 'Safety';

  @override
  String get navBrowse => 'Browse';

  @override
  String get navConversations => 'Conversations';

  @override
  String get navRequests => 'Requests';

  @override
  String get segmentIntros => 'Concierge';

  @override
  String get segmentListings => 'Listings';

  @override
  String get segmentRequests => 'Requests';

  @override
  String get filtersTitle => 'Filters';

  @override
  String get ageRange => 'Age range';

  @override
  String get maxDistance => 'Max distance';

  @override
  String get citiesFilterHint => 'Cities (comma-separated, optional)';

  @override
  String get discoverEmpty =>
      'No verified listings match your filters right now.';

  @override
  String get discoverEmptyCta => 'Adjust filters';

  @override
  String get conversationsInboxTitle => 'Conversations';

  @override
  String get conversationsInboxEmpty =>
      'No active conversations yet. Discover someone who moves you, or respond to a request that feels right.';

  @override
  String get conversationsInboxEmptyCtaDiscover => 'Find your spark';

  @override
  String get conversationsInboxEmptyCtaRequests => 'Open requests';

  @override
  String get conversationsInboxHint =>
      'Your turn means she is waiting to hear what you have in mind.';

  @override
  String get conversationsEmptyPreview =>
      'Begin with the mood, then talk details.';

  @override
  String get yourTurn => 'Your turn';

  @override
  String get theirTurn => 'Their turn';

  @override
  String get sayHello => 'Message';

  @override
  String get replyNow => 'Reply now';

  @override
  String get suggestedOpener => 'Suggested opener';

  @override
  String get sendOpener => 'Send it';

  @override
  String get typingIndicator => 'Typing…';

  @override
  String get messageRead => 'Read';

  @override
  String get clientRequestsEmpty =>
      'No client requests yet. Keep your listing, rates, and calendar updated.';

  @override
  String get clientRequestsEmptyCta => 'Open Concierge';

  @override
  String get introsEmpty => 'No concierge referrals right now.';

  @override
  String get introsEmptyCta => 'Edit listing';

  @override
  String get chatEmptyHint =>
      'Create comfort and anticipation first, then agree on the experience, rate, setting, and timing.';

  @override
  String get connectionConfirmedTitle => 'The feeling is mutual';

  @override
  String get connectionConfirmedBody =>
      'You can now talk privately and shape a night that feels right for both of you.';

  @override
  String connectionConfirmedWith(String name) {
    return 'You and $name chose to connect.';
  }

  @override
  String get connectionConfirmedNext =>
      'Let the conversation build, then agree on the setting, time, rate, and boundaries together.';

  @override
  String get keepBrowsing => 'Keep exploring';

  @override
  String get requestNotedPhoto => 'Noted your listing photo';

  @override
  String get requestNotedPrompt => 'Noted your listing prompt';

  @override
  String get genderMale => 'Man — Client';

  @override
  String get genderFemale => 'Woman — Performer';

  @override
  String get genderRequiredHint =>
      'Set your role in Profile. Clients browse listings; performers respond to requests.';

  @override
  String get womenReceiveOnly =>
      'Performers do not browse listings. Open Requests to respond to interested clients.';

  @override
  String get genderLabel => 'Gender';

  @override
  String get filterAreas => 'Addis areas';

  @override
  String get filterLanguages => 'Languages';

  @override
  String get filterIntent => 'Booking type';

  @override
  String get filterVerifiedOnly => 'Verified only';

  @override
  String get languageAmharic => 'Amharic';

  @override
  String get languageEnglish => 'English';

  @override
  String get intentSerious => 'Overnight';

  @override
  String get intentSocial => 'Evening';

  @override
  String get recentPassesTitle => 'Recently skipped';

  @override
  String get recentPassesHint =>
      'Last 5 listings you skipped — restore any one.';

  @override
  String get recentPassesEmpty => 'No recently skipped listings.';

  @override
  String get rewindPass => 'Restore';

  @override
  String get passRewound => 'Listing restored to your browse feed.';

  @override
  String get interestSent =>
      'Your interest is in. If she feels the connection too, you can begin planning together.';

  @override
  String get requestBooking => 'Send discreet interest';

  @override
  String get skipListing => 'Skip';

  @override
  String get clientRequestHint =>
      'He is interested in getting to know your energy';

  @override
  String get someoneLabel => 'Member';

  @override
  String listingDistanceKm(int km) {
    return '$km km away';
  }

  @override
  String get discoverSubtitleClient =>
      'Verified women, distinct energy, and nights worth anticipating';

  @override
  String get discoverSubtitlePerformer =>
      'Client requests waiting on your response';

  @override
  String get discoverSubtitleLocked =>
      'Set your role to browse listings or receive requests';

  @override
  String get chatSendHint => 'Say what you want…';

  @override
  String get genderSetupTitle => 'How are you joining?';

  @override
  String get genderSetupBody =>
      'Clients (men) browse verified performers and request private bookings. Performers (women) list rates and respond to interested clients.';

  @override
  String get genderMustSelect =>
      'Please select Client or Performer to continue.';

  @override
  String get profileDetails => 'Profile details';

  @override
  String get interestsLabel => 'Listing tags';

  @override
  String get interestsHint => 'Pick tags clients use to find your listing.';

  @override
  String get blockedMembers => 'Blocked members';

  @override
  String get blockedEmpty => 'You haven’t blocked anyone.';

  @override
  String get unblock => 'Unblock';

  @override
  String get unblocked => 'Member unblocked';

  @override
  String get openInMaps => 'Open in maps';

  @override
  String get venueAddress => 'Address';

  @override
  String meetingCountdown(int hours, int minutes) {
    return 'Meeting in ${hours}h ${minutes}m';
  }

  @override
  String get meetingNow => 'Meeting window is open';

  @override
  String get chatBookCta => 'Plan private booking';

  @override
  String get staffPortalMemberNavHint =>
      'Staff accounts use the web console — not Browse, Requests, or Conversations.';

  @override
  String get staffConsoleHint =>
      'Review members, connections, safety reports and operations.';

  @override
  String get adminConsole => 'Administrator console';

  @override
  String get adminConsoleHint =>
      'Manage members, verification, venues, reporting and platform operations.';

  @override
  String get conciergeConsole => 'Concierge console';

  @override
  String get conciergeConsoleHint =>
      'Coordinate referrals, member care and safety follow-up.';

  @override
  String get accessLevel => 'Access level';

  @override
  String get partnerPortal => 'Partner portal';

  @override
  String get partnerPortalHint =>
      'Manage venue bookings, check-ins and partner operations.';

  @override
  String get consoleBrowserHint =>
      'The console opens in your browser and uses its own secure staff sign-in.';

  @override
  String get openConsole => 'Open console';

  @override
  String get consoleOpenFailed =>
      'Could not open the console. Please try again.';

  @override
  String get profileSetupTitle => 'Finish your profile';

  @override
  String get profileSetupBody =>
      'Lead with the energy only you bring. Three photos and a magnetic bio help the right clients choose you.';

  @override
  String profileSetupPhotos(Object count) {
    return '$count photos';
  }

  @override
  String get profileSetupRequired =>
      'Add 3 photos, your city, and both listing summaries to continue.';

  @override
  String get promptListingEn => 'Describe your private-night energy (English)';

  @override
  String get promptListingAm => 'Describe your private-night energy (Amharic)';

  @override
  String get promptAnswerEn => 'What makes time with you unforgettable?';

  @override
  String get promptAnswerAm =>
      'What makes time with you unforgettable? (Amharic)';

  @override
  String get profileSetupFinish => 'I’m ready';

  @override
  String get profileReadyTitle => 'Your energy is live';

  @override
  String get profileReadyBody =>
      'Your profile is ready to attract the clients who are looking for exactly your kind of presence.';

  @override
  String get startDiscovering => 'Explore the chemistry';

  @override
  String get profileDetailsOptional => 'Listing details (optional)';

  @override
  String get profileClientHint =>
      'Clients only need basics here — browse listings and request bookings from the Browse tab.';

  @override
  String get profileListingSection => 'Your listing';

  @override
  String get membershipBenefitBrowse =>
      'Browse verified women, their energy, rates, and availability';

  @override
  String get membershipBenefitRequests =>
      'Send discreet interest requests to the women who catch your eye';

  @override
  String get membershipBenefitBook =>
      'Chat, find the chemistry, and plan a private night when connected';

  @override
  String get membershipPlanIncludes => 'Includes';

  @override
  String get languagesSpoken => 'Languages spoken';

  @override
  String get languagesSpokenHint => 'e.g. Amharic, English';

  @override
  String get listingTagsLabel => 'Listing tags';

  @override
  String get listingTagsHint => 'Tags shown on your listing card in browse.';

  @override
  String get sessionRateEtb => 'Session rate (ETB)';

  @override
  String get overnightRateEtb => 'Overnight rate (ETB)';

  @override
  String get availabilityNote => 'When you are open to connect';

  @override
  String get listingActive => 'Show my listing to clients';

  @override
  String rateSessionLabel(int amount) {
    return 'From $amount ETB / private session';
  }

  @override
  String rateOvernightLabel(int amount) {
    return '$amount ETB / overnight';
  }

  @override
  String get performerRatesSection => 'Listing rates';

  @override
  String get performerRatesHint =>
      'Clients see these beside your listing. Leave blank if you prefer to discuss the details once the chemistry is there.';

  @override
  String get safetyCenterTitle => 'Safety center';

  @override
  String get safetyCenterHint =>
      'Panic, block, report, share your trip with concierge, and see verified venues — in one place.';

  @override
  String get shareTripWithVelvet => 'Share trip with Velvet';

  @override
  String get tripSharedSnack => 'Concierge notified — safe travels.';

  @override
  String get verifiedVenues => 'Verified venues';

  @override
  String get verifiedVenuesEmpty => 'Verified venues will appear here.';

  @override
  String get reportMember => 'Report';

  @override
  String get reportSubmitted => 'Report sent to concierge.';

  @override
  String get addToCalendar => 'Add to calendar';

  @override
  String get timelinePropose => 'Propose';

  @override
  String get timelineConfirm => 'Confirm';

  @override
  String get timelineReminder => 'Reminder';

  @override
  String get timelineCheckIn => 'Check-in';

  @override
  String get timelineCheckout => 'Checkout';

  @override
  String get vibeQuiet => 'Quiet';

  @override
  String get vibeBalanced => 'Balanced';

  @override
  String get vibeLively => 'Lively';

  @override
  String get meetingFeedbackTitle => 'How was the meeting?';

  @override
  String get meetingFeedbackHint =>
      'Quick answers help Velvet keep bookings safe.';

  @override
  String get feltSafe => 'Felt safe?';

  @override
  String get wouldBookAgain => 'Would book again?';

  @override
  String get venueOk => 'Venue okay?';

  @override
  String get optionalNotes => 'Notes (optional)';

  @override
  String get submitFeedback => 'Submit';

  @override
  String get feedbackThanks => 'Thank you — that helps.';

  @override
  String get bookingProposedSnack =>
      'Your private-night plan is ready for her review.';

  @override
  String get bookingConfirmedSnack => 'Your private night is confirmed.';

  @override
  String get cbeStepAmount => '1 · Amount';

  @override
  String get cbeStepAccount => '2 · Transfer';

  @override
  String get cbeStepReceipt => '3 · Receipt';

  @override
  String get cbeVerifyEta =>
      'Usually verified within 30–60 minutes during business hours.';

  @override
  String get cbeMockLabel => 'Mock payment (dev)';

  @override
  String get cbeLiveLabel => 'Live CBE transfer';

  @override
  String get lowBandwidthMode => 'Low-bandwidth mode';

  @override
  String get lowBandwidthHint =>
      'Smaller photos, less autoplay — better on slow networks.';

  @override
  String get shareInviteWhatsApp => 'Share invite on WhatsApp';

  @override
  String get shareInviteWhatsAppGeneric =>
      'Join VELVET — Addis\'s discreet, verified space for adult chemistry and private nights. Ask me for an invite.';

  @override
  String shareInviteWhatsAppWithCode(String code) {
    return 'You are invited to VELVET, a discreet space for verified adult connection. Open the app and enter invite code $code with your +251 number.';
  }

  @override
  String get shareWaitlistWhatsAppGeneric =>
      'Join me on the VELVET waitlist — Addis\'s discreet, verified space for adult chemistry and private nights.';

  @override
  String shareWaitlistWhatsAppWithCode(String code) {
    return 'You\'re invited to VELVET. Use code $code with your +251 phone in the app.';
  }

  @override
  String waitlistFriendsApproved(int count) {
    return '$count friends approved';
  }

  @override
  String get waitlistStatusPending =>
      'You’re on the list — we’ll text when you’re in.';

  @override
  String get waitlistStatusApproved =>
      'You’re approved. Use your invite code to join.';

  @override
  String get waitlistCheckStatus => 'Check status';

  @override
  String get reorderPhotosHint =>
      'Long-press a photo to reorder. First photo is your cover.';

  @override
  String get photosReordered => 'Photo order saved.';

  @override
  String get makeCoverPhoto => 'Make cover';

  @override
  String get meetupPlace => 'Hotel / suite / meetup place';

  @override
  String get meetupPlaceHint => 'e.g. private suite · details agreed together';

  @override
  String get rateTypeSession => 'Evening / session';

  @override
  String get rateTypeOvernight => 'Overnight';

  @override
  String bookingAmount(int amount) {
    return '$amount ETB';
  }

  @override
  String get payBooking => 'Pay booking';

  @override
  String get bookingPaid =>
      'Payment confirmed — your private-night plan is secured.';

  @override
  String get paymentStatusLabel => 'Payment';

  @override
  String get paymentUnpaid => 'Unpaid';

  @override
  String get paymentPending => 'Payment pending';

  @override
  String get paymentPaid => 'Paid';

  @override
  String get paymentWaived => 'No charge';

  @override
  String get earningsTitle => 'Earnings';

  @override
  String earningsHint(int percent) {
    return 'You keep $percent% of each paid booking. Platform fee covers payments and safety ops.';
  }

  @override
  String get earningsAvailable => 'Available balance';

  @override
  String get earningsLifetime => 'Lifetime earned';

  @override
  String get earningsPaidOut => 'Paid out';

  @override
  String get earningsActivity => 'Activity';

  @override
  String get earningsEmpty =>
      'No earnings yet — paid bookings credit your balance here.';

  @override
  String get earningsCredit => 'Booking credit';

  @override
  String get earningsPayout => 'Payout';

  @override
  String get requestPayout => 'Request payout';

  @override
  String get payoutAmount => 'Amount (ETB)';

  @override
  String get payoutDestination => 'CBE / Telebirr account note';

  @override
  String get payoutMinAmount => 'Minimum payout is 50 ETB.';

  @override
  String get payoutRequested => 'Payout requested — concierge will process it.';

  @override
  String get listingRequiresVerification =>
      'ID verification must be approved before clients can see your listing.';

  @override
  String get verifyToListCta => 'Verify ID to go live';

  @override
  String get availabilityCalendarTitle => 'Availability calendar';

  @override
  String get availabilityCalendarHint =>
      'Choose the moments you are open to connect. Clients can only request time inside your published windows.';

  @override
  String get availabilityDay => 'Day';

  @override
  String get availabilityStart => 'Starts';

  @override
  String get availabilityEnd => 'Ends';

  @override
  String get availabilityWindowNote => 'Note (optional)';

  @override
  String get availabilityAddWindow => 'Add window';

  @override
  String get availabilityUpcoming => 'Upcoming windows';

  @override
  String get availabilityEmpty =>
      'No open moments yet — add the evenings or overnight windows that work for you.';

  @override
  String get availabilityAdded => 'Availability window added.';

  @override
  String get availabilityMustBeFuture => 'Start time must be in the future.';

  @override
  String get navListing => 'Listing';

  @override
  String get membershipRequiredBrowse =>
      'Membership is required to browse verified performers.';

  @override
  String get bookingNoAvailability =>
      'No open availability windows — ask her to publish times, or try later.';

  @override
  String get performerReadyTitle => 'Go live';

  @override
  String get performerReadyHint =>
      'Finish these steps so clients can find and book you.';

  @override
  String get readyStepVerify => 'Verify your ID';

  @override
  String get readyStepVerifyDone =>
      'Verified — clients can trust your listing.';

  @override
  String get readyStepVerifyTodo => 'Upload ID + selfie for admin review.';

  @override
  String get readyStepRates => 'Set your rates';

  @override
  String readyStepRatesDone(int session, int overnight) {
    return 'Session $session ETB · Overnight $overnight ETB';
  }

  @override
  String get readyStepRatesTodo =>
      'Add session and/or overnight rates on your profile.';

  @override
  String get readyStepCalendar => 'Publish availability';

  @override
  String readyStepCalendarDone(int count) {
    return '$count open windows';
  }

  @override
  String get readyStepCalendarTodo =>
      'Add evenings or overnight blocks clients can book.';

  @override
  String get readyStepPhotos => 'Add listing photos';

  @override
  String readyStepPhotosDone(int count) {
    return '$count photos on your listing';
  }

  @override
  String get readyStepPhotosTodo =>
      'Upload at least 3 photos clients can browse.';

  @override
  String get readyStepListing => 'Write your listing summary';

  @override
  String get readyStepListingDone => 'English and Amharic summaries are set.';

  @override
  String get readyStepListingTodo =>
      'Add both listing summaries on your profile.';

  @override
  String readyProgressLabel(int done, int total) {
    return '$done of $total complete';
  }

  @override
  String get readyGoLiveHint =>
      'Turn on when you\'re ready to appear in Browse.';

  @override
  String get readyFinishStepsFirst =>
      'Complete verification, rates, and calendar first.';

  @override
  String get readyLiveBanner =>
      'Your listing is live — the right clients can discover your energy and send discreet interest.';

  @override
  String get listingNowLive => 'Listing is live.';

  @override
  String get listingNowHidden => 'Listing hidden from clients.';

  @override
  String get flowNextBookTitle => 'Next best move: turn chemistry into a plan';

  @override
  String get flowNextBookBody =>
      'Open the booking and agree on the time, setting, rate, and boundaries while the connection feels alive.';

  @override
  String get flowNextPayTitle => 'Next best move: complete payment';

  @override
  String get flowNextPayBody =>
      'Payment secures the plan, leaving both of you free to focus on the anticipation.';

  @override
  String get flowNextConfirmTitle => 'Next best move: confirm details';

  @override
  String get flowNextConfirmBody =>
      'Confirm this booking now, then finalize details in chat.';

  @override
  String get flowNextChatTitle => 'Next best move: build the anticipation';

  @override
  String get flowNextChatBody =>
      'Open chat to confirm the mood, rate, place, timing, and boundaries you both want.';

  @override
  String get flowNextArriveTitle => 'Next best move: arrive smoothly';

  @override
  String get flowNextArriveBody =>
      'Share trip or check in when you are near the meetup.';

  @override
  String get flowFocusConfirmHint =>
      'Confirm this now to keep the booking on track.';

  @override
  String get flowFocusPayHint =>
      'Complete payment now so the booking is fully secured.';

  @override
  String get flowFocusPayDoneHint =>
      'Payment is confirmed. Move to chat and finalize the plan.';

  @override
  String get quickBookNow => 'Book now';

  @override
  String get quickSendRatePrompt => 'Send rate prompt';

  @override
  String get quickSendBookingSummary => 'Send booking summary';

  @override
  String get quickSendCheckinLineLabel => 'Send check-in line';

  @override
  String get quickSendAftercareLineLabel => 'Send aftercare line';

  @override
  String get quickAskPlace => 'Ask place';

  @override
  String get quickRatePromptLine =>
      'What kind of private experience are you open to, and what rate feels right for you?';

  @override
  String get quickPlacePromptLine =>
      'What setting would make tonight feel right for you?';

  @override
  String get quickBookingSummaryLine => 'Here is the night I have in mind:';

  @override
  String get quickSendCheckinLine =>
      'I\'m checked in now. Come when you\'re ready and text me when you arrive.';

  @override
  String get quickSendAftercareLine =>
      'Thank you for tonight. If you\'d like to book again, let\'s lock the next plan.';

  @override
  String get flowPostCheckoutTitle => 'Before this closes';

  @override
  String get flowPostCheckoutBody =>
      'Leave feedback for safety, or propose your next booking while you\'re still connected.';

  @override
  String get welcomeTitle => 'Where chemistry becomes a plan';

  @override
  String get welcomeBodyClient =>
      'Browse verified women, follow the connection, and arrange a private night with clarity and consent — all in one discreet place.';

  @override
  String get welcomeBodyPerformer =>
      'Show your energy, set your terms, and respond only when the connection feels right to you.';

  @override
  String get welcomeStepBrowse => 'Follow the spark';

  @override
  String get welcomeStepBrowseBody =>
      'Explore each woman\'s photos, energy, rates, availability, and verification.';

  @override
  String get welcomeStepRequest => 'Make your interest known';

  @override
  String get welcomeStepRequestBody =>
      'Send a discreet request when someone catches your attention. She always chooses whether to connect.';

  @override
  String get welcomeStepBook => 'Shape the night';

  @override
  String get welcomeStepBookBody =>
      'Once you connect, agree on the experience, timing, place, rate, and boundaries together.';

  @override
  String get welcomeStepListing => 'Complete your listing';

  @override
  String get welcomeStepListingBody =>
      'Photos, rates, and summaries help clients trust and choose you.';

  @override
  String get welcomeStepCalendar => 'Open your calendar';

  @override
  String get welcomeStepCalendarBody =>
      'Publish evenings or overnight windows clients can book.';

  @override
  String get welcomeStepRequests => 'Respond to requests';

  @override
  String get welcomeStepRequestsBody =>
      'Accept or decline incoming interest from your Requests inbox.';

  @override
  String get welcomeCta => 'Get started';

  @override
  String get discoverCoachTitle => 'From spark to private night';

  @override
  String get discoverCoachBody =>
      'Browse the energy → send interest → build chemistry in chat → agree on your private night. Skip anything that does not feel right.';

  @override
  String get flowHintBrowse => 'Browse';

  @override
  String get flowHintRequest => 'Request';

  @override
  String get flowHintBook => 'Book';

  @override
  String get flowHintRespond => 'Respond';

  @override
  String get conversationsEmptyFlowHint =>
      'Send discreet interest when a listing catches your eye — the conversation opens only after you both choose to connect.';

  @override
  String get listingSession => 'Session';

  @override
  String get listingOvernight => 'Overnight';

  @override
  String get listingAbout => 'Energy';

  @override
  String get listingClose => 'Close';

  @override
  String listingEtbAmount(int amount) {
    return '$amount ETB';
  }
}

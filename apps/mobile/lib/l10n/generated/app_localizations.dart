import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_am.dart';
import 'app_localizations_en.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'generated/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('am'),
    Locale('en'),
  ];

  /// No description provided for @appName.
  ///
  /// In en, this message translates to:
  /// **'VELVET'**
  String get appName;

  /// No description provided for @tagline.
  ///
  /// In en, this message translates to:
  /// **'Verified women. Electric chemistry. Private nights on your terms.'**
  String get tagline;

  /// No description provided for @inviteCode.
  ///
  /// In en, this message translates to:
  /// **'Invite code'**
  String get inviteCode;

  /// No description provided for @phoneNumber.
  ///
  /// In en, this message translates to:
  /// **'Phone number'**
  String get phoneNumber;

  /// No description provided for @phoneHint.
  ///
  /// In en, this message translates to:
  /// **'+2519…'**
  String get phoneHint;

  /// No description provided for @continueLabel.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get continueLabel;

  /// No description provided for @otpTitle.
  ///
  /// In en, this message translates to:
  /// **'Enter verification code'**
  String get otpTitle;

  /// No description provided for @otpSubtitle.
  ///
  /// In en, this message translates to:
  /// **'We sent a code to {phone}'**
  String otpSubtitle(String phone);

  /// No description provided for @verify.
  ///
  /// In en, this message translates to:
  /// **'Verify'**
  String get verify;

  /// No description provided for @profile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profile;

  /// No description provided for @signOut.
  ///
  /// In en, this message translates to:
  /// **'Sign out'**
  String get signOut;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @displayName.
  ///
  /// In en, this message translates to:
  /// **'Display name'**
  String get displayName;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @errorGeneric.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong. Please try again.'**
  String get errorGeneric;

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'Try again'**
  String get retry;

  /// No description provided for @statusAwaitingYou.
  ///
  /// In en, this message translates to:
  /// **'Awaiting you'**
  String get statusAwaitingYou;

  /// No description provided for @statusPending.
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get statusPending;

  /// No description provided for @statusConnected.
  ///
  /// In en, this message translates to:
  /// **'Connected'**
  String get statusConnected;

  /// No description provided for @statusDeclined.
  ///
  /// In en, this message translates to:
  /// **'Declined'**
  String get statusDeclined;

  /// No description provided for @statusExpired.
  ///
  /// In en, this message translates to:
  /// **'Expired'**
  String get statusExpired;

  /// No description provided for @statusConfirmed.
  ///
  /// In en, this message translates to:
  /// **'Confirmed'**
  String get statusConfirmed;

  /// No description provided for @statusCheckedIn.
  ///
  /// In en, this message translates to:
  /// **'Checked in'**
  String get statusCheckedIn;

  /// No description provided for @statusCompleted.
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get statusCompleted;

  /// No description provided for @statusCancelled.
  ///
  /// In en, this message translates to:
  /// **'Cancelled'**
  String get statusCancelled;

  /// No description provided for @statusNoShow.
  ///
  /// In en, this message translates to:
  /// **'No-show'**
  String get statusNoShow;

  /// No description provided for @statusVerified.
  ///
  /// In en, this message translates to:
  /// **'Verified'**
  String get statusVerified;

  /// No description provided for @devOtpHint.
  ///
  /// In en, this message translates to:
  /// **'Dev OTP: {code}'**
  String devOtpHint(String code);

  /// No description provided for @verificationTitle.
  ///
  /// In en, this message translates to:
  /// **'Verification'**
  String get verificationTitle;

  /// No description provided for @verificationNone.
  ///
  /// In en, this message translates to:
  /// **'You have not submitted verification yet.'**
  String get verificationNone;

  /// No description provided for @verificationStatus.
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get verificationStatus;

  /// No description provided for @verificationHint.
  ///
  /// In en, this message translates to:
  /// **'Upload government ID and a live selfie. Only verified adults can book or list.'**
  String get verificationHint;

  /// No description provided for @verificationReviewHint.
  ///
  /// In en, this message translates to:
  /// **'Reviews are completed by the VELVET team. We will notify you when your status changes.'**
  String get verificationReviewHint;

  /// No description provided for @verificationSubmittedPending.
  ///
  /// In en, this message translates to:
  /// **'Submitted for review. You do not need to upload again while it is being reviewed.'**
  String get verificationSubmittedPending;

  /// No description provided for @verificationApproved.
  ///
  /// In en, this message translates to:
  /// **'Your identity has been verified.'**
  String get verificationApproved;

  /// No description provided for @verificationRejected.
  ///
  /// In en, this message translates to:
  /// **'Your submission needs another look. Review the note below, then upload clear new photos and submit again.'**
  String get verificationRejected;

  /// No description provided for @idDocumentUrl.
  ///
  /// In en, this message translates to:
  /// **'ID document URL'**
  String get idDocumentUrl;

  /// No description provided for @selfieUrl.
  ///
  /// In en, this message translates to:
  /// **'Selfie URL'**
  String get selfieUrl;

  /// No description provided for @submitVerification.
  ///
  /// In en, this message translates to:
  /// **'Submit for review'**
  String get submitVerification;

  /// No description provided for @acceptRequest.
  ///
  /// In en, this message translates to:
  /// **'Accept request'**
  String get acceptRequest;

  /// No description provided for @declineRequest.
  ///
  /// In en, this message translates to:
  /// **'Decline'**
  String get declineRequest;

  /// No description provided for @waitingCounterpart.
  ///
  /// In en, this message translates to:
  /// **'Waiting for the other member'**
  String get waitingCounterpart;

  /// No description provided for @openChat.
  ///
  /// In en, this message translates to:
  /// **'Chat'**
  String get openChat;

  /// No description provided for @bookVenue.
  ///
  /// In en, this message translates to:
  /// **'Book meetup'**
  String get bookVenue;

  /// No description provided for @chatTitle.
  ///
  /// In en, this message translates to:
  /// **'Conversation'**
  String get chatTitle;

  /// No description provided for @chatHint.
  ///
  /// In en, this message translates to:
  /// **'Start with the spark, then agree on the experience, rate, place, timing, and boundaries.'**
  String get chatHint;

  /// No description provided for @bookingTitle.
  ///
  /// In en, this message translates to:
  /// **'Your private night'**
  String get bookingTitle;

  /// No description provided for @bookingHint.
  ///
  /// In en, this message translates to:
  /// **'Build the night you both want: agree on the setting, timing, rate, and boundaries in chat. Mutual consent is essential.'**
  String get bookingHint;

  /// No description provided for @bookingStatus.
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get bookingStatus;

  /// No description provided for @selectVenue.
  ///
  /// In en, this message translates to:
  /// **'Meetup place'**
  String get selectVenue;

  /// No description provided for @meetingTime.
  ///
  /// In en, this message translates to:
  /// **'Meeting time'**
  String get meetingTime;

  /// No description provided for @proposeBooking.
  ///
  /// In en, this message translates to:
  /// **'Propose booking'**
  String get proposeBooking;

  /// No description provided for @confirmBooking.
  ///
  /// In en, this message translates to:
  /// **'Confirm booking'**
  String get confirmBooking;

  /// No description provided for @upload.
  ///
  /// In en, this message translates to:
  /// **'Upload'**
  String get upload;

  /// No description provided for @uploaded.
  ///
  /// In en, this message translates to:
  /// **'Uploaded'**
  String get uploaded;

  /// No description provided for @notUploaded.
  ///
  /// In en, this message translates to:
  /// **'Not uploaded yet'**
  String get notUploaded;

  /// No description provided for @takePhoto.
  ///
  /// In en, this message translates to:
  /// **'Take photo'**
  String get takePhoto;

  /// No description provided for @chooseGallery.
  ///
  /// In en, this message translates to:
  /// **'Choose from gallery'**
  String get chooseGallery;

  /// No description provided for @uploadBothRequired.
  ///
  /// In en, this message translates to:
  /// **'Upload both ID and selfie first.'**
  String get uploadBothRequired;

  /// No description provided for @checkIn.
  ///
  /// In en, this message translates to:
  /// **'Check in'**
  String get checkIn;

  /// No description provided for @checkOut.
  ///
  /// In en, this message translates to:
  /// **'Complete meeting'**
  String get checkOut;

  /// No description provided for @panicButton.
  ///
  /// In en, this message translates to:
  /// **'Panic'**
  String get panicButton;

  /// No description provided for @panicConfirm.
  ///
  /// In en, this message translates to:
  /// **'Alert concierge immediately?'**
  String get panicConfirm;

  /// No description provided for @panicSent.
  ///
  /// In en, this message translates to:
  /// **'Concierge has been alerted.'**
  String get panicSent;

  /// No description provided for @panicSentDetails.
  ///
  /// In en, this message translates to:
  /// **'Your alert was sent with your available location. If you are in immediate danger, call local emergency services now.'**
  String get panicSentDetails;

  /// No description provided for @membershipTitle.
  ///
  /// In en, this message translates to:
  /// **'Membership'**
  String get membershipTitle;

  /// No description provided for @membershipHint.
  ///
  /// In en, this message translates to:
  /// **'Discover verified women, feel out the chemistry, and send private booking requests each month.'**
  String get membershipHint;

  /// No description provided for @telebirrOnly.
  ///
  /// In en, this message translates to:
  /// **'Pay securely with Telebirr'**
  String get telebirrOnly;

  /// No description provided for @payWithTelebirr.
  ///
  /// In en, this message translates to:
  /// **'Pay with Telebirr'**
  String get payWithTelebirr;

  /// No description provided for @cbePayHint.
  ///
  /// In en, this message translates to:
  /// **'Pay by CBE transfer, then upload your receipt screenshot for automatic verification.'**
  String get cbePayHint;

  /// No description provided for @payWithCbe.
  ///
  /// In en, this message translates to:
  /// **'Pay with CBE'**
  String get payWithCbe;

  /// No description provided for @cbeTransferTitle.
  ///
  /// In en, this message translates to:
  /// **'Transfer to VELVET'**
  String get cbeTransferTitle;

  /// No description provided for @cbeBank.
  ///
  /// In en, this message translates to:
  /// **'Bank'**
  String get cbeBank;

  /// No description provided for @cbeAccountName.
  ///
  /// In en, this message translates to:
  /// **'Account name'**
  String get cbeAccountName;

  /// No description provided for @cbeAccountNumber.
  ///
  /// In en, this message translates to:
  /// **'Account number'**
  String get cbeAccountNumber;

  /// No description provided for @amount.
  ///
  /// In en, this message translates to:
  /// **'Amount'**
  String get amount;

  /// No description provided for @orderId.
  ///
  /// In en, this message translates to:
  /// **'Order'**
  String get orderId;

  /// No description provided for @uploadCbeReceipt.
  ///
  /// In en, this message translates to:
  /// **'Upload CBE receipt screenshot'**
  String get uploadCbeReceipt;

  /// No description provided for @cbePaymentVerified.
  ///
  /// In en, this message translates to:
  /// **'Payment verified — membership activated.'**
  String get cbePaymentVerified;

  /// No description provided for @cbeMockComplete.
  ///
  /// In en, this message translates to:
  /// **'Simulate verified payment (dev)'**
  String get cbeMockComplete;

  /// No description provided for @copied.
  ///
  /// In en, this message translates to:
  /// **'Copied'**
  String get copied;

  /// No description provided for @activePlan.
  ///
  /// In en, this message translates to:
  /// **'Active plan'**
  String get activePlan;

  /// No description provided for @renews.
  ///
  /// In en, this message translates to:
  /// **'Valid until'**
  String get renews;

  /// No description provided for @bookingRequestsPerMonth.
  ///
  /// In en, this message translates to:
  /// **'booking requests / month'**
  String get bookingRequestsPerMonth;

  /// No description provided for @unlimitedBookingRequests.
  ///
  /// In en, this message translates to:
  /// **'Unlimited booking requests'**
  String get unlimitedBookingRequests;

  /// No description provided for @days.
  ///
  /// In en, this message translates to:
  /// **'days'**
  String get days;

  /// No description provided for @telebirrMockPaid.
  ///
  /// In en, this message translates to:
  /// **'Telebirr mock payment completed.'**
  String get telebirrMockPaid;

  /// No description provided for @telebirrOpenFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not open Telebirr checkout.'**
  String get telebirrOpenFailed;

  /// No description provided for @reportUser.
  ///
  /// In en, this message translates to:
  /// **'Report'**
  String get reportUser;

  /// No description provided for @reportHint.
  ///
  /// In en, this message translates to:
  /// **'Describe what happened'**
  String get reportHint;

  /// No description provided for @reportSubmit.
  ///
  /// In en, this message translates to:
  /// **'Submit report'**
  String get reportSubmit;

  /// No description provided for @reportSent.
  ///
  /// In en, this message translates to:
  /// **'Report submitted to concierge.'**
  String get reportSent;

  /// No description provided for @openerRequired.
  ///
  /// In en, this message translates to:
  /// **'Start with a suggested opener'**
  String get openerRequired;

  /// No description provided for @noActiveMembership.
  ///
  /// In en, this message translates to:
  /// **'No active membership'**
  String get noActiveMembership;

  /// No description provided for @messagePendingReview.
  ///
  /// In en, this message translates to:
  /// **'Pending safety review'**
  String get messagePendingReview;

  /// No description provided for @profilePhotos.
  ///
  /// In en, this message translates to:
  /// **'Photos'**
  String get profilePhotos;

  /// No description provided for @addPhoto.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get addPhoto;

  /// No description provided for @photoAdded.
  ///
  /// In en, this message translates to:
  /// **'Photo added'**
  String get photoAdded;

  /// No description provided for @removePhoto.
  ///
  /// In en, this message translates to:
  /// **'Remove photo'**
  String get removePhoto;

  /// No description provided for @removePhotoConfirm.
  ///
  /// In en, this message translates to:
  /// **'Remove this profile photo? This cannot be undone.'**
  String get removePhotoConfirm;

  /// No description provided for @photoPendingReview.
  ///
  /// In en, this message translates to:
  /// **'Photo uploaded — pending quality review.'**
  String get photoPendingReview;

  /// No description provided for @notificationsTitle.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notificationsTitle;

  /// No description provided for @notificationsEmpty.
  ///
  /// In en, this message translates to:
  /// **'No notifications yet'**
  String get notificationsEmpty;

  /// No description provided for @markAllRead.
  ///
  /// In en, this message translates to:
  /// **'Mark all read'**
  String get markAllRead;

  /// No description provided for @blockUser.
  ///
  /// In en, this message translates to:
  /// **'Block'**
  String get blockUser;

  /// No description provided for @blockConfirm.
  ///
  /// In en, this message translates to:
  /// **'Block this member? Open conversations and chat will close.'**
  String get blockConfirm;

  /// No description provided for @blockDone.
  ///
  /// In en, this message translates to:
  /// **'Member blocked'**
  String get blockDone;

  /// No description provided for @cancelBooking.
  ///
  /// In en, this message translates to:
  /// **'Cancel meeting'**
  String get cancelBooking;

  /// No description provided for @cancelBookingConfirm.
  ///
  /// In en, this message translates to:
  /// **'Cancel this venue meeting? Your conversation partner and venue will be notified.'**
  String get cancelBookingConfirm;

  /// No description provided for @bookingCancelled.
  ///
  /// In en, this message translates to:
  /// **'Meeting cancelled'**
  String get bookingCancelled;

  /// No description provided for @connectionHistoryTitle.
  ///
  /// In en, this message translates to:
  /// **'Past connections'**
  String get connectionHistoryTitle;

  /// No description provided for @connectionHistoryEmpty.
  ///
  /// In en, this message translates to:
  /// **'No past connections yet'**
  String get connectionHistoryEmpty;

  /// No description provided for @withdrawAccount.
  ///
  /// In en, this message translates to:
  /// **'Close account'**
  String get withdrawAccount;

  /// No description provided for @withdrawConfirm.
  ///
  /// In en, this message translates to:
  /// **'This withdraws your membership access. You will be signed out.'**
  String get withdrawConfirm;

  /// No description provided for @waitlistTitle.
  ///
  /// In en, this message translates to:
  /// **'Request an invite'**
  String get waitlistTitle;

  /// No description provided for @waitlistCta.
  ///
  /// In en, this message translates to:
  /// **'No invite yet? Join the waitlist'**
  String get waitlistCta;

  /// No description provided for @waitlistHint.
  ///
  /// In en, this message translates to:
  /// **'VELVET is a discreet, invite-only space for adults seeking real chemistry. Tell us a little about yourself and we will review your application.'**
  String get waitlistHint;

  /// No description provided for @waitlistCity.
  ///
  /// In en, this message translates to:
  /// **'City'**
  String get waitlistCity;

  /// No description provided for @waitlistNote.
  ///
  /// In en, this message translates to:
  /// **'Why you\'d like to join'**
  String get waitlistNote;

  /// No description provided for @waitlistSubmit.
  ///
  /// In en, this message translates to:
  /// **'Submit application'**
  String get waitlistSubmit;

  /// No description provided for @waitlistThanks.
  ///
  /// In en, this message translates to:
  /// **'You\'re on the list'**
  String get waitlistThanks;

  /// No description provided for @waitlistThanksBody.
  ///
  /// In en, this message translates to:
  /// **'We\'ll reach out with an invite if approved. Keep your phone nearby.'**
  String get waitlistThanksBody;

  /// No description provided for @reportCategory.
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get reportCategory;

  /// No description provided for @rescheduleBooking.
  ///
  /// In en, this message translates to:
  /// **'Reschedule'**
  String get rescheduleBooking;

  /// No description provided for @meetingCompleted.
  ///
  /// In en, this message translates to:
  /// **'Completed meeting'**
  String get meetingCompleted;

  /// No description provided for @renewSoon.
  ///
  /// In en, this message translates to:
  /// **'Membership ending soon — renew to keep browsing and requesting bookings.'**
  String get renewSoon;

  /// No description provided for @renewNow.
  ///
  /// In en, this message translates to:
  /// **'Renew membership'**
  String get renewNow;

  /// No description provided for @daysRemaining.
  ///
  /// In en, this message translates to:
  /// **'{days} days remaining'**
  String daysRemaining(int days);

  /// No description provided for @exportMyData.
  ///
  /// In en, this message translates to:
  /// **'Export my data'**
  String get exportMyData;

  /// No description provided for @eraseMyData.
  ///
  /// In en, this message translates to:
  /// **'Erase my data'**
  String get eraseMyData;

  /// No description provided for @eraseConfirm.
  ///
  /// In en, this message translates to:
  /// **'This permanently anonymizes your account beyond closing it. You will be signed out.'**
  String get eraseConfirm;

  /// No description provided for @legalMustAccept.
  ///
  /// In en, this message translates to:
  /// **'Please accept the Terms, Privacy Policy, and Community Guidelines to continue.'**
  String get legalMustAccept;

  /// No description provided for @legalAcceptPrefix.
  ///
  /// In en, this message translates to:
  /// **'I am 21+, and I agree to the'**
  String get legalAcceptPrefix;

  /// No description provided for @legalAnd.
  ///
  /// In en, this message translates to:
  /// **'and'**
  String get legalAnd;

  /// No description provided for @termsOfService.
  ///
  /// In en, this message translates to:
  /// **'Terms of Service'**
  String get termsOfService;

  /// No description provided for @privacyPolicy.
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get privacyPolicy;

  /// No description provided for @communityGuidelines.
  ///
  /// In en, this message translates to:
  /// **'Community Guidelines'**
  String get communityGuidelines;

  /// No description provided for @legalMarketplaceNotice.
  ///
  /// In en, this message translates to:
  /// **'VELVET is a 21+ adult marketplace. Bookings are between consenting adults — coercion and anyone under 21 are banned.'**
  String get legalMarketplaceNotice;

  /// No description provided for @legalUpdateTitle.
  ///
  /// In en, this message translates to:
  /// **'Updated legal terms'**
  String get legalUpdateTitle;

  /// No description provided for @legalUpdateBody.
  ///
  /// In en, this message translates to:
  /// **'Please review and accept the current Terms, Privacy Policy, and Community Guidelines to continue using VELVET.'**
  String get legalUpdateBody;

  /// No description provided for @legalAcceptCta.
  ///
  /// In en, this message translates to:
  /// **'I accept'**
  String get legalAcceptCta;

  /// No description provided for @dateOfBirth.
  ///
  /// In en, this message translates to:
  /// **'Date of birth'**
  String get dateOfBirth;

  /// No description provided for @bioEn.
  ///
  /// In en, this message translates to:
  /// **'Bio (English)'**
  String get bioEn;

  /// No description provided for @bioAm.
  ///
  /// In en, this message translates to:
  /// **'Bio (Amharic)'**
  String get bioAm;

  /// No description provided for @city.
  ///
  /// In en, this message translates to:
  /// **'City'**
  String get city;

  /// No description provided for @ageRequirement.
  ///
  /// In en, this message translates to:
  /// **'Members must be 21 or older.'**
  String get ageRequirement;

  /// No description provided for @legalDocuments.
  ///
  /// In en, this message translates to:
  /// **'Legal documents'**
  String get legalDocuments;

  /// No description provided for @close.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close;

  /// No description provided for @chatOpensSoon.
  ///
  /// In en, this message translates to:
  /// **'Chat opens once you\'re connected — arrange your booking there.'**
  String get chatOpensSoon;

  /// No description provided for @chatWindowClosed.
  ///
  /// In en, this message translates to:
  /// **'This conversation is closed. Messages are removed after the meeting window.'**
  String get chatWindowClosed;

  /// No description provided for @chatMessageHint.
  ///
  /// In en, this message translates to:
  /// **'Set the mood — respectfully…'**
  String get chatMessageHint;

  /// No description provided for @attachPhoto.
  ///
  /// In en, this message translates to:
  /// **'Photo'**
  String get attachPhoto;

  /// No description provided for @attachVideo.
  ///
  /// In en, this message translates to:
  /// **'Video'**
  String get attachVideo;

  /// No description provided for @attachAudio.
  ///
  /// In en, this message translates to:
  /// **'Audio file'**
  String get attachAudio;

  /// No description provided for @attachFile.
  ///
  /// In en, this message translates to:
  /// **'File'**
  String get attachFile;

  /// No description provided for @holdVoiceNote.
  ///
  /// In en, this message translates to:
  /// **'Hold to record a voice note'**
  String get holdVoiceNote;

  /// No description provided for @navMembership.
  ///
  /// In en, this message translates to:
  /// **'Membership'**
  String get navMembership;

  /// No description provided for @navSessionPayments.
  ///
  /// In en, this message translates to:
  /// **'Payments'**
  String get navSessionPayments;

  /// No description provided for @sessionPaymentsTitle.
  ///
  /// In en, this message translates to:
  /// **'Session payments'**
  String get sessionPaymentsTitle;

  /// No description provided for @sessionPaymentsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'No subscription. Pay only when you book.'**
  String get sessionPaymentsSubtitle;

  /// No description provided for @sessionPaymentsHeading.
  ///
  /// In en, this message translates to:
  /// **'Pay for the time you choose'**
  String get sessionPaymentsHeading;

  /// No description provided for @sessionPaymentsBody.
  ///
  /// In en, this message translates to:
  /// **'Browsing and connecting are free. Once you and a performer agree on a session, confirm the rate and pay securely for that individual booking.'**
  String get sessionPaymentsBody;

  /// No description provided for @navProfile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get navProfile;

  /// No description provided for @safetyTitle.
  ///
  /// In en, this message translates to:
  /// **'Safety'**
  String get safetyTitle;

  /// No description provided for @navBrowse.
  ///
  /// In en, this message translates to:
  /// **'Browse'**
  String get navBrowse;

  /// No description provided for @navConversations.
  ///
  /// In en, this message translates to:
  /// **'Conversations'**
  String get navConversations;

  /// No description provided for @navRequests.
  ///
  /// In en, this message translates to:
  /// **'Requests'**
  String get navRequests;

  /// No description provided for @segmentIntros.
  ///
  /// In en, this message translates to:
  /// **'Concierge'**
  String get segmentIntros;

  /// No description provided for @segmentListings.
  ///
  /// In en, this message translates to:
  /// **'Listings'**
  String get segmentListings;

  /// No description provided for @segmentRequests.
  ///
  /// In en, this message translates to:
  /// **'Requests'**
  String get segmentRequests;

  /// No description provided for @filtersTitle.
  ///
  /// In en, this message translates to:
  /// **'Filters'**
  String get filtersTitle;

  /// No description provided for @ageRange.
  ///
  /// In en, this message translates to:
  /// **'Age range'**
  String get ageRange;

  /// No description provided for @maxDistance.
  ///
  /// In en, this message translates to:
  /// **'Max distance'**
  String get maxDistance;

  /// No description provided for @citiesFilterHint.
  ///
  /// In en, this message translates to:
  /// **'Cities (comma-separated, optional)'**
  String get citiesFilterHint;

  /// No description provided for @discoverEmpty.
  ///
  /// In en, this message translates to:
  /// **'No verified listings match your filters right now.'**
  String get discoverEmpty;

  /// No description provided for @discoverEmptyCta.
  ///
  /// In en, this message translates to:
  /// **'Adjust filters'**
  String get discoverEmptyCta;

  /// No description provided for @conversationsInboxTitle.
  ///
  /// In en, this message translates to:
  /// **'Conversations'**
  String get conversationsInboxTitle;

  /// No description provided for @conversationsInboxEmpty.
  ///
  /// In en, this message translates to:
  /// **'No active conversations yet. Discover someone who moves you, or respond to a request that feels right.'**
  String get conversationsInboxEmpty;

  /// No description provided for @conversationsInboxEmptyCtaDiscover.
  ///
  /// In en, this message translates to:
  /// **'Find your spark'**
  String get conversationsInboxEmptyCtaDiscover;

  /// No description provided for @conversationsInboxEmptyCtaRequests.
  ///
  /// In en, this message translates to:
  /// **'Open requests'**
  String get conversationsInboxEmptyCtaRequests;

  /// No description provided for @conversationsInboxHint.
  ///
  /// In en, this message translates to:
  /// **'Your turn means she is waiting to hear what you have in mind.'**
  String get conversationsInboxHint;

  /// No description provided for @conversationsEmptyPreview.
  ///
  /// In en, this message translates to:
  /// **'Begin with the mood, then talk details.'**
  String get conversationsEmptyPreview;

  /// No description provided for @yourTurn.
  ///
  /// In en, this message translates to:
  /// **'Your turn'**
  String get yourTurn;

  /// No description provided for @theirTurn.
  ///
  /// In en, this message translates to:
  /// **'Their turn'**
  String get theirTurn;

  /// No description provided for @sayHello.
  ///
  /// In en, this message translates to:
  /// **'Message'**
  String get sayHello;

  /// No description provided for @replyNow.
  ///
  /// In en, this message translates to:
  /// **'Reply now'**
  String get replyNow;

  /// No description provided for @suggestedOpener.
  ///
  /// In en, this message translates to:
  /// **'Suggested opener'**
  String get suggestedOpener;

  /// No description provided for @sendOpener.
  ///
  /// In en, this message translates to:
  /// **'Send it'**
  String get sendOpener;

  /// No description provided for @typingIndicator.
  ///
  /// In en, this message translates to:
  /// **'Typing…'**
  String get typingIndicator;

  /// No description provided for @messageRead.
  ///
  /// In en, this message translates to:
  /// **'Read'**
  String get messageRead;

  /// No description provided for @clientRequestsEmpty.
  ///
  /// In en, this message translates to:
  /// **'No client requests yet. Keep your listing, rates, and calendar updated.'**
  String get clientRequestsEmpty;

  /// No description provided for @clientRequestsEmptyCta.
  ///
  /// In en, this message translates to:
  /// **'Open Concierge'**
  String get clientRequestsEmptyCta;

  /// No description provided for @introsEmpty.
  ///
  /// In en, this message translates to:
  /// **'No concierge referrals right now.'**
  String get introsEmpty;

  /// No description provided for @introsEmptyCta.
  ///
  /// In en, this message translates to:
  /// **'Edit listing'**
  String get introsEmptyCta;

  /// No description provided for @chatEmptyHint.
  ///
  /// In en, this message translates to:
  /// **'Create comfort and anticipation first, then agree on the experience, rate, setting, and timing.'**
  String get chatEmptyHint;

  /// No description provided for @connectionConfirmedTitle.
  ///
  /// In en, this message translates to:
  /// **'The feeling is mutual'**
  String get connectionConfirmedTitle;

  /// No description provided for @connectionConfirmedBody.
  ///
  /// In en, this message translates to:
  /// **'You can now talk privately and shape a night that feels right for both of you.'**
  String get connectionConfirmedBody;

  /// No description provided for @connectionConfirmedWith.
  ///
  /// In en, this message translates to:
  /// **'You and {name} chose to connect.'**
  String connectionConfirmedWith(String name);

  /// No description provided for @connectionConfirmedNext.
  ///
  /// In en, this message translates to:
  /// **'Let the conversation build, then agree on the setting, time, rate, and boundaries together.'**
  String get connectionConfirmedNext;

  /// No description provided for @keepBrowsing.
  ///
  /// In en, this message translates to:
  /// **'Keep exploring'**
  String get keepBrowsing;

  /// No description provided for @requestNotedPhoto.
  ///
  /// In en, this message translates to:
  /// **'Noted your listing photo'**
  String get requestNotedPhoto;

  /// No description provided for @requestNotedPrompt.
  ///
  /// In en, this message translates to:
  /// **'Noted your listing prompt'**
  String get requestNotedPrompt;

  /// No description provided for @genderMale.
  ///
  /// In en, this message translates to:
  /// **'Man — Client'**
  String get genderMale;

  /// No description provided for @genderFemale.
  ///
  /// In en, this message translates to:
  /// **'Woman — Performer'**
  String get genderFemale;

  /// No description provided for @genderRequiredHint.
  ///
  /// In en, this message translates to:
  /// **'Set your role in Profile. Clients browse listings; performers respond to requests.'**
  String get genderRequiredHint;

  /// No description provided for @womenReceiveOnly.
  ///
  /// In en, this message translates to:
  /// **'Performers do not browse listings. Open Requests to respond to interested clients.'**
  String get womenReceiveOnly;

  /// No description provided for @genderLabel.
  ///
  /// In en, this message translates to:
  /// **'Gender'**
  String get genderLabel;

  /// No description provided for @filterAreas.
  ///
  /// In en, this message translates to:
  /// **'Addis areas'**
  String get filterAreas;

  /// No description provided for @filterLanguages.
  ///
  /// In en, this message translates to:
  /// **'Languages'**
  String get filterLanguages;

  /// No description provided for @filterIntent.
  ///
  /// In en, this message translates to:
  /// **'Booking type'**
  String get filterIntent;

  /// No description provided for @filterVerifiedOnly.
  ///
  /// In en, this message translates to:
  /// **'Verified only'**
  String get filterVerifiedOnly;

  /// No description provided for @languageAmharic.
  ///
  /// In en, this message translates to:
  /// **'Amharic'**
  String get languageAmharic;

  /// No description provided for @languageEnglish.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get languageEnglish;

  /// No description provided for @intentSerious.
  ///
  /// In en, this message translates to:
  /// **'Overnight'**
  String get intentSerious;

  /// No description provided for @intentSocial.
  ///
  /// In en, this message translates to:
  /// **'Evening'**
  String get intentSocial;

  /// No description provided for @recentPassesTitle.
  ///
  /// In en, this message translates to:
  /// **'Recently skipped'**
  String get recentPassesTitle;

  /// No description provided for @recentPassesHint.
  ///
  /// In en, this message translates to:
  /// **'Last 5 listings you skipped — restore any one.'**
  String get recentPassesHint;

  /// No description provided for @recentPassesEmpty.
  ///
  /// In en, this message translates to:
  /// **'No recently skipped listings.'**
  String get recentPassesEmpty;

  /// No description provided for @rewindPass.
  ///
  /// In en, this message translates to:
  /// **'Restore'**
  String get rewindPass;

  /// No description provided for @passRewound.
  ///
  /// In en, this message translates to:
  /// **'Listing restored to your browse feed.'**
  String get passRewound;

  /// No description provided for @interestSent.
  ///
  /// In en, this message translates to:
  /// **'Your interest is in. If she feels the connection too, you can begin planning together.'**
  String get interestSent;

  /// No description provided for @requestBooking.
  ///
  /// In en, this message translates to:
  /// **'Send discreet interest'**
  String get requestBooking;

  /// No description provided for @skipListing.
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get skipListing;

  /// No description provided for @clientRequestHint.
  ///
  /// In en, this message translates to:
  /// **'He is interested in getting to know your energy'**
  String get clientRequestHint;

  /// No description provided for @someoneLabel.
  ///
  /// In en, this message translates to:
  /// **'Member'**
  String get someoneLabel;

  /// No description provided for @listingDistanceKm.
  ///
  /// In en, this message translates to:
  /// **'{km} km away'**
  String listingDistanceKm(int km);

  /// No description provided for @discoverSubtitleClient.
  ///
  /// In en, this message translates to:
  /// **'Verified women, distinct energy, and nights worth anticipating'**
  String get discoverSubtitleClient;

  /// No description provided for @discoverSubtitlePerformer.
  ///
  /// In en, this message translates to:
  /// **'Client requests waiting on your response'**
  String get discoverSubtitlePerformer;

  /// No description provided for @discoverSubtitleLocked.
  ///
  /// In en, this message translates to:
  /// **'Set your role to browse listings or receive requests'**
  String get discoverSubtitleLocked;

  /// No description provided for @chatSendHint.
  ///
  /// In en, this message translates to:
  /// **'Say what you want…'**
  String get chatSendHint;

  /// No description provided for @genderSetupTitle.
  ///
  /// In en, this message translates to:
  /// **'How are you joining?'**
  String get genderSetupTitle;

  /// No description provided for @genderSetupBody.
  ///
  /// In en, this message translates to:
  /// **'Clients (men) browse verified performers and request private bookings. Performers (women) list rates and respond to interested clients.'**
  String get genderSetupBody;

  /// No description provided for @genderMustSelect.
  ///
  /// In en, this message translates to:
  /// **'Please select Client or Performer to continue.'**
  String get genderMustSelect;

  /// No description provided for @profileDetails.
  ///
  /// In en, this message translates to:
  /// **'Profile details'**
  String get profileDetails;

  /// No description provided for @interestsLabel.
  ///
  /// In en, this message translates to:
  /// **'Listing tags'**
  String get interestsLabel;

  /// No description provided for @interestsHint.
  ///
  /// In en, this message translates to:
  /// **'Pick tags clients use to find your listing.'**
  String get interestsHint;

  /// No description provided for @blockedMembers.
  ///
  /// In en, this message translates to:
  /// **'Blocked members'**
  String get blockedMembers;

  /// No description provided for @blockedEmpty.
  ///
  /// In en, this message translates to:
  /// **'You haven’t blocked anyone.'**
  String get blockedEmpty;

  /// No description provided for @unblock.
  ///
  /// In en, this message translates to:
  /// **'Unblock'**
  String get unblock;

  /// No description provided for @unblocked.
  ///
  /// In en, this message translates to:
  /// **'Member unblocked'**
  String get unblocked;

  /// No description provided for @openInMaps.
  ///
  /// In en, this message translates to:
  /// **'Open in maps'**
  String get openInMaps;

  /// No description provided for @venueAddress.
  ///
  /// In en, this message translates to:
  /// **'Address'**
  String get venueAddress;

  /// No description provided for @meetingCountdown.
  ///
  /// In en, this message translates to:
  /// **'Meeting in {hours}h {minutes}m'**
  String meetingCountdown(int hours, int minutes);

  /// No description provided for @meetingNow.
  ///
  /// In en, this message translates to:
  /// **'Meeting window is open'**
  String get meetingNow;

  /// No description provided for @chatBookCta.
  ///
  /// In en, this message translates to:
  /// **'Plan private booking'**
  String get chatBookCta;

  /// No description provided for @staffPortalMemberNavHint.
  ///
  /// In en, this message translates to:
  /// **'Staff accounts use the web console — not Browse, Requests, or Conversations.'**
  String get staffPortalMemberNavHint;

  /// No description provided for @staffConsoleHint.
  ///
  /// In en, this message translates to:
  /// **'Review members, connections, safety reports and operations.'**
  String get staffConsoleHint;

  /// No description provided for @adminConsole.
  ///
  /// In en, this message translates to:
  /// **'Administrator console'**
  String get adminConsole;

  /// No description provided for @adminConsoleHint.
  ///
  /// In en, this message translates to:
  /// **'Manage members, verification, venues, reporting and platform operations.'**
  String get adminConsoleHint;

  /// No description provided for @conciergeConsole.
  ///
  /// In en, this message translates to:
  /// **'Concierge console'**
  String get conciergeConsole;

  /// No description provided for @conciergeConsoleHint.
  ///
  /// In en, this message translates to:
  /// **'Coordinate referrals, member care and safety follow-up.'**
  String get conciergeConsoleHint;

  /// No description provided for @accessLevel.
  ///
  /// In en, this message translates to:
  /// **'Access level'**
  String get accessLevel;

  /// No description provided for @partnerPortal.
  ///
  /// In en, this message translates to:
  /// **'Partner portal'**
  String get partnerPortal;

  /// No description provided for @partnerPortalHint.
  ///
  /// In en, this message translates to:
  /// **'Manage venue bookings, check-ins and partner operations.'**
  String get partnerPortalHint;

  /// No description provided for @consoleBrowserHint.
  ///
  /// In en, this message translates to:
  /// **'The console opens in your browser and uses its own secure staff sign-in.'**
  String get consoleBrowserHint;

  /// No description provided for @openConsole.
  ///
  /// In en, this message translates to:
  /// **'Open console'**
  String get openConsole;

  /// No description provided for @consoleOpenFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not open the console. Please try again.'**
  String get consoleOpenFailed;

  /// No description provided for @profileSetupTitle.
  ///
  /// In en, this message translates to:
  /// **'Finish your profile'**
  String get profileSetupTitle;

  /// No description provided for @profileSetupBody.
  ///
  /// In en, this message translates to:
  /// **'Lead with the energy only you bring. Three photos and a magnetic bio help the right clients choose you.'**
  String get profileSetupBody;

  /// No description provided for @profileSetupPhotos.
  ///
  /// In en, this message translates to:
  /// **'{count} photos'**
  String profileSetupPhotos(Object count);

  /// No description provided for @profileSetupRequired.
  ///
  /// In en, this message translates to:
  /// **'Add 3 photos, your city, and both listing summaries to continue.'**
  String get profileSetupRequired;

  /// No description provided for @promptListingEn.
  ///
  /// In en, this message translates to:
  /// **'Describe your private-night energy (English)'**
  String get promptListingEn;

  /// No description provided for @promptListingAm.
  ///
  /// In en, this message translates to:
  /// **'Describe your private-night energy (Amharic)'**
  String get promptListingAm;

  /// No description provided for @promptAnswerEn.
  ///
  /// In en, this message translates to:
  /// **'What makes time with you unforgettable?'**
  String get promptAnswerEn;

  /// No description provided for @promptAnswerAm.
  ///
  /// In en, this message translates to:
  /// **'What makes time with you unforgettable? (Amharic)'**
  String get promptAnswerAm;

  /// No description provided for @profileSetupFinish.
  ///
  /// In en, this message translates to:
  /// **'I’m ready'**
  String get profileSetupFinish;

  /// No description provided for @profileReadyTitle.
  ///
  /// In en, this message translates to:
  /// **'Your energy is live'**
  String get profileReadyTitle;

  /// No description provided for @profileReadyBody.
  ///
  /// In en, this message translates to:
  /// **'Your profile is ready to attract the clients who are looking for exactly your kind of presence.'**
  String get profileReadyBody;

  /// No description provided for @startDiscovering.
  ///
  /// In en, this message translates to:
  /// **'Explore the chemistry'**
  String get startDiscovering;

  /// No description provided for @profileDetailsOptional.
  ///
  /// In en, this message translates to:
  /// **'Listing details (optional)'**
  String get profileDetailsOptional;

  /// No description provided for @profileClientHint.
  ///
  /// In en, this message translates to:
  /// **'Clients only need basics here — browse listings and request bookings from the Browse tab.'**
  String get profileClientHint;

  /// No description provided for @profileListingSection.
  ///
  /// In en, this message translates to:
  /// **'Your listing'**
  String get profileListingSection;

  /// No description provided for @membershipBenefitBrowse.
  ///
  /// In en, this message translates to:
  /// **'Browse verified women, their energy, rates, and availability'**
  String get membershipBenefitBrowse;

  /// No description provided for @membershipBenefitRequests.
  ///
  /// In en, this message translates to:
  /// **'Send discreet interest requests to the women who catch your eye'**
  String get membershipBenefitRequests;

  /// No description provided for @membershipBenefitBook.
  ///
  /// In en, this message translates to:
  /// **'Chat, find the chemistry, and plan a private night when connected'**
  String get membershipBenefitBook;

  /// No description provided for @membershipPlanIncludes.
  ///
  /// In en, this message translates to:
  /// **'Includes'**
  String get membershipPlanIncludes;

  /// No description provided for @languagesSpoken.
  ///
  /// In en, this message translates to:
  /// **'Languages spoken'**
  String get languagesSpoken;

  /// No description provided for @languagesSpokenHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. Amharic, English'**
  String get languagesSpokenHint;

  /// No description provided for @listingTagsLabel.
  ///
  /// In en, this message translates to:
  /// **'Listing tags'**
  String get listingTagsLabel;

  /// No description provided for @listingTagsHint.
  ///
  /// In en, this message translates to:
  /// **'Tags shown on your listing card in browse.'**
  String get listingTagsHint;

  /// No description provided for @sessionRateEtb.
  ///
  /// In en, this message translates to:
  /// **'Session rate (ETB)'**
  String get sessionRateEtb;

  /// No description provided for @overnightRateEtb.
  ///
  /// In en, this message translates to:
  /// **'Overnight rate (ETB)'**
  String get overnightRateEtb;

  /// No description provided for @availabilityNote.
  ///
  /// In en, this message translates to:
  /// **'When you are open to connect'**
  String get availabilityNote;

  /// No description provided for @listingActive.
  ///
  /// In en, this message translates to:
  /// **'Show my listing to clients'**
  String get listingActive;

  /// No description provided for @rateSessionLabel.
  ///
  /// In en, this message translates to:
  /// **'From {amount} ETB / private session'**
  String rateSessionLabel(int amount);

  /// No description provided for @rateOvernightLabel.
  ///
  /// In en, this message translates to:
  /// **'{amount} ETB / overnight'**
  String rateOvernightLabel(int amount);

  /// No description provided for @performerRatesSection.
  ///
  /// In en, this message translates to:
  /// **'Listing rates'**
  String get performerRatesSection;

  /// No description provided for @performerRatesHint.
  ///
  /// In en, this message translates to:
  /// **'Clients see these beside your listing. Leave blank if you prefer to discuss the details once the chemistry is there.'**
  String get performerRatesHint;

  /// No description provided for @safetyCenterTitle.
  ///
  /// In en, this message translates to:
  /// **'Safety center'**
  String get safetyCenterTitle;

  /// No description provided for @safetyCenterHint.
  ///
  /// In en, this message translates to:
  /// **'Panic, block, report, share your trip with concierge, and see verified venues — in one place.'**
  String get safetyCenterHint;

  /// No description provided for @shareTripWithVelvet.
  ///
  /// In en, this message translates to:
  /// **'Share trip with Velvet'**
  String get shareTripWithVelvet;

  /// No description provided for @tripSharedSnack.
  ///
  /// In en, this message translates to:
  /// **'Concierge notified — safe travels.'**
  String get tripSharedSnack;

  /// No description provided for @verifiedVenues.
  ///
  /// In en, this message translates to:
  /// **'Verified venues'**
  String get verifiedVenues;

  /// No description provided for @verifiedVenuesEmpty.
  ///
  /// In en, this message translates to:
  /// **'Verified venues will appear here.'**
  String get verifiedVenuesEmpty;

  /// No description provided for @reportMember.
  ///
  /// In en, this message translates to:
  /// **'Report'**
  String get reportMember;

  /// No description provided for @reportSubmitted.
  ///
  /// In en, this message translates to:
  /// **'Report sent to concierge.'**
  String get reportSubmitted;

  /// No description provided for @addToCalendar.
  ///
  /// In en, this message translates to:
  /// **'Add to calendar'**
  String get addToCalendar;

  /// No description provided for @timelinePropose.
  ///
  /// In en, this message translates to:
  /// **'Propose'**
  String get timelinePropose;

  /// No description provided for @timelineConfirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get timelineConfirm;

  /// No description provided for @timelineReminder.
  ///
  /// In en, this message translates to:
  /// **'Reminder'**
  String get timelineReminder;

  /// No description provided for @timelineCheckIn.
  ///
  /// In en, this message translates to:
  /// **'Check-in'**
  String get timelineCheckIn;

  /// No description provided for @timelineCheckout.
  ///
  /// In en, this message translates to:
  /// **'Checkout'**
  String get timelineCheckout;

  /// No description provided for @vibeQuiet.
  ///
  /// In en, this message translates to:
  /// **'Quiet'**
  String get vibeQuiet;

  /// No description provided for @vibeBalanced.
  ///
  /// In en, this message translates to:
  /// **'Balanced'**
  String get vibeBalanced;

  /// No description provided for @vibeLively.
  ///
  /// In en, this message translates to:
  /// **'Lively'**
  String get vibeLively;

  /// No description provided for @meetingFeedbackTitle.
  ///
  /// In en, this message translates to:
  /// **'How was the meeting?'**
  String get meetingFeedbackTitle;

  /// No description provided for @meetingFeedbackHint.
  ///
  /// In en, this message translates to:
  /// **'Quick answers help Velvet keep bookings safe.'**
  String get meetingFeedbackHint;

  /// No description provided for @feltSafe.
  ///
  /// In en, this message translates to:
  /// **'Felt safe?'**
  String get feltSafe;

  /// No description provided for @wouldBookAgain.
  ///
  /// In en, this message translates to:
  /// **'Would book again?'**
  String get wouldBookAgain;

  /// No description provided for @venueOk.
  ///
  /// In en, this message translates to:
  /// **'Venue okay?'**
  String get venueOk;

  /// No description provided for @optionalNotes.
  ///
  /// In en, this message translates to:
  /// **'Notes (optional)'**
  String get optionalNotes;

  /// No description provided for @submitFeedback.
  ///
  /// In en, this message translates to:
  /// **'Submit'**
  String get submitFeedback;

  /// No description provided for @feedbackThanks.
  ///
  /// In en, this message translates to:
  /// **'Thank you — that helps.'**
  String get feedbackThanks;

  /// No description provided for @bookingProposedSnack.
  ///
  /// In en, this message translates to:
  /// **'Your private-night plan is ready for her review.'**
  String get bookingProposedSnack;

  /// No description provided for @bookingConfirmedSnack.
  ///
  /// In en, this message translates to:
  /// **'Your private night is confirmed.'**
  String get bookingConfirmedSnack;

  /// No description provided for @cbeStepAmount.
  ///
  /// In en, this message translates to:
  /// **'1 · Amount'**
  String get cbeStepAmount;

  /// No description provided for @cbeStepAccount.
  ///
  /// In en, this message translates to:
  /// **'2 · Transfer'**
  String get cbeStepAccount;

  /// No description provided for @cbeStepReceipt.
  ///
  /// In en, this message translates to:
  /// **'3 · Receipt'**
  String get cbeStepReceipt;

  /// No description provided for @cbeVerifyEta.
  ///
  /// In en, this message translates to:
  /// **'Usually verified within 30–60 minutes during business hours.'**
  String get cbeVerifyEta;

  /// No description provided for @cbeMockLabel.
  ///
  /// In en, this message translates to:
  /// **'Mock payment (dev)'**
  String get cbeMockLabel;

  /// No description provided for @cbeLiveLabel.
  ///
  /// In en, this message translates to:
  /// **'Live CBE transfer'**
  String get cbeLiveLabel;

  /// No description provided for @lowBandwidthMode.
  ///
  /// In en, this message translates to:
  /// **'Low-bandwidth mode'**
  String get lowBandwidthMode;

  /// No description provided for @lowBandwidthHint.
  ///
  /// In en, this message translates to:
  /// **'Smaller photos, less autoplay — better on slow networks.'**
  String get lowBandwidthHint;

  /// No description provided for @shareInviteWhatsApp.
  ///
  /// In en, this message translates to:
  /// **'Share invite on WhatsApp'**
  String get shareInviteWhatsApp;

  /// No description provided for @shareInviteWhatsAppGeneric.
  ///
  /// In en, this message translates to:
  /// **'Join VELVET — Addis\'s discreet, verified space for adult chemistry and private nights. Ask me for an invite.'**
  String get shareInviteWhatsAppGeneric;

  /// No description provided for @shareInviteWhatsAppWithCode.
  ///
  /// In en, this message translates to:
  /// **'You are invited to VELVET, a discreet space for verified adult connection. Open the app and enter invite code {code} with your +251 number.'**
  String shareInviteWhatsAppWithCode(String code);

  /// No description provided for @shareWaitlistWhatsAppGeneric.
  ///
  /// In en, this message translates to:
  /// **'Join me on the VELVET waitlist — Addis\'s discreet, verified space for adult chemistry and private nights.'**
  String get shareWaitlistWhatsAppGeneric;

  /// No description provided for @shareWaitlistWhatsAppWithCode.
  ///
  /// In en, this message translates to:
  /// **'You\'re invited to VELVET. Use code {code} with your +251 phone in the app.'**
  String shareWaitlistWhatsAppWithCode(String code);

  /// No description provided for @waitlistFriendsApproved.
  ///
  /// In en, this message translates to:
  /// **'{count} friends approved'**
  String waitlistFriendsApproved(int count);

  /// No description provided for @waitlistStatusPending.
  ///
  /// In en, this message translates to:
  /// **'You’re on the list — we’ll text when you’re in.'**
  String get waitlistStatusPending;

  /// No description provided for @waitlistStatusApproved.
  ///
  /// In en, this message translates to:
  /// **'You’re approved. Use your invite code to join.'**
  String get waitlistStatusApproved;

  /// No description provided for @waitlistCheckStatus.
  ///
  /// In en, this message translates to:
  /// **'Check status'**
  String get waitlistCheckStatus;

  /// No description provided for @reorderPhotosHint.
  ///
  /// In en, this message translates to:
  /// **'Long-press a photo to reorder. First photo is your cover.'**
  String get reorderPhotosHint;

  /// No description provided for @photosReordered.
  ///
  /// In en, this message translates to:
  /// **'Photo order saved.'**
  String get photosReordered;

  /// No description provided for @makeCoverPhoto.
  ///
  /// In en, this message translates to:
  /// **'Make cover'**
  String get makeCoverPhoto;

  /// No description provided for @meetupPlace.
  ///
  /// In en, this message translates to:
  /// **'Hotel / suite / meetup place'**
  String get meetupPlace;

  /// No description provided for @meetupPlaceHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. private suite · details agreed together'**
  String get meetupPlaceHint;

  /// No description provided for @rateTypeSession.
  ///
  /// In en, this message translates to:
  /// **'Evening / session'**
  String get rateTypeSession;

  /// No description provided for @rateTypeOvernight.
  ///
  /// In en, this message translates to:
  /// **'Overnight'**
  String get rateTypeOvernight;

  /// No description provided for @bookingAmount.
  ///
  /// In en, this message translates to:
  /// **'{amount} ETB'**
  String bookingAmount(int amount);

  /// No description provided for @payBooking.
  ///
  /// In en, this message translates to:
  /// **'Pay booking'**
  String get payBooking;

  /// No description provided for @bookingPaid.
  ///
  /// In en, this message translates to:
  /// **'Payment confirmed — your private-night plan is secured.'**
  String get bookingPaid;

  /// No description provided for @paymentStatusLabel.
  ///
  /// In en, this message translates to:
  /// **'Payment'**
  String get paymentStatusLabel;

  /// No description provided for @paymentUnpaid.
  ///
  /// In en, this message translates to:
  /// **'Unpaid'**
  String get paymentUnpaid;

  /// No description provided for @paymentPending.
  ///
  /// In en, this message translates to:
  /// **'Payment pending'**
  String get paymentPending;

  /// No description provided for @paymentPaid.
  ///
  /// In en, this message translates to:
  /// **'Paid'**
  String get paymentPaid;

  /// No description provided for @paymentWaived.
  ///
  /// In en, this message translates to:
  /// **'No charge'**
  String get paymentWaived;

  /// No description provided for @earningsTitle.
  ///
  /// In en, this message translates to:
  /// **'Earnings'**
  String get earningsTitle;

  /// No description provided for @earningsHint.
  ///
  /// In en, this message translates to:
  /// **'You keep {percent}% of each paid booking. Platform fee covers payments and safety ops.'**
  String earningsHint(int percent);

  /// No description provided for @earningsAvailable.
  ///
  /// In en, this message translates to:
  /// **'Available balance'**
  String get earningsAvailable;

  /// No description provided for @earningsLifetime.
  ///
  /// In en, this message translates to:
  /// **'Lifetime earned'**
  String get earningsLifetime;

  /// No description provided for @earningsPaidOut.
  ///
  /// In en, this message translates to:
  /// **'Paid out'**
  String get earningsPaidOut;

  /// No description provided for @earningsActivity.
  ///
  /// In en, this message translates to:
  /// **'Activity'**
  String get earningsActivity;

  /// No description provided for @earningsEmpty.
  ///
  /// In en, this message translates to:
  /// **'No earnings yet — paid bookings credit your balance here.'**
  String get earningsEmpty;

  /// No description provided for @earningsCredit.
  ///
  /// In en, this message translates to:
  /// **'Booking credit'**
  String get earningsCredit;

  /// No description provided for @earningsPayout.
  ///
  /// In en, this message translates to:
  /// **'Payout'**
  String get earningsPayout;

  /// No description provided for @requestPayout.
  ///
  /// In en, this message translates to:
  /// **'Request payout'**
  String get requestPayout;

  /// No description provided for @payoutAmount.
  ///
  /// In en, this message translates to:
  /// **'Amount (ETB)'**
  String get payoutAmount;

  /// No description provided for @payoutDestination.
  ///
  /// In en, this message translates to:
  /// **'CBE / Telebirr account note'**
  String get payoutDestination;

  /// No description provided for @payoutMinAmount.
  ///
  /// In en, this message translates to:
  /// **'Minimum payout is 50 ETB.'**
  String get payoutMinAmount;

  /// No description provided for @payoutRequested.
  ///
  /// In en, this message translates to:
  /// **'Payout requested — concierge will process it.'**
  String get payoutRequested;

  /// No description provided for @listingRequiresVerification.
  ///
  /// In en, this message translates to:
  /// **'ID verification must be approved before clients can see your listing.'**
  String get listingRequiresVerification;

  /// No description provided for @verifyToListCta.
  ///
  /// In en, this message translates to:
  /// **'Verify ID to go live'**
  String get verifyToListCta;

  /// No description provided for @availabilityCalendarTitle.
  ///
  /// In en, this message translates to:
  /// **'Availability calendar'**
  String get availabilityCalendarTitle;

  /// No description provided for @availabilityCalendarHint.
  ///
  /// In en, this message translates to:
  /// **'Choose the moments you are open to connect. Clients can only request time inside your published windows.'**
  String get availabilityCalendarHint;

  /// No description provided for @availabilityDay.
  ///
  /// In en, this message translates to:
  /// **'Day'**
  String get availabilityDay;

  /// No description provided for @availabilityStart.
  ///
  /// In en, this message translates to:
  /// **'Starts'**
  String get availabilityStart;

  /// No description provided for @availabilityEnd.
  ///
  /// In en, this message translates to:
  /// **'Ends'**
  String get availabilityEnd;

  /// No description provided for @availabilityWindowNote.
  ///
  /// In en, this message translates to:
  /// **'Note (optional)'**
  String get availabilityWindowNote;

  /// No description provided for @availabilityAddWindow.
  ///
  /// In en, this message translates to:
  /// **'Add window'**
  String get availabilityAddWindow;

  /// No description provided for @availabilityUpcoming.
  ///
  /// In en, this message translates to:
  /// **'Upcoming windows'**
  String get availabilityUpcoming;

  /// No description provided for @availabilityEmpty.
  ///
  /// In en, this message translates to:
  /// **'No open moments yet — add the evenings or overnight windows that work for you.'**
  String get availabilityEmpty;

  /// No description provided for @availabilityAdded.
  ///
  /// In en, this message translates to:
  /// **'Availability window added.'**
  String get availabilityAdded;

  /// No description provided for @availabilityMustBeFuture.
  ///
  /// In en, this message translates to:
  /// **'Start time must be in the future.'**
  String get availabilityMustBeFuture;

  /// No description provided for @navListing.
  ///
  /// In en, this message translates to:
  /// **'Listing'**
  String get navListing;

  /// No description provided for @membershipRequiredBrowse.
  ///
  /// In en, this message translates to:
  /// **'Membership is required to browse verified performers.'**
  String get membershipRequiredBrowse;

  /// No description provided for @bookingNoAvailability.
  ///
  /// In en, this message translates to:
  /// **'No open availability windows — ask her to publish times, or try later.'**
  String get bookingNoAvailability;

  /// No description provided for @performerReadyTitle.
  ///
  /// In en, this message translates to:
  /// **'Go live'**
  String get performerReadyTitle;

  /// No description provided for @performerReadyHint.
  ///
  /// In en, this message translates to:
  /// **'Finish these steps so clients can find and book you.'**
  String get performerReadyHint;

  /// No description provided for @readyStepVerify.
  ///
  /// In en, this message translates to:
  /// **'Verify your ID'**
  String get readyStepVerify;

  /// No description provided for @readyStepVerifyDone.
  ///
  /// In en, this message translates to:
  /// **'Verified — clients can trust your listing.'**
  String get readyStepVerifyDone;

  /// No description provided for @readyStepVerifyTodo.
  ///
  /// In en, this message translates to:
  /// **'Upload ID + selfie for admin review.'**
  String get readyStepVerifyTodo;

  /// No description provided for @readyStepRates.
  ///
  /// In en, this message translates to:
  /// **'Set your rates'**
  String get readyStepRates;

  /// No description provided for @readyStepRatesDone.
  ///
  /// In en, this message translates to:
  /// **'Session {session} ETB · Overnight {overnight} ETB'**
  String readyStepRatesDone(int session, int overnight);

  /// No description provided for @readyStepRatesTodo.
  ///
  /// In en, this message translates to:
  /// **'Add session and/or overnight rates on your profile.'**
  String get readyStepRatesTodo;

  /// No description provided for @readyStepCalendar.
  ///
  /// In en, this message translates to:
  /// **'Publish availability'**
  String get readyStepCalendar;

  /// No description provided for @readyStepCalendarDone.
  ///
  /// In en, this message translates to:
  /// **'{count} open windows'**
  String readyStepCalendarDone(int count);

  /// No description provided for @readyStepCalendarTodo.
  ///
  /// In en, this message translates to:
  /// **'Add evenings or overnight blocks clients can book.'**
  String get readyStepCalendarTodo;

  /// No description provided for @readyStepPhotos.
  ///
  /// In en, this message translates to:
  /// **'Add listing photos'**
  String get readyStepPhotos;

  /// No description provided for @readyStepPhotosDone.
  ///
  /// In en, this message translates to:
  /// **'{count} photos on your listing'**
  String readyStepPhotosDone(int count);

  /// No description provided for @readyStepPhotosTodo.
  ///
  /// In en, this message translates to:
  /// **'Upload at least 3 photos clients can browse.'**
  String get readyStepPhotosTodo;

  /// No description provided for @readyStepListing.
  ///
  /// In en, this message translates to:
  /// **'Write your listing summary'**
  String get readyStepListing;

  /// No description provided for @readyStepListingDone.
  ///
  /// In en, this message translates to:
  /// **'English and Amharic summaries are set.'**
  String get readyStepListingDone;

  /// No description provided for @readyStepListingTodo.
  ///
  /// In en, this message translates to:
  /// **'Add both listing summaries on your profile.'**
  String get readyStepListingTodo;

  /// No description provided for @readyProgressLabel.
  ///
  /// In en, this message translates to:
  /// **'{done} of {total} complete'**
  String readyProgressLabel(int done, int total);

  /// No description provided for @readyGoLiveHint.
  ///
  /// In en, this message translates to:
  /// **'Turn on when you\'re ready to appear in Browse.'**
  String get readyGoLiveHint;

  /// No description provided for @readyFinishStepsFirst.
  ///
  /// In en, this message translates to:
  /// **'Complete verification, rates, and calendar first.'**
  String get readyFinishStepsFirst;

  /// No description provided for @readyLiveBanner.
  ///
  /// In en, this message translates to:
  /// **'Your listing is live — the right clients can discover your energy and send discreet interest.'**
  String get readyLiveBanner;

  /// No description provided for @listingNowLive.
  ///
  /// In en, this message translates to:
  /// **'Listing is live.'**
  String get listingNowLive;

  /// No description provided for @listingNowHidden.
  ///
  /// In en, this message translates to:
  /// **'Listing hidden from clients.'**
  String get listingNowHidden;

  /// No description provided for @flowNextBookTitle.
  ///
  /// In en, this message translates to:
  /// **'Next best move: turn chemistry into a plan'**
  String get flowNextBookTitle;

  /// No description provided for @flowNextBookBody.
  ///
  /// In en, this message translates to:
  /// **'Open the booking and agree on the time, setting, rate, and boundaries while the connection feels alive.'**
  String get flowNextBookBody;

  /// No description provided for @flowNextPayTitle.
  ///
  /// In en, this message translates to:
  /// **'Next best move: complete payment'**
  String get flowNextPayTitle;

  /// No description provided for @flowNextPayBody.
  ///
  /// In en, this message translates to:
  /// **'Payment secures the plan, leaving both of you free to focus on the anticipation.'**
  String get flowNextPayBody;

  /// No description provided for @flowNextConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Next best move: confirm details'**
  String get flowNextConfirmTitle;

  /// No description provided for @flowNextConfirmBody.
  ///
  /// In en, this message translates to:
  /// **'Confirm this booking now, then finalize details in chat.'**
  String get flowNextConfirmBody;

  /// No description provided for @flowNextChatTitle.
  ///
  /// In en, this message translates to:
  /// **'Next best move: build the anticipation'**
  String get flowNextChatTitle;

  /// No description provided for @flowNextChatBody.
  ///
  /// In en, this message translates to:
  /// **'Open chat to confirm the mood, rate, place, timing, and boundaries you both want.'**
  String get flowNextChatBody;

  /// No description provided for @flowNextArriveTitle.
  ///
  /// In en, this message translates to:
  /// **'Next best move: arrive smoothly'**
  String get flowNextArriveTitle;

  /// No description provided for @flowNextArriveBody.
  ///
  /// In en, this message translates to:
  /// **'Share trip or check in when you are near the meetup.'**
  String get flowNextArriveBody;

  /// No description provided for @flowFocusConfirmHint.
  ///
  /// In en, this message translates to:
  /// **'Confirm this now to keep the booking on track.'**
  String get flowFocusConfirmHint;

  /// No description provided for @flowFocusPayHint.
  ///
  /// In en, this message translates to:
  /// **'Complete payment now so the booking is fully secured.'**
  String get flowFocusPayHint;

  /// No description provided for @flowFocusPayDoneHint.
  ///
  /// In en, this message translates to:
  /// **'Payment is confirmed. Move to chat and finalize the plan.'**
  String get flowFocusPayDoneHint;

  /// No description provided for @quickBookNow.
  ///
  /// In en, this message translates to:
  /// **'Book now'**
  String get quickBookNow;

  /// No description provided for @quickSendRatePrompt.
  ///
  /// In en, this message translates to:
  /// **'Send rate prompt'**
  String get quickSendRatePrompt;

  /// No description provided for @quickSendBookingSummary.
  ///
  /// In en, this message translates to:
  /// **'Send booking summary'**
  String get quickSendBookingSummary;

  /// No description provided for @quickSendCheckinLineLabel.
  ///
  /// In en, this message translates to:
  /// **'Send check-in line'**
  String get quickSendCheckinLineLabel;

  /// No description provided for @quickSendAftercareLineLabel.
  ///
  /// In en, this message translates to:
  /// **'Send aftercare line'**
  String get quickSendAftercareLineLabel;

  /// No description provided for @quickAskPlace.
  ///
  /// In en, this message translates to:
  /// **'Ask place'**
  String get quickAskPlace;

  /// No description provided for @quickRatePromptLine.
  ///
  /// In en, this message translates to:
  /// **'What kind of private experience are you open to, and what rate feels right for you?'**
  String get quickRatePromptLine;

  /// No description provided for @quickPlacePromptLine.
  ///
  /// In en, this message translates to:
  /// **'What setting would make tonight feel right for you?'**
  String get quickPlacePromptLine;

  /// No description provided for @quickBookingSummaryLine.
  ///
  /// In en, this message translates to:
  /// **'Here is the night I have in mind:'**
  String get quickBookingSummaryLine;

  /// No description provided for @quickSendCheckinLine.
  ///
  /// In en, this message translates to:
  /// **'I\'m checked in now. Come when you\'re ready and text me when you arrive.'**
  String get quickSendCheckinLine;

  /// No description provided for @quickSendAftercareLine.
  ///
  /// In en, this message translates to:
  /// **'Thank you for tonight. If you\'d like to book again, let\'s lock the next plan.'**
  String get quickSendAftercareLine;

  /// No description provided for @flowPostCheckoutTitle.
  ///
  /// In en, this message translates to:
  /// **'Before this closes'**
  String get flowPostCheckoutTitle;

  /// No description provided for @flowPostCheckoutBody.
  ///
  /// In en, this message translates to:
  /// **'Leave feedback for safety, or propose your next booking while you\'re still connected.'**
  String get flowPostCheckoutBody;

  /// No description provided for @welcomeTitle.
  ///
  /// In en, this message translates to:
  /// **'Where chemistry becomes a plan'**
  String get welcomeTitle;

  /// No description provided for @welcomeBodyClient.
  ///
  /// In en, this message translates to:
  /// **'Browse verified women, follow the connection, and arrange a private night with clarity and consent — all in one discreet place.'**
  String get welcomeBodyClient;

  /// No description provided for @welcomeBodyPerformer.
  ///
  /// In en, this message translates to:
  /// **'Show your energy, set your terms, and respond only when the connection feels right to you.'**
  String get welcomeBodyPerformer;

  /// No description provided for @welcomeStepBrowse.
  ///
  /// In en, this message translates to:
  /// **'Follow the spark'**
  String get welcomeStepBrowse;

  /// No description provided for @welcomeStepBrowseBody.
  ///
  /// In en, this message translates to:
  /// **'Explore each woman\'s photos, energy, rates, availability, and verification.'**
  String get welcomeStepBrowseBody;

  /// No description provided for @welcomeStepRequest.
  ///
  /// In en, this message translates to:
  /// **'Make your interest known'**
  String get welcomeStepRequest;

  /// No description provided for @welcomeStepRequestBody.
  ///
  /// In en, this message translates to:
  /// **'Send a discreet request when someone catches your attention. She always chooses whether to connect.'**
  String get welcomeStepRequestBody;

  /// No description provided for @welcomeStepBook.
  ///
  /// In en, this message translates to:
  /// **'Shape the night'**
  String get welcomeStepBook;

  /// No description provided for @welcomeStepBookBody.
  ///
  /// In en, this message translates to:
  /// **'Once you connect, agree on the experience, timing, place, rate, and boundaries together.'**
  String get welcomeStepBookBody;

  /// No description provided for @welcomeStepListing.
  ///
  /// In en, this message translates to:
  /// **'Complete your listing'**
  String get welcomeStepListing;

  /// No description provided for @welcomeStepListingBody.
  ///
  /// In en, this message translates to:
  /// **'Photos, rates, and summaries help clients trust and choose you.'**
  String get welcomeStepListingBody;

  /// No description provided for @welcomeStepCalendar.
  ///
  /// In en, this message translates to:
  /// **'Open your calendar'**
  String get welcomeStepCalendar;

  /// No description provided for @welcomeStepCalendarBody.
  ///
  /// In en, this message translates to:
  /// **'Publish evenings or overnight windows clients can book.'**
  String get welcomeStepCalendarBody;

  /// No description provided for @welcomeStepRequests.
  ///
  /// In en, this message translates to:
  /// **'Respond to requests'**
  String get welcomeStepRequests;

  /// No description provided for @welcomeStepRequestsBody.
  ///
  /// In en, this message translates to:
  /// **'Accept or decline incoming interest from your Requests inbox.'**
  String get welcomeStepRequestsBody;

  /// No description provided for @welcomeCta.
  ///
  /// In en, this message translates to:
  /// **'Get started'**
  String get welcomeCta;

  /// No description provided for @discoverCoachTitle.
  ///
  /// In en, this message translates to:
  /// **'From spark to private night'**
  String get discoverCoachTitle;

  /// No description provided for @discoverCoachBody.
  ///
  /// In en, this message translates to:
  /// **'Browse the energy → send interest → build chemistry in chat → agree on your private night. Skip anything that does not feel right.'**
  String get discoverCoachBody;

  /// No description provided for @flowHintBrowse.
  ///
  /// In en, this message translates to:
  /// **'Browse'**
  String get flowHintBrowse;

  /// No description provided for @flowHintRequest.
  ///
  /// In en, this message translates to:
  /// **'Request'**
  String get flowHintRequest;

  /// No description provided for @flowHintBook.
  ///
  /// In en, this message translates to:
  /// **'Book'**
  String get flowHintBook;

  /// No description provided for @flowHintRespond.
  ///
  /// In en, this message translates to:
  /// **'Respond'**
  String get flowHintRespond;

  /// No description provided for @conversationsEmptyFlowHint.
  ///
  /// In en, this message translates to:
  /// **'Send discreet interest when a listing catches your eye — the conversation opens only after you both choose to connect.'**
  String get conversationsEmptyFlowHint;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['am', 'en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'am':
      return AppLocalizationsAm();
    case 'en':
      return AppLocalizationsEn();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}

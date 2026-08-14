// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Amharic (`am`).
class AppLocalizationsAm extends AppLocalizations {
  AppLocalizationsAm([String locale = 'am']) : super(locale);

  @override
  String get appName => 'ቬልቬት';

  @override
  String get tagline => 'ከተረጋገጡ ሴቶች ጋር የግል ምሽቶች — ለመያዝ የሚፈልጉ';

  @override
  String get inviteCode => 'የግብዣ ኮድ';

  @override
  String get phoneNumber => 'ስልክ ቁጥር';

  @override
  String get phoneHint => '+2519...';

  @override
  String get continueLabel => 'ቀጥል';

  @override
  String get otpTitle => 'የማረጋገጫ ኮድ ያስገቡ';

  @override
  String otpSubtitle(String phone) {
    return 'ኮድ ወደ $phone ተልኳል';
  }

  @override
  String get verify => 'አረጋግጥ';

  @override
  String get profile => 'መገለጫ';

  @override
  String get signOut => 'ውጣ';

  @override
  String get language => 'ቋንቋ';

  @override
  String get displayName => 'የሚታይ ስም';

  @override
  String get save => 'አስቀምጥ';

  @override
  String get errorGeneric => 'ስህተት ተከስቷል። እንደገና ይሞክሩ።';

  @override
  String get retry => 'እንደገና ይሞክሩ';

  @override
  String get statusAwaitingYou => 'የእርስዎን ምላሽ በመጠባበቅ ላይ';

  @override
  String get statusPending => 'በመጠባበቅ ላይ';

  @override
  String get statusConnected => 'ተገናኝቷል';

  @override
  String get statusDeclined => 'ውድቅ ተደርጓል';

  @override
  String get statusExpired => 'ጊዜው አልፏል';

  @override
  String get statusConfirmed => 'ተረጋግጧል';

  @override
  String get statusCheckedIn => 'ገብተዋል';

  @override
  String get statusCompleted => 'ተጠናቋል';

  @override
  String get statusCancelled => 'ተሰርዟል';

  @override
  String get statusNoShow => 'አልተገኙም';

  @override
  String get statusVerified => 'ተረጋግጧል';

  @override
  String devOtpHint(String code) {
    return 'የልማት ኦቲፒ፡ $code';
  }

  @override
  String get verificationTitle => 'ማረጋገጫ';

  @override
  String get verificationNone => 'ገና ማረጋገጫ አላስገቡም።';

  @override
  String get verificationStatus => 'ሁኔታ';

  @override
  String get verificationHint =>
      'መንግስታዊ መታወቂያ እና ሴልፊ ያስገቡ (ለMVP URL)። ስብሰባዎች በተረጋገጡ ህዝባዊ ቦታዎች ብቻ ናቸው።';

  @override
  String get verificationReviewHint =>
      'ማረጋገጫዎች በVELVET ቡድን ይገመገማሉ። ሁኔታዎ ሲቀየር እናሳውቅዎታለን።';

  @override
  String get verificationSubmittedPending =>
      'ለግምገማ ተልኳል። በግምገማ ላይ እያለ እንደገና መጫን አያስፈልግም።';

  @override
  String get verificationApproved => 'መታወቂያዎ ተረጋግጧል።';

  @override
  String get verificationRejected =>
      'ማስገባትዎ እንደገና ግምገማ ይፈልጋል። ከዚህ በታች ያለውን ማስታወሻ ያንብቡ፣ ከዚያ ግልጽ አዲስ ፎቶዎችን ያስገቡ።';

  @override
  String get idDocumentUrl => 'የመታወቂያ URL';

  @override
  String get selfieUrl => 'የሴልፊ URL';

  @override
  String get submitVerification => 'ለግምገማ አስገባ';

  @override
  String get acceptRequest => 'ጥያቄ ተቀበል';

  @override
  String get declineRequest => 'አትቀበል';

  @override
  String get waitingCounterpart => 'ሌላኛው አባል እየጠበቀ ነው';

  @override
  String get openChat => 'ውይይት';

  @override
  String get bookVenue => 'ቦታ ያስይዙ';

  @override
  String get chatTitle => 'ውይይት';

  @override
  String get chatHint => 'ዋጋ፣ ቦታ እና ጊዜ ይስማሙ — ከዚያ booking በመተግበሪያ ውስጥ ይቀርቡ።';

  @override
  String get bookingTitle => 'የግል ቦታ ማስያዝ';

  @override
  String get bookingHint =>
      'ሆቴል፣ ስዊት ወይም የግል መገናኛ በቻት ይስማሙ። ሁለቱም ፈቃድ መስጠት አለባቸው።';

  @override
  String get bookingStatus => 'ሁኔታ';

  @override
  String get selectVenue => 'አጋር ቦታ';

  @override
  String get meetingTime => 'የስብሰባ ሰዓት';

  @override
  String get proposeBooking => 'ስብሰባ አቅርብ';

  @override
  String get confirmBooking => 'ስብሰባ አረጋግጥ';

  @override
  String get upload => 'ሰቅል';

  @override
  String get uploaded => 'ተሰቅሏል';

  @override
  String get notUploaded => 'ገና አልተሰቀለም';

  @override
  String get takePhoto => 'ፎቶ አንሳ';

  @override
  String get chooseGallery => 'ከጋለሪ ምረጥ';

  @override
  String get uploadBothRequired => 'መታወቂያ እና ሴልፊ ሁለቱንም ይስቀሉ።';

  @override
  String get checkIn => 'ግባ';

  @override
  String get checkOut => 'ስብሰባ ጨርስ';

  @override
  String get panicButton => 'አደጋ';

  @override
  String get panicConfirm => 'ኮንሲየርጅ ወዲያውኑ ይነገረው?';

  @override
  String get panicSent => 'ኮንሲየርጅ ተነግሯል።';

  @override
  String get panicSentDetails =>
      'ማንቂያዎ ካለ አካባቢዎ ጋር ተልኳል። አሁን አደጋ ላይ ከሆኑ ወደ የአካባቢዎ የአደጋ አገልግሎት ይደውሉ።';

  @override
  String get membershipTitle => 'አባልነት';

  @override
  String get membershipHint => 'የተረጋገጡ ዝርዝሮችን ይመልከቱ እና በወር booking ጥያቄዎችን ይላኩ።';

  @override
  String get telebirrOnly => 'በቴሌብር በደህንነት ይክፈሉ';

  @override
  String get payWithTelebirr => 'በቴሌብር ክፈል';

  @override
  String get cbePayHint => 'በሲቢኢ ያስተላልፉ፣ ከዚያ የደረሰኝ ስክሪንሾት ይስቀሉ።';

  @override
  String get payWithCbe => 'በሲቢኢ ክፈል';

  @override
  String get cbeTransferTitle => 'ወደ VELVET ያስተላልፉ';

  @override
  String get cbeBank => 'ባንክ';

  @override
  String get cbeAccountName => 'የሂሳብ ስም';

  @override
  String get cbeAccountNumber => 'የሂሳብ ቁጥር';

  @override
  String get amount => 'መጠን';

  @override
  String get orderId => 'ትዕዛዝ';

  @override
  String get uploadCbeReceipt => 'የሲቢኢ ደረሰኝ ስክሪንሾት ስቀል';

  @override
  String get cbePaymentVerified => 'ክፍያ ተረጋገጠ — አባልነት ተነቃ።';

  @override
  String get cbeMockComplete => 'የተረጋገጠ ክፍያ አስመስል (dev)';

  @override
  String get copied => 'ተቀድቷል';

  @override
  String get activePlan => 'ንቁ እቅድ';

  @override
  String get renews => 'እስከ';

  @override
  String get bookingRequestsPerMonth => 'booking ጥያቄዎች / ወር';

  @override
  String get unlimitedBookingRequests => 'ያልተገደበ booking ጥያቄዎች';

  @override
  String get days => 'ቀናት';

  @override
  String get telebirrMockPaid => 'የቴሌብር ሙከራ ክፍያ ተጠናቋል።';

  @override
  String get telebirrOpenFailed => 'የቴሌብር ክፍያ መክፈት አልተቻለም።';

  @override
  String get reportUser => 'ሪፖርት';

  @override
  String get reportHint => 'ምን እንደተከሰተ ይግለጹ';

  @override
  String get reportSubmit => 'ሪፖርት አስገባ';

  @override
  String get reportSent => 'ሪፖርት ወደ ኮንሲየርጅ ተልኳል።';

  @override
  String get openerRequired => 'በተጠቆመ መክፈቻ ይጀምሩ';

  @override
  String get noActiveMembership => 'ንቁ አባልነት የለም';

  @override
  String get messagePendingReview => 'የደህንነት ግምገማ በመጠባበቅ ላይ';

  @override
  String get profilePhotos => 'ፎቶዎች';

  @override
  String get addPhoto => 'ጨምር';

  @override
  String get photoAdded => 'ፎቶ ተጨምሯል';

  @override
  String get removePhoto => 'ፎቶ አስወግድ';

  @override
  String get removePhotoConfirm => 'ይህን የመገለጫ ፎቶ ማስወገድ ይፈልጋሉ? መመለስ አይቻልም።';

  @override
  String get photoPendingReview => 'ፎቶ ተሰቅሏል — የጥራት ግምገማ በመጠባበቅ ላይ።';

  @override
  String get notificationsTitle => 'ማሳወቂያዎች';

  @override
  String get notificationsEmpty => 'ማሳወቂያ የለም';

  @override
  String get markAllRead => 'ሁሉንም አንብብ';

  @override
  String get blockUser => 'አግድ';

  @override
  String get blockConfirm => 'ይህን አባል ያግዱ? ክፍት ግጥሞች እና ውይይት ይዘጋሉ።';

  @override
  String get blockDone => 'አባሉ ታግዷል';

  @override
  String get cancelBooking => 'ስብሰባ ሰርዝ';

  @override
  String get cancelBookingConfirm =>
      'ይህን የቦታ ስብሰባ መሰረዝ ይፈልጋሉ? ተዛማጅዎ እና ቦታው ይነገራቸዋል።';

  @override
  String get bookingCancelled => 'ስብሰባ ተሰርዟል';

  @override
  String get connectionHistoryTitle => 'ያለፉ ግንኙነቶች';

  @override
  String get connectionHistoryEmpty => 'ያለፈ ግንኙነት የለም';

  @override
  String get withdrawAccount => 'መለያ ዝጋ';

  @override
  String get withdrawConfirm => 'ይህ የአባልነት መዳረሻን ያጠፋል። ይወጣሉ።';

  @override
  String get waitlistTitle => 'ግብዣ ጠይቅ';

  @override
  String get waitlistCta => 'ግብዣ የለዎትም? በዝርዝር ይመዝገቡ';

  @override
  String get waitlistHint => 'VELVET በግብዣ ብቻ ነው። ስለራስዎ በአጭሩ ይጻፉ፣ እንገመግማለን።';

  @override
  String get waitlistCity => 'ከተማ';

  @override
  String get waitlistNote => 'ለምን መቀላቀል ይፈልጋሉ';

  @override
  String get waitlistSubmit => 'ማመልከቻ ላክ';

  @override
  String get waitlistThanks => 'በዝርዝሩ ላይ ነዎት';

  @override
  String get waitlistThanksBody => 'ከተፈቀደ ግብዣ እንልካለን። ስልክዎን አቅራቢያ ያኑሩ።';

  @override
  String get reportCategory => 'ምድብ';

  @override
  String get rescheduleBooking => 'እንደገና ቀጠሮ';

  @override
  String get meetingCompleted => 'የተጠናቀቀ ስብሰባ';

  @override
  String get renewSoon => 'አባልነት በቅርብ ያበቃል — browse እና booking ጥያቄ ለመቀጠል ያድሱ።';

  @override
  String get renewNow => 'አባልነት አድስ';

  @override
  String daysRemaining(int days) {
    return '$days ቀናት ቀርተዋል';
  }

  @override
  String get exportMyData => 'መረጃዬን ላክ';

  @override
  String get eraseMyData => 'መረጃዬን አጥፋ';

  @override
  String get eraseConfirm => 'ይህ መለያውን ከመዝጋት በላይ በቋሚነት ያጠፋል። ይወጣሉ።';

  @override
  String get legalMustAccept =>
      'ለመቀጠል የአገልግሎት ውል፣ የግላዊነት ፖሊሲ እና የማህበረሰብ መመሪያዎችን ይቀበሉ።';

  @override
  String get legalAcceptPrefix => '፳፩+ ነኝ፣ እና እቀበላለሁ';

  @override
  String get legalAnd => 'እና';

  @override
  String get termsOfService => 'የአገልግሎት ውል';

  @override
  String get privacyPolicy => 'የግላዊነት ፖሊሲ';

  @override
  String get communityGuidelines => 'የማህበረሰብ መመሪያዎች';

  @override
  String get legalMarketplaceNotice =>
      'ቬልቬት የ፳፩+ የአዋቂዎች ገበያ ነው። ቦታ ማስያዝ በፈቃደኛ አዋቂዎች መካከል ነው — ማስገደድ እና ከ፳፩ በታች የተከለከሉ ናቸው።';

  @override
  String get legalUpdateTitle => 'የተዘመኑ የሕግ ውሎች';

  @override
  String get legalUpdateBody =>
      'ቬልቬትን ለመቀጠል የአሁኑን ውል፣ የግላዊነት ፖሊሲ እና የማህበረሰብ መመሪያዎችን ይገምግሙ እና ይቀበሉ።';

  @override
  String get legalAcceptCta => 'እቀበላለሁ';

  @override
  String get dateOfBirth => 'የትውልድ ቀን';

  @override
  String get bioEn => 'ባዮ (እንግሊዝኛ)';

  @override
  String get bioAm => 'ባዮ (አማርኛ)';

  @override
  String get city => 'ከተማ';

  @override
  String get ageRequirement => 'አባላት ቢያንስ ፳፩ ዓመት መሆን አለባቸው።';

  @override
  String get legalDocuments => 'የሕግ ሰነዶች';

  @override
  String get close => 'ዝጋ';

  @override
  String get chatOpensSoon => 'ውይይት ከስብሰባዎ ፪ ሰዓት በፊት ይከፈታል።';

  @override
  String get chatWindowClosed => 'ይህ ውይይት ተዘግቷል። መልዕክቶች ከስብሰባ መስኮት በኋላ ይወገዳሉ።';

  @override
  String get chatMessageHint => 'የሚፈልጉትን ይጻፉ…';

  @override
  String get attachPhoto => 'ፎቶ';

  @override
  String get attachVideo => 'ቪዲዮ';

  @override
  String get attachAudio => 'የድምጽ ፋይል';

  @override
  String get attachFile => 'ፋይል';

  @override
  String get holdVoiceNote => 'የድምጽ ማስታወሻ ለመቅዳት ተጭነው ይያዙ';

  @override
  String get navMembership => 'አባልነት';

  @override
  String get navSessionPayments => 'ክፍያዎች';

  @override
  String get sessionPaymentsTitle => 'የክፍለ ጊዜ ክፍያ';

  @override
  String get sessionPaymentsSubtitle => 'ምንም አባልነት የለም፤ booking ሲያደርጉ ብቻ ይክፈሉ።';

  @override
  String get sessionPaymentsHeading => 'ለመረጡት ጊዜ ብቻ ይክፈሉ';

  @override
  String get sessionPaymentsBody =>
      'ማሰስ እና መገናኘት ነፃ ነው። እርስዎና አቀንቃኝዋ በክፍለ ጊዜ ሲስማሙ ዋጋውን ያረጋግጡ እና ለዚያ ብቻ booking በደህና ይክፈሉ።';

  @override
  String get navProfile => 'መገለጫ';

  @override
  String get safetyTitle => 'ደህንነት';

  @override
  String get navBrowse => 'ዝርዝር';

  @override
  String get navConversations => 'ውይይቶች';

  @override
  String get navRequests => 'ጥያቄዎች';

  @override
  String get segmentIntros => 'Concierge';

  @override
  String get segmentListings => 'ዝርዝሮች';

  @override
  String get segmentRequests => 'ጥያቄዎች';

  @override
  String get filtersTitle => 'ማጣሪያዎች';

  @override
  String get ageRange => 'የዕድሜ ክልል';

  @override
  String get maxDistance => 'ከፍተኛ ርቀት';

  @override
  String get citiesFilterHint => 'ከተሞች (በኮማ የተለዩ፣ አማራጭ)';

  @override
  String get discoverEmpty => 'አሁን ማጣሪያዎን የሚያሟሉ የተረጋገጡ ዝርዝሮች የሉም።';

  @override
  String get discoverEmptyCta => 'ማጣሪያዎችን ያስተካክሉ';

  @override
  String get conversationsInboxTitle => 'ውይይቶች';

  @override
  String get conversationsInboxEmpty =>
      'እስካሁን ንቁ ውይይት የለም። ዝርዝሮችን ይመልከቱ ወይም ጥያቄዎችን ይመልሱ።';

  @override
  String get conversationsInboxEmptyCtaDiscover => 'ዝርዝሮችን ይመልከቱ';

  @override
  String get conversationsInboxEmptyCtaRequests => 'ጥያቄዎችን ክፈት';

  @override
  String get conversationsInboxHint => 'የእርስዎ ተራ ማለት የbooking ዝርዝር እየጠበቀች ነው።';

  @override
  String get conversationsEmptyPreview => 'በመጀመሪያ ዋጋ፣ ቦታ እና ጊዜ ይስማሙ።';

  @override
  String get yourTurn => 'የእርስዎ ተራ';

  @override
  String get theirTurn => 'የእነሱ ተራ';

  @override
  String get sayHello => 'መልእክት';

  @override
  String get replyNow => 'አሁን መልስ';

  @override
  String get suggestedOpener => 'የተጠቆመ መክፈቻ';

  @override
  String get sendOpener => 'ላኩት';

  @override
  String get typingIndicator => 'እየጻፈች ነው…';

  @override
  String get messageRead => 'ተነብቧል';

  @override
  String get clientRequestsEmpty => 'እስካሁን የደንበኛ ጥያቄ የለም። ዝርዝርዎን እና ዋጋዎን ያዘምኑ።';

  @override
  String get clientRequestsEmptyCta => 'Concierge ክፈት';

  @override
  String get introsEmpty => 'አሁን የConcierge referral የለም።';

  @override
  String get introsEmptyCta => 'ዝርዝር አርትዕ';

  @override
  String get chatEmptyHint => 'ቦoking ከመቀርብ በፊት ዋጋ፣ ቦታ እና ጊዜ ይስማሙ።';

  @override
  String get connectionConfirmedTitle => 'ግንኙነት ተረጋግጧል';

  @override
  String get connectionConfirmedBody =>
      'አሁን መልእክት መላክ እና ግል booking መቀርብ ይችላሉ።';

  @override
  String connectionConfirmedWith(String name) {
    return 'እርስዎ እና $name ተገናኝተዋል።';
  }

  @override
  String get connectionConfirmedNext => 'ጊዜ፣ ቦታ እና ዋጋ ይቀርቡ — booking ይቀርቡ።';

  @override
  String get keepBrowsing => 'ወደ ዝርዝሮች ተመለስ';

  @override
  String get requestNotedPhoto => 'የዝርዝር ፎቶዎን አስተውሏል';

  @override
  String get requestNotedPrompt => 'የዝርዝር ጥያቄዎን አስተውሏል';

  @override
  String get genderMale => 'ወንድ — ደንበኛ';

  @override
  String get genderFemale => 'ሴት — አቀንቃኝ';

  @override
  String get genderRequiredHint =>
      'ሚናዎን በመገለጫ ያዘጋጁ። ወንዶች ዝርዝሮችን ይመልከታሉ፤ ሴቶች ጥያቄዎችን ይመልሳሉ።';

  @override
  String get womenReceiveOnly =>
      'አቀንቃኞች ዝርዝሮችን አይመለከቱም። ጥያቄዎችን ለመመለስ Requests ይክፈቱ።';

  @override
  String get genderLabel => 'ጾታ';

  @override
  String get filterAreas => 'የአዲስ አበባ አካባቢዎች';

  @override
  String get filterLanguages => 'ቋንቋዎች';

  @override
  String get filterIntent => 'የbooking ዓይነት';

  @override
  String get filterVerifiedOnly => 'የተረጋገጡ ብቻ';

  @override
  String get languageAmharic => 'አማርኛ';

  @override
  String get languageEnglish => 'እንግሊዝኛ';

  @override
  String get intentSerious => 'Overnight';

  @override
  String get intentSocial => 'Evening';

  @override
  String get recentPassesTitle => 'በቅርቡ የተዘለሉ';

  @override
  String get recentPassesHint => 'ያለፉ 5 ዝርዝሮች — ማንኛውንም ይመልሱ።';

  @override
  String get recentPassesEmpty => 'በቅርቡ የተዘለሉ ዝርዝሮች የሉም።';

  @override
  String get rewindPass => 'መልስ';

  @override
  String get passRewound => 'ዝርዝሩ ወደ browse feed ተመልሷል።';

  @override
  String get interestSent => 'ፍላጎት ተላከ — ተቀብላ booking መቀርብ ይችላሉ።';

  @override
  String get requestBooking => 'Booking ጠይቅ';

  @override
  String get skipListing => 'ዝለል';

  @override
  String get clientRequestHint => 'booking መጠየቅ ይፈልጋል';

  @override
  String get someoneLabel => 'አባል';

  @override
  String listingDistanceKm(int km) {
    return '$km ኪ.ሜ';
  }

  @override
  String get discoverSubtitleClient => 'የተረጋገጡ አቀንቃኞች — ዋጋ እና supply';

  @override
  String get discoverSubtitlePerformer => 'የደንበኛ ጥያቄዎች ምላሽ በመጠባበቅ ላይ';

  @override
  String get discoverSubtitleLocked =>
      'ዝርዝሮችን ለመመልከት ወይም ጥያቄዎችን ለመቀበል ሚናዎን ያዘጋጁ';

  @override
  String get chatSendHint => 'የሚፈልጉትን ይጻፉ…';

  @override
  String get genderSetupTitle => 'እንዴት ይቀላቀላሉ?';

  @override
  String get genderSetupBody =>
      'ደንበኞች (ወንዶች) የተረጋገጡ አቀንቃኞችን ይመለከታሉ እና የግል ቦታ ማስያዝ ይጠይቃሉ። አቀንቃኞች (ሴቶች) ዋጋ ያስቀምጣሉ እና ይመልሳሉ።';

  @override
  String get genderMustSelect => 'ለመቀጠል ወንድ ወይም ሴት ይምረጡ።';

  @override
  String get profileDetails => 'የመገለጫ ዝርዝር';

  @override
  String get interestsLabel => 'የዝርዝር መለያዎች';

  @override
  String get interestsHint => 'ደንበኞች listingዎን ለማግኘት የሚጠቀሙባቸው መለያዎች።';

  @override
  String get blockedMembers => 'የታገዱ አባላት';

  @override
  String get blockedEmpty => 'ማንንም አላገዱም።';

  @override
  String get unblock => 'አስወግድ';

  @override
  String get unblocked => 'አባሉ ተፈቅዷል';

  @override
  String get openInMaps => 'ካርታ ላይ ክፈት';

  @override
  String get venueAddress => 'አድራሻ';

  @override
  String meetingCountdown(int hours, int minutes) {
    return 'ስብሰባ በ $hoursሰ $minutesደ';
  }

  @override
  String get meetingNow => 'የስብሰባ መስኮት ክፍት ነው';

  @override
  String get chatBookCta => 'የግል ቦታ ማስያዝ አቅድ';

  @override
  String get staffPortalMemberNavHint =>
      'የstaff መለያዎች የድር console ይጠቀማሉ — Browse፣ Requests ወይም Conversations አይደረጉም።';

  @override
  String get staffConsoleHint =>
      'አባላትን፣ ማስተዋወቂያዎችን፣ የደህንነት ሪፖርቶችን እና ስራዎችን ይከታተሉ።';

  @override
  String get adminConsole => 'የአስተዳዳሪ ኮንሶል';

  @override
  String get adminConsoleHint =>
      'አባላትን፣ ማረጋገጫን፣ ቦታዎችን፣ ሪፖርትን እና የመድረክ ስራዎችን ያስተዳድሩ።';

  @override
  String get conciergeConsole => 'የኮንሲየርጅ ኮንሶል';

  @override
  String get conciergeConsoleHint =>
      'ማስተዋወቂያዎችን፣ የአባላት እንክብካቤን እና የደህንነት ክትትልን ያስተባብሩ።';

  @override
  String get accessLevel => 'የመዳረሻ ደረጃ';

  @override
  String get partnerPortal => 'የአጋር ፖርታል';

  @override
  String get partnerPortalHint =>
      'የቦታ ቦታ ማስያዣዎችን፣ check-in እና የአጋር ስራዎችን ያስተዳድሩ።';

  @override
  String get consoleBrowserHint =>
      'ኮንሶሉ በአሳሽዎ ይከፈታል እና የራሱን ደህንነታዊ የሰራተኛ መግቢያ ይጠቀማል።';

  @override
  String get openConsole => 'ኮንሶል ክፈት';

  @override
  String get consoleOpenFailed => 'ኮንሶሉን መክፈት አልተቻለም። እንደገና ይሞክሩ።';

  @override
  String get profileSetupTitle => 'መገለጫዎን ያጠናቅቁ';

  @override
  String get profileSetupBody =>
      'ሶስት ፎቶዎች እና ሁለት አሳቢ መልሶች እያንዳንዱን ማስተዋወቂያ የተሻለ ያደርጉታል።';

  @override
  String profileSetupPhotos(Object count) {
    return '$count ፎቶዎች';
  }

  @override
  String get profileSetupRequired =>
      'ለመቀጠል 3 ፎቶዎችን፣ ከተማዎን እና ሁለቱንም የዝርዝር መግለጫዎች ያክሉ።';

  @override
  String get promptListingEn => 'ለግል booking የምሰጠው (እንግሊዝኛ)';

  @override
  String get promptListingAm => 'ለግል booking የምሰጠው (አማርኛ)';

  @override
  String get promptAnswerEn => 'የዝርዝር መግለጫ በእንግሊዝኛ';

  @override
  String get promptAnswerAm => 'የዝርዝር መግለጫ በአማርኛ';

  @override
  String get profileSetupFinish => 'ዝግጁ ነኝ';

  @override
  String get profileReadyTitle => 'ዝግጁ ነዎት';

  @override
  String get profileReadyBody => 'መገለጫዎ ለትርጉም ያላቸው ማስተዋወቂያዎች ዝግጁ ነው።';

  @override
  String get startDiscovering => 'ዝርዝሮችን ይመልከቱ';

  @override
  String get profileDetailsOptional => 'የዝርዝር ዝርዝሮች (አማራጭ)';

  @override
  String get profileClientHint =>
      'ደንበኞች መሠረታዊ መረጃ ብቻ ይፈልጋሉ — ዝርዝሮችን ከBrowse ትር ይመልከቱ።';

  @override
  String get profileListingSection => 'የእርስዎ listing';

  @override
  String get membershipBenefitBrowse => 'የተረጋገጡ አቀንቃኞችን በዋጋ ይመልከቱ';

  @override
  String get membershipBenefitRequests => 'በወር booking ፍላጎት ጥያቄዎችን ይላኩ';

  @override
  String get membershipBenefitBook => 'ተገናኝተው chat እና booking ይቀርቡ';

  @override
  String get membershipPlanIncludes => 'ያካትታል';

  @override
  String get languagesSpoken => 'የሚናገሩት ቋንቋዎች';

  @override
  String get languagesSpokenHint => 'ለምሳሌ አማርኛ፣ እንግሊዝኛ';

  @override
  String get listingTagsLabel => 'የዝርዝር መለያዎች';

  @override
  String get listingTagsHint => 'በbrowse ላይ በlisting ካርድዎ ላይ የሚታዩ መለያዎች።';

  @override
  String get sessionRateEtb => 'የክፍለ ጊዜ ዋጋ (ብር)';

  @override
  String get overnightRateEtb => 'ለአንድ ሌሊት ዋጋ (ብር)';

  @override
  String get availabilityNote => 'ዝግጁነት';

  @override
  String get listingActive => 'ዝርዝሬን ለደንበኞች አሳይ';

  @override
  String rateSessionLabel(int amount) {
    return 'ከ $amount ብር / ክፍለ ጊዜ';
  }

  @override
  String rateOvernightLabel(int amount) {
    return '$amount ብር ለአንድ ሌሊት';
  }

  @override
  String get performerRatesSection => 'የዝርዝር ዋጋዎች';

  @override
  String get performerRatesHint => 'ደንበኞች በካርድዎ ላይ ያያሉ። ባዶ ከተዉ በቻት ይደራደሩ።';

  @override
  String get safetyCenterTitle => 'የደህንነት ማእከል';

  @override
  String get safetyCenterHint =>
      'አደጋ፣ ማገድ፣ ሪፖርት፣ ጉዞን ለኮንሲየርጅ ማጋራት እና የተረጋገጡ ቦታዎች — በአንድ ቦታ።';

  @override
  String get shareTripWithVelvet => 'ጉዞን ከቬልቬት ጋር አጋራ';

  @override
  String get tripSharedSnack => 'ኮንሲየርጅ ተነግሯል — ደህንነት ይሁንልዎ።';

  @override
  String get verifiedVenues => 'የተረጋገጡ ቦታዎች';

  @override
  String get verifiedVenuesEmpty => 'የተረጋገጡ ቦታዎች እዚህ ይታያሉ።';

  @override
  String get reportMember => 'ሪፖርት';

  @override
  String get reportSubmitted => 'ሪፖርቱ ወደ ኮንሲየርጅ ተልኳል።';

  @override
  String get addToCalendar => 'ወደ ቀን መቁጠሪያ አክል';

  @override
  String get timelinePropose => 'አቅርብ';

  @override
  String get timelineConfirm => 'አረጋግጥ';

  @override
  String get timelineReminder => 'ማስታወሻ';

  @override
  String get timelineCheckIn => 'ግባ';

  @override
  String get timelineCheckout => 'ጨርስ';

  @override
  String get vibeQuiet => 'ጸጥ ያለ';

  @override
  String get vibeBalanced => 'መካከለኛ';

  @override
  String get vibeLively => 'ሕያው';

  @override
  String get meetingFeedbackTitle => 'ስብሰባው እንዴት ነበር?';

  @override
  String get meetingFeedbackHint => 'አጭር መልሶች ማስተዋወቂያዎችን ደህንነታቸውን እንዲጠብቁ ይረዳሉ።';

  @override
  String get feltSafe => 'ደህንነት ተሰምቶዎታል?';

  @override
  String get wouldBookAgain => 'እንደገና ይያዙ?';

  @override
  String get venueOk => 'ቦታው ጥሩ ነበር?';

  @override
  String get optionalNotes => 'ማስታወሻ (አማራጭ)';

  @override
  String get submitFeedback => 'አስገባ';

  @override
  String get feedbackThanks => 'አመሰግናለን — ይረዳል።';

  @override
  String get bookingProposedSnack => 'ስብሰባ ቀርቧል።';

  @override
  String get bookingConfirmedSnack => 'ስብሰባ ተረጋግጧል።';

  @override
  String get cbeStepAmount => '፩ · መጠን';

  @override
  String get cbeStepAccount => '፪ · ማስተላለፍ';

  @override
  String get cbeStepReceipt => '፫ · ደረሰኝ';

  @override
  String get cbeVerifyEta => 'በስራ ሰዓት ውስጥ ብዙውን ጊዜ በ30–60 ደቂቃ ውስጥ ይረጋገጣል።';

  @override
  String get cbeMockLabel => 'ሙከራ ክፍያ (ልማት)';

  @override
  String get cbeLiveLabel => 'ቀጥተኛ የCBE ማስተላለፍ';

  @override
  String get lowBandwidthMode => 'ዝቅተኛ የውሂብ ሁነታ';

  @override
  String get lowBandwidthHint => 'ትንንሽ ፎቶዎች፣ ያነሰ ቪዲዮ — ለዝግ አውታረ መረብ።';

  @override
  String get shareInviteWhatsApp => 'ግብዣን በWhatsApp አጋራ';

  @override
  String get shareInviteWhatsAppGeneric =>
      'VELVET — በAddis የተረጋገጡ ግል booking። ግብዣ ጠይቁኝ።';

  @override
  String shareInviteWhatsAppWithCode(String code) {
    return 'ወደ VELVET ተጋብዘዋል። መተግበሪያውን ክፈቱ እና invite code $code ከ+251 ቁጥርዎ ጋር ያስገቡ።';
  }

  @override
  String get shareWaitlistWhatsAppGeneric =>
      'በVELVET waitlist ላይ ከእኔ ጋር ይቀላቀሉ — በAddis የተረጋገጡ ግል booking።';

  @override
  String shareWaitlistWhatsAppWithCode(String code) {
    return 'ወደ VELVET ተጋብዘዋል። በመተግበሪያው code $code ከ+251 ቁጥርዎ ጋር ይጠቀሙ።';
  }

  @override
  String waitlistFriendsApproved(int count) {
    return '$count ጓደኞች ጸድቀዋል';
  }

  @override
  String get waitlistStatusPending => 'በዝርዝሩ ላይ ነዎት — ሲፈቀድልዎ እንልክልዎታለን።';

  @override
  String get waitlistStatusApproved => 'ጸድቀዋል። የግብዣ ኮድዎን በመጠቀም ይግቡ።';

  @override
  String get waitlistCheckStatus => 'ሁኔታ ይመልከቱ';

  @override
  String get reorderPhotosHint => 'ፎቶ ለማስተካከል በረጅም ይጫኑ። የመጀመሪያው ሽፋን ነው።';

  @override
  String get photosReordered => 'የፎቶ ቅደም ተከተል ተቀምጧል።';

  @override
  String get makeCoverPhoto => 'ሽፋን አድርግ';

  @override
  String get meetupPlace => 'ሆቴል / ስዊት / የመገናኛ ቦታ';

  @override
  String get meetupPlaceHint => 'ለምሳሌ Skylight ሆቴል · ክፍል በግል';

  @override
  String get rateTypeSession => 'ምሽት / ክፍለ ጊዜ';

  @override
  String get rateTypeOvernight => 'ለአንድ ሌሊት';

  @override
  String bookingAmount(int amount) {
    return '$amount ብር';
  }

  @override
  String get payBooking => 'ቦታ ማስያዝ ክፈል';

  @override
  String get bookingPaid => 'የቦታ ማስያዝ ክፍያ ተረጋግጧል።';

  @override
  String get paymentStatusLabel => 'ክፍያ';

  @override
  String get paymentUnpaid => 'ያልተከፈለ';

  @override
  String get paymentPending => 'ክፍያ በመጠባበቅ ላይ';

  @override
  String get paymentPaid => 'ተከፍሏል';

  @override
  String get paymentWaived => 'ክፍያ የለም';

  @override
  String get earningsTitle => 'ገቢ';

  @override
  String earningsHint(int percent) {
    return 'ከእያንዳንዱ የተከፈለ ቦታ ማስያዝ $percent% ይቀራችኋል። የመድረክ ክፍያ ክፍያዎችንና ደህንነትን ይሸፍናል።';
  }

  @override
  String get earningsAvailable => 'ያለ ገንዘብ';

  @override
  String get earningsLifetime => 'ጠቅላላ ያገኙት';

  @override
  String get earningsPaidOut => 'የተከፈለ';

  @override
  String get earningsActivity => 'እንቅስቃሴ';

  @override
  String get earningsEmpty => 'ገና ገቢ የለም — የተከፈሉ ቦታ ማስያዣዎች እዚህ ይታከላሉ።';

  @override
  String get earningsCredit => 'የቦታ ማስያዝ ክሬዲት';

  @override
  String get earningsPayout => 'ክፍያ ማውጣት';

  @override
  String get requestPayout => 'ክፍያ ጠይቅ';

  @override
  String get payoutAmount => 'መጠን (ብር)';

  @override
  String get payoutDestination => 'የCBE / Telebirr መለያ ማስታወሻ';

  @override
  String get payoutMinAmount => 'ዝቅተኛ ክፍያ 50 ብር ነው።';

  @override
  String get payoutRequested => 'ክፍያ ተጠይቋል — ኮንሲየርጅ ያስተናግዳል።';

  @override
  String get listingRequiresVerification =>
      'ዝርዝርዎ ለደንበኞች ከመታየቱ በፊት የመታወቂያ ማረጋገጫ መጽደቅ አለበት።';

  @override
  String get verifyToListCta => 'ለመታየት መታወቂያ ያረጋግጡ';

  @override
  String get availabilityCalendarTitle => 'የዝግጁነት ቀን መቁጠሪያ';

  @override
  String get availabilityCalendarHint =>
      'ደንበኞች በክፍት መስኮቶችዎ ውስጥ ብቻ ማስያዝ ይችላሉ። ክፍለ ጊዜ 3 ሰዓት፤ ሌሊት 12 ሰዓት በመስኮት ውስጥ መሆን አለበት።';

  @override
  String get availabilityDay => 'ቀን';

  @override
  String get availabilityStart => 'መጀመሪያ';

  @override
  String get availabilityEnd => 'መጨረሻ';

  @override
  String get availabilityWindowNote => 'ማስታወሻ (አማራጭ)';

  @override
  String get availabilityAddWindow => 'መስኮት ጨምር';

  @override
  String get availabilityUpcoming => 'መጪ መስኮቶች';

  @override
  String get availabilityEmpty => 'ክፍት መስኮት የለም — ምሽቶችን ወይም ሌሊቶችን ይጨምሩ።';

  @override
  String get availabilityAdded => 'የዝግጁነት መስኮት ተጨምሯል።';

  @override
  String get availabilityMustBeFuture => 'መጀመሪያ ጊዜ ወደፊት መሆን አለበት።';

  @override
  String get navListing => 'ዝርዝር';

  @override
  String get membershipRequiredBrowse => 'ተረጋግጠው ያሉ አቀንቃኞችን ለማየት አባልነት ያስፈልጋል።';

  @override
  String get bookingNoAvailability =>
      'ክፍት የዝግጁነት መስኮት የለም — ጊዜ እንድታትም ጠይቁ ወይም ቆይተው ይሞክሩ።';

  @override
  String get performerReadyTitle => 'ቀጥታ ይውጡ';

  @override
  String get performerReadyHint =>
      'ደንበኞች እንዲያገኙዎት እና እንዲያስይዙ እነዚህን ደረጃዎች ያጠናቅቁ።';

  @override
  String get readyStepVerify => 'መታወቂያዎን ያረጋግጡ';

  @override
  String get readyStepVerifyDone => 'ተረጋግጧል — ደንበኞች ዝርዝርዎን ማመን ይችላሉ።';

  @override
  String get readyStepVerifyTodo => 'ለአስተዳዳሪ ግምገማ መታወቂያ እና ሴልፊ ይጭኑ።';

  @override
  String get readyStepRates => 'ዋጋዎን ያዘጋጁ';

  @override
  String readyStepRatesDone(int session, int overnight) {
    return 'ክፍለ ጊዜ $session ብር · ሌሊት $overnight ብር';
  }

  @override
  String get readyStepRatesTodo => 'በመገለጫዎ ላይ የክፍለ ጊዜ እና/ወይም የሌሊት ዋጋዎችን ይጨምሩ።';

  @override
  String get readyStepCalendar => 'ዝግጁነት ያትሙ';

  @override
  String readyStepCalendarDone(int count) {
    return '$count ክፍት መስኮቶች';
  }

  @override
  String get readyStepCalendarTodo => 'ደንበኞች ሊያስይዙ የሚችሉ ምሽቶችን ወይም ሌሊቶችን ይጨምሩ።';

  @override
  String get readyStepPhotos => 'የlisting ፎቶዎች ያክሉ';

  @override
  String readyStepPhotosDone(int count) {
    return '$count ፎቶዎች በlisting ላይ';
  }

  @override
  String get readyStepPhotosTodo => 'ቢያንስ 3 ፎቶዎችን ይስቀሉ።';

  @override
  String get readyStepListing => 'የlisting መግለጫ ይጻፉ';

  @override
  String get readyStepListingDone => 'የእንግሊዝኛ እና አማርኛ መግለጫዎች ተዘጋጅተዋል።';

  @override
  String get readyStepListingTodo => 'በመገለጫ ላይ ሁለቱንም listing መግለጫዎች ያክሉ።';

  @override
  String readyProgressLabel(int done, int total) {
    return '$done ከ $total ተጠናቋል';
  }

  @override
  String get readyGoLiveHint => 'በBrowse ለመታየት ሲዘጋጁ ያብሩ።';

  @override
  String get readyFinishStepsFirst => 'መጀመሪያ ማረጋገጫ፣ ዋጋ እና ቀን መቁጠሪያን ያጠናቅቁ።';

  @override
  String get readyLiveBanner => 'ዝርዝርዎ ቀጥታ ነው — ደንበኞች ማየትና ማስያዝ ይችላሉ።';

  @override
  String get listingNowLive => 'ዝርዝር ቀጥታ ነው።';

  @override
  String get listingNowHidden => 'ዝርዝር ከደንበኞች ተደብቋል።';

  @override
  String get flowNextBookTitle => 'ቀጣይ ምርጥ እርምጃ፡ ዕቅዱን አረጋግጥ';

  @override
  String get flowNextBookBody =>
      'ዝርዝሩ ሙሉ እስካለ ድረስ ጊዜ፣ ቦታ እና ዋጋ በbooking ያስቀምጡ።';

  @override
  String get flowNextPayTitle => 'ቀጣይ ምርጥ እርምጃ፡ ክፍያውን ጨርስ';

  @override
  String get flowNextPayBody => 'ክፍያ ሲጠናቀቅ booking ፍጹም እንዲሆን ይረዳል።';

  @override
  String get flowNextConfirmTitle => 'ቀጣይ ምርጥ እርምጃ፡ ዝርዝሩን አረጋግጥ';

  @override
  String get flowNextConfirmBody =>
      'ይህን booking አሁን አረጋግጡ፣ ከዚያ ዝርዝሩን በቻት ያጠናቅቁ።';

  @override
  String get flowNextChatTitle => 'ቀጣይ ምርጥ እርምጃ፡ በቻት ያስማሙ';

  @override
  String get flowNextChatBody => 'ቻት ክፈቱ እና ዋጋ፣ ቦታ፣ ጊዜ እና ወሰኖችን ያረጋግጡ።';

  @override
  String get flowNextArriveTitle => 'ቀጣይ ምርጥ እርምጃ፡ በደህና ድረስ';

  @override
  String get flowNextArriveBody => 'ወደ ቦታው ሲቀርቡ ጉዞን ያጋሩ ወይም check-in ያድርጉ።';

  @override
  String get flowFocusConfirmHint => 'booking በመስመር ላይ እንዲቆይ ይህን አሁን ያረጋግጡ።';

  @override
  String get flowFocusPayHint => 'booking ፍጹም እንዲሆን ክፍያውን አሁን ያጠናቅቁ።';

  @override
  String get flowFocusPayDoneHint => 'ክፍያ ተረጋግጧል። ወደ ቻት ሂዱና ዝርዝሩን ያጠናቅቁ።';

  @override
  String get quickBookNow => 'አሁን አስይዝ';

  @override
  String get quickSendRatePrompt => 'የዋጋ ጥያቄ ላክ';

  @override
  String get quickSendBookingSummary => 'የbooking ማጠቃለያ ላክ';

  @override
  String get quickSendCheckinLineLabel => 'የcheck-in ሐረግ ላክ';

  @override
  String get quickSendAftercareLineLabel => 'የኋላ እንክብካቤ ሐረግ ላክ';

  @override
  String get quickAskPlace => 'ቦታ ጠይቅ';

  @override
  String get quickRatePromptLine => 'የክፍለ ጊዜ እና የሌሊት ዋጋዎን ያጋሩ?';

  @override
  String get quickPlacePromptLine => 'ለዛሬ ማታ የሚመች ቦታ የት ነው?';

  @override
  String get quickBookingSummaryLine => 'ለእኔ የሚመች እንደዚህ ነው፡';

  @override
  String get quickSendCheckinLine =>
      'አሁን check-in አድርጌአለሁ። ሲዘጋጁ ይምጡ እና ሲደርሱ መልዕክት ይላኩ።';

  @override
  String get quickSendAftercareLine =>
      'ለዛሬ ማታ አመሰግናለሁ። እንደገና ለመያዝ ከፈለጉ ቀጣዩን booking እናስይዝ።';

  @override
  String get flowPostCheckoutTitle => 'ይህ ከመዘጋቱ በፊት';

  @override
  String get flowPostCheckoutBody =>
      'ለደህንነት feedback ይስጡ ወይም ግንኙነትዎ ሲቀርብ ቀጣዩን booking ያቀርቡ።';

  @override
  String get welcomeTitle => 'Velvet እንዴት እንደሚሰራ';

  @override
  String get welcomeBodyClient =>
      'ተረጋግጠው ያሉ ዝርዝሮችን ይመልከቱ፣ ፍላጎት ይጠይቁ፣ ከዚያም ግል booking ያቀርቡና ይክፈሉ — ሁሉ በአንድ ቦታ።';

  @override
  String get welcomeBodyPerformer =>
      'ዝርዝርዎን ያትሙ፣ ቀን መቁጠሪያዎን ይክፈቱ፣ እና ደንበኞች ጥያቄ ሲያቀርቡ ይመልሱ።';

  @override
  String get welcomeStepBrowse => 'ዝርዝሮችን ይመልከቱ';

  @override
  String get welcomeStepBrowseBody => 'በእያንዳንዱ መገለጫ ዋጋ፣ ዝግጁነት እና ማረጋገጫ ይመልከቱ።';

  @override
  String get welcomeStepRequest => 'booking ጠይቅ';

  @override
  String get welcomeStepRequestBody => 'የሚፈልጉትን ዝርዝር ፍላጎት ይላኩ — ግምት የለም።';

  @override
  String get welcomeStepBook => 'ያቀርቡ እና ይክፈሉ';

  @override
  String get welcomeStepBookBody => 'ሲገናኙ ቻት ያድርጉ እና ጊዜ፣ ቦታ እና ክፍያን ያረጋግጡ።';

  @override
  String get welcomeStepListing => 'ዝርዝርዎን ያጠናቅቁ';

  @override
  String get welcomeStepListingBody =>
      'ፎቶዎች፣ ዋጋዎች እና መግለጫዎች ደንበኞች እንዲታመኑ እና እንዲመርጡዎት ይረዳሉ።';

  @override
  String get welcomeStepCalendar => 'ቀን መቁጠሪያዎን ይክፈቱ';

  @override
  String get welcomeStepCalendarBody => 'ደንበኞች ሊያስይዙ የሚችሉ ምሽቶችን ወይም ሌሊቶችን ያትሙ።';

  @override
  String get welcomeStepRequests => 'ጥያቄዎችን ይመልሱ';

  @override
  String get welcomeStepRequestsBody =>
      'ከRequests inbox የሚመጡ ፍላጎቶችን ተቀበል ወይም ውድቅ አድርግ።';

  @override
  String get welcomeCta => 'ጀምር';

  @override
  String get discoverCoachTitle => 'የbooking ፍሰትዎ';

  @override
  String get discoverCoachBody =>
      'ዝርዝሮችን ይመልከቱ → ፍላጎት ይጠይቁ → ቻት → booking ያቀርቡ። የማይመች profile ይዘልቁ።';

  @override
  String get flowHintBrowse => 'Browse';

  @override
  String get flowHintRequest => 'ጥያቄ';

  @override
  String get flowHintBook => 'Booking';

  @override
  String get flowHintRespond => 'መልስ';

  @override
  String get conversationsEmptyFlowHint =>
      'መጀመሪያ በlisting ላይ ፍላጎት ይላኩ — ከተገናኙ በኋላ conversations ይከፈታሉ።';

  @override
  String get listingSession => 'ክፍለ ጊዜ';

  @override
  String get listingOvernight => 'ምሽት';

  @override
  String get listingAbout => 'ኃይሏ';

  @override
  String get listingClose => 'ዝጋ';

  @override
  String listingEtbAmount(int amount) {
    return '$amount ብር';
  }
}

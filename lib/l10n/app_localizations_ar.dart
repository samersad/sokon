// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class AppLocalizationsAr extends AppLocalizations {
  AppLocalizationsAr([String locale = 'ar']) : super(locale);

  @override
  String get findBestRecommendations =>
      'اعثر على أفضل الأماكن الموصى بها للعيش';

  @override
  String get featuredEstates => 'العقارات المميزة';

  @override
  String get nearbyEstate => 'عقارات مجاورة';

  @override
  String get viewAll => 'عرض الكل';

  @override
  String get viewAllOnMap => 'عرض جميع الشقق على الخريطة';

  @override
  String get apartmentsOnMap => 'الشقق على الخريطة';

  @override
  String get noFeaturedEstates => 'لا توجد عقارات مميزة متاحة';

  @override
  String get noNearbyEstates => 'لا توجد عقارات مجاورة متاحة';

  @override
  String get noEstatesFound => 'لم يتم العثور على عقارات.';

  @override
  String get notVerified => 'غير موثق';

  @override
  String get verified => 'موثق';

  @override
  String get notVerifiedBanner =>
      'هذه الشقة لم يتم توثيقها بعد من قبل مسؤول Sokon.';

  @override
  String get lookingFor => 'تبحث عن';

  @override
  String get recent => 'الأحدث';

  @override
  String get recentSearch => 'عمليات البحث الأخيرة';

  @override
  String get noApartmentsFound => 'لم يتم العثور على شقق';

  @override
  String apartmentsCount(Object count) {
    return '$count شقة';
  }

  @override
  String apartmentsInDistrictCount(Object count) {
    return '$count شقة في هذا الحي';
  }

  @override
  String apartmentsOnMapCount(Object count) {
    return '$count شقة بمواقع على الخريطة';
  }

  @override
  String get topLocation => 'أبرز المواقع';

  @override
  String get noDistrictsFound => 'لم يتم العثور على أحياء';

  @override
  String get noDistrictsAvailable => 'لا توجد أحياء متاحة';

  @override
  String get districtsRanked => 'الأحياء مرتبة حسب عدد الشقق المتوفرة بها';

  @override
  String get aboutThisApartment => 'عن هذه الشقة';

  @override
  String get about => 'عن';

  @override
  String get facilities => 'المرافق';

  @override
  String get bedrooms => 'غرف النوم';

  @override
  String get bathrooms => 'دورات المياه';

  @override
  String get livingRooms => 'غرف المعيشة';

  @override
  String get bedroom => 'غرفة نوم';

  @override
  String get bathtub => 'حوض استحمام';

  @override
  String floor(Object floor) {
    return 'الطابق $floor';
  }

  @override
  String get forRent => 'للإيجار';

  @override
  String get forSale => 'للبيع';

  @override
  String get noDescription => 'لا يوجد وصف متاح.';

  @override
  String get description => 'التفاصيل.';

  @override
  String get ownerContactNotAvailable => 'معلومات الاتصال بالمالك غير متوفرة';

  @override
  String get ownerNoAddress => 'لم يضف المالك عنوانًا بعد.';

  @override
  String get rentNow => 'استأجر الآن';

  @override
  String reviewsCount(Object count) {
    return '($count تقييمات)';
  }

  @override
  String get ratingSaved => 'تم حفظ التقييم بنجاح';

  @override
  String failedToSaveRating(Object error) {
    return 'فشل حفظ التقييم: $error';
  }

  @override
  String get alreadyRented =>
      'لقد قمت بالفعل باستئجار هذه الشقة. يمكنك حجزها مرة أخرى بعد انتهاء الفترة الحالية.';

  @override
  String get pleaseLoginToBook => 'يرجى تسجيل الدخول للحجز';

  @override
  String get openInMap => 'فتح في الخريطة';

  @override
  String get takeLookInside => 'ألقِ نظرة بالداخل';

  @override
  String get confirmAndPay => 'تأكيد ودفع الإيجار';

  @override
  String get selectDate => 'اختر التاريخ';

  @override
  String get selectDateRange => 'يرجى تحديد نطاق زمني';

  @override
  String get priceDetails => 'تفاصيل السعر';

  @override
  String get monthlyPayment => 'الدفع الشهري';

  @override
  String get tax => 'الضرائب';

  @override
  String get total => 'الإجمالي';

  @override
  String get totalPrice => 'السعر الإجمالي';

  @override
  String get payment => 'الدفع';

  @override
  String get payments => 'المدفوعات';

  @override
  String get cardHolder => 'حامل البطاقة';

  @override
  String get cardNumber => 'رقم البطاقة';

  @override
  String get expiryDate => 'تاريخ الانتهاء';

  @override
  String get validThru => 'صالح حتى';

  @override
  String get enterVoucher => 'أدخل قسيمة';

  @override
  String get checkDateBeforePayment =>
      'تأكد من مراجعة التواريخ قبل إجراء أي عملية دفع';

  @override
  String get noCardAdded => 'لم يتم إضافة بطاقة';

  @override
  String get myBank => 'مصرفي';

  @override
  String get addCard => 'إضافة بطاقة';

  @override
  String get addCardSuccess => 'تم إضافة البطاقة بنجاح';

  @override
  String get bookingSuccessTitle => 'رائع، تم الحجز بنجاح';

  @override
  String get bookingSuccessSub => 'لقد قمت بحجز العقار بنجاح، استمتع بإقامتك';

  @override
  String get period => 'الفترة';

  @override
  String get periodTime => 'مدة الإقامة';

  @override
  String get people => 'الأشخاص';

  @override
  String peopleCount(Object count) {
    return 'عدد الأشخاص: $count';
  }

  @override
  String get rateYourStay => 'قيم إقامتك';

  @override
  String get yourRating => 'تقييمك';

  @override
  String get editProfile => 'تعديل الملف الشخصي';

  @override
  String get profileUpdated => 'تم تحديث الملف الشخصي بنجاح';

  @override
  String get saveChanges => 'حفظ التغييرات';

  @override
  String get myApartments => 'شققي';

  @override
  String get myBookings => 'حجوزاتي';

  @override
  String get bookingRequests => 'طلبات الحجز';

  @override
  String get noBookingsFound => 'لم يتم العثور على حجوزات';

  @override
  String get noApartmentsListed =>
      'لم تقم بإدراج أي شقق بعد.\nابدأ بإضافة عقارك الأول!';

  @override
  String get trackYourApartmentBookings => 'تتبع حجوزات شققك';

  @override
  String get reviewLiveBookingActivity => 'راجع نشاط الحجز المباشر لشققك';

  @override
  String get manageYourProperties => 'إدارة عقاراتك';

  @override
  String get newBookingActivity =>
      'ستظهر أنشطة الحجز الجديدة لشققك هنا في الوقت الفعلي.';

  @override
  String get noBookingRequestsYet => 'لا توجد طلبات حجز بعد';

  @override
  String get pleaseLoginToSeeBookings => 'يرجى تسجيل الدخول لمشاهدة حجوزاتك';

  @override
  String get pleaseLoginToManageRequests =>
      'يرجى تسجيل الدخول لإدارة طلبات الحجز الخاصة بك';

  @override
  String get accept => 'قبول';

  @override
  String get reject => 'رفض';

  @override
  String get acceptBooking => 'قبول الحجز';

  @override
  String get rejectBooking => 'رفض الحجز';

  @override
  String get cancelBooking => 'إلغاء الحجز';

  @override
  String get confirmAcceptBooking => 'هل تريد قبول طلب الحجز هذا؟';

  @override
  String get confirmRejectBooking => 'هل تريد رفض طلب الحجز هذا؟';

  @override
  String get confirmCancelBooking => 'هل تريد إلغاء هذا الحجز؟';

  @override
  String get confirmCancelBookingRequest => 'هل تريد إلغاء طلب الحجز هذا؟';

  @override
  String get bookingAccepted => 'تم قبول الحجز';

  @override
  String get bookingCancelled => 'تم إلغاء الحجز';

  @override
  String get bookingRejected => 'تم رفض الحجز';

  @override
  String failedToCancelBooking(Object error) {
    return 'فشل إلغاء الحجز: $error';
  }

  @override
  String failedToUpdateBooking(Object error) {
    return 'فشل تحديث الحجز: $error';
  }

  @override
  String get deleteAccount => 'حذف الحساب';

  @override
  String get deleteAccountTitle => 'حذف حسابك نهائيًا؟';

  @override
  String get deleteAccountWarning =>
      'هذا الإجراء دائم ولا يمكن التراجع عنه. سيتم حذف جميع بياناتك بما في ذلك الشقق والحجوزات والمحادثات والإشعارات للأبد.';

  @override
  String get accountDeletedSuccess => 'تم حذف الحساب بنجاح';

  @override
  String get addNewListing => 'إضافة عقار جديد';

  @override
  String get editListing => 'تعديل العقار';

  @override
  String get addApartment => 'إضافة شقة';

  @override
  String get updateApartment => 'تحديث الشقة';

  @override
  String get basicInformation => 'المعلومات الأساسية';

  @override
  String get apartmentNameLabel => 'اسم الشقة';

  @override
  String get apartmentNameHint =>
      'يرجى تقديم اسم واضح ومختصر للشقة (مثال: \'استوديو خاص مريح بالقرب من كلية الهندسة\'). سيتم عرضه في القوائم.';

  @override
  String get apartmentNameRequired => 'اسم الشقة مطلوب';

  @override
  String get propertyDetails => 'تفاصيل العقار';

  @override
  String get propertyDetailsHint =>
      'صف تفاصيل العقار. اذكر المرافق المضمنة، القوانين، تفاصيل السكن المشترك، مبلغ التأمين، والمسافة إلى الجامعات.';

  @override
  String get propertyDetailsPlaceholder =>
      'صف ميزات العقار، الإطلالة، والمرافق المضمنة...';

  @override
  String get propertyType => 'نوع العقار';

  @override
  String get monthlyPriceLabel => 'الإيجار الشهري (بالجنيه المصري)';

  @override
  String get monthlyPriceHint =>
      'أدخل سعر الإيجار شهريًا بالجنيه المصري. يرجى تحري الدقة في تحديد السعر.';

  @override
  String get selectFloor =>
      'اختر الطابق الذي تقع فيه الشقة (مثال: الطابق الأرضي = 0، الطابق الأول = 1، إلخ).';

  @override
  String get selectBathrooms =>
      'حدد عدد دورات المياه الصالحة للاستخدام الكامل.';

  @override
  String get selectBedrooms => 'حدد عدد غرف النوم.';

  @override
  String get selectLivingRooms => 'حدد عدد غرف المعيشة الصالحة للاستخدام.';

  @override
  String get livingCapacity => 'السعة الاستيعابية (الأشخاص)';

  @override
  String get selectLivingCapacity =>
      'حدد الحد الأقصى لعدد الأشخاص المسموح لهم بالاستئجار والعيش معًا في هذه الشقة.';

  @override
  String get locationDetails => 'تفاصيل الموقع';

  @override
  String get city => 'المدينة';

  @override
  String get selectCity => 'اختر المدينة التي تقع فيها الشقة.';

  @override
  String get district => 'الحي / المنطقة';

  @override
  String get selectDistrict =>
      'اختر الحي أو المنطقة التي تقع فيها الشقة لمساعدة المستخدمين على البحث بالقرب منها.';

  @override
  String get streetAddressLabel => 'اسم ورقم الشارع';

  @override
  String get streetAddressHint =>
      'أدخل عنوان الشارع بالتفصيل، رقم المبنى، ورقم الشقة لسهولة وصول المستأجرين إليها.';

  @override
  String get pickApartmentLocation => 'تحديد موقع الشقة';

  @override
  String get tapMapToPlaceMarker => 'اضغط على الخريطة لوضع علامة موقع الشقة.';

  @override
  String get confirmLocation => 'تأكيد الموقع';

  @override
  String get addPhotos => 'إضافة صور';

  @override
  String get previewSelectedPhotos => 'معاينة الصور المحددة';

  @override
  String get pleaseAddOneImage => 'يرجى إضافة صورة واحدة على الأقل';

  @override
  String get addVideo => 'إضافة فيديو';

  @override
  String get videoAdded => 'تم إضافة الفيديو';

  @override
  String get videoDurationLimit => 'يجب ألا تتجاوز مدة الفيديو 10 دقائق.';

  @override
  String get savingApartmentData => 'جاري حفظ بيانات الشقة...';

  @override
  String get updatingApartmentData => 'جاري تحديث بيانات الشقة...';

  @override
  String get deleteListingTitle => 'حذف العقار';

  @override
  String get deleteListingConfirm =>
      'هل أنت متأكد من رغبتك في حذف هذا العقار؟ لا يمكن التراجع عن هذا الإجراء وسيتم إزالة العقار فورًا.';

  @override
  String get pleaseLoginBeforeAdding =>
      'يرجى تسجيل الدخول مرة أخرى قبل إضافة شقة.';

  @override
  String get pleaseLoginBeforeUpdating =>
      'يرجى تسجيل الدخول مرة أخرى قبل تحديث هذه الشقة.';

  @override
  String get capacityLowerThanRenters =>
      'لا يمكن أن تكون سعة الأشخاص أقل من عدد المستأجرين الحاليين لهذه الشقة.';

  @override
  String onlyAvailableCapacity(Object count) {
    return 'يمكن إضافة $count أشخاص فقط إلى هذه الشقة في الوقت الحالي.';
  }

  @override
  String get peopleRenting => 'المستأجرون الحاليون';

  @override
  String get fullyBooked => 'ممتلئة بالكامل';

  @override
  String get thisApartmentFullyBooked => 'هذه الشقة ممتلئة بالكامل.';

  @override
  String get pickYourLocation => 'حدد موقعك';

  @override
  String get tapMapConfirmLocation => 'اضغط على الخريطة، ثم أكد موقعك.';

  @override
  String get confirm => 'تأكيد';

  @override
  String get loadingSelectedAddress => 'جاري تحميل العنوان المحدد...';

  @override
  String selectedOnMap(Object address) {
    return 'المحدد على الخريطة: $address';
  }

  @override
  String get noLocationSelected => 'لم يتم تحديد موقع بعد.';

  @override
  String get myLocation => 'موقعي';

  @override
  String get userLocation => 'موقع المستخدم';

  @override
  String get startConversation => 'ابدأ المحادثة الآن';

  @override
  String get typeMessage => 'اكتب رسالة...';

  @override
  String get noMessages => 'لا توجد رسائل بعد';

  @override
  String get savedChat => 'محادثة محفوظة';

  @override
  String get sentPhoto => 'أرسل صورة';

  @override
  String get unableToSendPhoto => 'تعذر إرسال الصورة';

  @override
  String errorLoadingChats(Object error) {
    return 'خطأ أثناء تحميل المحادثات: $error';
  }

  @override
  String get camera => 'الكاميرا';

  @override
  String get gallery => 'المعرض';

  @override
  String get chooseFromGallery => 'اختر من المعرض';

  @override
  String get takePhoto => 'التقاط صورة';

  @override
  String get cancel => 'إلغاء';

  @override
  String get edit => 'تعديل';

  @override
  String get delete => 'حذف';

  @override
  String get ok => 'حسنًا';

  @override
  String get yes => 'نعم';

  @override
  String get no => 'لا';

  @override
  String get submit => 'إرسال';

  @override
  String get continueButton => 'متابعة';

  @override
  String get finish => 'إنهاء';

  @override
  String get apply => 'تطبيق';

  @override
  String get reset => 'إعادة تعيين';

  @override
  String get loading => 'جاري التحميل...';

  @override
  String get processing => 'جاري المعالجة...';

  @override
  String get pleaseWait => 'يرجى الانتظار...';

  @override
  String get somethingWentWrong => 'حدث خطأ ما';

  @override
  String errorLabel(Object error) {
    return 'خطأ: $error';
  }

  @override
  String get noAddress => 'لا يوجد عنوان';

  @override
  String get noName => 'بلا اسم';

  @override
  String get noEmail => 'بلا بريد إلكتروني';

  @override
  String get unknown => 'غير معروف';

  @override
  String get videoPlaybackFailed => 'فشل تشغيل الفيديو.';

  @override
  String get videoPlaybackUnavailable => 'تشغيل الفيديو غير متوفر.';

  @override
  String get couldNotOpenGoogleMaps => 'تعذر فتح خرائط Google';

  @override
  String get selectUniversity => 'حدد جامعتك لكي تظهر لك الشقق القريبة منها';

  @override
  String get assiutUniversity => 'جامعة أسيوط';

  @override
  String get assiutNationalUniversity => 'جامعة أسيوط الأهلية';

  @override
  String get badrUniversityAssiut => 'جامعة بدر بأسيوط';

  @override
  String get fieldRequired => 'هذا الحقل مطلوب';

  @override
  String get enterValidEmail => 'أدخل بريدًا إلكترونيًا صالحًا';

  @override
  String get passwordValidation =>
      'يجب أن تتكون كلمة المرور من 8 أحرف على الأقل وتشمل حروفًا وأرقامًا';

  @override
  String get passwordsNotMatching => 'كلمتا المرور غير متطابقتين';

  @override
  String get enterValidUsername => 'أدخل اسم مستخدم صالحًا';

  @override
  String get enterNumbersOnly => 'أدخل أرقامًا فقط';

  @override
  String get phoneValidation => 'يجب أن يتكون رقم الهاتف من 11 رقمًا';

  @override
  String get forgotPassword => 'هل نسيت كلمة المرور؟';

  @override
  String get enterEmailAddress => 'أدخل عنوان بريدك الإلكتروني';

  @override
  String get newPassword => 'كلمة المرور الجديدة';

  @override
  String get confirmNewPassword => 'تأكيد كلمة المرور الجديدة';

  @override
  String get selectYourRole => 'اختر دورك';

  @override
  String get owner => 'مالك';

  @override
  String get client => 'عميل';

  @override
  String get signUp => 'تسجيل جديد';

  @override
  String get username => 'اسم المستخدم';

  @override
  String get role => 'الدور';

  @override
  String get college => 'الكلية';

  @override
  String get phoneNumber => 'رقم الهاتف';

  @override
  String get confirmPassword => 'تأكيد كلمة المرور';

  @override
  String get selectedMedia => 'الوسائط المحددة';

  @override
  String get apartmentNameHintText => 'مثال: استوديو حديث في وسط المدينة';

  @override
  String get zeroPriceHint => '0.00';

  @override
  String get assiutHint => 'مثال: أسيوط';

  @override
  String get cityHint => 'مثال: المدينة';

  @override
  String get noVideoAvailable => 'لا يوجد فيديو متاح';

  @override
  String get address => 'العنوان';

  @override
  String get booking => 'حجز';

  @override
  String get date => 'التاريخ';

  @override
  String get noApartmentsInDistrict => 'لم يتم العثور على شقق في هذا الحي';

  @override
  String get noFeaturedApartmentsFound => 'لم يتم العثور على شقق مميزة';

  @override
  String get noApartmentsFoundNearby => 'لم يتم العثور على شقق';

  @override
  String get announcement => 'إعلان';

  @override
  String get newApartment => 'شقة جديدة';

  @override
  String get bookingRequestReceived => 'تم استلام طلب حجز';

  @override
  String get bookingApproved => 'تمت الموافقة على الحجز';

  @override
  String get newMessage => 'رسالة جديدة';

  @override
  String get fit => 'مناسب';

  @override
  String get messages => 'الرسائل';

  @override
  String get search => 'بحث';

  @override
  String get cardNumberPlaceholder => 'XXXX XXXX XXXX XXXX';

  @override
  String get expiryDatePlaceholder => 'MM/YY';

  @override
  String get cvvLabel => 'رمز الأمان (CVV)';

  @override
  String get cvvPlaceholder => 'XXX';

  @override
  String get acceptedStatus => 'مقبول';

  @override
  String get cancelledStatus => 'ملغى';

  @override
  String get pendingStatus => 'معلق';

  @override
  String get bookingIdRequired => 'معرف الحجز مطلوب';

  @override
  String get gender => 'الجنس';

  @override
  String get searchPlaceholder => 'بحث...';

  @override
  String get result => 'النتيجة';

  @override
  String get priceRange => 'نطاق السعر';

  @override
  String get language => 'اللغة';

  @override
  String get english => 'الإنجليزية';

  @override
  String get arabic => 'العربية';

  @override
  String get login => 'تسجيل الدخول';

  @override
  String get email => 'البريد الإلكتروني';

  @override
  String get password => 'كلمة المرور';

  @override
  String get dontHaveAccount => 'ليس لديك حساب؟';

  @override
  String get haveAccount => 'لديك حساب؟';

  @override
  String get settings => 'الإعدادات';

  @override
  String get theme => 'المظهر';

  @override
  String get lightMode => 'الوضع الفاتح';

  @override
  String get darkMode => 'الوضع الداكن';

  @override
  String get light => 'فاتح';

  @override
  String get dark => 'داكن';

  @override
  String get logout => 'تسجيل الخروج';

  @override
  String get notification => 'الإشعارات';

  @override
  String get aboutMenu => 'حول التطبيق';

  @override
  String get success => 'نجاح';

  @override
  String get error => 'خطأ';

  @override
  String get dismiss => 'إغلاق';

  @override
  String get close => 'إغلاق';

  @override
  String get uploading => 'جاري الرفع...';

  @override
  String get updating => 'جاري التحديث...';

  @override
  String get sendingOtp => 'جاري إرسال رمز التحقق...';

  @override
  String get verifyingOtp => 'جاري التحقق من الرمز...';

  @override
  String get updatingPassword => 'جاري تحديث كلمة المرور...';

  @override
  String get apartmentAddedSuccess => 'تمت إضافة الشقة بنجاح';

  @override
  String get apartmentUpdatedSuccess => 'تم تحديث الشقة بنجاح';

  @override
  String get pleaseEnterPassword => 'يرجى إدخال كلمة المرور';

  @override
  String get enterPasswordToConfirm => 'أدخل كلمة المرور للتأكيد:';

  @override
  String get passwordResetSuccess =>
      'تم إعادة تعيين كلمة المرور بنجاح. يرجى تسجيل الدخول باستخدام كلمة المرور الجديدة.';

  @override
  String get verification => 'التحقق';

  @override
  String get verificationDesc =>
      '* سنرسل لك رسالة لإعادة تعيين كلمة المرور الخاصة بك';

  @override
  String get enterCodeSent => 'أدخل الرمز المكون من 6 أرقام المرسل إلى:';

  @override
  String resendCodeIn(Object seconds) {
    return 'إعادة إرسال الرمز خلال $seconds ثانية';
  }

  @override
  String get resendCode => 'إعادة إرسال الرمز';

  @override
  String get register => 'تسجيل';

  @override
  String get pleaseSelectRole => 'يرجى اختيار دور';

  @override
  String get male => 'ذكر';

  @override
  String get female => 'أنثى';

  @override
  String get pleaseFillAllFields => 'يرجى ملء جميع الحقول';

  @override
  String get invalidEmailOrPassword =>
      'البريد الإلكتروني أو كلمة المرور غير صالحة';

  @override
  String get failedToUploadImage => 'فشل رفع الصورة';

  @override
  String get failedToUploadVideo => 'فشل رفع الفيديو';

  @override
  String get egp => 'جم';

  @override
  String get justNow => 'الآن';

  @override
  String minutesAgo(Object count) {
    return 'منذ $count دقيقة';
  }

  @override
  String hoursAgo(Object count) {
    return 'منذ $count ساعة';
  }

  @override
  String daysAgo(Object count) {
    return 'منذ $count أيام';
  }
}

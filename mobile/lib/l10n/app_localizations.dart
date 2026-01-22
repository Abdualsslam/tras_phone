import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
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
/// import 'l10n/app_localizations.dart';
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

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
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
    Locale('ar'),
    Locale('en'),
  ];

  /// اسم التطبيق
  ///
  /// In ar, this message translates to:
  /// **'تراس فون'**
  String get appName;

  /// عنصر التنقل للصفحة الرئيسية
  ///
  /// In ar, this message translates to:
  /// **'الرئيسية'**
  String get home;

  /// عنوان قسم الأقسام
  ///
  /// In ar, this message translates to:
  /// **'الأقسام'**
  String get categories;

  /// عنوان قسم الماركات
  ///
  /// In ar, this message translates to:
  /// **'الماركات'**
  String get brands;

  /// عنوان قسم المنتجات المميزة
  ///
  /// In ar, this message translates to:
  /// **'منتجات مميزة'**
  String get featuredProducts;

  /// عنوان قسم المنتجات الجديدة
  ///
  /// In ar, this message translates to:
  /// **'وصل حديثاً'**
  String get newArrivals;

  /// عنوان قسم الأكثر مبيعاً
  ///
  /// In ar, this message translates to:
  /// **'الأكثر مبيعاً'**
  String get bestSellers;

  /// زر عرض الكل
  ///
  /// In ar, this message translates to:
  /// **'عرض الكل'**
  String get viewAll;

  /// زر التسوق
  ///
  /// In ar, this message translates to:
  /// **'تسوق الآن'**
  String get shopNow;

  /// عنوان البحث
  ///
  /// In ar, this message translates to:
  /// **'بحث'**
  String get search;

  /// نص تلميح البحث
  ///
  /// In ar, this message translates to:
  /// **'ابحث عن منتجات...'**
  String get searchHint;

  /// عنوان الإشعارات
  ///
  /// In ar, this message translates to:
  /// **'الإشعارات'**
  String get notifications;

  /// عنوان السلة
  ///
  /// In ar, this message translates to:
  /// **'السلة'**
  String get cart;

  /// عنوان الملف الشخصي
  ///
  /// In ar, this message translates to:
  /// **'الملف الشخصي'**
  String get profile;

  /// عنوان الإعدادات
  ///
  /// In ar, this message translates to:
  /// **'الإعدادات'**
  String get settings;

  /// عنوان إعداد اللغة
  ///
  /// In ar, this message translates to:
  /// **'اللغة'**
  String get language;

  /// اسم اللغة العربية
  ///
  /// In ar, this message translates to:
  /// **'العربية'**
  String get arabic;

  /// اسم اللغة الإنجليزية
  ///
  /// In ar, this message translates to:
  /// **'English'**
  String get english;

  /// عنوان الطلبات
  ///
  /// In ar, this message translates to:
  /// **'طلباتي'**
  String get orders;

  /// عنوان المفضلة
  ///
  /// In ar, this message translates to:
  /// **'المفضلة'**
  String get wishlist;

  /// عنوان قائمة المفضلة
  ///
  /// In ar, this message translates to:
  /// **'المفضلة'**
  String get favorites;

  /// رسالة عدم وجود إشعارات
  ///
  /// In ar, this message translates to:
  /// **'لا توجد إشعارات'**
  String get noNotifications;

  /// عنوان المحفظة
  ///
  /// In ar, this message translates to:
  /// **'المحفظة'**
  String get wallet;

  /// عنوان العناوين
  ///
  /// In ar, this message translates to:
  /// **'العناوين'**
  String get addresses;

  /// عنوان الدعم الفني
  ///
  /// In ar, this message translates to:
  /// **'الدعم الفني'**
  String get support;

  /// عنوان صفحة من نحن
  ///
  /// In ar, this message translates to:
  /// **'من نحن'**
  String get aboutUs;

  /// عنوان سياسة الخصوصية
  ///
  /// In ar, this message translates to:
  /// **'سياسة الخصوصية'**
  String get privacyPolicy;

  /// عنوان الشروط والأحكام
  ///
  /// In ar, this message translates to:
  /// **'الشروط والأحكام'**
  String get termsAndConditions;

  /// زر تسجيل الخروج
  ///
  /// In ar, this message translates to:
  /// **'تسجيل الخروج'**
  String get logout;

  /// زر تسجيل الدخول
  ///
  /// In ar, this message translates to:
  /// **'تسجيل الدخول'**
  String get login;

  /// زر إنشاء حساب
  ///
  /// In ar, this message translates to:
  /// **'إنشاء حساب'**
  String get register;

  /// حقل رقم الهاتف
  ///
  /// In ar, this message translates to:
  /// **'رقم الهاتف'**
  String get phone;

  /// حقل كلمة المرور
  ///
  /// In ar, this message translates to:
  /// **'كلمة المرور'**
  String get password;

  /// حقل تأكيد كلمة المرور
  ///
  /// In ar, this message translates to:
  /// **'تأكيد كلمة المرور'**
  String get confirmPassword;

  /// حقل الاسم
  ///
  /// In ar, this message translates to:
  /// **'الاسم'**
  String get name;

  /// حقل البريد الإلكتروني
  ///
  /// In ar, this message translates to:
  /// **'البريد الإلكتروني'**
  String get email;

  /// رابط نسيت كلمة المرور
  ///
  /// In ar, this message translates to:
  /// **'نسيت كلمة المرور؟'**
  String get forgotPassword;

  /// عنوان صفحة تأكيد الرمز
  ///
  /// In ar, this message translates to:
  /// **'تأكيد الرمز'**
  String get verifyOtp;

  /// رسالة إرسال رمز التحقق
  ///
  /// In ar, this message translates to:
  /// **'تم إرسال رمز التحقق إلى'**
  String get otpSent;

  /// زر إعادة إرسال الرمز
  ///
  /// In ar, this message translates to:
  /// **'إعادة إرسال الرمز'**
  String get resendOtp;

  /// زر التحقق
  ///
  /// In ar, this message translates to:
  /// **'تحقق'**
  String get verify;

  /// زر الإضافة للسلة
  ///
  /// In ar, this message translates to:
  /// **'أضف للسلة'**
  String get addToCart;

  /// رسالة تأكيد الإضافة للسلة
  ///
  /// In ar, this message translates to:
  /// **'تمت الإضافة للسلة'**
  String get addedToCart;

  /// زر الشراء الآن
  ///
  /// In ar, this message translates to:
  /// **'اشتر الآن'**
  String get buyNow;

  /// عنوان تفاصيل المنتج
  ///
  /// In ar, this message translates to:
  /// **'تفاصيل المنتج'**
  String get productDetails;

  /// عنوان الوصف
  ///
  /// In ar, this message translates to:
  /// **'الوصف'**
  String get description;

  /// عنوان المواصفات
  ///
  /// In ar, this message translates to:
  /// **'المواصفات'**
  String get specifications;

  /// عنوان التقييمات
  ///
  /// In ar, this message translates to:
  /// **'التقييمات'**
  String get reviews;

  /// حالة المنتج المتوفر
  ///
  /// In ar, this message translates to:
  /// **'متوفر'**
  String get inStock;

  /// حالة المنتج غير المتوفر
  ///
  /// In ar, this message translates to:
  /// **'غير متوفر'**
  String get outOfStock;

  /// عنوان الكمية
  ///
  /// In ar, this message translates to:
  /// **'الكمية'**
  String get quantity;

  /// عنوان الإجمالي
  ///
  /// In ar, this message translates to:
  /// **'الإجمالي'**
  String get total;

  /// عنوان المجموع الفرعي
  ///
  /// In ar, this message translates to:
  /// **'المجموع الفرعي'**
  String get subtotal;

  /// عنوان الشحن
  ///
  /// In ar, this message translates to:
  /// **'الشحن'**
  String get shipping;

  /// عنوان الخصم
  ///
  /// In ar, this message translates to:
  /// **'الخصم'**
  String get discount;

  /// زر إتمام الطلب
  ///
  /// In ar, this message translates to:
  /// **'إتمام الطلب'**
  String get checkout;

  /// زر متابعة التسوق
  ///
  /// In ar, this message translates to:
  /// **'متابعة التسوق'**
  String get continueShopping;

  /// رسالة السلة الفارغة
  ///
  /// In ar, this message translates to:
  /// **'السلة فارغة'**
  String get emptyCart;

  /// رسالة نجاح الطلب
  ///
  /// In ar, this message translates to:
  /// **'تم تقديم الطلب بنجاح'**
  String get orderPlaced;

  /// عنوان رقم الطلب
  ///
  /// In ar, this message translates to:
  /// **'رقم الطلب'**
  String get orderNumber;

  /// عنوان حالة الطلب
  ///
  /// In ar, this message translates to:
  /// **'حالة الطلب'**
  String get orderStatus;

  /// حالة الطلب قيد الانتظار
  ///
  /// In ar, this message translates to:
  /// **'قيد الانتظار'**
  String get pending;

  /// حالة الطلب مؤكد
  ///
  /// In ar, this message translates to:
  /// **'مؤكد'**
  String get confirmed;

  /// حالة الطلب قيد المعالجة
  ///
  /// In ar, this message translates to:
  /// **'قيد المعالجة'**
  String get processing;

  /// حالة الطلب تم الشحن
  ///
  /// In ar, this message translates to:
  /// **'تم الشحن'**
  String get shipped;

  /// حالة الطلب تم التوصيل
  ///
  /// In ar, this message translates to:
  /// **'تم التوصيل'**
  String get delivered;

  /// حالة الطلب ملغي
  ///
  /// In ar, this message translates to:
  /// **'ملغي'**
  String get cancelled;

  /// رسالة خطأ عامة
  ///
  /// In ar, this message translates to:
  /// **'حدث خطأ'**
  String get error;

  /// زر إعادة المحاولة
  ///
  /// In ar, this message translates to:
  /// **'حاول مرة أخرى'**
  String get tryAgain;

  /// رسالة عدم وجود نتائج
  ///
  /// In ar, this message translates to:
  /// **'لا توجد نتائج'**
  String get noResults;

  /// رسالة التحميل
  ///
  /// In ar, this message translates to:
  /// **'جاري التحميل...'**
  String get loading;

  /// رسالة نجاح عامة
  ///
  /// In ar, this message translates to:
  /// **'تمت العملية بنجاح'**
  String get success;

  /// زر الإلغاء
  ///
  /// In ar, this message translates to:
  /// **'إلغاء'**
  String get cancel;

  /// زر التأكيد
  ///
  /// In ar, this message translates to:
  /// **'تأكيد'**
  String get confirm;

  /// زر الحفظ
  ///
  /// In ar, this message translates to:
  /// **'حفظ'**
  String get save;

  /// زر التعديل
  ///
  /// In ar, this message translates to:
  /// **'تعديل'**
  String get edit;

  /// زر الحذف
  ///
  /// In ar, this message translates to:
  /// **'حذف'**
  String get delete;

  /// زر الإغلاق
  ///
  /// In ar, this message translates to:
  /// **'إغلاق'**
  String get close;

  /// رمز العملة
  ///
  /// In ar, this message translates to:
  /// **'ر.س'**
  String get currency;

  /// عنوان الأسئلة الشائعة
  ///
  /// In ar, this message translates to:
  /// **'الأسئلة الشائعة'**
  String get faq;

  /// عنوان المركز التعليمي
  ///
  /// In ar, this message translates to:
  /// **'المركز التعليمي'**
  String get education;

  /// عنوان المرتجعات
  ///
  /// In ar, this message translates to:
  /// **'المرتجعات'**
  String get returns;

  /// عنوان الفاتورة
  ///
  /// In ar, this message translates to:
  /// **'الفاتورة'**
  String get invoice;

  /// عنوان الأجهزة
  ///
  /// In ar, this message translates to:
  /// **'الأجهزة'**
  String get devices;

  /// عنوان المنتجات
  ///
  /// In ar, this message translates to:
  /// **'المنتجات'**
  String get products;

  /// زر التصفية
  ///
  /// In ar, this message translates to:
  /// **'تصفية'**
  String get filter;

  /// زر الترتيب
  ///
  /// In ar, this message translates to:
  /// **'ترتيب'**
  String get sort;

  /// خيار الترتيب حسب السعر تنازلياً
  ///
  /// In ar, this message translates to:
  /// **'السعر: من الأعلى للأقل'**
  String get priceHighToLow;

  /// خيار الترتيب حسب السعر تصاعدياً
  ///
  /// In ar, this message translates to:
  /// **'السعر: من الأقل للأعلى'**
  String get priceLowToHigh;

  /// خيار الترتيب حسب الأحدث
  ///
  /// In ar, this message translates to:
  /// **'الأحدث'**
  String get newest;

  /// عنوان طريقة الدفع
  ///
  /// In ar, this message translates to:
  /// **'طريقة الدفع'**
  String get paymentMethod;

  /// خيار الدفع عند الاستلام
  ///
  /// In ar, this message translates to:
  /// **'الدفع عند الاستلام'**
  String get cashOnDelivery;

  /// خيار التحويل البنكي
  ///
  /// In ar, this message translates to:
  /// **'تحويل بنكي'**
  String get bankTransfer;

  /// خيار الدفع من المحفظة
  ///
  /// In ar, this message translates to:
  /// **'الدفع من المحفظة'**
  String get walletPayment;

  /// عنوان تغيير كلمة المرور
  ///
  /// In ar, this message translates to:
  /// **'تغيير كلمة المرور'**
  String get changePassword;

  /// حقل كلمة المرور الحالية
  ///
  /// In ar, this message translates to:
  /// **'كلمة المرور الحالية'**
  String get currentPassword;

  /// حقل كلمة المرور الجديدة
  ///
  /// In ar, this message translates to:
  /// **'كلمة المرور الجديدة'**
  String get newPassword;

  /// عنوان تعديل الملف الشخصي
  ///
  /// In ar, this message translates to:
  /// **'تعديل الملف الشخصي'**
  String get editProfile;

  /// زر إضافة عنوان
  ///
  /// In ar, this message translates to:
  /// **'إضافة عنوان'**
  String get addAddress;

  /// عنوان تعديل العنوان
  ///
  /// In ar, this message translates to:
  /// **'تعديل العنوان'**
  String get editAddress;

  /// حقل المدينة
  ///
  /// In ar, this message translates to:
  /// **'المدينة'**
  String get city;

  /// حقل الشارع
  ///
  /// In ar, this message translates to:
  /// **'الشارع'**
  String get street;

  /// حقل المبنى
  ///
  /// In ar, this message translates to:
  /// **'المبنى'**
  String get building;

  /// حقل الطابق
  ///
  /// In ar, this message translates to:
  /// **'الطابق'**
  String get floor;

  /// حقل الشقة
  ///
  /// In ar, this message translates to:
  /// **'الشقة'**
  String get apartment;

  /// حقل الملاحظات
  ///
  /// In ar, this message translates to:
  /// **'ملاحظات'**
  String get notes;

  /// خيار تعيين كعنوان افتراضي
  ///
  /// In ar, this message translates to:
  /// **'تعيين كعنوان افتراضي'**
  String get setAsDefault;

  /// رسالة خطأ الحقل المطلوب
  ///
  /// In ar, this message translates to:
  /// **'هذا الحقل مطلوب'**
  String get required;

  /// رسالة خطأ رقم الهاتف
  ///
  /// In ar, this message translates to:
  /// **'رقم الهاتف غير صالح'**
  String get invalidPhone;

  /// رسالة خطأ البريد الإلكتروني
  ///
  /// In ar, this message translates to:
  /// **'البريد الإلكتروني غير صالح'**
  String get invalidEmail;

  /// رسالة خطأ كلمة المرور القصيرة
  ///
  /// In ar, this message translates to:
  /// **'كلمة المرور قصيرة جداً'**
  String get passwordTooShort;

  /// رسالة خطأ عدم تطابق كلمات المرور
  ///
  /// In ar, this message translates to:
  /// **'كلمات المرور غير متطابقة'**
  String get passwordsDoNotMatch;

  /// عنوان تذاكر الدعم
  ///
  /// In ar, this message translates to:
  /// **'تذاكر الدعم'**
  String get supportTickets;

  /// زر إنشاء تذكرة جديدة
  ///
  /// In ar, this message translates to:
  /// **'إنشاء تذكرة'**
  String get createTicket;

  /// عنوان رقم التذكرة
  ///
  /// In ar, this message translates to:
  /// **'رقم التذكرة'**
  String get ticketNumber;

  /// حقل موضوع التذكرة
  ///
  /// In ar, this message translates to:
  /// **'موضوع التذكرة'**
  String get ticketSubject;

  /// حقل وصف المشكلة
  ///
  /// In ar, this message translates to:
  /// **'وصف المشكلة'**
  String get ticketDescription;

  /// عنوان فئة التذكرة
  ///
  /// In ar, this message translates to:
  /// **'فئة التذكرة'**
  String get ticketCategory;

  /// عنوان أولوية التذكرة
  ///
  /// In ar, this message translates to:
  /// **'أولوية التذكرة'**
  String get ticketPriority;

  /// عنوان حالة التذكرة
  ///
  /// In ar, this message translates to:
  /// **'حالة التذكرة'**
  String get ticketStatus;

  /// عنوان رسائل التذكرة
  ///
  /// In ar, this message translates to:
  /// **'رسائل التذكرة'**
  String get ticketMessages;

  /// زر إرسال رسالة
  ///
  /// In ar, this message translates to:
  /// **'إرسال رسالة'**
  String get sendMessage;

  /// نص تلميح حقل الرسالة
  ///
  /// In ar, this message translates to:
  /// **'اكتب رسالتك...'**
  String get typeMessage;

  /// عنوان المرفقات
  ///
  /// In ar, this message translates to:
  /// **'المرفقات'**
  String get attachments;

  /// زر إضافة مرفق
  ///
  /// In ar, this message translates to:
  /// **'إضافة مرفق'**
  String get addAttachment;

  /// عنوان تقييم التذكرة
  ///
  /// In ar, this message translates to:
  /// **'قيم التذكرة'**
  String get rateTicket;

  /// عنوان تقييم الخدمة
  ///
  /// In ar, this message translates to:
  /// **'قيم الخدمة'**
  String get rateService;

  /// عنوان المحادثة المباشرة
  ///
  /// In ar, this message translates to:
  /// **'المحادثة المباشرة'**
  String get liveChat;

  /// زر بدء المحادثة
  ///
  /// In ar, this message translates to:
  /// **'بدء المحادثة'**
  String get startChat;

  /// زر إنهاء المحادثة
  ///
  /// In ar, this message translates to:
  /// **'إنهاء المحادثة'**
  String get endChat;

  /// حالة الانتظار في المحادثة
  ///
  /// In ar, this message translates to:
  /// **'في الانتظار'**
  String get chatWaiting;

  /// حالة المحادثة النشطة
  ///
  /// In ar, this message translates to:
  /// **'نشطة'**
  String get chatActive;

  /// حالة المحادثة المنتهية
  ///
  /// In ar, this message translates to:
  /// **'منتهية'**
  String get chatEnded;

  /// رسالة عدم وجود تذاكر
  ///
  /// In ar, this message translates to:
  /// **'لا توجد تذاكر'**
  String get noTickets;

  /// رسالة عدم وجود رسائل
  ///
  /// In ar, this message translates to:
  /// **'لا توجد رسائل'**
  String get noMessages;

  /// رسالة نجاح إنشاء التذكرة
  ///
  /// In ar, this message translates to:
  /// **'تم إنشاء التذكرة بنجاح'**
  String get ticketCreated;

  /// رسالة نجاح إرسال الرسالة
  ///
  /// In ar, this message translates to:
  /// **'تم إرسال الرسالة'**
  String get messageSent;

  /// رسالة نجاح التقييم
  ///
  /// In ar, this message translates to:
  /// **'شكراً لتقييمك'**
  String get ratingSubmitted;

  /// رسالة اختيار الفئة
  ///
  /// In ar, this message translates to:
  /// **'اختر فئة التذكرة'**
  String get selectCategory;

  /// رسالة إدخال الموضوع
  ///
  /// In ar, this message translates to:
  /// **'أدخل موضوع التذكرة'**
  String get enterSubject;

  /// رسالة إدخال الوصف
  ///
  /// In ar, this message translates to:
  /// **'أدخل وصف المشكلة'**
  String get enterDescription;
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
      <String>['ar', 'en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return AppLocalizationsAr();
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

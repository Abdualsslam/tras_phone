part of 'api_client.dart';

class _ApiClientSupport {
  final Dio dio;
  final LocalStorage? localStorage;

  const _ApiClientSupport({required this.dio, required this.localStorage});

  static const Map<String, String> _arabicTranslations = {
    'Your account is under review. Please wait for activation':
        'حسابك قيد المراجعة. يرجى انتظار التفعيل',
    'Your account has been rejected': 'تم رفض حسابك',
    'Invalid credentials':
        'رقم الجوال أو كلمة المرور غير صحيحة. يرجى المحاولة مرة أخرى',
    'User not found': 'المستخدم غير موجود',
    'Account is locked': 'الحساب مقفل',
    'Account suspended': 'الحساب معلق',
    'Email already exists': 'البريد الإلكتروني مستخدم بالفعل',
    'Phone number already exists': 'رقم الهاتف مستخدم بالفعل',
    'User with this phone or email already exists':
        'المستخدم موجود بالفعل. رقم الجوال أو البريد الإلكتروني مستخدم',
    'Invalid token': 'رمز غير صحيح',
    'Token expired': 'انتهت صلاحية الرمز',
    'Unauthorized': 'غير مصرح',
    'Forbidden': 'غير مسموح',
    'Not found': 'غير موجود',
    'Internal server error': 'خطأ في الخادم',
    'Bad request': 'طلب غير صحيح',
    'Validation error': 'خطأ في التحقق',
  };

  void configureCertificatePinning() {
    if (!AppConfig.enableCertificatePinning ||
        AppConfig.baseUri.scheme != 'https') {
      return;
    }

    final pins = <String>{
      if (AppConfig.apiCertSha256Pin.isNotEmpty) AppConfig.apiCertSha256Pin,
      if (AppConfig.apiCertBackupSha256Pin.isNotEmpty)
        AppConfig.apiCertBackupSha256Pin,
    };

    if (pins.isEmpty) return;

    dio.httpClientAdapter = IOHttpClientAdapter(
      createHttpClient: () => HttpClient(),
      validateCertificate: (certificate, host, port) {
        if (certificate == null) return false;
        if (host != AppConfig.baseUri.host) return true;

        final fingerprint = base64UrlEncode(
          sha256.convert(certificate.der).bytes,
        ).replaceAll('=', '');
        return pins.contains(fingerprint);
      },
    );
  }

  String getCurrentLocale() {
    final savedLocale = localStorage?.getString(StorageKeys.locale);
    if (savedLocale != null && savedLocale.isNotEmpty) {
      return normalizeLocaleCode(savedLocale);
    }
    return 'ar';
  }

  String normalizeLocaleCode(String locale) {
    final normalized = locale.trim().toLowerCase();
    if (normalized.startsWith('ar')) return 'ar';
    if (normalized.startsWith('en')) return 'en';
    return normalized.split(RegExp(r'[-_]')).first;
  }

  String translateError(String englishMessage) {
    if (getCurrentLocale() != 'ar') {
      return englishMessage;
    }
    return _arabicTranslations[englishMessage] ?? englishMessage;
  }

  String extractMessage(dynamic value, {required String fallbackMessage}) {
    if (value is String) return value;
    if (value is List) {
      return value.map((item) => item.toString()).join(', ');
    }
    return value?.toString() ?? fallbackMessage;
  }

  String get defaultArabicServerError => 'خطأ في الخادم';
  String get defaultEnglishServerError => 'Server error';
  String get retryableArabicServerError => 'خطأ في الخادم، يرجى المحاولة لاحقاً';
}

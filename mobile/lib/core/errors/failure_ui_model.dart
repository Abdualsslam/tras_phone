library;

import '../../l10n/app_localizations.dart';
import 'failures.dart';

enum FailureDisplayType { snackbar, fullPage, inline }

class FailureUiModel {
  final String title;
  final String message;
  final String retryLabel;
  final FailureDisplayType displayType;
  final bool isRetryable;
  final bool isNetworkRelated;

  const FailureUiModel({
    required this.title,
    required this.message,
    required this.retryLabel,
    required this.displayType,
    required this.isRetryable,
    required this.isNetworkRelated,
  });

  factory FailureUiModel.fromFailure(
    Failure failure,
    AppLocalizations l10n, {
    FailureDisplayType? preferredDisplayType,
  }) {
    final isArabic = l10n.localeName.startsWith('ar');

    String title = l10n.error;
    String message = failure.message;
    var isRetryable = false;
    var isNetworkRelated = false;
    var displayType =
        preferredDisplayType ?? FailureDisplayType.fullPage;

    if (failure is NetworkFailure) {
      title = isArabic ? 'لا يوجد اتصال' : 'No Connection';
      message = isArabic
          ? 'تحقق من اتصالك بالإنترنت وحاول مرة أخرى'
          : 'Please check your internet connection and try again';
      isRetryable = true;
      isNetworkRelated = true;
      displayType = preferredDisplayType ?? FailureDisplayType.fullPage;
    } else if (failure is TimeoutFailure) {
      title = isArabic ? 'انتهت المهلة' : 'Request Timed Out';
      message = isArabic
          ? 'استغرق الطلب وقتاً أطول من المتوقع. حاول مرة أخرى.'
          : 'The request took too long. Please try again.';
      isRetryable = true;
      displayType = preferredDisplayType ?? FailureDisplayType.fullPage;
    } else if (failure is ValidationFailure) {
      title = isArabic ? 'تحقق من البيانات' : 'Check Your Input';
      displayType = preferredDisplayType ?? FailureDisplayType.inline;
    } else if (failure is AuthFailure) {
      title = isArabic ? 'تعذر تنفيذ العملية' : 'Action Failed';
      displayType = preferredDisplayType ?? FailureDisplayType.snackbar;
    } else if (failure is NotFoundFailure) {
      title = isArabic ? 'غير موجود' : 'Not Found';
    } else if (failure is ServerFailure) {
      title = isArabic ? 'حدث خطأ في الخادم' : 'Server Error';
      isRetryable = true;
    } else if (failure is CacheFailure) {
      title = isArabic ? 'تعذر تحميل البيانات' : 'Unable to Load Data';
      isRetryable = true;
    }

    return FailureUiModel(
      title: title,
      message: message,
      retryLabel: l10n.retryAction,
      displayType: displayType,
      isRetryable: isRetryable,
      isNetworkRelated: isNetworkRelated,
    );
  }
}

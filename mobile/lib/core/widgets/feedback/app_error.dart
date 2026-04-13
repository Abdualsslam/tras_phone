/// AppError - Error display widgets
library;

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iconsax/iconsax.dart';

import '../../../l10n/app_localizations.dart';
import '../../config/theme/app_colors.dart';
import '../../errors/failure_ui_model.dart';
import '../../errors/failures.dart';
import '../buttons/app_button.dart';

/// Full page error state
class AppError extends StatelessWidget {
  final String? title;
  final String? message;
  final String? buttonText;
  final VoidCallback? onRetry;
  final IconData? icon;
  final Failure? failure;

  const AppError({
    super.key,
    this.title,
    this.message,
    this.buttonText,
    this.onRetry,
    this.icon,
    this.failure,
  }) : assert(
         message != null || failure != null,
         'Either message or failure must be provided.',
       );

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context)!;
    final uiModel = failure == null
        ? null
        : FailureUiModel.fromFailure(failure!, l10n);
    final resolvedMessage = uiModel?.message ?? _cleanMessage(message!);
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';
    final isNetwork = uiModel?.isNetworkRelated == true ||
        resolvedMessage.toLowerCase().contains('network') ||
        resolvedMessage.contains('اتصال') ||
        resolvedMessage.toLowerCase().contains('internet') ||
        resolvedMessage.toLowerCase().contains('socketexception') ||
        resolvedMessage.toLowerCase().contains('no connection');

    final displayIcon =
        isNetwork ? Icons.wifi_off_rounded : (icon ?? Iconsax.warning_2);
    final displayTitle =
        title ?? uiModel?.title ?? (isArabic ? 'حدث خطأ' : 'Error');
    final displayButtonText =
        buttonText ?? uiModel?.retryLabel ?? l10n.retryAction;
    final containerColor = isNetwork
        ? AppColors.warning.withValues(alpha: 0.1)
        : AppColors.error.withValues(alpha: 0.1);
    final iconColor = isNetwork ? AppColors.warning : AppColors.error;

    return Center(
      child: Padding(
        padding: EdgeInsets.all(24.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80.w,
              height: 80.w,
              decoration: BoxDecoration(
                color: containerColor,
                shape: BoxShape.circle,
              ),
              child: Icon(displayIcon, size: 40.sp, color: iconColor),
            ),
            SizedBox(height: 24.h),
            Text(
              displayTitle,
              style: TextStyle(
                fontSize: 20.sp,
                fontWeight: FontWeight.w600,
                color: isDark
                    ? AppColors.textPrimaryDark
                    : AppColors.textPrimaryLight,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 8.h),
            Text(
              resolvedMessage,
              style: TextStyle(
                fontSize: 15.sp,
                color: isDark
                    ? AppColors.textSecondaryDark
                    : AppColors.textSecondaryLight,
              ),
              textAlign: TextAlign.center,
            ),
            if (onRetry != null) ...[
              SizedBox(height: 32.h),
              AppButton(
                text: displayButtonText,
                onPressed: onRetry,
                isFullWidth: false,
                size: AppButtonSize.medium,
                icon: Iconsax.refresh,
              ),
            ],
          ],
        ),
      ),
    );
  }

  static String _cleanMessage(String message) {
    var clean = message;
    final prefixes = [
      'AppException:',
      'ServerException:',
      'NetworkException:',
      'CacheException:',
      'AuthException:',
      'UnauthorizedException:',
      'ConflictException:',
      'ValidationException:',
      'Exception:',
      'Failure:',
    ];
    for (final prefix in prefixes) {
      if (clean.contains(prefix)) {
        clean = clean.split(prefix).last.trim();
        break;
      }
    }

    if (clean.contains('(code:')) {
      clean = clean.split('(code:').first.trim();
    }

    if (clean.startsWith('Exception: ')) {
      clean = clean.substring(11).trim();
    }

    return clean;
  }
}

/// Network error state
class NetworkError extends StatelessWidget {
  final VoidCallback? onRetry;

  const NetworkError({super.key, this.onRetry});

  @override
  Widget build(BuildContext context) {
    return AppError(
      icon: Icons.wifi_off_rounded,
      failure: const NetworkFailure(),
      onRetry: onRetry,
    );
  }
}

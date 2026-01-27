/// Language Settings Screen - Change app language
library;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iconsax/iconsax.dart';
import '../../../../core/config/theme/app_colors.dart';
import '../../../../core/cubit/locale_cubit.dart';
import '../../../../l10n/app_localizations.dart';

class LanguageSettingsScreen extends StatefulWidget {
  const LanguageSettingsScreen({super.key});

  @override
  State<LanguageSettingsScreen> createState() => _LanguageSettingsScreenState();
}

class _LanguageSettingsScreenState extends State<LanguageSettingsScreen> {
  final List<Map<String, String>> _languages = [
    {'code': 'ar', 'name': 'العربية', 'nativeName': 'العربية', 'flag': '🇸🇦'},
    {
      'code': 'en',
      'name': 'English',
      'nativeName': 'الإنجليزية',
      'flag': '🇺🇸',
    },
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)?.language ?? 'اللغة'),
      ),
      body: ListView(
        padding: EdgeInsets.all(16.w),
        children: [
          Text(
            'اختر لغة التطبيق',
            style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w600),
          ),
          SizedBox(height: 16.h),
          ..._languages.map((lang) => _buildLanguageOption(lang, isDark)),
          SizedBox(height: 24.h),
          Container(
            padding: EdgeInsets.all(16.w),
            decoration: BoxDecoration(
              color: AppColors.info.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(color: AppColors.info.withValues(alpha: 0.3)),
            ),
            child: Row(
              children: [
                Icon(Iconsax.info_circle, size: 22.sp, color: AppColors.info),
                SizedBox(width: 12.w),
                Expanded(
                  child: Text(
                    'سيتم إعادة تشغيل التطبيق لتطبيق اللغة الجديدة',
                    style: TextStyle(fontSize: 13.sp, color: AppColors.info),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLanguageOption(Map<String, String> lang, bool isDark) {
    return BlocBuilder<LocaleCubit, LocaleState>(
      builder: (context, localeState) {
        final isSelected = localeState.locale.languageCode == lang['code'];
        return GestureDetector(
          onTap: () => _changeLanguage(context, lang['code']!),
      child: Container(
        margin: EdgeInsets.only(bottom: 12.h),
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: isDark ? AppColors.cardDark : AppColors.cardLight,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(
            color: isSelected ? AppColors.primary : Colors.transparent,
            width: 2,
          ),
        ),
        child: Row(
          children: [
            Text(lang['flag']!, style: TextStyle(fontSize: 28.sp)),
            SizedBox(width: 16.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    lang['name']!,
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  if (lang['code'] != 'ar')
                    Text(
                      lang['nativeName']!,
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: AppColors.textSecondaryLight,
                      ),
                    ),
                ],
              ),
            ),
            Icon(
              isSelected ? Iconsax.tick_circle5 : Iconsax.tick_circle,
              size: 24.sp,
              color: isSelected
                  ? AppColors.primary
                  : AppColors.textTertiaryLight,
            ),
          ],
        ),
      ),
    );
      },
    );
  }

  void _changeLanguage(BuildContext context, String code) {
    final currentLocale = context.read<LocaleCubit>().state.locale;
    if (code == currentLocale.languageCode) return;

    final localizations = AppLocalizations.of(context);
    final currentLanguageCode = Localizations.localeOf(context).languageCode;
    final languageName = code == 'ar'
        ? (localizations?.arabic ?? 'العربية')
        : (localizations?.english ?? 'English');

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(localizations?.language ?? 'تغيير اللغة'),
        content: Text(
          currentLanguageCode == 'ar'
              ? 'سيتم تغيير اللغة إلى $languageName'
              : 'Language will be changed to $languageName',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(localizations?.cancel ?? 'إلغاء'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              context.read<LocaleCubit>().changeLocale(Locale(code));
              if (ctx.mounted) {
                ScaffoldMessenger.of(ctx).showSnackBar(
                  SnackBar(
                    content: Text(
                      currentLanguageCode == 'ar'
                          ? 'تم تغيير اللغة'
                          : 'Language changed',
                    ),
                    backgroundColor: AppColors.success,
                  ),
                );
              }
            },
            child: Text(currentLanguageCode == 'ar' ? 'تأكيد' : 'Confirm'),
          ),
        ],
      ),
    );
  }
}

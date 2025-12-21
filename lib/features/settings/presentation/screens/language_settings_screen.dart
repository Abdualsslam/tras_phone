/// Language Settings Screen - Change app language
library;

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iconsax/iconsax.dart';
import '../../../../core/config/theme/app_colors.dart';

class LanguageSettingsScreen extends StatefulWidget {
  const LanguageSettingsScreen({super.key});

  @override
  State<LanguageSettingsScreen> createState() => _LanguageSettingsScreenState();
}

class _LanguageSettingsScreenState extends State<LanguageSettingsScreen> {
  String _selectedLanguage = 'ar';

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
      appBar: AppBar(title: const Text('اللغة')),
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
    final isSelected = _selectedLanguage == lang['code'];
    return GestureDetector(
      onTap: () => _changeLanguage(lang['code']!),
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
  }

  void _changeLanguage(String code) {
    if (code == _selectedLanguage) return;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('تغيير اللغة'),
        content: Text(
          'سيتم إعادة تشغيل التطبيق لتطبيق اللغة ${code == 'ar' ? 'العربية' : 'الإنجليزية'}',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() => _selectedLanguage = code);
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(const SnackBar(content: Text('تم تغيير اللغة')));
            },
            child: const Text('تأكيد'),
          ),
        ],
      ),
    );
  }
}

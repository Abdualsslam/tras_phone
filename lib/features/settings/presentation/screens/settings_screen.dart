/// Settings Screen - App settings and preferences
library;

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax/iconsax.dart';
import '../../../../core/config/theme/app_colors.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _notificationsEnabled = true;
  bool _darkModeEnabled = false;
  String _selectedLanguage = 'العربية';

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('الإعدادات'),
        leading: IconButton(
          icon: const Icon(Iconsax.arrow_right_3),
          onPressed: () => context.pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Appearance Section
            _buildSectionTitle(theme, 'المظهر'),
            _buildSettingsCard(isDark, [
              _buildSwitchTile(
                theme,
                icon: Iconsax.moon,
                title: 'الوضع الداكن',
                subtitle: 'تفعيل المظهر الداكن',
                value: _darkModeEnabled,
                onChanged: (value) {
                  setState(() => _darkModeEnabled = value);
                },
              ),
              _buildDivider(),
              _buildNavigationTile(
                theme,
                icon: Iconsax.language_square,
                title: 'اللغة',
                subtitle: _selectedLanguage,
                onTap: () => _showLanguageDialog(),
              ),
            ]),
            SizedBox(height: 24.h),

            // Notifications Section
            _buildSectionTitle(theme, 'الإشعارات'),
            _buildSettingsCard(isDark, [
              _buildSwitchTile(
                theme,
                icon: Iconsax.notification,
                title: 'الإشعارات',
                subtitle: 'تفعيل إشعارات التطبيق',
                value: _notificationsEnabled,
                onChanged: (value) {
                  setState(() => _notificationsEnabled = value);
                },
              ),
            ]),
            SizedBox(height: 24.h),

            // Privacy Section
            _buildSectionTitle(theme, 'الخصوصية والأمان'),
            _buildSettingsCard(isDark, [
              _buildNavigationTile(
                theme,
                icon: Iconsax.lock,
                title: 'تغيير كلمة المرور',
                onTap: () {},
              ),
              _buildDivider(),
              _buildNavigationTile(
                theme,
                icon: Iconsax.finger_scan,
                title: 'البصمة / Face ID',
                onTap: () {},
              ),
              _buildDivider(),
              _buildNavigationTile(
                theme,
                icon: Iconsax.shield_tick,
                title: 'سياسة الخصوصية',
                onTap: () {},
              ),
            ]),
            SizedBox(height: 24.h),

            // About Section
            _buildSectionTitle(theme, 'حول التطبيق'),
            _buildSettingsCard(isDark, [
              _buildNavigationTile(
                theme,
                icon: Iconsax.info_circle,
                title: 'عن التطبيق',
                subtitle: 'الإصدار 1.0.0',
                onTap: () {},
              ),
              _buildDivider(),
              _buildNavigationTile(
                theme,
                icon: Iconsax.star,
                title: 'قيّم التطبيق',
                onTap: () {},
              ),
              _buildDivider(),
              _buildNavigationTile(
                theme,
                icon: Iconsax.share,
                title: 'شارك التطبيق',
                onTap: () {},
              ),
            ]),
            SizedBox(height: 24.h),

            // Danger Zone
            _buildSettingsCard(isDark, [
              _buildNavigationTile(
                theme,
                icon: Iconsax.trash,
                title: 'حذف الحساب',
                titleColor: AppColors.error,
                onTap: () => _showDeleteAccountDialog(),
              ),
            ]),
            SizedBox(height: 32.h),

            // Version
            Center(
              child: Text(
                'تراس فون v1.0.0',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: AppColors.textTertiaryLight,
                ),
              ),
            ),
            SizedBox(height: 16.h),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(ThemeData theme, String title) {
    return Padding(
      padding: EdgeInsets.only(right: 4.w, bottom: 8.h),
      child: Text(
        title,
        style: theme.textTheme.titleSmall?.copyWith(
          fontWeight: FontWeight.w600,
          color: AppColors.textSecondaryLight,
        ),
      ),
    );
  }

  Widget _buildSettingsCard(bool isDark, List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardDark : AppColors.cardLight,
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Column(children: children),
    );
  }

  Widget _buildDivider() {
    return Divider(height: 1, indent: 56.w, color: AppColors.dividerLight);
  }

  Widget _buildSwitchTile(
    ThemeData theme, {
    required IconData icon,
    required String title,
    String? subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return ListTile(
      leading: Container(
        width: 40.w,
        height: 40.w,
        decoration: BoxDecoration(
          color: AppColors.primary.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(10.r),
        ),
        child: Icon(icon, color: AppColors.primary, size: 20.sp),
      ),
      title: Text(
        title,
        style: theme.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w500),
      ),
      subtitle: subtitle != null
          ? Text(
              subtitle,
              style: theme.textTheme.bodySmall?.copyWith(
                color: AppColors.textTertiaryLight,
              ),
            )
          : null,
      trailing: Switch.adaptive(
        value: value,
        onChanged: onChanged,
        activeColor: AppColors.primary,
      ),
      contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 4.h),
    );
  }

  Widget _buildNavigationTile(
    ThemeData theme, {
    required IconData icon,
    required String title,
    String? subtitle,
    Color? titleColor,
    required VoidCallback onTap,
  }) {
    return ListTile(
      onTap: onTap,
      leading: Container(
        width: 40.w,
        height: 40.w,
        decoration: BoxDecoration(
          color: (titleColor ?? AppColors.primary).withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(10.r),
        ),
        child: Icon(icon, color: titleColor ?? AppColors.primary, size: 20.sp),
      ),
      title: Text(
        title,
        style: theme.textTheme.bodyLarge?.copyWith(
          fontWeight: FontWeight.w500,
          color: titleColor,
        ),
      ),
      subtitle: subtitle != null
          ? Text(
              subtitle,
              style: theme.textTheme.bodySmall?.copyWith(
                color: AppColors.textTertiaryLight,
              ),
            )
          : null,
      trailing: Icon(
        Iconsax.arrow_left_2,
        size: 18.sp,
        color: AppColors.textTertiaryLight,
      ),
      contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 4.h),
    );
  }

  void _showLanguageDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('اختر اللغة'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildLanguageOption(ctx, 'العربية', 'ar'),
            _buildLanguageOption(ctx, 'English', 'en'),
          ],
        ),
      ),
    );
  }

  Widget _buildLanguageOption(BuildContext ctx, String name, String code) {
    final isSelected = _selectedLanguage == name;
    return ListTile(
      title: Text(name),
      trailing: isSelected
          ? const Icon(Iconsax.tick_circle, color: AppColors.primary)
          : null,
      onTap: () {
        setState(() => _selectedLanguage = name);
        Navigator.pop(ctx);
      },
    );
  }

  void _showDeleteAccountDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('حذف الحساب'),
        content: const Text(
          'هل أنت متأكد من حذف حسابك؟ هذا الإجراء لا يمكن التراجع عنه.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            child: const Text('حذف'),
          ),
        ],
      ),
    );
  }
}

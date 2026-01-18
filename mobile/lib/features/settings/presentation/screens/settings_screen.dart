/// Settings Screen - App settings and preferences
library;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax/iconsax.dart';
import '../../../../core/config/theme/app_colors.dart';
import '../../../../core/cubit/locale_cubit.dart';
import '../../../../core/di/injection.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../auth/presentation/cubit/auth_cubit.dart';
import '../../../profile/presentation/cubit/profile_cubit.dart';
import '../../../profile/presentation/cubit/profile_state.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _notificationsEnabled = true;
  bool _darkModeEnabled = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.settings),
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
            _buildSectionTitle(theme, AppLocalizations.of(context)!.settings),
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
              BlocBuilder<LocaleCubit, LocaleState>(
                builder: (context, state) {
                  final isArabic = state.locale.languageCode == 'ar';
                  return _buildNavigationTile(
                    theme,
                    icon: Iconsax.language_square,
                    title: AppLocalizations.of(context)!.language,
                    subtitle: isArabic
                        ? AppLocalizations.of(context)!.arabic
                        : AppLocalizations.of(context)!.english,
                    onTap: () => _showLanguageDialog(),
                  );
                },
              ),
            ]),
            SizedBox(height: 24.h),

            // Notifications Section
            _buildSectionTitle(
              theme,
              AppLocalizations.of(context)!.notifications,
            ),
            _buildSettingsCard(isDark, [
              _buildSwitchTile(
                theme,
                icon: Iconsax.notification,
                title: AppLocalizations.of(context)!.notifications,
                subtitle: null,
                value: _notificationsEnabled,
                onChanged: (value) {
                  setState(() => _notificationsEnabled = value);
                },
              ),
            ]),
            SizedBox(height: 24.h),

            // Privacy Section
            _buildSectionTitle(
              theme,
              AppLocalizations.of(context)!.privacyPolicy,
            ),
            _buildSettingsCard(isDark, [
              _buildNavigationTile(
                theme,
                icon: Iconsax.lock,
                title: AppLocalizations.of(context)!.changePassword,
                onTap: () => context.push('/change-password'),
              ),
              _buildDivider(),
              _buildNavigationTile(
                theme,
                icon: Iconsax.finger_scan,
                title: 'البصمة / Face ID',
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('ميزة قيد التطوير')),
                  );
                },
              ),
              _buildDivider(),
              _buildNavigationTile(
                theme,
                icon: Iconsax.shield_tick,
                title: AppLocalizations.of(context)!.privacyPolicy,
                onTap: () => context.push('/privacy'),
              ),
            ]),
            SizedBox(height: 24.h),

            // About Section
            _buildSectionTitle(theme, AppLocalizations.of(context)!.aboutUs),
            _buildSettingsCard(isDark, [
              _buildNavigationTile(
                theme,
                icon: Iconsax.info_circle,
                title: AppLocalizations.of(context)!.aboutUs,
                subtitle: 'الإصدار 1.0.0',
                onTap: () => context.push('/about'),
              ),
              _buildDivider(),
              _buildNavigationTile(
                theme,
                icon: Iconsax.star,
                title: 'قيّم التطبيق',
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('شكراً لتقييمك!')),
                  );
                },
              ),
              _buildDivider(),
              _buildNavigationTile(
                theme,
                icon: Iconsax.share,
                title: 'شارك التطبيق',
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('جاري فتح المشاركة...')),
                  );
                },
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
                '${AppLocalizations.of(context)!.appName} v1.0.0',
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
        activeThumbColor: AppColors.primary,
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
        title: Text(AppLocalizations.of(context)!.language),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildLanguageOption(
              ctx,
              AppLocalizations.of(context)!.arabic,
              'ar',
            ),
            _buildLanguageOption(
              ctx,
              AppLocalizations.of(context)!.english,
              'en',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLanguageOption(BuildContext ctx, String name, String code) {
    final currentLocale = context.read<LocaleCubit>().state.locale.languageCode;
    final isSelected = currentLocale == code;
    return ListTile(
      title: Text(name),
      trailing: isSelected
          ? const Icon(Iconsax.tick_circle, color: AppColors.primary)
          : null,
      onTap: () {
        context.read<LocaleCubit>().changeLocale(Locale(code));
        Navigator.pop(ctx);
      },
    );
  }

  void _showDeleteAccountDialog() {
    final reasonController = TextEditingController();
    final profileCubit = getIt<ProfileCubit>();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => BlocProvider.value(
        value: profileCubit,
        child: BlocListener<ProfileCubit, ProfileState>(
          listener: (context, state) {
            if (state is ProfileError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: AppColors.error,
                ),
              );
            }
            // Note: ProfileCubit.deleteAccount() returns bool, doesn't emit state
            // We'll handle success through the Future result
          },
          child: BlocBuilder<ProfileCubit, ProfileState>(
            builder: (context, state) {
              final isLoading = state is ProfileLoading;

              return AlertDialog(
                title: const Text('حذف الحساب'),
                content: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'هل أنت متأكد من حذف حسابك؟ هذا الإجراء لا يمكن التراجع عنه.',
                      ),
                      SizedBox(height: 16.h),
                      TextField(
                        controller: reasonController,
                        enabled: !isLoading,
                        decoration: InputDecoration(
                          labelText: 'سبب الحذف (اختياري)',
                          hintText: 'أخبرنا لماذا تريد حذف حسابك...',
                          border: const OutlineInputBorder(),
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 12.w,
                            vertical: 12.h,
                          ),
                        ),
                        maxLines: 3,
                        maxLength: 500,
                      ),
                    ],
                  ),
                ),
                actions: [
                  TextButton(
                    onPressed: isLoading
                        ? null
                        : () {
                            Navigator.pop(ctx);
                            reasonController.dispose();
                          },
                    child: Text(AppLocalizations.of(context)!.cancel),
                  ),
                  ElevatedButton(
                    onPressed: isLoading
                        ? null
                        : () async {
                            final reason = reasonController.text.trim();
                            final success = await profileCubit.deleteAccount(
                              reason: reason.isEmpty ? null : reason,
                            );

                            if (!ctx.mounted) return;

                            if (success) {
                              Navigator.pop(ctx);
                              reasonController.dispose();

                              // Logout user and redirect to login
                              if (context.mounted) {
                                context.read<AuthCubit>().logout();
                                context.go('/login');
                              }

                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('تم حذف حسابك بنجاح'),
                                  backgroundColor: AppColors.success,
                                ),
                              );
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('حدث خطأ أثناء حذف الحساب'),
                                  backgroundColor: AppColors.error,
                                ),
                              );
                            }
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.error,
                      disabledBackgroundColor:
                          AppColors.error.withOpacity(0.5),
                    ),
                    child: isLoading
                        ? SizedBox(
                            width: 20.w,
                            height: 20.h,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: const AlwaysStoppedAnimation<Color>(
                                Colors.white,
                              ),
                            ),
                          )
                        : const Text('حذف'),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

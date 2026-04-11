import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iconsax/iconsax.dart';

import '../../../../core/config/theme/app_colors.dart';
import '../../../../l10n/app_localizations.dart';
import 'settings_sections.dart';

class SettingsContent extends StatelessWidget {
  final bool isDark;
  final bool notificationsEnabled;
  final bool biometricAvailable;
  final bool biometricEnabled;
  final String themeName;
  final String languageName;
  final ValueChanged<bool> onNotificationsChanged;
  final ValueChanged<bool> onBiometricChanged;
  final VoidCallback onShowThemeDialog;
  final VoidCallback onShowLanguageDialog;
  final VoidCallback onChangePassword;
  final VoidCallback onPrivacyPolicy;
  final VoidCallback onAbout;
  final VoidCallback onShareApp;
  final VoidCallback onDeleteAccount;

  const SettingsContent({
    super.key,
    required this.isDark,
    required this.notificationsEnabled,
    required this.biometricAvailable,
    required this.biometricEnabled,
    required this.themeName,
    required this.languageName,
    required this.onNotificationsChanged,
    required this.onBiometricChanged,
    required this.onShowThemeDialog,
    required this.onShowLanguageDialog,
    required this.onChangePassword,
    required this.onPrivacyPolicy,
    required this.onAbout,
    required this.onShareApp,
    required this.onDeleteAccount,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return SingleChildScrollView(
      padding: EdgeInsets.all(16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SettingsSectionTitle(title: l10n.settings),
          SettingsCard(
            isDark: isDark,
            children: [
              SettingsNavigationTile(
                icon: Iconsax.moon,
                title: l10n.appearance,
                subtitle: themeName,
                onTap: onShowThemeDialog,
              ),
              const SettingsDivider(),
              SettingsNavigationTile(
                icon: Iconsax.language_square,
                title: l10n.language,
                subtitle: languageName,
                onTap: onShowLanguageDialog,
              ),
            ],
          ),
          SizedBox(height: 24.h),
          SettingsSectionTitle(title: l10n.notifications),
          SettingsCard(
            isDark: isDark,
            children: [
              SettingsSwitchTile(
                icon: Iconsax.notification,
                title: l10n.notifications,
                subtitle: null,
                value: notificationsEnabled,
                onChanged: onNotificationsChanged,
              ),
            ],
          ),
          SizedBox(height: 24.h),
          SettingsSectionTitle(title: l10n.privacyPolicy),
          SettingsCard(
            isDark: isDark,
            children: [
              SettingsNavigationTile(
                icon: Iconsax.lock,
                title: l10n.changePassword,
                onTap: onChangePassword,
              ),
              if (biometricAvailable) ...[
                const SettingsDivider(),
                SettingsSwitchTile(
                  icon: Iconsax.finger_scan,
                  title: l10n.biometric,
                  subtitle: l10n.biometricSubtitle,
                  value: biometricEnabled,
                  onChanged: onBiometricChanged,
                ),
              ],
              const SettingsDivider(),
              SettingsNavigationTile(
                icon: Iconsax.shield_tick,
                title: l10n.privacyPolicy,
                onTap: onPrivacyPolicy,
              ),
            ],
          ),
          SizedBox(height: 24.h),
          SettingsSectionTitle(title: l10n.aboutUs),
          SettingsCard(
            isDark: isDark,
            children: [
              SettingsNavigationTile(
                icon: Iconsax.info_circle,
                title: l10n.aboutUs,
                subtitle: 'الإصدار 1.0.0',
                onTap: onAbout,
              ),
              const SettingsDivider(),
              SettingsNavigationTile(
                icon: Iconsax.share,
                title: l10n.shareApp,
                onTap: onShareApp,
              ),
            ],
          ),
          SizedBox(height: 24.h),
          SettingsCard(
            isDark: isDark,
            children: [
              SettingsNavigationTile(
                icon: Iconsax.trash,
                title: l10n.deleteAccount,
                titleColor: AppColors.error,
                onTap: onDeleteAccount,
              ),
            ],
          ),
          SizedBox(height: 32.h),
          Center(
            child: Text(
              '${l10n.appName} v1.0.0',
              style: theme.textTheme.bodySmall?.copyWith(
                color: AppColors.textTertiaryLight,
              ),
            ),
          ),
          SizedBox(height: 16.h),
        ],
      ),
    );
  }
}

library;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax/iconsax.dart';

import '../../../../core/config/theme/app_colors.dart';
import '../../../../core/cubit/locale_cubit.dart';
import '../../../../core/cubit/theme_cubit.dart';
import '../../../../core/services/biometric_credential_service.dart';
import '../../../../core/services/biometric_service.dart';
import '../../../../core/services/share_service.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../auth/presentation/cubit/auth_cubit.dart';
import '../widgets/settings_content.dart';
import '../widgets/settings_dialogs.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _notificationsEnabled = true;
  bool _biometricAvailable = false;
  bool _biometricEnabled = false;

  @override
  void initState() {
    super.initState();
    _checkBiometricAvailability();
    _loadBiometricStatus();
  }

  Future<void> _checkBiometricAvailability() async {
    final isAvailable = await context.read<BiometricService>().isAvailable();
    if (mounted) {
      setState(() => _biometricAvailable = isAvailable);
    }
  }

  Future<void> _loadBiometricStatus() async {
    final isEnabled = await context.read<BiometricService>().isEnabled();
    if (mounted) {
      setState(() => _biometricEnabled = isEnabled);
    }
  }

  Future<void> _handleBiometricChanged(bool value) async {
    final biometricService = context.read<BiometricService>();
    final credentialService = context.read<BiometricCredentialService>();
    final authCubit = context.read<AuthCubit>();
    final messenger = ScaffoldMessenger.of(context);
    final localizations = AppLocalizations.of(context)!;

    if (value) {
      final authenticated = await biometricService.verifyIdentityForSetup(
        localizedReason: 'يرجى التحقق من هويتك لتفعيل البصمة',
      );

      if (!authenticated) {
        if (mounted) {
          messenger.showSnackBar(
            SnackBar(
              content: Text(localizations.biometricFailed),
              backgroundColor: AppColors.error,
            ),
          );
        }
        return;
      }

      final hasCredentials = await credentialService.hasCredentials();
      if (!hasCredentials) {
        final user = authCubit.currentUser;
        if (!mounted) return;
        final password = await showSettingsPasswordDialog(context);
        if (password == null || !mounted) return;

        if (user == null || !mounted) return;

        await credentialService.saveCredentials(
          phone: user.phone,
          password: password,
        );
      }

      await biometricService.setEnabled(true);
      if (mounted) {
        setState(() => _biometricEnabled = true);
        messenger.showSnackBar(
          SnackBar(
            content: Text(localizations.biometricEnabled),
            backgroundColor: AppColors.success,
          ),
        );
      }
      return;
    }

    await credentialService.clearCredentials();
    await biometricService.setEnabled(false);
    if (mounted) {
      setState(() => _biometricEnabled = false);
      messenger.showSnackBar(
        SnackBar(
          content: Text(localizations.biometricDisabled),
          backgroundColor: AppColors.success,
        ),
      );
    }
  }

  Future<void> _shareApp() async {
    final messenger = ScaffoldMessenger.of(context);
    final localizations = AppLocalizations.of(context)!;

    try {
      await context.read<ShareService>().shareApp(context: context);
    } catch (error) {
      if (mounted) {
        messenger.showSnackBar(
          SnackBar(
            content: Text('${localizations.shareError}: $error'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  String _themeName(BuildContext context, ThemeMode themeMode) {
    final l10n = AppLocalizations.of(context)!;
    return switch (themeMode) {
      ThemeMode.light => l10n.themeLight,
      ThemeMode.dark => l10n.themeDark,
      ThemeMode.system => l10n.themeSystem,
    };
  }

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
      body: BlocBuilder<ThemeCubit, ThemeState>(
        builder: (context, themeState) {
          return BlocBuilder<LocaleCubit, LocaleState>(
            builder: (context, localeState) {
              final isArabic = localeState.locale.languageCode == 'ar';

              return SettingsContent(
                isDark: isDark,
                notificationsEnabled: _notificationsEnabled,
                biometricAvailable: _biometricAvailable,
                biometricEnabled: _biometricEnabled,
                themeName: _themeName(context, themeState.themeMode),
                languageName: isArabic
                    ? AppLocalizations.of(context)!.arabic
                    : AppLocalizations.of(context)!.english,
                onNotificationsChanged: (value) {
                  setState(() => _notificationsEnabled = value);
                },
                onBiometricChanged: _handleBiometricChanged,
                onShowThemeDialog: () => showSettingsThemeDialog(context),
                onShowLanguageDialog: () => showSettingsLanguageDialog(context),
                onChangePassword: () => context.push('/change-password'),
                onPrivacyPolicy: () => context.push('/privacy'),
                onAbout: () => context.push('/about'),
                onShareApp: _shareApp,
                onDeleteAccount: () => showDeleteAccountSettingsDialog(context),
              );
            },
          );
        },
      ),
    );
  }
}

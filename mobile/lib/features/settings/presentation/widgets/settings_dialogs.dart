import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax/iconsax.dart';

import '../../../../core/config/theme/app_colors.dart';
import '../../../../core/cubit/locale_cubit.dart';
import '../../../../core/cubit/theme_cubit.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../auth/presentation/cubit/auth_cubit.dart';
import '../../../profile/presentation/cubit/profile_cubit.dart';
import '../../../profile/presentation/cubit/profile_state.dart';
import 'settings_sections.dart';

Future<void> showSettingsLanguageDialog(BuildContext context) {
  return showDialog<void>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: Text(AppLocalizations.of(context)!.language),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _LanguageOption(
            name: AppLocalizations.of(context)!.arabic,
            code: 'ar',
          ),
          _LanguageOption(
            name: AppLocalizations.of(context)!.english,
            code: 'en',
          ),
        ],
      ),
    ),
  );
}

Future<void> showSettingsThemeDialog(BuildContext context) {
  return showDialog<void>(
    context: context,
    builder: (ctx) => BlocBuilder<ThemeCubit, ThemeState>(
      builder: (context, themeState) {
        final l10n = AppLocalizations.of(context)!;
        return AlertDialog(
          title: Text(l10n.chooseTheme),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _ThemeOption(
                title: l10n.themeSystem,
                subtitle: l10n.themeSystemSubtitle,
                icon: Iconsax.mobile,
                themeMode: ThemeMode.system,
                isSelected: themeState.themeMode == ThemeMode.system,
              ),
              _ThemeOption(
                title: l10n.themeLight,
                subtitle: l10n.themeLightSubtitle,
                icon: Iconsax.sun_1,
                themeMode: ThemeMode.light,
                isSelected: themeState.themeMode == ThemeMode.light,
              ),
              _ThemeOption(
                title: l10n.themeDark,
                subtitle: l10n.themeDarkSubtitle,
                icon: Iconsax.moon,
                themeMode: ThemeMode.dark,
                isSelected: themeState.themeMode == ThemeMode.dark,
              ),
            ],
          ),
        );
      },
    ),
  );
}

Future<String?> showSettingsPasswordDialog(BuildContext context) {
  final controller = TextEditingController();
  return showDialog<String>(
    context: context,
    barrierDismissible: false,
    builder: (ctx) => AlertDialog(
      title: Text(AppLocalizations.of(context)!.enterPassword),
      content: TextField(
        controller: controller,
        obscureText: true,
        decoration: InputDecoration(
          labelText: AppLocalizations.of(context)!.password,
          hintText: AppLocalizations.of(context)!.enterPasswordHint,
          border: const OutlineInputBorder(),
          contentPadding: EdgeInsets.symmetric(
            horizontal: 12.w,
            vertical: 12.h,
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx),
          child: Text(AppLocalizations.of(context)!.cancel),
        ),
        ElevatedButton(
          onPressed: () {
            final password = controller.text.trim();
            Navigator.pop(ctx, password.isNotEmpty ? password : null);
          },
          child: Text(AppLocalizations.of(context)!.save),
        ),
      ],
    ),
  );
}

void showDeleteAccountSettingsDialog(BuildContext context) {
  final reasonController = TextEditingController();
  final profileCubit = context.read<ProfileCubit>();

  showDialog<void>(
    context: context,
    barrierDismissible: false,
    builder: (ctx) => BlocProvider.value(
      value: profileCubit,
      child: BlocBuilder<ProfileCubit, ProfileState>(
        builder: (context, state) {
          final isLoading = state is ProfileLoading;
          return AlertDialog(
            title: Text(AppLocalizations.of(context)!.deleteAccount),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(AppLocalizations.of(context)!.deleteAccountConfirm),
                  SizedBox(height: 16.h),
                  TextField(
                    controller: reasonController,
                    enabled: !isLoading,
                    decoration: InputDecoration(
                      labelText: AppLocalizations.of(context)!.deleteReason,
                      hintText: AppLocalizations.of(context)!.deleteReasonHint,
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

                          if (context.mounted) {
                            context.read<AuthCubit>().logout();
                            context.go('/login');
                          }

                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                AppLocalizations.of(
                                  context,
                                )!.deleteAccountSuccess,
                              ),
                              backgroundColor: AppColors.success,
                            ),
                          );
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                AppLocalizations.of(
                                  context,
                                )!.deleteAccountError,
                              ),
                              backgroundColor: AppColors.error,
                            ),
                          );
                        }
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.error,
                  disabledBackgroundColor: AppColors.error.withValues(
                    alpha: 0.5,
                  ),
                ),
                child: isLoading
                    ? SizedBox(
                        width: 20.w,
                        height: 20.h,
                        child: const CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.white,
                          ),
                        ),
                      )
                    : Text(AppLocalizations.of(context)!.delete),
              ),
            ],
          );
        },
      ),
    ),
  );
}

class _LanguageOption extends StatelessWidget {
  final String name;
  final String code;

  const _LanguageOption({required this.name, required this.code});

  @override
  Widget build(BuildContext context) {
    final currentLocale = context.read<LocaleCubit>().state.locale.languageCode;
    final isSelected = currentLocale == code;

    return SettingsOptionTile(
      title: name,
      isSelected: isSelected,
      onTap: () {
        context.read<LocaleCubit>().changeLocale(Locale(code));
        Navigator.pop(context);
      },
    );
  }
}

class _ThemeOption extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final ThemeMode themeMode;
  final bool isSelected;

  const _ThemeOption({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.themeMode,
    required this.isSelected,
  });

  @override
  Widget build(BuildContext context) {
    return SettingsOptionTile(
      icon: icon,
      title: title,
      subtitle: subtitle,
      isSelected: isSelected,
      onTap: () {
        context.read<ThemeCubit>().changeTheme(themeMode);
        Navigator.pop(context);
      },
    );
  }
}

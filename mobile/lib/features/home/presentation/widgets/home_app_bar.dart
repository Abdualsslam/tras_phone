import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax/iconsax.dart';
import '../../../../core/config/theme/app_colors.dart';
import '../../../../l10n/app_localizations.dart';
import 'notification_button.dart';

class HomeAppBar extends StatelessWidget implements PreferredSizeWidget {
  const HomeAppBar({super.key});

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return AppBar(
      elevation: 0,
      scrolledUnderElevation: 0.5,
      leadingWidth: 200.w,
      leading: Row(
        children: [
          SizedBox(width: 16.w),
          Container(
            width: 36.w,
            height: 36.w,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10.r),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.15),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10.r),
              child: Image.asset(
                isDark ? 'assets/images/logo_dark.png' : 'assets/images/logo.png',
                width: 36.w,
                height: 36.w,
                fit: BoxFit.contain,
              ),
            ),
          ),
          SizedBox(width: 10.w),
          Flexible(
            child: Text(
              AppLocalizations.of(context)!.appName,
              style: TextStyle(
                fontSize: 20.sp,
                fontWeight: FontWeight.w800,
                color: isDark
                    ? AppColors.textPrimaryDark
                    : AppColors.textPrimaryLight,
              ),
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
          ),
        ],
      ),
      actions: [
        // Search button with subtle background
        _ActionButton(
          icon: Iconsax.search_normal,
          isDark: isDark,
          onTap: () => context.push('/search'),
        ),
        SizedBox(width: 4.w),
        const NotificationButton(),
        SizedBox(width: 12.w),
      ],
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final bool isDark;
  final VoidCallback onTap;

  const _ActionButton({
    required this.icon,
    required this.isDark,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 38.w,
        height: 38.w,
        decoration: BoxDecoration(
          color: isDark
              ? AppColors.cardDark
              : AppColors.backgroundLight,
          borderRadius: BorderRadius.circular(10.r),
        ),
        child: Icon(icon, size: 20.sp),
      ),
    );
  }
}

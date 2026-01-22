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
      leadingWidth: 200.w,
      leading: Row(
        children: [
          SizedBox(width: 16.w),
          Image.asset(
            isDark ? 'assets/images/logo_dark.png' : 'assets/images/logo.png',
            width: 36.w,
            height: 36.w,
            fit: BoxFit.contain,
          ),
          SizedBox(width: 10.w),
          Flexible(
            child: Text(
              AppLocalizations.of(context)!.appName,
              style: TextStyle(
                fontSize: 20.sp,
                fontWeight: FontWeight.w700,
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
        IconButton(
          onPressed: () => context.push('/search'),
          icon: Icon(Iconsax.search_normal, size: 24.sp),
        ),
        const NotificationButton(),
        SizedBox(width: 8.w),
      ],
    );
  }
}

/// Profile Screen - User account information and settings
library;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax/iconsax.dart';
import '../../../../core/config/theme/app_colors.dart';
import '../../../auth/presentation/cubit/auth_cubit.dart';
import '../../../auth/presentation/cubit/auth_state.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('حسابي'),
        actions: [
          IconButton(
            icon: const Icon(Iconsax.setting_2),
            onPressed: () {
              // Navigate to settings
            },
          ),
        ],
      ),
      body: BlocBuilder<AuthCubit, AuthState>(
        builder: (context, state) {
          if (state is AuthAuthenticated) {
            return _buildAuthenticatedContent(
              context,
              theme,
              isDark,
              state.customer,
            );
          }
          return _buildUnauthenticatedContent(context, theme);
        },
      ),
    );
  }

  Widget _buildAuthenticatedContent(
    BuildContext context,
    ThemeData theme,
    bool isDark,
    dynamic customer,
  ) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16.w),
      child: Column(
        children: [
          // Profile Header
          _buildProfileHeader(theme, isDark, customer),
          SizedBox(height: 24.h),

          // Stats Cards
          _buildStatsRow(theme, isDark, customer),
          SizedBox(height: 24.h),

          // Menu Sections
          _buildMenuSection(
            theme,
            isDark,
            title: 'طلباتي',
            items: [
              _MenuItem(
                icon: Iconsax.box,
                title: 'طلباتي',
                subtitle: 'تتبع وإدارة طلباتك',
                onTap: () {},
              ),
              _MenuItem(
                icon: Iconsax.rotate_left,
                title: 'المرتجعات',
                subtitle: 'طلبات الإرجاع والاستبدال',
                onTap: () {},
              ),
            ],
          ),
          SizedBox(height: 16.h),

          _buildMenuSection(
            theme,
            isDark,
            title: 'المحفظة والنقاط',
            items: [
              _MenuItem(
                icon: Iconsax.wallet,
                title: 'محفظتي',
                subtitle: '٥٠٠ ر.ي',
                onTap: () {},
              ),
              _MenuItem(
                icon: Iconsax.medal_star,
                title: 'نقاط الولاء',
                subtitle: '١٥٠ نقطة',
                onTap: () {},
              ),
            ],
          ),
          SizedBox(height: 16.h),

          _buildMenuSection(
            theme,
            isDark,
            title: 'حسابي',
            items: [
              _MenuItem(
                icon: Iconsax.user_edit,
                title: 'تعديل الملف الشخصي',
                onTap: () {},
              ),
              _MenuItem(
                icon: Iconsax.location,
                title: 'العناوين',
                onTap: () {},
              ),
              _MenuItem(
                icon: Iconsax.lock,
                title: 'تغيير كلمة المرور',
                onTap: () {},
              ),
            ],
          ),
          SizedBox(height: 16.h),

          _buildMenuSection(
            theme,
            isDark,
            title: 'المساعدة',
            items: [
              _MenuItem(
                icon: Iconsax.message_question,
                title: 'الأسئلة الشائعة',
                onTap: () {},
              ),
              _MenuItem(
                icon: Iconsax.headphone,
                title: 'الدعم الفني',
                onTap: () {},
              ),
              _MenuItem(
                icon: Iconsax.document_text,
                title: 'الشروط والأحكام',
                onTap: () {},
              ),
            ],
          ),
          SizedBox(height: 24.h),

          // Logout Button
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () => _showLogoutDialog(context),
              icon: const Icon(Iconsax.logout, color: AppColors.error),
              label: const Text(
                'تسجيل الخروج',
                style: TextStyle(color: AppColors.error),
              ),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: AppColors.error),
                padding: EdgeInsets.symmetric(vertical: 16.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14.r),
                ),
              ),
            ),
          ),
          SizedBox(height: 32.h),
        ],
      ),
    );
  }

  Widget _buildProfileHeader(ThemeData theme, bool isDark, dynamic customer) {
    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.primary, AppColors.primary.withValues(alpha: 0.8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: Row(
        children: [
          // Avatar
          Container(
            width: 70.w,
            height: 70.w,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(Iconsax.user, size: 35.sp, color: Colors.white),
          ),
          SizedBox(width: 16.w),

          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  customer?.responsiblePersonName ?? 'مستخدم',
                  style: TextStyle(
                    fontSize: 20.sp,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  customer?.shopName ?? 'متجر',
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: Colors.white.withValues(alpha: 0.8),
                  ),
                ),
                SizedBox(height: 4.h),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                  child: Text(
                    customer?.loyaltyTier?.toString().toUpperCase() ?? 'SILVER',
                    style: TextStyle(
                      fontSize: 11.sp,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Edit Button
          IconButton(
            onPressed: () {},
            icon: const Icon(Iconsax.edit, color: Colors.white),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsRow(ThemeData theme, bool isDark, dynamic customer) {
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            theme,
            isDark,
            icon: Iconsax.shopping_bag,
            value: '${customer?.totalOrders ?? 25}',
            label: 'طلب',
            color: Colors.blue,
          ),
        ),
        SizedBox(width: 12.w),
        Expanded(
          child: _buildStatCard(
            theme,
            isDark,
            icon: Iconsax.wallet_money,
            value: '${customer?.walletBalance?.toStringAsFixed(0) ?? '500'}',
            label: 'ر.ي',
            color: Colors.green,
          ),
        ),
        SizedBox(width: 12.w),
        Expanded(
          child: _buildStatCard(
            theme,
            isDark,
            icon: Iconsax.medal_star,
            value: '${customer?.loyaltyPoints ?? 150}',
            label: 'نقطة',
            color: Colors.orange,
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(
    ThemeData theme,
    bool isDark, {
    required IconData icon,
    required String value,
    required String label,
    required Color color,
  }) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardDark : AppColors.cardLight,
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Column(
        children: [
          Container(
            width: 40.w,
            height: 40.w,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 20.sp, color: color),
          ),
          SizedBox(height: 8.h),
          Text(
            value,
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              color: AppColors.textTertiaryLight,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuSection(
    ThemeData theme,
    bool isDark, {
    required String title,
    required List<_MenuItem> items,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(right: 4.w, bottom: 8.h),
          child: Text(
            title,
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondaryLight,
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: isDark ? AppColors.cardDark : AppColors.cardLight,
            borderRadius: BorderRadius.circular(16.r),
          ),
          child: Column(
            children: items.asMap().entries.map((entry) {
              final index = entry.key;
              final item = entry.value;
              return Column(
                children: [
                  _buildMenuItem(theme, item),
                  if (index < items.length - 1)
                    Divider(
                      height: 1,
                      indent: 56.w,
                      color: AppColors.dividerLight,
                    ),
                ],
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildMenuItem(ThemeData theme, _MenuItem item) {
    return ListTile(
      onTap: () {
        HapticFeedback.selectionClick();
        item.onTap();
      },
      leading: Container(
        width: 40.w,
        height: 40.w,
        decoration: BoxDecoration(
          color: AppColors.primary.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(10.r),
        ),
        child: Icon(item.icon, size: 20.sp, color: AppColors.primary),
      ),
      title: Text(
        item.title,
        style: theme.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w500),
      ),
      subtitle: item.subtitle != null
          ? Text(
              item.subtitle!,
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

  Widget _buildUnauthenticatedContent(BuildContext context, ThemeData theme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Iconsax.user_remove,
            size: 80.sp,
            color: AppColors.textTertiaryLight,
          ),
          SizedBox(height: 24.h),
          Text(
            'لم تقم بتسجيل الدخول',
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            'سجل الدخول للوصول إلى حسابك',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: AppColors.textTertiaryLight,
            ),
          ),
          SizedBox(height: 32.h),
          ElevatedButton(
            onPressed: () => context.go('/login'),
            style: ElevatedButton.styleFrom(
              padding: EdgeInsets.symmetric(horizontal: 48.w, vertical: 16.h),
            ),
            child: const Text('تسجيل الدخول'),
          ),
        ],
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('تسجيل الخروج'),
        content: const Text('هل أنت متأكد من تسجيل الخروج؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              context.read<AuthCubit>().logout();
              context.go('/login');
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            child: const Text('خروج'),
          ),
        ],
      ),
    );
  }
}

class _MenuItem {
  final IconData icon;
  final String title;
  final String? subtitle;
  final VoidCallback onTap;

  const _MenuItem({
    required this.icon,
    required this.title,
    this.subtitle,
    required this.onTap,
  });
}

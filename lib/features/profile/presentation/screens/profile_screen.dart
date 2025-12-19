/// Profile Screen - User profile and settings
library;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax/iconsax.dart';
import '../../../../core/config/theme/app_colors.dart';
import '../../../../core/config/theme/app_theme.dart';
import '../../../../core/widgets/app_image.dart';
import '../../../auth/presentation/cubit/auth_cubit.dart';
import '../../../auth/presentation/cubit/auth_state.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('حسابي'),
        actions: [
          IconButton(
            onPressed: () {},
            icon: Icon(Iconsax.setting_2, size: 24.sp),
          ),
        ],
      ),
      body: BlocBuilder<AuthCubit, AuthState>(
        builder: (context, state) {
          final customer = state is AuthAuthenticated ? state.customer : null;

          return ListView(
            padding: EdgeInsets.all(16.w),
            children: [
              // Profile Header
              Container(
                padding: EdgeInsets.all(20.w),
                decoration: BoxDecoration(
                  gradient: AppColors.primaryGradient,
                  borderRadius: AppTheme.radiusLg,
                ),
                child: Row(
                  children: [
                    AppAvatar(
                      name: customer?.responsiblePersonName ?? 'مستخدم',
                      size: 64,
                      backgroundColor: Colors.white.withValues(alpha: 0.2),
                    ),
                    SizedBox(width: 16.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            customer?.responsiblePersonName ?? 'مستخدم',
                            style: TextStyle(
                              fontSize: 18.sp,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                          SizedBox(height: 4.h),
                          Text(
                            customer?.shopName ?? 'اسم المحل',
                            style: TextStyle(
                              fontSize: 14.sp,
                              color: Colors.white.withValues(alpha: 0.8),
                            ),
                          ),
                          SizedBox(height: 4.h),
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 8.w,
                              vertical: 2.h,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.2),
                              borderRadius: AppTheme.radiusSm,
                            ),
                            child: Text(
                              customer?.loyaltyTier.toUpperCase() ?? 'BRONZE',
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
                    Icon(Iconsax.edit, color: Colors.white, size: 20.sp),
                  ],
                ),
              ),
              SizedBox(height: 16.h),

              // Stats Row
              Row(
                children: [
                  Expanded(
                    child: _buildStatCard(
                      context,
                      icon: Iconsax.wallet_3,
                      title: 'المحفظة',
                      value:
                          '${customer?.walletBalance.toStringAsFixed(0) ?? '0'} ر.س',
                      color: AppColors.success,
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: _buildStatCard(
                      context,
                      icon: Iconsax.star_1,
                      title: 'النقاط',
                      value: '${customer?.loyaltyPoints ?? 0}',
                      color: AppColors.warning,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 24.h),

              // Menu Items
              _buildMenuSection(
                context,
                title: 'إدارة الحساب',
                items: [
                  _MenuItem(Iconsax.user_edit, 'تعديل الملف الشخصي', () {}),
                  _MenuItem(Iconsax.location, 'العناوين', () {}),
                  _MenuItem(Iconsax.lock, 'تغيير كلمة المرور', () {}),
                ],
              ),
              SizedBox(height: 16.h),

              _buildMenuSection(
                context,
                title: 'المالية',
                items: [
                  _MenuItem(Iconsax.wallet_2, 'المحفظة', () {}),
                  _MenuItem(Iconsax.medal_star, 'نقاط الولاء', () {}),
                  _MenuItem(Iconsax.gift, 'الإحالات', () {}),
                ],
              ),
              SizedBox(height: 16.h),

              _buildMenuSection(
                context,
                title: 'الدعم',
                items: [
                  _MenuItem(Iconsax.message_question, 'الأسئلة الشائعة', () {}),
                  _MenuItem(Iconsax.headphone, 'تواصل معنا', () {}),
                  _MenuItem(Iconsax.info_circle, 'عن التطبيق', () {}),
                ],
              ),
              SizedBox(height: 24.h),

              // Logout Button
              GestureDetector(
                onTap: () {
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
                        TextButton(
                          onPressed: () {
                            Navigator.pop(ctx);
                            context.read<AuthCubit>().logout();
                            context.go('/login');
                          },
                          child: Text(
                            'خروج',
                            style: TextStyle(color: AppColors.error),
                          ),
                        ),
                      ],
                    ),
                  );
                },
                child: Container(
                  padding: EdgeInsets.all(16.w),
                  decoration: BoxDecoration(
                    color: AppColors.error.withValues(alpha: 0.1),
                    borderRadius: AppTheme.radiusMd,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Iconsax.logout, color: AppColors.error, size: 20.sp),
                      SizedBox(width: 8.w),
                      Text(
                        'تسجيل الخروج',
                        style: TextStyle(
                          fontSize: 15.sp,
                          fontWeight: FontWeight.w600,
                          color: AppColors.error,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 32.h),
            ],
          );
        },
      ),
    );
  }

  Widget _buildStatCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String value,
    required Color color,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardDark : AppColors.cardLight,
        borderRadius: AppTheme.radiusMd,
        boxShadow: AppTheme.shadowSm,
      ),
      child: Row(
        children: [
          Container(
            width: 44.w,
            height: 44.w,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Icon(icon, color: color, size: 22.sp),
          ),
          SizedBox(width: 12.w),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 12.sp,
                  color: isDark
                      ? AppColors.textSecondaryDark
                      : AppColors.textSecondaryLight,
                ),
              ),
              Text(
                value,
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w700,
                  color: isDark
                      ? AppColors.textPrimaryDark
                      : AppColors.textPrimaryLight,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMenuSection(
    BuildContext context, {
    required String title,
    required List<_MenuItem> items,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(bottom: 12.h, right: 4.w),
          child: Text(
            title,
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.w600,
              color: isDark
                  ? AppColors.textSecondaryDark
                  : AppColors.textSecondaryLight,
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: isDark ? AppColors.cardDark : AppColors.cardLight,
            borderRadius: AppTheme.radiusMd,
            boxShadow: AppTheme.shadowSm,
          ),
          child: Column(
            children: items.asMap().entries.map((entry) {
              final index = entry.key;
              final item = entry.value;
              return Column(
                children: [
                  ListTile(
                    onTap: item.onTap,
                    leading: Icon(
                      item.icon,
                      size: 22.sp,
                      color: AppColors.primary,
                    ),
                    title: Text(
                      item.title,
                      style: TextStyle(
                        fontSize: 15.sp,
                        fontWeight: FontWeight.w500,
                        color: isDark
                            ? AppColors.textPrimaryDark
                            : AppColors.textPrimaryLight,
                      ),
                    ),
                    trailing: Icon(
                      Iconsax.arrow_left_2,
                      size: 18.sp,
                      color: isDark
                          ? AppColors.textTertiaryDark
                          : AppColors.textTertiaryLight,
                    ),
                    contentPadding: EdgeInsets.symmetric(horizontal: 16.w),
                  ),
                  if (index < items.length - 1)
                    Divider(
                      height: 1,
                      indent: 56.w,
                      color: isDark
                          ? AppColors.dividerDark
                          : AppColors.dividerLight,
                    ),
                ],
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}

class _MenuItem {
  final IconData icon;
  final String title;
  final VoidCallback onTap;

  _MenuItem(this.icon, this.title, this.onTap);
}

/// Profile Screen - User account information and settings
library;

import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax/iconsax.dart';
import '../../../../core/config/theme/app_colors.dart';
import '../../../../core/di/injection.dart';
import '../../../auth/presentation/cubit/auth_cubit.dart';
import '../../../auth/presentation/cubit/auth_state.dart';
import '../../presentation/cubit/profile_cubit.dart';
import '../../presentation/cubit/profile_state.dart';
import '../../../../l10n/app_localizations.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return BlocProvider(
      create: (context) => getIt<ProfileCubit>()..loadProfile(),
      child: Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        appBar: AppBar(
          title: Text(AppLocalizations.of(context)!.profile),
          actions: [
            IconButton(
              icon: const Icon(Iconsax.setting_2),
              onPressed: () => context.push('/settings'),
            ),
          ],
        ),
        body: BlocBuilder<AuthCubit, AuthState>(
          builder: (context, authState) {
            if (authState is AuthAuthenticated) {
              return BlocBuilder<ProfileCubit, ProfileState>(
                builder: (context, profileState) {
                  if (profileState is ProfileLoading) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (profileState is ProfileError) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Iconsax.warning_2,
                            size: 64.sp,
                            color: AppColors.error,
                          ),
                          SizedBox(height: 16.h),
                          Text(
                            profileState.message,
                            style: theme.textTheme.bodyLarge,
                            textAlign: TextAlign.center,
                          ),
                          SizedBox(height: 16.h),
                          ElevatedButton(
                            onPressed: () =>
                                context.read<ProfileCubit>().loadProfile(),
                            child: const Text('إعادة المحاولة'),
                          ),
                        ],
                      ),
                    );
                  } else if (profileState is ProfileLoaded ||
                      profileState is ProfileUpdated) {
                    final customer = (profileState is ProfileLoaded
                        ? profileState.customer
                        : (profileState as ProfileUpdated).customer);

                    return RefreshIndicator(
                      onRefresh: () =>
                          context.read<ProfileCubit>().loadProfile(),
                      child: SingleChildScrollView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        padding: EdgeInsets.all(16.w),
                        child: Column(
                          children: [
                            // Profile Header
                            _buildProfileHeader(
                              context,
                              theme,
                              isDark,
                              customer,
                            ),
                            SizedBox(height: 24.h),

                            // Statistics Grid
                            _buildSectionTitle(theme, isDark, 'الإحصائيات'),
                            SizedBox(height: 12.h),
                            _buildStatsGrid(theme, isDark, customer),
                            SizedBox(height: 12.h),

                            // Business Info
                            _buildSectionTitle(theme, isDark, 'معلومات العمل'),
                            SizedBox(height: 12.h),
                            _buildBusinessInfoCard(theme, isDark, customer),
                            SizedBox(height: 12.h),

                            // Location Info
                            if (customer.cityId != null ||
                                customer.address != null)
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _buildSectionTitle(theme, isDark, 'الموقع'),
                                  SizedBox(height: 12.h),
                                  _buildLocationInfoCard(
                                    theme,
                                    isDark,
                                    customer,
                                  ),
                                  SizedBox(height: 24.h),
                                ],
                              ),

                            // Wallet & Credit
                            _buildSectionTitle(
                              theme,
                              isDark,
                              'المحفظة والائتمان',
                            ),
                            SizedBox(height: 12.h),
                            _buildWalletCard(theme, isDark, customer),
                            SizedBox(height: 24.h),

                            // Actions
                            _buildSectionTitle(theme, isDark, 'الإجراءات'),
                            SizedBox(height: 12.h),
                            _buildActionsSection(context, theme, isDark),
                            SizedBox(height: 24.h),

                            // Logout Button
                            SizedBox(
                              width: double.infinity,
                              child: OutlinedButton.icon(
                                onPressed: () => _showLogoutDialog(context),
                                icon: const Icon(
                                  Iconsax.logout,
                                  color: AppColors.error,
                                ),
                                label: Text(
                                  AppLocalizations.of(context)!.logout,
                                  style: const TextStyle(
                                    color: AppColors.error,
                                  ),
                                ),
                                style: OutlinedButton.styleFrom(
                                  side: const BorderSide(
                                    color: AppColors.error,
                                  ),
                                  padding: EdgeInsets.symmetric(vertical: 16.h),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(14.r),
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(height: 88.h), // Extra space for nav bar
                          ],
                        ),
                      ),
                    );
                  }
                  return const SizedBox();
                },
              );
            }
            return _buildUnauthenticatedContent(context, theme);
          },
        ),
      ),
    );
  }

  Widget _buildProfileHeader(
    BuildContext context,
    ThemeData theme,
    bool isDark,
    customer,
  ) {
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
            height: 70.h,
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
                  customer.responsiblePersonName,
                  style: TextStyle(
                    fontSize: 20.sp,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  customer.getShopName('ar'),
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: Colors.white.withValues(alpha: 0.8),
                  ),
                ),
                SizedBox(height: 4.h),
                Row(
                  children: [
                    if (customer.isApproved)
                      Container(
                        margin: EdgeInsets.only(left: 8.w),
                        padding: EdgeInsets.symmetric(
                          horizontal: 8.w,
                          vertical: 4.h,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.green.withValues(alpha: 0.3),
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                        child: Text(
                          '✓ معتمد',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 11.sp,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 8.w,
                        vertical: 4.h,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      child: Text(
                        customer.customerCode,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 11.sp,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Edit Button
          IconButton(
            onPressed: () => context.push('/edit-profile'),
            icon: const Icon(Iconsax.edit, color: Colors.white),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(ThemeData theme, bool isDark, String title) {
    return Padding(
      padding: EdgeInsets.only(right: 4.w),
      child: Text(
        title,
        style: theme.textTheme.titleSmall?.copyWith(
          fontWeight: FontWeight.w600,
          color: isDark
              ? AppColors.textSecondaryDark
              : AppColors.textSecondaryLight,
        ),
      ),
    );
  }

  Widget _buildStatsGrid(ThemeData theme, bool isDark, customer) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: EdgeInsets.zero,
      crossAxisSpacing: 12.w,
      mainAxisSpacing: 12.h,
      childAspectRatio: 1.7,
      children: [
        _buildStatCard(
          theme: theme,
          isDark: isDark,
          title: 'إجمالي الطلبات',
          value: customer.totalOrders.toString(),
          icon: Iconsax.shopping_bag,
          color: Colors.blue,
        ),
        _buildStatCard(
          theme: theme,
          isDark: isDark,
          title: 'إجمالي الإنفاق',
          value: '${customer.totalSpent.toStringAsFixed(2)} ر.س',
          icon: Iconsax.wallet_money,
          color: Colors.green,
        ),
        _buildStatCard(
          theme: theme,
          isDark: isDark,
          title: 'متوسط قيمة الطلب',
          value: '${customer.averageOrderValue.toStringAsFixed(2)} ر.س',
          icon: Iconsax.trend_up,
          color: Colors.orange,
        ),
        _buildStatCard(
          theme: theme,
          isDark: isDark,
          title: 'نقاط الولاء',
          value: customer.loyaltyPoints.toString(),
          icon: Iconsax.medal_star,
          color: Colors.purple,
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required ThemeData theme,
    required bool isDark,
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(18.r),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: EdgeInsets.all(10.w),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: isDark
                  ? [
                      Colors.white.withValues(alpha: 0.1),
                      Colors.white.withValues(alpha: 0.05),
                    ]
                  : [
                      Colors.white.withValues(alpha: 0.9),
                      Colors.white.withValues(alpha: 0.7),
                    ],
            ),
            borderRadius: BorderRadius.circular(18.r),
            border: Border.all(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.12)
                  : color.withValues(alpha: 0.2),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: color.withValues(alpha: 0.15),
                blurRadius: 15,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Flexible(
                child: Icon(icon, color: color, size: 24.sp),
              ),
              SizedBox(height: 4.h),
              Flexible(
                child: Text(
                  value,
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              SizedBox(height: 2.h),
              Flexible(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 10.sp,
                    color: isDark
                        ? AppColors.textSecondaryDark
                        : AppColors.textSecondaryLight,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBusinessInfoCard(ThemeData theme, bool isDark, customer) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(18.r),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: isDark
                  ? [
                      Colors.white.withValues(alpha: 0.08),
                      Colors.white.withValues(alpha: 0.04),
                    ]
                  : [
                      Colors.white.withValues(alpha: 0.9),
                      Colors.white.withValues(alpha: 0.75),
                    ],
            ),
            borderRadius: BorderRadius.circular(18.r),
            border: Border.all(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.1)
                  : AppColors.primary.withValues(alpha: 0.1),
              width: 1.5,
            ),
          ),
          child: Column(
            children: [
              _buildInfoTile(
                theme,
                isDark,
                Iconsax.shop,
                'اسم المتجر',
                customer.getShopName('ar'),
              ),
              Divider(
                height: 1,
                indent: 56.w,
                color: isDark ? AppColors.dividerDark : AppColors.dividerLight,
              ),
              _buildInfoTile(
                theme,
                isDark,
                Iconsax.user,
                'اسم المسؤول',
                customer.responsiblePersonName,
              ),
              Divider(
                height: 1,
                indent: 56.w,
                color: isDark ? AppColors.dividerDark : AppColors.dividerLight,
              ),
              _buildInfoTile(
                theme,
                isDark,
                Iconsax.category,
                'نوع العمل',
                customer.businessType.displayName,
              ),
              Divider(
                height: 1,
                indent: 56.w,
                color: isDark ? AppColors.dividerDark : AppColors.dividerLight,
              ),
              _buildInfoTile(
                theme,
                isDark,
                Iconsax.code,
                'كود العميل',
                customer.customerCode,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoTile(
    ThemeData theme,
    bool isDark,
    IconData icon,
    String title,
    String value,
  ) {
    return ListTile(
      leading: Container(
        width: 42.w,
        height: 42.w,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.primary.withValues(alpha: 0.15),
              AppColors.primaryLight.withValues(alpha: 0.08),
            ],
          ),
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: Icon(icon, size: 20.sp, color: AppColors.primary),
      ),
      title: Text(
        title,
        style: theme.textTheme.bodySmall?.copyWith(
          color: isDark
              ? AppColors.textSecondaryDark
              : AppColors.textSecondaryLight,
        ),
      ),
      subtitle: Text(
        value,
        style: theme.textTheme.bodyLarge?.copyWith(
          fontWeight: FontWeight.w500,
          color: isDark
              ? AppColors.textPrimaryDark
              : AppColors.textPrimaryLight,
        ),
      ),
      contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 6.h),
    );
  }

  Widget _buildLocationInfoCard(ThemeData theme, bool isDark, customer) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(18.r),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: isDark
                  ? [
                      Colors.white.withValues(alpha: 0.08),
                      Colors.white.withValues(alpha: 0.04),
                    ]
                  : [
                      Colors.white.withValues(alpha: 0.9),
                      Colors.white.withValues(alpha: 0.75),
                    ],
            ),
            borderRadius: BorderRadius.circular(18.r),
            border: Border.all(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.1)
                  : AppColors.primary.withValues(alpha: 0.1),
              width: 1.5,
            ),
          ),
          child: Column(
            children: [
              if (customer.address != null)
                _buildInfoTile(
                  theme,
                  isDark,
                  Iconsax.location,
                  'العنوان',
                  customer.address!,
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWalletCard(ThemeData theme, bool isDark, customer) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(18.r),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
        child: Container(
          padding: EdgeInsets.all(16.w),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppColors.primary.withValues(alpha: 0.1),
                AppColors.primaryLight.withValues(alpha: 0.05),
              ],
            ),
            borderRadius: BorderRadius.circular(18.r),
            border: Border.all(
              color: AppColors.primary.withValues(alpha: 0.2),
              width: 1.5,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'رصيد المحفظة',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: isDark
                      ? AppColors.textSecondaryDark
                      : AppColors.textSecondaryLight,
                ),
              ),
              SizedBox(height: 4.h),
              Text(
                '${customer.walletBalance.toStringAsFixed(2)} ر.س',
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
              SizedBox(height: 16.h),
              Divider(),
              SizedBox(height: 16.h),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'حد الائتمان',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: isDark
                              ? AppColors.textSecondaryDark
                              : AppColors.textSecondaryLight,
                        ),
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        '${customer.creditLimit.toStringAsFixed(2)} ر.س',
                        style: theme.textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        'المستخدم',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: isDark
                              ? AppColors.textSecondaryDark
                              : AppColors.textSecondaryLight,
                        ),
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        '${customer.creditUsed.toStringAsFixed(2)} ر.س',
                        style: theme.textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              SizedBox(height: 12.h),
              LinearProgressIndicator(
                value: customer.creditLimit > 0
                    ? customer.creditUsed / customer.creditLimit
                    : 0,
                backgroundColor: isDark
                    ? Colors.white.withValues(alpha: 0.1)
                    : Colors.grey.shade300,
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
              ),
              SizedBox(height: 8.h),
              Text(
                'المتاح: ${customer.availableCredit.toStringAsFixed(2)} ر.س',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: isDark
                      ? AppColors.textSecondaryDark
                      : AppColors.textSecondaryLight,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionsSection(
    BuildContext context,
    ThemeData theme,
    bool isDark,
  ) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(18.r),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: isDark
                  ? [
                      Colors.white.withValues(alpha: 0.08),
                      Colors.white.withValues(alpha: 0.04),
                    ]
                  : [
                      Colors.white.withValues(alpha: 0.9),
                      Colors.white.withValues(alpha: 0.75),
                    ],
            ),
            borderRadius: BorderRadius.circular(18.r),
            border: Border.all(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.1)
                  : AppColors.primary.withValues(alpha: 0.1),
              width: 1.5,
            ),
          ),
          child: Column(
            children: [
              _MenuItem(
                icon: Iconsax.user_edit,
                title: AppLocalizations.of(context)!.editProfile,
                onTap: () => context.push('/edit-profile'),
              ),
              Divider(
                height: 1,
                indent: 56.w,
                color: isDark ? AppColors.dividerDark : AppColors.dividerLight,
              ),
              _MenuItem(
                icon: Iconsax.location,
                title: AppLocalizations.of(context)!.addresses,
                onTap: () => context.push('/addresses'),
              ),
              Divider(
                height: 1,
                indent: 56.w,
                color: isDark ? AppColors.dividerDark : AppColors.dividerLight,
              ),
              _MenuItem(
                icon: Iconsax.box,
                title: AppLocalizations.of(context)!.orders,
                onTap: () => context.push('/orders'),
              ),
              Divider(
                height: 1,
                indent: 56.w,
                color: isDark ? AppColors.dividerDark : AppColors.dividerLight,
              ),
              _MenuItem(
                icon: Iconsax.trash,
                title: 'حذف الحساب',
                onTap: () => _showDeleteAccountDialog(context),
                isDestructive: true,
              ),
            ],
          ),
        ),
      ),
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
            child: Text(AppLocalizations.of(context)!.login),
          ),
        ],
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(AppLocalizations.of(context)!.logout),
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

  void _showDeleteAccountDialog(BuildContext context) {
    final reasonController = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('حذف الحساب'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'هل أنت متأكد من حذف حسابك؟ هذا الإجراء لا يمكن التراجع عنه.',
            ),
            SizedBox(height: 16.h),
            TextField(
              controller: reasonController,
              decoration: const InputDecoration(
                labelText: 'السبب (اختياري)',
                hintText: 'أخبرنا لماذا تريد حذف حسابك...',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              reasonController.dispose();
              Navigator.pop(ctx);
            },
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () async {
              final reason = reasonController.text.trim().isEmpty
                  ? null
                  : reasonController.text.trim();
              reasonController.dispose();

              final success = await context.read<ProfileCubit>().deleteAccount(
                reason: reason,
              );

              if (ctx.mounted) {
                Navigator.pop(ctx);
                if (success) {
                  context.read<AuthCubit>().logout();
                  context.go('/login');
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('فشل حذف الحساب'),
                      backgroundColor: AppColors.error,
                    ),
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            child: const Text('حذف'),
          ),
        ],
      ),
    );
  }
}

class _MenuItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;
  final bool isDestructive;

  const _MenuItem({
    required this.icon,
    required this.title,
    required this.onTap,
    this.isDestructive = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return ListTile(
      onTap: () {
        HapticFeedback.selectionClick();
        onTap();
      },
      leading: Container(
        width: 42.w,
        height: 42.w,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isDestructive
                ? [
                    AppColors.error.withValues(alpha: 0.15),
                    AppColors.error.withValues(alpha: 0.08),
                  ]
                : [
                    AppColors.primary.withValues(alpha: 0.15),
                    AppColors.primaryLight.withValues(alpha: 0.08),
                  ],
          ),
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: Icon(
          icon,
          size: 20.sp,
          color: isDestructive ? AppColors.error : AppColors.primary,
        ),
      ),
      title: Text(
        title,
        style: theme.textTheme.bodyLarge?.copyWith(
          fontWeight: FontWeight.w500,
          color: isDestructive
              ? AppColors.error
              : (isDark
                    ? AppColors.textPrimaryDark
                    : AppColors.textPrimaryLight),
        ),
      ),
      trailing: Container(
        width: 28.w,
        height: 28.w,
        decoration: BoxDecoration(
          color: AppColors.primary.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(8.r),
        ),
        child: Icon(
          Iconsax.arrow_left_2,
          size: 16.sp,
          color: AppColors.primary,
        ),
      ),
      contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 6.h),
    );
  }
}

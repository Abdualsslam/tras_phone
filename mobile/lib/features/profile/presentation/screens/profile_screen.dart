/// Profile Screen - User account information and settings
library;

import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax/iconsax.dart';
import '../../../../core/config/theme/app_colors.dart';
import '../../../auth/presentation/cubit/auth_cubit.dart';
import '../../../auth/presentation/cubit/auth_state.dart';
import '../../domain/entities/address_entity.dart';
import '../../presentation/cubit/profile_cubit.dart';
import '../../presentation/cubit/profile_state.dart';
import '../../../../l10n/app_localizations.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
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
                          child: Text(
                            AppLocalizations.of(context)!.retryAction,
                          ),
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
                    onRefresh: () => context.read<ProfileCubit>().loadProfile(),
                    child: SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: EdgeInsets.all(16.w),
                      child: Column(
                        children: [
                          // Profile Header
                          _buildProfileHeader(context, theme, isDark, customer),
                          SizedBox(height: 24.h),

                          // Statistics Grid
                          _buildSectionTitle(
                            theme,
                            isDark,
                            AppLocalizations.of(context)!.statistics,
                          ),
                          SizedBox(height: 12.h),
                          _buildStatsGrid(context, theme, isDark, customer),
                          SizedBox(height: 12.h),

                          // Business Info
                          _buildSectionTitle(
                            theme,
                            isDark,
                            AppLocalizations.of(context)!.businessInfo,
                          ),
                          SizedBox(height: 12.h),
                          _buildBusinessInfoCard(
                            context,
                            theme,
                            isDark,
                            customer,
                          ),
                          SizedBox(height: 12.h),

                          // Location Info - Default Address
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              _buildSectionTitle(
                                theme,
                                isDark,
                                AppLocalizations.of(context)!.deliveryAddresses,
                              ),
                              SizedBox(height: 12.h),
                              _buildLocationInfoCard(context, theme, isDark),
                              SizedBox(height: 24.h),
                            ],
                          ),

                          // Wallet & Credit
                          _buildSectionTitle(
                            theme,
                            isDark,
                            AppLocalizations.of(context)!.walletAndCredit,
                          ),
                          SizedBox(height: 12.h),
                          _buildWalletCard(context, theme, isDark, customer),
                          SizedBox(height: 12.h),
                          _buildReturnsCard(context, theme, isDark),
                          SizedBox(height: 12.h),
                          _buildSupportCard(context, theme, isDark),
                          SizedBox(height: 12.h),
                          _buildEducationCenterCard(context, theme, isDark),
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
                                style: const TextStyle(color: AppColors.error),
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
                          '✓ ${AppLocalizations.of(context)!.verified}',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 11.sp,
                            fontWeight: FontWeight.bold,
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

  Widget _buildStatsGrid(
    BuildContext context,
    ThemeData theme,
    bool isDark,
    customer,
  ) {
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
          title: AppLocalizations.of(context)!.totalOrders,
          value: customer.totalOrders.toString(),
          icon: Iconsax.shopping_bag,
          color: Colors.blue,
        ),
        _buildStatCard(
          theme: theme,
          isDark: isDark,
          title: AppLocalizations.of(context)!.totalSpent,
          value:
              '${customer.totalSpent.toStringAsFixed(2)} ${AppLocalizations.of(context)!.currency}',
          icon: Iconsax.wallet_money,
          color: Colors.green,
        ),
        _buildStatCard(
          theme: theme,
          isDark: isDark,
          title: AppLocalizations.of(context)!.averageOrderValue,
          value:
              '${customer.averageOrderValue.toStringAsFixed(2)} ${AppLocalizations.of(context)!.currency}',
          icon: Iconsax.trend_up,
          color: Colors.orange,
        ),
        _buildStatCard(
          theme: theme,
          isDark: isDark,
          title: AppLocalizations.of(context)!.loyaltyPoints,
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

  Widget _buildBusinessInfoCard(
    BuildContext context,
    ThemeData theme,
    bool isDark,
    customer,
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
              _buildInfoTile(
                theme,
                isDark,
                Iconsax.shop,
                AppLocalizations.of(context)!.shopName,
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
                AppLocalizations.of(context)!.responsiblePerson,
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
                AppLocalizations.of(context)!.businessType,
                customer.businessType.displayName,
              ),
              Divider(
                height: 1,
                indent: 56.w,
                color: isDark ? AppColors.dividerDark : AppColors.dividerLight,
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

  Widget _buildLocationInfoCard(
    BuildContext context,
    ThemeData theme,
    bool isDark,
  ) {
    return BlocConsumer<AddressesCubit, AddressesState>(
      listener: (context, addressesState) {
        // Ensure UI updates when addresses change
        // The builder will automatically rebuild when state changes
      },
      builder: (context, addressesState) {
        // Get list of addresses
        List<AddressEntity> addresses = [];
        if (addressesState is AddressesLoaded) {
          addresses = addressesState.addresses;
        } else if (addressesState is AddressOperationLoading) {
          addresses = addressesState.addresses;
        } else if (addressesState is AddressOperationSuccess) {
          addresses = addressesState.addresses;
        }

        // Get default address
        AddressEntity? defaultAddress = addresses
            .where((a) => a.isDefault)
            .firstOrNull;

        // If no default address but there are addresses, set the last one as default
        if (defaultAddress == null && addresses.isNotEmpty) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            try {
              final lastAddress = addresses.last;
              context.read<AddressesCubit>().setDefaultAddress(lastAddress.id);
            } catch (e) {
              // AddressesCubit not available, ignore
            }
          });
        }

        // Load addresses if not loaded yet
        if (addressesState is AddressesInitial) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            try {
              context.read<AddressesCubit>().loadAddresses();
            } catch (e) {
              // AddressesCubit not available, ignore
            }
          });
        }

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
                  if (addressesState is AddressesLoading)
                    Padding(
                      padding: EdgeInsets.all(16.w),
                      child: const Center(child: CircularProgressIndicator()),
                    )
                  else if (defaultAddress != null) ...[
                    _buildInfoTile(
                      theme,
                      isDark,
                      Iconsax.location,
                      defaultAddress.label,
                      defaultAddress.fullAddress,
                    ),
                    if (defaultAddress.notes != null &&
                        defaultAddress.notes!.isNotEmpty) ...[
                      Divider(
                        height: 1,
                        indent: 56.w,
                        color: isDark
                            ? AppColors.dividerDark
                            : AppColors.dividerLight,
                      ),
                      ListTile(
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
                          child: Icon(
                            Iconsax.note,
                            size: 20.sp,
                            color: AppColors.primary,
                          ),
                        ),
                        title: Text(
                          'ملاحظات',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: isDark
                                ? AppColors.textSecondaryDark
                                : AppColors.textSecondaryLight,
                          ),
                        ),
                        subtitle: Text(
                          defaultAddress.notes!,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: isDark
                                ? AppColors.textPrimaryDark
                                : AppColors.textPrimaryLight,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 16.w,
                          vertical: 6.h,
                        ),
                      ),
                    ],
                    Divider(
                      height: 1,
                      indent: 56.w,
                      color: isDark
                          ? AppColors.dividerDark
                          : AppColors.dividerLight,
                    ),
                    ListTile(
                      onTap: () => context.push('/addresses'),
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
                        child: Icon(
                          Iconsax.location_add,
                          size: 20.sp,
                          color: AppColors.primary,
                        ),
                      ),
                      title: Text(
                        AppLocalizations.of(context)!.manageAddresses,
                        style: theme.textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.w500,
                          color: isDark
                              ? AppColors.textPrimaryDark
                              : AppColors.textPrimaryLight,
                        ),
                      ),
                      trailing: Icon(
                        Iconsax.arrow_left_2,
                        size: 20.sp,
                        color: AppColors.primary,
                      ),
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 16.w,
                        vertical: 6.h,
                      ),
                    ),
                  ] else ...[
                    ListTile(
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
                        child: Icon(
                          Iconsax.location,
                          size: 20.sp,
                          color: AppColors.primary,
                        ),
                      ),
                      title: Text(
                        AppLocalizations.of(context)!.noDefaultAddress,
                        style: theme.textTheme.bodyLarge?.copyWith(
                          color: isDark
                              ? AppColors.textSecondaryDark
                              : AppColors.textSecondaryLight,
                        ),
                      ),
                      subtitle: Text(
                        AppLocalizations.of(context)!.addAddressHint,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: isDark
                              ? AppColors.textTertiaryDark
                              : AppColors.textTertiaryLight,
                        ),
                      ),
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 16.w,
                        vertical: 6.h,
                      ),
                    ),
                    Divider(
                      height: 1,
                      indent: 56.w,
                      color: isDark
                          ? AppColors.dividerDark
                          : AppColors.dividerLight,
                    ),
                    ListTile(
                      onTap: () => context.push('/addresses'),
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
                        child: Icon(
                          Iconsax.location_add,
                          size: 20.sp,
                          color: AppColors.primary,
                        ),
                      ),
                      title: Text(
                        AppLocalizations.of(context)!.addAddress,
                        style: theme.textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.w500,
                          color: AppColors.primary,
                        ),
                      ),
                      trailing: Icon(
                        Iconsax.arrow_left_2,
                        size: 20.sp,
                        color: AppColors.primary,
                      ),
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 16.w,
                        vertical: 6.h,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildWalletCard(
    BuildContext context,
    ThemeData theme,
    bool isDark,
    customer,
  ) {
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
                AppLocalizations.of(context)!.walletBalance,
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
                        AppLocalizations.of(context)!.creditLimit,
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
                        AppLocalizations.of(context)!.creditUsed,
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
                AppLocalizations.of(
                  context,
                )!.creditAvailable(customer.availableCredit.toStringAsFixed(2)),
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

  Widget _buildReturnsCard(BuildContext context, ThemeData theme, bool isDark) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => context.push('/returns'),
        borderRadius: BorderRadius.circular(18.r),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(18.r),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
            child: Container(
              padding: EdgeInsets.all(16.w),
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
                          Colors.white.withValues(alpha: 0.7),
                        ],
                ),
                borderRadius: BorderRadius.circular(18.r),
                border: Border.all(
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.12)
                      : Colors.orange.withValues(alpha: 0.2),
                  width: 1.5,
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 42.w,
                    height: 42.w,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Colors.orange.withValues(alpha: 0.2),
                          Colors.orange.withValues(alpha: 0.08),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    child: Icon(
                      Iconsax.rotate_left,
                      size: 20.sp,
                      color: Colors.orange,
                    ),
                  ),
                  SizedBox(width: 16.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          AppLocalizations.of(context)!.returns,
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        SizedBox(height: 2.h),
                        Text(
                          AppLocalizations.of(context)!.viewReturns,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: isDark
                                ? AppColors.textSecondaryDark
                                : AppColors.textSecondaryLight,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(Iconsax.arrow_left_2, size: 20.sp, color: Colors.orange),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSupportCard(BuildContext context, ThemeData theme, bool isDark) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => context.push('/support'),
        borderRadius: BorderRadius.circular(18.r),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(18.r),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
            child: Container(
              padding: EdgeInsets.all(16.w),
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
                          Colors.white.withValues(alpha: 0.7),
                        ],
                ),
                borderRadius: BorderRadius.circular(18.r),
                border: Border.all(
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.12)
                      : AppColors.primary.withValues(alpha: 0.2),
                  width: 1.5,
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 42.w,
                    height: 42.w,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          AppColors.primary.withValues(alpha: 0.2),
                          AppColors.primary.withValues(alpha: 0.08),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    child: Icon(
                      Iconsax.headphone,
                      size: 20.sp,
                      color: AppColors.primary,
                    ),
                  ),
                  SizedBox(width: 16.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          AppLocalizations.of(context)!.support,
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        SizedBox(height: 2.h),
                        Text(
                          AppLocalizations.of(context)!.contactSupport,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: isDark
                                ? AppColors.textSecondaryDark
                                : AppColors.textSecondaryLight,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    Iconsax.arrow_left_2,
                    size: 20.sp,
                    color: AppColors.primary,
                  ),
                ],
              ),
            ),
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
            AppLocalizations.of(context)!.notLoggedIn,
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            AppLocalizations.of(context)!.loginToAccess,
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
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context)!;

    showDialog(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.45),
      builder: (ctx) => AlertDialog(
        backgroundColor: isDark ? AppColors.cardDark : AppColors.cardLight,
        insetPadding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 24.h),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24.r),
        ),
        titlePadding: EdgeInsets.fromLTRB(20.w, 20.h, 20.w, 10.h),
        contentPadding: EdgeInsets.fromLTRB(20.w, 0, 20.w, 8.h),
        actionsPadding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 16.h),
        title: Row(
          children: [
            Container(
              width: 44.w,
              height: 44.w,
              decoration: BoxDecoration(
                color: AppColors.error.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(14.r),
              ),
              child: Icon(Iconsax.logout, color: AppColors.error, size: 20.sp),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Text(
                l10n.logout,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
        content: Text(
          l10n.logoutConfirm,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: isDark
                ? AppColors.textSecondaryDark
                : AppColors.textSecondaryLight,
            height: 1.45,
          ),
        ),
        actions: [
          SizedBox(
            height: 44.h,
            child: OutlinedButton(
              onPressed: () => Navigator.pop(ctx),
              style: OutlinedButton.styleFrom(
                side: BorderSide(
                  color: isDark
                      ? AppColors.dividerDark
                      : AppColors.dividerLight,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
                padding: EdgeInsets.symmetric(horizontal: 18.w),
              ),
              child: Text(l10n.cancel),
            ),
          ),
          SizedBox(
            height: 44.h,
            child: ElevatedButton.icon(
              onPressed: () {
                Navigator.pop(ctx);
                context.read<AuthCubit>().logout();
                context.go('/login');
              },
              icon: Icon(Iconsax.logout_1, size: 16.sp),
              label: Text(l10n.logoutAction),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.error,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
                padding: EdgeInsets.symmetric(horizontal: 16.w),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEducationCenterCard(
    BuildContext context,
    ThemeData theme,
    bool isDark,
  ) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => context.push('/education'),
        borderRadius: BorderRadius.circular(18.r),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(18.r),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
            child: Container(
              padding: EdgeInsets.all(16.w),
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
                          Colors.white.withValues(alpha: 0.7),
                        ],
                ),
                borderRadius: BorderRadius.circular(18.r),
                border: Border.all(
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.12)
                      : Colors.teal.withValues(alpha: 0.2),
                  width: 1.5,
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 42.w,
                    height: 42.w,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Colors.teal.withValues(alpha: 0.2),
                          Colors.teal.withValues(alpha: 0.08),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    child: Icon(
                      Iconsax.book_1,
                      size: 20.sp,
                      color: Colors.teal,
                    ),
                  ),
                  SizedBox(width: 16.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          AppLocalizations.of(context)!.education,
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        SizedBox(height: 2.h),
                        Text(
                          'مقالات، فيديوهات ودروس عملية',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: isDark
                                ? AppColors.textSecondaryDark
                                : AppColors.textSecondaryLight,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(Iconsax.arrow_left_2, size: 20.sp, color: Colors.teal),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

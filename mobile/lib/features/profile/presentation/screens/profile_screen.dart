/// Profile Screen - User account information and settings
library;

import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax/iconsax.dart';

import '../../../../core/config/theme/app_colors.dart';
import '../../../../core/shimmer/index.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../auth/domain/entities/customer_entity.dart';
import '../../../auth/presentation/cubit/auth_cubit.dart';
import '../../../auth/presentation/cubit/auth_state.dart';
import '../../domain/entities/address_entity.dart';
import '../../presentation/cubit/profile_cubit.dart';
import '../../presentation/cubit/profile_state.dart';
import '../widgets/profile_sections.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  CustomerEntity? _cachedCustomer;

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
                final customer = _extractCustomer(profileState);
                if (customer != null) {
                  _cachedCustomer = customer;
                  return _buildProfileContent(context, isDark, customer);
                }

                if (profileState is ProfileLoading) {
                  if (_cachedCustomer == null) {
                    return const ProfileShimmer();
                  }

                  return _buildProfileContent(
                    context,
                    isDark,
                    _cachedCustomer!,
                  );
                }

                if (profileState is ProfileError) {
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
                }

                return const ProfileShimmer();
              },
            );
          }

          return ProfileUnauthenticatedContent(
            onLogin: () => context.go('/login'),
          );
        },
      ),
    );
  }

  CustomerEntity? _extractCustomer(ProfileState state) {
    if (state is ProfileLoaded) {
      return state.customer;
    }
    if (state is ProfileUpdated) {
      return state.customer;
    }
    return null;
  }

  Widget _buildProfileContent(
    BuildContext context,
    bool isDark,
    CustomerEntity customer,
  ) {
    final l10n = AppLocalizations.of(context)!;

    return RefreshIndicator(
      onRefresh: () => context.read<ProfileCubit>().loadProfile(),
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: EdgeInsets.all(16.w),
        child: Column(
          children: [
            ProfileHeaderCard(
              customer: customer,
              onEditPressed: () => context.push('/edit-profile'),
            ),
            SizedBox(height: 24.h),
            ProfileSectionTitle(title: l10n.statistics, isDark: isDark),
            SizedBox(height: 12.h),
            ProfileStatsGrid(isDark: isDark, customer: customer),
            SizedBox(height: 12.h),
            ProfileSectionTitle(title: l10n.businessInfo, isDark: isDark),
            SizedBox(height: 12.h),
            ProfileBusinessInfoCard(isDark: isDark, customer: customer),
            SizedBox(height: 12.h),
            Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                ProfileSectionTitle(
                  title: l10n.deliveryAddresses,
                  isDark: isDark,
                ),
                SizedBox(height: 12.h),
                _buildLocationInfoCard(context, Theme.of(context), isDark),
                SizedBox(height: 24.h),
              ],
            ),
            ProfileSectionTitle(title: l10n.walletAndCredit, isDark: isDark),
            SizedBox(height: 12.h),
            ProfileWalletCard(
              isDark: isDark,
              customer: customer,
              onOpenWallet: () => context.push('/wallet'),
            ),
            SizedBox(height: 12.h),
            ProfileActionCard(
              isDark: isDark,
              icon: Iconsax.rotate_left,
              accentColor: Colors.orange,
              title: l10n.returns,
              subtitle: l10n.viewReturns,
              onTap: () => context.push('/returns'),
            ),
            SizedBox(height: 12.h),
            ProfileActionCard(
              isDark: isDark,
              icon: Iconsax.headphone,
              accentColor: AppColors.primary,
              title: l10n.support,
              subtitle: l10n.contactSupport,
              onTap: () => context.push('/support'),
            ),
            SizedBox(height: 12.h),
            ProfileActionCard(
              isDark: isDark,
              icon: Iconsax.book_1,
              accentColor: Colors.teal,
              title: l10n.education,
              subtitle: 'مقالات، فيديوهات ودروس عملية',
              onTap: () => context.push('/education'),
            ),
            SizedBox(height: 24.h),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () => _showLogoutDialog(context),
                icon: const Icon(Iconsax.logout, color: AppColors.error),
                label: Text(
                  l10n.logout,
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
            SizedBox(height: 88.h),
          ],
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
                          'Ù…Ù„Ø§Ø­Ø¸Ø§Øª',
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
}

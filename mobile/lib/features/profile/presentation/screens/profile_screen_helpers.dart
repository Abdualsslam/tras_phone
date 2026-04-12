import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax/iconsax.dart';

import '../../../../core/config/theme/app_colors.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../auth/domain/entities/customer_entity.dart';
import '../../domain/entities/address_entity.dart';
import '../cubit/profile_cubit.dart';
import '../cubit/profile_state.dart';
import '../widgets/profile_sections.dart';

class ProfileScreenContent extends StatelessWidget {
  final bool isDark;
  final CustomerEntity customer;
  final VoidCallback onRefresh;
  final VoidCallback onEditPressed;
  final VoidCallback onLogoutPressed;

  const ProfileScreenContent({
    super.key,
    required this.isDark,
    required this.customer,
    required this.onRefresh,
    required this.onEditPressed,
    required this.onLogoutPressed,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return RefreshIndicator(
      onRefresh: () async => onRefresh(),
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: EdgeInsets.all(16.w),
        child: Column(
          children: [
            ProfileHeaderCard(customer: customer, onEditPressed: onEditPressed),
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
                ProfileLocationInfoCard(isDark: isDark),
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
                onPressed: onLogoutPressed,
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
}

class ProfileLocationInfoCard extends StatelessWidget {
  final bool isDark;

  const ProfileLocationInfoCard({super.key, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return BlocBuilder<AddressesCubit, AddressesState>(
      builder: (context, addressesState) {
        final addresses = _getAddresses(addressesState);
        final defaultAddress = addresses
            .where((address) => address.isDefault)
            .firstOrNull;

        if (defaultAddress == null && addresses.isNotEmpty) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            try {
              context.read<AddressesCubit>().setDefaultAddress(
                addresses.last.id,
              );
            } catch (_) {}
          });
        }

        if (addressesState is AddressesInitial) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            try {
              context.read<AddressesCubit>().loadAddresses();
            } catch (_) {}
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
                    ProfileInfoTile(
                      isDark: isDark,
                      icon: Iconsax.location,
                      title: defaultAddress.label,
                      value: defaultAddress.fullAddress,
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
                        leading: _AddressTileIcon(icon: Iconsax.note),
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
                    _ManageAddressesTile(
                      isDark: isDark,
                      title: AppLocalizations.of(context)!.manageAddresses,
                    ),
                  ] else ...[
                    ListTile(
                      leading: const _AddressTileIcon(icon: Iconsax.location),
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
                    _ManageAddressesTile(
                      isDark: isDark,
                      title: AppLocalizations.of(context)!.addAddress,
                      highlight: true,
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

  List<AddressEntity> _getAddresses(AddressesState state) {
    if (state is AddressesLoaded) return state.addresses;
    if (state is AddressOperationLoading) return state.addresses;
    if (state is AddressOperationSuccess) return state.addresses;
    return const [];
  }
}

class ProfileInfoTile extends StatelessWidget {
  final bool isDark;
  final IconData icon;
  final String title;
  final String value;

  const ProfileInfoTile({
    super.key,
    required this.isDark,
    required this.icon,
    required this.title,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ListTile(
      leading: _AddressTileIcon(icon: icon),
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
}

class _ManageAddressesTile extends StatelessWidget {
  final bool isDark;
  final String title;
  final bool highlight;

  const _ManageAddressesTile({
    required this.isDark,
    required this.title,
    this.highlight = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ListTile(
      onTap: () => context.push('/addresses'),
      leading: const _AddressTileIcon(icon: Iconsax.location_add),
      title: Text(
        title,
        style: theme.textTheme.bodyLarge?.copyWith(
          fontWeight: FontWeight.w500,
          color: highlight
              ? AppColors.primary
              : isDark
              ? AppColors.textPrimaryDark
              : AppColors.textPrimaryLight,
        ),
      ),
      trailing: Icon(
        Iconsax.arrow_left_2,
        size: 20.sp,
        color: AppColors.primary,
      ),
      contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 6.h),
    );
  }
}

class _AddressTileIcon extends StatelessWidget {
  final IconData icon;

  const _AddressTileIcon({required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
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
    );
  }
}

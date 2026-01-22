/// Addresses List Screen - Manage delivery addresses
library;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iconsax/iconsax.dart';
import '../../../../core/config/theme/app_colors.dart';
import '../../../../core/di/injection.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../locations/presentation/cubit/locations_cubit.dart';
import '../../domain/entities/address_entity.dart';
import '../cubit/profile_cubit.dart';
import '../cubit/profile_state.dart';
import 'add_edit_address_screen.dart';

class AddressesListScreen extends StatelessWidget {
  const AddressesListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<AddressesCubit>()..loadAddresses(),
      child: const _AddressesListView(),
    );
  }
}

class _AddressesListView extends StatelessWidget {
  const _AddressesListView();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(title: Text(l10n.addresses)),
      body: BlocConsumer<AddressesCubit, AddressesState>(
        listener: (context, state) {
          if (state is AddressOperationSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppColors.success,
              ),
            );
          } else if (state is AddressesError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppColors.error,
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is AddressesLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          final addresses = _getAddresses(state);

          if (addresses.isEmpty) {
            return _buildEmptyState(theme);
          }

          return ListView.separated(
            padding: EdgeInsets.all(16.w),
            itemCount: addresses.length,
            separatorBuilder: (_, __) => SizedBox(height: 12.h),
            itemBuilder: (context, index) {
              return _buildAddressCard(
                context,
                theme,
                isDark,
                addresses[index],
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _navigateToAddAddress(context),
        icon: const Icon(Iconsax.add),
        label: Text(l10n.addAddress),
      ),
    );
  }

  List<AddressEntity> _getAddresses(AddressesState state) {
    if (state is AddressesLoaded) return state.addresses;
    if (state is AddressOperationLoading) return state.addresses;
    if (state is AddressOperationSuccess) return state.addresses;
    return [];
  }

  void _navigateToAddAddress(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => MultiBlocProvider(
          providers: [
            BlocProvider.value(value: context.read<AddressesCubit>()),
            BlocProvider.value(value: context.read<LocationsCubit>()),
          ],
          child: const AddEditAddressScreen(),
        ),
      ),
    );
  }

  void _navigateToEditAddress(BuildContext context, AddressEntity address) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => MultiBlocProvider(
          providers: [
            BlocProvider.value(value: context.read<AddressesCubit>()),
            BlocProvider.value(value: context.read<LocationsCubit>()),
          ],
          child: AddEditAddressScreen(address: address),
        ),
      ),
    );
  }

  Widget _buildEmptyState(ThemeData theme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Iconsax.location,
            size: 80.sp,
            color: AppColors.textTertiaryLight,
          ),
          SizedBox(height: 24.h),
          Text(
            'لا توجد عناوين',
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            'أضف عنوان توصيل جديد',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: AppColors.textTertiaryLight,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAddressCard(
    BuildContext context,
    ThemeData theme,
    bool isDark,
    AddressEntity address,
  ) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardDark : AppColors.cardLight,
        borderRadius: BorderRadius.circular(16.r),
        border: address.isDefault
            ? Border.all(color: AppColors.primary, width: 2)
            : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 44.w,
                height: 44.w,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Icon(Iconsax.location, color: AppColors.primary),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          address.label,
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        if (address.isDefault) ...[
                          SizedBox(width: 8.w),
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 8.w,
                              vertical: 2.h,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.primary,
                              borderRadius: BorderRadius.circular(4.r),
                            ),
                            child: Text(
                              'افتراضي',
                              style: TextStyle(
                                fontSize: 10.sp,
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      address.fullAddress,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: AppColors.textSecondaryLight,
                      ),
                    ),
                  ],
                ),
              ),
              PopupMenuButton(
                icon: const Icon(Iconsax.more),
                itemBuilder: (context) => [
                  const PopupMenuItem(value: 'edit', child: Text('تعديل')),
                  if (!address.isDefault)
                    const PopupMenuItem(
                      value: 'default',
                      child: Text('تعيين كافتراضي'),
                    ),
                  const PopupMenuItem(
                    value: 'delete',
                    child: Text(
                      'حذف',
                      style: TextStyle(color: AppColors.error),
                    ),
                  ),
                ],
                onSelected: (value) {
                  HapticFeedback.selectionClick();
                  _handleMenuAction(context, value, address);
                },
              ),
            ],
          ),
          if (address.recipientName != null || address.phone != null) ...[
            SizedBox(height: 8.h),
            if (address.recipientName != null)
              Row(
                children: [
                  Icon(Iconsax.user, size: 14.sp, color: AppColors.textTertiaryLight),
                  SizedBox(width: 4.w),
                  Text(
                    address.recipientName!,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: AppColors.textSecondaryLight,
                    ),
                  ),
                ],
              ),
            if (address.recipientName != null && address.phone != null)
              SizedBox(height: 4.h),
            if (address.phone != null)
              Row(
                children: [
                  Icon(Iconsax.call, size: 14.sp, color: AppColors.textTertiaryLight),
                  SizedBox(width: 4.w),
                  Text(
                    address.phone!,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: AppColors.textSecondaryLight,
                    ),
                  ),
                ],
              ),
          ],
        ],
      ),
    );
  }

  void _handleMenuAction(
    BuildContext context,
    String action,
    AddressEntity address,
  ) {
    final cubit = context.read<AddressesCubit>();

    switch (action) {
      case 'edit':
        _navigateToEditAddress(context, address);
        break;
      case 'default':
        cubit.setDefaultAddress(address.id);
        break;
      case 'delete':
        _showDeleteConfirmation(context, address);
        break;
    }
  }

  void _showDeleteConfirmation(BuildContext context, AddressEntity address) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('حذف العنوان'),
        content: Text('هل أنت متأكد من حذف "${address.label}"؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('إلغاء'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              context.read<AddressesCubit>().deleteAddress(address.id);
            },
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: const Text('حذف'),
          ),
        ],
      ),
    );
  }
}

/// Addresses List Screen - Manage delivery addresses
library;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iconsax/iconsax.dart';
import '../../../../core/config/theme/app_colors.dart';
import '../../../../l10n/app_localizations.dart';

class AddressesListScreen extends StatelessWidget {
  const AddressesListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final addresses = [
      _Address(
        id: 1,
        title: 'المنزل',
        address: 'الرياض - حي الملز - شارع الأمير سلطان',
        phone: '0555123456',
        isDefault: true,
      ),
      _Address(
        id: 2,
        title: 'العمل',
        address: 'الرياض - حي العليا - برج المملكة',
        phone: '0555123456',
        isDefault: false,
      ),
    ];

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(title: Text(AppLocalizations.of(context)!.addresses)),
      body: addresses.isEmpty
          ? _buildEmptyState(theme)
          : ListView.separated(
              padding: EdgeInsets.all(16.w),
              itemCount: addresses.length,
              separatorBuilder: (_, __) => SizedBox(height: 12.h),
              itemBuilder: (context, index) {
                return _buildAddressCard(theme, isDark, addresses[index]);
              },
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {},
        icon: const Icon(Iconsax.add),
        label: Text(AppLocalizations.of(context)!.addAddress),
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

  Widget _buildAddressCard(ThemeData theme, bool isDark, _Address address) {
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
                          address.title,
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
                      address.address,
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
                onSelected: (value) => HapticFeedback.selectionClick(),
              ),
            ],
          ),
          SizedBox(height: 8.h),
          Text(
            address.phone,
            style: theme.textTheme.bodySmall?.copyWith(
              color: AppColors.textTertiaryLight,
            ),
          ),
        ],
      ),
    );
  }
}

class _Address {
  final int id;
  final String title;
  final String address;
  final String phone;
  final bool isDefault;

  _Address({
    required this.id,
    required this.title,
    required this.address,
    required this.phone,
    required this.isDefault,
  });
}

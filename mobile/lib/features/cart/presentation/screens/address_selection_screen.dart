/// Address Selection Screen - Choose delivery address during checkout
library;

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax/iconsax.dart';
import '../../../../core/config/theme/app_colors.dart';

class AddressSelectionScreen extends StatefulWidget {
  final String? selectedAddressId;

  const AddressSelectionScreen({super.key, this.selectedAddressId});

  @override
  State<AddressSelectionScreen> createState() => _AddressSelectionScreenState();
}

class _AddressSelectionScreenState extends State<AddressSelectionScreen> {
  String? _selectedId;
  bool _isLoading = true;
  List<_AddressModel> _addresses = [];

  @override
  void initState() {
    super.initState();
    _selectedId = widget.selectedAddressId;
    _loadAddresses();
  }

  Future<void> _loadAddresses() async {
    await Future.delayed(const Duration(milliseconds: 500));
    setState(() {
      _addresses = [
        _AddressModel(
          id: '1',
          label: 'المنزل',
          name: 'أحمد محمد',
          phone: '0551234567',
          city: 'الرياض',
          address: 'حي النرجس، شارع الملك عبدالعزيز، مبنى رقم 15',
          isDefault: true,
        ),
        _AddressModel(
          id: '2',
          label: 'العمل',
          name: 'أحمد محمد',
          phone: '0559876543',
          city: 'الرياض',
          address: 'حي العليا، طريق الملك فهد، برج المملكة، الدور 25',
          isDefault: false,
        ),
        _AddressModel(
          id: '3',
          label: 'المحل',
          name: 'محل الصيانة',
          phone: '0551112233',
          city: 'جدة',
          address: 'سوق البلد، شارع قابل، محل رقم 45',
          isDefault: false,
        ),
      ];
      _selectedId ??= _addresses
          .firstWhere((a) => a.isDefault, orElse: () => _addresses.first)
          .id;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('اختيار العنوان'),
        actions: [
          TextButton.icon(
            onPressed: () async {
              final result = await context.push('/address/add');
              if (result == true) _loadAddresses();
            },
            icon: Icon(Iconsax.add, size: 18.sp),
            label: const Text('إضافة'),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _addresses.isEmpty
          ? _buildEmptyState(isDark)
          : Column(
              children: [
                Expanded(
                  child: ListView.separated(
                    padding: EdgeInsets.all(16.w),
                    itemCount: _addresses.length,
                    separatorBuilder: (_, _) => SizedBox(height: 12.h),
                    itemBuilder: (context, index) {
                      return _buildAddressCard(_addresses[index], isDark);
                    },
                  ),
                ),
                Container(
                  padding: EdgeInsets.all(16.w),
                  decoration: BoxDecoration(
                    color: isDark
                        ? AppColors.surfaceDark
                        : AppColors.surfaceLight,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 10,
                        offset: const Offset(0, -5),
                      ),
                    ],
                  ),
                  child: SafeArea(
                    child: ElevatedButton(
                      onPressed: _selectedId != null ? _confirmAddress : null,
                      child: Text(
                        'تأكيد العنوان',
                        style: TextStyle(fontSize: 16.sp),
                      ),
                    ),
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildAddressCard(_AddressModel address, bool isDark) {
    final isSelected = _selectedId == address.id;

    return GestureDetector(
      onTap: () => setState(() => _selectedId = address.id),
      child: Container(
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: isDark ? AppColors.cardDark : AppColors.cardLight,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(
            color: isSelected
                ? AppColors.primary
                : (isDark ? AppColors.dividerDark : AppColors.dividerLight),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 10.w,
                    vertical: 4.h,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppColors.primary
                        : AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(6.r),
                  ),
                  child: Text(
                    address.label,
                    style: TextStyle(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w600,
                      color: isSelected ? Colors.white : AppColors.primary,
                    ),
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
                      color: AppColors.success.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(4.r),
                    ),
                    child: Text(
                      'افتراضي',
                      style: TextStyle(
                        fontSize: 10.sp,
                        color: AppColors.success,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
                const Spacer(),
                Icon(
                  isSelected ? Iconsax.tick_circle5 : Iconsax.tick_circle,
                  size: 24.sp,
                  color: isSelected
                      ? AppColors.primary
                      : AppColors.textTertiaryLight,
                ),
              ],
            ),
            SizedBox(height: 12.h),
            Text(
              address.name,
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
                color: isDark
                    ? AppColors.textPrimaryDark
                    : AppColors.textPrimaryLight,
              ),
            ),
            SizedBox(height: 4.h),
            Text(
              address.phone,
              style: TextStyle(
                fontSize: 13.sp,
                color: isDark
                    ? AppColors.textSecondaryDark
                    : AppColors.textSecondaryLight,
              ),
            ),
            SizedBox(height: 4.h),
            Row(
              children: [
                Icon(
                  Iconsax.location,
                  size: 14.sp,
                  color: AppColors.textTertiaryLight,
                ),
                SizedBox(width: 4.w),
                Expanded(
                  child: Text(
                    '${address.city} - ${address.address}',
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: isDark
                          ? AppColors.textSecondaryDark
                          : AppColors.textSecondaryLight,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            SizedBox(height: 12.h),
            GestureDetector(
              onTap: () => context.push('/address/edit/${address.id}'),
              child: Text(
                'تعديل',
                style: TextStyle(
                  fontSize: 12.sp,
                  color: AppColors.primary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(bool isDark) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Iconsax.location,
            size: 80.sp,
            color: AppColors.textTertiaryLight,
          ),
          SizedBox(height: 16.h),
          Text(
            'لا توجد عناوين',
            style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.w600),
          ),
          SizedBox(height: 8.h),
          Text(
            'أضف عنوان توصيل جديد',
            style: TextStyle(
              fontSize: 14.sp,
              color: AppColors.textSecondaryLight,
            ),
          ),
          SizedBox(height: 24.h),
          ElevatedButton.icon(
            onPressed: () => context.push('/address/add'),
            icon: Icon(Iconsax.add, size: 18.sp),
            label: const Text('إضافة عنوان'),
          ),
        ],
      ),
    );
  }

  void _confirmAddress() {
    final address = _addresses.firstWhere((a) => a.id == _selectedId);
    context.pop(address.toJson());
  }
}

class _AddressModel {
  final String id, label, name, phone, city, address;
  final bool isDefault;

  _AddressModel({
    required this.id,
    required this.label,
    required this.name,
    required this.phone,
    required this.city,
    required this.address,
    required this.isDefault,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'label': label,
    'name': name,
    'phone': phone,
    'city': city,
    'address': address,
  };
}

/// Add/Edit Address Screen - Create or modify delivery address
library;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iconsax/iconsax.dart';
import '../../../../core/config/theme/app_colors.dart';
import '../../domain/entities/address_entity.dart';
import '../cubit/profile_cubit.dart';
import '../cubit/profile_state.dart';

class AddEditAddressScreen extends StatefulWidget {
  final AddressEntity? address;

  const AddEditAddressScreen({super.key, this.address});

  @override
  State<AddEditAddressScreen> createState() => _AddEditAddressScreenState();
}

class _AddEditAddressScreenState extends State<AddEditAddressScreen> {
  final _formKey = GlobalKey<FormState>();
  final _labelController = TextEditingController();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  String? _selectedCityId;
  bool _isDefault = false;

  bool get _isEditing => widget.address != null;

  // TODO: Load from API
  final List<Map<String, String>> _cities = [
    {'id': '1', 'name': 'الرياض'},
    {'id': '2', 'name': 'جدة'},
    {'id': '3', 'name': 'مكة المكرمة'},
    {'id': '4', 'name': 'المدينة المنورة'},
    {'id': '5', 'name': 'الدمام'},
  ];

  @override
  void initState() {
    super.initState();
    if (_isEditing) {
      final address = widget.address!;
      _labelController.text = address.label;
      _nameController.text = address.recipientName ?? '';
      _phoneController.text = address.phone ?? '';
      _addressController.text = address.addressLine;
      _selectedCityId = address.cityId;
      _isDefault = address.isDefault;
    }
  }

  @override
  void dispose() {
    _labelController.dispose();
    _nameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return BlocListener<AddressesCubit, AddressesState>(
      listener: (context, state) {
        if (state is AddressOperationSuccess) {
          Navigator.pop(context);
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(_isEditing ? 'تعديل العنوان' : 'إضافة عنوان'),
          actions: [
            if (_isEditing)
              IconButton(
                onPressed: _showDeleteDialog,
                icon: Icon(Iconsax.trash, size: 22.sp, color: AppColors.error),
              ),
          ],
        ),
        body: Form(
          key: _formKey,
          child: ListView(
            padding: EdgeInsets.all(16.w),
            children: [
              // Label
              _buildTextField(
                controller: _labelController,
                label: 'تسمية العنوان',
                hint: 'مثال: المنزل، العمل',
                icon: Iconsax.tag,
                validator: (value) {
                  if (value?.isEmpty ?? true) return 'يرجى إدخال تسمية';
                  return null;
                },
              ),
              SizedBox(height: 16.h),

              // Recipient Name
              _buildTextField(
                controller: _nameController,
                label: 'اسم المستلم',
                hint: 'الاسم الكامل',
                icon: Iconsax.user,
              ),
              SizedBox(height: 16.h),

              // Phone
              _buildTextField(
                controller: _phoneController,
                label: 'رقم الهاتف',
                hint: '05xxxxxxxx',
                icon: Iconsax.call,
                keyboardType: TextInputType.phone,
              ),
              SizedBox(height: 16.h),

              // City Dropdown
              _buildDropdown(isDark),
              SizedBox(height: 16.h),

              // Address Details
              _buildTextField(
                controller: _addressController,
                label: 'تفاصيل العنوان',
                hint: 'الحي، الشارع، رقم المبنى',
                icon: Iconsax.location,
                maxLines: 3,
                validator: (value) {
                  if (value?.isEmpty ?? true) return 'يرجى إدخال تفاصيل العنوان';
                  return null;
                },
              ),
              SizedBox(height: 16.h),

              // Pick from Map Button
              OutlinedButton.icon(
                onPressed: _pickFromMap,
                icon: Icon(Iconsax.map, size: 20.sp),
                label: const Text('تحديد الموقع على الخريطة'),
                style: OutlinedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 14.h),
                ),
              ),
              SizedBox(height: 24.h),

              // Set as Default
              Container(
                padding: EdgeInsets.all(16.w),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.cardDark : AppColors.cardLight,
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Row(
                  children: [
                    Icon(
                      Iconsax.star,
                      size: 24.sp,
                      color: _isDefault
                          ? AppColors.warning
                          : AppColors.textTertiaryLight,
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'العنوان الافتراضي',
                            style: TextStyle(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w600,
                              color: isDark
                                  ? AppColors.textPrimaryDark
                                  : AppColors.textPrimaryLight,
                            ),
                          ),
                          Text(
                            'استخدام هذا العنوان للطلبات الجديدة',
                            style: TextStyle(
                              fontSize: 12.sp,
                              color: isDark
                                  ? AppColors.textSecondaryDark
                                  : AppColors.textSecondaryLight,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Switch(
                      value: _isDefault,
                      onChanged: (value) => setState(() => _isDefault = value),
                      activeThumbColor: AppColors.primary,
                    ),
                  ],
                ),
              ),
              SizedBox(height: 32.h),

              // Save Button
              BlocBuilder<AddressesCubit, AddressesState>(
                builder: (context, state) {
                  final isLoading = state is AddressOperationLoading;

                  return ElevatedButton(
                    onPressed: isLoading ? null : _saveAddress,
                    child: isLoading
                        ? SizedBox(
                            width: 20.w,
                            height: 20.w,
                            child: const CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : Text(
                            _isEditing ? 'حفظ التغييرات' : 'إضافة العنوان',
                            style: TextStyle(fontSize: 16.sp),
                          ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    TextInputType? keyboardType,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.w500,
            color: isDark
                ? AppColors.textPrimaryDark
                : AppColors.textPrimaryLight,
          ),
        ),
        SizedBox(height: 8.h),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          maxLines: maxLines,
          validator: validator,
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: Icon(icon, size: 20.sp),
          ),
        ),
      ],
    );
  }

  Widget _buildDropdown(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'المدينة',
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.w500,
            color: isDark
                ? AppColors.textPrimaryDark
                : AppColors.textPrimaryLight,
          ),
        ),
        SizedBox(height: 8.h),
        DropdownButtonFormField<String>(
          value: _selectedCityId,
          decoration: InputDecoration(
            prefixIcon: Icon(Iconsax.buildings, size: 20.sp),
          ),
          hint: const Text('اختر المدينة'),
          items: _cities.map((city) {
            return DropdownMenuItem(
              value: city['id'],
              child: Text(city['name']!),
            );
          }).toList(),
          onChanged: (value) => setState(() => _selectedCityId = value),
          validator: (value) {
            if (value == null) return 'يرجى اختيار المدينة';
            return null;
          },
        ),
      ],
    );
  }

  void _pickFromMap() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('ميزة الخريطة قيد التطوير'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> _saveAddress() async {
    if (!_formKey.currentState!.validate()) return;

    final cubit = context.read<AddressesCubit>();

    if (_isEditing) {
      await cubit.updateAddress(
        id: widget.address!.id,
        label: _labelController.text,
        recipientName: _nameController.text.isNotEmpty
            ? _nameController.text
            : null,
        phone: _phoneController.text.isNotEmpty ? _phoneController.text : null,
        cityId: _selectedCityId,
        addressLine: _addressController.text,
        isDefault: _isDefault,
      );
    } else {
      await cubit.createAddress(
        label: _labelController.text,
        cityId: _selectedCityId!,
        addressLine: _addressController.text,
        recipientName: _nameController.text.isNotEmpty
            ? _nameController.text
            : null,
        phone: _phoneController.text.isNotEmpty ? _phoneController.text : null,
        isDefault: _isDefault,
      );
    }
  }

  void _showDeleteDialog() {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
        title: const Text('حذف العنوان'),
        content: const Text('هل أنت متأكد من حذف هذا العنوان؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('إلغاء'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              context.read<AddressesCubit>().deleteAddress(widget.address!.id);
            },
            child: Text('حذف', style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );
  }
}

/// Add/Edit Address Screen - Create or modify delivery address
library;

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax/iconsax.dart';
import '../../../../core/config/theme/app_colors.dart';

class AddEditAddressScreen extends StatefulWidget {
  final String? addressId;
  final Map<String, dynamic>? address;

  const AddEditAddressScreen({super.key, this.addressId, this.address});

  @override
  State<AddEditAddressScreen> createState() => _AddEditAddressScreenState();
}

class _AddEditAddressScreenState extends State<AddEditAddressScreen> {
  final _formKey = GlobalKey<FormState>();
  final _labelController = TextEditingController();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  String? _selectedCity;
  bool _isDefault = false;
  bool _isSaving = false;

  bool get _isEditing => widget.addressId != null;

  // Mock cities
  final List<String> _cities = [
    'الرياض',
    'جدة',
    'مكة المكرمة',
    'المدينة المنورة',
    'الدمام',
    'الخبر',
    'الظهران',
    'الطائف',
    'تبوك',
    'بريدة',
  ];

  @override
  void initState() {
    super.initState();
    if (_isEditing && widget.address != null) {
      _labelController.text = widget.address!['label'] ?? '';
      _nameController.text = widget.address!['name'] ?? '';
      _phoneController.text = widget.address!['phone'] ?? '';
      _addressController.text = widget.address!['address'] ?? '';
      _selectedCity = widget.address!['city'];
      _isDefault = widget.address!['isDefault'] ?? false;
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

    return Scaffold(
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
              validator: (value) {
                if (value?.isEmpty ?? true) return 'يرجى إدخال اسم المستلم';
                return null;
              },
            ),
            SizedBox(height: 16.h),

            // Phone
            _buildTextField(
              controller: _phoneController,
              label: 'رقم الهاتف',
              hint: '05xxxxxxxx',
              icon: Iconsax.call,
              keyboardType: TextInputType.phone,
              validator: (value) {
                if (value?.isEmpty ?? true) return 'يرجى إدخال رقم الهاتف';
                if (value!.length < 10) return 'رقم الهاتف غير صحيح';
                return null;
              },
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
            ElevatedButton(
              onPressed: _isSaving ? null : _saveAddress,
              child: _isSaving
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
            ),
          ],
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
          value: _selectedCity,
          decoration: InputDecoration(
            prefixIcon: Icon(Iconsax.buildings, size: 20.sp),
          ),
          hint: const Text('اختر المدينة'),
          items: _cities.map((city) {
            return DropdownMenuItem(value: city, child: Text(city));
          }).toList(),
          onChanged: (value) => setState(() => _selectedCity = value),
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

    setState(() => _isSaving = true);

    // Simulate API call
    await Future.delayed(const Duration(seconds: 1));

    setState(() => _isSaving = false);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_isEditing ? 'تم تحديث العنوان' : 'تم إضافة العنوان'),
          behavior: SnackBarBehavior.floating,
          backgroundColor: AppColors.success,
        ),
      );
      context.pop(true);
    }
  }

  void _showDeleteDialog() {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: isDark
            ? AppColors.surfaceDark
            : AppColors.surfaceLight,
        title: const Text('حذف العنوان'),
        content: const Text('هل أنت متأكد من حذف هذا العنوان؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              context.pop(true);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('تم حذف العنوان'),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            child: Text('حذف', style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );
  }
}

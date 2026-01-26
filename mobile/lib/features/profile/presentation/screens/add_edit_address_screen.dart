/// Add/Edit Address Screen - Create or modify delivery address
library;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax/iconsax.dart';
import '../../../../core/config/theme/app_colors.dart';
import '../../../../core/utils/extensions.dart';
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
  final _addressController = TextEditingController();
  final _cityNameController = TextEditingController();
  final _marketNameController = TextEditingController();
  final _notesController = TextEditingController();
  final _latitudeController = TextEditingController();
  final _longitudeController = TextEditingController();
  bool _isDefault = false;

  bool get _isEditing => widget.address != null;

  @override
  void initState() {
    super.initState();

    if (_isEditing) {
      final address = widget.address!;
      _labelController.text = address.label;
      _addressController.text = address.addressLine;
      _cityNameController.text = address.cityName ?? '';
      _marketNameController.text = address.marketName ?? '';
      _notesController.text = address.notes ?? '';
      _latitudeController.text = address.latitude.toString();
      _longitudeController.text = address.longitude.toString();
      _isDefault = address.isDefault;
    }
  }


  @override
  void dispose() {
    _labelController.dispose();
    _addressController.dispose();
    _cityNameController.dispose();
    _marketNameController.dispose();
    _notesController.dispose();
    _latitudeController.dispose();
    _longitudeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return BlocListener<AddressesCubit, AddressesState>(
      listener: (context, state) {
        if (state is AddressOperationSuccess) {
          Navigator.pop(context);
        } else if (state is AddressesError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: AppColors.error,
            ),
          );
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
                label: 'تسمية العنوان *',
                hint: 'مثال: المنزل، العمل',
                icon: Iconsax.tag,
                validator: (value) {
                  if (value?.isEmpty ?? true) return 'يرجى إدخال تسمية';
                  return null;
                },
              ),
              SizedBox(height: 16.h),

              // City Name (text field)
              _buildTextField(
                controller: _cityNameController,
                label: 'المدينة',
                hint: 'اسم المدينة (اختياري)',
                icon: Iconsax.buildings,
              ),
              SizedBox(height: 16.h),

              // Market/Area Name (text field)
              _buildTextField(
                controller: _marketNameController,
                label: 'السوق / الحي',
                hint: 'اسم السوق أو الحي (اختياري)',
                icon: Iconsax.shop,
              ),
              SizedBox(height: 16.h),

              // Address Details
              _buildTextField(
                controller: _addressController,
                label: 'تفاصيل العنوان *',
                hint: 'الحي، الشارع، رقم المبنى',
                icon: Iconsax.location,
                maxLines: 3,
                validator: (value) {
                  if (value?.isEmpty ?? true)
                    return 'يرجى إدخال تفاصيل العنوان';
                  return null;
                },
              ),
              SizedBox(height: 16.h),

              // Latitude
              _buildTextField(
                controller: _latitudeController,
                label: 'خط العرض *',
                hint: 'مثال: 24.7136',
                icon: Iconsax.location,
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                validator: (value) {
                  if (value?.isEmpty ?? true) {
                    return 'يرجى إدخال خط العرض';
                  }
                  final lat = double.tryParse(value!);
                  if (lat == null) {
                    return 'يرجى إدخال رقم صحيح';
                  }
                  if (lat < -90 || lat > 90) {
                    return 'خط العرض يجب أن يكون بين -90 و 90';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16.h),

              // Longitude
              _buildTextField(
                controller: _longitudeController,
                label: 'خط الطول *',
                hint: 'مثال: 46.6753',
                icon: Iconsax.location,
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                validator: (value) {
                  if (value?.isEmpty ?? true) {
                    return 'يرجى إدخال خط الطول';
                  }
                  final lng = double.tryParse(value!);
                  if (lng == null) {
                    return 'يرجى إدخال رقم صحيح';
                  }
                  if (lng < -180 || lng > 180) {
                    return 'خط الطول يجب أن يكون بين -180 و 180';
                  }
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
              SizedBox(height: 16.h),

              // Notes
              _buildTextField(
                controller: _notesController,
                label: 'ملاحظات',
                hint: 'مثال: التوصيل نهاراً، الطابق الثاني',
                icon: Iconsax.note,
                maxLines: 3,
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


  Future<void> _pickFromMap() async {
    final currentLat = double.tryParse(_latitudeController.text);
    final currentLng = double.tryParse(_longitudeController.text);
    
    final result = await context.push<Map<String, dynamic>?>(
      '/map/location-picker',
      extra: {
        'initialLatitude': currentLat,
        'initialLongitude': currentLng,
      },
    );

    if (result != null) {
      setState(() {
        final lat = result['latitude'] as double?;
        final lng = result['longitude'] as double?;
        
        if (lat != null) {
          _latitudeController.text = lat.toString();
        }
        if (lng != null) {
          _longitudeController.text = lng.toString();
        }

        // Update address field if address is available
        if (result['address'] != null &&
            result['address'].toString().isNotEmpty) {
          _addressController.text = result['address'].toString();
        }
      });
    }
  }

  Future<void> _saveAddress() async {
    if (!_formKey.currentState!.validate()) return;

    final cubit = context.read<AddressesCubit>();
    
    final latitude = double.parse(_latitudeController.text);
    final longitude = double.parse(_longitudeController.text);
    final cityName = _cityNameController.text.trim().isEmpty 
        ? null 
        : _cityNameController.text.trim();
    final marketName = _marketNameController.text.trim().isEmpty 
        ? null 
        : _marketNameController.text.trim();
    final notes = _notesController.text.trim().isEmpty 
        ? null 
        : _notesController.text.trim();

    if (_isEditing) {
      await cubit.updateAddress(
        id: widget.address!.id,
        label: _labelController.text,
        addressLine: _addressController.text,
        cityName: cityName,
        marketName: marketName,
        latitude: latitude,
        longitude: longitude,
        notes: notes,
        isDefault: _isDefault,
      );
    } else {
      await cubit.createAddress(
        label: _labelController.text,
        addressLine: _addressController.text,
        cityName: cityName,
        marketName: marketName,
        latitude: latitude,
        longitude: longitude,
        notes: notes,
        isDefault: _isDefault,
      );
    }
  }

  void _showDeleteDialog() {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: isDark
            ? AppColors.surfaceDark
            : AppColors.surfaceLight,
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

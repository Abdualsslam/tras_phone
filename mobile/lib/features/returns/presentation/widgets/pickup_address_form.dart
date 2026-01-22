/// Pickup Address Form - Widget for entering pickup address
library;

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../data/models/return_model.dart';
import '../../../../core/config/theme/app_colors.dart';

class PickupAddressForm extends StatefulWidget {
  final PickupAddress? initialAddress;
  final Function(PickupAddress?) onAddressChanged;

  const PickupAddressForm({
    super.key,
    this.initialAddress,
    required this.onAddressChanged,
  });

  @override
  State<PickupAddressForm> createState() => _PickupAddressFormState();
}

class _PickupAddressFormState extends State<PickupAddressForm> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _fullNameController;
  late final TextEditingController _phoneController;
  late final TextEditingController _addressController;
  late final TextEditingController _cityController;
  late final TextEditingController _notesController;

  @override
  void initState() {
    super.initState();
    _fullNameController = TextEditingController(
      text: widget.initialAddress?.fullName ?? '',
    );
    _phoneController = TextEditingController(
      text: widget.initialAddress?.phone ?? '',
    );
    _addressController = TextEditingController(
      text: widget.initialAddress?.address ?? '',
    );
    _cityController = TextEditingController(
      text: widget.initialAddress?.city ?? '',
    );
    _notesController = TextEditingController(
      text: widget.initialAddress?.notes ?? '',
    );

    // Listen to changes
    _fullNameController.addListener(_onFormChanged);
    _phoneController.addListener(_onFormChanged);
    _addressController.addListener(_onFormChanged);
    _cityController.addListener(_onFormChanged);
    _notesController.addListener(_onFormChanged);
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _cityController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _onFormChanged() {
    if (_formKey.currentState?.validate() ?? false) {
      final address = PickupAddress(
        fullName: _fullNameController.text.trim(),
        phone: _phoneController.text.trim(),
        address: _addressController.text.trim(),
        city: _cityController.text.trim(),
        notes: _notesController.text.trim().isNotEmpty
            ? _notesController.text.trim()
            : null,
      );
      widget.onAddressChanged(address);
    } else {
      widget.onAddressChanged(null);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'عنوان الاستلام (اختياري)',
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 12.h),

          // Full Name
          TextFormField(
            controller: _fullNameController,
            decoration: InputDecoration(
              labelText: 'الاسم الكامل',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.r),
              ),
              filled: true,
              fillColor: isDark ? AppColors.cardDark : AppColors.cardLight,
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'يرجى إدخال الاسم الكامل';
              }
              return null;
            },
          ),
          SizedBox(height: 12.h),

          // Phone
          TextFormField(
            controller: _phoneController,
            decoration: InputDecoration(
              labelText: 'رقم الهاتف',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.r),
              ),
              filled: true,
              fillColor: isDark ? AppColors.cardDark : AppColors.cardLight,
            ),
            keyboardType: TextInputType.phone,
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'يرجى إدخال رقم الهاتف';
              }
              return null;
            },
          ),
          SizedBox(height: 12.h),

          // Address
          TextFormField(
            controller: _addressController,
            decoration: InputDecoration(
              labelText: 'العنوان',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.r),
              ),
              filled: true,
              fillColor: isDark ? AppColors.cardDark : AppColors.cardLight,
            ),
            maxLines: 2,
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'يرجى إدخال العنوان';
              }
              return null;
            },
          ),
          SizedBox(height: 12.h),

          // City
          TextFormField(
            controller: _cityController,
            decoration: InputDecoration(
              labelText: 'المدينة',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.r),
              ),
              filled: true,
              fillColor: isDark ? AppColors.cardDark : AppColors.cardLight,
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'يرجى إدخال المدينة';
              }
              return null;
            },
          ),
          SizedBox(height: 12.h),

          // Notes
          TextFormField(
            controller: _notesController,
            decoration: InputDecoration(
              labelText: 'ملاحظات (اختياري)',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.r),
              ),
              filled: true,
              fillColor: isDark ? AppColors.cardDark : AppColors.cardLight,
            ),
            maxLines: 2,
          ),
        ],
      ),
    );
  }
}

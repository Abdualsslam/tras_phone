/// Edit Profile Screen - Update user profile information
library;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax/iconsax.dart';
import '../../../../core/config/theme/app_colors.dart';
import '../../../../core/di/injection.dart';
import '../../domain/enums/customer_enums.dart';
import '../../domain/repositories/profile_repository.dart';
import '../../data/models/update_customer_profile_dto.dart';
import '../../presentation/cubit/profile_cubit.dart';
import '../../presentation/cubit/profile_state.dart';
import '../../../../l10n/app_localizations.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _responsiblePersonNameController;
  late TextEditingController _shopNameController;
  late TextEditingController _shopNameArController;
  late TextEditingController _addressController;
  late TextEditingController _instagramHandleController;
  late TextEditingController _twitterHandleController;

  String? _selectedBusinessType;
  String? _selectedCityId;
  String? _selectedMarketId;
  String? _selectedPaymentMethod;
  String? _selectedShippingTime;
  String? _selectedContactMethod;

  List<Map<String, dynamic>> _cities = [];
  List<Map<String, dynamic>> _markets = [];
  bool _loadingCities = false;
  bool _loadingMarkets = false;

  @override
  void initState() {
    super.initState();
    _responsiblePersonNameController = TextEditingController();
    _shopNameController = TextEditingController();
    _shopNameArController = TextEditingController();
    _addressController = TextEditingController();
    _instagramHandleController = TextEditingController();
    _twitterHandleController = TextEditingController();

    // Load profile data
    context.read<ProfileCubit>().loadProfile();
  }

  @override
  void dispose() {
    _responsiblePersonNameController.dispose();
    _shopNameController.dispose();
    _shopNameArController.dispose();
    _addressController.dispose();
    _instagramHandleController.dispose();
    _twitterHandleController.dispose();
    super.dispose();
  }

  void _loadInitialData(customer) {
    if (customer != null) {
      _responsiblePersonNameController.text = customer.responsiblePersonName;
      _shopNameController.text = customer.shopName;
      _shopNameArController.text = customer.shopNameAr ?? '';
      _addressController.text = customer.address ?? '';
      _instagramHandleController.text = customer.instagramHandle ?? '';
      _twitterHandleController.text = customer.twitterHandle ?? '';

      _selectedBusinessType = customer.businessType.name;
      _selectedCityId = customer.cityId;
      _selectedPaymentMethod = customer.preferredPaymentMethod?.value;
      _selectedShippingTime = customer.preferredShippingTime;
      _selectedContactMethod = customer.preferredContactMethod.name;

      // Load cities if we have a country (assuming Saudi Arabia for now)
      if (_selectedCityId != null) {
        _loadCities();
      }
    }
  }

  Future<void> _loadCities() async {
    setState(() => _loadingCities = true);
    try {
      final repository = getIt<ProfileRepository>();
      // Assuming Saudi Arabia country ID - you may need to adjust this
      final cities = await repository.getCities('SA');
      setState(() {
        _cities = cities;
        _loadingCities = false;
      });
    } catch (e) {
      setState(() => _loadingCities = false);
    }
  }

  Future<void> _loadMarkets(String? cityId) async {
    if (cityId == null) return;
    setState(() => _loadingMarkets = true);
    try {
      // Markets might need a different endpoint - adjust as needed
      // For now, we'll leave it empty
      setState(() => _loadingMarkets = false);
    } catch (e) {
      setState(() => _loadingMarkets = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.editProfile),
        leading: IconButton(
          icon: const Icon(Iconsax.arrow_right_3),
          onPressed: () => context.pop(),
        ),
      ),
      body: BlocConsumer<ProfileCubit, ProfileState>(
        listener: (context, state) {
          if (state is ProfileUpdated) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: const Text('تم تحديث البروفايل بنجاح'),
                backgroundColor: AppColors.success,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
              ),
            );
            context.pop();
          } else if (state is ProfileError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppColors.error,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
              ),
            );
          } else if (state is ProfileLoaded) {
            _loadInitialData(state.customer);
          }
        },
        builder: (context, state) {
          if (state is ProfileLoading && _responsiblePersonNameController.text.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          final customer = state is ProfileLoaded ? state.customer : null;
          if (customer != null && _responsiblePersonNameController.text.isEmpty) {
            _loadInitialData(customer);
          }

          return SingleChildScrollView(
            padding: EdgeInsets.all(16.w),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Responsible Person Name
                  _buildTextField(
                    theme,
                    isDark,
                    controller: _responsiblePersonNameController,
                    label: 'اسم المسؤول *',
                    icon: Iconsax.user,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'الرجاء إدخال اسم المسؤول';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 16.h),

                  // Shop Name (English)
                  _buildTextField(
                    theme,
                    isDark,
                    controller: _shopNameController,
                    label: 'اسم المتجر (إنجليزي) *',
                    icon: Iconsax.shop,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'الرجاء إدخال اسم المتجر';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 16.h),

                  // Shop Name (Arabic)
                  _buildTextField(
                    theme,
                    isDark,
                    controller: _shopNameArController,
                    label: 'اسم المتجر (عربي)',
                    icon: Iconsax.shop,
                  ),
                  SizedBox(height: 16.h),

                  // Business Type
                  _buildDropdown<String>(
                    theme,
                    isDark,
                    label: 'نوع العمل *',
                    icon: Iconsax.category,
                    value: _selectedBusinessType,
                    items: BusinessType.values.map((type) {
                      return DropdownMenuItem<String>(
                        value: type.name,
                        child: Text(type.displayName),
                      );
                    }).toList(),
                    onChanged: (value) => setState(() => _selectedBusinessType = value),
                    validator: (value) {
                      if (value == null) {
                        return 'الرجاء اختيار نوع العمل';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 16.h),

                  // City
                  _buildDropdown<String>(
                    theme,
                    isDark,
                    label: 'المدينة',
                    icon: Iconsax.location,
                    value: _selectedCityId,
                    items: _cities.map((city) {
                      final id = city['_id']?.toString() ?? city['id']?.toString() ?? '';
                      final name = city['nameAr'] ?? city['name'] ?? '';
                      return DropdownMenuItem<String>(
                        value: id,
                        child: Text(name),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedCityId = value;
                        _selectedMarketId = null; // Reset market when city changes
                      });
                      _loadMarkets(value);
                    },
                    isLoading: _loadingCities,
                    onLoad: _loadCities,
                  ),
                  SizedBox(height: 16.h),

                  // Market
                  if (_selectedCityId != null)
                    _buildDropdown<String>(
                      theme,
                      isDark,
                      label: 'السوق',
                      icon: Iconsax.shop,
                      value: _selectedMarketId,
                      items: _markets.map((market) {
                        final id = market['_id']?.toString() ?? market['id']?.toString() ?? '';
                        final name = market['nameAr'] ?? market['name'] ?? '';
                        return DropdownMenuItem<String>(
                          value: id,
                          child: Text(name),
                        );
                      }).toList(),
                      onChanged: (value) => setState(() => _selectedMarketId = value),
                      isLoading: _loadingMarkets,
                    ),
                  if (_selectedCityId != null) SizedBox(height: 16.h),

                  // Address
                  _buildTextField(
                    theme,
                    isDark,
                    controller: _addressController,
                    label: 'العنوان',
                    icon: Iconsax.location,
                    maxLines: 3,
                  ),
                  SizedBox(height: 16.h),

                  // Preferred Payment Method
                  _buildDropdown<String>(
                    theme,
                    isDark,
                    label: 'طريقة الدفع المفضلة',
                    icon: Iconsax.wallet,
                    value: _selectedPaymentMethod,
                    items: PaymentMethod.values.map((method) {
                      return DropdownMenuItem<String>(
                        value: method.value,
                        child: Text(method.displayName),
                      );
                    }).toList(),
                    onChanged: (value) => setState(() => _selectedPaymentMethod = value),
                  ),
                  SizedBox(height: 16.h),

                  // Preferred Shipping Time
                  _buildDropdown<String>(
                    theme,
                    isDark,
                    label: 'وقت التوصيل المفضل',
                    icon: Iconsax.clock,
                    value: _selectedShippingTime,
                    items: const [
                      DropdownMenuItem(value: 'morning', child: Text('صباحاً')),
                      DropdownMenuItem(value: 'afternoon', child: Text('بعد الظهر')),
                      DropdownMenuItem(value: 'evening', child: Text('مساءً')),
                    ],
                    onChanged: (value) => setState(() => _selectedShippingTime = value),
                  ),
                  SizedBox(height: 16.h),

                  // Preferred Contact Method
                  _buildDropdown<String>(
                    theme,
                    isDark,
                    label: 'طريقة التواصل المفضلة',
                    icon: Iconsax.call,
                    value: _selectedContactMethod,
                    items: ContactMethod.values.map((method) {
                      return DropdownMenuItem<String>(
                        value: method.name,
                        child: Text(method.displayName),
                      );
                    }).toList(),
                    onChanged: (value) => setState(() => _selectedContactMethod = value),
                  ),
                  SizedBox(height: 16.h),

                  // Instagram Handle
                  _buildTextField(
                    theme,
                    isDark,
                    controller: _instagramHandleController,
                    label: 'حساب إنستغرام',
                    icon: Iconsax.instagram,
                    prefixText: '@',
                  ),
                  SizedBox(height: 16.h),

                  // Twitter Handle
                  _buildTextField(
                    theme,
                    isDark,
                    controller: _twitterHandleController,
                    label: 'حساب تويتر',
                    icon: Iconsax.message,
                    prefixText: '@',
                  ),
                  SizedBox(height: 32.h),

                  // Save Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: state is ProfileLoading ? null : _saveProfile,
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: 16.h),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14.r),
                        ),
                      ),
                      child: state is ProfileLoading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Text('حفظ التعديلات'),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildTextField(
    ThemeData theme,
    bool isDark, {
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
    String? prefixText,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: AppColors.textSecondaryLight),
        prefixText: prefixText,
        filled: true,
        fillColor: isDark ? AppColors.cardDark : AppColors.cardLight,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14.r),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14.r),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14.r),
          borderSide: const BorderSide(color: AppColors.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14.r),
          borderSide: const BorderSide(color: AppColors.error, width: 2),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14.r),
          borderSide: const BorderSide(color: AppColors.error, width: 2),
        ),
      ),
    );
  }

  Widget _buildDropdown<T>(
    ThemeData theme,
    bool isDark, {
    required String label,
    required IconData icon,
    required T? value,
    required List<DropdownMenuItem<T>> items,
    required void Function(T?) onChanged,
    String? Function(T?)? validator,
    bool isLoading = false,
    VoidCallback? onLoad,
  }) {
    return DropdownButtonFormField<T>(
      value: value,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: AppColors.textSecondaryLight),
        filled: true,
        fillColor: isDark ? AppColors.cardDark : AppColors.cardLight,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14.r),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14.r),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14.r),
          borderSide: const BorderSide(color: AppColors.primary, width: 2),
        ),
        suffixIcon: isLoading
            ? const Padding(
                padding: EdgeInsets.all(12.0),
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              )
            : onLoad != null && items.isEmpty
                ? IconButton(
                    icon: const Icon(Icons.refresh),
                    onPressed: onLoad,
                  )
                : null,
      ),
      items: items,
      onChanged: onChanged,
      validator: validator,
    );
  }

  void _saveProfile() {
    if (_formKey.currentState!.validate()) {
      final dto = UpdateCustomerProfileDto(
        responsiblePersonName: _responsiblePersonNameController.text.trim(),
        shopName: _shopNameController.text.trim(),
        shopNameAr: _shopNameArController.text.trim().isEmpty
            ? null
            : _shopNameArController.text.trim(),
        businessType: _selectedBusinessType,
        cityId: _selectedCityId,
        marketId: _selectedMarketId,
        address: _addressController.text.trim().isEmpty
            ? null
            : _addressController.text.trim(),
        preferredPaymentMethod: _selectedPaymentMethod,
        preferredShippingTime: _selectedShippingTime,
        preferredContactMethod: _selectedContactMethod,
        instagramHandle: _instagramHandleController.text.trim().isEmpty
            ? null
            : _instagramHandleController.text.trim(),
        twitterHandle: _twitterHandleController.text.trim().isEmpty
            ? null
            : _twitterHandleController.text.trim(),
      );

      context.read<ProfileCubit>().updateProfile(dto);
    }
  }
}

/// Register Screen - New user registration
library;

import 'dart:developer' as developer;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax/iconsax.dart';
import '../../../../core/config/theme/app_colors.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/utils/validators.dart';
import '../../../../core/widgets/widgets.dart';
import '../cubit/auth_cubit.dart';
import '../cubit/auth_state.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../address/presentation/cubit/locations_cubit.dart';
import '../../../address/presentation/cubit/locations_state.dart';
import '../../../address/data/models/city_model.dart';
import '../../../address/data/models/country_model.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _nameController = TextEditingController();
  final _shopNameController = TextEditingController();
  bool _isLoading = false;
  CityModel? _selectedCity;

  @override
  void initState() {
    super.initState();
    // Load countries first, which will load cities for default country (Saudi Arabia)
    context.read<LocationsCubit>().loadCountries();
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _nameController.dispose();
    _shopNameController.dispose();
    super.dispose();
  }

  void _handleRegister() {
    if (_formKey.currentState?.validate() ?? false) {
      if (_selectedCity == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('يرجى اختيار المدينة'),
            backgroundColor: AppColors.error,
          ),
        );
        return;
      }

      // Log cityId for debugging
      final cityIdValue = _selectedCity!.id;
      developer.log(
        'Selected city: ${_selectedCity!.nameAr} (id: $cityIdValue, type: ${cityIdValue.runtimeType})',
        name: 'RegisterScreen',
      );

      context.read<AuthCubit>().register(
        phone: _phoneController.text.trim(),
        password: _passwordController.text,
        responsiblePersonName: _nameController.text.trim(),
        shopName: _shopNameController.text.trim(),
        cityId: cityIdValue, // Use MongoDB ObjectId from API
        businessType: 'shop', // Default business type
        // email: optional email field would go here
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return BlocConsumer<AuthCubit, AuthState>(
      listener: (context, state) {
        if (state is AuthLoading) {
          setState(() => _isLoading = true);
        } else {
          setState(() => _isLoading = false);
        }

        if (state is AuthAuthenticated) {
          if (state.user.isPending) {
            // Show success banner for pending registration
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: const Text(
                  'تم إرسال طلب تسجيل الحساب بنجاح... انتظر حتى يتم قبولك',
                ),
                backgroundColor: AppColors.success,
                behavior: SnackBarBehavior.floating,
              ),
            );
            // Logout to clear tokens and redirect to login
            context.read<AuthCubit>().logout();
            // Redirect after a small delay to allow logout to process
            Future.delayed(const Duration(milliseconds: 100), () {
              if (mounted) context.go('/login');
            });
          } else {
            // Active user, proceed to home
            context.go('/home');
          }
        } else if (state is AuthError) {
          // Get current locale
          final locale = Localizations.localeOf(context);
          final isArabic = locale.languageCode == 'ar';

          // Check if this is an account under review error
          final isAccountUnderReview =
              state.message.contains('account is under review') ||
              state.message.contains('قيد المراجعة') ||
              state.message.contains('ACCOUNT_UNDER_REVIEW') ||
              state.message.contains('under review');

          // Check if this is an account rejected error
          final isAccountRejected =
              state.message.contains('account has been rejected') ||
              state.message.contains('تم رفض') ||
              state.message.contains('ACCOUNT_REJECTED') ||
              state.message.contains('has been rejected');

          // Check if this is a user already exists error
          final isUserAlreadyExists =
              state.message.contains('phone or email already exists') ||
              state.message.contains(
                'User with this phone or email already exists',
              ) ||
              state.message.contains('موجود بالفعل') ||
              state.message.contains('CONFLICT') ||
              state.message.contains('ConflictException') ||
              state.message.contains('already exists');

          final backgroundColor = isAccountUnderReview
              ? AppColors.warning
              : AppColors.error;

          final icon = isAccountUnderReview
              ? Iconsax.warning_2
              : Iconsax.info_circle;

          // Extract clean message (remove exception prefix if present)
          String cleanMessage = state.message;
          // Remove AppException, ConflictException, or other exception prefixes
          if (cleanMessage.contains('AppException:')) {
            cleanMessage = cleanMessage.split('AppException:').last.trim();
          } else if (cleanMessage.contains('ConflictException:')) {
            cleanMessage = cleanMessage.split('ConflictException:').last.trim();
          } else if (cleanMessage.contains('Exception:')) {
            cleanMessage = cleanMessage.split('Exception:').last.trim();
          }
          // Remove code part if present
          if (cleanMessage.contains('(code:')) {
            cleanMessage = cleanMessage.split('(code:').first.trim();
          }

          // Use localized message for account under review
          if (isAccountUnderReview) {
            cleanMessage = isArabic
                ? AccountUnderReviewException.arabicMessage
                : AccountUnderReviewException.englishMessage;
          }
          // Use localized message for account rejected
          else if (isAccountRejected) {
            cleanMessage = isArabic
                ? AccountRejectedException.arabicMessage
                : AccountRejectedException.englishMessage;
          }
          // Use localized message for user already exists
          else if (isUserAlreadyExists) {
            cleanMessage = isArabic
                ? ConflictException.userAlreadyExistsAr
                : ConflictException.userAlreadyExistsEn;
          }

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  Icon(icon, color: Colors.white, size: 20.sp),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: Text(
                      cleanMessage,
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w500,
                        color: Colors.white,
                      ),
                      textDirection: isArabic
                          ? TextDirection.rtl
                          : TextDirection.ltr,
                      textAlign: isArabic ? TextAlign.right : TextAlign.left,
                    ),
                  ),
                ],
              ),
              backgroundColor: backgroundColor,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.r),
              ),
              margin: EdgeInsets.all(16.w),
              duration: const Duration(seconds: 4),
            ),
          );
        }
      },
      builder: (context, state) {
        return Scaffold(
          appBar: AppBar(title: Text(AppLocalizations.of(context)!.register)),
          body: SafeArea(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(24.w),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Header
                    Text(
                      'أهلاً بك في تراس فون',
                      textAlign: TextAlign.right,
                      textDirection: TextDirection.rtl,
                      style: TextStyle(
                        fontSize: 24.sp,
                        fontWeight: FontWeight.w700,
                        color: isDark
                            ? AppColors.textPrimaryDark
                            : AppColors.textPrimaryLight,
                      ),
                    ),
                    SizedBox(height: 8.h),
                    Text(
                      'أنشئ حسابك للاستفادة من أسعار الجملة',
                      textAlign: TextAlign.right,
                      textDirection: TextDirection.rtl,
                      style: TextStyle(
                        fontSize: 15.sp,
                        color: isDark
                            ? AppColors.textSecondaryDark
                            : AppColors.textSecondaryLight,
                      ),
                    ),
                    SizedBox(height: 32.h),

                    // Personal Info Section
                    _buildSectionHeader('المعلومات الشخصية'),
                    SizedBox(height: 16.h),

                    // Name Field
                    AppTextField(
                      label: 'اسم المسؤول',
                      hint: 'أدخل اسمك الكامل',
                      controller: _nameController,
                      prefixIcon: Iconsax.user,
                      validator: Validators.name,
                      textInputAction: TextInputAction.next,
                    ),
                    SizedBox(height: 16.h),

                    // Phone Field
                    AppTextField(
                      label: AppLocalizations.of(context)!.phone,
                      hint: '5XXXXXXXX',
                      controller: _phoneController,
                      keyboardType: TextInputType.phone,
                      prefixIcon: Iconsax.call,
                      validator: Validators.phone,
                      textInputAction: TextInputAction.next,
                      maxLength: 9,
                    ),
                    SizedBox(height: 24.h),

                    // Business Info Section
                    _buildSectionHeader('معلومات المحل'),
                    SizedBox(height: 16.h),

                    // Shop Name Field
                    AppTextField(
                      label: 'اسم المحل',
                      hint: 'أدخل اسم المحل',
                      controller: _shopNameController,
                      prefixIcon: Iconsax.shop,
                      validator: Validators.shopName,
                      textInputAction: TextInputAction.next,
                    ),
                    SizedBox(height: 16.h),

                    // Country Dropdown
                    Text(
                      'الدولة',
                      textAlign: TextAlign.right,
                      textDirection: TextDirection.rtl,
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w500,
                        color: isDark
                            ? AppColors.textPrimaryDark
                            : AppColors.textPrimaryLight,
                      ),
                    ),
                    SizedBox(height: 8.h),
                    BlocConsumer<LocationsCubit, LocationsState>(
                      listener: (context, locationsState) {
                        // Auto-select first city when cities are loaded for the first time
                        if (locationsState.cities.isNotEmpty &&
                            _selectedCity == null) {
                          if (mounted) {
                            setState(() {
                              _selectedCity = locationsState.cities.first;
                            });
                          }
                        }
                        // Reset and auto-select first city when country changes
                        if (locationsState.selectedCountry != null) {
                          // Check if current city belongs to different country
                          if (_selectedCity != null &&
                              _selectedCity!.countryId !=
                                  locationsState.selectedCountry!.id) {
                            // Reset city and select first city of new country
                            if (locationsState.cities.isNotEmpty) {
                              if (mounted) {
                                setState(() {
                                  _selectedCity = locationsState.cities.first;
                                });
                              }
                            } else if (mounted) {
                              setState(() {
                                _selectedCity = null;
                              });
                            }
                          }
                        }
                      },
                      builder: (context, locationsState) {
                        // Show loading only when initial load and countries are empty
                        if (locationsState.status == LocationsStatus.loading &&
                            locationsState.countries.isEmpty &&
                            locationsState.selectedCountry == null) {
                          return const Center(
                            child: Padding(
                              padding: EdgeInsets.all(16.0),
                              child: CircularProgressIndicator(),
                            ),
                          );
                        }

                        // Show error if countries failed to load
                        if (locationsState.status == LocationsStatus.failure &&
                            locationsState.countries.isEmpty) {
                          return Text(
                            locationsState.errorMessage ?? 'فشل تحميل الدول',
                            textAlign: TextAlign.right,
                            textDirection: TextDirection.rtl,
                            style: TextStyle(
                              color: AppColors.error,
                              fontSize: 14.sp,
                            ),
                          );
                        }

                        // Show message if no countries available (but not loading)
                        if (locationsState.countries.isEmpty &&
                            locationsState.status != LocationsStatus.loading) {
                          return Text(
                            'لا توجد دول متاحة',
                            textAlign: TextAlign.right,
                            textDirection: TextDirection.rtl,
                            style: TextStyle(
                              color: AppColors.error,
                              fontSize: 14.sp,
                            ),
                          );
                        }

                        return DropdownButtonFormField<CountryModel>(
                          value: locationsState.selectedCountry,
                          decoration: InputDecoration(
                            prefixIcon: Icon(
                              Iconsax.global,
                              size: 20.sp,
                              color: isDark
                                  ? AppColors.textSecondaryDark
                                  : AppColors.textSecondaryLight,
                            ),
                          ),
                          alignment: AlignmentDirectional.centerStart,
                          hint: Text(
                            'اختر الدولة',
                            textDirection: TextDirection.rtl,
                            textAlign: TextAlign.right,
                          ),
                          items: locationsState.countries.map((country) {
                            return DropdownMenuItem<CountryModel>(
                              value: country,
                              alignment: AlignmentDirectional.centerStart,
                              child: Text(
                                country.nameAr,
                                textDirection: TextDirection.rtl,
                                textAlign: TextAlign.right,
                              ),
                            );
                          }).toList(),
                          onChanged: (country) {
                            if (country != null) {
                              context.read<LocationsCubit>().selectCountry(
                                country,
                              );
                            }
                          },
                        );
                      },
                    ),
                    SizedBox(height: 16.h),

                    // City Dropdown
                    Text(
                      AppLocalizations.of(context)!.city,
                      textAlign: TextAlign.right,
                      textDirection: TextDirection.rtl,
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w500,
                        color: isDark
                            ? AppColors.textPrimaryDark
                            : AppColors.textPrimaryLight,
                      ),
                    ),
                    SizedBox(height: 8.h),
                    BlocBuilder<LocationsCubit, LocationsState>(
                      builder: (context, locationsState) {
                        if (locationsState.status == LocationsStatus.loading &&
                            locationsState.cities.isEmpty &&
                            locationsState.selectedCountry != null) {
                          return const Center(
                            child: Padding(
                              padding: EdgeInsets.all(16.0),
                              child: CircularProgressIndicator(),
                            ),
                          );
                        }

                        if (locationsState.cities.isEmpty) {
                          return Text(
                            'لا توجد مدن متاحة',
                            textAlign: TextAlign.right,
                            textDirection: TextDirection.rtl,
                            style: TextStyle(
                              color: AppColors.error,
                              fontSize: 14.sp,
                            ),
                          );
                        }

                        return DropdownButtonFormField<CityModel>(
                          value: _selectedCity,
                          decoration: InputDecoration(
                            prefixIcon: Icon(
                              Iconsax.location,
                              size: 20.sp,
                              color: isDark
                                  ? AppColors.textSecondaryDark
                                  : AppColors.textSecondaryLight,
                            ),
                          ),
                          alignment: AlignmentDirectional.centerStart,
                          hint: Text(
                            'اختر المدينة',
                            textDirection: TextDirection.rtl,
                            textAlign: TextAlign.right,
                          ),
                          items: locationsState.cities.map((city) {
                            return DropdownMenuItem<CityModel>(
                              value: city,
                              alignment: AlignmentDirectional.centerStart,
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  if (city.isCapital)
                                    Icon(
                                      Icons.star,
                                      size: 16.sp,
                                      color: Colors.amber,
                                    ),
                                  if (city.isCapital) SizedBox(width: 8.w),
                                  Flexible(
                                    child: Text(
                                      city.nameAr,
                                      textDirection: TextDirection.rtl,
                                      textAlign: TextAlign.right,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                          onChanged: (city) {
                            setState(() => _selectedCity = city);
                          },
                        );
                      },
                    ),
                    SizedBox(height: 24.h),

                    // Password Section
                    _buildSectionHeader('كلمة المرور'),
                    SizedBox(height: 16.h),

                    // Password Field
                    AppTextField(
                      label: AppLocalizations.of(context)!.password,
                      hint: 'أدخل كلمة المرور',
                      controller: _passwordController,
                      obscureText: true,
                      prefixIcon: Iconsax.lock,
                      validator: Validators.password,
                      textInputAction: TextInputAction.next,
                    ),
                    SizedBox(height: 16.h),

                    // Confirm Password Field
                    AppTextField(
                      label: AppLocalizations.of(context)!.confirmPassword,
                      hint: 'أعد إدخال كلمة المرور',
                      controller: _confirmPasswordController,
                      obscureText: true,
                      prefixIcon: Iconsax.lock,
                      validator: (value) => Validators.confirmPassword(
                        value,
                        _passwordController.text,
                      ),
                      textInputAction: TextInputAction.done,
                      onSubmitted: (_) => _handleRegister(),
                    ),
                    SizedBox(height: 32.h),

                    // Register Button
                    AppButton(
                      text: AppLocalizations.of(context)!.register,
                      onPressed: _handleRegister,
                      isLoading: _isLoading,
                    ),
                    SizedBox(height: 24.h),

                    // Login Link
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'لديك حساب بالفعل؟',
                          textAlign: TextAlign.right,
                          textDirection: TextDirection.rtl,
                          style: TextStyle(
                            fontSize: 15.sp,
                            color: isDark
                                ? AppColors.textSecondaryDark
                                : AppColors.textSecondaryLight,
                          ),
                        ),
                        TextButton(
                          onPressed: () => context.pop(),
                          child: Text(
                            AppLocalizations.of(context)!.login,
                            textDirection: TextDirection.rtl,
                            style: TextStyle(
                              fontSize: 15.sp,
                              fontWeight: FontWeight.w600,
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 24.h),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildSectionHeader(String title) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Text(
      title,
      textAlign: TextAlign.right,
      textDirection: TextDirection.rtl,
      style: TextStyle(
        fontSize: 18.sp,
        fontWeight: FontWeight.w600,
        color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
      ),
    );
  }
}

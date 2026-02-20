/// Register Screen - New user registration
library;

import 'dart:developer' as developer;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax/iconsax.dart';
import '../../../../core/config/theme/app_colors.dart';
import '../../../../core/utils/validators.dart';
import '../../../../core/widgets/widgets.dart';
import '../cubit/auth_cubit.dart';
import '../cubit/auth_state.dart';
import '../../../../l10n/app_localizations.dart';
import '../helpers/auth_error_helper.dart';
import '../../../address/presentation/cubit/locations_cubit.dart';
import '../../../address/presentation/cubit/locations_state.dart';
import '../../../address/domain/entities/city_entity.dart';
import '../../../address/domain/entities/country_entity.dart';

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
  CityEntity? _selectedCity;

  @override
  void initState() {
    super.initState();
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

      final cityIdValue = _selectedCity!.id;
      developer.log(
        'Selected city: ${_selectedCity!.nameAr} (id: $cityIdValue)',
        name: 'RegisterScreen',
      );

      context.read<AuthCubit>().register(
            phone: _phoneController.text.trim(),
            password: _passwordController.text,
            responsiblePersonName: _nameController.text.trim(),
            shopName: _shopNameController.text.trim(),
            cityId: cityIdValue,
            businessType: 'shop',
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
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text(
                  'تم إرسال طلب تسجيل الحساب بنجاح... انتظر حتى يتم قبولك',
                ),
                backgroundColor: AppColors.success,
                behavior: SnackBarBehavior.floating,
              ),
            );
            context.read<AuthCubit>().logout();
            Future.delayed(const Duration(milliseconds: 100), () {
              if (mounted) context.go('/login');
            });
          } else {
            context.go('/home');
          }
        } else if (state is AuthError) {
          final locale = Localizations.localeOf(context);
          AuthErrorHelper.showErrorSnackBar(
            context,
            state.message,
            isArabic: locale.languageCode == 'ar',
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

                    _buildSectionHeader('المعلومات الشخصية'),
                    SizedBox(height: 16.h),

                    AppTextField(
                      label: 'اسم المسؤول',
                      hint: 'أدخل اسمك الكامل',
                      controller: _nameController,
                      prefixIcon: Iconsax.user,
                      validator: Validators.name,
                      textInputAction: TextInputAction.next,
                    ),
                    SizedBox(height: 16.h),

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

                    _buildSectionHeader('معلومات المحل'),
                    SizedBox(height: 16.h),

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
                        if (locationsState.cities.isNotEmpty &&
                            _selectedCity == null) {
                          if (mounted) {
                            setState(() {
                              _selectedCity = locationsState.cities.first;
                            });
                          }
                        }
                        if (locationsState.selectedCountry != null &&
                            _selectedCity != null &&
                            _selectedCity!.countryId !=
                                locationsState.selectedCountry!.id) {
                          if (mounted) {
                            setState(() {
                              _selectedCity = locationsState.cities.isNotEmpty
                                  ? locationsState.cities.first
                                  : null;
                            });
                          }
                        }
                      },
                      builder: (context, locationsState) {
                        if (locationsState.status == LocationsStatus.loading &&
                            locationsState.countries.isEmpty) {
                          return const Center(
                            child: Padding(
                              padding: EdgeInsets.all(16.0),
                              child: CircularProgressIndicator(),
                            ),
                          );
                        }

                        if (locationsState.status == LocationsStatus.failure &&
                            locationsState.countries.isEmpty) {
                          return Text(
                            locationsState.errorMessage ?? 'فشل تحميل الدول',
                            textAlign: TextAlign.right,
                            textDirection: TextDirection.rtl,
                            style: TextStyle(
                                color: AppColors.error, fontSize: 14.sp),
                          );
                        }

                        if (locationsState.countries.isEmpty) {
                          return Text(
                            'لا توجد دول متاحة',
                            textAlign: TextAlign.right,
                            textDirection: TextDirection.rtl,
                            style: TextStyle(
                                color: AppColors.error, fontSize: 14.sp),
                          );
                        }

                        return DropdownButtonFormField<CountryEntity>(
                          initialValue: locationsState.selectedCountry,
                          decoration: InputDecoration(
                            prefixIcon: Icon(
                              Iconsax.global,
                              size: 20.sp,
                              color: isDark
                                  ? AppColors.textSecondaryDark
                                  : AppColors.textSecondaryLight,
                            ),
                          ),
                          hint: const Text('اختر الدولة',
                              textDirection: TextDirection.rtl),
                          items: locationsState.countries.map((country) {
                            return DropdownMenuItem<CountryEntity>(
                              value: country,
                              child: Text(country.nameAr,
                                  textDirection: TextDirection.rtl),
                            );
                          }).toList(),
                          onChanged: (country) {
                            if (country != null) {
                              context
                                  .read<LocationsCubit>()
                                  .selectCountry(country);
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
                            locationsState.cities.isEmpty) {
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
                                color: AppColors.error, fontSize: 14.sp),
                          );
                        }

                        CityEntity? safeSelectedCity;
                        if (_selectedCity != null) {
                          try {
                            safeSelectedCity = locationsState.cities.firstWhere(
                              (city) => city.id == _selectedCity!.id,
                            );
                          } catch (_) {
                            safeSelectedCity = null;
                          }
                        }

                        return DropdownButtonFormField<CityEntity>(
                          initialValue: safeSelectedCity,
                          decoration: InputDecoration(
                            prefixIcon: Icon(
                              Iconsax.location,
                              size: 20.sp,
                              color: isDark
                                  ? AppColors.textSecondaryDark
                                  : AppColors.textSecondaryLight,
                            ),
                          ),
                          hint: const Text('اختر المدينة',
                              textDirection: TextDirection.rtl),
                          items: locationsState.cities.map((city) {
                            return DropdownMenuItem<CityEntity>(
                              value: city,
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  if (city.isCapital)
                                    Icon(Icons.star,
                                        size: 16.sp, color: Colors.amber),
                                  if (city.isCapital) SizedBox(width: 8.w),
                                  Flexible(
                                    child: Text(
                                      city.nameAr,
                                      textDirection: TextDirection.rtl,
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

                    _buildSectionHeader('كلمة المرور'),
                    SizedBox(height: 16.h),

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

                    AppButton(
                      text: AppLocalizations.of(context)!.register,
                      onPressed: _handleRegister,
                      isLoading: _isLoading,
                    ),
                    SizedBox(height: 24.h),

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

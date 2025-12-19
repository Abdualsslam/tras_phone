/// Register Screen - New user registration
library;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax/iconsax.dart';
import '../../../../core/config/theme/app_colors.dart';
import '../../../../core/utils/validators.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../cubit/auth_cubit.dart';
import '../cubit/auth_state.dart';

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
  int _selectedCityId = 1;

  final List<Map<String, dynamic>> _cities = [
    {'id': 1, 'name': 'الرياض'},
    {'id': 2, 'name': 'جدة'},
    {'id': 3, 'name': 'الدمام'},
    {'id': 4, 'name': 'مكة المكرمة'},
    {'id': 5, 'name': 'المدينة المنورة'},
  ];

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
      context.read<AuthCubit>().register(
        phone: _phoneController.text.trim(),
        password: _passwordController.text,
        responsiblePersonName: _nameController.text.trim(),
        shopName: _shopNameController.text.trim(),
        cityId: _selectedCityId,
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
          context.go('/home');
        } else if (state is AuthError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: AppColors.error,
            ),
          );
        }
      },
      builder: (context, state) {
        return Scaffold(
          appBar: AppBar(title: const Text('إنشاء حساب')),
          body: SafeArea(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(24.w),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header
                    Text(
                      'أهلاً بك في تراس فون',
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
                      label: 'رقم الجوال',
                      hint: '5XXXXXXXX',
                      controller: _phoneController,
                      keyboardType: TextInputType.phone,
                      prefixIcon: Iconsax.call,
                      validator: Validators.phone,
                      textInputAction: TextInputAction.next,
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

                    // City Dropdown
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
                    DropdownButtonFormField<int>(
                      value: _selectedCityId,
                      decoration: InputDecoration(
                        prefixIcon: Icon(
                          Iconsax.location,
                          size: 20.sp,
                          color: isDark
                              ? AppColors.textSecondaryDark
                              : AppColors.textSecondaryLight,
                        ),
                      ),
                      items: _cities.map((city) {
                        return DropdownMenuItem<int>(
                          value: city['id'] as int,
                          child: Text(city['name'] as String),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() => _selectedCityId = value ?? 1);
                      },
                    ),
                    SizedBox(height: 24.h),

                    // Password Section
                    _buildSectionHeader('كلمة المرور'),
                    SizedBox(height: 16.h),

                    // Password Field
                    AppTextField(
                      label: 'كلمة المرور',
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
                      label: 'تأكيد كلمة المرور',
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
                      text: 'إنشاء الحساب',
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
                            'سجل الدخول',
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
      style: TextStyle(
        fontSize: 18.sp,
        fontWeight: FontWeight.w600,
        color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
      ),
    );
  }
}

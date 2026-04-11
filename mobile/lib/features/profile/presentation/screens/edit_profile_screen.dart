library;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax/iconsax.dart';

import '../../../../core/config/theme/app_colors.dart';
import '../../../../l10n/app_localizations.dart';
import '../../domain/enums/customer_enums.dart';
import '../../domain/repositories/profile_repository.dart';
import '../../presentation/cubit/profile_cubit.dart';
import '../../presentation/cubit/profile_state.dart';
import '../models/edit_profile_form_state.dart';
import '../widgets/edit_profile_sections.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  late final EditProfileFormState _formState;

  @override
  void initState() {
    super.initState();
    _formState = EditProfileFormState();
    context.read<ProfileCubit>().loadProfile();
  }

  @override
  void dispose() {
    _formState.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final repository = context.read<ProfileRepository>();

    return AnimatedBuilder(
      animation: _formState,
      builder: (context, _) {
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
            listener: (context, state) async {
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
                return;
              }

              if (state is ProfileError) {
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
                return;
              }

              if (state is ProfileLoaded) {
                await _formState.initializeFromCustomer(
                  state.customer,
                  repository,
                );
              }
            },
            builder: (context, state) {
              if (state is ProfileLoading && !_formState.isInitialized) {
                return const Center(child: CircularProgressIndicator());
              }

              final customer = switch (state) {
                ProfileLoaded(:final customer) => customer,
                ProfileUpdated(:final customer) => customer,
                _ => null,
              };

              if (customer != null && !_formState.isInitialized) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  _formState.initializeFromCustomer(customer, repository);
                });
              }

              return SingleChildScrollView(
                padding: EdgeInsets.all(16.w),
                child: Form(
                  key: _formState.formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const EditProfileSectionTitle(title: 'بيانات المتجر'),
                      EditProfileTextField(
                        isDark: isDark,
                        controller: _formState.responsiblePersonNameController,
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
                      EditProfileTextField(
                        isDark: isDark,
                        controller: _formState.shopNameController,
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
                      EditProfileTextField(
                        isDark: isDark,
                        controller: _formState.shopNameArController,
                        label: 'اسم المتجر (عربي)',
                        icon: Iconsax.shop,
                      ),
                      SizedBox(height: 16.h),
                      EditProfileDropdownField<String>(
                        isDark: isDark,
                        label: 'نوع العمل *',
                        icon: Iconsax.category,
                        value: _formState.selectedBusinessType,
                        items: BusinessType.values
                            .map(
                              (type) => DropdownMenuItem<String>(
                                value: type.name,
                                child: Text(type.displayName),
                              ),
                            )
                            .toList(),
                        onChanged: _formState.setBusinessType,
                        validator: (value) {
                          if (value == null) {
                            return 'الرجاء اختيار نوع العمل';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 24.h),
                      const EditProfileSectionTitle(title: 'الموقع والتوصيل'),
                      EditProfileDropdownField<String>(
                        isDark: isDark,
                        label: 'المدينة',
                        icon: Iconsax.location,
                        value: _formState.selectedCityId,
                        items: _formState.cities.map((city) {
                          final id =
                              city['_id']?.toString() ??
                              city['id']?.toString() ??
                              '';
                          final name = city['nameAr'] ?? city['name'] ?? '';
                          return DropdownMenuItem<String>(
                            value: id,
                            child: Text(name),
                          );
                        }).toList(),
                        onChanged: (value) {
                          _formState.onCityChanged(repository, value);
                        },
                        isLoading: _formState.loadingCities,
                        onLoad: () => _formState.loadCities(repository),
                      ),
                      SizedBox(height: 16.h),
                      if (_formState.selectedCityId != null) ...[
                        EditProfileDropdownField<String>(
                          isDark: isDark,
                          label: 'السوق',
                          icon: Iconsax.shop,
                          value: _formState.selectedMarketId,
                          items: _formState.markets.map((market) {
                            final id =
                                market['_id']?.toString() ??
                                market['id']?.toString() ??
                                '';
                            final name =
                                market['nameAr'] ?? market['name'] ?? '';
                            return DropdownMenuItem<String>(
                              value: id,
                              child: Text(name),
                            );
                          }).toList(),
                          onChanged: _formState.setMarketId,
                          isLoading: _formState.loadingMarkets,
                        ),
                        SizedBox(height: 16.h),
                      ],
                      EditProfileTextField(
                        isDark: isDark,
                        controller: _formState.addressController,
                        label: 'العنوان',
                        icon: Iconsax.location,
                        maxLines: 3,
                      ),
                      SizedBox(height: 16.h),
                      EditProfileDropdownField<String>(
                        isDark: isDark,
                        label: 'طريقة الدفع المفضلة',
                        icon: Iconsax.wallet,
                        value: _formState.selectedPaymentMethod,
                        items: PaymentMethod.values
                            .map(
                              (method) => DropdownMenuItem<String>(
                                value: method.value,
                                child: Text(method.displayName),
                              ),
                            )
                            .toList(),
                        onChanged: _formState.setPaymentMethod,
                      ),
                      SizedBox(height: 16.h),
                      EditProfileDropdownField<String>(
                        isDark: isDark,
                        label: 'وقت التوصيل المفضل',
                        icon: Iconsax.clock,
                        value: _formState.selectedShippingTime,
                        items: const [
                          DropdownMenuItem(
                            value: 'morning',
                            child: Text('صباحاً'),
                          ),
                          DropdownMenuItem(
                            value: 'afternoon',
                            child: Text('بعد الظهر'),
                          ),
                          DropdownMenuItem(
                            value: 'evening',
                            child: Text('مساءً'),
                          ),
                        ],
                        onChanged: _formState.setShippingTime,
                      ),
                      SizedBox(height: 16.h),
                      EditProfileDropdownField<String>(
                        isDark: isDark,
                        label: 'طريقة التواصل المفضلة',
                        icon: Iconsax.call,
                        value: _formState.selectedContactMethod,
                        items: ContactMethod.values
                            .map(
                              (method) => DropdownMenuItem<String>(
                                value: method.name,
                                child: Text(method.displayName),
                              ),
                            )
                            .toList(),
                        onChanged: _formState.setContactMethod,
                      ),
                      SizedBox(height: 24.h),
                      const EditProfileSectionTitle(
                        title: 'الحسابات الاجتماعية',
                      ),
                      EditProfileTextField(
                        isDark: isDark,
                        controller: _formState.instagramHandleController,
                        label: 'حساب إنستغرام',
                        icon: Iconsax.instagram,
                        prefixText: '@',
                      ),
                      SizedBox(height: 16.h),
                      EditProfileTextField(
                        isDark: isDark,
                        controller: _formState.twitterHandleController,
                        label: 'حساب تويتر',
                        icon: Iconsax.message,
                        prefixText: '@',
                      ),
                      SizedBox(height: 32.h),
                      EditProfileSaveButton(
                        isLoading: state is ProfileLoading,
                        onPressed: () {
                          if (_formState.formKey.currentState?.validate() !=
                              true) {
                            return;
                          }
                          context.read<ProfileCubit>().updateProfile(
                            _formState.buildDto(),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}

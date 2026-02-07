/// Devices List Screen - Phone models for spare parts
library;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax/iconsax.dart';
import '../../../../core/config/theme/app_colors.dart';
import '../../../../core/config/theme/app_theme.dart';
import '../../../../core/di/injection.dart';
import '../../domain/entities/brand_entity.dart';
import '../../domain/entities/device_entity.dart';
import '../../domain/repositories/catalog_repository.dart';
import '../cubit/brands_cubit.dart';
import '../cubit/brands_state.dart';
import '../cubit/devices_cubit.dart';
import '../cubit/devices_state.dart';
import '../../../../l10n/app_localizations.dart';

class DevicesListScreen extends StatelessWidget {
  const DevicesListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => BrandsCubit(
            repository: getIt<CatalogRepository>(),
          )..loadBrands(),
        ),
        BlocProvider(
          create: (context) => DevicesCubit(
            repository: getIt<CatalogRepository>(),
          ),
        ),
      ],
      child: const _DevicesListView(),
    );
  }
}

class _DevicesListView extends StatefulWidget {
  const _DevicesListView();

  @override
  State<_DevicesListView> createState() => _DevicesListViewState();
}

class _DevicesListViewState extends State<_DevicesListView> {
  String? _selectedBrandId;
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.devices),
        actions: [
          IconButton(
            onPressed: () => context.push('/search'),
            icon: Icon(Iconsax.search_normal, size: 22.sp),
          ),
        ],
      ),
      body: BlocConsumer<BrandsCubit, BrandsState>(
        listener: (context, state) {
          if (state is BrandsLoaded && state.brands.isNotEmpty) {
            if (_selectedBrandId == null) {
              _selectedBrandId = state.brands.first.id;
              context.read<DevicesCubit>().loadDevicesByBrand(_selectedBrandId!);
            }
          }
        },
        builder: (context, brandsState) {
          if (brandsState is BrandsLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (brandsState is BrandsError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(brandsState.message),
                  SizedBox(height: 16.h),
                  ElevatedButton(
                    onPressed: () => context.read<BrandsCubit>().loadBrands(),
                    child: const Text('إعادة المحاولة'),
                  ),
                ],
              ),
            );
          }

          if (brandsState is BrandsLoaded) {
            return Column(
              children: [
                // Search Bar
                Padding(
                  padding: EdgeInsets.all(16.w),
                  child: TextField(
                    controller: _searchController,
                    onChanged: (value) => setState(() {}),
                    decoration: InputDecoration(
                      hintText: 'ابحث عن جهاز...',
                      prefixIcon: Icon(Iconsax.search_normal, size: 20.sp),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.r),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: isDark
                          ? AppColors.cardDark
                          : AppColors.backgroundLight,
                    ),
                  ),
                ),

                // Brands Filter
                _buildBrandsFilter(brandsState.brands, isDark),

                // Devices List
                Expanded(
                  child: BlocBuilder<DevicesCubit, DevicesState>(
                    builder: (context, devicesState) {
                      if (devicesState is DevicesLoading) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      if (devicesState is DevicesError) {
                        return Center(child: Text(devicesState.message));
                      }

                      if (devicesState is DevicesLoaded) {
                        if (devicesState.devices.isEmpty) {
                          return _buildEmptyState(isDark);
                        }
                        return _buildDevicesList(devicesState.devices, isDark);
                      }

                      return _buildEmptyState(isDark);
                    },
                  ),
                ),
              ],
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildBrandsFilter(List<BrandEntity> brands, bool isDark) {
    return SizedBox(
      height: 50.h,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: 16.w),
        itemCount: brands.length,
        separatorBuilder: (context, index) => SizedBox(width: 8.w),
        itemBuilder: (context, index) {
          final brand = brands[index];
          final isSelected = _selectedBrandId == brand.id;

          return GestureDetector(
            onTap: () {
              setState(() => _selectedBrandId = brand.id);
              context.read<DevicesCubit>().loadDevicesByBrand(brand.id);
            },
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 20.w),
              decoration: BoxDecoration(
                color: isSelected
                    ? AppColors.primary
                    : (isDark ? AppColors.cardDark : AppColors.backgroundLight),
                borderRadius: BorderRadius.circular(25.r),
                border: Border.all(
                  color: isSelected
                      ? AppColors.primary
                      : (isDark
                            ? AppColors.dividerDark
                            : AppColors.dividerLight),
                ),
              ),
              child: Center(
                child: Text(
                  brand.nameAr,
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w500,
                    color: isSelected
                        ? Colors.white
                        : (isDark
                              ? AppColors.textPrimaryDark
                              : AppColors.textPrimaryLight),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildDevicesList(List<DeviceEntity> devices, bool isDark) {
    final searchQuery = _searchController.text.toLowerCase();
    final filteredDevices = devices
        .where(
          (d) =>
              d.name.toLowerCase().contains(searchQuery) ||
              d.nameAr.toLowerCase().contains(searchQuery),
        )
        .toList();

    if (filteredDevices.isEmpty) {
      return _buildEmptyState(isDark);
    }

    return ListView.builder(
      padding: EdgeInsets.all(16.w),
      itemCount: filteredDevices.length,
      itemBuilder: (context, index) {
        final device = filteredDevices[index];
        return _buildDeviceCard(device, isDark);
      },
    );
  }

  Widget _buildDeviceCard(DeviceEntity device, bool isDark) {
    return GestureDetector(
      onTap: () => context.push('/device/${device.id}/products'),
      child: Container(
        margin: EdgeInsets.only(bottom: 8.h),
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: isDark ? AppColors.cardDark : AppColors.cardLight,
          borderRadius: AppTheme.radiusMd,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            // Device Icon
            Container(
              width: 48.w,
              height: 48.w,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Icon(
                Iconsax.mobile,
                size: 24.sp,
                color: AppColors.primary,
              ),
            ),
            SizedBox(width: 12.w),

            // Device Name
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    device.nameAr,
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w500,
                      color: isDark
                          ? AppColors.textPrimaryDark
                          : AppColors.textPrimaryLight,
                    ),
                  ),
                  if (device.modelNumber != null)
                    Text(
                      device.modelNumber!,
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

            // Products count badge
            if (device.productsCount > 0)
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Text(
                  '${device.productsCount}',
                  style: TextStyle(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary,
                  ),
                ),
              ),
            SizedBox(width: 8.w),

            // Arrow
            Icon(
              Iconsax.arrow_left_2,
              size: 18.sp,
              color: isDark
                  ? AppColors.textSecondaryDark
                  : AppColors.textSecondaryLight,
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
            Iconsax.mobile,
            size: 80.sp,
            color: isDark
                ? AppColors.textTertiaryDark
                : AppColors.textTertiaryLight,
          ),
          SizedBox(height: 16.h),
          Text(
            'لا توجد أجهزة',
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.w600,
              color: isDark
                  ? AppColors.textPrimaryDark
                  : AppColors.textPrimaryLight,
            ),
          ),
        ],
      ),
    );
  }
}

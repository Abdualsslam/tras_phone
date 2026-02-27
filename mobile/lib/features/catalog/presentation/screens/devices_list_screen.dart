/// Devices List Screen - Phone models for spare parts
library;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax/iconsax.dart';
import '../../../../core/config/app_config.dart';
import '../../../../core/config/theme/app_colors.dart';
import '../../../../core/config/theme/app_theme.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/shimmer/index.dart';
import '../../domain/entities/brand_entity.dart';
import '../../domain/entities/device_entity.dart';
import '../../domain/repositories/catalog_repository.dart';
import '../cubit/brands_cubit.dart';
import '../cubit/brands_state.dart';
import '../cubit/devices_cubit.dart';
import '../cubit/devices_state.dart';
import '../../../../l10n/app_localizations.dart';

class DevicesListScreen extends StatelessWidget {
  final bool flowMode;
  final String? categoryId;
  final String? categoryName;
  final String? initialBrandId;
  final String? initialBrandName;

  const DevicesListScreen({
    super.key,
    this.flowMode = false,
    this.categoryId,
    this.categoryName,
    this.initialBrandId,
    this.initialBrandName,
  });

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) =>
              BrandsCubit(repository: getIt<CatalogRepository>())..loadBrands(),
        ),
        BlocProvider(
          create: (context) =>
              DevicesCubit(repository: getIt<CatalogRepository>()),
        ),
      ],
      child: _DevicesListView(
        flowMode: flowMode,
        categoryId: categoryId,
        categoryName: categoryName,
        initialBrandId: initialBrandId,
        initialBrandName: initialBrandName,
      ),
    );
  }
}

class _DevicesListView extends StatefulWidget {
  final bool flowMode;
  final String? categoryId;
  final String? categoryName;
  final String? initialBrandId;
  final String? initialBrandName;

  const _DevicesListView({
    required this.flowMode,
    this.categoryId,
    this.categoryName,
    this.initialBrandId,
    this.initialBrandName,
  });

  @override
  State<_DevicesListView> createState() => _DevicesListViewState();
}

class _DevicesListViewState extends State<_DevicesListView> {
  String? _selectedBrandId;
  String? _selectedBrandName;
  final _searchController = TextEditingController();
  List<BrandEntity> _cachedBrands = const [];
  List<DeviceEntity> _cachedDevices = const [];

  @override
  void initState() {
    super.initState();
    _selectedBrandId = widget.initialBrandId;
    _selectedBrandName = widget.initialBrandName;
  }

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
        title: Text(
          widget.flowMode
              ? 'اختر الجهاز'
              : AppLocalizations.of(context)!.devices,
        ),
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
            final brandIds = state.brands.map((b) => b.id).toSet();

            if (_selectedBrandId != null &&
                !brandIds.contains(_selectedBrandId)) {
              _selectedBrandId = state.brands.first.id;
            }

            _selectedBrandId ??= state.brands.first.id;

            if (_selectedBrandName == null && _selectedBrandId != null) {
              final selectedBrand = state.brands.firstWhere(
                (b) => b.id == _selectedBrandId,
                orElse: () => state.brands.first,
              );
              _selectedBrandName = selectedBrand.nameAr;
            }

            context.read<DevicesCubit>().loadDevicesByBrand(_selectedBrandId!);
          }
        },
        builder: (context, brandsState) {
          if (brandsState is BrandsLoaded) {
            _cachedBrands = brandsState.brands;
            return _buildLoadedContent(brandsState.brands, isDark);
          }

          if (brandsState is BrandsLoading) {
            if (_cachedBrands.isEmpty) {
              return const DevicesListShimmer();
            }

            return _buildLoadedContent(_cachedBrands, isDark);
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

          return const DevicesListShimmer();
        },
      ),
    );
  }

  Widget _buildLoadedContent(List<BrandEntity> brands, bool isDark) {
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
              fillColor: isDark ? AppColors.cardDark : AppColors.backgroundLight,
            ),
          ),
        ),

        // Brands Filter
        _buildBrandsFilter(brands, isDark),

        // Devices List
        Expanded(
          child: BlocBuilder<DevicesCubit, DevicesState>(
            builder: (context, devicesState) =>
                _buildDevicesContent(devicesState, isDark),
          ),
        ),
      ],
    );
  }

  Widget _buildDevicesContent(DevicesState devicesState, bool isDark) {
    if (devicesState is DevicesLoaded) {
      _cachedDevices = devicesState.devices;
      if (devicesState.devices.isEmpty) {
        return _buildEmptyState(isDark);
      }
      return _buildDevicesList(devicesState.devices, isDark);
    }

    if (devicesState is DevicesLoading) {
      if (_cachedDevices.isEmpty) {
        return const DeviceItemsShimmer();
      }
      return _buildDevicesList(_cachedDevices, isDark);
    }

    if (devicesState is DevicesError) {
      if (_cachedDevices.isNotEmpty) {
        return _buildDevicesList(_cachedDevices, isDark);
      }
      return Center(child: Text(devicesState.message));
    }

    if (_cachedDevices.isNotEmpty) {
      return _buildDevicesList(_cachedDevices, isDark);
    }

    return _buildEmptyState(isDark);
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
              setState(() {
                _selectedBrandId = brand.id;
                _selectedBrandName = brand.nameAr;
              });
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
      onTap: () {
        if (widget.flowMode) {
          final queryParams = <String, String>{
            if (widget.categoryId != null && widget.categoryId!.isNotEmpty)
              'categoryId': widget.categoryId!,
            if (widget.categoryName != null && widget.categoryName!.isNotEmpty)
              'categoryName': widget.categoryName!,
            'deviceId': device.id,
            'deviceName': device.nameAr,
          };

          final route = Uri(
            path: '/products',
            queryParameters: queryParams,
          ).toString();
          context.push(route);
          return;
        }

        final route = Uri(
          path: '/device/${device.id}',
          queryParameters: {'name': device.nameAr},
        ).toString();
        context.push(route);
      },
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
            _buildDeviceThumbnail(device),
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

  Widget _buildDeviceThumbnail(DeviceEntity device) {
    final imageUrl = _resolveDeviceImageUrl(device.image);

    if (imageUrl == null || imageUrl.isEmpty) {
      return _buildDeviceIconPlaceholder();
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(12.r),
      child: Image.network(
        imageUrl,
        width: 48.w,
        height: 48.w,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) =>
            _buildDeviceIconPlaceholder(),
      ),
    );
  }

  Widget _buildDeviceIconPlaceholder() {
    return Container(
      width: 48.w,
      height: 48.w,
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Icon(Iconsax.mobile, size: 24.sp, color: AppColors.primary),
    );
  }

  String? _resolveDeviceImageUrl(String? rawImage) {
    if (rawImage == null || rawImage.trim().isEmpty) return null;

    final value = rawImage.trim();
    if (value.startsWith('http://') || value.startsWith('https://')) {
      return value;
    }

    final base = Uri.parse(AppConfig.baseUrl);
    final host =
        '${base.scheme}://${base.host}${base.hasPort ? ':${base.port}' : ''}';
    if (value.startsWith('/')) {
      return '$host$value';
    }

    return '$host/$value';
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

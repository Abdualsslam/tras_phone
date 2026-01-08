/// Devices List Screen - Phone models for spare parts
library;

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax/iconsax.dart';
import '../../../../core/config/theme/app_colors.dart';
import '../../../../core/config/theme/app_theme.dart';
import '../../../../core/di/injection.dart';
import '../../domain/entities/brand_entity.dart';
import '../../domain/entities/device_entity.dart';
import '../../data/datasources/catalog_remote_datasource.dart';
import '../../../../l10n/app_localizations.dart';

class DevicesListScreen extends StatefulWidget {
  const DevicesListScreen({super.key});

  @override
  State<DevicesListScreen> createState() => _DevicesListScreenState();
}

class _DevicesListScreenState extends State<DevicesListScreen> {
  final _dataSource = getIt<CatalogRemoteDataSource>();
  List<BrandEntity> _brands = [];
  String? _selectedBrandId;
  List<DeviceEntity> _devices = [];
  bool _isLoading = true;
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadBrands();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadBrands() async {
    setState(() => _isLoading = true);
    try {
      final brands = await _dataSource.getBrands();
      setState(() {
        _brands = brands;
        if (brands.isNotEmpty) {
          _selectedBrandId = brands.first.id.toString();
          _loadDevices();
        }
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _loadDevices() async {
    if (_selectedBrandId == null) return;
    try {
      final devices = await _dataSource.getDevicesByBrand(_selectedBrandId!);
      setState(() {
        _devices = devices;
      });
    } catch (e) {
      setState(() {
        _devices = [];
      });
    }
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
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
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
                _buildBrandsFilter(isDark),

                // Devices List
                Expanded(
                  child: _devices.isEmpty
                      ? _buildEmptyState(isDark)
                      : _buildDevicesList(isDark),
                ),
              ],
            ),
    );
  }

  Widget _buildBrandsFilter(bool isDark) {
    return SizedBox(
      height: 50.h,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: 16.w),
        itemCount: _brands.length,
        separatorBuilder: (_, __) => SizedBox(width: 8.w),
        itemBuilder: (context, index) {
          final brand = _brands[index];
          final isSelected = _selectedBrandId == brand.id.toString();

          return GestureDetector(
            onTap: () {
              setState(() => _selectedBrandId = brand.id.toString());
              _loadDevices();
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

  Widget _buildDevicesList(bool isDark) {
    final searchQuery = _searchController.text.toLowerCase();
    final filteredDevices = _devices
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

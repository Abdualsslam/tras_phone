/// Devices List Screen - Phone models for spare parts
library;

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax/iconsax.dart';
import '../../../../core/config/theme/app_colors.dart';
import '../../../../core/config/theme/app_theme.dart';
import '../../domain/entities/brand_entity.dart';
import '../../data/datasources/catalog_mock_datasource.dart';
import '../../../../l10n/app_localizations.dart';

class DevicesListScreen extends StatefulWidget {
  const DevicesListScreen({super.key});

  @override
  State<DevicesListScreen> createState() => _DevicesListScreenState();
}

class _DevicesListScreenState extends State<DevicesListScreen> {
  final _dataSource = CatalogMockDataSource();
  List<BrandEntity> _brands = [];
  String? _selectedBrandId;
  List<_DeviceModel> _devices = [];
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

  void _loadDevices() {
    // Mock devices data
    final mockDevices = <_DeviceModel>[
      _DeviceModel(
        id: '1',
        name: 'iPhone 15 Pro Max',
        brandId: '1',
        year: 2023,
      ),
      _DeviceModel(id: '2', name: 'iPhone 15 Pro', brandId: '1', year: 2023),
      _DeviceModel(id: '3', name: 'iPhone 15', brandId: '1', year: 2023),
      _DeviceModel(
        id: '4',
        name: 'iPhone 14 Pro Max',
        brandId: '1',
        year: 2022,
      ),
      _DeviceModel(id: '5', name: 'iPhone 14 Pro', brandId: '1', year: 2022),
      _DeviceModel(id: '6', name: 'iPhone 14', brandId: '1', year: 2022),
      _DeviceModel(
        id: '7',
        name: 'iPhone 13 Pro Max',
        brandId: '1',
        year: 2021,
      ),
      _DeviceModel(id: '8', name: 'Galaxy S24 Ultra', brandId: '2', year: 2024),
      _DeviceModel(id: '9', name: 'Galaxy S24+', brandId: '2', year: 2024),
      _DeviceModel(id: '10', name: 'Galaxy S24', brandId: '2', year: 2024),
      _DeviceModel(
        id: '11',
        name: 'Galaxy S23 Ultra',
        brandId: '2',
        year: 2023,
      ),
      _DeviceModel(id: '12', name: 'Galaxy A54', brandId: '2', year: 2023),
      _DeviceModel(id: '13', name: 'Huawei P60 Pro', brandId: '3', year: 2023),
      _DeviceModel(
        id: '14',
        name: 'Huawei Mate 60 Pro',
        brandId: '3',
        year: 2023,
      ),
      _DeviceModel(id: '15', name: 'Xiaomi 14 Pro', brandId: '4', year: 2024),
      _DeviceModel(id: '16', name: 'Xiaomi 13 Ultra', brandId: '4', year: 2023),
      _DeviceModel(
        id: '17',
        name: 'Redmi Note 13 Pro',
        brandId: '4',
        year: 2024,
      ),
    ];

    setState(() {
      _devices = mockDevices
          .where((d) => d.brandId == _selectedBrandId)
          .toList();
    });
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
                  brand.nameAr ?? brand.name,
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
        .where((d) => d.name.toLowerCase().contains(searchQuery))
        .toList();

    // Group by year
    final devicesByYear = <int, List<_DeviceModel>>{};
    for (final device in filteredDevices) {
      devicesByYear.putIfAbsent(device.year, () => []).add(device);
    }

    final years = devicesByYear.keys.toList()..sort((a, b) => b.compareTo(a));

    return ListView.builder(
      padding: EdgeInsets.all(16.w),
      itemCount: years.length,
      itemBuilder: (context, index) {
        final year = years[index];
        final devices = devicesByYear[year]!;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Year Header
            Padding(
              padding: EdgeInsets.only(bottom: 12.h, top: index > 0 ? 16.h : 0),
              child: Text(
                year.toString(),
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w700,
                  color: isDark
                      ? AppColors.textPrimaryDark
                      : AppColors.textPrimaryLight,
                ),
              ),
            ),

            // Devices
            ...devices.map((device) => _buildDeviceCard(device, isDark)),
          ],
        );
      },
    );
  }

  Widget _buildDeviceCard(_DeviceModel device, bool isDark) {
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
              child: Text(
                device.name,
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w500,
                  color: isDark
                      ? AppColors.textPrimaryDark
                      : AppColors.textPrimaryLight,
                ),
              ),
            ),

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

class _DeviceModel {
  final String id;
  final String name;
  final String brandId;
  final int year;

  _DeviceModel({
    required this.id,
    required this.name,
    required this.brandId,
    required this.year,
  });
}

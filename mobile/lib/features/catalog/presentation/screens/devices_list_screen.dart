library;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax/iconsax.dart';

import '../../../../core/shimmer/index.dart';
import '../../../../l10n/app_localizations.dart';
import '../../domain/entities/brand_entity.dart';
import '../../domain/entities/device_entity.dart';
import '../../domain/repositories/catalog_repository.dart';
import '../cubit/brands_cubit.dart';
import '../cubit/brands_state.dart';
import '../cubit/devices_cubit.dart';
import '../cubit/devices_state.dart';
import '../widgets/devices_list_sections.dart';

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
              BrandsCubit(repository: context.read<CatalogRepository>())
                ..loadBrands(),
        ),
        BlocProvider(
          create: (context) =>
              DevicesCubit(repository: context.read<CatalogRepository>()),
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
            final brandIds = state.brands.map((brand) => brand.id).toSet();

            if (_selectedBrandId != null &&
                !brandIds.contains(_selectedBrandId)) {
              _selectedBrandId = state.brands.first.id;
            }

            _selectedBrandId ??= state.brands.first.id;
            _selectedBrandName ??= state.brands
                .firstWhere(
                  (brand) => brand.id == _selectedBrandId,
                  orElse: () => state.brands.first,
                )
                .nameAr;

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
        DevicesSearchBar(
          controller: _searchController,
          isDark: isDark,
          onChanged: (_) => setState(() {}),
        ),
        DevicesBrandFilterBar(
          brands: brands,
          selectedBrandId: _selectedBrandId,
          isDark: isDark,
          onBrandSelected: (brand) {
            setState(() {
              _selectedBrandId = brand.id;
              _selectedBrandName = brand.nameAr;
            });
            context.read<DevicesCubit>().loadDevicesByBrand(brand.id);
          },
        ),
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
      return DevicesListContent(
        devices: _filterDevices(devicesState.devices),
        isDark: isDark,
        onDeviceTap: _openDevice,
      );
    }

    if (devicesState is DevicesLoading) {
      if (_cachedDevices.isEmpty) {
        return const DeviceItemsShimmer();
      }

      return DevicesListContent(
        devices: _filterDevices(_cachedDevices),
        isDark: isDark,
        onDeviceTap: _openDevice,
      );
    }

    if (devicesState is DevicesError) {
      if (_cachedDevices.isNotEmpty) {
        return DevicesListContent(
          devices: _filterDevices(_cachedDevices),
          isDark: isDark,
          onDeviceTap: _openDevice,
        );
      }
      return Center(child: Text(devicesState.message));
    }

    return DevicesListContent(
      devices: _filterDevices(_cachedDevices),
      isDark: isDark,
      onDeviceTap: _openDevice,
    );
  }

  List<DeviceEntity> _filterDevices(List<DeviceEntity> devices) {
    final searchQuery = _searchController.text.toLowerCase();
    if (searchQuery.isEmpty) {
      return devices;
    }

    return devices
        .where(
          (device) =>
              device.name.toLowerCase().contains(searchQuery) ||
              device.nameAr.toLowerCase().contains(searchQuery),
        )
        .toList();
  }

  void _openDevice(DeviceEntity device) {
    if (widget.flowMode) {
      final queryParams = <String, String>{
        if (widget.categoryId case final categoryId? when categoryId.isNotEmpty)
          'categoryId': categoryId,
        if (widget.categoryName case final categoryName?
            when categoryName.isNotEmpty)
          'categoryName': categoryName,
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
  }
}

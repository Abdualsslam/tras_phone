/// Device Products Screen - Spare parts for specific device
library;

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax/iconsax.dart';
import '../../../../core/config/theme/app_colors.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/widgets/widgets.dart';
import '../../domain/entities/product_entity.dart';
import '../../domain/entities/category_entity.dart';
import '../../data/datasources/catalog_remote_datasource.dart';

class DeviceProductsScreen extends StatefulWidget {
  final String deviceId;
  final String? deviceName;

  const DeviceProductsScreen({
    super.key,
    required this.deviceId,
    this.deviceName,
  });

  @override
  State<DeviceProductsScreen> createState() => _DeviceProductsScreenState();
}

class _DeviceProductsScreenState extends State<DeviceProductsScreen>
    with SingleTickerProviderStateMixin {
  final _dataSource = getIt<CatalogRemoteDataSource>();
  List<CategoryEntity> _categories = [];
  List<ProductEntity> _products = [];
  bool _isLoading = true;
  TabController? _tabController;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void dispose() {
    _tabController?.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final categories = await _dataSource.getCategories();
      final products = await _dataSource.getProducts(deviceId: widget.deviceId);

      setState(() {
        _categories = categories;
        _products = products;
        _tabController = TabController(length: categories.length, vsync: this);
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.deviceName ?? 'قطع الغيار'),
        actions: [
          IconButton(
            onPressed: () => context.push('/search'),
            icon: Icon(Iconsax.search_normal, size: 22.sp),
          ),
        ],
        bottom: _isLoading || _categories.isEmpty
            ? null
            : TabBar(
                controller: _tabController,
                isScrollable: true,
                tabAlignment: TabAlignment.start,
                labelColor: AppColors.primary,
                unselectedLabelColor: isDark
                    ? AppColors.textSecondaryDark
                    : AppColors.textSecondaryLight,
                indicatorColor: AppColors.primary,
                tabs: _categories.map((c) => Tab(text: c.nameAr)).toList(),
              ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _categories.isEmpty
          ? _buildEmptyState(isDark)
          : TabBarView(
              controller: _tabController,
              children: _categories.map((category) {
                return _buildProductsGrid(category.id.toString());
              }).toList(),
            ),
    );
  }

  Widget _buildProductsGrid(String categoryId) {
    // Filter products by category (mock filtering)
    final categoryProducts = _products;

    if (categoryProducts.isEmpty) {
      return _buildEmptyState(Theme.of(context).brightness == Brightness.dark);
    }

    return GridView.builder(
      padding: EdgeInsets.all(16.w),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 12.h,
        crossAxisSpacing: 12.w,
        childAspectRatio: 0.65,
      ),
      itemCount: categoryProducts.length,
      itemBuilder: (context, index) {
        final product = categoryProducts[index];
        return ProductCard(
          id: product.id.toString(),
          name: product.name,
          nameAr: product.nameAr,
          imageUrl: product.imageUrl,
          price: product.price,
          originalPrice: product.originalPrice,
          stockQuantity: product.stockQuantity,
          onTap: () => context.push('/product/${product.id}', extra: product),
        );
      },
    );
  }

  Widget _buildEmptyState(bool isDark) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Iconsax.box_1,
            size: 80.sp,
            color: isDark
                ? AppColors.textTertiaryDark
                : AppColors.textTertiaryLight,
          ),
          SizedBox(height: 16.h),
          Text(
            'لا توجد قطع غيار',
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.w600,
              color: isDark
                  ? AppColors.textPrimaryDark
                  : AppColors.textPrimaryLight,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            'لا توجد قطع غيار لهذا الجهاز حالياً',
            style: TextStyle(
              fontSize: 14.sp,
              color: isDark
                  ? AppColors.textSecondaryDark
                  : AppColors.textSecondaryLight,
            ),
          ),
        ],
      ),
    );
  }
}

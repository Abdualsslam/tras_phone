/// Advanced Search Screen - Search with filters
library;

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax/iconsax.dart';
import '../../../../core/config/theme/app_colors.dart';

class AdvancedSearchScreen extends StatefulWidget {
  const AdvancedSearchScreen({super.key});

  @override
  State<AdvancedSearchScreen> createState() => _AdvancedSearchScreenState();
}

class _AdvancedSearchScreenState extends State<AdvancedSearchScreen> {
  final _searchController = TextEditingController();
  RangeValues _priceRange = const RangeValues(0, 2000);
  String? _selectedCategory;
  String? _selectedBrand;
  bool _inStockOnly = false;
  bool _onSaleOnly = false;

  final _categories = [
    'شاشات',
    'بطاريات',
    'منافذ الشحن',
    'أغطية خلفية',
    'كاميرات',
  ];
  final _brands = ['Apple', 'Samsung', 'Huawei', 'Xiaomi', 'Oppo', 'Vivo'];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(title: const Text('بحث متقدم')),
      body: ListView(
        padding: EdgeInsets.all(16.w),
        children: [
          // Search Field
          TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'ابحث عن منتج...',
              prefixIcon: const Icon(Iconsax.search_normal),
              suffixIcon: _searchController.text.isNotEmpty
                  ? IconButton(
                      onPressed: () =>
                          setState(() => _searchController.clear()),
                      icon: const Icon(Icons.close),
                    )
                  : null,
            ),
            onChanged: (_) => setState(() {}),
          ),
          SizedBox(height: 24.h),

          // Price Range
          _buildSectionTitle('نطاق السعر', isDark),
          SizedBox(height: 12.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${_priceRange.start.toInt()} ر.س',
                style: TextStyle(fontSize: 14.sp, color: AppColors.primary),
              ),
              Text(
                '${_priceRange.end.toInt()} ر.س',
                style: TextStyle(fontSize: 14.sp, color: AppColors.primary),
              ),
            ],
          ),
          RangeSlider(
            values: _priceRange,
            min: 0,
            max: 5000,
            divisions: 50,
            activeColor: AppColors.primary,
            onChanged: (values) => setState(() => _priceRange = values),
          ),
          SizedBox(height: 24.h),

          // Category Filter
          _buildSectionTitle('التصنيف', isDark),
          SizedBox(height: 12.h),
          Wrap(
            spacing: 8.w,
            runSpacing: 8.h,
            children: _categories.map((cat) {
              final isSelected = _selectedCategory == cat;
              return ChoiceChip(
                label: Text(cat),
                selected: isSelected,
                onSelected: (selected) {
                  setState(() => _selectedCategory = selected ? cat : null);
                },
                selectedColor: AppColors.primary,
                labelStyle: TextStyle(color: isSelected ? Colors.white : null),
              );
            }).toList(),
          ),
          SizedBox(height: 24.h),

          // Brand Filter
          _buildSectionTitle('الماركة', isDark),
          SizedBox(height: 12.h),
          Wrap(
            spacing: 8.w,
            runSpacing: 8.h,
            children: _brands.map((brand) {
              final isSelected = _selectedBrand == brand;
              return ChoiceChip(
                label: Text(brand),
                selected: isSelected,
                onSelected: (selected) {
                  setState(() => _selectedBrand = selected ? brand : null);
                },
                selectedColor: AppColors.primary,
                labelStyle: TextStyle(color: isSelected ? Colors.white : null),
              );
            }).toList(),
          ),
          SizedBox(height: 24.h),

          // Toggle Options
          _buildSectionTitle('خيارات إضافية', isDark),
          SizedBox(height: 12.h),
          _buildToggleOption('متوفر في المخزون فقط', _inStockOnly, (val) {
            setState(() => _inStockOnly = val);
          }, isDark),
          _buildToggleOption('عروض فقط', _onSaleOnly, (val) {
            setState(() => _onSaleOnly = val);
          }, isDark),
          SizedBox(height: 32.h),

          // Action Buttons
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: _resetFilters,
                  child: Text('إعادة ضبط', style: TextStyle(fontSize: 14.sp)),
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                flex: 2,
                child: ElevatedButton.icon(
                  onPressed: _applyFilters,
                  icon: Icon(Iconsax.search_normal, size: 20.sp),
                  label: Text('بحث', style: TextStyle(fontSize: 16.sp)),
                ),
              ),
            ],
          ),
          SizedBox(height: 100.h),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title, bool isDark) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 16.sp,
        fontWeight: FontWeight.w600,
        color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
      ),
    );
  }

  Widget _buildToggleOption(
    String title,
    bool value,
    ValueChanged<bool> onChanged,
    bool isDark,
  ) {
    return Container(
      margin: EdgeInsets.only(bottom: 8.h),
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardDark : AppColors.cardLight,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 14.sp,
              color: isDark
                  ? AppColors.textPrimaryDark
                  : AppColors.textPrimaryLight,
            ),
          ),
          Switch.adaptive(
            value: value,
            onChanged: onChanged,
            activeThumbColor: AppColors.primary,
          ),
        ],
      ),
    );
  }

  void _resetFilters() {
    setState(() {
      _searchController.clear();
      _priceRange = const RangeValues(0, 2000);
      _selectedCategory = null;
      _selectedBrand = null;
      _inStockOnly = false;
      _onSaleOnly = false;
    });
  }

  void _applyFilters() {
    context.push(
      '/search-results',
      extra: {
        'query': _searchController.text,
        'minPrice': _priceRange.start,
        'maxPrice': _priceRange.end,
        'category': _selectedCategory,
        'brand': _selectedBrand,
        'inStock': _inStockOnly,
        'onSale': _onSaleOnly,
      },
    );
  }
}

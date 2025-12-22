/// Search Screen - Product search with filters
library;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax/iconsax.dart';
import '../../../../core/config/theme/app_colors.dart';
import '../../../../core/widgets/product_card.dart';
import '../../domain/entities/product_entity.dart';
import '../../data/datasources/catalog_mock_datasource.dart';
import '../../../../l10n/app_localizations.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _searchController = TextEditingController();
  final _focusNode = FocusNode();
  final _dataSource = CatalogMockDataSource();

  List<ProductEntity> _allProducts = [];
  List<ProductEntity> _searchResults = [];
  List<String> _recentSearches = ['شاشة آيفون', 'بطارية سامسونج', 'كابل شحن'];
  bool _isLoading = false;
  bool _hasSearched = false;

  @override
  void initState() {
    super.initState();
    _loadProducts();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  Future<void> _loadProducts() async {
    final products = await _dataSource.getFeaturedProducts();
    setState(() => _allProducts = products);
  }

  void _performSearch(String query) {
    if (query.isEmpty) {
      setState(() {
        _searchResults = [];
        _hasSearched = false;
      });
      return;
    }

    setState(() => _isLoading = true);

    // Simulate search delay
    Future.delayed(const Duration(milliseconds: 300), () {
      final results = _allProducts.where((product) {
        final name = (product.nameAr ?? product.name).toLowerCase();
        final sku = product.sku.toLowerCase();
        final q = query.toLowerCase();
        return name.contains(q) || sku.contains(q);
      }).toList();

      setState(() {
        _searchResults = results;
        _hasSearched = true;
        _isLoading = false;
      });

      // Add to recent searches
      if (!_recentSearches.contains(query) && query.length > 2) {
        _recentSearches.insert(0, query);
        if (_recentSearches.length > 5) {
          _recentSearches.removeLast();
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: isDark ? AppColors.surfaceDark : Colors.white,
        leading: IconButton(
          icon: const Icon(Iconsax.arrow_right_3),
          onPressed: () => context.pop(),
        ),
        title: _buildSearchField(theme, isDark),
        titleSpacing: 0,
      ),
      body: _buildBody(theme, isDark),
    );
  }

  Widget _buildSearchField(ThemeData theme, bool isDark) {
    return Container(
      margin: EdgeInsets.only(left: 16.w),
      child: TextField(
        controller: _searchController,
        focusNode: _focusNode,
        onChanged: _performSearch,
        onSubmitted: _performSearch,
        style: theme.textTheme.bodyLarge,
        decoration: InputDecoration(
          hintText: AppLocalizations.of(context)!.search,
          hintStyle: TextStyle(
            color: AppColors.textTertiaryLight,
            fontSize: 16.sp,
          ),
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
          filled: true,
          fillColor: isDark
              ? AppColors.backgroundDark
              : AppColors.backgroundLight,
          contentPadding: EdgeInsets.symmetric(
            horizontal: 16.w,
            vertical: 12.h,
          ),
          prefixIcon: Icon(
            Iconsax.search_normal,
            color: AppColors.textTertiaryLight,
            size: 20.sp,
          ),
          suffixIcon: _searchController.text.isNotEmpty
              ? IconButton(
                  icon: Icon(
                    Iconsax.close_circle5,
                    color: AppColors.textTertiaryLight,
                    size: 20.sp,
                  ),
                  onPressed: () {
                    _searchController.clear();
                    _performSearch('');
                    _focusNode.requestFocus();
                  },
                )
              : null,
        ),
      ),
    );
  }

  Widget _buildBody(ThemeData theme, bool isDark) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_hasSearched) {
      return _buildSearchResults(theme, isDark);
    }

    return _buildInitialContent(theme, isDark);
  }

  Widget _buildInitialContent(ThemeData theme, bool isDark) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Recent Searches
          if (_recentSearches.isNotEmpty) ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'عمليات البحث الأخيرة',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                TextButton(
                  onPressed: () {
                    setState(() => _recentSearches.clear());
                  },
                  child: Text(
                    'مسح الكل',
                    style: TextStyle(
                      color: AppColors.textTertiaryLight,
                      fontSize: 14.sp,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 12.h),
            Wrap(
              spacing: 8.w,
              runSpacing: 8.h,
              children: _recentSearches.map((search) {
                return _buildRecentSearchChip(search, theme, isDark);
              }).toList(),
            ),
            SizedBox(height: 32.h),
          ],

          // Popular Searches
          Text(
            'بحث شائع',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 12.h),
          _buildPopularSearches(theme, isDark),
        ],
      ),
    );
  }

  Widget _buildRecentSearchChip(String search, ThemeData theme, bool isDark) {
    return GestureDetector(
      onTap: () {
        _searchController.text = search;
        _performSearch(search);
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
        decoration: BoxDecoration(
          color: isDark ? AppColors.cardDark : AppColors.cardLight,
          borderRadius: BorderRadius.circular(20.r),
          border: Border.all(color: AppColors.dividerLight),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Iconsax.clock,
              size: 16.sp,
              color: AppColors.textTertiaryLight,
            ),
            SizedBox(width: 8.w),
            Text(search, style: theme.textTheme.bodyMedium),
          ],
        ),
      ),
    );
  }

  Widget _buildPopularSearches(ThemeData theme, bool isDark) {
    final popularSearches = [
      'شاشات آيفون',
      'بطاريات سامسونج',
      'كابلات شحن',
      'سماعات',
      'حافظات جوال',
      'قطع غيار هواوي',
    ];

    return Wrap(
      spacing: 8.w,
      runSpacing: 8.h,
      children: popularSearches.map((search) {
        return GestureDetector(
          onTap: () {
            _searchController.text = search;
            _performSearch(search);
            HapticFeedback.selectionClick();
          },
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(20.r),
            ),
            child: Text(
              search,
              style: TextStyle(
                color: AppColors.primary,
                fontSize: 14.sp,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildSearchResults(ThemeData theme, bool isDark) {
    if (_searchResults.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Iconsax.search_status,
              size: 80.sp,
              color: AppColors.textTertiaryLight,
            ),
            SizedBox(height: 16.h),
            Text(
              AppLocalizations.of(context)!.noResults,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              'جرب البحث بكلمات مختلفة',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: AppColors.textTertiaryLight,
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.all(16.w),
          child: Text(
            '${_searchResults.length} نتيجة',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: AppColors.textTertiaryLight,
            ),
          ),
        ),
        Expanded(
          child: GridView.builder(
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.65,
              crossAxisSpacing: 12.w,
              mainAxisSpacing: 12.h,
            ),
            itemCount: _searchResults.length,
            itemBuilder: (context, index) {
              final product = _searchResults[index];
              return ProductCard(
                id: product.id.toString(),
                name: product.name,
                nameAr: product.nameAr,
                imageUrl: product.imageUrl,
                price: product.price,
                originalPrice: product.originalPrice,
                stockQuantity: product.stockQuantity,
                onTap: () {
                  context.push('/product/${product.id}', extra: product);
                },
                onAddToCart: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(AppLocalizations.of(context)!.addedToCart),
                      backgroundColor: AppColors.success,
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
}

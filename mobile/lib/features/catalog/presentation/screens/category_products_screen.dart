/// Category Products Screen - Products filtered by category
library;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax/iconsax.dart';

import '../../../../core/config/theme/app_colors.dart';
import '../../../../core/mixins/product_favorites_mixin.dart';
import '../../../../core/widgets/widgets.dart';
import '../../../../l10n/app_localizations.dart';
import '../../domain/entities/product_entity.dart';
import '../../domain/repositories/catalog_repository.dart';
import '../widgets/category_products_sections.dart';

class CategoryProductsScreen extends StatefulWidget {
  final String categoryId;
  final String? categoryName;

  const CategoryProductsScreen({
    super.key,
    required this.categoryId,
    this.categoryName,
  });

  @override
  State<CategoryProductsScreen> createState() => _CategoryProductsScreenState();
}

class _CategoryProductsScreenState extends State<CategoryProductsScreen>
    with ProductFavoritesMixin<CategoryProductsScreen> {
  late final CatalogRepository _repository;
  final ScrollController _scrollController = ScrollController();

  List<ProductEntity> _products = [];
  bool _isLoading = true;
  bool _isLoadingMore = false;
  bool _hasMore = true;
  int _currentPage = 1;
  final int _limit = 20;
  Map<String, dynamic>? _pagination;
  String _sortBy = 'createdAt';
  String _sortOrder = 'desc';
  bool _isGridView = true;

  @override
  void initState() {
    super.initState();
    _repository = context.read<CatalogRepository>();
    _scrollController.addListener(_onScroll);
    _loadProducts();
    loadFavoriteProductIds();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      _loadMoreProducts();
    }
  }

  Future<void> _loadProducts() async {
    setState(() {
      _isLoading = true;
      _currentPage = 1;
      _products.clear();
      _hasMore = true;
    });

    try {
      final result = await _repository.getCategoryProducts(
        widget.categoryId,
        page: _currentPage,
        limit: _limit,
        sortBy: _sortBy,
        sortOrder: _sortOrder,
      );

      result.fold(
        (failure) {
          setState(() => _isLoading = false);
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(failure.message)));
        },
        (data) {
          final products = data['products'] as List<ProductEntity>;
          final pagination = data['pagination'] as Map<String, dynamic>?;

          setState(() {
            _products = products;
            _pagination = pagination;
            _hasMore = _currentPage < (pagination?['pages'] ?? 1);
            _isLoading = false;
          });
        },
      );
    } catch (error) {
      if (!mounted) return;

      setState(() => _isLoading = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('حدث خطأ: $error')));
    }
  }

  Future<void> _loadMoreProducts() async {
    if (_isLoadingMore || !_hasMore) return;

    setState(() => _isLoadingMore = true);
    _currentPage++;

    try {
      final result = await _repository.getCategoryProducts(
        widget.categoryId,
        page: _currentPage,
        limit: _limit,
        sortBy: _sortBy,
        sortOrder: _sortOrder,
      );

      result.fold(
        (failure) {
          setState(() {
            _isLoadingMore = false;
            _currentPage--;
          });
        },
        (data) {
          final products = data['products'] as List<ProductEntity>;
          final pagination = data['pagination'] as Map<String, dynamic>?;

          setState(() {
            _products.addAll(products);
            _pagination = pagination;
            _hasMore = _currentPage < (pagination?['pages'] ?? 1);
            _isLoadingMore = false;
          });
        },
      );
    } catch (_) {
      setState(() {
        _isLoadingMore = false;
        _currentPage--;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.categoryName ?? AppLocalizations.of(context)!.products,
        ),
        actions: [
          IconButton(
            onPressed: () => context.push('/search'),
            icon: Icon(Iconsax.search_normal, size: 22.sp),
          ),
          IconButton(
            onPressed: _showFilterSheet,
            icon: Icon(Iconsax.filter, size: 22.sp),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadProducts,
        child: Column(
          children: [
            CategoryProductsTopBar(
              productsCount: _pagination?['total'] ?? _products.length,
              sortLabel: _getSortLabel(),
              isGridView: _isGridView,
              onSortTap: _showSortOptions,
              onLayoutToggle: () {
                setState(() => _isGridView = !_isGridView);
              },
            ),
            Expanded(child: _buildBodyContent()),
          ],
        ),
      ),
    );
  }

  Widget _buildBodyContent() {
    if (_isLoading) {
      return const ProductsGridShimmer();
    }

    if (_products.isEmpty) {
      return const CategoryProductsEmptyState();
    }

    if (_isGridView) {
      return CategoryProductsGridView(
        controller: _scrollController,
        products: _products,
        isLoadingMore: _isLoadingMore,
        isFavorite: isProductFavorite,
        onProductTap: _openProduct,
        onToggleFavorite: (product) => toggleFavoriteProduct(product.id),
      );
    }

    return CategoryProductsListView(
      controller: _scrollController,
      products: _products,
      isLoadingMore: _isLoadingMore,
      onProductTap: _openProduct,
    );
  }

  void _openProduct(ProductEntity product) {
    context.push('/product/${product.id}', extra: product);
  }

  String _getSortLabel() {
    switch (_sortBy) {
      case 'createdAt':
        return _sortOrder == 'desc' ? 'الأحدث' : 'الأقدم';
      case 'price':
        return _sortOrder == 'asc' ? 'السعر: الأقل' : 'السعر: الأعلى';
      case 'name':
        return 'الاسم';
      case 'ordersCount':
        return 'الأكثر مبيعاً';
      default:
        return 'ترتيب';
    }
  }

  void _showSortOptions() {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showModalBottomSheet(
      context: context,
      backgroundColor: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      builder: (sheetContext) => CategoryProductsSortSheet(
        currentSortBy: _sortBy,
        currentSortOrder: _sortOrder,
        onSelect: (sortBy, sortOrder) {
          setState(() {
            _sortBy = sortBy;
            _sortOrder = sortOrder;
          });
          Navigator.pop(sheetContext);
          _loadProducts();
        },
      ),
    );
  }

  void _showFilterSheet() {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      builder: (sheetContext) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.9,
        expand: false,
        builder: (context, scrollController) => CategoryProductsFilterSheet(
          onReset: () => Navigator.pop(sheetContext),
          onApply: () => Navigator.pop(sheetContext),
        ),
      ),
    );
  }
}

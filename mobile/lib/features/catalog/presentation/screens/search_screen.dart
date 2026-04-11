library;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax/iconsax.dart';

import '../../../../core/config/theme/app_colors.dart';
import '../../../../core/mixins/product_favorites_mixin.dart';
import '../../../../core/widgets/widgets.dart';
import '../../data/datasources/catalog_remote_datasource.dart';
import '../../domain/entities/product_entity.dart';
import '../controllers/catalog_search_coordinator.dart';
import '../widgets/search_sections.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen>
    with ProductFavoritesMixin<SearchScreen> {
  late final CatalogSearchCoordinator _coordinator;

  @override
  void initState() {
    super.initState();
    _coordinator = CatalogSearchCoordinator(
      dataSource: context.read<CatalogRemoteDataSource>(),
    );
    _coordinator.initialize();
    loadFavoriteProductIds();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _coordinator.requestFocus();
    });
  }

  @override
  void dispose() {
    _coordinator.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return AnimatedBuilder(
      animation: _coordinator,
      builder: (context, _) {
        return Scaffold(
          backgroundColor: theme.scaffoldBackgroundColor,
          appBar: AppBar(
            backgroundColor: isDark ? AppColors.surfaceDark : Colors.white,
            leading: IconButton(
              icon: const Icon(Iconsax.arrow_right_3),
              onPressed: () => context.pop(),
            ),
            title: SearchFieldBar(
              controller: _coordinator.searchController,
              focusNode: _coordinator.focusNode,
              isDark: isDark,
              onChanged: _coordinator.onQueryChanged,
              onSubmitted: _coordinator.submitSearch,
              onClear: () {
                _coordinator.clearSearch();
                _coordinator.requestFocus();
              },
            ),
            titleSpacing: 0,
          ),
          body: Stack(
            children: [
              _buildBody(),
              if (_coordinator.showSuggestions && !_coordinator.hasSearched)
                SearchAutocompleteOverlay(
                  suggestions: _coordinator.autocompleteSuggestions,
                  isDark: isDark,
                  onSuggestionTap: (suggestion) {
                    _coordinator.selectQuery(suggestion);
                  },
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildBody() {
    if (_coordinator.isLoading) {
      return const SearchResultsShimmer();
    }

    if (_coordinator.hasSearched) {
      return SearchResultsView(
        products: _coordinator.searchResults,
        isFavorite: isProductFavorite,
        onToggleFavorite: toggleFavoriteProduct,
        onProductTap: _openProduct,
        onAddToCart: _showAddToCartFeedback,
      );
    }

    return SearchInitialContent(
      recentSearches: _coordinator.recentSearches,
      popularTags: _coordinator.popularTags,
      onClearRecent: _coordinator.clearRecentSearches,
      onQueryTap: (query) {
        _coordinator.selectQuery(query);
        HapticFeedback.selectionClick();
      },
    );
  }

  void _openProduct(ProductEntity product) {
    context.push('/product/${product.id}', extra: product);
  }

  void _showAddToCartFeedback(ProductEntity _) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('تمت إضافة المنتج إلى السلة'),
        backgroundColor: AppColors.success,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.r),
        ),
      ),
    );
  }
}

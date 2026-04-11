import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/widgets/widgets.dart';
import '../../domain/entities/product_entity.dart';
import 'products_list_sections_states.dart';

class ProductsGridSection extends StatelessWidget {
  final ScrollController scrollController;
  final List<ProductEntity> products;
  final bool isLoadingMore;
  final bool Function(String productId) isProductFavorite;
  final void Function(ProductEntity product) onProductTap;
  final void Function(ProductEntity product) onToggleFavorite;

  const ProductsGridSection({
    super.key,
    required this.scrollController,
    required this.products,
    required this.isLoadingMore,
    required this.isProductFavorite,
    required this.onProductTap,
    required this.onToggleFavorite,
  });

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      key: const ValueKey('products-grid'),
      controller: scrollController,
      padding: EdgeInsets.all(16.w),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 12.h,
        crossAxisSpacing: 12.w,
        childAspectRatio: 0.60,
      ),
      itemCount: products.length + (isLoadingMore ? 1 : 0),
      itemBuilder: (context, index) {
        if (index >= products.length) {
          return const ProductsLoadMoreIndicator();
        }

        final product = products[index];
        return ProductCard(
          id: product.id.toString(),
          name: product.name,
          nameAr: product.nameAr,
          imageUrl: product.imageUrl,
          price: product.price,
          originalPrice: product.originalPrice,
          stockQuantity: product.stockQuantity,
          isFavorite: isProductFavorite(product.id),
          onTap: () => onProductTap(product),
          onToggleFavorite: () => onToggleFavorite(product),
        );
      },
    );
  }
}

class ProductsListSection extends StatelessWidget {
  final ScrollController scrollController;
  final List<ProductEntity> products;
  final bool isLoadingMore;
  final bool Function(String productId) isProductFavorite;
  final void Function(ProductEntity product) onProductTap;
  final void Function(ProductEntity product) onToggleFavorite;

  const ProductsListSection({
    super.key,
    required this.scrollController,
    required this.products,
    required this.isLoadingMore,
    required this.isProductFavorite,
    required this.onProductTap,
    required this.onToggleFavorite,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      key: const ValueKey('products-list'),
      controller: scrollController,
      padding: EdgeInsets.all(16.w),
      itemCount: products.length + (isLoadingMore ? 1 : 0),
      separatorBuilder: (context, index) => SizedBox(height: 12.h),
      itemBuilder: (context, index) {
        if (index >= products.length) {
          return const ProductsLoadMoreIndicator();
        }

        final product = products[index];
        return ProductListItem(
          id: product.id,
          title: product.nameAr,
          imageUrl: product.imageUrl,
          price: product.price,
          originalPrice: product.originalPrice,
          isFavorite: isProductFavorite(product.id),
          onTap: () => onProductTap(product),
          onToggleFavorite: () => onToggleFavorite(product),
        );
      },
    );
  }
}

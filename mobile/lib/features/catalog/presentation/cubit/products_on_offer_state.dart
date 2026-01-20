/// Products On Offer State - States for products on offer feature
library;

import 'package:equatable/equatable.dart';
import '../../domain/entities/product_entity.dart';

/// Base state for products on offer
abstract class ProductsOnOfferState extends Equatable {
  const ProductsOnOfferState();

  @override
  List<Object?> get props => [];
}

/// Initial state
class ProductsOnOfferInitial extends ProductsOnOfferState {
  const ProductsOnOfferInitial();
}

/// Loading state
class ProductsOnOfferLoading extends ProductsOnOfferState {
  const ProductsOnOfferLoading();
}

/// Loaded state with products
class ProductsOnOfferLoaded extends ProductsOnOfferState {
  final List<ProductEntity> products;
  final bool hasMore;
  final int currentPage;
  final int totalPages;

  const ProductsOnOfferLoaded({
    required this.products,
    required this.hasMore,
    required this.currentPage,
    required this.totalPages,
  });

  @override
  List<Object?> get props => [products, hasMore, currentPage, totalPages];

  ProductsOnOfferLoaded copyWith({
    List<ProductEntity>? products,
    bool? hasMore,
    int? currentPage,
    int? totalPages,
  }) {
    return ProductsOnOfferLoaded(
      products: products ?? this.products,
      hasMore: hasMore ?? this.hasMore,
      currentPage: currentPage ?? this.currentPage,
      totalPages: totalPages ?? this.totalPages,
    );
  }
}

/// Error state
class ProductsOnOfferError extends ProductsOnOfferState {
  final String message;

  const ProductsOnOfferError(this.message);

  @override
  List<Object?> get props => [message];
}

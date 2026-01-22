/// Home Cubit State
library;

import 'package:equatable/equatable.dart';
import '../../../catalog/domain/entities/brand_entity.dart';
import '../../../catalog/domain/entities/category_entity.dart';
import '../../../catalog/domain/entities/product_entity.dart';

abstract class HomeState extends Equatable {
  const HomeState();

  @override
  List<Object?> get props => [];
}

class HomeInitial extends HomeState {
  const HomeInitial();
}

class HomeLoading extends HomeState {
  const HomeLoading();
}

class HomeLoaded extends HomeState {
  final List<CategoryEntity> categories;
  final List<BrandEntity> brands;
  final List<ProductEntity> featuredProducts;
  final List<ProductEntity> newArrivals;
  final List<ProductEntity> bestSellers;

  const HomeLoaded({
    this.categories = const [],
    this.brands = const [],
    this.featuredProducts = const [],
    this.newArrivals = const [],
    this.bestSellers = const [],
  });

  HomeLoaded copyWith({
    List<CategoryEntity>? categories,
    List<BrandEntity>? brands,
    List<ProductEntity>? featuredProducts,
    List<ProductEntity>? newArrivals,
    List<ProductEntity>? bestSellers,
  }) {
    return HomeLoaded(
      categories: categories ?? this.categories,
      brands: brands ?? this.brands,
      featuredProducts: featuredProducts ?? this.featuredProducts,
      newArrivals: newArrivals ?? this.newArrivals,
      bestSellers: bestSellers ?? this.bestSellers,
    );
  }

  @override
  List<Object?> get props => [
    categories,
    brands,
    featuredProducts,
    newArrivals,
    bestSellers,
  ];
}

class HomeError extends HomeState {
  final String message;

  const HomeError(this.message);

  @override
  List<Object?> get props => [message];
}

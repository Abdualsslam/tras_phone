/// Categories State - State classes for CategoriesCubit
library;

import 'package:equatable/equatable.dart';
import '../../domain/entities/category_entity.dart';

/// Base state for categories list
sealed class CategoriesState extends Equatable {
  const CategoriesState();

  @override
  List<Object?> get props => [];
}

class CategoriesInitial extends CategoriesState {
  const CategoriesInitial();
}

class CategoriesLoading extends CategoriesState {
  const CategoriesLoading();
}

class CategoriesLoaded extends CategoriesState {
  final List<CategoryEntity> categories;

  const CategoriesLoaded(this.categories);

  @override
  List<Object?> get props => [categories];
}

class CategoriesError extends CategoriesState {
  final String message;

  const CategoriesError(this.message);

  @override
  List<Object?> get props => [message];
}

/// State for category tree
sealed class CategoryTreeState extends Equatable {
  const CategoryTreeState();

  @override
  List<Object?> get props => [];
}

class CategoryTreeInitial extends CategoryTreeState {
  const CategoryTreeInitial();
}

class CategoryTreeLoading extends CategoryTreeState {
  const CategoryTreeLoading();
}

class CategoryTreeLoaded extends CategoryTreeState {
  final List<CategoryEntity> tree;

  const CategoryTreeLoaded(this.tree);

  @override
  List<Object?> get props => [tree];
}

class CategoryTreeError extends CategoryTreeState {
  final String message;

  const CategoryTreeError(this.message);

  @override
  List<Object?> get props => [message];
}

/// State for single category with breadcrumb
sealed class CategoryDetailsState extends Equatable {
  const CategoryDetailsState();

  @override
  List<Object?> get props => [];
}

class CategoryDetailsInitial extends CategoryDetailsState {
  const CategoryDetailsInitial();
}

class CategoryDetailsLoading extends CategoryDetailsState {
  const CategoryDetailsLoading();
}

class CategoryDetailsLoaded extends CategoryDetailsState {
  final CategoryWithBreadcrumb categoryWithBreadcrumb;

  const CategoryDetailsLoaded(this.categoryWithBreadcrumb);

  CategoryEntity get category => categoryWithBreadcrumb.category;
  List<BreadcrumbItem> get breadcrumb => categoryWithBreadcrumb.breadcrumb;

  @override
  List<Object?> get props => [categoryWithBreadcrumb];
}

class CategoryDetailsError extends CategoryDetailsState {
  final String message;

  const CategoryDetailsError(this.message);

  @override
  List<Object?> get props => [message];
}

/// State for category children
sealed class CategoryChildrenState extends Equatable {
  const CategoryChildrenState();

  @override
  List<Object?> get props => [];
}

class CategoryChildrenInitial extends CategoryChildrenState {
  const CategoryChildrenInitial();
}

class CategoryChildrenLoading extends CategoryChildrenState {
  const CategoryChildrenLoading();
}

class CategoryChildrenLoaded extends CategoryChildrenState {
  final List<CategoryEntity> children;

  const CategoryChildrenLoaded(this.children);

  @override
  List<Object?> get props => [children];
}

class CategoryChildrenError extends CategoryChildrenState {
  final String message;

  const CategoryChildrenError(this.message);

  @override
  List<Object?> get props => [message];
}

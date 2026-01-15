/// Categories Cubit - Manages categories state
library;

import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/repositories/catalog_repository.dart';
import 'categories_state.dart';

/// Cubit for managing root categories list
class CategoriesCubit extends Cubit<CategoriesState> {
  final CatalogRepository _repository;

  CategoriesCubit({required CatalogRepository repository})
      : _repository = repository,
        super(const CategoriesInitial());

  /// Load root categories
  Future<void> loadCategories() async {
    emit(const CategoriesLoading());

    final result = await _repository.getRootCategories();

    result.fold(
      (failure) => emit(CategoriesError(failure.message)),
      (categories) => emit(CategoriesLoaded(categories)),
    );
  }
}

/// Cubit for managing category tree
class CategoryTreeCubit extends Cubit<CategoryTreeState> {
  final CatalogRepository _repository;

  CategoryTreeCubit({required CatalogRepository repository})
      : _repository = repository,
        super(const CategoryTreeInitial());

  /// Load full category tree
  Future<void> loadCategoryTree() async {
    emit(const CategoryTreeLoading());

    final result = await _repository.getCategoryTree();

    result.fold(
      (failure) => emit(CategoryTreeError(failure.message)),
      (tree) => emit(CategoryTreeLoaded(tree)),
    );
  }
}

/// Cubit for managing single category details with breadcrumb
class CategoryDetailsCubit extends Cubit<CategoryDetailsState> {
  final CatalogRepository _repository;

  CategoryDetailsCubit({required CatalogRepository repository})
      : _repository = repository,
        super(const CategoryDetailsInitial());

  /// Load category by ID with breadcrumb
  Future<void> loadCategory(String id) async {
    emit(const CategoryDetailsLoading());

    final result = await _repository.getCategoryById(id);

    result.fold(
      (failure) => emit(CategoryDetailsError(failure.message)),
      (categoryWithBreadcrumb) =>
          emit(CategoryDetailsLoaded(categoryWithBreadcrumb)),
    );
  }
}

/// Cubit for managing category children
class CategoryChildrenCubit extends Cubit<CategoryChildrenState> {
  final CatalogRepository _repository;

  CategoryChildrenCubit({required CatalogRepository repository})
      : _repository = repository,
        super(const CategoryChildrenInitial());

  /// Load children of a category
  Future<void> loadChildren(String parentId) async {
    emit(const CategoryChildrenLoading());

    final result = await _repository.getCategoryChildren(parentId);

    result.fold(
      (failure) => emit(CategoryChildrenError(failure.message)),
      (children) => emit(CategoryChildrenLoaded(children)),
    );
  }
}

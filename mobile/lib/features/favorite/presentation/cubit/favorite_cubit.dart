/// Favorite Cubit - Manages favorite state
library;

import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/datasources/favorite_remote_datasource.dart';
import 'favorite_state.dart';

/// Cubit for managing favorites
class FavoriteCubit extends Cubit<FavoriteState> {
  final FavoriteRemoteDataSource _dataSource;

  FavoriteCubit({required FavoriteRemoteDataSource dataSource})
    : _dataSource = dataSource,
      super(const FavoriteInitial());

  /// Load favorite items
  Future<void> loadFavorites() async {
    if (isClosed) return;
    emit(const FavoriteLoading());

    try {
      final items = await _dataSource.getFavorites();
      if (isClosed) return;
      emit(FavoriteLoaded(items));
    } catch (e) {
      if (isClosed) return;
      emit(FavoriteError(e.toString()));
    }
  }

  /// Add product to favorites
  Future<void> addToFavorites(String productId) async {
    try {
      await _dataSource.addToFavorites(productId);
      if (!isClosed) {
        loadFavorites();
      }
    } catch (e) {
      if (isClosed) return;
      emit(FavoriteError(e.toString()));
      if (!isClosed) {
        loadFavorites();
      }
    }
  }

  /// Remove product from favorites
  Future<void> removeFromFavorites(String productId) async {
    try {
      await _dataSource.removeFromFavorites(productId);
      if (!isClosed) {
        loadFavorites();
      }
    } catch (e) {
      if (isClosed) return;
      emit(FavoriteError(e.toString()));
      if (!isClosed) {
        loadFavorites();
      }
    }
  }

  /// Toggle favorite status
  Future<void> toggleFavorite(String productId) async {
    final currentState = state;
    bool isFavorite = false;

    if (currentState is FavoriteLoaded) {
      isFavorite = currentState.items.any(
        (item) => item.productId.toString() == productId,
      );
    }

    try {
      await _dataSource.toggleFavorite(productId, isFavorite);
      if (!isClosed) {
        loadFavorites();
      }
    } catch (e) {
      if (isClosed) return;
      emit(FavoriteError(e.toString()));
      if (!isClosed) {
        loadFavorites();
      }
    }
  }

  /// Clear entire favorites
  Future<void> clearFavorites() async {
    try {
      await _dataSource.clearFavorites();
      if (isClosed) return;
      emit(const FavoriteLoaded([]));
    } catch (e) {
      if (isClosed) return;
      emit(FavoriteError(e.toString()));
    }
  }
}

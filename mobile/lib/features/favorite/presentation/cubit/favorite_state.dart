/// Favorite State - States for favorite feature
library;

import 'package:equatable/equatable.dart';
import '../../data/models/favorite_item_model.dart';

/// Base state for favorite
abstract class FavoriteState extends Equatable {
  const FavoriteState();

  @override
  List<Object?> get props => [];
}

/// Initial state
class FavoriteInitial extends FavoriteState {
  const FavoriteInitial();
}

/// Loading state
class FavoriteLoading extends FavoriteState {
  const FavoriteLoading();
}

/// Loaded state with favorite items
class FavoriteLoaded extends FavoriteState {
  final List<FavoriteItemModel> items;

  const FavoriteLoaded(this.items);

  @override
  List<Object?> get props => [items];
}

/// Error state
class FavoriteError extends FavoriteState {
  final String message;

  const FavoriteError(this.message);

  @override
  List<Object?> get props => [message];
}

/// Favorite count state
class FavoriteCountState extends Equatable {
  final int count;

  const FavoriteCountState(this.count);

  @override
  List<Object?> get props => [count];
}

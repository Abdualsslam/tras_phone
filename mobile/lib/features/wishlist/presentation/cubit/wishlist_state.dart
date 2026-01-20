/// Wishlist State - States for wishlist feature
library;

import 'package:equatable/equatable.dart';
import '../../data/models/wishlist_item_model.dart';

/// Base state for wishlist
abstract class WishlistState extends Equatable {
  const WishlistState();

  @override
  List<Object?> get props => [];
}

/// Initial state
class WishlistInitial extends WishlistState {
  const WishlistInitial();
}

/// Loading state
class WishlistLoading extends WishlistState {
  const WishlistLoading();
}

/// Loaded state with wishlist items
class WishlistLoaded extends WishlistState {
  final List<WishlistItemModel> items;

  const WishlistLoaded(this.items);

  @override
  List<Object?> get props => [items];
}

/// Error state
class WishlistError extends WishlistState {
  final String message;

  const WishlistError(this.message);

  @override
  List<Object?> get props => [message];
}

/// Wishlist count state
class WishlistCountState extends Equatable {
  final int count;

  const WishlistCountState(this.count);

  @override
  List<Object?> get props => [count];
}

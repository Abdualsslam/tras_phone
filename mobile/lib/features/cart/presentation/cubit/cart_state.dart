/// Cart State - State classes for CartCubit
library;

import 'package:equatable/equatable.dart';
import '../../domain/entities/cart_entity.dart';
import '../../domain/entities/cart_sync_result_entity.dart';

abstract class CartState extends Equatable {
  const CartState();

  @override
  List<Object?> get props => [];
}

class CartInitial extends CartState {
  const CartInitial();
}

class CartLoading extends CartState {
  const CartLoading();
}

class CartLoaded extends CartState {
  final CartEntity cart;

  const CartLoaded(this.cart);

  @override
  List<Object?> get props => [cart];
}

class CartUpdating extends CartState {
  final CartEntity cart;

  const CartUpdating(this.cart);

  @override
  List<Object?> get props => [cart];
}

class CartError extends CartState {
  final String message;
  final CartEntity? previousCart;

  const CartError(this.message, {this.previousCart});

  @override
  List<Object?> get props => [message, previousCart];
}

class CartSyncing extends CartState {
  final CartEntity? currentCart;

  const CartSyncing({this.currentCart});

  @override
  List<Object?> get props => [currentCart];
}

class CartSyncCompleted extends CartState {
  final CartSyncResultEntity syncResult;

  const CartSyncCompleted(this.syncResult);

  @override
  List<Object?> get props => [syncResult];
}

class CartSyncError extends CartState {
  final String message;
  final CartSyncResultEntity? partialSyncResult;

  const CartSyncError(this.message, {this.partialSyncResult});

  @override
  List<Object?> get props => [message, partialSyncResult];
}

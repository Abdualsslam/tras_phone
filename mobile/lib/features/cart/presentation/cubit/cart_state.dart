/// Cart State - State classes for CartCubit
library;

import 'package:equatable/equatable.dart';
import '../../domain/entities/cart_entity.dart';

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

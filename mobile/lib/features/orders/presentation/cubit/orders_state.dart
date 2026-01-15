/// Orders Cubit State - State classes for OrdersCubit
library;

import 'package:equatable/equatable.dart';
import '../../domain/entities/order_entity.dart';
import '../../domain/enums/order_enums.dart';

abstract class OrdersState extends Equatable {
  const OrdersState();

  @override
  List<Object?> get props => [];
}

class OrdersInitial extends OrdersState {
  const OrdersInitial();
}

class OrdersLoading extends OrdersState {
  const OrdersLoading();
}

class OrdersLoaded extends OrdersState {
  final List<OrderEntity> orders;
  final int total;
  final OrderStatus? filterStatus;

  const OrdersLoaded(this.orders, {this.total = 0, this.filterStatus});

  @override
  List<Object?> get props => [orders, total, filterStatus];
}

class OrdersError extends OrdersState {
  final String message;

  const OrdersError(this.message);

  @override
  List<Object?> get props => [message];
}

/// Orders Cubit State - State classes for OrdersCubit
library;

import 'package:equatable/equatable.dart';
import '../../domain/entities/order_entity.dart';
import '../../domain/entities/order_stats_entity.dart';
import '../../domain/entities/bank_account_entity.dart';
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
  final OrderStatsEntity? stats;

  const OrdersLoaded(this.orders,
      {this.total = 0, this.filterStatus, this.stats});

  @override
  List<Object?> get props => [orders, total, filterStatus, stats];
}

class OrdersError extends OrdersState {
  final String message;

  const OrdersError(this.message);

  @override
  List<Object?> get props => [message];
}

class OrdersStatsLoaded extends OrdersState {
  final OrderStatsEntity stats;

  const OrdersStatsLoaded(this.stats);

  @override
  List<Object?> get props => [stats];
}

class OrdersPendingPaymentLoaded extends OrdersState {
  final List<OrderEntity> orders;

  const OrdersPendingPaymentLoaded(this.orders);

  @override
  List<Object?> get props => [orders];
}

class BankAccountsLoaded extends OrdersState {
  final List<BankAccountEntity> accounts;

  const BankAccountsLoaded(this.accounts);

  @override
  List<Object?> get props => [accounts];
}

class OrderReceiptUploading extends OrdersState {
  final String orderId;

  const OrderReceiptUploading(this.orderId);

  @override
  List<Object?> get props => [orderId];
}

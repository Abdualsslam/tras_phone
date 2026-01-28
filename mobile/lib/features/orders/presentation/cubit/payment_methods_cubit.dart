/// Payment Methods Cubit - State management for payment methods
library;

import 'dart:developer' as developer;
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/datasources/orders_remote_datasource.dart';
import '../../data/models/payment_method_model.dart';
import 'payment_methods_state.dart';

/// Cubit for managing payment methods
class PaymentMethodsCubit extends Cubit<PaymentMethodsState> {
  final OrdersRemoteDataSource _dataSource;

  PaymentMethodsCubit({required OrdersRemoteDataSource dataSource})
    : _dataSource = dataSource,
      super(const PaymentMethodsInitial());

  /// Load payment methods
  Future<void> loadPaymentMethods() async {
    emit(const PaymentMethodsLoading());
    try {
      final response = await _dataSource.getPaymentMethods();

      // Convert Map to PaymentMethodModel then to Entity
      final paymentMethods =
          response
              .map((json) => PaymentMethodModel.fromJson(json))
              .where((model) => model.isActive) // Filter only active methods
              .map((model) => model.toEntity())
              .toList()
            ..sort(
              (a, b) => a.sortOrder.compareTo(b.sortOrder),
            ); // Sort by sortOrder

      emit(PaymentMethodsLoaded(paymentMethods));
    } catch (e) {
      developer.log(
        'Error loading payment methods: $e',
        name: 'PaymentMethodsCubit',
      );
      emit(PaymentMethodsError(e.toString()));
    }
  }
}

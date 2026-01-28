/// Payment Methods Cubit - State management for payment methods
library;

import 'dart:developer' as developer;
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/datasources/orders_remote_datasource.dart';
import '../../data/models/payment_method_model.dart';
import '../../domain/entities/payment_method_entity.dart';
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

      // Print raw API response to terminal
      _printPaymentMethodsRaw(response);

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

      // Print parsed payment methods to terminal
      _printPaymentMethodsParsed(paymentMethods);

      emit(PaymentMethodsLoaded(paymentMethods));
    } catch (e) {
      developer.log(
        'Error loading payment methods: $e',
        name: 'PaymentMethodsCubit',
      );
      emit(PaymentMethodsError(e.toString()));
    }
  }

  /// Print raw API response to terminal
  void _printPaymentMethodsRaw(List<Map<String, dynamic>> response) {
    final separator = List.filled(80, '=').join();
    print('\n$separator');
    print(
      '💳 PAYMENT METHODS - Raw API Response (طرق الدفع - الاستجابة الخام)',
    );
    print(separator);
    print('Count: ${response.length}');
    for (var i = 0; i < response.length; i++) {
      print('\n--- Method ${i + 1} ---');
      response[i].forEach((key, value) {
        print('  $key: $value');
      });
    }
    print('\n$separator\n');
  }

  /// Print parsed payment methods (entities) to terminal
  void _printPaymentMethodsParsed(List<PaymentMethodEntity> paymentMethods) {
    final separator = List.filled(80, '=').join();
    print('\n$separator');
    print('💳 PAYMENT METHODS - Parsed (طرق الدفع - بعد المعالجة)');
    print(separator);
    print('Active count: ${paymentMethods.length}');
    for (var i = 0; i < paymentMethods.length; i++) {
      final m = paymentMethods[i];
      print('\n--- ${i + 1}. ${m.nameAr} / ${m.nameEn} ---');
      print('  id: ${m.id}');
      print('  nameAr: ${m.nameAr}');
      print('  nameEn: ${m.nameEn}');
      print('  type: ${m.type}');
      print('  descriptionAr: ${m.descriptionAr}');
      print('  descriptionEn: ${m.descriptionEn}');
      print('  icon: ${m.icon}');
      print('  logo: ${m.logo}');
      print('  isActive: ${m.isActive}');
      print('  sortOrder: ${m.sortOrder}');
      print('  orderPaymentMethodValue: ${m.orderPaymentMethodValue}');
      if (m.bankDetails != null && m.bankDetails!.isNotEmpty) {
        print('  bankDetails: ${m.bankDetails}');
      }
    }
    print('\n$separator\n');
  }
}

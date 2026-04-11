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

      _logPaymentMethodsRaw(response);

      final paymentMethods =
          response
              .map(PaymentMethodModel.fromJson)
              .where((model) => model.isActive)
              .map((model) => model.toEntity())
              .toList()
            ..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));

      _logPaymentMethodsParsed(paymentMethods);

      emit(PaymentMethodsLoaded(paymentMethods));
    } catch (e) {
      developer.log(
        'Error loading payment methods: $e',
        name: 'PaymentMethodsCubit',
      );
      emit(PaymentMethodsError(e.toString()));
    }
  }

  void _logPaymentMethodsRaw(List<Map<String, dynamic>> response) {
    final separator = List.filled(80, '=').join();
    final buffer = StringBuffer()
      ..writeln('\n$separator')
      ..writeln('PAYMENT METHODS - Raw API Response')
      ..writeln('طرق الدفع - الاستجابة الخام')
      ..writeln(separator)
      ..writeln('Count: ${response.length}');

    for (var i = 0; i < response.length; i++) {
      buffer.writeln('\n--- Method ${i + 1} ---');
      response[i].forEach((key, value) {
        buffer.writeln('  $key: $value');
      });
    }

    buffer.writeln('\n$separator\n');
    developer.log(buffer.toString(), name: 'PaymentMethodsCubit');
  }

  void _logPaymentMethodsParsed(List<PaymentMethodEntity> paymentMethods) {
    final separator = List.filled(80, '=').join();
    final buffer = StringBuffer()
      ..writeln('\n$separator')
      ..writeln('PAYMENT METHODS - Parsed')
      ..writeln('طرق الدفع - بعد المعالجة')
      ..writeln(separator)
      ..writeln('Active count: ${paymentMethods.length}');

    for (var i = 0; i < paymentMethods.length; i++) {
      final paymentMethod = paymentMethods[i];
      buffer.writeln(
        '\n--- ${i + 1}. ${paymentMethod.nameAr} / ${paymentMethod.nameEn} ---',
      );
      buffer.writeln('  id: ${paymentMethod.id}');
      buffer.writeln('  nameAr: ${paymentMethod.nameAr}');
      buffer.writeln('  nameEn: ${paymentMethod.nameEn}');
      buffer.writeln('  type: ${paymentMethod.type}');
      buffer.writeln('  descriptionAr: ${paymentMethod.descriptionAr}');
      buffer.writeln('  descriptionEn: ${paymentMethod.descriptionEn}');
      buffer.writeln('  icon: ${paymentMethod.icon}');
      buffer.writeln('  logo: ${paymentMethod.logo}');
      buffer.writeln('  isActive: ${paymentMethod.isActive}');
      buffer.writeln('  sortOrder: ${paymentMethod.sortOrder}');
      buffer.writeln(
        '  orderPaymentMethodValue: ${paymentMethod.orderPaymentMethodValue}',
      );
      if (paymentMethod.bankDetails != null &&
          paymentMethod.bankDetails!.isNotEmpty) {
        buffer.writeln('  bankDetails: ${paymentMethod.bankDetails}');
      }
    }

    buffer.writeln('\n$separator\n');
    developer.log(buffer.toString(), name: 'PaymentMethodsCubit');
  }
}

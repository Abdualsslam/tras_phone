/// Payment Methods State - State classes for PaymentMethodsCubit
library;

import '../../domain/entities/payment_method_entity.dart';

/// Base state for payment methods
abstract class PaymentMethodsState {
  const PaymentMethodsState();
}

/// Initial state
class PaymentMethodsInitial extends PaymentMethodsState {
  const PaymentMethodsInitial();
}

/// Loading state
class PaymentMethodsLoading extends PaymentMethodsState {
  const PaymentMethodsLoading();
}

/// Payment methods loaded successfully
class PaymentMethodsLoaded extends PaymentMethodsState {
  final List<PaymentMethodEntity> paymentMethods;

  const PaymentMethodsLoaded(this.paymentMethods);
}

/// Payment methods error state
class PaymentMethodsError extends PaymentMethodsState {
  final String message;

  const PaymentMethodsError(this.message);
}

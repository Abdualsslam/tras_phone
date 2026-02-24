import 'package:equatable/equatable.dart';

/// Customer basic info for checkout
class CheckoutCustomerEntity extends Equatable {
  final String id;
  final String? name;
  final String? phone;
  final String? priceLevelId;
  final double walletBalance;

  const CheckoutCustomerEntity({
    required this.id,
    this.name,
    this.phone,
    this.priceLevelId,
    this.walletBalance = 0,
  });

  @override
  List<Object?> get props => [id, name, phone, priceLevelId, walletBalance];
}

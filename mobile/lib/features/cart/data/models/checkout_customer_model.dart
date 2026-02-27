import '../../domain/entities/checkout_customer_entity.dart';

/// Customer basic info for checkout
class CheckoutCustomerModel {
  final String id;
  final String? name;
  final String? phone;
  final String? priceLevelId;
  final double walletBalance;

  const CheckoutCustomerModel({
    required this.id,
    this.name,
    this.phone,
    this.priceLevelId,
    this.walletBalance = 0,
  });

  factory CheckoutCustomerModel.fromJson(Map<String, dynamic> json) {
    return CheckoutCustomerModel(
      id: json['id']?.toString() ?? '',
      name: json['name'],
      phone: json['phone'],
      priceLevelId: json['priceLevelId'],
      walletBalance: (json['walletBalance'] as num?)?.toDouble() ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'phone': phone,
    'priceLevelId': priceLevelId,
    'walletBalance': walletBalance,
  };

  CheckoutCustomerEntity toEntity() {
    return CheckoutCustomerEntity(
      id: id,
      name: name,
      phone: phone,
      priceLevelId: priceLevelId,
      walletBalance: walletBalance,
    );
  }
}

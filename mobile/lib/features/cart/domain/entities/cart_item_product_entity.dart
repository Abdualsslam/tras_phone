import 'package:equatable/equatable.dart';

/// Product details in cart item
class CartItemProductEntity extends Equatable {
  final String name;
  final String nameAr;
  final String? image;
  final String sku;
  final bool isActive;
  final int stockQuantity;

  const CartItemProductEntity({
    required this.name,
    required this.nameAr,
    this.image,
    required this.sku,
    required this.isActive,
    required this.stockQuantity,
  });

  /// Get localized name
  String getName(String locale) =>
      locale == 'ar' && nameAr.isNotEmpty ? nameAr : name;

  @override
  List<Object?> get props => [
    name,
    nameAr,
    image,
    sku,
    isActive,
    stockQuantity,
  ];
}

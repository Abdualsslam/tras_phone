import '../../domain/entities/checkout_cart_entity.dart';
import 'checkout_cart_item_model.dart';

/// Cart with populated product details
class CheckoutCartModel {
  final String id;
  final String customerId;
  final String status;
  final List<CheckoutCartItemModel> items;
  final int itemsCount;
  final double subtotal;
  final double discount;
  final double taxAmount;
  final double shippingCost;
  final double total;
  final String? couponCode;
  final double couponDiscount;

  const CheckoutCartModel({
    required this.id,
    required this.customerId,
    required this.status,
    required this.items,
    required this.itemsCount,
    required this.subtotal,
    required this.discount,
    required this.taxAmount,
    required this.shippingCost,
    required this.total,
    this.couponCode,
    required this.couponDiscount,
  });

  factory CheckoutCartModel.fromJson(Map<String, dynamic> json) {
    // Handle MongoDB _id or id field
    String? extractId(dynamic value) {
      if (value is String) return value;
      if (value is Map) {
        return value['_id']?.toString() ?? value['\$oid']?.toString();
      }
      return value?.toString();
    }

    return CheckoutCartModel(
      id: extractId(json['_id'] ?? json['id']) ?? '',
      customerId: extractId(json['customerId']) ?? '',
      status: json['status'] ?? 'active',
      items:
          (json['items'] as List<dynamic>?)
              ?.map((e) => CheckoutCartItemModel.fromJson(e))
              .toList() ??
          [],
      itemsCount: (json['itemsCount'] as num?)?.toInt() ?? 0,
      subtotal: (json['subtotal'] as num?)?.toDouble() ?? 0.0,
      discount: (json['discount'] as num?)?.toDouble() ?? 0.0,
      taxAmount: (json['taxAmount'] as num?)?.toDouble() ?? 0.0,
      shippingCost: (json['shippingCost'] as num?)?.toDouble() ?? 0.0,
      total: (json['total'] as num?)?.toDouble() ?? 0.0,
      couponCode: json['couponCode'],
      couponDiscount: (json['couponDiscount'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'customerId': customerId,
    'status': status,
    'items': items.map((e) => e.toJson()).toList(),
    'itemsCount': itemsCount,
    'subtotal': subtotal,
    'discount': discount,
    'taxAmount': taxAmount,
    'shippingCost': shippingCost,
    'total': total,
    'couponCode': couponCode,
    'couponDiscount': couponDiscount,
  };

  CheckoutCartEntity toEntity() {
    return CheckoutCartEntity(
      id: id,
      customerId: customerId,
      status: status,
      items: items.map((e) => e.toEntity()).toList(),
      itemsCount: itemsCount,
      subtotal: subtotal,
      discount: discount,
      taxAmount: taxAmount,
      shippingCost: shippingCost,
      total: total,
      couponCode: couponCode,
      couponDiscount: couponDiscount,
    );
  }
}

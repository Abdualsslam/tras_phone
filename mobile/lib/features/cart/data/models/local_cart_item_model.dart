/// Local Cart Item Model - Model for local cart items stored on device
library;

class LocalCartItemModel {
  final String productId;
  final int quantity;
  final double unitPrice;
  final DateTime addedAt;

  // Product details for display (optional, filled when available)
  final String? productName;
  final String? productNameAr;
  final String? productImage;
  final String? productSku;

  LocalCartItemModel({
    required this.productId,
    required this.quantity,
    required this.unitPrice,
    required this.addedAt,
    this.productName,
    this.productNameAr,
    this.productImage,
    this.productSku,
  });

  double get totalPrice => quantity * unitPrice;

  /// Convert to JSON for storage
  Map<String, dynamic> toJson() {
    return {
      'productId': productId,
      'quantity': quantity,
      'unitPrice': unitPrice,
      'addedAt': addedAt.toIso8601String(),
      if (productName != null) 'productName': productName,
      if (productNameAr != null) 'productNameAr': productNameAr,
      if (productImage != null) 'productImage': productImage,
      if (productSku != null) 'productSku': productSku,
    };
  }

  /// Create from JSON - resilient to type mismatches (e.g. quantity as double from JSON)
  factory LocalCartItemModel.fromJson(Map<String, dynamic> json) {
    final productId = json['productId']?.toString();
    if (productId == null || productId.isEmpty) {
      throw FormatException('productId is required');
    }
    final quantity = json['quantity'] != null
        ? (json['quantity'] is num
              ? (json['quantity'] as num).toInt()
              : int.tryParse(json['quantity'].toString()) ?? 1)
        : 1;
    final unitPrice = json['unitPrice'] != null
        ? (json['unitPrice'] as num).toDouble()
        : 0.0;
    final addedAtStr = json['addedAt']?.toString();
    final addedAt = addedAtStr != null
        ? DateTime.tryParse(addedAtStr) ?? DateTime.now()
        : DateTime.now();
    return LocalCartItemModel(
      productId: productId,
      quantity: quantity.clamp(1, 999),
      unitPrice: unitPrice,
      addedAt: addedAt,
      productName: json['productName'] as String?,
      productNameAr: json['productNameAr'] as String?,
      productImage: json['productImage'] as String?,
      productSku: json['productSku'] as String?,
    );
  }

  /// Create from CartItemEntity (when syncing from server)
  factory LocalCartItemModel.fromCartItemEntity(
    String productId,
    int quantity,
    double unitPrice, {
    String? productName,
    String? productNameAr,
    String? productImage,
    String? productSku,
  }) {
    return LocalCartItemModel(
      productId: productId,
      quantity: quantity,
      unitPrice: unitPrice,
      addedAt: DateTime.now(),
      productName: productName,
      productNameAr: productNameAr,
      productImage: productImage,
      productSku: productSku,
    );
  }

  /// Update with product details
  LocalCartItemModel copyWithProductDetails({
    String? productName,
    String? productNameAr,
    String? productImage,
    String? productSku,
  }) {
    return LocalCartItemModel(
      productId: productId,
      quantity: quantity,
      unitPrice: unitPrice,
      addedAt: addedAt,
      productName: productName ?? this.productName,
      productNameAr: productNameAr ?? this.productNameAr,
      productImage: productImage ?? this.productImage,
      productSku: productSku ?? this.productSku,
    );
  }

  /// Copy with updated values
  LocalCartItemModel copyWith({
    String? productId,
    int? quantity,
    double? unitPrice,
    DateTime? addedAt,
    String? productName,
    String? productNameAr,
    String? productImage,
    String? productSku,
  }) {
    return LocalCartItemModel(
      productId: productId ?? this.productId,
      quantity: quantity ?? this.quantity,
      unitPrice: unitPrice ?? this.unitPrice,
      addedAt: addedAt ?? this.addedAt,
      productName: productName ?? this.productName,
      productNameAr: productNameAr ?? this.productNameAr,
      productImage: productImage ?? this.productImage,
      productSku: productSku ?? this.productSku,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LocalCartItemModel &&
          runtimeType == other.runtimeType &&
          productId == other.productId;

  @override
  int get hashCode => productId.hashCode;
}

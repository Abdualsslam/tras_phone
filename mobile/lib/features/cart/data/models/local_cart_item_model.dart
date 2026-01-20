/// Local Cart Item Model - Model for local cart items stored on device

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

  /// Create from JSON
  factory LocalCartItemModel.fromJson(Map<String, dynamic> json) {
    return LocalCartItemModel(
      productId: json['productId'] as String,
      quantity: json['quantity'] as int,
      unitPrice: (json['unitPrice'] as num).toDouble(),
      addedAt: DateTime.parse(json['addedAt'] as String),
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

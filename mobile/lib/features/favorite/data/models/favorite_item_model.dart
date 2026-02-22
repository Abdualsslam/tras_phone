/// Favorite Item Model - Data layer model with JSON serialization
library;

import 'package:json_annotation/json_annotation.dart';
import '../../../catalog/data/models/product_model.dart';

part 'favorite_item_model.g.dart';

@JsonSerializable(explicitToJson: true)
class FavoriteItemModel {
  @JsonKey(name: '_id', readValue: _readId)
  final String id;
  
  @JsonKey(name: 'customerId', readValue: _readRelationId)
  final String? customerId;
  
  @JsonKey(name: 'productId', readValue: _readProductData)
  final dynamic productData;
  
  @JsonKey(includeFromJson: false, includeToJson: false)
  final String? productIdString;
  
  @JsonKey(includeFromJson: false, includeToJson: false)
  final ProductModel? product;
  
  @JsonKey(name: 'createdAt')
  final String? addedAt;
  
  @JsonKey(name: 'notifyOnPriceChange', defaultValue: false)
  final bool notifyOnPriceChange;
  
  @JsonKey(name: 'notifyOnBackInStock', defaultValue: false)
  final bool notifyOnBackInStock;
  
  @JsonKey(name: 'note')
  final String? note;

  const FavoriteItemModel({
    required this.id,
    this.customerId,
    this.productData,
    this.productIdString,
    this.product,
    this.addedAt,
    this.notifyOnPriceChange = false,
    this.notifyOnBackInStock = false,
    this.note,
  });

  /// Handle MongoDB _id or id field
  static Object? _readId(Map<dynamic, dynamic> json, String key) {
    final value = json['_id'] ?? json['id'];
    if (value is Map) {
      return value['\$oid'] ?? value.toString();
    }
    return value?.toString();
  }

  /// Handle relation IDs which can be String or populated object
  static Object? _readRelationId(Map<dynamic, dynamic> json, String key) {
    final value = json[key];
    if (value is String) return value;
    if (value is Map) {
      return value['_id']?.toString() ?? value['\$oid']?.toString();
    }
    return value?.toString();
  }

  /// Read productId which can be String or populated Product object
  static Object? _readProductData(Map<dynamic, dynamic> json, String key) {
    return json[key];
  }

  factory FavoriteItemModel.fromJson(Map<String, dynamic> json) {
    final model = _$FavoriteItemModelFromJson(json);
    
    // Extract product and productId from productData
    String? extractedProductId;
    ProductModel? extractedProduct;
    
    if (model.productData != null) {
      if (model.productData is String) {
        extractedProductId = model.productData as String;
      } else if (model.productData is Map<String, dynamic>) {
        try {
          extractedProduct = ProductModel.fromJson(model.productData as Map<String, dynamic>);
          extractedProductId = extractedProduct.id;
        } catch (e) {
          // If parsing fails, try to extract just the ID
          final data = model.productData as Map<String, dynamic>;
          extractedProductId = data['_id']?.toString() ?? data['id']?.toString();
        }
      }
    }
    
    return FavoriteItemModel(
      id: model.id,
      customerId: model.customerId,
      productData: model.productData,
      productIdString: extractedProductId,
      product: extractedProduct,
      addedAt: model.addedAt,
      notifyOnPriceChange: model.notifyOnPriceChange,
      notifyOnBackInStock: model.notifyOnBackInStock,
      note: model.note,
    );
  }
  
  Map<String, dynamic> toJson() => _$FavoriteItemModelToJson(this);

  // Computed properties based on product data
  String get productId => productIdString ?? product?.id ?? '';
  
  bool get isInStock => product?.stockQuantity != null && product!.stockQuantity > 0;
  
  bool get priceDropped {
    if (product?.compareAtPrice != null && product != null) {
      final current = product!.price ?? product!.basePrice;
      return product!.compareAtPrice! > current;
    }
    return false;
  }
  
  double? get originalPrice => product?.compareAtPrice ?? product?.basePrice;
  
  /// Current price (customer tier price when logged in, else basePrice)
  double? get currentPrice => product?.price ?? product?.basePrice;
  
  double? get priceDifference {
    if (originalPrice != null && currentPrice != null) {
      return originalPrice! - currentPrice!;
    }
    return null;
  }
  
  double? get discountPercentage {
    if (originalPrice != null && currentPrice != null && originalPrice! > currentPrice!) {
      return ((originalPrice! - currentPrice!) / originalPrice!) * 100;
    }
    return null;
  }
}

/// Product Review Model - Data layer model for product reviews
library;

import 'package:json_annotation/json_annotation.dart';
import '../../domain/enums/product_enums.dart';

part 'product_review_model.g.dart';

@JsonSerializable()
class ProductReviewModel {
  @JsonKey(name: 'id', readValue: _readId)
  final String id;

  @JsonKey(name: 'productId', readValue: _readRelationId)
  final String productId;

  @JsonKey(name: 'customerId', readValue: _readRelationId)
  final String customerId;

  final String? orderId;

  final int rating;
  final String? title;
  final String? comment;

  @JsonKey(defaultValue: [])
  final List<String> images;

  @JsonKey(defaultValue: 'pending')
  final String status;

  @JsonKey(defaultValue: 0)
  final int helpfulCount;

  @JsonKey(defaultValue: false)
  final bool isVerifiedPurchase;

  final DateTime createdAt;

  // Customer details (populated)
  @JsonKey(includeFromJson: false, includeToJson: false)
  final String? customerName;
  @JsonKey(includeFromJson: false, includeToJson: false)
  final String? customerShopName;

  const ProductReviewModel({
    required this.id,
    required this.productId,
    required this.customerId,
    this.orderId,
    required this.rating,
    this.title,
    this.comment,
    this.images = const [],
    this.status = 'pending',
    this.helpfulCount = 0,
    this.isVerifiedPurchase = false,
    required this.createdAt,
    this.customerName,
    this.customerShopName,
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
    return value?.toString() ?? '';
  }

  factory ProductReviewModel.fromJson(Map<String, dynamic> json) {
    // Extract customer data if populated
    String? customerName, customerShopName;
    final customerData = json['customerId'];
    if (customerData is Map<String, dynamic>) {
      customerName = customerData['name'] as String?;
      customerShopName = customerData['shopName'] as String?;
    }

    return ProductReviewModel(
      id: _readId(json, 'id')?.toString() ?? '',
      productId: _readRelationId(json, 'productId')?.toString() ?? '',
      customerId: _readRelationId(json, 'customerId')?.toString() ?? '',
      orderId: json['orderId'] as String?,
      rating: json['rating'] as int,
      title: json['title'] as String?,
      comment: json['comment'] as String?,
      images: (json['images'] as List<dynamic>?)?.cast<String>() ?? [],
      status: json['status'] as String? ?? 'pending',
      helpfulCount: json['helpfulCount'] as int? ?? 0,
      isVerifiedPurchase: json['isVerifiedPurchase'] as bool? ?? false,
      createdAt: DateTime.parse(json['createdAt'] as String),
      customerName: customerName,
      customerShopName: customerShopName,
    );
  }

  Map<String, dynamic> toJson() => _$ProductReviewModelToJson(this);

  ReviewStatus get reviewStatus => ReviewStatus.fromString(status);
}

/// Request for creating a review
class CreateReviewRequest {
  final int rating;
  final String? title;
  final String? comment;
  final List<String>? images;

  const CreateReviewRequest({
    required this.rating,
    this.title,
    this.comment,
    this.images,
  });

  Map<String, dynamic> toJson() => {
    'rating': rating,
    if (title != null) 'title': title,
    if (comment != null) 'comment': comment,
    if (images != null && images!.isNotEmpty) 'images': images,
  };
}

// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'product_review_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ProductReviewModel _$ProductReviewModelFromJson(
  Map<String, dynamic> json,
) => ProductReviewModel(
  id: ProductReviewModel._readId(json, 'id') as String,
  productId: ProductReviewModel._readRelationId(json, 'productId') as String,
  customerId: ProductReviewModel._readRelationId(json, 'customerId') as String,
  orderId: json['orderId'] as String?,
  rating: (json['rating'] as num).toInt(),
  title: json['title'] as String?,
  comment: json['comment'] as String?,
  images:
      (json['images'] as List<dynamic>?)?.map((e) => e as String).toList() ??
      [],
  status: json['status'] as String? ?? 'pending',
  helpfulCount: (json['helpfulCount'] as num?)?.toInt() ?? 0,
  isVerifiedPurchase: json['isVerifiedPurchase'] as bool? ?? false,
  createdAt: DateTime.parse(json['createdAt'] as String),
);

Map<String, dynamic> _$ProductReviewModelToJson(ProductReviewModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'productId': instance.productId,
      'customerId': instance.customerId,
      'orderId': instance.orderId,
      'rating': instance.rating,
      'title': instance.title,
      'comment': instance.comment,
      'images': instance.images,
      'status': instance.status,
      'helpfulCount': instance.helpfulCount,
      'isVerifiedPurchase': instance.isVerifiedPurchase,
      'createdAt': instance.createdAt.toIso8601String(),
    };

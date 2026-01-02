// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'review_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ReviewModel _$ReviewModelFromJson(Map<String, dynamic> json) => ReviewModel(
  id: (json['id'] as num).toInt(),
  productId: (json['product_id'] as num).toInt(),
  productName: json['product_name'] as String?,
  productImage: json['product_image'] as String?,
  orderId: (json['order_id'] as num?)?.toInt(),
  customerName: json['customer_name'] as String?,
  rating: (json['rating'] as num).toInt(),
  title: json['title'] as String?,
  comment: json['comment'] as String?,
  images: (json['images'] as List<dynamic>?)?.map((e) => e as String).toList(),
  isVerified: json['is_verified'] as bool? ?? false,
  helpfulCount: (json['is_helpful'] as num?)?.toInt() ?? 0,
  adminReply: json['admin_reply'] as String?,
  status: json['status'] as String? ?? 'approved',
  createdAt: json['created_at'] as String,
);

Map<String, dynamic> _$ReviewModelToJson(ReviewModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'product_id': instance.productId,
      'product_name': instance.productName,
      'product_image': instance.productImage,
      'order_id': instance.orderId,
      'customer_name': instance.customerName,
      'rating': instance.rating,
      'title': instance.title,
      'comment': instance.comment,
      'images': instance.images,
      'is_verified': instance.isVerified,
      'is_helpful': instance.helpfulCount,
      'admin_reply': instance.adminReply,
      'status': instance.status,
      'created_at': instance.createdAt,
    };

ProductRatingSummary _$ProductRatingSummaryFromJson(
  Map<String, dynamic> json,
) => ProductRatingSummary(
  productId: (json['product_id'] as num).toInt(),
  averageRating: (json['average_rating'] as num).toDouble(),
  totalReviews: (json['total_reviews'] as num).toInt(),
  ratingDistribution:
      (json['rating_distribution'] as Map<String, dynamic>?)?.map(
        (k, e) => MapEntry(k, (e as num).toInt()),
      ) ??
      const {},
);

Map<String, dynamic> _$ProductRatingSummaryToJson(
  ProductRatingSummary instance,
) => <String, dynamic>{
  'product_id': instance.productId,
  'average_rating': instance.averageRating,
  'total_reviews': instance.totalReviews,
  'rating_distribution': instance.ratingDistribution,
};

PendingReviewModel _$PendingReviewModelFromJson(Map<String, dynamic> json) =>
    PendingReviewModel(
      orderId: (json['order_id'] as num).toInt(),
      orderItemId: (json['order_item_id'] as num?)?.toInt(),
      productId: (json['product_id'] as num).toInt(),
      productName: json['product_name'] as String,
      productImage: json['product_image'] as String?,
      orderDate: json['order_date'] as String?,
      canReviewUntil: json['can_review_until'] as String?,
    );

Map<String, dynamic> _$PendingReviewModelToJson(PendingReviewModel instance) =>
    <String, dynamic>{
      'order_id': instance.orderId,
      'order_item_id': instance.orderItemId,
      'product_id': instance.productId,
      'product_name': instance.productName,
      'product_image': instance.productImage,
      'order_date': instance.orderDate,
      'can_review_until': instance.canReviewUntil,
    };

CreateReviewRequest _$CreateReviewRequestFromJson(Map<String, dynamic> json) =>
    CreateReviewRequest(
      productId: (json['product_id'] as num).toInt(),
      orderId: (json['order_id'] as num?)?.toInt(),
      rating: (json['rating'] as num).toInt(),
      title: json['title'] as String?,
      comment: json['comment'] as String?,
      images: (json['images'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
    );

Map<String, dynamic> _$CreateReviewRequestToJson(
  CreateReviewRequest instance,
) => <String, dynamic>{
  'product_id': instance.productId,
  'order_id': instance.orderId,
  'rating': instance.rating,
  'title': instance.title,
  'comment': instance.comment,
  'images': instance.images,
};

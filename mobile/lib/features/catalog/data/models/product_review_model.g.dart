// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'product_review_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

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
      'reviewStatus': _$ReviewStatusEnumMap[instance.reviewStatus]!,
    };

const _$ReviewStatusEnumMap = {
  ReviewStatus.pending: 'pending',
  ReviewStatus.approved: 'approved',
  ReviewStatus.rejected: 'rejected',
};

/// Review Models - Data layer models with JSON serialization
library;

import 'package:json_annotation/json_annotation.dart';

part 'review_model.g.dart';

@JsonSerializable()
class ReviewModel {
  final int id;
  @JsonKey(name: 'product_id')
  final int productId;
  @JsonKey(name: 'product_name')
  final String? productName;
  @JsonKey(name: 'product_image')
  final String? productImage;
  @JsonKey(name: 'order_id')
  final int? orderId;
  @JsonKey(name: 'customer_name')
  final String? customerName;
  final int rating;
  final String? title;
  final String? comment;
  final List<String>? images;
  @JsonKey(name: 'is_verified')
  final bool isVerified;
  @JsonKey(name: 'is_helpful')
  final int helpfulCount;
  @JsonKey(name: 'admin_reply')
  final String? adminReply;
  final String status; // 'pending', 'approved', 'rejected'
  @JsonKey(name: 'created_at')
  final String createdAt;

  const ReviewModel({
    required this.id,
    required this.productId,
    this.productName,
    this.productImage,
    this.orderId,
    this.customerName,
    required this.rating,
    this.title,
    this.comment,
    this.images,
    this.isVerified = false,
    this.helpfulCount = 0,
    this.adminReply,
    this.status = 'approved',
    required this.createdAt,
  });

  factory ReviewModel.fromJson(Map<String, dynamic> json) =>
      _$ReviewModelFromJson(json);
  Map<String, dynamic> toJson() => _$ReviewModelToJson(this);

  bool get isPending => status == 'pending';
  bool get isApproved => status == 'approved';
  bool get isRejected => status == 'rejected';
}

@JsonSerializable()
class ProductRatingSummary {
  @JsonKey(name: 'product_id')
  final int productId;
  @JsonKey(name: 'average_rating')
  final double averageRating;
  @JsonKey(name: 'total_reviews')
  final int totalReviews;
  @JsonKey(name: 'rating_distribution')
  final Map<String, int> ratingDistribution;

  const ProductRatingSummary({
    required this.productId,
    required this.averageRating,
    required this.totalReviews,
    this.ratingDistribution = const {},
  });

  factory ProductRatingSummary.fromJson(Map<String, dynamic> json) =>
      _$ProductRatingSummaryFromJson(json);
  Map<String, dynamic> toJson() => _$ProductRatingSummaryToJson(this);
}

@JsonSerializable()
class PendingReviewModel {
  @JsonKey(name: 'order_id')
  final int orderId;
  @JsonKey(name: 'order_item_id')
  final int? orderItemId;
  @JsonKey(name: 'product_id')
  final int productId;
  @JsonKey(name: 'product_name')
  final String productName;
  @JsonKey(name: 'product_image')
  final String? productImage;
  @JsonKey(name: 'order_date')
  final String? orderDate;
  @JsonKey(name: 'can_review_until')
  final String? canReviewUntil;

  const PendingReviewModel({
    required this.orderId,
    this.orderItemId,
    required this.productId,
    required this.productName,
    this.productImage,
    this.orderDate,
    this.canReviewUntil,
  });

  factory PendingReviewModel.fromJson(Map<String, dynamic> json) =>
      _$PendingReviewModelFromJson(json);
  Map<String, dynamic> toJson() => _$PendingReviewModelToJson(this);
}

@JsonSerializable()
class CreateReviewRequest {
  @JsonKey(name: 'product_id')
  final int productId;
  @JsonKey(name: 'order_id')
  final int? orderId;
  final int rating;
  final String? title;
  final String? comment;
  final List<String>? images;

  const CreateReviewRequest({
    required this.productId,
    this.orderId,
    required this.rating,
    this.title,
    this.comment,
    this.images,
  });

  factory CreateReviewRequest.fromJson(Map<String, dynamic> json) =>
      _$CreateReviewRequestFromJson(json);
  Map<String, dynamic> toJson() => _$CreateReviewRequestToJson(this);
}

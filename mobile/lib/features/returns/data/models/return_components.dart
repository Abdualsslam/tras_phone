import 'package:json_annotation/json_annotation.dart';
import '../../domain/entities/return_entity.dart';
import 'return_model.dart';

part 'return_components.g.dart';

/// Return Item Model
@JsonSerializable()
class ReturnItemModel {
  @JsonKey(name: '_id', fromJson: extractIdFromJson)
  final String id;
  @JsonKey(fromJson: extractIdFromJson)
  final String returnRequestId;
  @JsonKey(fromJson: extractIdFromJson)
  final String orderItemId;
  @JsonKey(fromJson: extractIdFromJson)
  final String productId;
  final String productSku;
  final String productName;
  final String? productImage;
  final int quantity;
  final double unitPrice;
  final double totalValue;
  final String inspectionStatus;
  final String? condition;
  final int approvedQuantity;
  final int rejectedQuantity;
  final String? inspectionNotes;

  const ReturnItemModel({
    required this.id,
    this.returnRequestId = '',
    this.orderItemId = '',
    required this.productId,
    this.productSku = '',
    required this.productName,
    this.productImage,
    required this.quantity,
    required this.unitPrice,
    this.totalValue = 0,
    this.inspectionStatus = 'pending',
    this.condition,
    this.approvedQuantity = 0,
    this.rejectedQuantity = 0,
    this.inspectionNotes,
  });

  factory ReturnItemModel.fromJson(Map<String, dynamic> json) =>
      _$ReturnItemModelFromJson(json);
  Map<String, dynamic> toJson() => _$ReturnItemModelToJson(this);

  InspectionStatus get inspectionStatusEnum =>
      InspectionStatus.fromString(inspectionStatus);
  ItemCondition? get conditionEnum =>
      condition != null ? ItemCondition.fromString(condition!) : null;

  /// Convert to domain entity
  ReturnItemEntity toEntity() {
    return ReturnItemEntity(
      id: id,
      returnRequestId: returnRequestId,
      orderItemId: orderItemId,
      productId: productId,
      productSku: productSku,
      productName: productName,
      productImage: productImage,
      quantity: quantity,
      unitPrice: unitPrice,
      totalValue: totalValue,
      inspectionStatus: inspectionStatusEnum,
      condition: conditionEnum,
      approvedQuantity: approvedQuantity,
      rejectedQuantity: rejectedQuantity,
      inspectionNotes: inspectionNotes,
    );
  }
}

/// Return Reason Model
@JsonSerializable()
class ReturnReasonModel {
  @JsonKey(name: '_id', fromJson: extractIdFromJson)
  final String id;
  final String name;
  final String nameAr;
  final String? description;
  final String category;
  final bool requiresPhoto;
  final bool eligibleForRefund;
  final bool eligibleForExchange;
  final int displayOrder;
  final bool isActive;

  const ReturnReasonModel({
    required this.id,
    required this.name,
    required this.nameAr,
    this.description,
    this.category = 'other',
    this.requiresPhoto = true,
    this.eligibleForRefund = true,
    this.eligibleForExchange = true,
    this.displayOrder = 0,
    this.isActive = true,
  });

  factory ReturnReasonModel.fromJson(Map<String, dynamic> json) =>
      _$ReturnReasonModelFromJson(json);
  Map<String, dynamic> toJson() => _$ReturnReasonModelToJson(this);

  ReasonCategory get categoryEnum => ReasonCategory.fromString(category);

  /// الحصول على الاسم حسب اللغة
  String getName(String locale) => locale == 'ar' ? nameAr : name;

  /// Convert to domain entity
  ReturnReasonEntity toEntity() {
    return ReturnReasonEntity(
      id: id,
      name: name,
      nameAr: nameAr,
      description: description,
      category: categoryEnum,
      requiresPhoto: requiresPhoto,
      eligibleForRefund: eligibleForRefund,
      eligibleForExchange: eligibleForExchange,
      displayOrder: displayOrder,
      isActive: isActive,
    );
  }
}

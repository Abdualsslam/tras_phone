part of 'ticket_models.dart';

@JsonSerializable()
class TicketCustomerInfo {
  final String? customerId;
  final String name;
  final String email;
  final String? phone;

  const TicketCustomerInfo({
    this.customerId,
    required this.name,
    required this.email,
    this.phone,
  });

  factory TicketCustomerInfo.fromJson(Map<String, dynamic> json) =>
      _$TicketCustomerInfoFromJson(json);
  Map<String, dynamic> toJson() => _$TicketCustomerInfoToJson(this);
}

@JsonSerializable()
class TicketSLA {
  final DateTime? firstResponseDue;
  final DateTime? resolutionDue;
  final DateTime? firstRespondedAt;
  final DateTime? resolvedAt;
  final bool firstResponseBreached;
  final bool resolutionBreached;

  const TicketSLA({
    this.firstResponseDue,
    this.resolutionDue,
    this.firstRespondedAt,
    this.resolvedAt,
    this.firstResponseBreached = false,
    this.resolutionBreached = false,
  });

  factory TicketSLA.fromJson(Map<String, dynamic> json) =>
      _$TicketSLAFromJson(json);
  Map<String, dynamic> toJson() => _$TicketSLAToJson(this);
}

@JsonSerializable()
class TicketResolution {
  final String? summary;
  @JsonKey(fromJson: _resolutionTypeFromJson)
  final ResolutionType? type;
  final String? resolvedBy;
  final DateTime? resolvedAt;

  const TicketResolution({
    this.summary,
    this.type,
    this.resolvedBy,
    this.resolvedAt,
  });

  factory TicketResolution.fromJson(Map<String, dynamic> json) =>
      _$TicketResolutionFromJson(json);
  Map<String, dynamic> toJson() => _$TicketResolutionToJson(this);

  static ResolutionType? _resolutionTypeFromJson(String? value) =>
      value != null ? ResolutionType.fromString(value) : null;
}

@JsonSerializable()
class TicketCategoryModel {
  @JsonKey(name: '_id', readValue: _readId)
  final String id;
  final String nameAr;
  final String nameEn;
  final String? descriptionAr;
  final String? descriptionEn;
  final String? icon;
  @JsonKey(name: 'parent')
  final String? parentId;
  final int sortOrder;
  final bool isActive;
  final bool requiresOrderId;
  final bool requiresProductId;

  const TicketCategoryModel({
    required this.id,
    required this.nameAr,
    required this.nameEn,
    this.descriptionAr,
    this.descriptionEn,
    this.icon,
    this.parentId,
    this.sortOrder = 0,
    this.isActive = true,
    this.requiresOrderId = false,
    this.requiresProductId = false,
  });

  factory TicketCategoryModel.fromJson(Map<String, dynamic> json) =>
      _$TicketCategoryModelFromJson(json);
  Map<String, dynamic> toJson() => _$TicketCategoryModelToJson(this);

  String getName(String locale) => locale == 'ar' ? nameAr : nameEn;
  String? getDescription(String locale) =>
      locale == 'ar' ? descriptionAr : descriptionEn;
}

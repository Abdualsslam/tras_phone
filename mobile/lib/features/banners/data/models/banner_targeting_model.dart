/// Banner Targeting Model
library;

import 'package:json_annotation/json_annotation.dart';
import '../../domain/entities/banner_targeting_entity.dart';

part 'banner_targeting_model.g.dart';

@JsonSerializable()
class BannerTargetingModel {
  @JsonKey(name: 'customerSegments', defaultValue: [])
  final List<String> customerSegments;
  @JsonKey(name: 'categories')
  final List<String>? categories;
  @JsonKey(name: 'userTypes', defaultValue: ['all'])
  final List<String> userTypes;
  @JsonKey(name: 'devices', defaultValue: [])
  final List<String> devices;

  const BannerTargetingModel({
    this.customerSegments = const [],
    this.categories,
    this.userTypes = const ['all'],
    this.devices = const [],
  });

  factory BannerTargetingModel.fromJson(Map<String, dynamic> json) {
    return BannerTargetingModel(
      customerSegments: List<String>.from(json['customerSegments'] ?? []),
      categories: json['categories'] != null
          ? List<String>.from(json['categories'])
          : null,
      userTypes: List<String>.from(json['userTypes'] ?? ['all']),
      devices: List<String>.from(json['devices'] ?? []),
    );
  }

  Map<String, dynamic> toJson() => _$BannerTargetingModelToJson(this);

  BannerTargetingEntity toEntity() {
    return BannerTargetingEntity(
      customerSegments: customerSegments,
      categories: categories,
      userTypes: userTypes,
      devices: devices,
    );
  }

  /// هل البانر يستهدف جميع المستخدمين؟
  bool get isForAllUsers => userTypes.contains('all');

  /// هل البانر يستهدف الضيوف فقط؟
  bool get isForGuestsOnly =>
      userTypes.contains('guest') && !userTypes.contains('registered');

  /// هل البانر يستهدف المستخدمين المسجلين فقط؟
  bool get isForRegisteredOnly =>
      userTypes.contains('registered') && !userTypes.contains('guest');

  /// هل البانر يستهدف جهاز معين؟
  bool isForDevice(String device) => devices.isEmpty || devices.contains(device);
}

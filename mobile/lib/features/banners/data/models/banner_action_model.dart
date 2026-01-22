/// Banner Action Model
library;

import 'package:json_annotation/json_annotation.dart';
import '../../domain/entities/banner_action_entity.dart';
import '../../domain/enums/banner_action_type.dart';

part 'banner_action_model.g.dart';

@JsonSerializable()
class BannerActionModel {
  final String type;
  final String? url;
  @JsonKey(name: 'refId')
  final String? refId;
  @JsonKey(name: 'refModel')
  final String? refModel;
  @JsonKey(name: 'openInNewTab', defaultValue: false)
  final bool openInNewTab;

  const BannerActionModel({
    required this.type,
    this.url,
    this.refId,
    this.refModel,
    this.openInNewTab = false,
  });

  factory BannerActionModel.fromJson(Map<String, dynamic> json) {
    // Handle refId which might be a string or an object with _id
    String? parsedRefId;
    if (json['refId'] != null) {
      if (json['refId'] is String) {
        parsedRefId = json['refId'];
      } else if (json['refId'] is Map && json['refId']['_id'] != null) {
        parsedRefId = json['refId']['_id'].toString();
      }
    }

    return _$BannerActionModelFromJson({
      ...json,
      'refId': parsedRefId,
    });
  }

  Map<String, dynamic> toJson() => _$BannerActionModelToJson(this);

  BannerActionEntity toEntity() {
    return BannerActionEntity(
      type: BannerActionType.values.firstWhere(
        (e) => e.value == type,
        orElse: () => BannerActionType.none,
      ),
      url: url,
      refId: refId,
      refModel: refModel,
      openInNewTab: openInNewTab,
    );
  }
}

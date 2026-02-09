/// Banners Cache Data - Stores cached banners (raw API response format)
library;

import 'package:json_annotation/json_annotation.dart';
import 'banner_model.dart';
import '../../domain/entities/banner_entity.dart';

part 'banners_cache_data.g.dart';

@JsonSerializable()
class BannersCacheData {
  final List<Map<String, dynamic>> banners;
  final String placement;
  final String cachedAt;

  const BannersCacheData({
    required this.banners,
    required this.placement,
    required this.cachedAt,
  });

  factory BannersCacheData.fromJson(Map<String, dynamic> json) =>
      _$BannersCacheDataFromJson(json);

  Map<String, dynamic> toJson() => _$BannersCacheDataToJson(this);

  List<BannerEntity> toEntities() {
    return banners
        .map((json) => BannerModel.fromJson(json).toEntity())
        .toList();
  }
}

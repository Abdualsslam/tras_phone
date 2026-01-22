/// Banner Media Model
library;

import 'package:json_annotation/json_annotation.dart';
import '../../domain/entities/banner_media_entity.dart';

part 'banner_media_model.g.dart';

@JsonSerializable()
class BannerMediaModel {
  @JsonKey(name: 'imageDesktopAr')
  final String imageDesktopAr;
  @JsonKey(name: 'imageDesktopEn')
  final String imageDesktopEn;
  @JsonKey(name: 'imageMobileAr')
  final String? imageMobileAr;
  @JsonKey(name: 'imageMobileEn')
  final String? imageMobileEn;
  @JsonKey(name: 'videoUrl')
  final String? videoUrl;
  @JsonKey(name: 'altTextAr')
  final String? altTextAr;
  @JsonKey(name: 'altTextEn')
  final String? altTextEn;

  const BannerMediaModel({
    required this.imageDesktopAr,
    required this.imageDesktopEn,
    this.imageMobileAr,
    this.imageMobileEn,
    this.videoUrl,
    this.altTextAr,
    this.altTextEn,
  });

  factory BannerMediaModel.fromJson(Map<String, dynamic> json) =>
      _$BannerMediaModelFromJson(json);

  Map<String, dynamic> toJson() => _$BannerMediaModelToJson(this);

  BannerMediaEntity toEntity() {
    return BannerMediaEntity(
      imageDesktopAr: imageDesktopAr,
      imageDesktopEn: imageDesktopEn,
      imageMobileAr: imageMobileAr,
      imageMobileEn: imageMobileEn,
      videoUrl: videoUrl,
      altTextAr: altTextAr,
      altTextEn: altTextEn,
    );
  }

  /// الحصول على الصورة حسب اللغة والجهاز
  String getImage({required String locale, required bool isMobile}) {
    if (isMobile) {
      return locale == 'ar'
          ? (imageMobileAr ?? imageDesktopAr)
          : (imageMobileEn ?? imageDesktopEn);
    }
    return locale == 'ar' ? imageDesktopAr : imageDesktopEn;
  }
}

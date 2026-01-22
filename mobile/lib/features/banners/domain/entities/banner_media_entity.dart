/// Banner Media Entity
library;

import 'package:equatable/equatable.dart';

class BannerMediaEntity extends Equatable {
  final String imageDesktopAr;
  final String imageDesktopEn;
  final String? imageMobileAr;
  final String? imageMobileEn;
  final String? videoUrl;
  final String? altTextAr;
  final String? altTextEn;

  const BannerMediaEntity({
    required this.imageDesktopAr,
    required this.imageDesktopEn,
    this.imageMobileAr,
    this.imageMobileEn,
    this.videoUrl,
    this.altTextAr,
    this.altTextEn,
  });

  /// الحصول على الصورة حسب اللغة والجهاز
  String getImage({required String locale, required bool isMobile}) {
    if (isMobile) {
      return locale == 'ar'
          ? (imageMobileAr ?? imageDesktopAr)
          : (imageMobileEn ?? imageDesktopEn);
    }
    return locale == 'ar' ? imageDesktopAr : imageDesktopEn;
  }

  /// الحصول على نص بديل حسب اللغة
  String? getAltText(String locale) =>
      locale == 'ar' ? altTextAr : altTextEn;

  /// هل يحتوي على فيديو؟
  bool get hasVideo => videoUrl != null && videoUrl!.isNotEmpty;

  @override
  List<Object?> get props => [
        imageDesktopAr,
        imageDesktopEn,
        imageMobileAr,
        imageMobileEn,
        videoUrl,
        altTextAr,
        altTextEn,
      ];
}

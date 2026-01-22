/// Banner Content Model
library;

import 'package:json_annotation/json_annotation.dart';
import 'package:flutter/material.dart';
import '../../domain/entities/banner_content_entity.dart';

part 'banner_content_model.g.dart';

@JsonSerializable()
class BannerContentModel {
  @JsonKey(name: 'headingAr')
  final String? headingAr;
  @JsonKey(name: 'headingEn')
  final String? headingEn;
  @JsonKey(name: 'subheadingAr')
  final String? subheadingAr;
  @JsonKey(name: 'subheadingEn')
  final String? subheadingEn;
  @JsonKey(name: 'buttonTextAr')
  final String? buttonTextAr;
  @JsonKey(name: 'buttonTextEn')
  final String? buttonTextEn;
  @JsonKey(name: 'textColor')
  final String? textColor;
  @JsonKey(name: 'overlayColor')
  final String? overlayColor;
  @JsonKey(name: 'overlayOpacity')
  final double? overlayOpacity;

  const BannerContentModel({
    this.headingAr,
    this.headingEn,
    this.subheadingAr,
    this.subheadingEn,
    this.buttonTextAr,
    this.buttonTextEn,
    this.textColor,
    this.overlayColor,
    this.overlayOpacity,
  });

  factory BannerContentModel.fromJson(Map<String, dynamic> json) {
    return BannerContentModel(
      headingAr: json['headingAr'],
      headingEn: json['headingEn'],
      subheadingAr: json['subheadingAr'],
      subheadingEn: json['subheadingEn'],
      buttonTextAr: json['buttonTextAr'],
      buttonTextEn: json['buttonTextEn'],
      textColor: json['textColor'],
      overlayColor: json['overlayColor'],
      overlayOpacity: (json['overlayOpacity'] as num?)?.toDouble(),
    );
  }

  Map<String, dynamic> toJson() => _$BannerContentModelToJson(this);

  BannerContentEntity toEntity() {
    return BannerContentEntity(
      headingAr: headingAr,
      headingEn: headingEn,
      subheadingAr: subheadingAr,
      subheadingEn: subheadingEn,
      buttonTextAr: buttonTextAr,
      buttonTextEn: buttonTextEn,
      textColor: textColor,
      overlayColor: overlayColor,
      overlayOpacity: overlayOpacity,
    );
  }

  /// الحصول على العنوان حسب اللغة
  String? getHeading(String locale) =>
      locale == 'ar' ? headingAr : headingEn;

  /// الحصول على العنوان الفرعي حسب اللغة
  String? getSubheading(String locale) =>
      locale == 'ar' ? subheadingAr : subheadingEn;

  /// الحصول على نص الزر حسب اللغة
  String? getButtonText(String locale) =>
      locale == 'ar' ? buttonTextAr : buttonTextEn;

  /// تحويل لون النص إلى Color
  Color? getTextColor() {
    if (textColor == null) return null;
    final hex = textColor!.replaceFirst('#', '');
    return Color(int.parse('FF$hex', radix: 16));
  }

  /// تحويل لون الـ Overlay إلى Color
  Color? getOverlayColor() {
    if (overlayColor == null) return null;
    final hex = overlayColor!.replaceFirst('#', '');
    return Color(int.parse('FF$hex', radix: 16));
  }
}

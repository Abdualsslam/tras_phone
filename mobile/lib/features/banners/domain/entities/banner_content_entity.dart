/// Banner Content Entity
library;

import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

class BannerContentEntity extends Equatable {
  final String? headingAr;
  final String? headingEn;
  final String? subheadingAr;
  final String? subheadingEn;
  final String? buttonTextAr;
  final String? buttonTextEn;
  final String? textColor;
  final String? overlayColor;
  final double? overlayOpacity;

  const BannerContentEntity({
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

  @override
  List<Object?> get props => [
        headingAr,
        headingEn,
        subheadingAr,
        subheadingEn,
        buttonTextAr,
        buttonTextEn,
        textColor,
        overlayColor,
        overlayOpacity,
      ];
}

/// Banner Entity - Domain layer representation of a banner
library;

import 'package:equatable/equatable.dart';

class BannerEntity extends Equatable {
  final int id;
  final String title;
  final String? titleAr;
  final String? subtitle;
  final String? subtitleAr;
  final String imageUrl;
  final String? imageMobileUrl;
  final String? linkType;
  final String? linkValue;
  final String placement;
  final bool isActive;

  const BannerEntity({
    required this.id,
    required this.title,
    this.titleAr,
    this.subtitle,
    this.subtitleAr,
    required this.imageUrl,
    this.imageMobileUrl,
    this.linkType,
    this.linkValue,
    required this.placement,
    this.isActive = true,
  });

  @override
  List<Object?> get props => [id];
}

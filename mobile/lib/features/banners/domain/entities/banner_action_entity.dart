/// Banner Action Entity
library;

import 'package:equatable/equatable.dart';
import '../enums/banner_action_type.dart';

class BannerActionEntity extends Equatable {
  final BannerActionType type;
  final String? url;
  final String? refId;
  final String? refModel; // 'Product', 'Category', 'Brand', 'Page'
  final bool openInNewTab;

  const BannerActionEntity({
    required this.type,
    this.url,
    this.refId,
    this.refModel,
    this.openInNewTab = false,
  });

  /// هل البانر قابل للنقر؟
  bool get isClickable => type != BannerActionType.none;

  /// الحصول على الرابط للتنقل
  String? get navigationPath {
    switch (type) {
      case BannerActionType.link:
        return url;
      case BannerActionType.product:
        return '/product/$refId';
      case BannerActionType.category:
        return '/category/$refId';
      case BannerActionType.brand:
        return '/brand/$refId';
      case BannerActionType.page:
        return '/page/$refId';
      case BannerActionType.none:
        return null;
    }
  }

  @override
  List<Object?> get props => [type, url, refId, refModel, openInNewTab];
}

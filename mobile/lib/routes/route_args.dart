library;

class OtpVerificationRouteArgs {
  final String phone;
  final String purpose;

  const OtpVerificationRouteArgs({
    required this.phone,
    this.purpose = 'verification',
  });

  factory OtpVerificationRouteArgs.fromExtra(Object? extra) {
    if (extra is OtpVerificationRouteArgs) {
      return extra;
    }
    if (extra is Map<String, dynamic>) {
      return OtpVerificationRouteArgs(
        phone: extra['phone'] as String? ?? '',
        purpose: extra['purpose'] as String? ?? 'verification',
      );
    }
    return const OtpVerificationRouteArgs(phone: '');
  }
}

class ResetPasswordRouteArgs {
  final String phone;
  final String resetToken;

  const ResetPasswordRouteArgs({required this.phone, required this.resetToken});

  factory ResetPasswordRouteArgs.fromExtra(Object? extra) {
    if (extra is ResetPasswordRouteArgs) {
      return extra;
    }
    if (extra is Map<String, dynamic>) {
      return ResetPasswordRouteArgs(
        phone: extra['phone'] as String? ?? '',
        resetToken: extra['resetToken'] as String? ?? '',
      );
    }
    return const ResetPasswordRouteArgs(phone: '', resetToken: '');
  }
}

class ProductEducationRouteArgs {
  final String? productName;

  const ProductEducationRouteArgs({this.productName});

  factory ProductEducationRouteArgs.fromNavigation({
    required Object? extra,
    required Map<String, String> queryParameters,
  }) {
    if (extra is ProductEducationRouteArgs) {
      return extra;
    }
    if (extra is Map<String, dynamic>) {
      return ProductEducationRouteArgs(
        productName: extra['productName'] as String?,
      );
    }
    return ProductEducationRouteArgs(
      productName: queryParameters['productName'],
    );
  }
}

class ProductReviewsRouteArgs {
  final String? productName;
  final double? averageRating;
  final int? reviewsCount;

  const ProductReviewsRouteArgs({
    this.productName,
    this.averageRating,
    this.reviewsCount,
  });

  factory ProductReviewsRouteArgs.fromExtra(Object? extra) {
    if (extra is ProductReviewsRouteArgs) {
      return extra;
    }
    if (extra is Map<String, dynamic>) {
      return ProductReviewsRouteArgs(
        productName: extra['productName'] as String?,
        averageRating: (extra['averageRating'] as num?)?.toDouble(),
        reviewsCount: extra['reviewsCount'] as int?,
      );
    }
    return const ProductReviewsRouteArgs();
  }
}

class WriteReviewRouteArgs {
  final String? productName;

  const WriteReviewRouteArgs({this.productName});

  factory WriteReviewRouteArgs.fromExtra(Object? extra) {
    if (extra is WriteReviewRouteArgs) {
      return extra;
    }
    if (extra is Map<String, dynamic>) {
      return WriteReviewRouteArgs(productName: extra['productName'] as String?);
    }
    return const WriteReviewRouteArgs();
  }
}

class MapLocationPickerRouteArgs {
  final double? initialLatitude;
  final double? initialLongitude;

  const MapLocationPickerRouteArgs({
    this.initialLatitude,
    this.initialLongitude,
  });

  factory MapLocationPickerRouteArgs.fromExtra(Object? extra) {
    if (extra is MapLocationPickerRouteArgs) {
      return extra;
    }
    if (extra is Map<String, dynamic>) {
      return MapLocationPickerRouteArgs(
        initialLatitude: (extra['initialLatitude'] as num?)?.toDouble(),
        initialLongitude: (extra['initialLongitude'] as num?)?.toDouble(),
      );
    }
    return const MapLocationPickerRouteArgs();
  }
}

class UploadReceiptRouteArgs {
  final double amount;

  const UploadReceiptRouteArgs({this.amount = 0});

  factory UploadReceiptRouteArgs.fromExtra(Object? extra) {
    if (extra is UploadReceiptRouteArgs) {
      return extra;
    }
    if (extra is Map<String, dynamic>) {
      return UploadReceiptRouteArgs(
        amount: (extra['amount'] as num?)?.toDouble() ?? 0,
      );
    }
    return const UploadReceiptRouteArgs();
  }
}

class SearchResultsRouteArgs {
  final Map<String, dynamic>? filters;

  const SearchResultsRouteArgs({this.filters});

  factory SearchResultsRouteArgs.fromExtra(Object? extra) {
    if (extra is SearchResultsRouteArgs) {
      return extra;
    }
    if (extra is Map<String, dynamic>) {
      return SearchResultsRouteArgs(filters: extra);
    }
    return const SearchResultsRouteArgs();
  }
}

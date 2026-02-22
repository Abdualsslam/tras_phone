/// ProductCard - Reusable product card widget with iOS aesthetics
library;

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../cache/image_cache_config.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iconsax/iconsax.dart';
import '../../config/theme/app_colors.dart';
import '../../di/injection.dart';
import '../../../features/favorite/data/datasources/favorite_remote_datasource.dart';

class ProductCard extends StatefulWidget {
  final String id;
  final String name;
  final String? nameAr;
  final String? imageUrl;
  final double price;
  final double? originalPrice;
  final int? stockQuantity;
  final bool isFavorite;
  final VoidCallback? onTap;
  final VoidCallback? onAddToCart;
  final VoidCallback? onToggleFavorite;

  const ProductCard({
    super.key,
    required this.id,
    required this.name,
    this.nameAr,
    this.imageUrl,
    required this.price,
    this.originalPrice,
    this.stockQuantity,
    this.isFavorite = false,
    this.onTap,
    this.onAddToCart,
    this.onToggleFavorite,
  });

  @override
  State<ProductCard> createState() => _ProductCardState();
}

class _ProductCardState extends State<ProductCard> {
  FavoriteRemoteDataSource? _favoriteDataSource;
  bool _isFavoriteLocal = false;
  bool _isTogglingFavorite = false;

  bool get _usesExternalFavoriteControl => widget.onToggleFavorite != null;

  bool get _displayedFavorite =>
      _usesExternalFavoriteControl ? widget.isFavorite : _isFavoriteLocal;

  bool get hasDiscount =>
      widget.originalPrice != null && widget.originalPrice! > widget.price;

  bool get isOutOfStock =>
      widget.stockQuantity != null && widget.stockQuantity! <= 0;

  int get discountPercent {
    if (!hasDiscount) return 0;
    return (((widget.originalPrice! - widget.price) / widget.originalPrice!) *
            100)
        .round();
  }

  @override
  void initState() {
    super.initState();
    _isFavoriteLocal = widget.isFavorite;

    if (!_usesExternalFavoriteControl) {
      _favoriteDataSource = getIt<FavoriteRemoteDataSource>();
      _resolveInitialFavoriteState();
    }
  }

  @override
  void didUpdateWidget(covariant ProductCard oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.id != widget.id || oldWidget.isFavorite != widget.isFavorite) {
      _isFavoriteLocal = widget.isFavorite;
    }

    if (!_usesExternalFavoriteControl && oldWidget.id != widget.id) {
      _resolveInitialFavoriteState();
    }
  }

  Future<void> _resolveInitialFavoriteState() async {
    final dataSource = _favoriteDataSource;
    if (dataSource == null) return;

    try {
      final ids = await dataSource.getFavoriteProductIds();
      if (!mounted) return;
      setState(() {
        _isFavoriteLocal = ids.contains(widget.id);
      });
    } catch (_) {
      // Keep current local state when resolving fails.
    }
  }

  Future<void> _handleFavoriteTap() async {
    HapticFeedback.lightImpact();

    if (_usesExternalFavoriteControl) {
      widget.onToggleFavorite?.call();
      return;
    }

    if (_isTogglingFavorite) return;
    final dataSource = _favoriteDataSource;
    if (dataSource == null) return;

    final previous = _isFavoriteLocal;
    setState(() {
      _isFavoriteLocal = !previous;
      _isTogglingFavorite = true;
    });

    try {
      final next = await dataSource.toggleFavorite(widget.id, previous);

      if (!mounted) return;
      setState(() {
        _isFavoriteLocal = next;
        _isTogglingFavorite = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _isFavoriteLocal = previous;
        _isTogglingFavorite = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('تعذر تحديث المفضلة، حاول مرة أخرى'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: widget.onTap,
      child: Container(
        decoration: BoxDecoration(
          color: isDark ? AppColors.cardDark : AppColors.cardLight,
          borderRadius: BorderRadius.circular(16.r),
          boxShadow: [
            BoxShadow(
              color: AppColors.shadowLight,
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image Section with badges
            _buildImageSection(isDark),

            // Content Section
            Padding(
              padding: EdgeInsets.all(12.w),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Product Name
                  Text(
                    widget.nameAr ?? widget.name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w600,
                      color: isDark
                          ? AppColors.textPrimaryDark
                          : AppColors.textPrimaryLight,
                      height: 1.3,
                    ),
                  ),
                  SizedBox(height: 8.h),

                  // Price Section
                  _buildPriceSection(isDark),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImageSection(bool isDark) {
    return AspectRatio(
      aspectRatio: 1.0,
      child: Stack(
        children: [
          // Product Image
          ClipRRect(
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(16.r),
              topRight: Radius.circular(16.r),
            ),
            child: Container(
              width: double.infinity,
              color: isDark ? AppColors.surfaceDark : Colors.grey[100],
              child: _buildImage(),
            ),
          ),

          // Discount Badge
          if (hasDiscount)
            Positioned(
              top: 8.h,
              left: 8.w,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: AppColors.error,
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Text(
                  '-$discountPercent%',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 11.sp,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),

          // Favorite Button
          Positioned(
            top: 8.h,
            right: 8.w,
              child: GestureDetector(
                onTap: _handleFavoriteTap,
                child: Container(
                  width: 32.w,
                  height: 32.w,
                decoration: BoxDecoration(
                  color: (isDark ? AppColors.cardDark : Colors.white)
                      .withValues(alpha: 0.95),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Icon(
                  _displayedFavorite ? Iconsax.heart5 : Iconsax.heart,
                  size: 16.sp,
                  color: _displayedFavorite
                      ? AppColors.error
                      : (isDark
                            ? AppColors.textSecondaryDark
                            : AppColors.textSecondaryLight),
                ),
              ),
            ),
          ),

          // Out of Stock Overlay
          if (isOutOfStock)
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.6),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(16.r),
                    topRight: Radius.circular(16.r),
                  ),
                ),
                child: Center(
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 12.w,
                      vertical: 6.h,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    child: Text(
                      'نفذت الكمية',
                      style: TextStyle(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimaryLight,
                      ),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildImage() {
    if (widget.imageUrl == null || widget.imageUrl!.isEmpty) {
      return Center(
        child: Icon(
          Iconsax.mobile,
          size: 48.sp,
          color: AppColors.textTertiaryLight,
        ),
      );
    }

    final isLocalAsset = widget.imageUrl!.startsWith('assets/');

    if (isLocalAsset) {
      return Image.asset(
        widget.imageUrl!,
        fit: BoxFit.cover,
        width: double.infinity,
        height: double.infinity,
        errorBuilder: (_, __, ___) => Center(
          child: Icon(
            Iconsax.image,
            size: 48.sp,
            color: AppColors.textTertiaryLight,
          ),
        ),
      );
    }

    return CachedNetworkImage(
      imageUrl: widget.imageUrl!,
      cacheKey: imageCacheKey(widget.imageUrl!),
      cacheManager: imageCacheManager,
      fit: BoxFit.cover,
      width: double.infinity,
      height: double.infinity,
      placeholder: (context, url) => Center(
        child: CircularProgressIndicator(
          strokeWidth: 2,
        ),
      ),
      errorWidget: (context, url, error) => Center(
        child: Icon(
          Iconsax.image,
          size: 48.sp,
          color: AppColors.textTertiaryLight,
        ),
      ),
    );
  }

  Widget _buildPriceSection(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // Current Price
        Row(
          children: [
            Flexible(
              child: Text(
                '${widget.price.toStringAsFixed(0)} ر.س',
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primary,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),

        // Original Price (if discounted)
        if (hasDiscount) ...[
          SizedBox(height: 2.h),
          Text(
            '${widget.originalPrice!.toStringAsFixed(0)} ر.س',
            style: TextStyle(
              fontSize: 12.sp,
              fontWeight: FontWeight.w400,
              color: isDark
                  ? AppColors.textTertiaryDark
                  : AppColors.textTertiaryLight,
              decoration: TextDecoration.lineThrough,
              decorationColor: isDark
                  ? AppColors.textTertiaryDark
                  : AppColors.textTertiaryLight,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],

        // Low Stock Warning
        if (widget.stockQuantity != null &&
            widget.stockQuantity! > 0 &&
            widget.stockQuantity! <= 10) ...[
          SizedBox(height: 4.h),
          Text(
            'متبقي ${widget.stockQuantity} فقط',
            style: TextStyle(
              fontSize: 10.sp,
              fontWeight: FontWeight.w600,
              color: AppColors.warning,
            ),
          ),
        ],
      ],
    );
  }
}

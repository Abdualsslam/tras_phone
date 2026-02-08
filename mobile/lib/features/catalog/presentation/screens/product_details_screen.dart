/// Product Details Screen - Shows detailed product information
library;

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax/iconsax.dart';
import '../../../../core/config/theme/app_colors.dart';
import '../../../../core/di/injection.dart';
import '../../domain/entities/product_entity.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../wishlist/data/datasources/wishlist_remote_datasource.dart';
import '../../../cart/presentation/cubit/cart_cubit.dart';

class ProductDetailsScreen extends StatefulWidget {
  final ProductEntity product;

  const ProductDetailsScreen({super.key, required this.product});

  @override
  State<ProductDetailsScreen> createState() => _ProductDetailsScreenState();
}

class _ProductDetailsScreenState extends State<ProductDetailsScreen> {
  int _currentImageIndex = 0;
  int _quantity = 1;
  bool _isFavorite = false;
  bool _isLoadingWishlist = false;
  late PageController _pageController;
  late WishlistRemoteDataSource _wishlistDataSource;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _wishlistDataSource = getIt<WishlistRemoteDataSource>();
    _checkWishlistStatus();
  }

  Future<void> _checkWishlistStatus() async {
    try {
      final isInWishlist = await _wishlistDataSource.isInWishlist(widget.product.id);
      if (mounted) {
        setState(() {
          _isFavorite = isInWishlist;
        });
      }
    } catch (e) {
      // Silently fail - wishlist check is optional
      // If check fails, try to get wishlist and check if product is in it
      try {
        final wishlist = await _wishlistDataSource.getWishlist();
        final isInWishlist = wishlist.any((item) => item.productId.toString() == widget.product.id);
        if (mounted) {
          setState(() {
            _isFavorite = isInWishlist;
          });
        }
      } catch (e2) {
        // If both fail, just leave it as false
        debugPrint('Error checking wishlist status: $e, $e2');
      }
    }
  }

  Future<void> _toggleWishlist() async {
    if (_isLoadingWishlist) return;

    final wasFavorite = _isFavorite;
    
    // Optimistic update
    setState(() {
      _isFavorite = !_isFavorite;
      _isLoadingWishlist = true;
    });

    HapticFeedback.lightImpact();

    try {
      final newState = await _wishlistDataSource.toggleWishlist(
        widget.product.id,
        wasFavorite,
      );

      if (mounted) {
        setState(() {
          _isFavorite = newState;
          _isLoadingWishlist = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              newState ? 'تم الإضافة للمفضلة' : 'تم الإزالة من المفضلة',
            ),
            backgroundColor: AppColors.success,
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      // Revert on error
      if (mounted) {
        setState(() {
          _isFavorite = wasFavorite;
          _isLoadingWishlist = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '${AppLocalizations.of(context)!.error}: ${e.toString()}',
            ),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final product = widget.product;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: CustomScrollView(
        slivers: [
          // App Bar with Image
          _buildSliverAppBar(theme, isDark, product),

          // Product Info
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.all(16.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Brand & SKU
                  _buildBrandAndSku(theme, product),
                  SizedBox(height: 12.h),

                  // Product Name
                  Text(
                    product.nameAr,
                    style: theme.textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  SizedBox(height: 8.h),

                  // Rating
                  _buildRating(theme, product),
                  SizedBox(height: 16.h),

                  // Price Section
                  _buildPriceSection(theme, product),
                  SizedBox(height: 24.h),

                  // Quantity Selector
                  _buildQuantitySelector(theme, isDark),
                  SizedBox(height: 24.h),

                  // Description
                  if (product.description != null ||
                      product.descriptionAr != null)
                    _buildDescription(theme, product),

                  // Stock Status
                  _buildStockStatus(theme, product),
                  SizedBox(height: 100.h), // Space for bottom bar
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomBar(theme, product),
    );
  }

  Widget _buildSliverAppBar(
    ThemeData theme,
    bool isDark,
    ProductEntity product,
  ) {
    final images = product.images.isNotEmpty
        ? product.images
        : (product.imageUrl != null ? [product.imageUrl!] : <String>[]);

    return SliverAppBar(
      expandedHeight: 350.h,
      pinned: true,
      backgroundColor: isDark ? AppColors.surfaceDark : Colors.white,
      systemOverlayStyle: isDark
          ? SystemUiOverlayStyle.light
          : SystemUiOverlayStyle.dark,
      leading: Container(
        margin: EdgeInsets.all(8.w),
        decoration: BoxDecoration(
          color: (isDark ? Colors.black : Colors.white).withValues(alpha: 0.8),
          shape: BoxShape.circle,
        ),
        child: IconButton(
          icon: const Icon(Iconsax.arrow_right_3),
          onPressed: () => context.pop(),
        ),
      ),
      actions: [
        Container(
          margin: EdgeInsets.all(8.w),
          decoration: BoxDecoration(
            color: (isDark ? Colors.black : Colors.white).withValues(
              alpha: 0.8,
            ),
            shape: BoxShape.circle,
          ),
          child: IconButton(
            icon: _isLoadingWishlist
                ? SizedBox(
                    width: 20.sp,
                    height: 20.sp,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        _isFavorite ? AppColors.error : AppColors.primary,
                      ),
                    ),
                  )
                : Icon(
                    _isFavorite ? Iconsax.heart5 : Iconsax.heart,
                    color: _isFavorite ? AppColors.error : null,
                  ),
            onPressed: _toggleWishlist,
          ),
        ),
        Container(
          margin: EdgeInsets.only(left: 8.w, top: 8.w, bottom: 8.w),
          decoration: BoxDecoration(
            color: (isDark ? Colors.black : Colors.white).withValues(
              alpha: 0.8,
            ),
            shape: BoxShape.circle,
          ),
          child: IconButton(
            icon: const Icon(Iconsax.share),
            onPressed: () {
              // Share product
            },
          ),
        ),
      ],
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          children: [
            // Image PageView
            if (images.isNotEmpty)
              PageView.builder(
                controller: _pageController,
                itemCount: images.length,
                onPageChanged: (index) {
                  setState(() => _currentImageIndex = index);
                },
                itemBuilder: (context, index) {
                  final imageUrl = images[index];
                  final isLocalAsset = imageUrl.startsWith('assets/');

                  return Container(
                    color: isDark ? AppColors.surfaceDark : Colors.grey[100],
                    child: isLocalAsset
                        ? Image.asset(
                            imageUrl,
                            fit: BoxFit.contain,
                            errorBuilder: (_, _, _) => Center(
                              child: Icon(
                                Iconsax.image,
                                size: 80.sp,
                                color: AppColors.textTertiaryLight,
                              ),
                            ),
                          )
                        : CachedNetworkImage(
                            imageUrl: imageUrl,
                            fit: BoxFit.contain,
                            placeholder: (context, url) => Center(
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                              ),
                            ),
                            errorWidget: (context, url, error) => Center(
                              child: Icon(
                                Iconsax.image,
                                size: 80.sp,
                                color: AppColors.textTertiaryLight,
                              ),
                            ),
                          ),
                  );
                },
              )
            else
              Container(
                color: isDark ? AppColors.surfaceDark : Colors.grey[100],
                child: Center(
                  child: Icon(
                    Iconsax.image,
                    size: 80.sp,
                    color: AppColors.textTertiaryLight,
                  ),
                ),
              ),

            // Image Indicator
            if (images.length > 1)
              Positioned(
                bottom: 16.h,
                left: 0,
                right: 0,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    images.length,
                    (index) => Container(
                      width: _currentImageIndex == index ? 24.w : 8.w,
                      height: 8.h,
                      margin: EdgeInsets.symmetric(horizontal: 4.w),
                      decoration: BoxDecoration(
                        color: _currentImageIndex == index
                            ? AppColors.primary
                            : Colors.grey.withValues(alpha: 0.5),
                        borderRadius: BorderRadius.circular(4.r),
                      ),
                    ),
                  ),
                ),
              ),

            // Discount Badge
            if (product.hasDiscount)
              Positioned(
                top: 100.h,
                right: 16.w,
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 12.w,
                    vertical: 6.h,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.error,
                    borderRadius: BorderRadius.circular(20.r),
                  ),
                  child: Text(
                    '-${product.discountPercentage.toInt()}%',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildBrandAndSku(ThemeData theme, ProductEntity product) {
    return Row(
      children: [
        Container(
          padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(6.r),
          ),
          child: Text(
            'براند ${product.brandId}', // Would come from brand lookup
            style: TextStyle(
              color: AppColors.primary,
              fontSize: 12.sp,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        const Spacer(),
        Text(
          'SKU: ${product.sku}',
          style: theme.textTheme.bodySmall?.copyWith(
            color: AppColors.textTertiaryLight,
          ),
        ),
      ],
    );
  }

  Widget _buildRating(ThemeData theme, ProductEntity product) {
    return GestureDetector(
      onTap: () => context.push(
        '/product/${product.id}/reviews',
        extra: {
          'productName': product.getName('ar'),
          'averageRating': product.averageRating,
          'reviewsCount': product.reviewsCount,
        },
      ),
      child: product.reviewsCount == 0
          ? Row(
              children: [
                ...List.generate(5, (index) {
                  return Icon(
                    Iconsax.star,
                    color: Colors.amber.withValues(alpha: 0.3),
                    size: 18.sp,
                  );
                }),
                SizedBox(width: 8.w),
                Text(
                  '(اضغط لإضافة تقييم)',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: AppColors.textTertiaryLight,
                  ),
                ),
              ],
            )
          : Row(
              children: [
                ...List.generate(5, (index) {
                  final rating = product.rating;
                  return Icon(
                    index < rating.floor() ? Iconsax.star1 : Iconsax.star,
                    color: Colors.amber,
                    size: 18.sp,
                  );
                }),
                SizedBox(width: 8.w),
                Text(
                  '${product.rating}',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(width: 4.w),
                Text(
                  '(${product.reviewsCount} تقييم)',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: AppColors.textTertiaryLight,
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildPriceSection(ThemeData theme, ProductEntity product) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(
          '${product.price.toStringAsFixed(0)} ${AppLocalizations.of(context)!.currency}',
          style: TextStyle(
            fontSize: 28.sp,
            fontWeight: FontWeight.w700,
            color: AppColors.primary,
          ),
        ),
        if (product.hasDiscount) ...[
          SizedBox(width: 12.w),
          Text(
            '${product.originalPrice!.toStringAsFixed(0)} ${AppLocalizations.of(context)!.currency}',
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.w500,
              color: AppColors.textTertiaryLight,
              decoration: TextDecoration.lineThrough,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildQuantitySelector(ThemeData theme, bool isDark) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardDark : AppColors.cardLight,
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Row(
        children: [
          Text(
            AppLocalizations.of(context)!.quantity,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const Spacer(),
          Container(
            decoration: BoxDecoration(
              color: isDark
                  ? AppColors.backgroundDark
                  : AppColors.backgroundLight,
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Row(
              children: [
                _buildQuantityButton(
                  icon: Iconsax.minus,
                  onPressed: _quantity > 1
                      ? () => setState(() => _quantity--)
                      : null,
                ),
                SizedBox(
                  width: 50.w,
                  child: Text(
                    '$_quantity',
                    textAlign: TextAlign.center,
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                _buildQuantityButton(
                  icon: Iconsax.add,
                  onPressed: _quantity < widget.product.stockQuantity
                      ? () => setState(() => _quantity++)
                      : null,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuantityButton({
    required IconData icon,
    VoidCallback? onPressed,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          onPressed?.call();
          HapticFeedback.selectionClick();
        },
        borderRadius: BorderRadius.circular(12.r),
        child: Container(
          width: 44.w,
          height: 44.h,
          alignment: Alignment.center,
          child: Icon(
            icon,
            size: 20.sp,
            color: onPressed == null ? AppColors.textTertiaryLight : null,
          ),
        ),
      ),
    );
  }

  Widget _buildDescription(ThemeData theme, ProductEntity product) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppLocalizations.of(context)!.description,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        SizedBox(height: 8.h),
        Text(
          product.descriptionAr ?? product.description ?? '',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: AppColors.textSecondaryLight,
            height: 1.6,
          ),
        ),
        SizedBox(height: 24.h),
      ],
    );
  }

  Widget _buildStockStatus(ThemeData theme, ProductEntity product) {
    final isInStock = product.isInStock;
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: (isInStock ? AppColors.success : AppColors.error).withValues(
          alpha: 0.1,
        ),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: (isInStock ? AppColors.success : AppColors.error).withValues(
            alpha: 0.3,
          ),
        ),
      ),
      child: Row(
        children: [
          Icon(
            isInStock ? Iconsax.tick_circle : Iconsax.close_circle,
            color: isInStock ? AppColors.success : AppColors.error,
            size: 24.sp,
          ),
          SizedBox(width: 12.w),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                product.isInStock
                    ? AppLocalizations.of(context)!.inStock
                    : AppLocalizations.of(context)!.outOfStock,
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: isInStock ? AppColors.success : AppColors.error,
                ),
              ),
              if (isInStock)
                Text(
                  '${product.stockQuantity} قطعة متاحة',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: AppColors.textTertiaryLight,
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBottomBar(ThemeData theme, ProductEntity product) {
    final isDark = theme.brightness == Brightness.dark;
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            // Total Price
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    AppLocalizations.of(context)!.total,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: AppColors.textTertiaryLight,
                    ),
                  ),
                  Text(
                    '${(product.price * _quantity).toStringAsFixed(0)} ${AppLocalizations.of(context)!.currency}',
                    style: TextStyle(
                      fontSize: 22.sp,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
            ),

            // Add to Cart Button
            Expanded(
              child: ElevatedButton.icon(
                onPressed: product.isInStock
                    ? () {
                        HapticFeedback.mediumImpact();
                        // Add to local cart (instant operation)
                        context.read<CartCubit>().addToCartLocal(
                              productId: product.id,
                              quantity: _quantity,
                              unitPrice: product.effectivePrice,
                              productName: product.name,
                              productNameAr: product.nameAr,
                              productImage: product.mainImage ?? 
                                  (product.images.isNotEmpty ? product.images.first : null),
                              productSku: product.sku,
                            );
                        // Show success message
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              AppLocalizations.of(context)!.addedToCart,
                            ),
                            backgroundColor: AppColors.success,
                            behavior: SnackBarBehavior.floating,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12.r),
                            ),
                          ),
                        );
                      }
                    : null,
                icon: const Icon(Iconsax.shopping_cart),
                label: Text(AppLocalizations.of(context)!.addToCart),
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 16.h),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14.r),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

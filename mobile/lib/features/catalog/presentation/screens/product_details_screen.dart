/// Product Details Screen - Shows detailed product information
library;

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:dio/dio.dart';
import 'package:iconsax/iconsax.dart';
import '../../../../core/config/theme/app_colors.dart';
import '../../../../core/di/injection.dart';
import '../../domain/entities/product_entity.dart';
import '../../domain/repositories/catalog_repository.dart';
import '../../data/models/product_review_model.dart';
import '../../../education/domain/entities/educational_content_entity.dart';
import '../../../education/domain/repositories/education_repository.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../favorite/data/datasources/favorite_remote_datasource.dart';
import '../../../cart/presentation/cubit/cart_cubit.dart';
import '../widgets/add_review_bottom_sheet.dart';
import '../widgets/product_review_card.dart';
import '../widgets/rating_bar_row.dart';

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
  bool _isLoadingFavorite = false;
  late PageController _pageController;
  late FavoriteRemoteDataSource _favoriteDataSource;
  late CatalogRepository _catalogRepository;
  late EducationRepository _educationRepository;

  List<ProductReviewModel> _reviews = [];
  ProductReviewModel? _myReview;
  bool _reviewsLoading = true;
  String? _reviewsError;
  double _reviewsAverageRating = 0;
  int _reviewsCount = 0;
  List<EducationalContentEntity> _relatedEducationalContent = [];
  bool _educationLoading = false;
  String? _educationError;

  @override
  void initState() {
    super.initState();
    _printProductData();
    _pageController = PageController();
    _favoriteDataSource = getIt<FavoriteRemoteDataSource>();
    _catalogRepository = getIt<CatalogRepository>();
    _educationRepository = getIt<EducationRepository>();
    _checkFavoriteStatus();
    _loadReviews();
    _loadRelatedEducationalContent();
  }

  Future<void> _loadRelatedEducationalContent() async {
    setState(() {
      _educationLoading = true;
      _educationError = null;
    });

    List<String> ids = widget.product.relatedEducationalContent ?? [];

    final productResult = await _catalogRepository.getProduct(widget.product.id);
    productResult.fold((_) {}, (product) {
      if ((product.relatedEducationalContent ?? []).isNotEmpty) {
        ids = product.relatedEducationalContent!;
      }
    });

    final normalizedIds = ids
        .where((id) => id.trim().isNotEmpty)
        .map((id) => id.trim())
        .toSet()
        .toList();

    if (normalizedIds.isEmpty) {
      if (!mounted) return;
      setState(() {
        _relatedEducationalContent = [];
        _educationLoading = false;
      });
      return;
    }

    try {
      final loaded = await Future.wait(
        normalizedIds.map(
          (id) => _educationRepository
              .getContentById(id)
              .catchError((_) => null),
        ),
      );

      if (!mounted) return;
      setState(() {
        _relatedEducationalContent = loaded.whereType<EducationalContentEntity>().toList();
        _educationLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _educationError = 'تعذر تحميل المحتوى التعليمي';
        _educationLoading = false;
      });
    }
  }

  void _printProductData() {
    final p = widget.product;
    debugPrint('═══════════════════════════════════════════════════');
    debugPrint('Product Details (visited):');
    debugPrint('  id: ${p.id}');
    debugPrint('  sku: ${p.sku}');
    debugPrint('  name: ${p.name}');
    debugPrint('  nameAr: ${p.nameAr}');
    debugPrint('  slug: ${p.slug}');
    debugPrint('  brandId: ${p.brandId}');
    debugPrint('  categoryId: ${p.categoryId}');
    debugPrint('  basePrice: ${p.basePrice}');
    debugPrint('  tierPrice: ${p.tierPrice}');
    debugPrint('  price (effective): ${p.price}');
    debugPrint('  stockQuantity: ${p.stockQuantity}');
    debugPrint('  isInStock: ${p.isInStock}');
    debugPrint('  status: ${p.status}');
    debugPrint('  reviewsCount: ${p.reviewsCount}');
    debugPrint('  averageRating: ${p.averageRating}');
    debugPrint('  mainImage: ${p.mainImage}');
    debugPrint('  images count: ${p.images.length}');
    if (p.descriptionAr != null || p.description != null) {
      final desc = (p.descriptionAr ?? p.description ?? '').replaceAll('\n', ' ');
      debugPrint('  description: ${desc.length > 80 ? '${desc.substring(0, 80)}...' : desc}');
    }
    debugPrint('═══════════════════════════════════════════════════');
  }

  Future<void> _loadReviews() async {
    setState(() {
      _reviewsLoading = true;
      _reviewsError = null;
      _reviewsAverageRating = widget.product.averageRating;
      _reviewsCount = widget.product.reviewsCount;
    });

    final reviewsResult =
        await _catalogRepository.getProductReviews(widget.product.id);
    final myReviewResult =
        await _catalogRepository.getMyReview(widget.product.id);

    if (!mounted) return;

    String? error;
    List<ProductReviewModel> reviews = [];
    ProductReviewModel? myReview;

    reviewsResult.fold(
      (failure) => error = failure.message,
      (list) => reviews = list,
    );
    myReviewResult.fold(
      (_) => myReview = null,
      (r) => myReview = r,
    );

    if (!mounted) return;
    setState(() {
      _reviewsLoading = false;
      _reviewsError = error;
      _reviews = reviews;
      _myReview = myReview;
      _reviewsCount = reviews.length;
      if (reviews.isNotEmpty) {
        _reviewsAverageRating = reviews
                .map((r) => r.rating)
                .reduce((a, b) => a + b) /
            reviews.length;
      }
    });
  }

  Future<void> _onAddReviewPressed() async {
    final added = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => AddReviewBottomSheet(
        productId: widget.product.id,
        productName: widget.product.getName('ar'),
        existingReview: _myReview,
      ),
    );
    if (added == true && mounted) {
      _loadReviews();
    }
  }

  Future<void> _checkFavoriteStatus() async {
    try {
      final isFavorite = await _favoriteDataSource.isFavorite(widget.product.id);
      if (mounted) {
        setState(() {
          _isFavorite = isFavorite;
        });
      }
    } catch (e) {
      // Silently fail - favorite check is optional
      // If check fails, try to get favorites and check if product is in it
      try {
        final favorites = await _favoriteDataSource.getFavorites();
        final isFavorite = favorites.any((item) => item.productId.toString() == widget.product.id);
        if (mounted) {
          setState(() {
            _isFavorite = isFavorite;
          });
        }
      } catch (e2) {
        // If both fail, just leave it as false
        debugPrint('Error checking favorite status: $e, $e2');
      }
    }
  }

  Future<void> _toggleFavorite() async {
    if (_isLoadingFavorite) return;

    final wasFavorite = _isFavorite;
    
    // Optimistic update
    setState(() {
      _isFavorite = !_isFavorite;
      _isLoadingFavorite = true;
    });

    HapticFeedback.lightImpact();

    try {
      final newState = await _favoriteDataSource.toggleFavorite(
        widget.product.id,
        wasFavorite,
      );

      if (mounted) {
        setState(() {
          _isFavorite = newState;
          _isLoadingFavorite = false;
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
      if (mounted) {
        setState(() {
          _isLoadingFavorite = false;
        });

        // 409 = المنتج موجود فعلاً في المفضلة → نحدّث الواجهة ولا نعتبره خطأ
        if (e is DioException && e.response?.statusCode == 409) {
          setState(() => _isFavorite = true);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('المنتج موجود في المفضلة'),
              backgroundColor: AppColors.success,
              behavior: SnackBarBehavior.floating,
              duration: Duration(seconds: 2),
            ),
          );
          return;
        }

        setState(() => _isFavorite = wasFavorite);
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
                  SizedBox(height: 16.h),

                  // Price Section
                  _buildPriceSection(theme, product),
                  SizedBox(height: 24.h),

                  // Description
                  if (product.description != null ||
                      product.descriptionAr != null) ...[
                    _buildDescription(theme, product),
                    SizedBox(height: 24.h),
                  ],

                  // Stock Status
                  _buildStockStatus(theme, product),
                  SizedBox(height: 24.h),

                  if (
                    _educationLoading ||
                    _relatedEducationalContent.isNotEmpty ||
                    _educationError != null
                  )
                    ...[
                      _buildRelatedEducationalContentSection(theme, isDark),
                      SizedBox(height: 24.h),
                    ],

                  // Reviews Section (inline)
                  _buildReviewsSection(theme, isDark, product),
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
          color: isDark ? AppColors.glassDark : AppColors.glassLight,
          shape: BoxShape.circle,
          border: Border.all(
            color: AppColors.glassBorder,
            width: 1,
          ),
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
            color: isDark ? AppColors.glassDark : AppColors.glassLight,
            shape: BoxShape.circle,
            border: Border.all(
              color: AppColors.glassBorder,
              width: 1,
            ),
          ),
          child: IconButton(
            icon: _isLoadingFavorite
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
            onPressed: _toggleFavorite,
          ),
        ),
        Container(
          margin: EdgeInsets.only(left: 8.w, top: 8.w, bottom: 8.w),
          decoration: BoxDecoration(
            color: isDark ? AppColors.glassDark : AppColors.glassLight,
            shape: BoxShape.circle,
            border: Border.all(
              color: AppColors.glassBorder,
              width: 1,
            ),
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
    final brandName = product.brandNameAr ?? product.brandName;
    return Row(
      children: [
        if (brandName != null && brandName.isNotEmpty)
          Container(
            padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(6.r),
            ),
            child: Text(
              brandName,
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

  Widget _buildQuantityButton({
    required IconData icon,
    VoidCallback? onPressed,
    bool compact = false,
  }) {
    final w = compact ? 36.w : 44.w;
    final h = compact ? 36.h : 44.h;
    final iconSize = compact ? 18.sp : 20.sp;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          onPressed?.call();
          HapticFeedback.selectionClick();
        },
        borderRadius: BorderRadius.circular(compact ? 10.r : 12.r),
        child: Container(
          width: w,
          height: h,
          alignment: Alignment.center,
          child: Icon(
            icon,
            size: iconSize,
            color: onPressed == null ? AppColors.textTertiaryLight : null,
          ),
        ),
      ),
    );
  }

  Widget _buildDescription(ThemeData theme, ProductEntity product) {
    final isDark = theme.brightness == Brightness.dark;
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardDark : AppColors.cardLight,
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowLight,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
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
        ],
      ),
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
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowLight,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
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

  Widget _buildReviewsSection(
    ThemeData theme,
    bool isDark,
    ProductEntity product,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'التقييمات والمراجعات',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        SizedBox(height: 16.h),
        if (_reviewsLoading)
          Center(
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 24.h),
              child: SizedBox(
                width: 32.w,
                height: 32.h,
                child: const CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
          )
        else if (_reviewsError != null)
          Container(
            padding: EdgeInsets.all(16.w),
            decoration: BoxDecoration(
              color: AppColors.error.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12.r),
              boxShadow: [
                BoxShadow(
                  color: AppColors.shadowLight,
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              children: [
                Icon(Iconsax.warning_2, color: AppColors.error, size: 32.sp),
                SizedBox(height: 8.h),
                Text(
                  _reviewsError!,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyMedium,
                ),
                SizedBox(height: 12.h),
                TextButton(
                  onPressed: _loadReviews,
                  child: const Text('إعادة المحاولة'),
                ),
              ],
            ),
          )
        else if (_reviews.isEmpty)
          Container(
            padding: EdgeInsets.all(24.w),
            decoration: BoxDecoration(
              color: isDark ? AppColors.cardDark : AppColors.cardLight,
              borderRadius: BorderRadius.circular(12.r),
              boxShadow: [
                BoxShadow(
                  color: AppColors.shadowLight,
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              children: [
                Icon(
                  Iconsax.message_question,
                  size: 48.sp,
                  color: AppColors.textTertiaryLight,
                ),
                SizedBox(height: 12.h),
                Text(
                  'لا توجد تقييمات بعد',
                  style: theme.textTheme.titleMedium,
                ),
                SizedBox(height: 8.h),
                Text(
                  'كن أول من يقيم هذا المنتج',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: AppColors.textTertiaryLight,
                  ),
                ),
                SizedBox(height: 16.h),
                FilledButton.icon(
                  onPressed: _onAddReviewPressed,
                  icon: const Icon(Iconsax.edit, size: 20),
                  label: const Text('أضف تقييم'),
                ),
              ],
            ),
          )
        else
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: EdgeInsets.all(16.w),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.cardDark : AppColors.cardLight,
                  borderRadius: BorderRadius.circular(12.r),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.shadowLight,
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Column(
                      children: [
                        Text(
                          _reviewsAverageRating.toStringAsFixed(1),
                          style: TextStyle(
                            fontSize: 32.sp,
                            fontWeight: FontWeight.w700,
                            color: AppColors.primary,
                          ),
                        ),
                        Row(
                          children: List.generate(5, (index) {
                            return Icon(
                              index < _reviewsAverageRating.floor()
                                  ? Iconsax.star5
                                  : Iconsax.star,
                              size: 14.sp,
                              color: Colors.amber,
                            );
                          }),
                        ),
                        SizedBox(height: 4.h),
                        Text(
                          '$_reviewsCount تقييم',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: AppColors.textTertiaryLight,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(width: 24.w),
                    Expanded(
                      child: Column(
                        children: List.generate(5, (i) {
                          final star = 5 - i;
                          final count =
                              _reviews.where((r) => r.rating == star).length;
                          final pct = _reviews.isEmpty
                              ? 0.0
                              : count / _reviews.length;
                          return Padding(
                            padding: EdgeInsets.only(bottom: 6.h),
                            child: RatingBarRow(
                              theme: theme,
                              stars: star,
                              percentage: pct,
                            ),
                          );
                        }),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 16.h),
              ...List.generate(
                _reviews.length,
                (index) => Padding(
                  padding: EdgeInsets.only(bottom: 12.h),
                  child: ProductReviewCard(
                    theme: theme,
                    isDark: isDark,
                    review: _reviews[index],
                  ),
                ),
              ),
              SizedBox(height: 8.h),
              OutlinedButton.icon(
                onPressed: _onAddReviewPressed,
                icon: const Icon(Iconsax.edit, size: 20),
                label: const Text('أضف تقييم'),
              ),
            ],
          ),
      ],
    );
  }

  Widget _buildRelatedEducationalContentSection(ThemeData theme, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'المحتوى التعليمي الخاص بالمنتج',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        SizedBox(height: 12.h),
        if (_educationLoading)
          Center(
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 12.h),
              child: const CircularProgressIndicator(strokeWidth: 2),
            ),
          )
        else if (_educationError != null)
          Text(
            _educationError!,
            style: theme.textTheme.bodySmall?.copyWith(color: AppColors.error),
          )
        else
          Column(
            children: _relatedEducationalContent
                .map(
                  (content) => Padding(
                    padding: EdgeInsets.only(bottom: 10.h),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(12.r),
                      onTap: () => context.push('/education/details/${content.slug}'),
                      child: Container(
                        padding: EdgeInsets.all(12.w),
                        decoration: BoxDecoration(
                          color: isDark ? AppColors.cardDark : AppColors.cardLight,
                          borderRadius: BorderRadius.circular(12.r),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.shadowLight,
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (content.featuredImage != null)
                              ClipRRect(
                                borderRadius: BorderRadius.circular(8.r),
                                child: CachedNetworkImage(
                                  imageUrl: content.featuredImage!,
                                  width: 72.w,
                                  height: 72.h,
                                  fit: BoxFit.cover,
                                  errorWidget: (_, __, ___) => Container(
                                    width: 72.w,
                                    height: 72.h,
                                    color: AppColors.inputBackgroundLight,
                                    child: Icon(
                                      Iconsax.book,
                                      size: 20.sp,
                                      color: AppColors.textTertiaryLight,
                                    ),
                                  ),
                                ),
                              )
                            else
                              Container(
                                width: 72.w,
                                height: 72.h,
                                decoration: BoxDecoration(
                                  color: AppColors.inputBackgroundLight,
                                  borderRadius: BorderRadius.circular(8.r),
                                ),
                                child: Icon(
                                  Iconsax.book,
                                  size: 20.sp,
                                  color: AppColors.textTertiaryLight,
                                ),
                              ),
                            SizedBox(width: 12.w),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    content.getTitle('ar'),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: theme.textTheme.titleSmall?.copyWith(
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  SizedBox(height: 6.h),
                                  Text(
                                    content.type.getName('ar'),
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      color: AppColors.primary,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  if (content.getExcerpt('ar') != null)
                                    Padding(
                                      padding: EdgeInsets.only(top: 4.h),
                                      child: Text(
                                        content.getExcerpt('ar')!,
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                        style: theme.textTheme.bodySmall?.copyWith(
                                          color: AppColors.textSecondaryLight,
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                            Icon(
                              Iconsax.arrow_left_2,
                              size: 16.sp,
                              color: AppColors.textTertiaryLight,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                )
                .toList(),
          ),
      ],
    );
  }

  Widget _buildBottomBar(ThemeData theme, ProductEntity product) {
    final isDark = theme.brightness == Brightness.dark;
    return Container(
      padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 12.h),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowLight,
            blurRadius: 10,
            offset: const Offset(0, -4),
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
                      fontSize: 20.sp,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
            ),

            // Quantity Stepper (compact)
            Container(
              decoration: BoxDecoration(
                color: isDark
                    ? AppColors.backgroundDark
                    : AppColors.inputBackgroundLight,
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildQuantityButton(
                    icon: Iconsax.minus,
                    onPressed: _quantity > 1
                        ? () => setState(() => _quantity--)
                        : null,
                    compact: true,
                  ),
                  SizedBox(
                    width: 36.w,
                    child: Text(
                      '$_quantity',
                      textAlign: TextAlign.center,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  _buildQuantityButton(
                    icon: Iconsax.add,
                    onPressed: _quantity < product.stockQuantity
                        ? () => setState(() => _quantity++)
                        : null,
                    compact: true,
                  ),
                ],
              ),
            ),
            SizedBox(width: 12.w),

            // Add to Cart Button (primary gradient, min touch 48)
            Expanded(
              flex: 2,
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: product.isInStock
                      ? () {
                          HapticFeedback.mediumImpact();
                          context.read<CartCubit>().addToCartLocal(
                                productId: product.id,
                                quantity: _quantity,
                                unitPrice: product.effectivePrice,
                                productName: product.name,
                                productNameAr: product.nameAr,
                                productImage: product.mainImage ??
                                    (product.images.isNotEmpty
                                        ? product.images.first
                                        : null),
                                productSku: product.sku,
                              );
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
                  borderRadius: BorderRadius.circular(14.r),
                  child: Container(
                    height: 48.h,
                    decoration: BoxDecoration(
                      gradient: product.isInStock
                          ? AppColors.primaryGradient
                          : null,
                      color: product.isInStock
                          ? null
                          : AppColors.textTertiaryLight.withValues(alpha: 0.4),
                      borderRadius: BorderRadius.circular(14.r),
                      boxShadow: product.isInStock
                          ? [
                              BoxShadow(
                                color: AppColors.shadowPrimary,
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ]
                          : null,
                    ),
                    alignment: Alignment.center,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Iconsax.shopping_cart,
                          size: 20.sp,
                          color: Colors.white,
                        ),
                        SizedBox(width: 8.w),
                        Text(
                          AppLocalizations.of(context)!.addToCart,
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                            fontSize: 14.sp,
                          ),
                        ),
                      ],
                    ),
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

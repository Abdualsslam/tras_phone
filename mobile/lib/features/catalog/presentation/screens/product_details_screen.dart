/// Product Details Screen - Shows detailed product information
library;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:dio/dio.dart';
import '../../../../core/config/theme/app_colors.dart';
import '../../domain/entities/product_entity.dart';
import '../../domain/repositories/catalog_repository.dart';
import '../../data/models/product_review_model.dart';
import '../../../education/domain/entities/educational_content_entity.dart';
import '../../../education/domain/repositories/education_repository.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../favorite/domain/repositories/favorite_repository.dart';
import '../../../cart/presentation/cubit/cart_cubit.dart';
import '../widgets/add_review_bottom_sheet.dart';
import '../widgets/product_details_sections.dart';

class ProductDetailsScreen extends StatefulWidget {
  final ProductEntity product;

  const ProductDetailsScreen({super.key, required this.product});

  @override
  State<ProductDetailsScreen> createState() => _ProductDetailsScreenState();
}

class _ProductDetailsScreenState extends State<ProductDetailsScreen> {
  late ProductEntity _product;
  int _currentImageIndex = 0;
  int _quantity = 1;
  bool _isFavorite = false;
  bool _isLoadingFavorite = false;
  bool _productLoading = false;
  late PageController _pageController;
  late FavoriteRepository _favoriteRepository;
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
  bool _educationHasMore = false;

  @override
  void initState() {
    super.initState();
    _product = widget.product;
    _printProductData(_product);
    _pageController = PageController();
    _favoriteRepository = context.read<FavoriteRepository>();
    _catalogRepository = context.read<CatalogRepository>();
    _educationRepository = context.read<EducationRepository>();
    _checkFavoriteStatus();
    _loadProductDetails();
    _loadReviews();
    _loadRelatedEducationalContent();
  }

  Future<void> _loadProductDetails() async {
    setState(() {
      _productLoading = true;
    });

    final result = await _catalogRepository.getProduct(widget.product.id);
    if (!mounted) return;

    result.fold(
      (_) {
        setState(() {
          _productLoading = false;
        });
      },
      (product) {
        setState(() {
          _product = product;
          _productLoading = false;
          if (_quantity > _product.stockQuantity &&
              _product.stockQuantity > 0) {
            _quantity = _product.stockQuantity;
          }
        });
        _printProductData(_product);
      },
    );
  }

  Future<void> _loadRelatedEducationalContent() async {
    setState(() {
      _educationLoading = true;
      _educationError = null;
    });

    try {
      final result = await _educationRepository.getProductEducationalContent(
        productId: widget.product.id,
        page: 1,
        limit: 3,
      );

      final content =
          (result['content'] as List<EducationalContentEntity>?) ??
          <EducationalContentEntity>[];
      final pagination =
          (result['pagination'] as Map<String, dynamic>?) ??
          <String, dynamic>{};
      final pages = (pagination['pages'] as num?)?.toInt() ?? 1;
      final total = (pagination['total'] as num?)?.toInt() ?? content.length;

      if (!mounted) return;
      setState(() {
        _relatedEducationalContent = content;
        _educationHasMore = pages > 1 || total > content.length;
        _educationLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _educationError = 'ØªØ¹Ø°Ø± ØªØ­Ù…ÙŠÙ„ Ø§Ù„Ù…Ø­ØªÙˆÙ‰ Ø§Ù„ØªØ¹Ù„ÙŠÙ…ÙŠ';
        _educationLoading = false;
      });
    }
  }

  void _openAllEducationalContent() {
    context.push(
      '/product/${widget.product.id}/education',
      extra: {'productName': widget.product.getName('ar')},
    );
  }

  void _printProductData(ProductEntity p) {
    debugPrint(
      'â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•',
    );
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
    debugPrint('  compatibleDevices count: ${p.compatibleDevices.length}');
    debugPrint('  compatibleDeviceNamesAr: ${p.compatibleDeviceNamesAr}');
    debugPrint('  mainImage: ${p.mainImage}');
    debugPrint('  images count: ${p.images.length}');
    if (p.descriptionAr != null || p.description != null) {
      final desc = (p.descriptionAr ?? p.description ?? '').replaceAll(
        '\n',
        ' ',
      );
      debugPrint(
        '  description: ${desc.length > 80 ? '${desc.substring(0, 80)}...' : desc}',
      );
    }
    debugPrint(
      'â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•',
    );
  }

  Future<void> _loadReviews() async {
    setState(() {
      _reviewsLoading = true;
      _reviewsError = null;
      _reviewsAverageRating = widget.product.averageRating;
      _reviewsCount = widget.product.reviewsCount;
    });

    final reviewsResult = await _catalogRepository.getProductReviews(
      widget.product.id,
    );
    final myReviewResult = await _catalogRepository.getMyReview(
      widget.product.id,
    );

    if (!mounted) return;

    String? error;
    List<ProductReviewModel> reviews = [];
    ProductReviewModel? myReview;

    reviewsResult.fold(
      (failure) => error = failure.message,
      (list) => reviews = list,
    );
    myReviewResult.fold((_) => myReview = null, (r) => myReview = r);

    if (!mounted) return;
    setState(() {
      _reviewsLoading = false;
      _reviewsError = error;
      _reviews = reviews;
      _myReview = myReview;
      _reviewsCount = reviews.length;
      if (reviews.isNotEmpty) {
        _reviewsAverageRating =
            reviews.map((r) => r.rating).reduce((a, b) => a + b) /
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
      final isFavorite = await _favoriteRepository.isFavorite(
        widget.product.id,
      );
      if (mounted) {
        setState(() {
          _isFavorite = isFavorite;
        });
      }
    } catch (e) {
      // Silently fail - favorite check is optional
      // If check fails, try to get favorites and check if product is in it
      try {
        final favorites = await _favoriteRepository.getFavorites();
        final isFavorite = favorites.any(
          (item) => item.productId.toString() == widget.product.id,
        );
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
      final newState = await _favoriteRepository.toggleFavorite(
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
              newState
                  ? 'ØªÙ… Ø§Ù„Ø¥Ø¶Ø§ÙØ© Ù„Ù„Ù…ÙØ¶Ù„Ø©'
                  : 'ØªÙ… Ø§Ù„Ø¥Ø²Ø§Ù„Ø© Ù…Ù† Ø§Ù„Ù…ÙØ¶Ù„Ø©',
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

        // 409 = Ø§Ù„Ù…Ù†ØªØ¬ Ù…ÙˆØ¬ÙˆØ¯ ÙØ¹Ù„Ø§Ù‹ ÙÙŠ Ø§Ù„Ù…ÙØ¶Ù„Ø© â†’ Ù†Ø­Ø¯Ù‘Ø« Ø§Ù„ÙˆØ§Ø¬Ù‡Ø© ÙˆÙ„Ø§ Ù†Ø¹ØªØ¨Ø±Ù‡ Ø®Ø·Ø£
        if (e is DioException && e.response?.statusCode == 409) {
          setState(() => _isFavorite = true);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Ø§Ù„Ù…Ù†ØªØ¬ Ù…ÙˆØ¬ÙˆØ¯ ÙÙŠ Ø§Ù„Ù…ÙØ¶Ù„Ø©'),
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

  void _addToCart() {
    final product = _product;

    context.read<CartCubit>().addToCartLocal(
      productId: product.id,
      quantity: _quantity,
      unitPrice: product.effectivePrice,
      productName: product.name,
      productNameAr: product.nameAr,
      productImage:
          product.mainImage ??
          (product.images.isNotEmpty ? product.images.first : null),
      productSku: product.sku,
    );

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(AppLocalizations.of(context)!.addedToCart),
        backgroundColor: AppColors.success,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.r),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final product = _product;
    final locale = Localizations.localeOf(context).languageCode;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: CustomScrollView(
        slivers: [
          ProductDetailsSliverAppBar(
            product: product,
            pageController: _pageController,
            currentImageIndex: _currentImageIndex,
            onPageChanged: (index) {
              setState(() => _currentImageIndex = index);
            },
            isFavorite: _isFavorite,
            isLoadingFavorite: _isLoadingFavorite,
            onToggleFavorite: _toggleFavorite,
            onShare: () {},
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.all(16.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ProductBrandSkuRow(product: product),
                  SizedBox(height: 12.h),
                  Text(
                    product.getName(locale),
                    style: theme.textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  SizedBox(height: 16.h),
                  ProductPriceSection(product: product),
                  SizedBox(height: 24.h),
                  if (product.description != null ||
                      product.descriptionAr != null) ...[
                    ProductDescriptionCard(product: product),
                    SizedBox(height: 24.h),
                  ],
                  if ((product.categoryNameAr ?? product.categoryName) !=
                          null ||
                      (product.qualityTypeNameAr ?? product.qualityTypeName) !=
                          null) ...[
                    ProductSpecsCard(product: product),
                    SizedBox(height: 24.h),
                  ],
                  if (product.compatibleDeviceNames.isNotEmpty ||
                      product.compatibleDeviceNamesAr.isNotEmpty) ...[
                    ProductCompatibleDevicesCard(
                      product: product,
                      isLoading: _productLoading,
                    ),
                    SizedBox(height: 24.h),
                  ],
                  ProductStockStatusCard(product: product),
                  SizedBox(height: 24.h),
                  ProductEducationSection(
                    relatedContent: _relatedEducationalContent,
                    isLoading: _educationLoading,
                    error: _educationError,
                    hasMore: _educationHasMore,
                    onRetry: _loadRelatedEducationalContent,
                    onOpenAll: _openAllEducationalContent,
                  ),
                  SizedBox(height: 24.h),
                  ProductReviewsSection(
                    reviews: _reviews,
                    isLoading: _reviewsLoading,
                    error: _reviewsError,
                    averageRating: _reviewsAverageRating,
                    reviewsCount: _reviewsCount,
                    onRetry: _loadReviews,
                    onAddReview: _onAddReviewPressed,
                  ),
                  SizedBox(height: 100.h),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: ProductDetailsBottomBar(
        product: product,
        quantity: _quantity,
        onDecrease: _quantity > 1 ? () => setState(() => _quantity--) : null,
        onIncrease: _quantity < product.stockQuantity
            ? () => setState(() => _quantity++)
            : null,
        onAddToCart: _addToCart,
      ),
    );
  }
}

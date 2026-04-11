/// Education Details Screen - Article or video content
library;

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax/iconsax.dart';
import 'package:share_plus/share_plus.dart';

import '../../../../core/shimmer/index.dart';
import '../../../catalog/domain/entities/product_entity.dart';
import '../../../catalog/domain/repositories/catalog_repository.dart';
import '../../data/services/favorites_service.dart';
import '../../domain/entities/educational_content_entity.dart';
import '../../domain/repositories/education_repository.dart';
import '../cubit/education_details_cubit.dart';
import '../cubit/education_details_state.dart';
import '../widgets/education_details_sections.dart';

class EducationDetailsScreen extends StatelessWidget {
  final String contentId;

  const EducationDetailsScreen({super.key, required this.contentId});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          EducationDetailsCubit(repository: context.read<EducationRepository>())
            ..loadContent(contentId),
      child: const _EducationDetailsView(),
    );
  }
}

class _EducationDetailsView extends StatefulWidget {
  const _EducationDetailsView();

  @override
  State<_EducationDetailsView> createState() => _EducationDetailsViewState();
}

class _EducationDetailsViewState extends State<_EducationDetailsView> {
  late final FavoritesService _favoritesService;
  late final CatalogRepository _catalogRepository;

  bool _isFavorite = false;
  String? _favoriteLoadedForContentId;
  String? _relatedProductsLoadedForContentId;
  bool _relatedProductsLoading = false;
  String? _relatedProductsError;
  List<ProductEntity> _relatedProducts = [];

  @override
  void initState() {
    super.initState();
    _favoritesService = context.read<FavoritesService>();
    _catalogRepository = context.read<CatalogRepository>();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<EducationDetailsCubit, EducationDetailsState>(
      builder: (context, state) {
        if (state is EducationDetailsLoading) {
          return Scaffold(
            appBar: AppBar(),
            body: const EducationDetailsShimmer(),
          );
        }

        if (state is EducationDetailsError) {
          return Scaffold(
            appBar: AppBar(),
            body: EducationDetailsErrorState(
              message: state.message,
              onBack: () => Navigator.pop(context),
            ),
          );
        }

        if (state is! EducationDetailsLoaded) {
          return const SizedBox.shrink();
        }

        final content = state.content;
        _scheduleContentSideEffects(content);
        const locale = 'ar';

        return Scaffold(
          appBar: AppBar(
            title: Text(content.getTitle(locale)),
            actions: [
              IconButton(
                onPressed: () => _toggleFavorite(content.id),
                icon: Icon(
                  _isFavorite ? Iconsax.heart5 : Iconsax.heart,
                  size: 22.sp,
                  color: _isFavorite ? Colors.red : null,
                ),
              ),
              IconButton(
                onPressed: () => _shareContent(content),
                icon: Icon(Iconsax.share, size: 22.sp),
              ),
            ],
          ),
          body: EducationDetailsContent(
            content: content,
            relatedProductsLoading: _relatedProductsLoading,
            relatedProductsError: _relatedProductsError,
            relatedProducts: _relatedProducts,
            onLikeTap: () => _likeContent(content.id),
            onRetryRelatedProducts: () =>
                _loadRelatedProducts(content.relatedProducts),
            onRelatedProductTap: _openProduct,
          ),
        );
      },
    );
  }

  void _scheduleContentSideEffects(EducationalContentEntity content) {
    if (_favoriteLoadedForContentId != content.id) {
      _favoriteLoadedForContentId = content.id;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        unawaited(_checkFavoriteStatus(content.id));
      });
    }

    if (_relatedProductsLoadedForContentId != content.id) {
      _relatedProductsLoadedForContentId = content.id;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        unawaited(_loadRelatedProducts(content.relatedProducts));
      });
    }
  }

  Future<void> _loadRelatedProducts(List<String> productIds) async {
    final normalizedIds = productIds
        .where((id) => id.trim().isNotEmpty)
        .map((id) => id.trim())
        .toSet()
        .take(6)
        .toList();

    if (normalizedIds.isEmpty) {
      if (!mounted) return;
      setState(() {
        _relatedProducts = [];
        _relatedProductsError = null;
        _relatedProductsLoading = false;
      });
      return;
    }

    setState(() {
      _relatedProductsLoading = true;
      _relatedProductsError = null;
    });

    try {
      final results = await Future.wait(
        normalizedIds.map((id) => _catalogRepository.getProduct(id)),
      );

      final products = <ProductEntity>[];
      for (final result in results) {
        result.fold((_) {}, (product) => products.add(product));
      }

      if (!mounted) return;
      setState(() {
        _relatedProducts = products;
        _relatedProductsLoading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _relatedProductsError = 'تعذر تحميل المنتجات المرتبطة';
        _relatedProductsLoading = false;
      });
    }
  }

  void _openProduct(ProductEntity product) {
    context.push('/product/${product.id}', extra: product);
  }

  Future<void> _likeContent(String contentId) async {
    final success = await context.read<EducationDetailsCubit>().likeContent(
      contentId,
    );

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(success ? 'تم تسجيل الإعجاب' : 'تعذر تسجيل الإعجاب'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> _checkFavoriteStatus(String contentId) async {
    final isFav = await _favoritesService.isFavorite(contentId);
    if (!mounted) return;
    setState(() => _isFavorite = isFav);
  }

  Future<void> _toggleFavorite(String contentId) async {
    try {
      await _favoritesService.toggleFavorite(contentId);
      await _checkFavoriteStatus(contentId);
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _isFavorite ? 'تمت الإضافة للمفضلة' : 'تمت الإزالة من المفضلة',
          ),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('تعذر تحديث المفضلة'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Future<void> _shareContent(EducationalContentEntity content) async {
    final cubit = context.read<EducationDetailsCubit>();

    await Share.share(
      '${content.titleAr ?? content.title}\n\n${content.excerptAr ?? content.excerpt ?? ''}\n\nشاهد المزيد على تطبيق TRAS Phone',
      subject: content.titleAr ?? content.title,
    );

    final tracked = await cubit.shareContent(content.id);
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          tracked ? 'تمت مشاركة المحتوى' : 'تمت المشاركة بدون تتبع',
        ),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}

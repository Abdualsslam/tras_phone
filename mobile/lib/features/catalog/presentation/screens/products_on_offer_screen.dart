/// Products On Offer Screen - Screen for displaying products with offers
library;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax/iconsax.dart';
import 'package:flutter/services.dart';
import '../../../../core/config/theme/app_colors.dart';
import '../../../../core/di/injection.dart';
import '../../domain/repositories/catalog_repository.dart';
import '../../../favorite/data/datasources/favorite_remote_datasource.dart';
import '../cubit/products_on_offer_cubit.dart';
import '../cubit/products_on_offer_state.dart';
import '../widgets/product_offer_card.dart';

class ProductsOnOfferScreen extends StatefulWidget {
  const ProductsOnOfferScreen({super.key});

  @override
  State<ProductsOnOfferScreen> createState() => _ProductsOnOfferScreenState();
}

class _ProductsOnOfferScreenState extends State<ProductsOnOfferScreen> {
  final ScrollController _scrollController = ScrollController();
  late final ProductsOnOfferCubit _cubit;
  late final FavoriteRemoteDataSource _favoriteDataSource;
  final Set<String> _favoriteProductIds = {};

  @override
  void initState() {
    super.initState();
    _cubit = ProductsOnOfferCubit(
      repository: getIt<CatalogRepository>(),
    );
    _favoriteDataSource = getIt<FavoriteRemoteDataSource>();
    _cubit.loadProducts();
    _scrollController.addListener(_onScroll);
    _loadFavoriteIds();
  }

  Future<void> _loadFavoriteIds() async {
    try {
      final favoriteIds = await _favoriteDataSource.getFavoriteProductIds();
      setState(() {
        _favoriteProductIds.clear();
        _favoriteProductIds.addAll(favoriteIds);
      });
    } catch (e) {
      // Silently fail - favorite check is optional
    }
  }

  Future<void> _toggleFavorite(String productId) async {
    final isFavorite = _favoriteProductIds.contains(productId);
    
    setState(() {
      if (isFavorite) {
        _favoriteProductIds.remove(productId);
      } else {
        _favoriteProductIds.add(productId);
      }
    });

    try {
      HapticFeedback.lightImpact();
      await _favoriteDataSource.toggleFavorite(productId, isFavorite);
    } catch (e) {
      // Revert on error
      setState(() {
        if (isFavorite) {
          _favoriteProductIds.add(productId);
        } else {
          _favoriteProductIds.remove(productId);
        }
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('فشل تحديث المفضلة: ${e.toString()}'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _cubit.close();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent * 0.9) {
      _cubit.loadProducts();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return BlocProvider.value(
      value: _cubit,
      child: Scaffold(
        backgroundColor: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
        appBar: AppBar(
          title: const Text('العروض'),
          actions: [
            IconButton(
              icon: Icon(Iconsax.filter, size: 22.sp),
              onPressed: _showFilterDialog,
            ),
          ],
        ),
        body: BlocBuilder<ProductsOnOfferCubit, ProductsOnOfferState>(
          bloc: _cubit,
          builder: (context, state) {
            if (state is ProductsOnOfferLoading && _cubit.products.isEmpty) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state is ProductsOnOfferError) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Iconsax.danger,
                      size: 64.sp,
                      color: AppColors.error,
                    ),
                    SizedBox(height: 16.h),
                    Text(
                      state.message,
                      style: TextStyle(
                        fontSize: 16.sp,
                        color: isDark
                            ? AppColors.textPrimaryDark
                            : AppColors.textPrimaryLight,
                      ),
                    ),
                    SizedBox(height: 16.h),
                    ElevatedButton(
                      onPressed: () => _cubit.loadProducts(refresh: true),
                      child: const Text('إعادة المحاولة'),
                    ),
                  ],
                ),
              );
            }

            if (state is ProductsOnOfferLoaded) {
              if (state.products.isEmpty) {
                return _buildEmptyState(isDark);
              }

              return RefreshIndicator(
                onRefresh: () => _cubit.loadProducts(refresh: true),
                child: GridView.builder(
                  controller: _scrollController,
                  padding: EdgeInsets.all(16.w),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: 12.h,
                    crossAxisSpacing: 12.w,
                    childAspectRatio: 0.65,
                  ),
                  itemCount: state.products.length + (state.hasMore ? 1 : 0),
                  itemBuilder: (context, index) {
                    if (index >= state.products.length) {
                      return const Center(
                        child: Padding(
                          padding: EdgeInsets.all(16.0),
                          child: CircularProgressIndicator(),
                        ),
                      );
                    }
                    final product = state.products[index];
                    return ProductOfferCard(
                      product: product,
                       isFavorite: _favoriteProductIds.contains(product.id),
                      onTap: () => context.push(
                        '/product/${product.id}',
                        extra: product,
                      ),
                       onToggleFavorite: () => _toggleFavorite(product.id),
                    );
                  },
                ),
              );
            }

            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }

  Widget _buildEmptyState(bool isDark) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Iconsax.tag,
            size: 64.sp,
            color: AppColors.textTertiaryLight,
          ),
          SizedBox(height: 16.h),
          Text(
            'لا توجد عروض متاحة',
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.w600,
              color: isDark
                  ? AppColors.textPrimaryDark
                  : AppColors.textPrimaryLight,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            'تحقق مرة أخرى لاحقاً',
            style: TextStyle(
              fontSize: 14.sp,
              color: isDark
                  ? AppColors.textSecondaryDark
                  : AppColors.textSecondaryLight,
            ),
          ),
        ],
      ),
    );
  }

  void _showFilterDialog() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cubit = context.read<ProductsOnOfferCubit>();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: isDark ? AppColors.cardDark : AppColors.cardLight,
        title: Text(
          'تصفية العروض',
          style: TextStyle(
            color: isDark
                ? AppColors.textPrimaryDark
                : AppColors.textPrimaryLight,
          ),
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Sort By
              DropdownButtonFormField<String>(
                initialValue: cubit.sortBy,
                decoration: InputDecoration(
                  labelText: 'ترتيب حسب',
                  labelStyle: TextStyle(
                    color: isDark
                        ? AppColors.textSecondaryDark
                        : AppColors.textSecondaryLight,
                  ),
                ),
                dropdownColor: isDark ? AppColors.cardDark : AppColors.cardLight,
                style: TextStyle(
                  color: isDark
                      ? AppColors.textPrimaryDark
                      : AppColors.textPrimaryLight,
                ),
                items: const [
                  DropdownMenuItem(
                    value: 'discount',
                    child: Text('نسبة الخصم'),
                  ),
                  DropdownMenuItem(
                    value: 'price',
                    child: Text('السعر'),
                  ),
                  DropdownMenuItem(
                    value: 'createdAt',
                    child: Text('الأحدث'),
                  ),
                ],
                onChanged: (value) {
                  if (value != null) {
                    cubit.updateFilters(sortBy: value);
                  }
                },
              ),

              SizedBox(height: 16.h),

              // Sort Order
              DropdownButtonFormField<String>(
                initialValue: cubit.sortOrder,
                decoration: InputDecoration(
                  labelText: 'اتجاه الترتيب',
                  labelStyle: TextStyle(
                    color: isDark
                        ? AppColors.textSecondaryDark
                        : AppColors.textSecondaryLight,
                  ),
                ),
                dropdownColor: isDark ? AppColors.cardDark : AppColors.cardLight,
                style: TextStyle(
                  color: isDark
                      ? AppColors.textPrimaryDark
                      : AppColors.textPrimaryLight,
                ),
                items: const [
                  DropdownMenuItem(
                    value: 'asc',
                    child: Text('تصاعدي'),
                  ),
                  DropdownMenuItem(
                    value: 'desc',
                    child: Text('تنازلي'),
                  ),
                ],
                onChanged: (value) {
                  if (value != null) {
                    cubit.updateFilters(sortOrder: value);
                  }
                },
              ),

              SizedBox(height: 16.h),

              // Min Discount
              TextField(
                decoration: InputDecoration(
                  labelText: 'الحد الأدنى للخصم (%)',
                  labelStyle: TextStyle(
                    color: isDark
                        ? AppColors.textSecondaryDark
                        : AppColors.textSecondaryLight,
                  ),
                ),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                style: TextStyle(
                  color: isDark
                      ? AppColors.textPrimaryDark
                      : AppColors.textPrimaryLight,
                ),
                onChanged: (value) {
                  final discount = double.tryParse(value);
                  cubit.updateFilters(minDiscount: discount);
                },
              ),

              SizedBox(height: 16.h),

              // Max Discount
              TextField(
                decoration: InputDecoration(
                  labelText: 'الحد الأقصى للخصم (%)',
                  labelStyle: TextStyle(
                    color: isDark
                        ? AppColors.textSecondaryDark
                        : AppColors.textSecondaryLight,
                  ),
                ),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                style: TextStyle(
                  color: isDark
                      ? AppColors.textPrimaryDark
                      : AppColors.textPrimaryLight,
                ),
                onChanged: (value) {
                  final discount = double.tryParse(value);
                  cubit.updateFilters(maxDiscount: discount);
                },
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء'),
          ),
          TextButton(
            onPressed: () {
              cubit.resetFilters();
              Navigator.pop(context);
            },
            child: const Text('إعادة تعيين'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text('تطبيق'),
          ),
        ],
      ),
    );
  }
}

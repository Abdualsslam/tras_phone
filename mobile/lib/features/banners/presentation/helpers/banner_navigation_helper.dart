/// Banner Navigation Helper
library;

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/config/theme/app_colors.dart';
import '../../../catalog/data/datasources/catalog_remote_datasource.dart';
import '../../../catalog/domain/repositories/catalog_repository.dart';
import '../../domain/entities/banner_entity.dart';
import '../../domain/enums/banner_action_type.dart';

/// Helper class for banner navigation
class BannerNavigationHelper {
  /// Handle banner tap navigation
  static Future<void> handleBannerTap(
    BuildContext context,
    BannerEntity banner,
  ) async {
    if (!banner.action.isClickable) return;

    final action = banner.action;
    final path = action.navigationPath;

    switch (action.type) {
      case BannerActionType.link:
        if (action.url != null) {
          await _openUrl(action.url!);
        }
        break;

      case BannerActionType.product:
        if (path != null && action.refId != null) {
          await _navigateToProduct(context, action.refId!);
        }
        break;

      case BannerActionType.category:
        if (path != null) {
          context.push(path);
        }
        break;

      case BannerActionType.brand:
        if (action.refId != null) {
          await _navigateToBrand(context, action.refId!);
        }
        break;

      case BannerActionType.page:
        if (path != null) {
          context.push(path);
        }
        break;

      case BannerActionType.none:
        // Do nothing
        break;
    }
  }

  /// Navigate to product by loading it first
  static Future<void> _navigateToProduct(
    BuildContext context,
    String productId,
  ) async {
    // Show loading indicator
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(
          color: AppColors.primary,
        ),
      ),
    );

    try {
      // Load product from API
      final dataSource = getIt<CatalogRemoteDataSource>();
      final product = await dataSource.getProduct(productId);

      // Close loading indicator
      if (context.mounted) {
        Navigator.of(context).pop();
      }

      if (product != null && context.mounted) {
        // Navigate to product details with product entity
        context.push('/product/$productId', extra: product);
      } else if (context.mounted) {
        // Show error message if product not found
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('المنتج غير موجود'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      // Close loading indicator
      if (context.mounted) {
        Navigator.of(context).pop();
      }

      // Show error message
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('حدث خطأ أثناء تحميل المنتج: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  /// Navigate to brand by loading it first
  static Future<void> _navigateToBrand(
    BuildContext context,
    String brandId,
  ) async {
    // Show loading indicator
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(
          color: AppColors.primary,
        ),
      ),
    );

    try {
      // Load brand from API using repository
      final repository = getIt<CatalogRepository>();
      final brandResult = await repository.getBrandById(brandId);

      // Close loading indicator
      if (context.mounted) {
        Navigator.of(context).pop();
      }

      brandResult.fold(
        (failure) {
          // Show error message if brand not found
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(failure.message),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        (brand) {
          // Navigate to brand details with slug
          if (context.mounted) {
            context.push('/brand/${brand.slug}');
          }
        },
      );
    } catch (e) {
      // Close loading indicator
      if (context.mounted) {
        Navigator.of(context).pop();
      }

      // Show error message
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('حدث خطأ أثناء تحميل العلامة التجارية: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  /// Open URL in browser
  static Future<void> _openUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }
}

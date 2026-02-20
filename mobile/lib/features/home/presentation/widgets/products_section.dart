import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/widgets/widgets.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../catalog/domain/entities/product_entity.dart';
import 'section_header.dart';

class ProductsSection extends StatelessWidget {
  final String title;
  final List<ProductEntity> products;
  final VoidCallback? onSeeAll;
  final IconData? icon;

  const ProductsSection({
    super.key,
    required this.title,
    required this.products,
    this.onSeeAll,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SectionHeader(title: title, icon: icon, onSeeAll: onSeeAll),
        SizedBox(height: 14.h),
        SizedBox(
          height: 280.h,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.only(left: 16.w, right: 16.w, bottom: 8.h),
            clipBehavior: Clip.none,
            itemCount: products.length,
            separatorBuilder: (_, _) => SizedBox(width: 12.w),
            itemBuilder: (context, index) {
              final product = products[index];
              return SizedBox(
                width: 165.w,
                child: ProductCard(
                  id: product.id.toString(),
                  name: product.name,
                  nameAr: product.nameAr,
                  imageUrl: product.imageUrl,
                  price: product.price,
                  originalPrice: product.originalPrice,
                  stockQuantity: product.stockQuantity,
                  onTap: () =>
                      context.push('/product/${product.id}', extra: product),
                  onAddToCart: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          '${AppLocalizations.of(context)!.addedToCart}: ${product.nameAr}',
                        ),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  },
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

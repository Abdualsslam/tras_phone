import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tras_phone/features/cart/domain/entities/cart_item_product_entity.dart';
import 'package:tras_phone/features/cart/domain/entities/checkout_cart_item_entity.dart';
import 'package:tras_phone/features/cart/presentation/widgets/checkout_cart_item_row.dart';
import 'package:tras_phone/l10n/app_localizations.dart';

void main() {
  Widget buildTestApp(CheckoutCartItemEntity item) {
    return ScreenUtilInit(
      designSize: const Size(390, 844),
      builder: (context, child) {
        return MaterialApp(
          locale: const Locale('ar'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(body: child),
        );
      },
      child: CheckoutCartItemRow(item: item, locale: 'ar'),
    );
  }

  testWidgets('shows a generic stock issue message without a quantity', (
    tester,
  ) async {
    const item = CheckoutCartItemEntity(
      productId: 'p1',
      quantity: 5,
      unitPrice: 100,
      totalPrice: 500,
      addedAt: DateTime(2026, 4, 7),
      product: CartItemProductEntity(
        name: 'Product',
        nameAr: 'منتج',
        sku: 'SKU-1',
        isActive: true,
        stockQuantity: 2,
      ),
    );

    await tester.pumpWidget(buildTestApp(item));
    await tester.pumpAndSettle();

    expect(find.text('الكمية المطلوبة غير متوفرة'), findsOneWidget);
    expect(find.textContaining('الكمية المتوفرة'), findsNothing);
  });
}

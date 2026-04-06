import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iconsax/iconsax.dart';

import 'package:tras_phone/core/widgets/cards/product_card.dart';

void main() {
  testWidgets('does not show low-stock count on the product card', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(375, 812);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      ScreenUtilInit(
        designSize: const Size(375, 812),
        builder: (_, child) => const MaterialApp(
          home: Scaffold(
            body: Center(
              child: SizedBox(
                width: 165,
                height: 280,
                child: ProductCard(
                  id: 'p1',
                  name: 'Product',
                  nameAr: 'منتج',
                  price: 100,
                  stockQuantity: 3,
                ),
              ),
            ),
          ),
        ),
      ),
    );

    expect(find.textContaining('متبقي'), findsNothing);
  });

  testWidgets('uses external favorite callback without internal dependencies', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(375, 812);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    var toggled = false;

    await tester.pumpWidget(
      ScreenUtilInit(
        designSize: const Size(375, 812),
        builder: (_, child) => MaterialApp(
          home: Scaffold(
            body: Center(
              child: SizedBox(
                width: 165,
                height: 280,
                child: ProductCard(
                  id: 'p1',
                  name: 'Product',
                  nameAr: 'منتج',
                  price: 100,
                  isFavorite: true,
                  onToggleFavorite: () {
                    toggled = true;
                  },
                ),
              ),
            ),
          ),
        ),
      ),
    );

    expect(find.byIcon(Iconsax.heart5), findsOneWidget);

    await tester.tap(find.byIcon(Iconsax.heart5));
    await tester.pumpAndSettle();

    expect(toggled, isTrue);
  });
}

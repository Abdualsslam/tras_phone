import 'package:flutter_test/flutter_test.dart';
import 'package:tras_phone/features/catalog/data/models/product_model.dart';

import '../../../../fixtures/product_detail_payload_fixture.dart';

void main() {
  group('ProductModel.fromJson with wrapped product payload data', () {
    test(
      'maps populated relations, null optionals, zeros, and image fallback fields',
      () {
        final model = ProductModel.fromJson(productDetailPayloadData());

        expect(model.id, '69cffe8e7ed450de3fc8c2d5');
        expect(model.sku, 'BC11PM');
        expect(model.name, 'Iphone 11 Pro Max Rear Camera - OEM');
        expect(model.nameAr, 'كاميرا خلفية ايفون 11 برو ماكس - وكالة');
        expect(model.slug, 'iphone-11-pro-max-rear-camera-oem');

        expect(model.brandId, '69cf0131194a078b20dd5236');
        expect(model.categoryId, '69cfe9c164a3cc250216e50a');
        expect(model.qualityTypeId, '69cf0131194a078b20dd5240');
        expect(model.brandName, 'Apple');
        expect(model.brandNameAr, 'Apple');
        expect(model.categoryName, 'Cameras');
        expect(model.categoryNameAr, 'الكاميرات');
        expect(model.qualityTypeName, 'OEM');
        expect(model.qualityTypeNameAr, 'وكالة');

        expect(model.compatibleDevices, const [
          '69cfda3b570af0e74bb7d672',
          '69cfda3b570af0e74bb7d66f',
        ]);
        expect(model.compatibleDeviceNames, const [
          'IPHONE 11 PRO MAX',
          'IPHONE 11',
        ]);
        expect(model.compatibleDeviceNamesAr, const [
          'IPHONE 11 PRO MAX',
          'IPHONE 11',
        ]);
        expect(model.relatedProducts, isEmpty);
        expect(model.relatedEducationalContent, isEmpty);
        expect(model.additionalCategories, isEmpty);
        expect(model.tags, isEmpty);

        expect(
          model.mainImage,
          'https://cdn.shopify.com/s/files/1/0045/4092/4007/files/IsfsAfQXQLqULwBo.jpg?v=1733346513&width=1000',
        );
        expect(model.images, isEmpty);
        expect(model.shortDescription, isNull);
        expect(model.shortDescriptionAr, isNull);
        expect(model.warrantyDays, isNull);
        expect(model.warrantyDescription, isNull);

        expect(model.basePrice, 0);
        expect(model.price, 0);
        expect(model.stockQuantity, 0);
        expect(model.viewsCount, 0);
        expect(model.ordersCount, 0);
        expect(model.reviewsCount, 0);
        expect(model.averageRating, 0);
        expect(model.favoriteCount, 0);
        expect(model.allowBackorder, isFalse);
        expect(model.trackInventory, isTrue);
        expect(model.minOrderQuantity, 1);
        expect(model.quantityStep, 1);
        expect(model.isActive, isTrue);
        expect(model.status, 'active');
      },
    );

    test(
      'converts to entity with mainImage fallback and out-of-stock state',
      () {
        final entity = ProductModel.fromJson(
          productDetailPayloadData(),
        ).toEntity();

        expect(entity.imageUrl, entity.mainImage);
        expect(entity.mainImage, isNotNull);
        expect(entity.images, isEmpty);
        expect(entity.price, 0);
        expect(entity.effectivePrice, 0);
        expect(entity.isOutOfStock, isTrue);
        expect(entity.isInStock, isFalse);
        expect(entity.canOrder, isFalse);
        expect(entity.compatibleDevices, const [
          '69cfda3b570af0e74bb7d672',
          '69cfda3b570af0e74bb7d66f',
        ]);
        expect(entity.compatibleDeviceNames, const [
          'IPHONE 11 PRO MAX',
          'IPHONE 11',
        ]);
        expect(entity.compatibleDeviceNamesAr, const [
          'IPHONE 11 PRO MAX',
          'IPHONE 11',
        ]);
      },
    );
  });
}

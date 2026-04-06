import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tras_phone/core/constants/api_endpoints.dart';
import 'package:tras_phone/core/network/api_client.dart';
import 'package:tras_phone/features/catalog/data/datasources/catalog_remote_datasource.dart';

import '../../../../fixtures/product_detail_payload_fixture.dart';

class MockApiClient extends Mock implements ApiClient {}

void main() {
  late MockApiClient mockApiClient;
  late CatalogRemoteDataSourceImpl dataSource;

  setUp(() {
    mockApiClient = MockApiClient();
    dataSource = CatalogRemoteDataSourceImpl(apiClient: mockApiClient);
  });

  Response<dynamic> buildResponse(String path, Map<String, dynamic> data) {
    return Response<dynamic>(
      requestOptions: RequestOptions(path: path),
      data: data,
      statusCode: 200,
    );
  }

  group('getProduct', () {
    test('unwraps data payload and returns a parsed product entity', () async {
      final identifier = 'iphone-11-pro-max-rear-camera-oem';
      final path = '${ApiEndpoints.products}/$identifier';

      when(() => mockApiClient.get<dynamic>(path)).thenAnswer(
        (_) async => buildResponse(path, productDetailPayloadResponse()),
      );

      final product = await dataSource.getProduct(identifier);

      expect(product, isNotNull);
      expect(product!.id, '69cffe8e7ed450de3fc8c2d5');
      expect(product.brandId, '69cf0131194a078b20dd5236');
      expect(product.categoryId, '69cfe9c164a3cc250216e50a');
      expect(product.qualityTypeId, '69cf0131194a078b20dd5240');
      expect(product.brandName, 'Apple');
      expect(product.compatibleDeviceNames, const [
        'IPHONE 11 PRO MAX',
        'IPHONE 11',
      ]);
      expect(product.categoryNameAr, 'الكاميرات');
      expect(product.qualityTypeNameAr, 'وكالة');
      expect(product.images, isEmpty);
      expect(product.mainImage, isNotNull);
      expect(product.price, 0);
      expect(product.stockQuantity, 0);
      expect(product.isInStock, isFalse);

      verify(() => mockApiClient.get<dynamic>(path)).called(1);
    });
  });

  group('getProductById', () {
    test('reads the same wrapped success response shape by id', () async {
      final id = '69cffe8e7ed450de3fc8c2d5';
      final path = '${ApiEndpoints.products}/$id';

      when(() => mockApiClient.get<dynamic>(path)).thenAnswer(
        (_) async => buildResponse(path, productDetailPayloadResponse()),
      );

      final product = await dataSource.getProductById(id);

      expect(product, isNotNull);
      expect(product!.id, id);
      expect(product.nameAr, 'كاميرا خلفية ايفون 11 برو ماكس - وكالة');
      expect(product.compatibleDevices.length, 2);
      expect(product.compatibleDeviceNamesAr.length, 2);
      expect(product.relatedProducts, isEmpty);
      expect(product.relatedEducationalContent, isEmpty);

      verify(() => mockApiClient.get<dynamic>(path)).called(1);
    });
  });
}

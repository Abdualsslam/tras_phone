import 'dart:convert';

const String productDetailPayloadJson = r'''
{
  "status": "success",
  "statusCode": 200,
  "message": "Product retrieved",
  "messageAr": "تم استرجاع المنتج",
  "data": {
    "relatedProducts": [],
    "relatedEducationalContent": [],
    "minOrderQuantity": 1,
    "quantityStep": 1,
    "metaKeywords": [],
    "tags": [],
    "viewsCount": 0,
    "ordersCount": 0,
    "reviewsCount": 0,
    "averageRating": 0,
    "favoriteCount": 0,
    "_id": "69cffe8e7ed450de3fc8c2d5",
    "sku": "BC11PM",
    "additionalCategories": [],
    "allowBackorder": false,
    "basePrice": 0,
    "brandId": {
      "_id": "69cf0131194a078b20dd5236",
      "name": "Apple",
      "nameAr": "Apple",
      "slug": "apple",
      "metaKeywords": [],
      "isActive": true,
      "isFeatured": true,
      "displayOrder": 0,
      "productsCount": 0,
      "__v": 0,
      "createdAt": "2026-04-02T23:52:17.010Z",
      "updatedAt": "2026-04-03T15:34:51.222Z",
      "logo": "https://pub-6ce30c0ca0604b97ba00d527953e6e40.r2.dev/brands/2026/04/2f94fbc3de4151bc8cc1ae07d2618410.png"
    },
    "categoryId": {
      "metaKeywords": [],
      "_id": "69cfe9c164a3cc250216e50a",
      "slug": "cameras",
      "name": "Cameras",
      "nameAr": "الكاميرات",
      "parentId": null,
      "ancestors": [],
      "level": 0,
      "path": "cameras",
      "isActive": true,
      "isFeatured": false,
      "displayOrder": 0,
      "productsCount": 0,
      "childrenCount": 0,
      "createdAt": "2026-04-03T16:24:31.575Z",
      "updatedAt": "2026-04-03T16:40:54.143Z",
      "image": null
    },
    "compatibleDevices": [
      {
        "colors": [],
        "storageOptions": [],
        "_id": "69cfda3b570af0e74bb7d672",
        "name": "IPHONE 11 PRO MAX",
        "nameAr": "IPHONE 11 PRO MAX",
        "slug": "iphone-11-pro-max",
        "brandId": "69cf0131194a078b20dd5236",
        "isActive": true,
        "isPopular": false,
        "displayOrder": 0,
        "productsCount": 0,
        "createdAt": "2026-04-03T15:18:19.693Z",
        "updatedAt": "2026-04-03T15:34:51.744Z"
      },
      {
        "colors": [],
        "storageOptions": [],
        "_id": "69cfda3b570af0e74bb7d66f",
        "name": "IPHONE 11",
        "nameAr": "IPHONE 11",
        "slug": "iphone-11",
        "brandId": "69cf0131194a078b20dd5236",
        "isActive": true,
        "isPopular": false,
        "displayOrder": 0,
        "productsCount": 0,
        "createdAt": "2026-04-03T15:18:19.403Z",
        "updatedAt": "2026-04-03T15:34:51.744Z"
      }
    ],
    "createdAt": "2026-04-03T17:53:43.068Z",
    "images": [],
    "isActive": true,
    "isBestSeller": false,
    "isFeatured": false,
    "isNewArrival": false,
    "lowStockThreshold": 5,
    "mainImage": "https://cdn.shopify.com/s/files/1/0045/4092/4007/files/IsfsAfQXQLqULwBo.jpg?v=1733346513&width=1000",
    "name": "Iphone 11 Pro Max Rear Camera - OEM",
    "nameAr": "كاميرا خلفية ايفون 11 برو ماكس - وكالة",
    "qualityTypeId": {
      "_id": "69cf0131194a078b20dd5240",
      "name": "OEM",
      "nameAr": "وكالة",
      "code": "oem",
      "color": "#3b82f6",
      "displayOrder": 3,
      "isActive": true,
      "defaultWarrantyDays": 180,
      "__v": 0,
      "createdAt": "2026-04-02T23:52:17.031Z",
      "updatedAt": "2026-04-03T16:10:31.751Z"
    },
    "shortDescription": null,
    "shortDescriptionAr": null,
    "slug": "iphone-11-pro-max-rear-camera-oem",
    "status": "active",
    "stockQuantity": 0,
    "trackInventory": true,
    "updatedAt": "2026-04-03T18:15:11.428Z",
    "warrantyDays": null,
    "warrantyDescription": null,
    "price": 0,
    "brandName": "Apple",
    "brandNameAr": "Apple"
  },
  "timestamp": "2026-04-03T18:46:26.012Z"
}
''';

Map<String, dynamic> productDetailPayloadResponse() =>
    Map<String, dynamic>.from(
      jsonDecode(productDetailPayloadJson) as Map<String, dynamic>,
    );

Map<String, dynamic> productDetailPayloadData() => Map<String, dynamic>.from(
  productDetailPayloadResponse()['data'] as Map<String, dynamic>,
);

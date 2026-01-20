# 🎁 Products on Offer - دليل المنتجات ذات العروض المباشرة

## 📋 نظرة عامة

هذا الموديول يتعامل مع:
- ✅ المنتجات التي لديها عروض مباشرة (compareAtPrice > basePrice)
- ✅ نظام أولوية العروض
- ✅ جلب المنتجات ذات العروض مع Pagination و Sorting و Filtering

> **ملاحظة**: الـ endpoint **عام** 🌐 ولا يحتاج Token

---

## 🎯 نظام أولوية العروض

### ترتيب الأولوية (من الأعلى للأقل):

1. **عرض المنتج المباشر** (أعلى أولوية) 🔥
   - عندما يكون `compareAtPrice > basePrice`
   - هذا العرض له أولوية مطلقة
   - **لا يتم تطبيق أي عروض أخرى** إذا كان المنتج له عرض مباشر

2. **عرض على منتج محدد** (Product-specific)
   - عروض مرتبطة بمنتج معين عبر `productIds`

3. **عرض على الفئة** (Category)
   - عروض مرتبطة بفئة المنتج

4. **عرض على الماركة** (Brand)
   - عروض مرتبطة بماركة المنتج

5. **عرض عام** (General)
   - عروض تطبق على جميع المنتجات (`scope: 'all'`)

### مثال عملي:

```
منتج: iPhone 15 Pro
- basePrice: 3,500 ريال
- compareAtPrice: 4,000 ريال
- categoryId: "smartphones"
- brandId: "apple"

عروض متاحة:
- عرض على فئة "smartphones": خصم 10%
- عرض على ماركة "apple": خصم 5%

النتيجة:
✅ يعرض: السعر القديم 4,000 ريال والسعر الجديد 3,500 ريال
❌ لا يطبق عرض الفئة (10%)
❌ لا يطبق عرض الماركة (5%)
```

---

## 📁 Flutter Models

> **ملاحظة مهمة:** يمكنك استخدام `Product` model الموجود في `products.md` مباشرة. الباك إند يُرجع جميع حقول Product العادية بالإضافة إلى الحقول الإضافية (`hasDirectOffer`, `originalPrice`, `currentPrice`, `discountPercentage`, `appliedPromotion`). يمكنك استخدام extension أدناه أو معالجة الحقول مباشرة من JSON.

### Product with Offer Model Extension

```dart
// Extension على Product Model الموجود
extension ProductOfferExtension on Product {
  /// هل المنتج له عرض مباشر؟
  bool get hasDirectOffer {
    return compareAtPrice != null && 
           compareAtPrice! > basePrice;
  }

  /// حساب نسبة الخصم
  double get discountPercentage {
    if (!hasDirectOffer) return 0.0;
    return ((compareAtPrice! - basePrice) / compareAtPrice!) * 100;
  }

  /// السعر الأصلي (قبل الخصم)
  double get originalPrice => compareAtPrice ?? basePrice;

  /// السعر الحالي (بعد الخصم)
  double get currentPrice => basePrice;

  /// نص الخصم للعرض
  String get discountText {
    if (!hasDirectOffer) return '';
    final discount = discountPercentage.round();
    return 'خصم $discount%';
  }

  /// هل المنتج في عرض الآن؟
  bool get isOnOffer => hasDirectOffer;
}
```

### Product Response with Offer Fields (اختياري)

> **ملاحظة:** الباك إند يُرجع `Product` objects عادية مع حقول إضافية. يمكنك استخدام `Product.fromJson()` مباشرة وقراءة الحقول الإضافية من JSON.

عند جلب المنتجات من endpoint `/products/on-offer`، ستحصل على حقول إضافية في JSON:

```dart
// يمكنك استخدام Product model مباشرة أو إنشاء extension
class ProductWithOffer {
  // جميع حقول Product العادية
  final String id;
  final String name;
  final String nameAr;
  final double basePrice;
  final double? compareAtPrice;
  // ... باقي الحقول

  // حقول إضافية للعروض
  final bool hasDirectOffer;        // دائماً true في هذا endpoint
  final double originalPrice;       // compareAtPrice
  final double currentPrice;        // basePrice
  final double discountPercentage;  // نسبة الخصم المحسوبة
  final dynamic appliedPromotion;   // null (لأنه عرض مباشر)

  ProductWithOffer({
    // ... جميع الحقول
    required this.hasDirectOffer,
    required this.originalPrice,
    required this.currentPrice,
    required this.discountPercentage,
    this.appliedPromotion,
  });

  factory ProductWithOffer.fromJson(Map<String, dynamic> json) {
    return ProductWithOffer(
      id: json['_id'] ?? json['id'],
      name: json['name'],
      nameAr: json['nameAr'],
      basePrice: json['basePrice']?.toDouble() ?? 0.0,
      compareAtPrice: json['compareAtPrice']?.toDouble(),
      // ... باقي الحقول
      hasDirectOffer: json['hasDirectOffer'] ?? false,
      originalPrice: json['originalPrice']?.toDouble() ?? json['compareAtPrice']?.toDouble() ?? 0.0,
      currentPrice: json['currentPrice']?.toDouble() ?? json['basePrice']?.toDouble() ?? 0.0,
      discountPercentage: json['discountPercentage'] != null
          ? (json['discountPercentage'] is double
              ? json['discountPercentage']
              : json['discountPercentage'].toDouble())
          : (json['compareAtPrice'] != null && json['basePrice'] != null
              ? ((json['compareAtPrice'] - json['basePrice']) / json['compareAtPrice']) * 100
              : 0.0),
      appliedPromotion: json['appliedPromotion'], // دائماً null
    );
  }
}
```

**ملاحظة:** يوصى باستخدام `Product` model الموجود مع extension بدلاً من إنشاء class جديد. الباك إند يُرجع:
- جميع حقول `Product` العادية
- حقول إضافية: `hasDirectOffer` (دائماً true), `originalPrice`, `currentPrice`, `discountPercentage`, `appliedPromotion` (دائماً null)

---

## 🔌 API Endpoints

### 1. جلب المنتجات ذات العروض

```http
GET /products/on-offer
```

**Query Parameters:**

| Parameter | Type | Required | Default | Description |
|-----------|------|----------|---------|-------------|
| `page` | number | No | 1 | رقم الصفحة |
| `limit` | number | No | 20 | عدد العناصر في الصفحة (1-100) |
| `sortBy` | string | No | 'discount' | نوع الترتيب: 'discount', 'price', 'createdAt' |
| `sortOrder` | string | No | 'desc' | اتجاه الترتيب: 'asc', 'desc' |
| `minDiscount` | number | No | - | الحد الأدنى لنسبة الخصم (0-100) |
| `maxDiscount` | number | No | - | الحد الأقصى لنسبة الخصم (0-100) |
| `categoryId` | string | No | - | تصفية حسب الفئة (MongoDB ID) |
| `brandId` | string | No | - | تصفية حسب الماركة (MongoDB ID) |
| `status` | string | No | 'active' | حالة المنتج (افتراضي: 'active') |

**ملاحظات:**
- جميع المنتجات المُرجعة لديها `compareAtPrice > basePrice` (عرض مباشر)
- يتم حساب `discountPercentage` تلقائياً في الباك إند
- البيانات تأتي مع populate للعلاقات (brandId, categoryId, qualityTypeId)
- الحقل `appliedPromotion` دائماً `null` لأن هذه عروض مباشرة وليست من نظام العروض

**Response:**

```json
{
  "success": true,
  "message": "Products on offer retrieved",
  "messageAr": "تم استرجاع المنتجات ذات العروض",
  "data": [
    {
      "_id": "507f1f77bcf86cd799439011",
      "name": "iPhone 15 Pro Max",
      "nameAr": "آيفون 15 برو ماكس",
      "basePrice": 3500,
      "compareAtPrice": 4000,
      "hasDirectOffer": true,
      "originalPrice": 4000,
      "currentPrice": 3500,
      "discountPercentage": 12.5,
      "appliedPromotion": null,
      "brandId": {
        "_id": "...",
        "name": "Apple",
        "nameAr": "أبل",
        "slug": "apple"
      },
      "categoryId": {
        "_id": "...",
        "name": "Smartphones",
        "nameAr": "الهواتف الذكية",
        "slug": "smartphones"
      },
      "qualityTypeId": {
        "_id": "...",
        "name": "Original",
        "nameAr": "أصلي",
        "code": "original",
        "color": "#22c55e"
      }
      // ... باقي الحقول (جميع حقول Product العادية)
    }
  ],
  "meta": {
    "page": 1,
    "limit": 20,
    "pages": 5,
    "total": 95
  }
}
```

---

## 💻 Flutter Implementation

### 1. Data Source

```dart
// lib/features/products/data/datasources/products_remote_datasource.dart

abstract class ProductsRemoteDataSource {
  Future<Map<String, dynamic>> getProductsOnOffer({
    int page = 1,
    int limit = 20,
    String sortBy = 'discount',
    String sortOrder = 'desc',
    double? minDiscount,
    double? maxDiscount,
    String? categoryId,
    String? brandId,
  });
}

class ProductsRemoteDataSourceImpl implements ProductsRemoteDataSource {
  final Dio dio;

  ProductsRemoteDataSourceImpl({required this.dio});

  @override
  Future<Map<String, dynamic>> getProductsOnOffer({
    int page = 1,
    int limit = 20,
    String sortBy = 'discount',
    String sortOrder = 'desc',
    double? minDiscount,
    double? maxDiscount,
    String? categoryId,
    String? brandId,
  }) async {
    final queryParams = <String, dynamic>{
      'page': page,
      'limit': limit,
      'sortBy': sortBy,
      'sortOrder': sortOrder,
    };

    if (minDiscount != null) queryParams['minDiscount'] = minDiscount;
    if (maxDiscount != null) queryParams['maxDiscount'] = maxDiscount;
    if (categoryId != null) queryParams['categoryId'] = categoryId;
    if (brandId != null) queryParams['brandId'] = brandId;

    final response = await dio.get(
      '/products/on-offer',
      queryParameters: queryParams,
    );

    if (response.data['success']) {
      final data = response.data['data'] as List;
      final products = data.map((json) => Product.fromJson(json)).toList();
      return {
        'products': products,
        'pagination': response.data['meta'],
      };
    }
    throw Exception(response.data['messageAr'] ?? 'Failed to load products');
  }
}
```

### 2. Repository

```dart
// lib/features/products/domain/repositories/products_repository.dart

abstract class ProductsRepository {
  Future<Either<Failure, PaginatedResponse<Product>>> getProductsOnOffer({
    int page = 1,
    int limit = 20,
    String sortBy = 'discount',
    String sortOrder = 'desc',
    double? minDiscount,
    double? maxDiscount,
    String? categoryId,
    String? brandId,
  });
}

// lib/features/products/data/repositories/products_repository_impl.dart

class ProductsRepositoryImpl implements ProductsRepository {
  final ProductsRemoteDataSource remoteDataSource;

  ProductsRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, PaginatedResponse<Product>>> getProductsOnOffer({
    int page = 1,
    int limit = 20,
    String sortBy = 'discount',
    String sortOrder = 'desc',
    double? minDiscount,
    double? maxDiscount,
    String? categoryId,
    String? brandId,
  }) async {
    try {
      final result = await remoteDataSource.getProductsOnOffer(
        page: page,
        limit: limit,
        sortBy: sortBy,
        sortOrder: sortOrder,
        minDiscount: minDiscount,
        maxDiscount: maxDiscount,
        categoryId: categoryId,
        brandId: brandId,
      );

      final products = result['products'] as List<Product>;
      final pagination = result['pagination'] as Map<String, dynamic>;
      
      return Right(PaginatedResponse(
        data: products,
        page: pagination['page'] ?? page,
        limit: pagination['limit'] ?? limit,
        total: pagination['total'] ?? 0,
        pages: pagination['pages'] ?? 1,
      ));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }
}
```

### 3. Use Case

```dart
// lib/features/products/domain/usecases/get_products_on_offer.dart

class GetProductsOnOffer {
  final ProductsRepository repository;

  GetProductsOnOffer(this.repository);

  Future<Either<Failure, PaginatedResponse<ProductWithOffer>>> call({
    int page = 1,
    int limit = 20,
    String sortBy = 'discount',
    String sortOrder = 'desc',
    double? minDiscount,
    double? maxDiscount,
    String? categoryId,
    String? brandId,
  }) {
    return repository.getProductsOnOffer(
      page: page,
      limit: limit,
      sortBy: sortBy,
      sortOrder: sortOrder,
      minDiscount: minDiscount,
      maxDiscount: maxDiscount,
      categoryId: categoryId,
      brandId: brandId,
    );
  }
}
```

### 4. Bloc/Cubit

```dart
// lib/features/products/presentation/cubit/products_on_offer_cubit.dart

class ProductsOnOfferCubit extends Cubit<ProductsOnOfferState> {
  final GetProductsOnOffer getProductsOnOffer;

  ProductsOnOfferCubit({required this.getProductsOnOffer}) 
      : super(ProductsOnOfferInitial());

  int currentPage = 1;
  bool hasMore = true;
  List<Product> products = [];
  
  String sortBy = 'discount';
  String sortOrder = 'desc';
  double? minDiscount;
  double? maxDiscount;
  String? categoryId;
  String? brandId;

  Future<void> loadProducts({bool refresh = false}) async {
    if (refresh) {
      currentPage = 1;
      products.clear();
      hasMore = true;
    }

    if (!hasMore) return;

    emit(ProductsOnOfferLoading());

    final result = await getProductsOnOffer(
      page: currentPage,
      limit: 20,
      sortBy: sortBy,
      sortOrder: sortOrder,
      minDiscount: minDiscount,
      maxDiscount: maxDiscount,
      categoryId: categoryId,
      brandId: brandId,
    );

    result.fold(
      (failure) => emit(ProductsOnOfferError(failure.message)),
      (response) {
        products.addAll(response.data);
        hasMore = currentPage < response.pages;
        currentPage++;
        emit(ProductsOnOfferLoaded(products: products, hasMore: hasMore));
      },
    );
  }

  void updateFilters({
    String? sortBy,
    String? sortOrder,
    double? minDiscount,
    double? maxDiscount,
    String? categoryId,
    String? brandId,
  }) {
    this.sortBy = sortBy ?? this.sortBy;
    this.sortOrder = sortOrder ?? this.sortOrder;
    this.minDiscount = minDiscount;
    this.maxDiscount = maxDiscount;
    this.categoryId = categoryId;
    this.brandId = brandId;
    loadProducts(refresh: true);
  }
}

// States
abstract class ProductsOnOfferState {}

class ProductsOnOfferInitial extends ProductsOnOfferState {}

class ProductsOnOfferLoading extends ProductsOnOfferState {}

class ProductsOnOfferLoaded extends ProductsOnOfferState {
  final List<Product> products;
  final bool hasMore;

  ProductsOnOfferLoaded({required this.products, required this.hasMore});
}

class ProductsOnOfferError extends ProductsOnOfferState {
  final String message;

  ProductsOnOfferError(this.message);
}
```

---

## 🎨 UI Components

### 1. Product Offer Card

```dart
// lib/features/products/presentation/widgets/product_offer_card.dart

class ProductOfferCard extends StatelessWidget {
  final Product product;

  const ProductOfferCard({Key? key, required this.product}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // صورة المنتج مع شارة الخصم
          Stack(
            children: [
              Image.network(
                product.mainImage ?? '',
                height: 200,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
              // شارة الخصم
              Positioned(
                top: 8,
                right: 8,
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    'خصم ${product.hasDiscount ? product.discountPercentage.round() : 0}%',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ),
            ],
          ),
          
          Padding(
            padding: EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // اسم المنتج
                Text(
                  product.nameAr,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                
                SizedBox(height: 8),
                
                // الأسعار
                Row(
                  children: [
                    // السعر القديم (مشطوب)
                    if (product.hasDiscount && product.compareAtPrice != null)
                      Text(
                        '${product.compareAtPrice!.toStringAsFixed(0)} ر.س',
                        style: TextStyle(
                          decoration: TextDecoration.lineThrough,
                          color: Colors.grey,
                          fontSize: 14,
                        ),
                      ),
                    if (product.hasDiscount && product.compareAtPrice != null)
                      SizedBox(width: 8),
                    // السعر الجديد
                    Text(
                      '${product.basePrice.toStringAsFixed(0)} ر.س',
                      style: TextStyle(
                        color: Colors.red,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                
                SizedBox(height: 4),
                
                // نسبة الخصم
                if (product.hasDiscount && product.compareAtPrice != null)
                  Text(
                    'وفر ${(product.compareAtPrice! - product.basePrice).toStringAsFixed(0)} ر.س',
                  style: TextStyle(
                    color: Colors.green,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
```

### 2. Products on Offer Screen

```dart
// lib/features/products/presentation/screens/products_on_offer_screen.dart

class ProductsOnOfferScreen extends StatefulWidget {
  @override
  _ProductsOnOfferScreenState createState() => _ProductsOnOfferScreenState();
}

class _ProductsOnOfferScreenState extends State<ProductsOnOfferScreen> {
  final ProductsOnOfferCubit _cubit = GetIt.instance<ProductsOnOfferCubit>();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _cubit.loadProducts();
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= 
        _scrollController.position.maxScrollExtent * 0.9) {
      _cubit.loadProducts();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('العروض'),
        actions: [
          IconButton(
            icon: Icon(Icons.filter_list),
            onPressed: () => _showFilterDialog(),
          ),
        ],
      ),
      body: BlocBuilder<ProductsOnOfferCubit, ProductsOnOfferState>(
        bloc: _cubit,
        builder: (context, state) {
          if (state is ProductsOnOfferLoading && _cubit.products.isEmpty) {
            return Center(child: CircularProgressIndicator());
          }

          if (state is ProductsOnOfferError) {
            return Center(child: Text(state.message));
          }

          if (state is ProductsOnOfferLoaded) {
            if (state.products.isEmpty) {
              return Center(child: Text('لا توجد عروض متاحة'));
            }

            return RefreshIndicator(
              onRefresh: () => _cubit.loadProducts(refresh: true),
              child: GridView.builder(
                controller: _scrollController,
                padding: EdgeInsets.all(8),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 0.7,
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                ),
                itemCount: state.products.length + (state.hasMore ? 1 : 0),
                itemBuilder: (context, index) {
                  if (index >= state.products.length) {
                    return Center(child: CircularProgressIndicator());
                  }
                  return ProductOfferCard(product: state.products[index]);
                },
              ),
            );
          }

          return SizedBox.shrink();
        },
      ),
    );
  }

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('تصفية العروض'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Sort By
              DropdownButtonFormField<String>(
                value: _cubit.sortBy,
                decoration: InputDecoration(labelText: 'ترتيب حسب'),
                items: [
                  DropdownMenuItem(value: 'discount', child: Text('نسبة الخصم')),
                  DropdownMenuItem(value: 'price', child: Text('السعر')),
                  DropdownMenuItem(value: 'createdAt', child: Text('الأحدث')),
                ],
                onChanged: (value) {
                  if (value != null) {
                    _cubit.updateFilters(sortBy: value);
                    Navigator.pop(context);
                  }
                },
              ),
              
              SizedBox(height: 16),
              
              // Min Discount
              TextField(
                decoration: InputDecoration(
                  labelText: 'الحد الأدنى للخصم (%)',
                ),
                keyboardType: TextInputType.number,
                onChanged: (value) {
                  final discount = double.tryParse(value);
                  _cubit.updateFilters(minDiscount: discount);
                },
              ),
              
              SizedBox(height: 16),
              
              // Max Discount
              TextField(
                decoration: InputDecoration(
                  labelText: 'الحد الأقصى للخصم (%)',
                ),
                keyboardType: TextInputType.number,
                onChanged: (value) {
                  final discount = double.tryParse(value);
                  _cubit.updateFilters(maxDiscount: discount);
                },
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('إلغاء'),
          ),
          TextButton(
            onPressed: () {
              _cubit.loadProducts(refresh: true);
              Navigator.pop(context);
            },
            child: Text('تطبيق'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }
}
```

---

## 📊 أمثلة الاستخدام

### مثال 1: جلب جميع المنتجات ذات العروض

```dart
final cubit = GetIt.instance<ProductsOnOfferCubit>();
await cubit.loadProducts();
```

### مثال 2: تصفية حسب نسبة الخصم

```dart
// عروض بخصم من 10% إلى 50%
cubit.updateFilters(
  minDiscount: 10,
  maxDiscount: 50,
);
```

### مثال 3: ترتيب حسب السعر

```dart
cubit.updateFilters(
  sortBy: 'price',
  sortOrder: 'asc', // من الأقل للأعلى
);
```

### مثال 4: تصفية حسب الفئة

```dart
cubit.updateFilters(
  categoryId: '507f1f77bcf86cd799439011',
);
```

---

## 🔍 التحقق من عرض المنتج

عند عرض أي منتج، يجب التحقق من وجود عرض مباشر أولاً:

```dart
// في Product Details Screen
void checkProductOffer(Product product) {
  if (product.hasDirectOffer) {
    // عرض السعر القديم والجديد
    // لا تطبق أي عروض أخرى
    showOfferBadge(product.discountPercentage);
  } else {
    // جلب العروض الأخرى (من PromotionsService)
    // تطبيق العروض حسب الأولوية
    loadProductPromotions(product);
  }
}
```

---

## 📝 ملاحظات مهمة

1. **أولوية العرض المباشر**: إذا كان المنتج له `compareAtPrice > basePrice`، لا تطبق أي عروض أخرى عليه.

2. **Endpoint `/products/on-offer`**: يعيد فقط المنتجات التي لديها عروض مباشرة.

3. **Pagination**: استخدم pagination لتحسين الأداء عند وجود عدد كبير من المنتجات.

4. **Caching**: يمكنك cache نتائج `/products/on-offer` لأنها لا تتغير كثيراً.

5. **Real-time Updates**: إذا كنت تريد تحديثات فورية، استخدم WebSocket أو Polling.

---

## 🎯 Best Practices

1. **استخدم Infinite Scroll**: لتحسين تجربة المستخدم
2. **أضف Pull to Refresh**: لتحديث القائمة
3. **عرض نسبة الخصم بوضوح**: استخدم ألوان جذابة للشارات
4. **عرض السعر القديم مشطوب**: لزيادة الإقناع
5. **أضف عداد للوقت المتبقي**: إذا كان متوفراً في API

---

## 🔗 روابط ذات صلة

- [Promotions Module](./promotions.md) - دليل العروض والكوبونات
- [Products Module](./products.md) - دليل المنتجات
- [Catalog Module](./catalog.md) - دليل الكتالوج

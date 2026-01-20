# 🛒 Local Cart Module - نظام السلة المحلية مع المزامنة

## 📋 نظرة عامة

نظام السلة المحلية (Local Cart) يعمل فوراً بدون انتظار السيرفر، مما يوفر تجربة مستخدم سريعة وسلسة. يتم المزامنة مع السيرفر عند الحاجة (قبل الدفع أو عند تسجيل الدخول) للتحقق من المخزون والأسعار.

### المزايا الرئيسية

- ⚡ **عمليات فورية**: إضافة، تعديل، حذف العناصر بدون تأخير
- 🔄 **المزامنة الذكية**: التحقق من المخزون والأسعار قبل الدفع
- 📱 **العمل بدون إنترنت**: إمكانية إضافة المنتجات بدون اتصال
- 🎯 **تجربة مستخدم محسنة**: بدون انتظار استجابات السيرفر

---

## 🏗️ البنية المعمارية

### تدفق العمل

```
┌─────────────────┐
│  المستخدم       │
│  يضيف منتج      │
└────────┬────────┘
         │
         ▼
┌─────────────────┐
│ CartCubit       │
│ addToCartLocal()│
└────────┬────────┘
         │
         ▼
┌─────────────────┐
│LocalDataSource  │
│ حفظ محلي         │
└────────┬────────┘
         │
         ▼
┌─────────────────┐
│ LocalStorage    │
│ SharedPrefs     │
└─────────────────┘

عند الدفع:
┌─────────────────┐
│ CartCubit       │
│ syncCart()      │
└────────┬────────┘
         │
         ▼
┌─────────────────┐
│RemoteDataSource │
│ POST /cart/sync │
└────────┬────────┘
         │
         ▼
┌─────────────────┐
│  السيرفر        │
│  التحقق من:     │
│  - المخزون      │
│  - الأسعار      │
│  - التوفر       │
└────────┬────────┘
         │
         ▼
┌─────────────────┐
│ SyncResult      │
│ - المنتجات      │
│   المحذوفة      │
│ - الأسعار       │
│   المتغيرة      │
│ - الكميات       │
│   المعدلة       │
└─────────────────┘
```

---

## 📦 المكونات الرئيسية

### 1. LocalCartItemModel

نموذج عنصر السلة المحلي:

```dart
class LocalCartItemModel {
  final String productId;
  final int quantity;
  final double unitPrice;
  final DateTime addedAt;
  
  // معلومات المنتج (اختيارية، للعرض)
  final String? productName;
  final String? productNameAr;
  final String? productImage;
  final String? productSku;
  
  double get totalPrice => quantity * unitPrice;
}
```

### 2. CartLocalDataSource

واجهة لحفظ وجلب السلة المحلية:

```dart
abstract class CartLocalDataSource {
  Future<List<LocalCartItemModel>> getLocalCart();
  Future<void> saveLocalCart(List<LocalCartItemModel> items);
  Future<List<LocalCartItemModel>> addToCartLocal({...});
  Future<List<LocalCartItemModel>> updateQuantityLocal({...});
  Future<List<LocalCartItemModel>> removeFromCartLocal({...});
  Future<void> clearCartLocal();
  Future<int> getLocalCartCount();
}
```

### 3. CartSyncResultEntity

نتائج المزامنة من السيرفر:

```dart
class CartSyncResultEntity {
  final CartEntity syncedCart;
  final List<RemovedCartItem> removedItems;      // المنتجات المحذوفة
  final List<PriceChangedCartItem> priceChangedItems;  // المنتجات التي تغير سعرها
  final List<QuantityAdjustedCartItem> quantityAdjustedItems;  // المنتجات التي تم تعديل كميتها
  
  bool get hasIssues => 
    removedItems.isNotEmpty || 
    priceChangedItems.isNotEmpty || 
    quantityAdjustedItems.isNotEmpty;
}
```

---

## 🚀 الاستخدام

### 1. العمليات المحلية (فورية)

#### إضافة منتج للسلة

```dart
// في ProductDetailsScreen أو أي شاشة
context.read<CartCubit>().addToCartLocal(
  productId: product.id,
  quantity: 1,
  unitPrice: product.price,
  productName: product.name,
  productNameAr: product.nameAr,
  productImage: product.image,
  productSku: product.sku,
);

// يتم تحديث الـ UI فوراً بدون انتظار
```

#### تحديث الكمية

```dart
// في CartScreen
context.read<CartCubit>().updateQuantityLocal(
  productId: item.productId,
  quantity: newQuantity,
);

// تحديث فوري للعرض
```

#### حذف منتج

```dart
context.read<CartCubit>().removeFromCartLocal(
  productId: item.productId,
);
```

#### تفريغ السلة

```dart
context.read<CartCubit>().clearCartLocal();
```

### 2. جلب السلة المحلية

```dart
// في CartScreen initState
@override
void initState() {
  super.initState();
  context.read<CartCubit>().loadLocalCart();
}
```

### 3. المزامنة مع السيرفر

#### عند الضغط على Checkout

```dart
// في CartScreen
Future<void> _handleCheckout() async {
  // عرض loading
  showDialog(context: context, builder: (_) => LoadingDialog());
  
  // المزامنة
  final result = await context.read<CartCubit>().syncCart();
  
  // إغلاق loading
  Navigator.pop(context);
  
  if (result == null) {
    // فشلت المزامنة
    showErrorDialog('فشلت المزامنة');
    return;
  }
  
  // التحقق من النتائج
  if (result.hasIssues) {
    // عرض نتائج المزامنة
    _showSyncIssuesDialog(result);
  } else {
    // المتابعة للدفع
    context.push('/checkout');
  }
}
```

#### عرض نتائج المزامنة

```dart
void _showSyncIssuesDialog(CartSyncResultEntity result) {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: Text('تحديثات السلة'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // المنتجات المحذوفة
          if (result.removedItems.isNotEmpty) ...[
            Text('تم حذف المنتجات التالية:'),
            ...result.removedItems.map((item) => 
              ListTile(
                title: Text(item.productNameAr ?? item.productId),
                subtitle: Text(_getRemovalReason(item.reason)),
              ),
            ),
          ],
          
          // الأسعار المتغيرة
          if (result.priceChangedItems.isNotEmpty) ...[
            Text('تغيرت أسعار المنتجات التالية:'),
            ...result.priceChangedItems.map((item) => 
              ListTile(
                title: Text(item.productNameAr ?? item.productId),
                subtitle: Text(
                  '${item.oldPrice} → ${item.newPrice}'
                ),
              ),
            ),
          ],
          
          // الكميات المعدلة
          if (result.quantityAdjustedItems.isNotEmpty) ...[
            Text('تم تعديل كميات المنتجات التالية:'),
            ...result.quantityAdjustedItems.map((item) => 
              ListTile(
                title: Text(item.productNameAr ?? item.productId),
                subtitle: Text(
                  'الكمية المطلوبة: ${item.requestedQuantity}\n'
                  'الكمية المتاحة: ${item.availableQuantity}\n'
                  'الكمية النهائية: ${item.finalQuantity}'
                ),
              ),
            ),
          ],
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text('إلغاء'),
        ),
        ElevatedButton(
          onPressed: () {
            Navigator.pop(context);
            context.push('/checkout');
          },
          child: Text('موافق والمتابعة'),
        ),
      ],
    ),
  );
}

String _getRemovalReason(String reason) {
  switch (reason) {
    case 'out_of_stock':
      return 'نفذ المخزون';
    case 'deleted':
      return 'تم حذف المنتج';
    case 'inactive':
      return 'المنتج غير متاح';
    default:
      return 'غير متاح';
  }
}
```

### 4. المزامنة عند تسجيل الدخول

```dart
// في AuthRepositoryImpl أو AuthCubit
Future<void> login(String phone, String password) async {
  // ... login logic
  
  // بعد تسجيل الدخول بنجاح
  await context.read<CartCubit>().syncCart(silent: true);
  
  // silent: true يعني عدم عرض loading أو أخطاء
}
```

### 5. الاستماع لحالة السلة

```dart
BlocBuilder<CartCubit, CartState>(
  builder: (context, state) {
    if (state is CartLoaded) {
      final cart = state.cart;
      
      return Column(
        children: [
          // عرض العناصر
          ...cart.items.map((item) => CartItemWidget(item: item)),
          
          // الإجمالي
          Text('الإجمالي: ${cart.total}'),
          
          // زر الدفع
          ElevatedButton(
            onPressed: _handleCheckout,
            child: Text('الدفع'),
          ),
        ],
      );
    } else if (state is CartSyncing) {
      return CircularProgressIndicator();
    } else if (state is CartSyncCompleted) {
      // عرض نتائج المزامنة
      final result = state.syncResult;
      if (result.hasIssues) {
        return _SyncIssuesWidget(result: result);
      }
      return Text('تمت المزامنة بنجاح');
    } else if (state is CartSyncError) {
      return Text('خطأ في المزامنة: ${state.message}');
    }
    
    return SizedBox.shrink();
  },
)
```

---

## 🔌 Backend Integration

### Sync Endpoint

**Endpoint:** `POST /cart/sync`

**Headers:** 
```
Authorization: Bearer <token>
Content-Type: application/json
```

**Request Body:**
```json
{
  "items": [
    {
      "productId": "507f1f77bcf86cd799439011",
      "quantity": 2,
      "unitPrice": 150.00
    },
    {
      "productId": "507f1f77bcf86cd799439012",
      "quantity": 1,
      "unitPrice": 200.00
    }
  ]
}
```

**Response:**
```json
{
  "success": true,
  "data": {
    "cart": {
      "_id": "...",
      "customerId": "...",
      "status": "active",
      "items": [
        {
          "productId": "507f1f77bcf86cd799439011",
          "quantity": 2,
          "unitPrice": 150.00,
          "totalPrice": 300.00,
          "addedAt": "2024-01-01T00:00:00Z"
        },
        {
          "productId": "507f1f77bcf86cd799439012",
          "quantity": 1,
          "unitPrice": 180.00,
          "totalPrice": 180.00,
          "addedAt": "2024-01-01T00:00:00Z"
        }
      ],
      "itemsCount": 3,
      "subtotal": 480.00,
      "discount": 0,
      "taxAmount": 0,
      "shippingCost": 0,
      "total": 480.00,
      "couponId": null,
      "couponCode": null,
      "couponDiscount": 0
    },
    "removedItems": [
      {
        "productId": "507f1f77bcf86cd799439013",
        "reason": "out_of_stock",
        "productName": "Product Name",
        "productNameAr": "اسم المنتج"
      }
    ],
    "priceChangedItems": [
      {
        "productId": "507f1f77bcf86cd799439012",
        "oldPrice": 200.00,
        "newPrice": 180.00,
        "productName": "Product Name",
        "productNameAr": "اسم المنتج"
      }
    ],
    "quantityAdjustedItems": [
      {
        "productId": "507f1f77bcf86cd799439011",
        "requestedQuantity": 5,
        "availableQuantity": 2,
        "finalQuantity": 2,
        "productName": "Product Name",
        "productNameAr": "اسم المنتج"
      }
    ]
  },
  "message": "Cart synced successfully",
  "messageAr": "تمت مزامنة السلة بنجاح"
}
```

---

## 📝 Best Practices

### 1. استخدام العمليات المحلية دائماً

```dart
// ✅ صحيح - استخدام العمليات المحلية
context.read<CartCubit>().addToCartLocal(...);

// ❌ خاطئ - لا تستخدم العمليات البعيدة للعمليات اليومية
context.read<CartCubit>().addToCart(...);  // هذا بطيء!
```

### 2. المزامنة فقط عند الحاجة

```dart
// ✅ صحيح - المزامنة عند الدفع
await cartCubit.syncCart();

// ❌ خاطئ - لا تزامن بعد كل عملية
await cartCubit.addToCartLocal(...);
await cartCubit.syncCart();  // لا حاجة!
```

### 3. معالجة نتائج المزامنة

```dart
// ✅ صحيح - عرض النتائج للمستخدم
final result = await cartCubit.syncCart();
if (result?.hasIssues == true) {
  _showSyncIssuesDialog(result!);
}

// ❌ خاطئ - تجاهل النتائج
await cartCubit.syncCart();  // المستخدم لا يعلم بالتغييرات!
```

### 4. حفظ معلومات المنتج مع العنصر

```dart
// ✅ صحيح - حفظ معلومات المنتج للعرض
await cartCubit.addToCartLocal(
  productId: product.id,
  quantity: 1,
  unitPrice: product.price,
  productName: product.name,
  productNameAr: product.nameAr,
  productImage: product.image,
);

// ❌ خاطئ - حفظ فقط productId
await cartCubit.addToCartLocal(
  productId: product.id,  // فقط! ستحتاج جلب المنتج مرة أخرى للعرض
  quantity: 1,
  unitPrice: product.price,
);
```

### 5. استخدام Silent Sync عند الحاجة

```dart
// ✅ صحيح - silent sync عند تسجيل الدخول
await cartCubit.syncCart(silent: true);

// ✅ صحيح - sync عادي عند الدفع
await cartCubit.syncCart();  // silent: false (default)
```

---

## 🔄 تدفق المزامنة التفصيلي

### 1. المزامنة عند الدفع

```
المستخدم → Checkout Button
    ↓
CartCubit.syncCart()
    ↓
CartSyncing State (عرض loading)
    ↓
LocalDataSource.getLocalCart()
    ↓
RemoteDataSource.syncCartWithResults()
    ↓
POST /cart/sync
    ↓
السيرفر يتحقق من:
    - وجود المنتج ونشاطه
    - المخزون المتاح
    - السعر الحالي
    ↓
CartSyncResultEntity
    ↓
LocalDataSource.saveLocalCart() (تحديث السلة المحلية)
    ↓
CartSyncCompleted State
    ↓
إذا hasIssues:
    - عرض Dialog مع النتائج
    - انتظار موافقة المستخدم
    ↓
المتابعة للدفع
```

### 2. المزامنة عند تسجيل الدخول

```
المستخدم → Login
    ↓
AuthRepository.login()
    ↓
بعد نجاح Login
    ↓
CartCubit.syncCart(silent: true)
    ↓
LocalDataSource.getLocalCart()
    ↓
RemoteDataSource.syncCartWithResults()
    ↓
السيرفر يدمج السلات (المحلية + على السيرفر)
    ↓
LocalDataSource.saveLocalCart() (تحديث السلة المحلية)
    ↓
CartSyncCompleted (بدون إشعارات)
```

---

## ⚠️ ملاحظات مهمة

1. **الكوبونات**: لا يتم حفظها محلياً. التحقق من الكوبونات يكون فقط في مرحلة الدفع.

2. **الحفظ التلقائي**: يتم حفظ السلة المحلية تلقائياً بعد كل عملية محلية.

3. **معالجة الأخطاء**: عند فشل المزامنة، تبقى السلة المحلية كما هي.

4. **التزامن**: عند تسجيل الدخول على جهاز جديد، يتم دمج السلات (المحلية + على السيرفر).

5. **الأداء**: العمليات المحلية فورية بدون أي تأخير.

6. **التخزين**: السلة المحلية محفوظة في `SharedPreferences` باستخدام مفتاح `cart_items`.

---

## 📚 أمثلة كاملة

### مثال: ProductDetailsScreen

```dart
class ProductDetailsScreen extends StatelessWidget {
  final ProductEntity product;
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // عرض المنتج
          ProductDetails(product: product),
          
          // زر إضافة للسلة
          ElevatedButton(
            onPressed: () {
              context.read<CartCubit>().addToCartLocal(
                productId: product.id,
                quantity: 1,
                unitPrice: product.price,
                productName: product.name,
                productNameAr: product.nameAr,
                productImage: product.images.firstOrNull,
                productSku: product.sku,
              );
              
              // عرض رسالة نجاح
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('تمت الإضافة للسلة')),
              );
            },
            child: Text('أضف للسلة'),
          ),
        ],
      ),
    );
  }
}
```

### مثال: CartScreen كامل

```dart
class CartScreen extends StatefulWidget {
  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  @override
  void initState() {
    super.initState();
    // جلب السلة المحلية
    context.read<CartCubit>().loadLocalCart();
  }
  
  Future<void> _handleCheckout() async {
    // عرض loading
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => Center(child: CircularProgressIndicator()),
    );
    
    // المزامنة
    final result = await context.read<CartCubit>().syncCart();
    
    // إغلاق loading
    Navigator.pop(context);
    
    if (result == null) {
      // فشلت المزامنة
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('فشلت المزامنة. حاول مرة أخرى.')),
      );
      return;
    }
    
    // التحقق من النتائج
    if (result.hasIssues) {
      // عرض نتائج المزامنة
      await _showSyncIssuesDialog(result);
    } else {
      // المتابعة للدفع
      context.push('/checkout');
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('السلة')),
      body: BlocBuilder<CartCubit, CartState>(
        builder: (context, state) {
          if (state is CartLoaded) {
            final cart = state.cart;
            
            if (cart.isEmpty) {
              return Center(child: Text('السلة فارغة'));
            }
            
            return Column(
              children: [
                // قائمة العناصر
                Expanded(
                  child: ListView.builder(
                    itemCount: cart.items.length,
                    itemBuilder: (context, index) {
                      final item = cart.items[index];
                      return CartItemCard(
                        item: item,
                        onQuantityChanged: (newQuantity) {
                          context.read<CartCubit>().updateQuantityLocal(
                            item.productId,
                            newQuantity,
                          );
                        },
                        onRemove: () {
                          context.read<CartCubit>().removeFromCartLocal(
                            item.productId,
                          );
                        },
                      );
                    },
                  ),
                ),
                
                // الملخص
                CartSummary(cart: cart),
                
                // زر الدفع
                Padding(
                  padding: EdgeInsets.all(16),
                  child: ElevatedButton(
                    onPressed: _handleCheckout,
                    style: ElevatedButton.styleFrom(
                      minimumSize: Size(double.infinity, 50),
                    ),
                    child: Text('الدفع'),
                  ),
                ),
              ],
            );
          } else if (state is CartSyncing) {
            return Center(child: CircularProgressIndicator());
          } else if (state is CartSyncCompleted) {
            // بعد المزامنة، نعرض السلة المحدثة
            return build(context);  // rebuild
          }
          
          return Center(child: CircularProgressIndicator());
        },
      ),
    );
  }
}
```

---

## 🐛 Troubleshooting

### المشكلة: السلة لا تظهر بعد الإضافة

**الحل:**
```dart
// تأكد من استدعاء loadLocalCart() في initState
@override
void initState() {
  super.initState();
  context.read<CartCubit>().loadLocalCart();
}
```

### المشكلة: المزامنة تفشل

**الحل:**
```dart
// تحقق من وجود token
// تأكد من الاتصال بالإنترنت
// تحقق من format البيانات المرسلة
```

### المشكلة: السلة المحلية لا تزامن مع السيرفر

**الحل:**
```dart
// تأكد من استدعاء syncCart() قبل الدفع
// تحقق من أن syncCartWithResults() موجودة في RemoteDataSource
```

---

## 📞 الدعم

للمزيد من المعلومات أو المساعدة، يرجى الرجوع إلى:
- [Orders Module Documentation](./orders.md)
- [API Documentation](../../backend/README.md)

---

**آخر تحديث:** 2024-01-01

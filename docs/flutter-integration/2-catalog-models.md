# 📚 Catalog Models - نماذج الكتالوج

## 📋 نظرة عامة

هذا الملف يحتوي على جميع Flutter Models المستخدمة في Catalog Module:
- ✅ العلامات التجارية (Brands)
- ✅ الأقسام والتصنيفات (Categories)
- ✅ الأجهزة/الموديلات (Devices)
- ✅ أنواع الجودة (Quality Types)

---

## 📁 Flutter Models

### Brand Model

```dart
class Brand {
  final String id;
  final String name;
  final String nameAr;
  final String slug;
  final String? description;
  final String? descriptionAr;
  final String? logo;
  final String? website;
  final bool isActive;
  final bool isFeatured;
  final int displayOrder;
  final int productsCount;
  final DateTime createdAt;
  final DateTime updatedAt;

  Brand({
    required this.id,
    required this.name,
    required this.nameAr,
    required this.slug,
    this.description,
    this.descriptionAr,
    this.logo,
    this.website,
    required this.isActive,
    required this.isFeatured,
    required this.displayOrder,
    required this.productsCount,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Brand.fromJson(Map<String, dynamic> json) {
    return Brand(
      id: json['_id'] ?? json['id'],
      name: json['name'],
      nameAr: json['nameAr'],
      slug: json['slug'],
      description: json['description'],
      descriptionAr: json['descriptionAr'],
      logo: json['logo'],
      website: json['website'],
      isActive: json['isActive'] ?? true,
      isFeatured: json['isFeatured'] ?? false,
      displayOrder: json['displayOrder'] ?? 0,
      productsCount: json['productsCount'] ?? 0,
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }

  /// الحصول على الاسم حسب اللغة
  String getName(String locale) => locale == 'ar' ? nameAr : name;
  
  /// الحصول على الوصف حسب اللغة
  String? getDescription(String locale) => 
      locale == 'ar' ? descriptionAr : description;
}
```

### Category Model

```dart
class Category {
  final String id;
  final String name;
  final String nameAr;
  final String slug;
  final String? description;
  final String? descriptionAr;
  final String? image;
  final String? icon;
  final String? parentId;
  final List<String> ancestors;
  final int level;
  final String? path;
  final bool isActive;
  final bool isFeatured;
  final int displayOrder;
  final int productsCount;
  final int childrenCount;
  final DateTime createdAt;
  final DateTime updatedAt;
  
  // للـ Tree structure
  List<Category>? children;

  Category({
    required this.id,
    required this.name,
    required this.nameAr,
    required this.slug,
    this.description,
    this.descriptionAr,
    this.image,
    this.icon,
    this.parentId,
    required this.ancestors,
    required this.level,
    this.path,
    required this.isActive,
    required this.isFeatured,
    required this.displayOrder,
    required this.productsCount,
    required this.childrenCount,
    required this.createdAt,
    required this.updatedAt,
    this.children,
  });

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['_id'] ?? json['id'],
      name: json['name'],
      nameAr: json['nameAr'],
      slug: json['slug'],
      description: json['description'],
      descriptionAr: json['descriptionAr'],
      image: json['image'],
      icon: json['icon'],
      parentId: json['parentId'],
      ancestors: List<String>.from(json['ancestors'] ?? []),
      level: json['level'] ?? 0,
      path: json['path'],
      isActive: json['isActive'] ?? true,
      isFeatured: json['isFeatured'] ?? false,
      displayOrder: json['displayOrder'] ?? 0,
      productsCount: json['productsCount'] ?? 0,
      childrenCount: json['childrenCount'] ?? 0,
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
      children: json['children'] != null
          ? (json['children'] as List)
              .map((c) => Category.fromJson(c))
              .toList()
          : null,
    );
  }

  /// هل هذا قسم رئيسي؟
  bool get isRoot => parentId == null && level == 0;
  
  /// هل لديه أقسام فرعية؟
  bool get hasChildren => childrenCount > 0;
  
  /// الحصول على الاسم حسب اللغة
  String getName(String locale) => locale == 'ar' ? nameAr : name;
}
```

### Device Model

```dart
class Device {
  final String id;
  final String brandId;
  final String name;
  final String nameAr;
  final String slug;
  final String? modelNumber;
  final String? image;
  final String? screenSize;
  final int? releaseYear;
  final List<String>? colors;
  final List<String>? storageOptions;
  final bool isActive;
  final bool isPopular;
  final int displayOrder;
  final int productsCount;
  final DateTime createdAt;
  final DateTime updatedAt;
  
  // يمكن تعبئتها إذا تم populate
  Brand? brand;

  Device({
    required this.id,
    required this.brandId,
    required this.name,
    required this.nameAr,
    required this.slug,
    this.modelNumber,
    this.image,
    this.screenSize,
    this.releaseYear,
    this.colors,
    this.storageOptions,
    required this.isActive,
    required this.isPopular,
    required this.displayOrder,
    required this.productsCount,
    required this.createdAt,
    required this.updatedAt,
    this.brand,
  });

  factory Device.fromJson(Map<String, dynamic> json) {
    return Device(
      id: json['_id'] ?? json['id'],
      brandId: json['brandId'] is String 
          ? json['brandId'] 
          : json['brandId']['_id'],
      name: json['name'],
      nameAr: json['nameAr'],
      slug: json['slug'],
      modelNumber: json['modelNumber'],
      image: json['image'],
      screenSize: json['screenSize'],
      releaseYear: json['releaseYear'],
      colors: json['colors'] != null 
          ? List<String>.from(json['colors']) 
          : null,
      storageOptions: json['storageOptions'] != null 
          ? List<String>.from(json['storageOptions']) 
          : null,
      isActive: json['isActive'] ?? true,
      isPopular: json['isPopular'] ?? false,
      displayOrder: json['displayOrder'] ?? 0,
      productsCount: json['productsCount'] ?? 0,
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
      brand: json['brandId'] is Map 
          ? Brand.fromJson(json['brandId']) 
          : null,
    );
  }

  /// الحصول على الاسم حسب اللغة
  String getName(String locale) => locale == 'ar' ? nameAr : name;
}
```

### QualityType Model

```dart
class QualityType {
  final String id;
  final String name;
  final String nameAr;
  final String code;  // "original", "oem", "aaa", "copy"
  final String? description;
  final String? descriptionAr;
  final String? color;  // Badge color (hex)
  final String? icon;
  final int displayOrder;
  final bool isActive;
  final int? defaultWarrantyDays;
  final DateTime createdAt;
  final DateTime updatedAt;

  QualityType({
    required this.id,
    required this.name,
    required this.nameAr,
    required this.code,
    this.description,
    this.descriptionAr,
    this.color,
    this.icon,
    required this.displayOrder,
    required this.isActive,
    this.defaultWarrantyDays,
    required this.createdAt,
    required this.updatedAt,
  });

  factory QualityType.fromJson(Map<String, dynamic> json) {
    return QualityType(
      id: json['_id'] ?? json['id'],
      name: json['name'],
      nameAr: json['nameAr'],
      code: json['code'],
      description: json['description'],
      descriptionAr: json['descriptionAr'],
      color: json['color'],
      icon: json['icon'],
      displayOrder: json['displayOrder'] ?? 0,
      isActive: json['isActive'] ?? true,
      defaultWarrantyDays: json['defaultWarrantyDays'],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }

  /// الحصول على الاسم حسب اللغة
  String getName(String locale) => locale == 'ar' ? nameAr : name;
  
  /// تحويل اللون hex إلى Color
  Color? getColor() {
    if (color == null) return null;
    final hex = color!.replaceFirst('#', '');
    return Color(int.parse('FF$hex', radix: 16));
  }
}
```

### CategoryWithBreadcrumb Model

```dart
class CategoryWithBreadcrumb {
  final Category category;
  final List<BreadcrumbItem> breadcrumb;

  CategoryWithBreadcrumb({
    required this.category,
    required this.breadcrumb,
  });

  factory CategoryWithBreadcrumb.fromJson(Map<String, dynamic> json) {
    return CategoryWithBreadcrumb(
      category: Category.fromJson(json['category']),
      breadcrumb: (json['breadcrumb'] as List)
          .map((b) => BreadcrumbItem.fromJson(b))
          .toList(),
    );
  }
}

class BreadcrumbItem {
  final String id;
  final String name;
  final String nameAr;
  final String slug;

  BreadcrumbItem({
    required this.id,
    required this.name,
    required this.nameAr,
    required this.slug,
  });

  factory BreadcrumbItem.fromJson(Map<String, dynamic> json) {
    return BreadcrumbItem(
      id: json['_id'] ?? json['id'],
      name: json['name'],
      nameAr: json['nameAr'],
      slug: json['slug'],
    );
  }
}
```

---

> 🔗 **التالي:**
> - [Brands API](./2-catalog-brands.md) - دليل ربط العلامات التجارية
> - [Categories API](./2-catalog-categories.md) - دليل ربط الأقسام
> - [Devices & Quality Types](./2-catalog-devices-quality.md) - دليل ربط الأجهزة وأنواع الجودة

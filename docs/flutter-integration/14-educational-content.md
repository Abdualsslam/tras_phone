# 📚 Educational Content Module - دليل ربط المحتوى التعليمي

## 📋 نظرة عامة

هذا الموديول يتعامل مع:
- ✅ الفئات التعليمية (Categories)
- ✅ المحتوى التعليمي (Articles, Videos, Tutorials, Tips, Guides)
- ✅ البحث والفلترة حسب الفئة والنوع
- ✅ المحتوى المميز (Featured Content)
- ✅ الإعجاب والمشاركة (Like & Share)
- ✅ ربط المحتوى بالمنتجات ذات الصلة

> **ملاحظة**: جميع الـ endpoints هنا **عامة (Public)** ولا تحتاج Token، باستثناء عمليات الإعجاب والمشاركة التي يمكن استخدامها بدون Token أيضاً.

---

## 📁 Flutter Models

### Educational Category Model

```dart
class EducationalCategory {
  final String id;
  final String name;
  final String? nameAr;
  final String slug;
  final String? description;
  final String? descriptionAr;
  final String? icon;
  final String? image;
  final String? parentId;
  final int contentCount;
  final int sortOrder;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;
  
  // Populated parent category
  EducationalCategory? parent;

  EducationalCategory({
    required this.id,
    required this.name,
    this.nameAr,
    required this.slug,
    this.description,
    this.descriptionAr,
    this.icon,
    this.image,
    this.parentId,
    this.contentCount = 0,
    this.sortOrder = 0,
    this.isActive = true,
    required this.createdAt,
    required this.updatedAt,
    this.parent,
  });

  factory EducationalCategory.fromJson(Map<String, dynamic> json) {
    return EducationalCategory(
      id: json['_id'] ?? json['id'],
      name: json['name'],
      nameAr: json['nameAr'],
      slug: json['slug'],
      description: json['description'],
      descriptionAr: json['descriptionAr'],
      icon: json['icon'],
      image: json['image'],
      parentId: json['parentId'] is String 
          ? json['parentId'] 
          : json['parentId']?['_id']?.toString(),
      contentCount: json['contentCount'] ?? 0,
      sortOrder: json['sortOrder'] ?? 0,
      isActive: json['isActive'] ?? true,
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
      parent: json['parentId'] is Map 
          ? EducationalCategory.fromJson(json['parentId']) 
          : null,
    );
  }

  /// الحصول على الاسم حسب اللغة
  String getName(String locale) => 
      locale == 'ar' && nameAr != null ? nameAr! : name;
  
  /// الحصول على الوصف حسب اللغة
  String? getDescription(String locale) => 
      locale == 'ar' && descriptionAr != null ? descriptionAr : description;
  
  /// هل لديه محتوى؟
  bool get hasContent => contentCount > 0;
}
```

### Content Type Enum

```dart
enum ContentType {
  article,
  video,
  tutorial,
  tip,
  guide;

  String get value {
    switch (this) {
      case ContentType.article: return 'article';
      case ContentType.video: return 'video';
      case ContentType.tutorial: return 'tutorial';
      case ContentType.tip: return 'tip';
      case ContentType.guide: return 'guide';
    }
  }

  String getName(String locale) {
    switch (this) {
      case ContentType.article:
        return locale == 'ar' ? 'مقال' : 'Article';
      case ContentType.video:
        return locale == 'ar' ? 'فيديو' : 'Video';
      case ContentType.tutorial:
        return locale == 'ar' ? 'دليل' : 'Tutorial';
      case ContentType.tip:
        return locale == 'ar' ? 'نصيحة' : 'Tip';
      case ContentType.guide:
        return locale == 'ar' ? 'مرشد' : 'Guide';
    }
  }

  IconData get icon {
    switch (this) {
      case ContentType.article:
        return Icons.article;
      case ContentType.video:
        return Icons.video_library;
      case ContentType.tutorial:
        return Icons.school;
      case ContentType.tip:
        return Icons.lightbulb;
      case ContentType.guide:
        return Icons.menu_book;
    }
  }
}
```

### Difficulty Level Enum

```dart
enum DifficultyLevel {
  beginner,
  intermediate,
  advanced;

  String get value {
    switch (this) {
      case DifficultyLevel.beginner: return 'beginner';
      case DifficultyLevel.intermediate: return 'intermediate';
      case DifficultyLevel.advanced: return 'advanced';
    }
  }

  String getName(String locale) {
    switch (this) {
      case DifficultyLevel.beginner:
        return locale == 'ar' ? 'مبتدئ' : 'Beginner';
      case DifficultyLevel.intermediate:
        return locale == 'ar' ? 'متوسط' : 'Intermediate';
      case DifficultyLevel.advanced:
        return locale == 'ar' ? 'متقدم' : 'Advanced';
    }
  }

  Color get color {
    switch (this) {
      case DifficultyLevel.beginner:
        return Colors.green;
      case DifficultyLevel.intermediate:
        return Colors.orange;
      case DifficultyLevel.advanced:
        return Colors.red;
    }
  }
}
```

### Educational Content Model

```dart
class EducationalContent {
  final String id;
  final String title;
  final String? titleAr;
  final String slug;
  final String categoryId;
  final ContentType type;
  
  // Content
  final String? excerpt;
  final String? excerptAr;
  final String content;
  final String? contentAr;
  
  // Media
  final String? featuredImage;
  final String? videoUrl;
  final int? videoDuration; // in seconds
  
  // Attachments
  final List<String> attachments;
  
  // Related
  final List<String>? relatedProducts;
  final List<String>? relatedContent;
  final List<String> tags;
  
  // SEO
  final String? metaTitle;
  final String? metaDescription;
  
  // Status
  final String status; // 'draft' | 'published' | 'archived'
  final DateTime? publishedAt;
  final bool isFeatured;
  
  // Stats
  final int viewCount;
  final int likeCount;
  final int shareCount;
  
  // Reading
  final int? readingTime; // in minutes
  final DifficultyLevel difficulty;
  
  final DateTime createdAt;
  final DateTime updatedAt;
  
  // Populated fields
  EducationalCategory? category;
  List<Product>? relatedProductsList;
  List<EducationalContent>? relatedContentList;

  EducationalContent({
    required this.id,
    required this.title,
    this.titleAr,
    required this.slug,
    required this.categoryId,
    this.type = ContentType.article,
    this.excerpt,
    this.excerptAr,
    required this.content,
    this.contentAr,
    this.featuredImage,
    this.videoUrl,
    this.videoDuration,
    this.attachments = const [],
    this.relatedProducts,
    this.relatedContent,
    this.tags = const [],
    this.metaTitle,
    this.metaDescription,
    this.status = 'draft',
    this.publishedAt,
    this.isFeatured = false,
    this.viewCount = 0,
    this.likeCount = 0,
    this.shareCount = 0,
    this.readingTime,
    this.difficulty = DifficultyLevel.beginner,
    required this.createdAt,
    required this.updatedAt,
    this.category,
    this.relatedProductsList,
    this.relatedContentList,
  });

  factory EducationalContent.fromJson(Map<String, dynamic> json) {
    // Parse category
    EducationalCategory? categoryObj;
    if (json['categoryId'] is Map) {
      categoryObj = EducationalCategory.fromJson(json['categoryId']);
    }

    // Parse related products
    List<Product>? productsList;
    if (json['relatedProducts'] != null && json['relatedProducts'] is List) {
      productsList = (json['relatedProducts'] as List)
          .map((p) => Product.fromJson(p))
          .toList();
    }

    // Parse related content
    List<EducationalContent>? contentList;
    if (json['relatedContent'] != null && json['relatedContent'] is List) {
      contentList = (json['relatedContent'] as List)
          .map((c) => EducationalContent.fromJson(c))
          .toList();
    }

    return EducationalContent(
      id: json['_id'] ?? json['id'],
      title: json['title'],
      titleAr: json['titleAr'],
      slug: json['slug'],
      categoryId: json['categoryId'] is String 
          ? json['categoryId'] 
          : json['categoryId']?['_id']?.toString() ?? '',
      type: ContentType.values.firstWhere(
        (e) => e.value == json['type'],
        orElse: () => ContentType.article,
      ),
      excerpt: json['excerpt'],
      excerptAr: json['excerptAr'],
      content: json['content'],
      contentAr: json['contentAr'],
      featuredImage: json['featuredImage'],
      videoUrl: json['videoUrl'],
      videoDuration: json['videoDuration'],
      attachments: List<String>.from(json['attachments'] ?? []),
      relatedProducts: json['relatedProducts'] != null
          ? (json['relatedProducts'] as List)
              .map((p) => p is String ? p : p['_id']?.toString() ?? '')
              .toList()
          : null,
      relatedContent: json['relatedContent'] != null
          ? (json['relatedContent'] as List)
              .map((c) => c is String ? c : c['_id']?.toString() ?? '')
              .toList()
          : null,
      tags: List<String>.from(json['tags'] ?? []),
      metaTitle: json['metaTitle'],
      metaDescription: json['metaDescription'],
      status: json['status'] ?? 'draft',
      publishedAt: json['publishedAt'] != null 
          ? DateTime.parse(json['publishedAt']) 
          : null,
      isFeatured: json['isFeatured'] ?? false,
      viewCount: json['viewCount'] ?? 0,
      likeCount: json['likeCount'] ?? 0,
      shareCount: json['shareCount'] ?? 0,
      readingTime: json['readingTime'],
      difficulty: DifficultyLevel.values.firstWhere(
        (e) => e.value == json['difficulty'],
        orElse: () => DifficultyLevel.beginner,
      ),
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
      category: categoryObj,
      relatedProductsList: productsList,
      relatedContentList: contentList,
    );
  }

  /// الحصول على العنوان حسب اللغة
  String getTitle(String locale) => 
      locale == 'ar' && titleAr != null ? titleAr! : title;
  
  /// الحصول على الملخص حسب اللغة
  String? getExcerpt(String locale) => 
      locale == 'ar' && excerptAr != null ? excerptAr : excerpt;
  
  /// الحصول على المحتوى حسب اللغة
  String getContentText(String locale) => 
      locale == 'ar' && contentAr != null ? contentAr! : content;
  
  /// هل المحتوى منشور؟
  bool get isPublished => status == 'published';
  
  /// هل يحتوي على فيديو؟
  bool get hasVideo => videoUrl != null && videoUrl!.isNotEmpty;
  
  /// مدة الفيديو بصيغة قابلة للقراءة
  String? get videoDurationFormatted {
    if (videoDuration == null) return null;
    final minutes = videoDuration! ~/ 60;
    final seconds = videoDuration! % 60;
    return '${minutes}:${seconds.toString().padLeft(2, '0')}';
  }
  
  /// وقت القراءة بصيغة قابلة للقراءة
  String get readingTimeFormatted {
    if (readingTime == null) return '';
    return readingTime == 1 
        ? 'دقيقة واحدة' 
        : '$readingTime دقائق';
  }
}
```

---

## 📞 API Endpoints

### 🏷️ Categories

#### 1️⃣ جلب جميع الفئات

**Endpoint:** `GET /educational/categories`

> **ملاحظة**: هذا الـ endpoint يرجع فقط الفئات النشطة (`isActive: true`).

**Response (200 OK):**
```dart
{
  "success": true,
  "data": [
    {
      "_id": "507f1f77bcf86cd799439011",
      "name": "Screen Repair",
      "nameAr": "إصلاح الشاشات",
      "slug": "screen-repair",
      "description": "Learn how to repair phone screens",
      "descriptionAr": "تعلم كيفية إصلاح شاشات الهواتف",
      "icon": "smartphone",
      "image": "https://cdn.example.com/categories/screen-repair.jpg",
      "parentId": null,
      "contentCount": 15,
      "sortOrder": 1,
      "isActive": true,
      "createdAt": "2024-01-01T00:00:00.000Z",
      "updatedAt": "2024-01-01T00:00:00.000Z"
    },
    {
      "_id": "507f1f77bcf86cd799439012",
      "name": "Battery Replacement",
      "nameAr": "تبديل البطاريات",
      "slug": "battery-replacement",
      "contentCount": 8,
      "sortOrder": 2,
      "isActive": true,
      ...
    }
  ],
  "message": "Categories retrieved successfully",
  "messageAr": "تم استرجاع الفئات بنجاح"
}
```

**Flutter Code:**
```dart
class EducationalContentService {
  final Dio _dio;
  
  EducationalContentService(this._dio);
  
  Future<List<EducationalCategory>> getCategories() async {
    try {
      final response = await _dio.get('/educational/categories');
      
      if (response.data['success']) {
        return (response.data['data'] as List)
            .map((c) => EducationalCategory.fromJson(c))
            .toList();
      }
      throw Exception(response.data['messageAr'] ?? response.data['message']);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }
}
```

---

#### 2️⃣ جلب فئة بالـ Slug

**Endpoint:** `GET /educational/categories/:slug`

**Response (200 OK):**
```dart
{
  "success": true,
  "data": {
    "_id": "507f1f77bcf86cd799439011",
    "name": "Screen Repair",
    "nameAr": "إصلاح الشاشات",
    "slug": "screen-repair",
    "description": "Learn how to repair phone screens",
    "descriptionAr": "تعلم كيفية إصلاح شاشات الهواتف",
    "icon": "smartphone",
    "contentCount": 15,
    ...
  },
  "message": "Category retrieved successfully",
  "messageAr": "تم استرجاع الفئة بنجاح"
}
```

**Flutter Code:**
```dart
Future<EducationalCategory> getCategoryBySlug(String slug) async {
  try {
    final response = await _dio.get('/educational/categories/$slug');
    
    if (response.data['success']) {
      return EducationalCategory.fromJson(response.data['data']);
    }
    throw Exception(response.data['messageAr'] ?? response.data['message']);
  } on DioException catch (e) {
    throw _handleError(e);
  }
}
```

---

### 📖 Content

#### 3️⃣ جلب المحتوى التعليمي

**Endpoint:** `GET /educational/content`

**Query Parameters:**
| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `categoryId` | string | ❌ | فلترة حسب الفئة |
| `type` | string | ❌ | `article`, `video`, `tutorial`, `tip`, `guide` |
| `featured` | boolean | ❌ | المحتوى المميز فقط |
| `search` | string | ❌ | البحث في العنوان والمحتوى |
| `page` | number | ❌ | رقم الصفحة (افتراضي: 1) |
| `limit` | number | ❌ | عدد العناصر (افتراضي: 20) |

**Response (200 OK):**
```dart
{
  "success": true,
  "data": [
    {
      "_id": "507f1f77bcf86cd799439021",
      "title": "How to Replace iPhone Screen",
      "titleAr": "كيفية تبديل شاشة الآيفون",
      "slug": "how-to-replace-iphone-screen",
      "categoryId": {
        "_id": "507f1f77bcf86cd799439011",
        "name": "Screen Repair",
        "nameAr": "إصلاح الشاشات",
        "slug": "screen-repair"
      },
      "type": "tutorial",
      "excerpt": "Step-by-step guide to replace iPhone screen",
      "excerptAr": "دليل خطوة بخطوة لتبديل شاشة الآيفون",
      "featuredImage": "https://cdn.example.com/content/screen-repair.jpg",
      "isFeatured": true,
      "viewCount": 1250,
      "likeCount": 45,
      "shareCount": 12,
      "readingTime": 10,
      "difficulty": "intermediate",
      "tags": ["iphone", "screen", "repair"],
      "publishedAt": "2024-01-15T10:00:00.000Z",
      "createdAt": "2024-01-15T10:00:00.000Z",
      "updatedAt": "2024-01-15T10:00:00.000Z"
    }
  ],
  "pagination": {
    "page": 1,
    "limit": 20,
    "total": 45,
    "pages": 3
  },
  "message": "Content retrieved successfully",
  "messageAr": "تم استرجاع المحتوى بنجاح"
}
```

**Flutter Code:**
```dart
Future<Map<String, dynamic>> getContent({
  String? categoryId,
  ContentType? type,
  bool? featured,
  String? search,
  int page = 1,
  int limit = 20,
}) async {
  final queryParams = <String, dynamic>{
    'page': page,
    'limit': limit,
  };
  
  if (categoryId != null) queryParams['categoryId'] = categoryId;
  if (type != null) queryParams['type'] = type.value;
  if (featured != null) queryParams['featured'] = featured;
  if (search != null) queryParams['search'] = search;
  
  try {
    final response = await _dio.get(
      '/educational/content',
      queryParameters: queryParams,
    );
    
    if (response.data['success']) {
      return {
        'content': (response.data['data'] as List)
            .map((c) => EducationalContent.fromJson(c))
            .toList(),
        'pagination': response.data['pagination'],
      };
    }
    throw Exception(response.data['messageAr'] ?? response.data['message']);
  } on DioException catch (e) {
    throw _handleError(e);
  }
}
```

---

#### 4️⃣ جلب المحتوى المميز

**Endpoint:** `GET /educational/content/featured`

**Query Parameters:**
| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `limit` | number | ❌ | عدد العناصر (افتراضي: 6) |

**Response (200 OK):**
```dart
{
  "success": true,
  "data": [
    {
      "_id": "507f1f77bcf86cd799439021",
      "title": "How to Replace iPhone Screen",
      "titleAr": "كيفية تبديل شاشة الآيفون",
      "slug": "how-to-replace-iphone-screen",
      "featuredImage": "https://cdn.example.com/content/screen-repair.jpg",
      "isFeatured": true,
      "viewCount": 1250,
      ...
    }
  ],
  "message": "Featured content retrieved successfully",
  "messageAr": "تم استرجاع المحتوى المميز بنجاح"
}
```

**Flutter Code:**
```dart
Future<List<EducationalContent>> getFeaturedContent({int limit = 6}) async {
  try {
    final response = await _dio.get(
      '/educational/content/featured',
      queryParameters: {'limit': limit},
    );
    
    if (response.data['success']) {
      return (response.data['data'] as List)
          .map((c) => EducationalContent.fromJson(c))
          .toList();
    }
    throw Exception(response.data['messageAr'] ?? response.data['message']);
  } on DioException catch (e) {
    throw _handleError(e);
  }
}
```

---

#### 5️⃣ جلب المحتوى حسب الفئة

**Endpoint:** `GET /educational/content/category/:slug`

**Query Parameters:**
| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `limit` | number | ❌ | عدد العناصر (افتراضي: 20) |

**Response (200 OK):**
```dart
{
  "success": true,
  "data": [
    {
      "_id": "507f1f77bcf86cd799439021",
      "title": "How to Replace iPhone Screen",
      "slug": "how-to-replace-iphone-screen",
      ...
    }
  ],
  "message": "Content retrieved successfully",
  "messageAr": "تم استرجاع المحتوى بنجاح"
}
```

**Flutter Code:**
```dart
Future<List<EducationalContent>> getContentByCategory(
  String categorySlug, {
  int limit = 20,
}) async {
  try {
    final response = await _dio.get(
      '/educational/content/category/$categorySlug',
      queryParameters: {'limit': limit},
    );
    
    if (response.data['success']) {
      return (response.data['data'] as List)
          .map((c) => EducationalContent.fromJson(c))
          .toList();
    }
    throw Exception(response.data['messageAr'] ?? response.data['message']);
  } on DioException catch (e) {
    throw _handleError(e);
  }
}
```

---

#### 6️⃣ جلب محتوى محدد بالـ Slug

**Endpoint:** `GET /educational/content/:slug`

> **ملاحظة**: عند جلب المحتوى، يتم زيادة عدد المشاهدات (`viewCount`) تلقائياً.

**Response (200 OK):**
```dart
{
  "success": true,
  "data": {
    "_id": "507f1f77bcf86cd799439021",
    "title": "How to Replace iPhone Screen",
    "titleAr": "كيفية تبديل شاشة الآيفون",
    "slug": "how-to-replace-iphone-screen",
    "categoryId": {
      "_id": "507f1f77bcf86cd799439011",
      "name": "Screen Repair",
      "nameAr": "إصلاح الشاشات",
      "slug": "screen-repair"
    },
    "type": "tutorial",
    "excerpt": "Step-by-step guide to replace iPhone screen",
    "excerptAr": "دليل خطوة بخطوة لتبديل شاشة الآيفون",
    "content": "<p>Full HTML content here...</p>",
    "contentAr": "<p>المحتوى الكامل بالعربية...</p>",
    "featuredImage": "https://cdn.example.com/content/screen-repair.jpg",
    "videoUrl": "https://youtube.com/watch?v=...",
    "videoDuration": 600,
    "attachments": [
      "https://cdn.example.com/attachments/guide.pdf"
    ],
    "relatedProducts": [
      {
        "_id": "507f1f77bcf86cd799439031",
        "name": "iPhone Screen Replacement",
        "nameAr": "شاشة آيفون بديلة",
        "slug": "iphone-screen-replacement",
        "mainImage": "https://...",
        "basePrice": 150.00
      }
    ],
    "relatedContent": [
      {
        "_id": "507f1f77bcf86cd799439022",
        "title": "iPhone Screen Types",
        "titleAr": "أنواع شاشات الآيفون",
        "slug": "iphone-screen-types",
        "featuredImage": "https://..."
      }
    ],
    "tags": ["iphone", "screen", "repair"],
    "isFeatured": true,
    "viewCount": 1251,
    "likeCount": 45,
    "shareCount": 12,
    "readingTime": 10,
    "difficulty": "intermediate",
    "publishedAt": "2024-01-15T10:00:00.000Z",
    "createdAt": "2024-01-15T10:00:00.000Z",
    "updatedAt": "2024-01-15T10:00:00.000Z"
  },
  "message": "Content retrieved successfully",
  "messageAr": "تم استرجاع المحتوى بنجاح"
}
```

**Flutter Code:**
```dart
Future<EducationalContent> getContentBySlug(String slug) async {
  try {
    final response = await _dio.get('/educational/content/$slug');
    
    if (response.data['success']) {
      return EducationalContent.fromJson(response.data['data']);
    }
    throw Exception(response.data['messageAr'] ?? response.data['message']);
  } on DioException catch (e) {
    throw _handleError(e);
  }
}
```

---

#### 7️⃣ الإعجاب بالمحتوى

**Endpoint:** `POST /educational/content/:id/like`

> **ملاحظة**: يمكن استخدام هذا الـ endpoint بدون Token (Public).

**Response (200 OK):**
```dart
{
  "success": true,
  "data": null,
  "message": "Content liked",
  "messageAr": "تم الإعجاب بالمحتوى"
}
```

**Flutter Code:**
```dart
Future<void> likeContent(String contentId) async {
  try {
    await _dio.post('/educational/content/$contentId/like');
  } on DioException catch (e) {
    throw _handleError(e);
  }
}
```

---

#### 8️⃣ مشاركة المحتوى

**Endpoint:** `POST /educational/content/:id/share`

> **ملاحظة**: يمكن استخدام هذا الـ endpoint بدون Token (Public). يستخدم لتتبع عدد المشاركات.

**Response (200 OK):**
```dart
{
  "success": true,
  "data": null,
  "message": "Share tracked",
  "messageAr": "تم تتبع المشاركة"
}
```

**Flutter Code:**
```dart
Future<void> shareContent(String contentId) async {
  try {
    await _dio.post('/educational/content/$contentId/share');
  } on DioException catch (e) {
    throw _handleError(e);
  }
}
```

---

## 🛠️ EducationalContentService الكامل

```dart
import 'package:dio/dio.dart';

class EducationalContentService {
  final Dio _dio;
  
  EducationalContentService(this._dio);
  
  // ═════════════════════════════════════
  // Categories
  // ═════════════════════════════════════
  
  /// جلب جميع الفئات
  Future<List<EducationalCategory>> getCategories() async {
    try {
      final response = await _dio.get('/educational/categories');
      
      if (response.data['success']) {
        return (response.data['data'] as List)
            .map((c) => EducationalCategory.fromJson(c))
            .toList();
      }
      throw Exception(response.data['messageAr'] ?? response.data['message']);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }
  
  /// جلب فئة بالـ slug
  Future<EducationalCategory> getCategoryBySlug(String slug) async {
    try {
      final response = await _dio.get('/educational/categories/$slug');
      
      if (response.data['success']) {
        return EducationalCategory.fromJson(response.data['data']);
      }
      throw Exception(response.data['messageAr'] ?? response.data['message']);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }
  
  // ═════════════════════════════════════
  // Content
  // ═════════════════════════════════════
  
  /// جلب المحتوى التعليمي
  Future<Map<String, dynamic>> getContent({
    String? categoryId,
    ContentType? type,
    bool? featured,
    String? search,
    int page = 1,
    int limit = 20,
  }) async {
    final queryParams = <String, dynamic>{
      'page': page,
      'limit': limit,
    };
    
    if (categoryId != null) queryParams['categoryId'] = categoryId;
    if (type != null) queryParams['type'] = type.value;
    if (featured != null) queryParams['featured'] = featured;
    if (search != null) queryParams['search'] = search;
    
    try {
      final response = await _dio.get(
        '/educational/content',
        queryParameters: queryParams,
      );
      
      if (response.data['success']) {
        return {
          'content': (response.data['data'] as List)
              .map((c) => EducationalContent.fromJson(c))
              .toList(),
          'pagination': response.data['pagination'],
        };
      }
      throw Exception(response.data['messageAr'] ?? response.data['message']);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }
  
  /// جلب المحتوى المميز
  Future<List<EducationalContent>> getFeaturedContent({int limit = 6}) async {
    try {
      final response = await _dio.get(
        '/educational/content/featured',
        queryParameters: {'limit': limit},
      );
      
      if (response.data['success']) {
        return (response.data['data'] as List)
            .map((c) => EducationalContent.fromJson(c))
            .toList();
      }
      throw Exception(response.data['messageAr'] ?? response.data['message']);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }
  
  /// جلب المحتوى حسب الفئة
  Future<List<EducationalContent>> getContentByCategory(
    String categorySlug, {
    int limit = 20,
  }) async {
    try {
      final response = await _dio.get(
        '/educational/content/category/$categorySlug',
        queryParameters: {'limit': limit},
      );
      
      if (response.data['success']) {
        return (response.data['data'] as List)
            .map((c) => EducationalContent.fromJson(c))
            .toList();
      }
      throw Exception(response.data['messageAr'] ?? response.data['message']);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }
  
  /// جلب محتوى محدد بالـ slug
  Future<EducationalContent> getContentBySlug(String slug) async {
    try {
      final response = await _dio.get('/educational/content/$slug');
      
      if (response.data['success']) {
        return EducationalContent.fromJson(response.data['data']);
      }
      throw Exception(response.data['messageAr'] ?? response.data['message']);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }
  
  /// الإعجاب بالمحتوى
  Future<void> likeContent(String contentId) async {
    try {
      await _dio.post('/educational/content/$contentId/like');
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }
  
  /// مشاركة المحتوى
  Future<void> shareContent(String contentId) async {
    try {
      await _dio.post('/educational/content/$contentId/share');
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }
  
  // ═════════════════════════════════════
  // Error Handling
  // ═════════════════════════════════════
  
  Exception _handleError(DioException e) {
    if (e.response != null) {
      final data = e.response!.data;
      if (data is Map) {
        final message = data['messageAr'] ?? data['message'] ?? 'خطأ غير معروف';
        return Exception(message);
      }
    }
    
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return Exception('انتهت مهلة الاتصال');
      case DioExceptionType.connectionError:
        return Exception('لا يوجد اتصال بالإنترنت');
      default:
        return Exception('حدث خطأ غير متوقع');
    }
  }
}
```

---

## 🎯 State Management - EducationalContentCubit

```dart
import 'package:flutter_bloc/flutter_bloc.dart';

// States
abstract class EducationalContentState {}

class EducationalContentInitial extends EducationalContentState {}

class EducationalContentLoading extends EducationalContentState {}

class CategoriesLoaded extends EducationalContentState {
  final List<EducationalCategory> categories;
  
  CategoriesLoaded(this.categories);
}

class ContentLoaded extends EducationalContentState {
  final List<EducationalContent> content;
  final Map<String, dynamic> pagination;
  
  ContentLoaded(this.content, this.pagination);
}

class ContentDetailLoaded extends EducationalContentState {
  final EducationalContent content;
  
  ContentDetailLoaded(this.content);
}

class EducationalContentError extends EducationalContentState {
  final String message;
  
  EducationalContentError(this.message);
}

// Cubit
class EducationalContentCubit extends Cubit<EducationalContentState> {
  final EducationalContentService _service;
  
  EducationalContentCubit(this._service) : super(EducationalContentInitial());
  
  /// جلب الفئات
  Future<void> loadCategories() async {
    emit(EducationalContentLoading());
    try {
      final categories = await _service.getCategories();
      emit(CategoriesLoaded(categories));
    } catch (e) {
      emit(EducationalContentError(e.toString()));
    }
  }
  
  /// جلب المحتوى
  Future<void> loadContent({
    String? categoryId,
    ContentType? type,
    bool? featured,
    String? search,
    int page = 1,
    int limit = 20,
  }) async {
    emit(EducationalContentLoading());
    try {
      final result = await _service.getContent(
        categoryId: categoryId,
        type: type,
        featured: featured,
        search: search,
        page: page,
        limit: limit,
      );
      emit(ContentLoaded(
        result['content'],
        result['pagination'],
      ));
    } catch (e) {
      emit(EducationalContentError(e.toString()));
    }
  }
  
  /// جلب محتوى محدد
  Future<void> loadContentBySlug(String slug) async {
    emit(EducationalContentLoading());
    try {
      final content = await _service.getContentBySlug(slug);
      emit(ContentDetailLoaded(content));
    } catch (e) {
      emit(EducationalContentError(e.toString()));
    }
  }
  
  /// جلب المحتوى المميز
  Future<void> loadFeaturedContent({int limit = 6}) async {
    emit(EducationalContentLoading());
    try {
      final content = await _service.getFeaturedContent(limit: limit);
      emit(ContentLoaded(content, {}));
    } catch (e) {
      emit(EducationalContentError(e.toString()));
    }
  }
  
  /// الإعجاب بالمحتوى
  Future<void> likeContent(String contentId) async {
    try {
      await _service.likeContent(contentId);
      // يمكن تحديث الحالة المحلية هنا
    } catch (e) {
      emit(EducationalContentError(e.toString()));
    }
  }
  
  /// مشاركة المحتوى
  Future<void> shareContent(String contentId) async {
    try {
      await _service.shareContent(contentId);
    } catch (e) {
      emit(EducationalContentError(e.toString()));
    }
  }
}
```

---

## 🏗️ UI Examples

### Educational Content Home Screen

```dart
class EducationalContentScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => EducationalContentCubit(
        EducationalContentService(dio),
      )..loadCategories()..loadFeaturedContent(),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('المحتوى التعليمي'),
        ),
        body: Column(
          children: [
            // Featured Content Section
            _buildFeaturedSection(context),
            
            // Categories Section
            _buildCategoriesSection(context),
            
            // All Content Section
            _buildAllContentSection(context),
          ],
        ),
      ),
    );
  }
  
  Widget _buildFeaturedSection(BuildContext context) {
    return BlocBuilder<EducationalContentCubit, EducationalContentState>(
      builder: (context, state) {
        if (state is ContentLoaded && state.content.isNotEmpty) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(
                padding: EdgeInsets.all(16),
                child: Text(
                  'محتوى مميز',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              SizedBox(
                height: 200,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: state.content.length,
                  itemBuilder: (context, index) {
                    final content = state.content[index];
                    return _buildFeaturedCard(content);
                  },
                ),
              ),
            ],
          );
        }
        return const SizedBox();
      },
    );
  }
  
  Widget _buildFeaturedCard(EducationalContent content) {
    return Container(
      width: 300,
      margin: const EdgeInsets.only(right: 12),
      child: Card(
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: () {
            // Navigate to content detail
          },
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (content.featuredImage != null)
                Image.network(
                  content.featuredImage!,
                  height: 120,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          content.type.icon,
                          size: 16,
                          color: Colors.blue,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          content.type.getName('ar'),
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.blue,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      content.getTitle('ar'),
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(Icons.visibility, size: 14, color: Colors.grey),
                        const SizedBox(width: 4),
                        Text(
                          '${content.viewCount}',
                          style: TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                        const SizedBox(width: 16),
                        Icon(Icons.favorite, size: 14, color: Colors.grey),
                        const SizedBox(width: 4),
                        Text(
                          '${content.likeCount}',
                          style: TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildCategoriesSection(BuildContext context) {
    return BlocBuilder<EducationalContentCubit, EducationalContentState>(
      builder: (context, state) {
        if (state is CategoriesLoaded) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(
                padding: EdgeInsets.all(16),
                child: Text(
                  'الفئات',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              SizedBox(
                height: 100,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: state.categories.length,
                  itemBuilder: (context, index) {
                    final category = state.categories[index];
                    return _buildCategoryCard(category);
                  },
                ),
              ),
            ],
          );
        }
        return const SizedBox();
      },
    );
  }
  
  Widget _buildCategoryCard(EducationalCategory category) {
    return Container(
      width: 120,
      margin: const EdgeInsets.only(right: 12),
      child: Card(
        child: InkWell(
          onTap: () {
            // Navigate to category content
          },
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (category.icon != null)
                Icon(
                  _getIconData(category.icon!),
                  size: 32,
                  color: Colors.blue,
                ),
              const SizedBox(height: 8),
              Text(
                category.getName('ar'),
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 4),
              Text(
                '${category.contentCount} محتوى',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildAllContentSection(BuildContext context) {
    return Expanded(
      child: BlocBuilder<EducationalContentCubit, EducationalContentState>(
        builder: (context, state) {
          if (state is ContentLoaded) {
            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: state.content.length,
              itemBuilder: (context, index) {
                final content = state.content[index];
                return _buildContentCard(content);
              },
            );
          } else if (state is EducationalContentLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is EducationalContentError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 64, color: Colors.red),
                  const SizedBox(height: 16),
                  Text(state.message),
                ],
              ),
            );
          }
          return const SizedBox();
        },
      ),
    );
  }
  
  Widget _buildContentCard(EducationalContent content) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () {
          // Navigate to content detail
        },
        child: Row(
          children: [
            if (content.featuredImage != null)
              ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(12),
                  bottomLeft: Radius.circular(12),
                ),
                child: Image.network(
                  content.featuredImage!,
                  width: 120,
                  height: 120,
                  fit: BoxFit.cover,
                ),
              ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          content.type.icon,
                          size: 16,
                          color: Colors.blue,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          content.type.getName('ar'),
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.blue,
                          ),
                        ),
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: content.difficulty.color.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            content.difficulty.getName('ar'),
                            style: TextStyle(
                              fontSize: 10,
                              color: content.difficulty.color,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      content.getTitle('ar'),
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (content.getExcerpt('ar') != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        content.getExcerpt('ar')!,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(Icons.visibility, size: 14, color: Colors.grey),
                        const SizedBox(width: 4),
                        Text(
                          '${content.viewCount}',
                          style: TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                        const SizedBox(width: 16),
                        Icon(Icons.favorite, size: 14, color: Colors.grey),
                        const SizedBox(width: 4),
                        Text(
                          '${content.likeCount}',
                          style: TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                        if (content.readingTime != null) ...[
                          const SizedBox(width: 16),
                          Icon(Icons.access_time, size: 14, color: Colors.grey),
                          const SizedBox(width: 4),
                          Text(
                            content.readingTimeFormatted,
                            style: TextStyle(fontSize: 12, color: Colors.grey),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  IconData _getIconData(String iconName) {
    // Map icon names to IconData
    switch (iconName) {
      case 'smartphone':
        return Icons.smartphone;
      case 'battery':
        return Icons.battery_charging_full;
      case 'cpu':
        return Icons.memory;
      case 'tool':
        return Icons.build;
      case 'lightbulb':
        return Icons.lightbulb;
      default:
        return Icons.category;
    }
  }
}
```

### Content Detail Screen

```dart
class ContentDetailScreen extends StatelessWidget {
  final String contentSlug;
  
  const ContentDetailScreen({required this.contentSlug});
  
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => EducationalContentCubit(
        EducationalContentService(dio),
      )..loadContentBySlug(contentSlug),
      child: Scaffold(
        body: BlocBuilder<EducationalContentCubit, EducationalContentState>(
          builder: (context, state) {
            if (state is ContentDetailLoaded) {
              final content = state.content;
              return CustomScrollView(
                slivers: [
                  // App Bar with Image
                  SliverAppBar(
                    expandedHeight: 250,
                    pinned: true,
                    flexibleSpace: FlexibleSpaceBar(
                      background: content.featuredImage != null
                          ? Image.network(
                              content.featuredImage!,
                              fit: BoxFit.cover,
                            )
                          : Container(color: Colors.blue.shade100),
                      title: Text(
                        content.getTitle('ar'),
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  
                  // Content Body
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Meta Info
                          Row(
                            children: [
                              Chip(
                                avatar: Icon(content.type.icon),
                                label: Text(content.type.getName('ar')),
                              ),
                              const SizedBox(width: 8),
                              Chip(
                                label: Text(content.difficulty.getName('ar')),
                                backgroundColor: content.difficulty.color.withOpacity(0.1),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          
                          // Stats
                          Row(
                            children: [
                              _buildStatItem(
                                Icons.visibility,
                                '${content.viewCount}',
                              ),
                              const SizedBox(width: 16),
                              _buildStatItem(
                                Icons.favorite,
                                '${content.likeCount}',
                              ),
                              const SizedBox(width: 16),
                              _buildStatItem(
                                Icons.share,
                                '${content.shareCount}',
                              ),
                              if (content.readingTime != null) ...[
                                const SizedBox(width: 16),
                                _buildStatItem(
                                  Icons.access_time,
                                  content.readingTimeFormatted,
                                ),
                              ],
                            ],
                          ),
                          const SizedBox(height: 16),
                          
                          // Actions
                          Row(
                            children: [
                              Expanded(
                                child: ElevatedButton.icon(
                                  onPressed: () {
                                    context.read<EducationalContentCubit>()
                                        .likeContent(content.id);
                                  },
                                  icon: const Icon(Icons.favorite_border),
                                  label: const Text('إعجاب'),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: OutlinedButton.icon(
                                  onPressed: () {
                                    context.read<EducationalContentCubit>()
                                        .shareContent(content.id);
                                    // Show share dialog
                                  },
                                  icon: const Icon(Icons.share),
                                  label: const Text('مشاركة'),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),
                          
                          // Content
                          if (content.hasVideo) ...[
                            _buildVideoPlayer(content.videoUrl!),
                            const SizedBox(height: 16),
                          ],
                          
                          // HTML Content
                          HtmlWidget(
                            content.getContentText('ar'),
                            textStyle: const TextStyle(fontSize: 16),
                          ),
                          
                          // Related Products
                          if (content.relatedProductsList != null &&
                              content.relatedProductsList!.isNotEmpty) ...[
                            const SizedBox(height: 32),
                            const Text(
                              'منتجات ذات صلة',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 12),
                            SizedBox(
                              height: 200,
                              child: ListView.builder(
                                scrollDirection: Axis.horizontal,
                                itemCount: content.relatedProductsList!.length,
                                itemBuilder: (context, index) {
                                  final product = content.relatedProductsList![index];
                                  return _buildRelatedProductCard(product);
                                },
                              ),
                            ),
                          ],
                          
                          // Related Content
                          if (content.relatedContentList != null &&
                              content.relatedContentList!.isNotEmpty) ...[
                            const SizedBox(height: 32),
                            const Text(
                              'محتوى ذو صلة',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 12),
                            ...content.relatedContentList!.map((related) {
                              return _buildRelatedContentCard(related);
                            }),
                          ],
                        ],
                      ),
                    ),
                  ),
                ],
              );
            } else if (state is EducationalContentLoading) {
              return const Center(child: CircularProgressIndicator());
            } else if (state is EducationalContentError) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.error_outline, size: 64, color: Colors.red),
                    const SizedBox(height: 16),
                    Text(state.message),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        context.read<EducationalContentCubit>()
                            .loadContentBySlug(contentSlug);
                      },
                      child: const Text('إعادة المحاولة'),
                    ),
                  ],
                ),
              );
            }
            return const SizedBox();
          },
        ),
      ),
    );
  }
  
  Widget _buildStatItem(IconData icon, String value) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.grey),
        const SizedBox(width: 4),
        Text(
          value,
          style: TextStyle(fontSize: 14, color: Colors.grey.shade700),
        ),
      ],
    );
  }
  
  Widget _buildVideoPlayer(String videoUrl) {
    // Use video player package (e.g., video_player)
    return Container(
      height: 200,
      color: Colors.black,
      child: Center(
        child: IconButton(
          icon: const Icon(Icons.play_circle_filled, size: 64, color: Colors.white),
          onPressed: () {
            // Play video
          },
        ),
      ),
    );
  }
  
  Widget _buildRelatedProductCard(Product product) {
    return Container(
      width: 150,
      margin: const EdgeInsets.only(right: 12),
      child: Card(
        child: InkWell(
          onTap: () {
            // Navigate to product
          },
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (product.mainImage != null)
                Image.network(
                  product.mainImage!,
                  height: 100,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              Padding(
                padding: const EdgeInsets.all(8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.getName('ar'),
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${product.basePrice.toStringAsFixed(2)} ر.س',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.blue,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildRelatedContentCard(EducationalContent content) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: content.featuredImage != null
            ? Image.network(
                content.featuredImage!,
                width: 60,
                height: 60,
                fit: BoxFit.cover,
              )
            : Icon(content.type.icon),
        title: Text(content.getTitle('ar')),
        subtitle: Text(
          content.getExcerpt('ar') ?? '',
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: () {
          // Navigate to related content
        },
      ),
    );
  }
}
```

---

## 📝 ملخص الـ Endpoints

| Method | Endpoint | Auth | الوصف |
|--------|----------|------|-------|
| GET | `/educational/categories` | ❌ | جلب جميع الفئات |
| GET | `/educational/categories/:slug` | ❌ | جلب فئة بالـ slug |
| GET | `/educational/content` | ❌ | جلب المحتوى (مع فلترة) |
| GET | `/educational/content/featured` | ❌ | جلب المحتوى المميز |
| GET | `/educational/content/category/:slug` | ❌ | جلب المحتوى حسب الفئة |
| GET | `/educational/content/:slug` | ❌ | جلب محتوى محدد |
| POST | `/educational/content/:id/like` | ❌ | الإعجاب بالمحتوى |
| POST | `/educational/content/:id/share` | ❌ | مشاركة المحتوى |

---

## ⚠️ ملاحظات مهمة

### أنواع المحتوى (Content Types)
- `article`: مقالات تعليمية
- `video`: فيديوهات تعليمية
- `tutorial`: دروس خطوة بخطوة
- `tip`: نصائح سريعة
- `guide`: أدلة شاملة

### مستويات الصعوبة (Difficulty Levels)
- `beginner`: للمبتدئين
- `intermediate`: للمتوسطين
- `advanced`: للمتقدمين

### حالة المحتوى (Status)
- `draft`: مسودة (غير مرئي للعملاء)
- `published`: منشور (مرئي للعملاء)
- `archived`: مؤرشف

### الإحصائيات
- `viewCount`: يتم زيادته تلقائياً عند جلب المحتوى بالـ slug
- `likeCount`: يتم زيادته عند استدعاء endpoint الإعجاب
- `shareCount`: يتم زيادته عند استدعاء endpoint المشاركة

### المحتوى المرتبط
- يمكن ربط المحتوى بمنتجات ذات صلة (`relatedProducts`)
- يمكن ربط المحتوى بمحتوى آخر ذي صلة (`relatedContent`)

---

## 🔗 Related Documentation

- [Products Module](./3-products.md) - المنتجات المرتبطة
- [Catalog Module](./2-catalog.md) - الكتالوج والفئات

---

> 🔗 **السابق:** [13-customer-profile.md](./13-customer-profile.md) - دليل بروفايل العملاء  
> 🔗 **التالي:** [README.md](./README.md) - الفهرس العام

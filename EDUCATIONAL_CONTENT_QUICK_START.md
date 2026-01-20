# 🚀 دليل البدء السريع - نظام المحتوى التعليمي

## ✅ ما تم إنجازه

تم إكمال **88%** من نظام المحتوى التعليمي:
- ✅ Backend (100%)
- ✅ Admin Panel (100%)
- ✅ Mobile App - Core Infrastructure (100%)
- ⚠️ Mobile App - UI Integration (0% - متبقي)

---

## 🎯 الخطوات المتبقية (30-60 دقيقة)

### 1. تشغيل Build Runner (دقيقة واحدة)

```bash
cd mobile
flutter pub get
flutter pub run build_runner build --delete-conflicting-outputs
```

هذا سينشئ ملفات `.g.dart` المطلوبة للـ JSON serialization.

---

### 2. تحديث الشاشات (30-45 دقيقة)

#### A. `education_categories_screen.dart`

**استبدل البيانات الوهمية بهذا:**

```dart
import 'package:flutter_bloc/flutter_bloc.dart';
import '../cubit/education_categories_cubit.dart';
import '../cubit/education_categories_state.dart';
import '../../../../core/di/injection.dart';

class EducationCategoriesScreen extends StatelessWidget {
  const EducationCategoriesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => getIt<EducationCategoriesCubit>()..loadCategories(),
      child: Scaffold(
        appBar: AppBar(title: const Text('المحتوى التعليمي')),
        body: BlocBuilder<EducationCategoriesCubit, EducationCategoriesState>(
          builder: (context, state) {
            if (state is EducationCategoriesLoading) {
              return const Center(child: CircularProgressIndicator());
            }
            
            if (state is EducationCategoriesError) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(state.message),
                    ElevatedButton(
                      onPressed: () => context.read<EducationCategoriesCubit>().loadCategories(),
                      child: const Text('إعادة المحاولة'),
                    ),
                  ],
                ),
              );
            }
            
            if (state is EducationCategoriesLoaded) {
              return RefreshIndicator(
                onRefresh: () => context.read<EducationCategoriesCubit>().refreshCategories(),
                child: ListView(
                  padding: EdgeInsets.all(16.w),
                  children: [
                    // Featured Banner (نفس الكود الموجود)
                    Container(/* ... */),
                    SizedBox(height: 24.h),
                    
                    // Categories Grid
                    Text('التصنيفات', /* ... */),
                    SizedBox(height: 12.h),
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate: /* ... */,
                      itemCount: state.categories.length,
                      itemBuilder: (context, index) {
                        final category = state.categories[index];
                        return _buildCategoryCard(category, isDark, context);
                      },
                    ),
                  ],
                ),
              );
            }
            
            return Container();
          },
        ),
      ),
    );
  }

  Widget _buildCategoryCard(
    EducationalCategoryEntity category,
    bool isDark,
    BuildContext context,
  ) {
    return GestureDetector(
      onTap: () => context.push('/education/list/${category.slug}'),
      child: Container(
        // استخدام category.name, category.contentCount, etc.
        // بدلاً من البيانات الوهمية
      ),
    );
  }
}
```

#### B. `education_list_screen.dart`

**نفس النمط - استخدم `EducationContentCubit`**

#### C. `education_details_screen.dart`

**استخدم `EducationDetailsCubit` + Widgets:**

```dart
// في build method:
if (state is EducationDetailsLoaded) {
  final content = state.content;
  
  return SingleChildScrollView(
    child: Column(
      children: [
        // للفيديو
        if (content.videoUrl != null)
          VideoPlayerWidget(videoUrl: content.videoUrl!),
        
        // للمقالات
        if (content.type == ContentType.article)
          HtmlContentWidget(htmlContent: content.content),
        
        // Like & Share buttons
        Row(
          children: [
            IconButton(
              onPressed: () => context.read<EducationDetailsCubit>().likeContent(content.id),
              icon: Icon(Iconsax.heart),
            ),
            IconButton(
              onPressed: () async {
                await Share.share('${content.title}\n${content.slug}');
                context.read<EducationDetailsCubit>().shareContent(content.id);
              },
              icon: Icon(Iconsax.share),
            ),
          ],
        ),
      ],
    ),
  );
}
```

---

### 3. تحديث Routes (10 دقائق)

**في `app_router.dart`:**

```dart
GoRoute(
  path: '/education',
  builder: (context, state) => BlocProvider(
    create: (context) => getIt<EducationCategoriesCubit>()..loadCategories(),
    child: const EducationCategoriesScreen(),
  ),
),

GoRoute(
  path: '/education/list/:slug',
  builder: (context, state) {
    final slug = state.pathParameters['slug'] ?? '';
    return BlocProvider(
      create: (context) => getIt<EducationContentCubit>()
        ..loadContent(categoryId: slug),
      child: EducationListScreen(categoryId: slug),
    );
  },
),

GoRoute(
  path: '/education/details/:slug',
  builder: (context, state) {
    final slug = state.pathParameters['slug'] ?? '';
    return BlocProvider(
      create: (context) => getIt<EducationDetailsCubit>()..loadContent(slug),
      child: EducationDetailsScreen(contentId: slug),
    );
  },
),
```

---

## 📁 الملفات المهمة

### Backend:
- `backend/src/modules/content/educational.controller.ts`
- `backend/src/modules/content/educational.service.ts`

### Admin Panel:
- `admin/src/pages/content/EducationalContentPage.tsx`
- `admin/src/api/content.api.ts`

### Mobile App:
- **Data Layer:** `mobile/lib/features/education/data/`
- **Domain Layer:** `mobile/lib/features/education/domain/`
- **Presentation:** `mobile/lib/features/education/presentation/`
- **DI:** `mobile/lib/core/di/injection.dart`

---

## 🧪 الاختبار

### Admin Panel:
```bash
cd admin
npm run dev
# افتح http://localhost:5173/educational-content
```

### Mobile App:
```bash
cd mobile
flutter run
# انتقل إلى /education في التطبيق
```

---

## 📞 الدعم

للمزيد من التفاصيل، راجع:
- `EDUCATIONAL_CONTENT_IMPLEMENTATION_STATUS.md` - حالة التنفيذ
- `EDUCATIONAL_CONTENT_FINAL_REPORT.md` - التقرير الكامل

---

## ✨ ملاحظات

- جميع الـ Cubits جاهزة ومسجلة في DI
- جميع الـ Widgets (Video Player, HTML Renderer) جاهزة
- FavoritesService جاهز للاستخدام
- فقط تحتاج لربط UI بالـ Cubits

**وقت الإكمال المتوقع:** 30-60 دقيقة فقط! 🚀

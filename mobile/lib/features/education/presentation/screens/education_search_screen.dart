/// Education Search Screen - Search educational content
library;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax/iconsax.dart';
import '../../../../core/config/theme/app_colors.dart';
import '../../../../core/di/injection.dart';
import '../../domain/entities/educational_content_entity.dart';
import '../cubit/education_categories_cubit.dart';
import '../cubit/education_categories_state.dart';
import '../cubit/education_content_cubit.dart';
import '../cubit/education_content_state.dart';

class EducationSearchScreen extends StatelessWidget {
  const EducationSearchScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => getIt<EducationCategoriesCubit>()..loadCategories(activeOnly: true),
        ),
        BlocProvider(
          create: (context) => getIt<EducationContentCubit>(),
        ),
      ],
      child: const _EducationSearchView(),
    );
  }
}

class _EducationSearchView extends StatefulWidget {
  const _EducationSearchView();

  @override
  State<_EducationSearchView> createState() => _EducationSearchViewState();
}

class _EducationSearchViewState extends State<_EducationSearchView> {
  final TextEditingController _searchController = TextEditingController();
  String? _selectedCategoryId;
  ContentType? _selectedType;
  bool _hasSearched = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _performSearch() {
    final query = _searchController.text.trim();
    if (query.isEmpty && _selectedCategoryId == null && _selectedType == null) {
      return;
    }

    setState(() => _hasSearched = true);

    context.read<EducationContentCubit>().loadContent(
          categoryId: _selectedCategoryId,
          type: _selectedType,
          search: query.isEmpty ? null : query,
        );
  }

  void _clearSearch() {
    _searchController.clear();
    setState(() {
      _selectedCategoryId = null;
      _selectedType = null;
      _hasSearched = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('البحث في المحتوى التعليمي'),
      ),
      body: Column(
        children: [
          // Search Header
          Container(
            padding: EdgeInsets.all(16.w),
            color: isDark ? AppColors.cardDark : AppColors.cardLight,
            child: Column(
              children: [
                // Search Bar
                TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'ابحث عن مقالات، فيديوهات، دروس...',
                    prefixIcon: const Icon(Iconsax.search_normal),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Iconsax.close_circle),
                            onPressed: () {
                              _searchController.clear();
                              setState(() {});
                            },
                          )
                        : null,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    filled: true,
                    fillColor: isDark ? Colors.black12 : Colors.white,
                  ),
                  onSubmitted: (_) => _performSearch(),
                  onChanged: (_) => setState(() {}),
                ),
                SizedBox(height: 12.h),

                // Filters Row
                Row(
                  children: [
                    // Category Filter
                    Expanded(
                      child: BlocBuilder<EducationCategoriesCubit, EducationCategoriesState>(
                        builder: (context, state) {
                          if (state is EducationCategoriesLoaded) {
                            return DropdownButtonFormField<String?>(
                              value: _selectedCategoryId,
                              decoration: InputDecoration(
                                labelText: 'الفئة',
                                prefixIcon: const Icon(Iconsax.category),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12.r),
                                ),
                                filled: true,
                                fillColor: isDark ? Colors.black12 : Colors.white,
                              ),
                              items: [
                                const DropdownMenuItem(
                                  value: null,
                                  child: Text('جميع الفئات'),
                                ),
                                ...state.categories.map((category) {
                                  return DropdownMenuItem(
                                    value: category.id,
                                    child: Text(category.nameAr ?? category.name),
                                  );
                                }),
                              ],
                              onChanged: (value) {
                                setState(() => _selectedCategoryId = value);
                              },
                            );
                          }
                          return const SizedBox.shrink();
                        },
                      ),
                    ),
                    SizedBox(width: 12.w),

                    // Type Filter
                    Expanded(
                      child: DropdownButtonFormField<ContentType?>(
                        value: _selectedType,
                        decoration: InputDecoration(
                          labelText: 'النوع',
                          prefixIcon: const Icon(Iconsax.filter),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                          filled: true,
                          fillColor: isDark ? Colors.black12 : Colors.white,
                        ),
                        items: const [
                          DropdownMenuItem(
                            value: null,
                            child: Text('الكل'),
                          ),
                          DropdownMenuItem(
                            value: ContentType.article,
                            child: Text('مقالات'),
                          ),
                          DropdownMenuItem(
                            value: ContentType.video,
                            child: Text('فيديوهات'),
                          ),
                          DropdownMenuItem(
                            value: ContentType.tutorial,
                            child: Text('دروس'),
                          ),
                          DropdownMenuItem(
                            value: ContentType.tip,
                            child: Text('نصائح'),
                          ),
                          DropdownMenuItem(
                            value: ContentType.guide,
                            child: Text('أدلة'),
                          ),
                        ],
                        onChanged: (value) {
                          setState(() => _selectedType = value);
                        },
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 12.h),

                // Action Buttons
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: _performSearch,
                        icon: const Icon(Iconsax.search_normal),
                        label: const Text('بحث'),
                      ),
                    ),
                    if (_hasSearched || _searchController.text.isNotEmpty) ...[
                      SizedBox(width: 12.w),
                      OutlinedButton.icon(
                        onPressed: _clearSearch,
                        icon: const Icon(Iconsax.refresh),
                        label: const Text('مسح'),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),

          // Search Results
          Expanded(
            child: BlocBuilder<EducationContentCubit, EducationContentState>(
              builder: (context, state) {
                if (!_hasSearched) {
                  return _buildEmptyState(
                    icon: Iconsax.search_normal_1,
                    title: 'ابدأ البحث',
                    subtitle: 'استخدم شريط البحث أعلاه للعثور على المحتوى',
                  );
                }

                if (state is EducationContentLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (state is EducationContentError) {
                  return _buildEmptyState(
                    icon: Iconsax.info_circle,
                    title: 'حدث خطأ',
                    subtitle: state.message,
                    color: Colors.red,
                  );
                }

                if (state is EducationContentLoaded) {
                  if (state.content.isEmpty) {
                    return _buildEmptyState(
                      icon: Iconsax.search_status,
                      title: 'لا توجد نتائج',
                      subtitle: 'جرب البحث بكلمات مختلفة أو غير الفلاتر',
                    );
                  }

                  return ListView.separated(
                    padding: EdgeInsets.all(16.w),
                    itemCount: state.content.length,
                    separatorBuilder: (_, __) => SizedBox(height: 12.h),
                    itemBuilder: (context, index) {
                      final content = state.content[index];
                      return _buildSearchResultCard(content, isDark, context);
                    },
                  );
                }

                return const SizedBox.shrink();
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState({
    required IconData icon,
    required String title,
    required String subtitle,
    Color? color,
  }) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(32.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 80.sp,
              color: color ?? AppColors.textSecondaryLight,
            ),
            SizedBox(height: 16.h),
            Text(
              title,
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 8.h),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 14.sp,
                color: AppColors.textSecondaryLight,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchResultCard(
    EducationalContentEntity content,
    bool isDark,
    BuildContext context,
  ) {
    String getTypeLabel(ContentType type) {
      switch (type) {
        case ContentType.article:
          return 'مقال';
        case ContentType.video:
          return 'فيديو';
        case ContentType.tutorial:
          return 'درس';
        case ContentType.tip:
          return 'نصيحة';
        case ContentType.guide:
          return 'دليل';
      }
    }

    Color getTypeColor(ContentType type) {
      switch (type) {
        case ContentType.video:
          return AppColors.error;
        case ContentType.tutorial:
          return AppColors.warning;
        case ContentType.tip:
          return AppColors.success;
        default:
          return AppColors.info;
      }
    }

    return GestureDetector(
      onTap: () => context.push('/education/details/${content.slug}'),
      child: Container(
        padding: EdgeInsets.all(12.w),
        decoration: BoxDecoration(
          color: isDark ? AppColors.cardDark : AppColors.cardLight,
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: Row(
          children: [
            // Thumbnail
            Container(
              width: 80.w,
              height: 80.w,
              decoration: BoxDecoration(
                color: getTypeColor(content.type).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10.r),
                image: content.featuredImage != null
                    ? DecorationImage(
                        image: NetworkImage(content.featuredImage!),
                        fit: BoxFit.cover,
                      )
                    : null,
              ),
              child: content.featuredImage == null
                  ? Icon(
                      content.type == ContentType.video ? Iconsax.video : Iconsax.document_text,
                      size: 32.sp,
                      color: getTypeColor(content.type),
                    )
                  : null,
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Type Badge
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
                    decoration: BoxDecoration(
                      color: getTypeColor(content.type).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(4.r),
                    ),
                    child: Text(
                      getTypeLabel(content.type),
                      style: TextStyle(
                        fontSize: 10.sp,
                        color: getTypeColor(content.type),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  SizedBox(height: 6.h),
                  // Title
                  Text(
                    content.titleAr ?? content.title,
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (content.excerpt != null || content.excerptAr != null) ...[
                    SizedBox(height: 4.h),
                    Text(
                      content.excerptAr ?? content.excerpt!,
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: AppColors.textSecondaryLight,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                  SizedBox(height: 6.h),
                  // Meta
                  Row(
                    children: [
                      Icon(Iconsax.eye, size: 12.sp, color: AppColors.textSecondaryLight),
                      SizedBox(width: 4.w),
                      Text(
                        '${content.viewCount}',
                        style: TextStyle(
                          fontSize: 11.sp,
                          color: AppColors.textSecondaryLight,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Icon(
              Iconsax.arrow_left_2,
              size: 18.sp,
              color: AppColors.textSecondaryLight,
            ),
          ],
        ),
      ),
    );
  }
}

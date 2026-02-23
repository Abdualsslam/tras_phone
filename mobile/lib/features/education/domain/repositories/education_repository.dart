/// Education Repository Interface
library;

import '../entities/educational_category_entity.dart';
import '../entities/educational_content_entity.dart';

abstract class EducationRepository {
  // Categories
  Future<List<EducationalCategoryEntity>> getCategories({bool? activeOnly});
  Future<EducationalCategoryEntity?> getCategoryBySlug(String slug);

  // Content
  Future<Map<String, dynamic>> getContent({
    String? categoryId,
    ContentType? type,
    String? status,
    bool? featured,
    String? search,
    int page = 1,
    int limit = 20,
  });

  Future<EducationalContentEntity?> getContentBySlug(String slug);
  Future<EducationalContentEntity?> getContentById(String id);
  Future<Map<String, dynamic>> getProductEducationalContent({
    required String productId,
    int page = 1,
    int limit = 20,
  });
  Future<List<EducationalContentEntity>> getFeaturedContent({int? limit});
  Future<List<EducationalContentEntity>> getContentByCategory(
    String categorySlug, {
    int? limit,
  });

  // Interactions
  Future<void> likeContent(String id);
  Future<void> shareContent(String id);
}

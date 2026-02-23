/// Education Repository Implementation
library;

import '../../domain/entities/educational_category_entity.dart';
import '../../domain/entities/educational_content_entity.dart';
import '../../domain/repositories/education_repository.dart';
import '../datasources/education_remote_datasource.dart';

class EducationRepositoryImpl implements EducationRepository {
  final EducationRemoteDataSource _remoteDataSource;

  EducationRepositoryImpl({required EducationRemoteDataSource remoteDataSource})
    : _remoteDataSource = remoteDataSource;

  @override
  Future<List<EducationalCategoryEntity>> getCategories({
    bool? activeOnly,
  }) async {
    try {
      return await _remoteDataSource.getCategories(activeOnly: activeOnly);
    } catch (e) {
      throw Exception('Failed to fetch categories: $e');
    }
  }

  @override
  Future<EducationalCategoryEntity?> getCategoryBySlug(String slug) async {
    try {
      return await _remoteDataSource.getCategoryBySlug(slug);
    } catch (e) {
      throw Exception('Failed to fetch category: $e');
    }
  }

  @override
  Future<Map<String, dynamic>> getContent({
    String? categoryId,
    ContentType? type,
    String? status,
    bool? featured,
    String? search,
    int page = 1,
    int limit = 20,
  }) async {
    try {
      return await _remoteDataSource.getContent(
        categoryId: categoryId,
        type: type,
        status: status,
        featured: featured,
        search: search,
        page: page,
        limit: limit,
      );
    } catch (e) {
      throw Exception('Failed to fetch content: $e');
    }
  }

  @override
  Future<EducationalContentEntity?> getContentBySlug(String slug) async {
    try {
      return await _remoteDataSource.getContentBySlug(slug);
    } catch (e) {
      throw Exception('Failed to fetch content: $e');
    }
  }

  @override
  Future<EducationalContentEntity?> getContentById(String id) async {
    try {
      return await _remoteDataSource.getContentById(id);
    } catch (e) {
      throw Exception('Failed to fetch content: $e');
    }
  }

  @override
  Future<Map<String, dynamic>> getProductEducationalContent({
    required String productId,
    int page = 1,
    int limit = 20,
  }) async {
    try {
      return await _remoteDataSource.getProductEducationalContent(
        productId: productId,
        page: page,
        limit: limit,
      );
    } catch (e) {
      throw Exception('Failed to fetch product educational content: $e');
    }
  }

  @override
  Future<List<EducationalContentEntity>> getFeaturedContent({
    int? limit,
  }) async {
    try {
      return await _remoteDataSource.getFeaturedContent(limit: limit);
    } catch (e) {
      throw Exception('Failed to fetch featured content: $e');
    }
  }

  @override
  Future<List<EducationalContentEntity>> getContentByCategory(
    String categorySlug, {
    int? limit,
  }) async {
    try {
      return await _remoteDataSource.getContentByCategory(
        categorySlug,
        limit: limit,
      );
    } catch (e) {
      throw Exception('Failed to fetch content by category: $e');
    }
  }

  @override
  Future<void> likeContent(String id) async {
    try {
      await _remoteDataSource.likeContent(id);
    } catch (e) {
      throw Exception('Failed to like content: $e');
    }
  }

  @override
  Future<void> shareContent(String id) async {
    try {
      await _remoteDataSource.shareContent(id);
    } catch (e) {
      throw Exception('Failed to share content: $e');
    }
  }
}

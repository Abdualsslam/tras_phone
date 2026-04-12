/// Education Remote DataSource
library;

import 'dart:developer' as developer;

import '../../../../core/constants/api_endpoints.dart';
import '../../../../core/network/api_client.dart';
import '../../domain/entities/educational_category_entity.dart';
import '../../domain/entities/educational_content_entity.dart';
import '../models/educational_category_model.dart';
import '../models/educational_content_model.dart';

part 'education_remote_datasource_support.dart';
part 'education_remote_datasource_categories.dart';
part 'education_remote_datasource_content.dart';
part 'education_remote_datasource_interactions.dart';

abstract class EducationRemoteDataSource {
  Future<List<EducationalCategoryEntity>> getCategories({bool? activeOnly});
  Future<EducationalCategoryEntity?> getCategoryBySlug(String slug);

  Future<Map<String, dynamic>> getContent({
    String? categoryId,
    ContentType? type,
    String? status,
    bool? featured,
    String? search,
    int page,
    int limit,
  });

  Future<EducationalContentEntity?> getContentBySlug(String slug);
  Future<EducationalContentEntity?> getContentById(String id);
  Future<Map<String, dynamic>> getProductEducationalContent({
    required String productId,
    int page,
    int limit,
  });
  Future<List<EducationalContentEntity>> getFeaturedContent({int? limit});
  Future<List<EducationalContentEntity>> getContentByCategory(
    String categorySlug, {
    int? limit,
  });

  Future<void> likeContent(String id);
  Future<void> shareContent(String id);
}

class EducationRemoteDataSourceImpl implements EducationRemoteDataSource {
  final ApiClient _apiClient;

  late final _EducationRemoteSupport _support;
  late final _EducationCategoriesRemote _categoriesRemote;
  late final _EducationContentRemote _contentRemote;
  late final _EducationInteractionsRemote _interactionsRemote;

  EducationRemoteDataSourceImpl({required ApiClient apiClient})
    : _apiClient = apiClient {
    _support = _EducationRemoteSupport(apiClient: _apiClient);
    _categoriesRemote = _EducationCategoriesRemote(_support);
    _contentRemote = _EducationContentRemote(_support);
    _interactionsRemote = _EducationInteractionsRemote(_support);
  }

  @override
  Future<List<EducationalCategoryEntity>> getCategories({bool? activeOnly}) =>
      _categoriesRemote.getCategories(activeOnly: activeOnly);

  @override
  Future<EducationalCategoryEntity?> getCategoryBySlug(String slug) =>
      _categoriesRemote.getCategoryBySlug(slug);

  @override
  Future<Map<String, dynamic>> getContent({
    String? categoryId,
    ContentType? type,
    String? status,
    bool? featured,
    String? search,
    int page = 1,
    int limit = 20,
  }) => _contentRemote.getContent(
    categoryId: categoryId,
    type: type,
    status: status,
    featured: featured,
    search: search,
    page: page,
    limit: limit,
  );

  @override
  Future<EducationalContentEntity?> getContentBySlug(String slug) =>
      _contentRemote.getContentBySlug(slug);

  @override
  Future<EducationalContentEntity?> getContentById(String id) =>
      _contentRemote.getContentById(id);

  @override
  Future<Map<String, dynamic>> getProductEducationalContent({
    required String productId,
    int page = 1,
    int limit = 20,
  }) => _contentRemote.getProductEducationalContent(
    productId: productId,
    page: page,
    limit: limit,
  );

  @override
  Future<List<EducationalContentEntity>> getFeaturedContent({int? limit}) =>
      _contentRemote.getFeaturedContent(limit: limit);

  @override
  Future<List<EducationalContentEntity>> getContentByCategory(
    String categorySlug, {
    int? limit,
  }) => _contentRemote.getContentByCategory(categorySlug, limit: limit);

  @override
  Future<void> likeContent(String id) => _interactionsRemote.likeContent(id);

  @override
  Future<void> shareContent(String id) => _interactionsRemote.shareContent(id);
}

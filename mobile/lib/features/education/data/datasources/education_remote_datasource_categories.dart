part of 'education_remote_datasource.dart';

class _EducationCategoriesRemote {
  final _EducationRemoteSupport _support;

  const _EducationCategoriesRemote(this._support);

  Future<List<EducationalCategoryEntity>> getCategories({
    bool? activeOnly,
  }) async {
    _support.log('Fetching educational categories (activeOnly: $activeOnly)');

    final response = await _support.apiClient.get(
      ApiEndpoints.educationCategories,
      queryParameters: activeOnly != null ? {'activeOnly': activeOnly} : null,
    );

    return _support.parseCategories(response.data);
  }

  Future<EducationalCategoryEntity?> getCategoryBySlug(String slug) async {
    _support.log('Fetching educational category: $slug');

    try {
      final response = await _support.apiClient.get(
        '${ApiEndpoints.educationCategories}/$slug',
      );
      final payload = _support.extractPayload(response.data);
      if (payload is! Map<String, dynamic>) return null;
      return EducationalCategoryModel.fromJson(payload).toEntity();
    } catch (_) {
      _support.log('Category not found: $slug');
      return null;
    }
  }
}

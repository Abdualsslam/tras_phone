/// Education Content Cubit
library;

import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/educational_content_entity.dart';
import '../../domain/repositories/education_repository.dart';
import 'education_content_state.dart';

class EducationContentCubit extends Cubit<EducationContentState> {
  final EducationRepository _repository;

  String? _currentCategoryId;
  ContentType? _currentType;
  String? _currentStatus;
  bool? _currentFeatured;
  String? _currentSearch;
  int _currentPage = 1;
  final int _limit = 20;

  EducationContentCubit({required EducationRepository repository})
      : _repository = repository,
        super(const EducationContentInitial());

  Future<void> loadContent({
    String? categoryId,
    ContentType? type,
    String? status,
    bool? featured,
    String? search,
  }) async {
    emit(const EducationContentLoading());

    _currentCategoryId = categoryId;
    _currentType = type;
    _currentStatus = status;
    _currentFeatured = featured;
    _currentSearch = search;
    _currentPage = 1;

    try {
      final result = await _repository.getContent(
        categoryId: categoryId,
        type: type,
        status: status,
        featured: featured,
        search: search,
        page: _currentPage,
        limit: _limit,
      );

      final content = result['content'] as List<EducationalContentEntity>;
      final pagination = result['pagination'] as Map<String, dynamic>;
      final total = pagination['total'] as int? ?? content.length;
      final pages = pagination['pages'] as int? ?? (total / _limit).ceil();
      final hasMore = _currentPage < pages;

      emit(EducationContentLoaded(
        content: content,
        hasMore: hasMore,
        currentPage: _currentPage,
        total: total,
      ));
    } catch (e) {
      emit(EducationContentError(e.toString()));
    }
  }

  Future<void> loadMore() async {
    final currentState = state;
    if (currentState is! EducationContentLoaded || !currentState.hasMore) {
      return;
    }

    _currentPage++;

    try {
      final result = await _repository.getContent(
        categoryId: _currentCategoryId,
        type: _currentType,
        status: _currentStatus,
        featured: _currentFeatured,
        search: _currentSearch,
        page: _currentPage,
        limit: _limit,
      );

      final newContent = result['content'] as List<EducationalContentEntity>;
      final pagination = result['pagination'] as Map<String, dynamic>;
      final total = pagination['total'] as int? ?? currentState.total;
      final pages = pagination['pages'] as int? ?? (total / _limit).ceil();
      final hasMore = _currentPage < pages;

      emit(EducationContentLoaded(
        content: [...currentState.content, ...newContent],
        hasMore: hasMore,
        currentPage: _currentPage,
        total: total,
      ));
    } catch (e) {
      emit(EducationContentError(e.toString()));
    }
  }

  Future<void> refresh() async {
    await loadContent(
      categoryId: _currentCategoryId,
      type: _currentType,
      status: _currentStatus,
      featured: _currentFeatured,
      search: _currentSearch,
    );
  }

  void filterByCategory(String? categoryId) {
    loadContent(
      categoryId: categoryId,
      type: _currentType,
      status: _currentStatus,
      featured: _currentFeatured,
      search: _currentSearch,
    );
  }

  void filterByType(ContentType? type) {
    loadContent(
      categoryId: _currentCategoryId,
      type: type,
      status: _currentStatus,
      featured: _currentFeatured,
      search: _currentSearch,
    );
  }

  void search(String query) {
    loadContent(
      categoryId: _currentCategoryId,
      type: _currentType,
      status: _currentStatus,
      featured: _currentFeatured,
      search: query.isEmpty ? null : query,
    );
  }

  /// جلب المحتوى المميز
  Future<void> loadFeaturedContent({int limit = 6}) async {
    emit(const EducationContentLoading());

    try {
      final content = await _repository.getFeaturedContent(limit: limit);
      emit(EducationContentLoaded(
        content: content,
        hasMore: false,
        currentPage: 1,
        total: content.length,
      ));
    } catch (e) {
      emit(EducationContentError(e.toString()));
    }
  }

  /// الإعجاب بالمحتوى
  Future<void> likeContent(String contentId) async {
    try {
      await _repository.likeContent(contentId);
      // يمكن تحديث الحالة المحلية هنا إذا لزم الأمر
    } catch (e) {
      emit(EducationContentError(e.toString()));
    }
  }

  /// مشاركة المحتوى
  Future<void> shareContent(String contentId) async {
    try {
      await _repository.shareContent(contentId);
    } catch (e) {
      emit(EducationContentError(e.toString()));
    }
  }
}

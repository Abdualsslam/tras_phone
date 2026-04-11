import 'dart:async';

import 'package:flutter/material.dart';

import '../../data/datasources/catalog_remote_datasource.dart';
import '../../domain/entities/product_entity.dart';

class CatalogSearchCoordinator extends ChangeNotifier {
  final CatalogRemoteDataSource _dataSource;

  final TextEditingController searchController = TextEditingController();
  final FocusNode focusNode = FocusNode();

  final List<String> _recentSearches = [];
  List<ProductEntity> _searchResults = const [];
  List<String> _autocompleteSuggestions = const [];
  List<String> _popularTags = const [];
  Timer? _debounceTimer;
  bool _isLoading = false;
  bool _hasSearched = false;
  bool _showSuggestions = false;

  CatalogSearchCoordinator({required CatalogRemoteDataSource dataSource})
    : _dataSource = dataSource;

  List<ProductEntity> get searchResults => _searchResults;
  List<String> get recentSearches => _recentSearches;
  List<String> get autocompleteSuggestions => _autocompleteSuggestions;
  List<String> get popularTags => _popularTags;
  bool get isLoading => _isLoading;
  bool get hasSearched => _hasSearched;
  bool get showSuggestions => _showSuggestions;
  String get query => searchController.text;

  Future<void> initialize() async {
    await _loadPopularTags();
  }

  void requestFocus() {
    focusNode.requestFocus();
  }

  void onQueryChanged(String query) {
    _debounceTimer?.cancel();

    if (query.isEmpty) {
      _searchResults = const [];
      _autocompleteSuggestions = const [];
      _isLoading = false;
      _hasSearched = false;
      _showSuggestions = false;
      notifyListeners();
      return;
    }

    if (query.length < 2) {
      _autocompleteSuggestions = const [];
      _showSuggestions = false;
      notifyListeners();
      return;
    }

    _showSuggestions = true;
    notifyListeners();

    _debounceTimer = Timer(
      const Duration(milliseconds: 300),
      () => _loadAutocompleteSuggestions(query),
    );
  }

  Future<void> submitSearch([String? query]) async {
    final normalizedQuery = (query ?? searchController.text).trim();
    searchController.value = TextEditingValue(
      text: normalizedQuery,
      selection: TextSelection.collapsed(offset: normalizedQuery.length),
    );

    if (normalizedQuery.isEmpty) {
      _searchResults = const [];
      _autocompleteSuggestions = const [];
      _isLoading = false;
      _hasSearched = false;
      _showSuggestions = false;
      notifyListeners();
      return;
    }

    _isLoading = true;
    _hasSearched = true;
    _showSuggestions = false;
    notifyListeners();

    try {
      _searchResults = await _dataSource.advancedSearch(
        query: normalizedQuery,
        page: 1,
        limit: 20,
      );

      if (!_recentSearches.contains(normalizedQuery) &&
          normalizedQuery.length > 2) {
        _recentSearches.insert(0, normalizedQuery);
        if (_recentSearches.length > 5) {
          _recentSearches.removeLast();
        }
      }
    } catch (_) {
      _searchResults = const [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void selectQuery(String query) {
    submitSearch(query);
  }

  void clearSearch() {
    _debounceTimer?.cancel();
    searchController.clear();
    _searchResults = const [];
    _autocompleteSuggestions = const [];
    _isLoading = false;
    _hasSearched = false;
    _showSuggestions = false;
    notifyListeners();
  }

  void clearRecentSearches() {
    _recentSearches.clear();
    notifyListeners();
  }

  Future<void> _loadPopularTags() async {
    try {
      final tags = await _dataSource.getPopularTags(limit: 15);
      _popularTags = tags.map((tag) => tag['tag']).whereType<String>().toList();
      notifyListeners();
    } catch (_) {
      _popularTags = const [];
      notifyListeners();
    }
  }

  Future<void> _loadAutocompleteSuggestions(String query) async {
    try {
      _autocompleteSuggestions = await _dataSource.getAutocompleteSuggestions(
        query,
        limit: 5,
      );
      notifyListeners();
    } catch (_) {
      _autocompleteSuggestions = const [];
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    searchController.dispose();
    focusNode.dispose();
    super.dispose();
  }
}

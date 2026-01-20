/// Favorites Service for Educational Content
library;

import 'package:shared_preferences/shared_preferences.dart';

class FavoritesService {
  static const String _favoritesKey = 'educational_favorites';
  final SharedPreferences _prefs;

  FavoritesService({required SharedPreferences prefs}) : _prefs = prefs;

  /// Get all favorite content IDs
  Future<List<String>> getFavorites() async {
    final favorites = _prefs.getStringList(_favoritesKey);
    return favorites ?? [];
  }

  /// Check if content is favorited
  Future<bool> isFavorite(String contentId) async {
    final favorites = await getFavorites();
    return favorites.contains(contentId);
  }

  /// Add content to favorites
  Future<bool> addFavorite(String contentId) async {
    final favorites = await getFavorites();
    
    if (!favorites.contains(contentId)) {
      favorites.add(contentId);
      return await _prefs.setStringList(_favoritesKey, favorites);
    }
    
    return true;
  }

  /// Remove content from favorites
  Future<bool> removeFavorite(String contentId) async {
    final favorites = await getFavorites();
    
    if (favorites.contains(contentId)) {
      favorites.remove(contentId);
      return await _prefs.setStringList(_favoritesKey, favorites);
    }
    
    return true;
  }

  /// Toggle favorite status
  Future<bool> toggleFavorite(String contentId) async {
    final isFav = await isFavorite(contentId);
    
    if (isFav) {
      return await removeFavorite(contentId);
    } else {
      return await addFavorite(contentId);
    }
  }

  /// Clear all favorites
  Future<bool> clearFavorites() async {
    return await _prefs.remove(_favoritesKey);
  }
}

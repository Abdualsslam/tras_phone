library;

import 'package:flutter/material.dart';

import '../di/injection.dart';
import '../../features/favorite/data/datasources/favorite_remote_datasource.dart';

mixin ProductFavoritesMixin<T extends StatefulWidget> on State<T> {
  late final FavoriteRemoteDataSource favoriteDataSource =
      getIt<FavoriteRemoteDataSource>();

  final Set<String> favoriteProductIds = <String>{};

  bool isProductFavorite(String productId) =>
      favoriteProductIds.contains(productId);

  Future<void> loadFavoriteProductIds() async {
    try {
      final favoriteIds = await favoriteDataSource.getFavoriteProductIds();
      if (!mounted) return;

      setState(() {
        favoriteProductIds
          ..clear()
          ..addAll(favoriteIds);
      });
    } catch (_) {
      // Favorite state is additive; ignore background failures.
    }
  }

  Future<void> toggleFavoriteProduct(String productId) async {
    final wasFavorite = favoriteProductIds.contains(productId);

    setState(() {
      if (wasFavorite) {
        favoriteProductIds.remove(productId);
      } else {
        favoriteProductIds.add(productId);
      }
    });

    try {
      await favoriteDataSource.toggleFavorite(productId, wasFavorite);
    } catch (_) {
      if (!mounted) return;

      setState(() {
        if (wasFavorite) {
          favoriteProductIds.add(productId);
        } else {
          favoriteProductIds.remove(productId);
        }
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('تعذر تحديث المفضلة، حاول مرة أخرى'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }
}

/// Search Shimmer - Loading placeholder for search results
library;

import 'package:flutter/material.dart';
import 'products_shimmer.dart';

/// Shimmer for search screen when loading results.
/// Reuses ProductsGridShimmer layout (without sort bar for search context).
class SearchResultsShimmer extends StatelessWidget {
  const SearchResultsShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return const ProductsGridShimmer();
  }
}

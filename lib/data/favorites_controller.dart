import 'package:flutter/foundation.dart';

/// In-memory, app-wide favorites state — a demo stand-in for a real
/// backend/account-synced favorites list.
///
/// A single shared instance (rather than each screen holding its own
/// `Set`) is what lets favoriting a product on, say, the Product Details
/// screen show up immediately when the user navigates back to Home or
/// the Furniture List, without passing results back through every
/// `Navigator.push`.
class FavoritesController {
  FavoritesController._();

  static final FavoritesController instance = FavoritesController._();

  final ValueNotifier<Set<String>> favoriteIds = ValueNotifier<Set<String>>({});

  bool isFavorite(String id) => favoriteIds.value.contains(id);

  void toggle(String id) {
    final Set<String> updated = Set<String>.from(favoriteIds.value);
    if (!updated.add(id)) updated.remove(id);
    favoriteIds.value = updated;
  }
}

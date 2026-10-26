/// A single rentable furniture item.
///
/// This is the one shared shape used by Home, Search, the Furniture List,
/// and Product Details — a plain, backend-free data class so the demo
/// catalog in `lib/data/demo_data.dart` can later be swapped for a real
/// API/database response without touching any screen's UI code.
class Furniture {
  const Furniture({
    required this.id,
    required this.name,
    required this.category,
    required this.price,
    required this.imageAsset,
    required this.description,
    required this.rating,
    required this.reviewCount,
  });

  /// Stable identifier — used as the favorites-set key instead of a list
  /// index, so favoriting survives filtering/reordering.
  final String id;
  final String name;
  final String category;

  /// Pre-formatted for display (e.g. `'₹799/mo'`) — there's no numeric
  /// pricing/booking logic yet, just the customer-facing UI.
  final String price;
  final String imageAsset;
  final String description;

  /// Out of 5 — shown next to [reviewCount] on the Furniture List screen
  /// (`design_reference/06_furniture_list.png`'s "★ 4.5 (120)" rows).
  final double rating;
  final int reviewCount;
}

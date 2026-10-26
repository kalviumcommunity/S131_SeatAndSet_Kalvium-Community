import '../models/furniture.dart';

/// Local, hardcoded demo data for the customer-facing screens.
///
/// There is no backend/database yet — every screen that lists furniture,
/// categories, or delivery locations reads from here. Keeping it all in
/// one file (instead of scattering mock lists across screens) means
/// swapping this out for a real API later only touches this file.
class DemoData {
  DemoData._();

  /// Furniture categories. The first 4 (Sofas, Beds, Tables, Chairs) are
  /// also the ones shown as tiles on the Home screen; the rest only show
  /// up as filter chips on the Furniture List screen.
  static const List<String> categories = [
    'Sofas',
    'Beds',
    'Tables',
    'Chairs',
    'Wardrobes',
    'Lamps',
  ];

  /// Deliverable cities/regions, shown on the location-selector screen.
  static const List<String> locations = [
    'Jammu, J&K',
    'Srinagar, J&K',
    'Punjab',
    'Chandigarh',
    'Amritsar, Punjab',
    'Ludhiana, Punjab',
    'Jalandhar, Punjab',
    'Delhi',
    'Noida',
    'Gurugram',
  ];

  /// The demo furniture catalog. Images are reused from the Home screen's
  /// own cropped reference artwork (there's no dedicated photo per demo
  /// item yet) — swapping in real product photography later is just a
  /// matter of changing `imageAsset` per row.
  static const List<Furniture> furniture = [
    Furniture(
      id: 'sofa-modern',
      name: 'Modern Sofa',
      category: 'Sofas',
      price: '₹799/mo',
      imageAsset: 'assets/images/home_product_sofa_clean.png',
      description:
          'A plush 2-seater sofa with soft cushions and sturdy wooden '
          'legs — perfect for cosy evenings in.',
      rating: 4.5,
      reviewCount: 120,
    ),
    Furniture(
      id: 'sofa-classic',
      name: 'Classic Sofa',
      category: 'Sofas',
      price: '₹699/mo',
      imageAsset: 'assets/images/home_category_sofa.png',
      description:
          'A timeless sofa silhouette that fits comfortably into almost '
          'any living room.',
      rating: 4.3,
      reviewCount: 76,
    ),
    Furniture(
      id: 'table-study',
      name: 'Study Table',
      category: 'Tables',
      price: '₹399/mo',
      imageAsset: 'assets/images/home_product_table_clean.png',
      description:
          'A compact study table with a handy drawer, ideal for a work '
          '(or work-from-home) corner.',
      rating: 4.6,
      reviewCount: 98,
    ),
    Furniture(
      id: 'table-dining',
      name: 'Dining Table',
      category: 'Tables',
      price: '₹549/mo',
      imageAsset: 'assets/images/home_category_tables.png',
      description:
          'A sturdy wooden dining table that seats the family comfortably.',
      rating: 4.4,
      reviewCount: 52,
    ),
    Furniture(
      id: 'bed-cozy',
      name: 'Cozy Bed',
      category: 'Beds',
      price: '₹899/mo',
      imageAsset: 'assets/images/home_category_beds.png',
      description:
          'A comfortable queen-size bed frame with a padded headboard.',
      rating: 4.7,
      reviewCount: 64,
    ),
    Furniture(
      id: 'chair-wooden',
      name: 'Wooden Chair',
      category: 'Chairs',
      price: '₹249/mo',
      imageAsset: 'assets/images/home_category_chairs.png',
      description: 'A simple, sturdy wooden chair that suits any dining set.',
      rating: 4.2,
      reviewCount: 40,
    ),
  ];

  /// Case-insensitive search across name and category.
  static List<Furniture> search(String query) {
    final String q = query.trim().toLowerCase();
    if (q.isEmpty) return furniture;
    return furniture
        .where(
          (item) =>
              item.name.toLowerCase().contains(q) ||
              item.category.toLowerCase().contains(q),
        )
        .toList();
  }

  /// All items in [category], or every item when [category] is `null`.
  static List<Furniture> byCategory(String? category) {
    if (category == null) return furniture;
    return furniture.where((item) => item.category == category).toList();
  }

  /// Combined search-text + category filter, used by the Browse/Search
  /// screen (which offers both at once) — [search] and [byCategory]
  /// stay as the simpler single-filter versions used elsewhere.
  static List<Furniture> filter({String? category, String query = ''}) {
    final String q = query.trim().toLowerCase();
    return furniture.where((item) {
      final bool matchesCategory =
          category == null || item.category == category;
      final bool matchesQuery =
          q.isEmpty ||
          item.name.toLowerCase().contains(q) ||
          item.category.toLowerCase().contains(q);
      return matchesCategory && matchesQuery;
    }).toList();
  }
}

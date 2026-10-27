import 'package:cloud_firestore/cloud_firestore.dart';

/// A single rentable furniture item.
///
/// Shape used by Home, Search, Furniture List, and Product Details.
/// Maps live Firestore documents while preserving fallback defaults for
/// demo assets and styling.
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

  /// Pre-formatted for display (e.g. `'₹799/mo'`).
  final String price;
  final String imageAsset;
  final String description;

  /// Out of 5 — shown next to [reviewCount] on the Furniture List screen.
  final double rating;
  final int reviewCount;

  factory Furniture.fromMap(String id, Map<String, dynamic> map) {
    final type = map['type'] as String? ?? 'sofa';
    final categoryLabel = _typeToCategory(type);

    return Furniture(
      id: id,
      name: (map['name'] as String?)?.trim().isNotEmpty == true
          ? (map['name'] as String).trim()
          : 'Furniture Item',
      category: (map['category'] as String?)?.trim().isNotEmpty == true
          ? (map['category'] as String).trim()
          : categoryLabel,
      price: (map['price'] as String?)?.trim().isNotEmpty == true
          ? (map['price'] as String).trim()
          : _categoryDefaultPrice(type),
      imageAsset: (map['imageAsset'] as String?)?.trim().isNotEmpty == true
          ? (map['imageAsset'] as String).trim()
          : _categoryDefaultImageAsset(type),
      description: (map['description'] as String?)?.trim().isNotEmpty == true
          ? (map['description'] as String).trim()
          : _categoryDefaultDescription(type),
      rating: (map['rating'] as num?)?.toDouble() ?? 4.5,
      reviewCount: (map['reviewCount'] as num?)?.toInt() ?? 120,
    );
  }

  factory Furniture.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? {};
    return Furniture.fromMap(doc.id, data);
  }

  static String _typeToCategory(String type) {
    switch (type) {
      case 'sofa':
        return 'Sofas';
      case 'bed':
        return 'Beds';
      case 'studyTable':
      case 'diningTable':
        return 'Tables';
      case 'officeChair':
        return 'Chairs';
      default:
        return 'Sofas';
    }
  }

  static String _categoryDefaultPrice(String type) {
    switch (type) {
      case 'sofa':
        return '₹799/mo';
      case 'bed':
        return '₹899/mo';
      case 'studyTable':
        return '₹399/mo';
      case 'diningTable':
        return '₹549/mo';
      case 'officeChair':
        return '₹249/mo';
      default:
        return '₹499/mo';
    }
  }

  static String _categoryDefaultImageAsset(String type) {
    switch (type) {
      case 'sofa':
        return 'assets/images/home_product_sofa_clean.png';
      case 'bed':
        return 'assets/images/home_category_beds.png';
      case 'studyTable':
        return 'assets/images/home_product_table_clean.png';
      case 'diningTable':
        return 'assets/images/home_category_tables.png';
      case 'officeChair':
        return 'assets/images/home_category_chairs.png';
      default:
        return 'assets/images/home_product_sofa_clean.png';
    }
  }

  static String _categoryDefaultDescription(String type) {
    switch (type) {
      case 'sofa':
        return 'A plush 2-seater sofa with soft cushions and sturdy wooden legs.';
      case 'bed':
        return 'A comfortable queen-size bed frame with a padded headboard.';
      case 'studyTable':
        return 'A compact study table with a handy drawer, ideal for work.';
      case 'diningTable':
        return 'A sturdy wooden dining table that seats the family comfortably.';
      case 'officeChair':
        return 'An ergonomic chair designed for all-day comfort.';
      default:
        return 'High quality rentable furniture for your living space.';
    }
  }
}

import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/furniture.dart';

/// Local demo data and Firestore stream loader for customer-facing screens.
class DemoData {
  DemoData._();

  static const List<String> categories = [
    'Sofas',
    'Beds',
    'Tables',
    'Chairs',
    'Wardrobes',
    'Lamps',
  ];

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

  static Stream<List<Furniture>> watchLiveFurniture({
    FirebaseFirestore? firestore,
  }) {
    try {
      FirebaseFirestore? db;
      if (firestore != null) {
        db = firestore;
      } else {
        try {
          db = FirebaseFirestore.instance;
        } catch (_) {
          db = null;
        }
      }

      if (db == null) return Stream.value(furniture);

      return db.collection('furniture').snapshots().map((snapshot) {
        if (snapshot.docs.isEmpty) return furniture;
        return snapshot.docs
            .map((doc) => Furniture.fromFirestore(doc))
            .toList();
      });
    } catch (_) {
      return Stream.value(furniture);
    }
  }

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

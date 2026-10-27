import 'package:cloud_firestore/cloud_firestore.dart';

/// A customer record stored in the Firestore `customers` collection.
///
/// Schema (enforced by Firestore security rules):
/// ```
/// {
///   "name":        string (non-empty)
///   "phoneNumber": string (non-empty)
///   "email":       string
///   "address":     string
///   "memberSince": timestamp
///   "createdAt":   timestamp
///   "updatedAt":   timestamp
/// }
/// ```
class Customer {
  final String id;
  final String name;
  final String phoneNumber;
  final String email;
  final String address;
  final int activeRentals;
  final DateTime? memberSince;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const Customer({
    required this.id,
    required this.name,
    required this.phoneNumber,
    required this.email,
    required this.address,
    this.activeRentals = 0,
    this.memberSince,
    this.createdAt,
    this.updatedAt,
  });

  String get rentalsLabel {
    if (activeRentals == 0) return 'No active rentals';
    if (activeRentals == 1) return '1 active rental';
    return '$activeRentals active rentals';
  }

  // ── Display helpers ──────────────────────────────────────────────────────────

  /// Two-letter initials derived from the customer name.
  String get initials {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty) return '?';
    if (parts.length == 1) return parts[0][0].toUpperCase();
    return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
  }

  /// Human-readable member-since string (e.g. "Jan 2024").
  String get memberSinceLabel {
    if (memberSince == null) return 'Unknown';
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    return '${months[memberSince!.month - 1]} ${memberSince!.year}';
  }

  bool matchesQuery(String cleanQuery) {
    if (cleanQuery.isEmpty) return true;
    return name.toLowerCase().contains(cleanQuery) ||
        phoneNumber.replaceAll(' ', '').contains(cleanQuery) ||
        initials.toLowerCase().contains(cleanQuery) ||
        email.toLowerCase().contains(cleanQuery);
  }

  // ── Firestore serialisation ──────────────────────────────────────────────────

  Map<String, dynamic> toMap() {
    return {
      'name': name.trim(),
      'phoneNumber': phoneNumber.trim(),
      'email': email.trim(),
      'address': address.trim(),
      'memberSince': memberSince == null
          ? FieldValue.serverTimestamp()
          : Timestamp.fromDate(memberSince!),
      'createdAt': createdAt == null
          ? FieldValue.serverTimestamp()
          : Timestamp.fromDate(createdAt!),
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }

  factory Customer.fromMap(String id, Map<String, dynamic> map) {
    return Customer(
      id: id,
      name: _str(map, 'name'),
      phoneNumber: _str(map, 'phoneNumber'),
      email: _optStr(map, 'email') ?? '',
      address: _optStr(map, 'address') ?? '',
      activeRentals: (map['activeRentals'] as num?)?.toInt() ?? 0,
      memberSince: _optDate(map['memberSince']),
      createdAt: _optDate(map['createdAt']),
      updatedAt: _optDate(map['updatedAt']),
    );
  }

  factory Customer.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data();
    if (data == null) {
      throw FormatException('Customer document ${doc.id} has no data.');
    }
    return Customer.fromMap(doc.id, data);
  }

  // ── Private helpers ──────────────────────────────────────────────────────────

  static String _str(Map<String, dynamic> map, String field) {
    final v = map[field];
    if (v is String && v.trim().isNotEmpty) return v.trim();
    throw FormatException('Customer field "$field" is missing or blank.');
  }

  static String? _optStr(Map<String, dynamic> map, String field) {
    final v = map[field];
    if (v is String && v.trim().isNotEmpty) return v.trim();
    return null;
  }

  static DateTime? _optDate(dynamic v) {
    if (v is Timestamp) return v.toDate();
    if (v is DateTime) return v;
    return null;
  }

  static List<Customer> get mockCustomers => [
        Customer(
          id: 'CUST-001',
          name: 'Rahul Sharma',
          phoneNumber: '+91 98765 43210',
          email: 'rahul.sharma@example.com',
          address: '402, Green Glen Layout, Bellandur, Bengaluru',
          activeRentals: 12,
          memberSince: DateTime(2024, 1, 1),
        ),
        Customer(
          id: 'CUST-002',
          name: 'Priya Mehta',
          phoneNumber: '+91 87654 32109',
          email: 'priya.mehta@example.com',
          address: '88, 4th Cross, Koramangala 5th Block, Bengaluru',
          activeRentals: 3,
          memberSince: DateTime(2024, 3, 1),
        ),
        Customer(
          id: 'CUST-003',
          name: 'Arjun Singh',
          phoneNumber: '+91 76543 21098',
          email: 'arjun.singh@example.com',
          address: 'Villa 14, Prestige Silver Oak, Whitefield, Bengaluru',
          activeRentals: 1,
          memberSince: DateTime(2024, 7, 1),
        ),
        Customer(
          id: 'CUST-004',
          name: 'Neha Kapoor',
          phoneNumber: '+91 65432 10987',
          email: 'neha.kapoor@example.com',
          address: 'Flat 203, Orchid Enclave, HSR Layout, Bengaluru',
          activeRentals: 2,
          memberSince: DateTime(2025, 2, 1),
        ),
        Customer(
          id: 'CUST-005',
          name: 'Vikram Raina',
          phoneNumber: '+91 98760 12345',
          email: 'vikram.raina@example.com',
          address: 'B-701, Sobha Dream Acres, Panathur, Bengaluru',
          activeRentals: 0,
          memberSince: DateTime(2025, 8, 1),
        ),
      ];
}

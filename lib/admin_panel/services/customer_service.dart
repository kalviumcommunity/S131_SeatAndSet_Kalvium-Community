import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/customer.dart';

/// CRUD + real-time service for the Firestore `customers` collection.
///
/// Schema per document:
///   name, phoneNumber, email, address, memberSince, createdAt, updatedAt
class CustomerService {
  CustomerService({this.firestore});

  final FirebaseFirestore? firestore;

  FirebaseFirestore get _effectiveFirestore {
    if (firestore != null) return firestore!;
    try {
      return FirebaseFirestore.instance;
    } catch (_) {
      throw StateError('Firebase is not initialized.');
    }
  }

  CollectionReference<Map<String, dynamic>> get _col =>
      _effectiveFirestore.collection('customers');

  // ── Read ─────────────────────────────────────────────────────────────────────

  /// Live stream of all customers, ordered by name.
  Stream<List<Customer>> watchAllCustomers() {
    try {
      if (firestore == null) {
        try {
          FirebaseFirestore.instance;
        } catch (_) {
          return Stream.value(<Customer>[]);
        }
      }
      return _col.orderBy('name').snapshots().map(
            (snapshot) => snapshot.docs
                .map((doc) => Customer.fromMap(doc.id, doc.data()))
                .toList(),
          );
    } catch (_) {
      return Stream.value(<Customer>[]);
    }
  }

  /// One-shot fetch of all customers.
  Future<List<Customer>> getAllCustomers() async {
    try {
      final snapshot = await _col.orderBy('name').get();
      return snapshot.docs
          .map((doc) => Customer.fromMap(doc.id, doc.data()))
          .toList();
    } catch (_) {
      return <Customer>[];
    }
  }

  Future<Customer?> getCustomerById(String customerId) async {
    final id = customerId.trim();
    if (id.isEmpty) throw ArgumentError('Customer ID cannot be empty.');
    final doc = await _col.doc(id).get();
    if (!doc.exists || doc.data() == null) return null;
    return Customer.fromMap(doc.id, doc.data()!);
  }

  // ── Write ────────────────────────────────────────────────────────────────────

  /// Adds a new customer and returns the generated document ID.
  Future<String> addCustomer(Customer customer) async {
    _validate(customer);
    final ref = _col.doc();
    await ref.set({
      ...customer.toMap(),
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
    return ref.id;
  }

  /// Overwrites mutable fields on an existing customer record.
  Future<void> updateCustomer(Customer customer) async {
    if (customer.id.trim().isEmpty) {
      throw ArgumentError('Customer ID cannot be empty for an update.');
    }
    _validate(customer);
    await _col.doc(customer.id).update({
      'name': customer.name.trim(),
      'phoneNumber': customer.phoneNumber.trim(),
      'email': customer.email.trim(),
      'address': customer.address.trim(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  /// Deletes a customer record.
  Future<void> deleteCustomer(String customerId) async {
    final id = customerId.trim();
    if (id.isEmpty) throw ArgumentError('Customer ID cannot be empty.');
    await _col.doc(id).delete();
  }

  // ── Private ──────────────────────────────────────────────────────────────────

  void _validate(Customer c) {
    if (c.name.trim().isEmpty) throw ArgumentError('Customer name is required.');
    if (c.phoneNumber.trim().isEmpty) {
      throw ArgumentError('Customer phone number is required.');
    }
  }
}

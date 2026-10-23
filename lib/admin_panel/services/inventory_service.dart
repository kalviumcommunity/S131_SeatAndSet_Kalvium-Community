import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/inventory_item.dart';

class InventoryService {
  InventoryService({this.firestore});

  final FirebaseFirestore? firestore;

  FirebaseFirestore get _effectiveFirestore => firestore ?? FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _furnitureCollection =>
      _effectiveFirestore.collection('furniture');

  /// Fetch all furniture items once.
  Future<List<InventoryItem>> getFurniture() async {
    try {
      final snapshot = await _furnitureCollection.get();

      return snapshot.docs
          .map((doc) => InventoryItem.fromMap(doc.id, doc.data()))
          .toList();
    } catch (_) {
      return <InventoryItem>[];
    }
  }

  /// Listen for real-time inventory changes.
  Stream<List<InventoryItem>> watchFurniture() {
    try {
      return _furnitureCollection.snapshots().map(
        (snapshot) => snapshot.docs
            .map((doc) => InventoryItem.fromMap(doc.id, doc.data()))
            .toList(),
      );
    } catch (_) {
      return Stream.value(<InventoryItem>[]);
    }
  }

  /// Add furniture and return its generated document ID.
  Future<String> addFurniture(InventoryItem item) async {
    final normalizedSku = item.sku.trim();

    if (item.name.trim().isEmpty) {
      throw ArgumentError('Furniture name cannot be empty.');
    }

    if (normalizedSku.isEmpty) {
      throw ArgumentError('Furniture SKU cannot be empty.');
    }

    // Use the SKU as the document ID to prevent duplicate IDs
    // for the same SKU. Existing documents are not overwritten.
    final document = _furnitureCollection.doc(normalizedSku);

    return _effectiveFirestore.runTransaction<String>((transaction) async {
      final existing = await transaction.get(document);

      if (existing.exists) {
        throw StateError('Furniture SKU already exists: $normalizedSku');
      }

      transaction.set(document, {
        ...item.toMap(),
        'name': item.name.trim(),
        'sku': normalizedSku,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      return document.id;
    });
  }

  /// Update furniture details without replacing creation metadata.
  Future<void> updateFurniture(InventoryItem item) async {
    if (item.id.trim().isEmpty) {
      throw ArgumentError('Furniture document ID cannot be empty.');
    }

    if (item.name.trim().isEmpty || item.sku.trim().isEmpty) {
      throw ArgumentError('Furniture name and SKU are required.');
    }

    final document = _furnitureCollection.doc(item.id);
    final skuDocument = _furnitureCollection.doc(item.sku.trim());

    await _effectiveFirestore.runTransaction<void>((transaction) async {
      if (document.path != skuDocument.path) {
        final existingSku = await transaction.get(skuDocument);

        if (existingSku.exists) {
          throw StateError('Furniture SKU already exists: ${item.sku.trim()}');
        }
      }

      transaction.update(document, {
        ...item.toMap(),
        'name': item.name.trim(),
        'sku': item.sku.trim(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    });
  }

  /// Change only the furniture status.
  Future<void> updateFurnitureStatus(
    String furnitureId,
    InventoryStatus status,
  ) async {
    if (furnitureId.trim().isEmpty) {
      throw ArgumentError('Furniture document ID cannot be empty.');
    }

    await _furnitureCollection.doc(furnitureId).update({
      'status': status.name,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  /// Delete a furniture record.
  ///
  /// Use only when deletion is permitted by your business rules.
  /// Furniture linked to rental history should generally be archived.
  Future<void> deleteFurniture(String furnitureId) async {
    if (furnitureId.trim().isEmpty) {
      throw ArgumentError('Furniture document ID cannot be empty.');
    }

    await _furnitureCollection.doc(furnitureId).delete();
  }
}

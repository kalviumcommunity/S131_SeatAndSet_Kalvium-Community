import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

import 'demo_data.dart';
import '../models/booking.dart';
import '../models/furniture.dart';

/// Customer bookings controller with live Firestore synchronization.
class BookingsController {
  BookingsController._();

  static final BookingsController instance = BookingsController._();

  final ValueNotifier<List<Booking>> bookings = ValueNotifier<List<Booking>>(
    const [],
  );

  void add(Booking booking) {
    bookings.value = [booking, ...bookings.value];
  }

  void remove(String id) {
    bookings.value = bookings.value.where((b) => b.id != id).toList();
  }

  Stream<List<Booking>> watchCustomerBookings({
    required String customerId,
    FirebaseFirestore? firestore,
  }) {
    try {
      FirebaseFirestore? db = firestore;
      if (db == null) {
        try {
          db = FirebaseFirestore.instance;
        } catch (_) {
          return Stream.value(bookings.value);
        }
      }

      return db
          .collection('bookings')
          .where('customerId', isEqualTo: customerId)
          .snapshots()
          .map((snapshot) {
        final liveList =
            snapshot.docs.map((doc) => _mapFirestoreDocToBooking(doc)).toList();

        // Combine live Firestore bookings with in-memory session bookings
        final combined = <Booking>[...liveList];
        for (final b in bookings.value) {
          if (!combined.any((item) => item.id == b.id)) {
            combined.add(b);
          }
        }
        return combined;
      });
    } catch (_) {
      return Stream.value(bookings.value);
    }
  }

  Booking _mapFirestoreDocToBooking(
      QueryDocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data();
    final fid = data['furnitureId'] as String? ?? '';

    final matchingFurniture = DemoData.furniture.firstWhere(
      (f) => f.id == fid,
      orElse: () => Furniture(
        id: fid,
        name: 'Rentable Item',
        category: 'Furniture',
        price: '₹499/mo',
        imageAsset: 'assets/images/home_product_sofa_clean.png',
        description: 'Quality furniture item.',
        rating: 4.5,
        reviewCount: 100,
      ),
    );

    final startDate =
        (data['startDate'] as Timestamp?)?.toDate() ?? DateTime.now();
    final endDate = (data['endDate'] as Timestamp?)?.toDate() ??
        DateTime.now().add(const Duration(days: 30));
    final createdAt =
        (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now();

    return Booking(
      id: doc.id,
      item: matchingFurniture,
      quantity: 1,
      startDate: startDate,
      endDate: endDate,
      addressLabel: 'Home',
      addressDetail: 'Registered Address',
      rent: 499,
      deliveryCharge: 99,
      total: 598,
      bookedAt: createdAt,
    );
  }
}

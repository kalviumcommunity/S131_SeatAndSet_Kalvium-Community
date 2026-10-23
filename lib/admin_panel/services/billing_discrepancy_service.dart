import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/billing_discrepancy.dart';
import '../models/booking.dart';
import '../models/delivery.dart';

class BillingDiscrepancyService {
  BillingDiscrepancyService({
    FirebaseFirestore? firestore,
  }) : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  /// Scans active bookings and deliveries to detect basic discrepancy flags
  /// supported by existing data.
  Future<List<BillingDiscrepancy>> detectDiscrepancies({
    DateTime? referenceTime,
  }) async {
    final now = referenceTime ?? DateTime.now();
    final discrepancies = <BillingDiscrepancy>[];

    final bookingsSnapshot = await _firestore.collection('bookings').get();
    final deliveriesSnapshot = await _firestore.collection('deliveries').get();

    final bookings = bookingsSnapshot.docs
        .map((doc) => Booking.fromMap(doc.id, doc.data()))
        .toList();

    final deliveries = deliveriesSnapshot.docs
        .map((doc) => Delivery.fromMap(doc.id, doc.data()))
        .toList();

    for (final booking in bookings) {
      // 1. Check for overdue rentals (end date passed, not returned or cancelled)
      if (booking.status != BookingStatus.cancelled &&
          booking.status != BookingStatus.returned &&
          booking.status != BookingStatus.pickedUp &&
          booking.endDate.isBefore(now)) {
        final daysOverdue = now.difference(booking.endDate).inDays;
        discrepancies.add(
          BillingDiscrepancy(
            id: 'DISC-OVERDUE-${booking.id}',
            bookingId: booking.id,
            customerId: booking.customerId,
            furnitureId: booking.furnitureId,
            type: DiscrepancyType.overdueRental,
            severity: daysOverdue > 7
                ? DiscrepancySeverity.high
                : (daysOverdue > 3
                    ? DiscrepancySeverity.medium
                    : DiscrepancySeverity.low),
            description:
                'Rental is overdue by $daysOverdue day(s). Expected return was ${booking.endDate}.',
            detectedAt: now,
          ),
        );
      }

      // 2. Check for missing delivery records for active/delivered bookings
      if (booking.status == BookingStatus.delivered ||
          booking.status == BookingStatus.active) {
        final bookingDeliveries = deliveries.where(
          (d) => d.bookingId == booking.id && d.type == DeliveryType.delivery,
        );
        if (bookingDeliveries.isEmpty) {
          discrepancies.add(
            BillingDiscrepancy(
              id: 'DISC-NODELIVERY-${booking.id}',
              bookingId: booking.id,
              customerId: booking.customerId,
              furnitureId: booking.furnitureId,
              type: DiscrepancyType.missingDeliveryRecord,
              severity: DiscrepancySeverity.medium,
              description:
                  'Booking is active/delivered but has no corresponding delivery record.',
              detectedAt: now,
            ),
          );
        }
      }
    }

    // 3. Check for delayed pickups
    for (final delivery in deliveries) {
      if (delivery.type == DeliveryType.pickup &&
          delivery.status != DeliveryStatus.completed &&
          delivery.status != DeliveryStatus.cancelled &&
          delivery.scheduledAt.isBefore(now)) {
        discrepancies.add(
          BillingDiscrepancy(
            id: 'DISC-DELAYEDPICKUP-${delivery.id}',
            bookingId: delivery.bookingId,
            customerId: delivery.customerId,
            furnitureId: delivery.furnitureId,
            type: DiscrepancyType.delayedPickup,
            severity: DiscrepancySeverity.high,
            description:
                'Pickup scheduled for ${delivery.scheduledAt} has not been completed.',
            detectedAt: now,
          ),
        );
      }
    }

    return discrepancies;
  }
}

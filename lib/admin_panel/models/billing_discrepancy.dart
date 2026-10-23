enum DiscrepancyType {
  overdueRental,
  delayedPickup,
  missingDeliveryRecord,
}

enum DiscrepancySeverity {
  low,
  medium,
  high,
}

class BillingDiscrepancy {
  final String id;
  final String bookingId;
  final String customerId;
  final String furnitureId;
  final DiscrepancyType type;
  final DiscrepancySeverity severity;
  final String description;
  final DateTime detectedAt;

  const BillingDiscrepancy({
    required this.id,
    required this.bookingId,
    required this.customerId,
    required this.furnitureId,
    required this.type,
    required this.severity,
    required this.description,
    required this.detectedAt,
  });
}

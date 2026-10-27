import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../models/reports_data.dart';

/// Aggregates report metrics from the `bookings` and `furniture` Firestore
/// collections.
///
/// Revenue figures are computed from `bookings` documents that expose an
/// optional `totalAmount` field (added by the booking creation flow or a
/// Cloud Function). If the field is absent, it is treated as ₹0 so the
/// count-based metrics remain accurate even without a pricing backend.
class ReportsService {
  ReportsService({this.firestore});

  final FirebaseFirestore? firestore;

  FirebaseFirestore get _effectiveFirestore {
    if (firestore != null) return firestore!;
    try {
      return FirebaseFirestore.instance;
    } catch (_) {
      throw StateError('Firebase is not initialized.');
    }
  }

  CollectionReference<Map<String, dynamic>> get _bookings =>
      _effectiveFirestore.collection('bookings');

  CollectionReference<Map<String, dynamic>> get _furniture =>
      _effectiveFirestore.collection('furniture');

  // ── Public API ───────────────────────────────────────────────────────────────

  /// Live stream of [ReportsData] for the given [timeframe].
  ///
  /// The stream merges a snapshot of bookings within the time window with a
  /// snapshot of the furniture catalogue (for category breakdown).
  Stream<ReportsData> watchReportsData(String timeframe) {
    try {
      if (firestore == null) {
        try {
          FirebaseFirestore.instance;
        } catch (_) {
          return Stream.value(ReportsData.forTimeframe(timeframe));
        }
      }
      final range = _dateRange(timeframe);
      final bookingsStream = _bookings
          .where('createdAt',
              isGreaterThanOrEqualTo: Timestamp.fromDate(range.start))
          .where('createdAt',
              isLessThanOrEqualTo: Timestamp.fromDate(range.end))
          .snapshots();

      return bookingsStream.asyncMap((bookingSnap) async {
        final furnitureSnap = await _furniture.get();
        return _compute(timeframe, bookingSnap, furnitureSnap);
      });
    } catch (_) {
      return Stream.value(ReportsData.forTimeframe(timeframe));
    }
  }

  /// One-shot fetch of [ReportsData] for the given [timeframe].
  Future<ReportsData> getReportsData(String timeframe) async {
    try {
      final range = _dateRange(timeframe);

      final bookingSnap = await _bookings
          .where('createdAt',
              isGreaterThanOrEqualTo: Timestamp.fromDate(range.start))
          .where('createdAt', isLessThanOrEqualTo: Timestamp.fromDate(range.end))
          .get();

      final furnitureSnap = await _furniture.get();
      return _compute(timeframe, bookingSnap, furnitureSnap);
    } catch (_) {
      return ReportsData.forTimeframe(timeframe);
    }
  }

  // ── Private helpers ──────────────────────────────────────────────────────────

  _DateRange _dateRange(String timeframe) {
    final now = DateTime.now();
    switch (timeframe) {
      case 'This Week':
        final start =
            now.subtract(Duration(days: now.weekday - 1)).copyWith(
                  hour: 0, minute: 0, second: 0, millisecond: 0);
        return _DateRange(start, now);
      case 'This Quarter':
        final quarterStart = DateTime(now.year, ((now.month - 1) ~/ 3) * 3 + 1);
        return _DateRange(quarterStart, now);
      case 'This Year':
        return _DateRange(DateTime(now.year, 1, 1), now);
      case 'This Month':
      default:
        return _DateRange(DateTime(now.year, now.month, 1), now);
    }
  }

  ReportsData _compute(
    String timeframe,
    QuerySnapshot<Map<String, dynamic>> bookingSnap,
    QuerySnapshot<Map<String, dynamic>> furnitureSnap,
  ) {
    final docs = bookingSnap.docs;

    // ── Totals ───────────────────────────────────────────────────────────────
    final totalRentals = docs.length;
    final totalRevenue = docs.fold<double>(
      0,
      (sum, doc) => sum + ((doc.data()['totalAmount'] as num?)?.toDouble() ?? 0),
    );

    // ── Daily trend ──────────────────────────────────────────────────────────
    final Map<int, int> perDay = {};
    for (final doc in docs) {
      final ts = doc.data()['createdAt'];
      if (ts is Timestamp) {
        final day = ts.toDate().day;
        perDay[day] = (perDay[day] ?? 0) + 1;
      }
    }

    final sortedDays = perDay.keys.toList()..sort();
    final trendPoints = sortedDays.map((day) {
      return DailyRentalTrendPoint(day: day, count: perDay[day]!);
    }).toList();

    // ── Category breakdown ────────────────────────────────────────────────────
    // Build furnitureId → type mapping from furniture snapshot.
    final Map<String, String> furnitureTypes = {
      for (final doc in furnitureSnap.docs)
        doc.id: (doc.data()['type'] as String? ?? 'sofa'),
    };

    // Count active (non-cancelled) bookings per furniture category.
    final Map<String, int> categoryCounts = {};
    for (final doc in docs) {
      final data = doc.data();
      final status = data['status'] as String? ?? '';
      if (status == 'cancelled') continue;
      final fid = data['furnitureId'] as String? ?? '';
      final type = furnitureTypes[fid] ?? 'sofa';
      final label = _typeLabel(type);
      categoryCounts[label] = (categoryCounts[label] ?? 0) + 1;
    }

    final maxCount = categoryCounts.values.fold(0, (a, b) => a > b ? a : b);
    final topCategories = _orderedCategories(categoryCounts, maxCount);

    return ReportsData(
      timeframe: timeframe,
      totalRevenue: totalRevenue > 0
          ? '₹${_formatAmount(totalRevenue)}'
          : totalRentals > 0
              ? '—'   // bookings exist but no pricing data yet
              : '₹0',
      revenueGrowth: '—',        // growth requires prior-period data
      totalRentals: totalRentals,
      rentalsGrowth: '—',
      trendPoints: trendPoints,
      topCategories: topCategories,
    );
  }

  String _typeLabel(String type) {
    switch (type) {
      case 'sofa':        return 'Sofas';
      case 'studyTable':  return 'Tables';
      case 'diningTable': return 'Tables';
      case 'officeChair': return 'Chairs';
      case 'bed':         return 'Beds';
      default:            return 'Other';
    }
  }

  /// Returns up to 4 categories in a fixed display order.
  List<CategoryReportItem> _orderedCategories(
      Map<String, int> counts, int maxCount) {
    final order = <String, IconData>{
      'Sofas':  Icons.weekend_outlined,
      'Tables': Icons.table_restaurant_outlined,
      'Chairs': Icons.chair_alt_outlined,
      'Beds':   Icons.bed_outlined,
      'Other':  Icons.inventory_2_outlined,
    };

    return order.entries
        .where((e) => counts.containsKey(e.key))
        .map((e) => CategoryReportItem(
              name: e.key,
              count: counts[e.key]!,
              maxCount: maxCount == 0 ? 1 : maxCount,
              icon: e.value,
            ))
        .toList();
  }

  String _formatAmount(double amount) {
    if (amount >= 100000) {
      return '${(amount / 100000).toStringAsFixed(1)} L';
    }
    if (amount >= 1000) {
      // Format as Indian numbering: e.g. 1,24,800
      final intAmount = amount.toInt();
      final str = intAmount.toString();
      if (str.length <= 3) return str;
      final last3 = str.substring(str.length - 3);
      final rest = str.substring(0, str.length - 3);
      final buf = StringBuffer();
      for (var i = 0; i < rest.length; i++) {
        if (i > 0 && (rest.length - i) % 2 == 0) buf.write(',');
        buf.write(rest[i]);
      }
      return '$buf,$last3';
    }
    return amount.toStringAsFixed(0);
  }
}

class _DateRange {
  final DateTime start;
  final DateTime end;
  const _DateRange(this.start, this.end);
}

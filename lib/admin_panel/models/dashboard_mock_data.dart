enum ActivityType { delivery, pickup, booking }

class ActivityItem {
  final String title;
  final String orderId;
  final String timeAgo;
  final ActivityType type;

  const ActivityItem({
    required this.title,
    required this.orderId,
    required this.timeAgo,
    required this.type,
  });
}

class DashboardData {
  final int totalItems;
  final int rented;
  final int available;
  final int inTransit;

  final int deliveriesToday;
  final int pickupsToday;
  final String delayStatus;
  final bool hasDelays;

  final String currentDateFormatted;
  final List<ActivityItem> recentActivities;

  const DashboardData({
    required this.totalItems,
    required this.rented,
    required this.available,
    required this.inTransit,
    required this.deliveriesToday,
    required this.pickupsToday,
    required this.delayStatus,
    required this.hasDelays,
    required this.currentDateFormatted,
    required this.recentActivities,
  });

  /// Mock data matching the exact Figma mockup (Admin 03 – Dashboard)
  factory DashboardData.mock() {
    return const DashboardData(
      totalItems: 124,
      rented: 86,
      available: 28,
      inTransit: 10,
      deliveriesToday: 5,
      pickupsToday: 3,
      delayStatus: 'No delays today',
      hasDelays: false,
      currentDateFormatted: 'Mon, 15 Sep 2025',
      recentActivities: [
        ActivityItem(
          title: 'Sofa delivered',
          orderId: '#ORD1234',
          timeAgo: '2 mins ago',
          type: ActivityType.delivery,
        ),
        ActivityItem(
          title: 'Pickup scheduled',
          orderId: '#ORD1235',
          timeAgo: '15 mins ago',
          type: ActivityType.pickup,
        ),
        ActivityItem(
          title: 'New booking',
          orderId: '#ORD1236',
          timeAgo: '1 hour ago',
          type: ActivityType.booking,
        ),
      ],
    );
  }
}

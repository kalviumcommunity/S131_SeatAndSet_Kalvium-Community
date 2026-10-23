import 'package:flutter/material.dart';

class CategoryReportItem {
  final String name;
  final int count;
  final int maxCount;
  final IconData icon;

  const CategoryReportItem({
    required this.name,
    required this.count,
    required this.maxCount,
    required this.icon,
  });

  double get percentage => maxCount == 0 ? 0.0 : (count / maxCount).clamp(0.0, 1.0);
}

class DailyRentalTrendPoint {
  final int day;
  final int count;
  final bool isHighlight; // whether to show primary purple or lighter lavender

  const DailyRentalTrendPoint({
    required this.day,
    required this.count,
    this.isHighlight = true,
  });
}

class ReportsData {
  final String timeframe;
  final String totalRevenue;
  final String revenueGrowth;
  final int totalRentals;
  final String rentalsGrowth;
  final List<DailyRentalTrendPoint> trendPoints;
  final List<CategoryReportItem> topCategories;

  const ReportsData({
    required this.timeframe,
    required this.totalRevenue,
    required this.revenueGrowth,
    required this.totalRentals,
    required this.rentalsGrowth,
    required this.trendPoints,
    required this.topCategories,
  });

  /// Factory providing exact mock data from Figma Admin 07 – Reports design
  factory ReportsData.mockThisMonth() {
    return const ReportsData(
      timeframe: 'This Month',
      totalRevenue: '₹1,24,800',
      revenueGrowth: '+12%',
      totalRentals: 86,
      rentalsGrowth: '+8%',
      trendPoints: [
        DailyRentalTrendPoint(day: 1, count: 22, isHighlight: true),
        DailyRentalTrendPoint(day: 3, count: 34, isHighlight: true),
        DailyRentalTrendPoint(day: 5, count: 18, isHighlight: false),
        DailyRentalTrendPoint(day: 7, count: 40, isHighlight: true),
        DailyRentalTrendPoint(day: 9, count: 28, isHighlight: true),
        DailyRentalTrendPoint(day: 11, count: 45, isHighlight: false),
        DailyRentalTrendPoint(day: 13, count: 30, isHighlight: true),
        DailyRentalTrendPoint(day: 15, count: 51, isHighlight: true),
        DailyRentalTrendPoint(day: 17, count: 38, isHighlight: false),
        DailyRentalTrendPoint(day: 19, count: 26, isHighlight: true),
        DailyRentalTrendPoint(day: 21, count: 44, isHighlight: true),
        DailyRentalTrendPoint(day: 23, count: 57, isHighlight: false),
        DailyRentalTrendPoint(day: 25, count: 36, isHighlight: true),
        DailyRentalTrendPoint(day: 27, count: 47, isHighlight: true),
        DailyRentalTrendPoint(day: 29, count: 30, isHighlight: false),
        DailyRentalTrendPoint(day: 30, count: 53, isHighlight: true),
        DailyRentalTrendPoint(day: 31, count: 42, isHighlight: true),
        DailyRentalTrendPoint(day: 32, count: 59, isHighlight: false),
      ],
      topCategories: [
        CategoryReportItem(
          name: 'Sofas',
          count: 32,
          maxCount: 32,
          icon: Icons.weekend_outlined,
        ),
        CategoryReportItem(
          name: 'Tables',
          count: 24,
          maxCount: 32,
          icon: Icons.table_restaurant_outlined,
        ),
        CategoryReportItem(
          name: 'Chairs',
          count: 18,
          maxCount: 32,
          icon: Icons.chair_alt_outlined,
        ),
        CategoryReportItem(
          name: 'Beds',
          count: 12,
          maxCount: 32,
          icon: Icons.bed_outlined,
        ),
      ],
    );
  }

  factory ReportsData.mockThisWeek() {
    return const ReportsData(
      timeframe: 'This Week',
      totalRevenue: '₹34,200',
      revenueGrowth: '+15%',
      totalRentals: 24,
      rentalsGrowth: '+6%',
      trendPoints: [
        DailyRentalTrendPoint(day: 1, count: 18, isHighlight: true),
        DailyRentalTrendPoint(day: 2, count: 25, isHighlight: true),
        DailyRentalTrendPoint(day: 3, count: 32, isHighlight: false),
        DailyRentalTrendPoint(day: 4, count: 28, isHighlight: true),
        DailyRentalTrendPoint(day: 5, count: 42, isHighlight: true),
        DailyRentalTrendPoint(day: 6, count: 55, isHighlight: false),
        DailyRentalTrendPoint(day: 7, count: 48, isHighlight: true),
      ],
      topCategories: [
        CategoryReportItem(
          name: 'Sofas',
          count: 10,
          maxCount: 10,
          icon: Icons.weekend_outlined,
        ),
        CategoryReportItem(
          name: 'Tables',
          count: 7,
          maxCount: 10,
          icon: Icons.table_restaurant_outlined,
        ),
        CategoryReportItem(
          name: 'Chairs',
          count: 5,
          maxCount: 10,
          icon: Icons.chair_alt_outlined,
        ),
        CategoryReportItem(
          name: 'Beds',
          count: 2,
          maxCount: 10,
          icon: Icons.bed_outlined,
        ),
      ],
    );
  }

  factory ReportsData.mockThisQuarter() {
    return const ReportsData(
      timeframe: 'This Quarter',
      totalRevenue: '₹3,88,400',
      revenueGrowth: '+18%',
      totalRentals: 264,
      rentalsGrowth: '+14%',
      trendPoints: [
        DailyRentalTrendPoint(day: 1, count: 35, isHighlight: true),
        DailyRentalTrendPoint(day: 5, count: 45, isHighlight: true),
        DailyRentalTrendPoint(day: 10, count: 52, isHighlight: false),
        DailyRentalTrendPoint(day: 15, count: 48, isHighlight: true),
        DailyRentalTrendPoint(day: 20, count: 58, isHighlight: false),
        DailyRentalTrendPoint(day: 25, count: 54, isHighlight: true),
        DailyRentalTrendPoint(day: 30, count: 60, isHighlight: true),
      ],
      topCategories: [
        CategoryReportItem(
          name: 'Sofas',
          count: 98,
          maxCount: 98,
          icon: Icons.weekend_outlined,
        ),
        CategoryReportItem(
          name: 'Tables',
          count: 76,
          maxCount: 98,
          icon: Icons.table_restaurant_outlined,
        ),
        CategoryReportItem(
          name: 'Chairs',
          count: 54,
          maxCount: 98,
          icon: Icons.chair_alt_outlined,
        ),
        CategoryReportItem(
          name: 'Beds',
          count: 36,
          maxCount: 98,
          icon: Icons.bed_outlined,
        ),
      ],
    );
  }

  factory ReportsData.mockThisYear() {
    return const ReportsData(
      timeframe: 'This Year',
      totalRevenue: '₹14,92,000',
      revenueGrowth: '+22%',
      totalRentals: 1048,
      rentalsGrowth: '+19%',
      trendPoints: [
        DailyRentalTrendPoint(day: 1, count: 40, isHighlight: true),
        DailyRentalTrendPoint(day: 5, count: 48, isHighlight: false),
        DailyRentalTrendPoint(day: 10, count: 55, isHighlight: true),
        DailyRentalTrendPoint(day: 15, count: 52, isHighlight: true),
        DailyRentalTrendPoint(day: 20, count: 58, isHighlight: false),
        DailyRentalTrendPoint(day: 25, count: 56, isHighlight: true),
        DailyRentalTrendPoint(day: 30, count: 60, isHighlight: false),
      ],
      topCategories: [
        CategoryReportItem(
          name: 'Sofas',
          count: 380,
          maxCount: 380,
          icon: Icons.weekend_outlined,
        ),
        CategoryReportItem(
          name: 'Tables',
          count: 290,
          maxCount: 380,
          icon: Icons.table_restaurant_outlined,
        ),
        CategoryReportItem(
          name: 'Chairs',
          count: 215,
          maxCount: 380,
          icon: Icons.chair_alt_outlined,
        ),
        CategoryReportItem(
          name: 'Beds',
          count: 163,
          maxCount: 380,
          icon: Icons.bed_outlined,
        ),
      ],
    );
  }

  static final ReportsData _thisMonth = ReportsData.mockThisMonth();
  static final ReportsData _thisWeek = ReportsData.mockThisWeek();
  static final ReportsData _thisQuarter = ReportsData.mockThisQuarter();
  static final ReportsData _thisYear = ReportsData.mockThisYear();

  static ReportsData forTimeframe(String timeframe) {
    switch (timeframe) {
      case 'This Week':
        return _thisWeek;
      case 'This Quarter':
        return _thisQuarter;
      case 'This Year':
        return _thisYear;
      case 'This Month':
      default:
        return _thisMonth;
    }
  }
}

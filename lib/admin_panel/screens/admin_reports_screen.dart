import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../models/reports_data.dart';
import 'admin_dashboard_screen.dart';
import 'admin_inventory_screen.dart';
import 'admin_orders_screen.dart';
import 'admin_customers_screen.dart';

class AdminReportsScreen extends StatefulWidget {
  final bool showBottomNav;
  final ValueChanged<int>? onNavigateTab;

  const AdminReportsScreen({
    super.key,
    this.showBottomNav = true,
    this.onNavigateTab,
  });

  @override
  State<AdminReportsScreen> createState() => _AdminReportsScreenState();
}

class _AdminReportsScreenState extends State<AdminReportsScreen> {
  String _selectedTimeframe = 'This Month';
  late ReportsData _reportsData;
  int? _selectedBarIndex;

  @override
  void initState() {
    super.initState();
    _reportsData = ReportsData.forTimeframe(_selectedTimeframe);
  }

  void _onTimeframeChanged(String timeframe) {
    if (_selectedTimeframe == timeframe) return;
    setState(() {
      _selectedTimeframe = timeframe;
      _reportsData = ReportsData.forTimeframe(timeframe);
      _selectedBarIndex = null;
    });
  }

  void _showTimeframePicker() {
    final options = ['This Week', 'This Month', 'This Quarter', 'This Year'];

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                const Text(
                  'Select Timeframe',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1E202B),
                  ),
                ),
                const SizedBox(height: 12),
                for (final option in options)
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(
                      option,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: _selectedTimeframe == option
                            ? FontWeight.bold
                            : FontWeight.w500,
                        color: _selectedTimeframe == option
                            ? const Color(0xFF5D5FEF)
                            : const Color(0xFF1E202B),
                      ),
                    ),
                    trailing: _selectedTimeframe == option
                        ? const Icon(
                            Icons.check_circle_rounded,
                            color: Color(0xFF5D5FEF),
                          )
                        : null,
                    onTap: () {
                      Navigator.pop(ctx);
                      _onTimeframeChanged(option);
                    },
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: const Color(0xFFF7F8FC),
        body: SafeArea(
          bottom: false,
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 18),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 12),
                      _buildHeader(),
                      const SizedBox(height: 16),
                      _buildMetricCard(
                        value: _reportsData.totalRevenue,
                        label: 'Total Revenue',
                        growth: _reportsData.revenueGrowth,
                      ),
                      const SizedBox(height: 12),
                      _buildMetricCard(
                        value: '${_reportsData.totalRentals}',
                        label: 'Total Rentals',
                        growth: _reportsData.rentalsGrowth,
                      ),
                      const SizedBox(height: 22),
                      const Text(
                        'Rentals Trend',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1B1D28),
                          letterSpacing: -0.3,
                        ),
                      ),
                      const SizedBox(height: 12),
                      _buildRentalsTrendCard(),
                      const SizedBox(height: 22),
                      const Text(
                        'Top Categories',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1B1D28),
                          letterSpacing: -0.3,
                        ),
                      ),
                      const SizedBox(height: 12),
                      _buildTopCategoriesCard(),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
              _buildBottomNavigationBar(),
            ],
          ),
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Header with Timeframe Dropdown
  // ---------------------------------------------------------------------------
  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          'Reports',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1E202B),
            letterSpacing: -0.5,
          ),
        ),
        GestureDetector(
          onTap: _showTimeframePicker,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: const Color(0xFFE2E4EE),
                width: 1.0,
              ),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x06000000),
                  blurRadius: 4,
                  offset: Offset(0, 1),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  _selectedTimeframe,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF2E303E),
                  ),
                ),
                const SizedBox(width: 4),
                const Icon(
                  Icons.keyboard_arrow_down_rounded,
                  size: 18,
                  color: Color(0xFF5E6375),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // Metric Cards (Revenue, Rentals)
  // ---------------------------------------------------------------------------
  Widget _buildMetricCard({
    required String value,
    required String label,
    required String growth,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFFEAECEF),
          width: 0.8,
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x05000000),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: const TextStyle(
                  fontSize: 27,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF1B1D28),
                  letterSpacing: -0.5,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFEAF7EE),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  growth,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF22C55E),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: Color(0xFF8E95A5),
            ),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Rentals Trend Chart Card
  // ---------------------------------------------------------------------------
  Widget _buildRentalsTrendCard() {
    final points = _reportsData.trendPoints;
    const maxVal = 60.0;
    const chartHeight = 130.0;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(14, 18, 14, 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFFEAECEF),
          width: 0.8,
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x05000000),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Active tooltip indicator if a bar is selected
          if (_selectedBarIndex != null && _selectedBarIndex! < points.length)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E202B),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    'Day ${points[_selectedBarIndex!].day}: ${points[_selectedBarIndex!].count} rentals',
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),

          RepaintBoundary(
            child: SizedBox(
              height: chartHeight,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Y-axis labels
                Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text(
                      '60',
                      style: TextStyle(
                        fontSize: 11,
                        color: Color(0xFFA5ABC0),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      '40',
                      style: TextStyle(
                        fontSize: 11,
                        color: Color(0xFFA5ABC0),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      '20',
                      style: TextStyle(
                        fontSize: 11,
                        color: Color(0xFFA5ABC0),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      '0',
                      style: TextStyle(
                        fontSize: 11,
                        color: Color(0xFFA5ABC0),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 8),

                // Chart Grid & Bars
                Expanded(
                  child: Stack(
                    children: [
                      // Horizontal grid lines
                      Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          for (int i = 0; i < 4; i++)
                            Container(
                              height: 1,
                              color: const Color(0xFFF0F2F8),
                            ),
                        ],
                      ),

                      // Vertical Bars
                      Positioned.fill(
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            for (int i = 0; i < points.length; i++)
                              GestureDetector(
                                onTap: () {
                                  setState(() {
                                    _selectedBarIndex =
                                        _selectedBarIndex == i ? null : i;
                                  });
                                },
                                behavior: HitTestBehavior.opaque,
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 1.5),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      AnimatedContainer(
                                        duration: const Duration(milliseconds: 300),
                                        curve: Curves.easeOutCubic,
                                        width: 8.5,
                                        height: (points[i].count / maxVal * (chartHeight - 16))
                                            .clamp(6.0, chartHeight - 16),
                                        decoration: BoxDecoration(
                                          color: _selectedBarIndex == i
                                              ? const Color(0xFF3838E8)
                                              : (points[i].isHighlight
                                                  ? const Color(0xFF5D5FEF)
                                                  : const Color(0xFFB5B7FB)),
                                          borderRadius: BorderRadius.circular(4),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),

          const SizedBox(height: 8),

          // X-axis day labels
          Padding(
            padding: const EdgeInsets.only(left: 24, right: 6),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: const [
                Text(
                  '01',
                  style: TextStyle(
                    fontSize: 11,
                    color: Color(0xFFA5ABC0),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  '05',
                  style: TextStyle(
                    fontSize: 11,
                    color: Color(0xFFA5ABC0),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  '10',
                  style: TextStyle(
                    fontSize: 11,
                    color: Color(0xFFA5ABC0),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  '15',
                  style: TextStyle(
                    fontSize: 11,
                    color: Color(0xFFA5ABC0),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  '20',
                  style: TextStyle(
                    fontSize: 11,
                    color: Color(0xFFA5ABC0),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  '25',
                  style: TextStyle(
                    fontSize: 11,
                    color: Color(0xFFA5ABC0),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  '30',
                  style: TextStyle(
                    fontSize: 11,
                    color: Color(0xFFA5ABC0),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Top Categories Card
  // ---------------------------------------------------------------------------
  Widget _buildTopCategoriesCard() {
    final categories = _reportsData.topCategories;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFFEAECEF),
          width: 0.8,
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x05000000),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          for (int i = 0; i < categories.length; i++) ...[
            _buildCategoryRow(categories[i]),
            if (i < categories.length - 1) const SizedBox(height: 16),
          ],
        ],
      ),
    );
  }

  Widget _buildCategoryRow(CategoryReportItem item) {
    return Row(
      children: [
        // Category Icon Container
        Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: const Color(0xFFEEF0FE),
            borderRadius: BorderRadius.circular(10),
          ),
          alignment: Alignment.center,
          child: Icon(
            item.icon,
            color: const Color(0xFF5D5FEF),
            size: 20,
          ),
        ),
        const SizedBox(width: 12),

        // Category Name
        SizedBox(
          width: 60,
          child: Text(
            item.name,
            style: const TextStyle(
              fontSize: 14.5,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1B1D28),
            ),
          ),
        ),
        const SizedBox(width: 8),

        // Horizontal Progress Bar
        Expanded(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final totalWidth = constraints.maxWidth;
              final filledWidth = (totalWidth * item.percentage).clamp(6.0, totalWidth);

              return Stack(
                children: [
                  // Background Track
                  Container(
                    height: 7,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF3F4FB),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),

                  // Filled Bar
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeOutCubic,
                    height: 7,
                    width: filledWidth,
                    decoration: BoxDecoration(
                      color: const Color(0xFF5D5FEF),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
        const SizedBox(width: 14),

        // Count Value
        Text(
          '${item.count}',
          style: const TextStyle(
            fontSize: 14.5,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1B1D28),
          ),
        ),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // Bottom Navigation Bar
  // ---------------------------------------------------------------------------
  Widget _buildBottomNavigationBar() {
    if (!widget.showBottomNav) return const SizedBox.shrink();

    final navItems = [
      _NavItem(icon: Icons.grid_view_rounded, label: 'Dashboard'),
      _NavItem(icon: Icons.inventory_2_outlined, label: 'Inventory'),
      _NavItem(icon: Icons.receipt_long_outlined, label: 'Orders'),
      _NavItem(icon: Icons.people_outline_rounded, label: 'Customers'),
      _NavItem(icon: Icons.bar_chart_rounded, label: 'Reports'),
    ];

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(color: Colors.grey.shade200, width: 0.8),
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x06000000),
            blurRadius: 10,
            offset: Offset(0, -3),
          ),
        ],
      ),
      padding: const EdgeInsets.only(top: 8, bottom: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          for (int i = 0; i < navItems.length; i++)
            _buildNavButton(
              item: navItems[i],
              isSelected: i == 4, // Reports is selected
              onTap: () {
                if (widget.onNavigateTab != null) {
                  widget.onNavigateTab!(i);
                  return;
                }
                if (i == 0) {
                  Navigator.pushReplacement(
                    context,
                    PageRouteBuilder(
                      pageBuilder: (_, _, _) => const AdminDashboardScreen(),
                      transitionDuration: Duration.zero,
                    ),
                  );
                } else if (i == 1) {
                  Navigator.pushReplacement(
                    context,
                    PageRouteBuilder(
                      pageBuilder: (_, _, _) => const AdminInventoryScreen(),
                      transitionDuration: Duration.zero,
                    ),
                  );
                } else if (i == 2) {
                  Navigator.pushReplacement(
                    context,
                    PageRouteBuilder(
                      pageBuilder: (_, _, _) => const AdminOrdersScreen(),
                      transitionDuration: Duration.zero,
                    ),
                  );
                } else if (i == 3) {
                  Navigator.pushReplacement(
                    context,
                    PageRouteBuilder(
                      pageBuilder: (_, _, _) => const AdminCustomersScreen(),
                      transitionDuration: Duration.zero,
                    ),
                  );
                }
              },
            ),
        ],
      ),
    );
  }

  Widget _buildNavButton({
    required _NavItem item,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (isSelected)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 5),
              decoration: BoxDecoration(
                color: const Color(0xFFEEF0FE),
                borderRadius: BorderRadius.circular(18),
              ),
              child: Icon(
                item.icon,
                size: 22,
                color: const Color(0xFF5D5FEF),
              ),
            )
          else
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 5),
              child: Icon(
                item.icon,
                size: 22,
                color: const Color(0xFF9AA0B2),
              ),
            ),
          const SizedBox(height: 3),
          Text(
            item.label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
              color: isSelected
                  ? const Color(0xFF5D5FEF)
                  : const Color(0xFF8E95A5),
            ),
          ),
        ],
      ),
    );
  }
}

class _NavItem {
  final IconData icon;
  final String label;

  _NavItem({required this.icon, required this.label});
}

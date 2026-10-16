import 'package:flutter/material.dart';

import 'admin_dashboard_screen.dart';
import 'admin_inventory_screen.dart';
import 'admin_orders_screen.dart';
import 'admin_customers_screen.dart';
import 'admin_reports_screen.dart';

/// Performance-optimized state-preserving Navigation Shell for the Admin Panel.
///
/// Uses an [IndexedStack] to keep all 5 admin modules alive in memory, preserving
/// scroll positions, form inputs, search filters, and avoiding redundant route transitions.
class AdminShellScreen extends StatefulWidget {
  final int initialIndex;
  final dynamic inventoryService;

  const AdminShellScreen({
    super.key,
    this.initialIndex = 0,
    this.inventoryService,
  });

  static AdminShellScreenState? of(BuildContext context) {
    return context.findAncestorStateOfType<AdminShellScreenState>();
  }

  @override
  State<AdminShellScreen> createState() => AdminShellScreenState();
}

class AdminShellScreenState extends State<AdminShellScreen> {
  late int _currentIndex;

  final List<_ShellNavItem> _navItems = const [
    _ShellNavItem(icon: Icons.grid_view_rounded, label: 'Dashboard'),
    _ShellNavItem(icon: Icons.inventory_2_outlined, label: 'Inventory'),
    _ShellNavItem(icon: Icons.receipt_long_outlined, label: 'Orders'),
    _ShellNavItem(icon: Icons.people_outline_rounded, label: 'Customers'),
    _ShellNavItem(icon: Icons.bar_chart_rounded, label: 'Reports'),
  ];

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
  }

  void switchTab(int index) {
    if (index < 0 || index >= _navItems.length) return;
    if (_currentIndex != index) {
      setState(() => _currentIndex = index);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FC),
      body: IndexedStack(
        index: _currentIndex,
        children: [
          AdminDashboardScreen(
            showBottomNav: false,
            onNavigateTab: switchTab,
          ),
          AdminInventoryScreen(
            inventoryService: widget.inventoryService,
            showBottomNav: false,
            onNavigateTab: switchTab,
          ),
          AdminOrdersScreen(
            showBottomNav: false,
            onNavigateTab: switchTab,
          ),
          AdminCustomersScreen(
            showBottomNav: false,
            onNavigateTab: switchTab,
          ),
          AdminReportsScreen(
            showBottomNav: false,
            onNavigateTab: switchTab,
          ),
        ],
      ),
      bottomNavigationBar: _buildMasterBottomNav(),
    );
  }

  Widget _buildMasterBottomNav() {
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
          for (int i = 0; i < _navItems.length; i++)
            _buildNavButton(
              item: _navItems[i],
              isSelected: _currentIndex == i,
              onTap: () => switchTab(i),
            ),
        ],
      ),
    );
  }

  Widget _buildNavButton({
    required _ShellNavItem item,
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

class _ShellNavItem {
  final IconData icon;
  final String label;

  const _ShellNavItem({required this.icon, required this.label});
}

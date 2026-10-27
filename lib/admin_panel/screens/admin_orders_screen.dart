import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../models/delivery.dart';
import '../models/order_delivery_item.dart';
import '../services/delivery_service.dart';
import 'admin_dashboard_screen.dart';
import 'admin_inventory_screen.dart';
import 'admin_customers_screen.dart';
import 'admin_reports_screen.dart';
import '../widgets/admin_animations.dart';

class AdminOrdersScreen extends StatefulWidget {
  final bool showBottomNav;
  final ValueChanged<int>? onNavigateTab;
  final DeliveryService? deliveryService;

  const AdminOrdersScreen({
    super.key,
    this.showBottomNav = true,
    this.onNavigateTab,
    this.deliveryService,
  });

  @override
  State<AdminOrdersScreen> createState() => _AdminOrdersScreenState();
}

class _AdminOrdersScreenState extends State<AdminOrdersScreen> {
  OrderTab _selectedTab = OrderTab.today;
  late final DeliveryService _deliveryService =
      widget.deliveryService ?? DeliveryService();
  late List<OrderDeliveryItem> _mockOrders;

  @override
  void initState() {
    super.initState();
    _mockOrders = OrderDeliveryItem.getMockOrders();
  }

  OrderDeliveryItem _mapDeliveryToOrderItem(Delivery delivery) {
    final now = DateTime.now();
    final isToday = delivery.scheduledAt.year == now.year &&
        delivery.scheduledAt.month == now.month &&
        delivery.scheduledAt.day == now.day;
    final isCompleted = delivery.status == DeliveryStatus.completed;

    OrderTab tab = OrderTab.upcoming;
    if (isCompleted) {
      tab = OrderTab.completed;
    } else if (isToday) {
      tab = OrderTab.today;
    }

    final formattedTime =
        '${delivery.scheduledAt.hour.toString().padLeft(2, '0')}:${delivery.scheduledAt.minute.toString().padLeft(2, '0')}';

    return OrderDeliveryItem(
      id: delivery.id,
      type: delivery.type == DeliveryType.delivery
          ? OrderDeliveryType.deliver
          : OrderDeliveryType.pickup,
      furnitureName: 'Furniture ID: ${delivery.furnitureId}',
      customerName: 'Customer ID: ${delivery.customerId}',
      time: formattedTime,
      tab: tab,
      address: delivery.notes ?? 'Standard Delivery Address',
      phoneNumber: 'N/A',
      status: delivery.status.name,
      notes: delivery.notes,
    );
  }

  void _showNavigationDialog(OrderDeliveryItem item) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: item.isDeliver
                        ? const Color(0xFFEEF0FE)
                        : const Color(0xFFFFEEED),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    item.isDeliver
                        ? Icons.local_shipping_outlined
                        : Icons.store_mall_directory_outlined,
                    color: item.isDeliver
                        ? const Color(0xFF5D5FEF)
                        : const Color(0xFFEF4444),
                    size: 22,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Route to ${item.customerName}',
                        style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF0F172A),
                        ),
                      ),
                      Text(
                        '${item.typeLabel} • ${item.furnitureName}',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: item.isDeliver
                              ? const Color(0xFF5D5FEF)
                              : const Color(0xFFEF4444),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.location_on_outlined,
                    color: Color(0xFF5D5FEF),
                    size: 20,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      item.address,
                      style: const TextStyle(
                        fontSize: 13.5,
                        color: Color(0xFF334155),
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFF334155),
                      padding: const EdgeInsets.symmetric(vertical: 13),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      side: const BorderSide(color: Color(0xFFCBD5E1)),
                    ),
                    icon: const Icon(Icons.call_outlined, size: 18),
                    label: const Text('Call Customer'),
                    onPressed: () {
                      Navigator.pop(ctx);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Calling ${item.customerName} (${item.phoneNumber})...'),
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FilledButton.icon(
                    style: FilledButton.styleFrom(
                      backgroundColor: const Color(0xFF5D5FEF),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 13),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    icon: const Icon(Icons.directions_outlined, size: 18),
                    label: const Text('Start GPS'),
                    onPressed: () {
                      Navigator.pop(ctx);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          backgroundColor: const Color(0xFF16A34A),
                          content: Text('Navigating to: ${item.address}'),
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showOrderDetails(OrderDeliveryItem item) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: item.isDeliver
                            ? const Color(0xFFEEF0FE)
                            : const Color(0xFFFFEEED),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        item.isDeliver
                            ? Icons.local_shipping_outlined
                            : Icons.store_mall_directory_outlined,
                        color: item.isDeliver
                            ? const Color(0xFF5D5FEF)
                            : const Color(0xFFEF4444),
                        size: 22,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.id,
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF64748B),
                          ),
                        ),
                        Text(
                          item.furnitureName,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF0F172A),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: item.isDeliver
                        ? const Color(0xFFEEF0FE)
                        : const Color(0xFFFFEEED),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    item.typeLabel,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: item.isDeliver
                          ? const Color(0xFF5D5FEF)
                          : const Color(0xFFEF4444),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            _buildDetailRow(Icons.person_outline, 'Customer', item.customerName),
            const SizedBox(height: 10),
            _buildDetailRow(Icons.phone_outlined, 'Phone', item.phoneNumber),
            const SizedBox(height: 10),
            _buildDetailRow(Icons.access_time, 'Scheduled Time', item.time),
            const SizedBox(height: 10),
            _buildDetailRow(Icons.location_on_outlined, 'Address', item.address),
            if (item.notes != null) ...[
              const SizedBox(height: 10),
              _buildDetailRow(Icons.notes_outlined, 'Notes', item.notes!),
            ],
            const SizedBox(height: 22),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 13),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      side: const BorderSide(color: Color(0xFF5D5FEF)),
                    ),
                    onPressed: () {
                      Navigator.pop(ctx);
                      _showNavigationDialog(item);
                    },
                    child: const Text(
                      'Navigate',
                      style: TextStyle(
                        color: Color(0xFF5D5FEF),
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FilledButton(
                    style: FilledButton.styleFrom(
                      backgroundColor: const Color(0xFF5D5FEF),
                      padding: const EdgeInsets.symmetric(vertical: 13),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    onPressed: () {
                      Navigator.pop(ctx);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          backgroundColor: const Color(0xFF16A34A),
                          content: Text('Order ${item.id} status updated to Completed!'),
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    },
                    child: const Text('Mark Completed'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFF1F5F9)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: const Color(0xFF64748B)),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF94A3B8),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF0F172A),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
      ),
      child: Scaffold(
        backgroundColor: const Color(0xFFF6F8FC),
        body: SafeArea(
          bottom: false,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Screen Header
              Padding(
                padding: const EdgeInsets.only(left: 20, right: 20, top: 18, bottom: 16),
                child: const Text(
                  'Deliveries & Pickups',
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF0F172A),
                    letterSpacing: -0.3,
                  ),
                ),
              ),

              // Filter Tabs (Today / Upcoming / Completed)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: _buildFilterTabs(),
              ),

              const SizedBox(height: 18),

              // Delivery & Pickup Cards List
              Expanded(
                child: StreamBuilder<List<Delivery>>(
                  stream: _deliveryService.watchAllDeliveries(),
                  builder: (context, snapshot) {
                    List<OrderDeliveryItem> items = [];

                    if (snapshot.hasData && snapshot.data!.isNotEmpty) {
                      items = snapshot.data!
                          .map(_mapDeliveryToOrderItem)
                          .toList();
                    } else {
                      items = _mockOrders;
                    }

                    final filtered = items
                        .where((item) => item.tab == _selectedTab)
                        .toList();

                    if (filtered.isEmpty) {
                      return _buildEmptyState();
                    }

                    return RefreshIndicator(
                      color: const Color(0xFF5D5FEF),
                      backgroundColor: Colors.white,
                      onRefresh: () async {
                        HapticFeedback.lightImpact();
                        await Future<void>.delayed(
                            const Duration(milliseconds: 500));
                        if (mounted) setState(() {});
                      },
                      child: ListView.builder(
                        physics: const AlwaysScrollableScrollPhysics(
                          parent: BouncingScrollPhysics(),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        itemCount: filtered.length,
                        itemBuilder: (context, index) {
                          return StaggeredSlideFade(
                            index: index,
                            child: _buildOrderCard(filtered[index]),
                          );
                        },
                      ),
                    );
                  },
                ),
              ),

              // Bottom Navigation Bar with Orders selected
              _buildBottomNavigationBar(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFilterTabs() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
        boxShadow: const [
          BoxShadow(
            color: Color(0x060F172A),
            blurRadius: 10,
            offset: Offset(0, 3),
          ),
        ],
      ),
      padding: const EdgeInsets.all(4),
      child: Row(
        children: [
          _buildTabPill('Today', OrderTab.today),
          _buildTabPill('Upcoming', OrderTab.upcoming),
          _buildTabPill('Completed', OrderTab.completed),
        ],
      ),
    );
  }

  Widget _buildTabPill(String title, OrderTab tab) {
    final isSelected = _selectedTab == tab;

    return Expanded(
      child: BouncingScaleTap(
        onTap: () => setState(() => _selectedTab = tab),
        scaleDown: 0.94,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeInOut,
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFF5D5FEF) : Colors.transparent,
            borderRadius: BorderRadius.circular(24),
          ),
          alignment: Alignment.center,
          child: Text(
            title,
            style: TextStyle(
              fontSize: 14,
              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
              color: isSelected ? Colors.white : const Color(0xFF64748B),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildOrderCard(OrderDeliveryItem item) {
    return BouncingScaleTap(
      scaleDown: 0.98,
      onTap: () => _showOrderDetails(item),
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: const [
            BoxShadow(
              color: Color(0x060F172A),
              blurRadius: 12,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Icon badge (Deliver vs Pickup)
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: item.isDeliver
                    ? const Color(0xFFEEF0FE)
                    : const Color(0xFFFFEEED),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(
                item.isDeliver
                    ? Icons.local_shipping_outlined
                    : Icons.store_mall_directory_outlined,
                color: item.isDeliver
                    ? const Color(0xFF5D5FEF)
                    : const Color(0xFFEF4444),
                size: 22,
              ),
            ),

            const SizedBox(width: 14),

            // Details column
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.typeLabel,
                    style: TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w700,
                      color: item.isDeliver
                          ? const Color(0xFF5D5FEF)
                          : const Color(0xFFEF4444),
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    item.furnitureName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    '${item.partyPrefix}${item.customerName}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF64748B),
                    ),
                  ),
                  const SizedBox(height: 7),
                  Row(
                    children: [
                      const Icon(
                        Icons.access_time_rounded,
                        size: 14,
                        color: Color(0xFF64748B),
                      ),
                      const SizedBox(width: 5),
                      Expanded(
                        child: Text(
                          item.time,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w500,
                            color: Color(0xFF64748B),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

          const SizedBox(width: 8),

          // Actions Column (3 dots and Navigate button)
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              PopupMenuButton<String>(
                padding: EdgeInsets.zero,
                icon: const Icon(
                  Icons.more_vert_rounded,
                  color: Color(0xFF94A3B8),
                  size: 20,
                ),
                onSelected: (action) {
                  if (action == 'navigate') {
                    _showNavigationDialog(item);
                  } else if (action == 'details') {
                    _showOrderDetails(item);
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('$action for ${item.furnitureName}'),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  }
                },
                itemBuilder: (context) => const [
                  PopupMenuItem(
                    value: 'details',
                    child: Text('View Details'),
                  ),
                  PopupMenuItem(
                    value: 'navigate',
                    child: Text('Directions'),
                  ),
                  PopupMenuItem(
                    value: 'Call Customer',
                    child: Text('Call Customer'),
                  ),
                  PopupMenuItem(
                    value: 'Mark In Progress',
                    child: Text('Mark In Progress'),
                  ),
                  PopupMenuItem(
                    value: 'Mark Completed',
                    child: Text('Mark Completed'),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              SizedBox(
                height: 34,
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(
                      color: Color(0xFF5D5FEF),
                      width: 1.2,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                  ),
                  onPressed: () => _showNavigationDialog(item),
                  child: const Text(
                    'Navigate',
                    style: TextStyle(
                      color: Color(0xFF5D5FEF),
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            _selectedTab == OrderTab.completed
                ? Icons.check_circle_outline_rounded
                : Icons.schedule_rounded,
            size: 52,
            color: const Color(0xFF94A3B8),
          ),
          const SizedBox(height: 14),
          Text(
            'No ${_selectedTab.name} orders',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: Color(0xFF334155),
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Check other tabs for scheduled deliveries & pickups.',
            style: TextStyle(
              fontSize: 13,
              color: Color(0xFF64748B),
            ),
          ),
        ],
      ),
    );
  }

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
              isSelected: i == 2, // Orders is selected
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
                } else if (i == 3) {
                  Navigator.pushReplacement(
                    context,
                    PageRouteBuilder(
                      pageBuilder: (_, _, _) => const AdminCustomersScreen(),
                      transitionDuration: Duration.zero,
                    ),
                  );
                } else if (i == 4) {
                  Navigator.pushReplacement(
                    context,
                    PageRouteBuilder(
                      pageBuilder: (_, _, _) => const AdminReportsScreen(),
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
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
            decoration: BoxDecoration(
              color: isSelected ? const Color(0xFFEEF2FF) : Colors.transparent,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              item.icon,
              size: 22,
              color: isSelected ? const Color(0xFF4F46E5) : const Color(0xFF94A3B8),
            ),
          ),
          const SizedBox(height: 2),
          Text(
            item.label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
              color: isSelected ? const Color(0xFF4F46E5) : const Color(0xFF94A3B8),
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

  const _NavItem({required this.icon, required this.label});
}

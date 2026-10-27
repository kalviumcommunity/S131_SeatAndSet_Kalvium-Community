import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/delivery.dart';
import '../models/inventory_item.dart';
import '../services/admin_auth_service.dart';
import '../services/delivery_service.dart';
import '../services/inventory_service.dart';
import 'admin_login_screen.dart';
import 'admin_inventory_screen.dart';
import 'admin_orders_screen.dart';
import 'admin_customers_screen.dart';
import 'admin_reports_screen.dart';
import '../widgets/admin_animations.dart';

class AdminDashboardScreen extends StatefulWidget {
  final bool showBottomNav;
  final ValueChanged<int>? onNavigateTab;
  final InventoryService? inventoryService;
  final DeliveryService? deliveryService;

  const AdminDashboardScreen({
    super.key,
    this.showBottomNav = true,
    this.onNavigateTab,
    this.inventoryService,
    this.deliveryService,
  });

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  int _selectedNavIndex = 0;
  late final InventoryService _inventoryService =
      widget.inventoryService ?? InventoryService();
  late final DeliveryService _deliveryService =
      widget.deliveryService ?? DeliveryService();
  AdminAuthService? _authService;

  void _handleSignOut() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Log Out',
          style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
        ),
        content: const Text(
          'Are you sure you want to sign out from the Admin Dashboard?',
          style: TextStyle(color: Color(0xFF64748B)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel', style: TextStyle(color: Color(0xFF64748B))),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFDC2626),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Sign Out'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await (_authService ??= AdminAuthService()).signOut();
      if (!mounted) return;
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const AdminLoginScreen()),
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Set status bar icons dark for the light dashboard background
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
            children: [
              Expanded(
                child: RefreshIndicator(
                  color: const Color(0xFF4F46E5),
                  backgroundColor: Colors.white,
                  onRefresh: () async {
                    HapticFeedback.lightImpact();
                    await Future<void>.delayed(const Duration(milliseconds: 500));
                    if (mounted) setState(() {});
                  },
                  child: ListView(
                    physics: const AlwaysScrollableScrollPhysics(
                      parent: BouncingScrollPhysics(),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  children: [
                    // Top App Header
                    _buildHeader(),
                    const SizedBox(height: 20),

                    // 4 KPI Summary Cards Row
                    _buildInventoryKpiSection(),
                    const SizedBox(height: 24),

                    // "Today" Section
                    _buildTodaySection(),
                    const SizedBox(height: 24),

                    // "Recent Activity" Section
                    _buildRecentActivitySection(),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
              ),
              // Bottom Navigation Bar
              _buildBottomNavigationBar(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    final now = DateTime.now();
    const weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    final dateLabel =
        '${weekdays[now.weekday - 1]}, ${now.day} ${months[now.month - 1]} ${now.year}';

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Dashboard',
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.w800,
                color: Color(0xFF0F172A),
                letterSpacing: -0.3,
              ),
            ),
            const SizedBox(height: 3),
            Text(
              dateLabel,
              style: const TextStyle(
                fontSize: 13.5,
                fontWeight: FontWeight.w500,
                color: Color(0xFF64748B),
              ),
            ),
          ],
        ),
        // Notification Icon with red dot badge + Logout popup
        PopupMenuButton<String>(
          icon: Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                height: 44,
                width: 44,
                decoration: BoxDecoration(
                  color: const Color(0xFFEFF2FE),
                  shape: BoxShape.circle,
                  border: Border.all(color: const Color(0xFFE0E7FF), width: 1),
                ),
                child: const Icon(
                  Icons.notifications_none_rounded,
                  color: Color(0xFF4F46E5),
                  size: 22,
                ),
              ),
              const Positioned(
                top: 4,
                right: 4,
                child: PulsingGlowBadge(
                  color: Color(0xFFEF4444),
                  size: 8,
                ),
              ),
            ],
          ),
          offset: const Offset(0, 50),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          onSelected: (value) {
            if (value == 'logout') {
              _handleSignOut();
            }
          },
          itemBuilder: (ctx) => [
            const PopupMenuItem(
              value: 'notifications',
              child: Row(
                children: [
                  Icon(Icons.mark_email_read_outlined, size: 18, color: Color(0xFF64748B)),
                  SizedBox(width: 10),
                  Text('3 New Notifications', style: TextStyle(fontSize: 13.5)),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'logout',
              child: Row(
                children: [
                  Icon(Icons.logout_rounded, size: 18, color: Color(0xFFDC2626)),
                  SizedBox(width: 10),
                  Text('Sign Out', style: TextStyle(fontSize: 13.5, color: Color(0xFFDC2626))),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildInventoryKpiSection() {
    return StreamBuilder<List<InventoryItem>>(
      stream: _inventoryService.watchFurniture(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting &&
            !snapshot.hasData) {
          return Column(
            children: [
              _buildKpiRow(),
              _buildInventoryState('Loading inventory...'),
            ],
          );
        }

        if (snapshot.hasError) {
          return Column(
            children: [
              _buildKpiRow(),
              _buildInventoryState(
                'Inventory metrics are unavailable. Check your connection.',
                isError: true,
              ),
            ],
          );
        }

        final items = snapshot.data ?? <InventoryItem>[];
        return Column(
          children: [
            _buildKpiRow(items),
            if (items.isEmpty)
              _buildInventoryState('No inventory has been added yet.'),
          ],
        );
      },
    );
  }

  Widget _buildInventoryState(String message, {bool isError = false}) {
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Row(
        children: [
          Icon(
            isError ? Icons.cloud_off_outlined : Icons.inventory_2_outlined,
            size: 16,
            color: isError ? const Color(0xFFDC2626) : const Color(0xFF64748B),
          ),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              message,
              style: TextStyle(
                fontSize: 12,
                color: isError
                    ? const Color(0xFFDC2626)
                    : const Color(0xFF64748B),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildKpiRow([List<InventoryItem>? items]) {
    dynamic countFor(InventoryStatus? status) {
      if (items == null) return '—';
      if (status == null) return items.length;
      return items.where((item) => item.status == status).length;
    }

    return Row(
      children: [
        _buildKpiCard(
          index: 0,
          value: countFor(null),
          label: 'Total Items',
          countColor: const Color(0xFF3730A3),
          onTap: () => widget.onNavigateTab?.call(1),
        ),
        const SizedBox(width: 10),
        _buildKpiCard(
          index: 1,
          value: countFor(InventoryStatus.rented),
          label: 'Rented',
          countColor: const Color(0xFF16A34A),
          onTap: () => widget.onNavigateTab?.call(1),
        ),
        const SizedBox(width: 10),
        _buildKpiCard(
          index: 2,
          value: countFor(InventoryStatus.available),
          label: 'Available',
          countColor: const Color(0xFF2563EB),
          onTap: () => widget.onNavigateTab?.call(1),
        ),
        const SizedBox(width: 10),
        _buildKpiCard(
          index: 3,
          value: countFor(InventoryStatus.inTransit),
          label: 'In Transit',
          countColor: const Color(0xFFDC2626),
          onTap: () => widget.onNavigateTab?.call(1),
        ),
      ],
    );
  }

  Widget _buildKpiCard({
    required int index,
    required dynamic value,
    required String label,
    required Color countColor,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: StaggeredSlideFade(
        index: index,
        child: BouncingScaleTap(
          onTap: onTap,
          scaleDown: 0.94,
          child: Container(
            key: ValueKey(label),
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 4),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x080F172A),
                  blurRadius: 10,
                  offset: Offset(0, 3),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (value is num)
                  AnimatedCounter(
                    value: value,
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: countColor,
                      letterSpacing: -0.5,
                    ),
                  )
                else
                  Text(
                    value.toString(),
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: countColor,
                      letterSpacing: -0.5,
                    ),
                  ),
                const SizedBox(height: 5),
                Text(
                  label,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF64748B),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTodaySection() {
    return StreamBuilder<List<Delivery>>(
      stream: _deliveryService.watchAllDeliveries(),
      builder: (context, snapshot) {
        final deliveries = snapshot.data ?? [];
        final today = DateTime.now();
        final todayDeliveries = deliveries.where((d) {
          final isToday = d.scheduledAt.year == today.year &&
              d.scheduledAt.month == today.month &&
              d.scheduledAt.day == today.day;
          return isToday &&
              d.type == DeliveryType.delivery &&
              d.status != DeliveryStatus.cancelled;
        }).length;
        final todayPickups = deliveries.where((d) {
          final isToday = d.scheduledAt.year == today.year &&
              d.scheduledAt.month == today.month &&
              d.scheduledAt.day == today.day;
          return isToday &&
              d.type == DeliveryType.pickup &&
              d.status != DeliveryStatus.cancelled;
        }).length;

        final hasDelays = deliveries.any((d) {
          final isToday = d.scheduledAt.year == today.year &&
              d.scheduledAt.month == today.month &&
              d.scheduledAt.day == today.day;
          return isToday && d.status == DeliveryStatus.delayed;
        });

        final delayStatus =
            hasDelays ? 'Some deliveries are delayed today' : 'No delays today';

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Today',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: Color(0xFF0F172A),
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x080F172A),
                    blurRadius: 10,
                    offset: Offset(0, 3),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: BouncingScaleTap(
                      onTap: () => widget.onNavigateTab?.call(2),
                      child: Row(
                        children: [
                          Container(
                            height: 44, width: 44,
                            decoration: const BoxDecoration(
                              color: Color(0xFFEEF2FF),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.local_shipping_outlined,
                              color: Color(0xFF6366F1), size: 22,
                            ),
                          ),
                          const SizedBox(width: 14),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              AnimatedCounter(
                                value: todayDeliveries,
                                style: const TextStyle(
                                  fontSize: 21,
                                  fontWeight: FontWeight.w800,
                                  color: Color(0xFF4F46E5),
                                ),
                              ),
                              const SizedBox(height: 2),
                              const Text(
                                'Deliveries',
                                style: TextStyle(
                                  fontSize: 12.5,
                                  fontWeight: FontWeight.w500,
                                  color: Color(0xFF64748B),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  Container(height: 40, width: 1, color: const Color(0xFFF1F5F9)),
                  const SizedBox(width: 16),
                  Expanded(
                    child: BouncingScaleTap(
                      onTap: () => widget.onNavigateTab?.call(2),
                      child: Row(
                        children: [
                          Container(
                            height: 44, width: 44,
                            decoration: const BoxDecoration(
                              color: Color(0xFFFEE2E2),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.home_outlined,
                              color: Color(0xFFEF4444), size: 23,
                            ),
                          ),
                          const SizedBox(width: 14),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              AnimatedCounter(
                                value: todayPickups,
                                style: const TextStyle(
                                  fontSize: 21,
                                  fontWeight: FontWeight.w800,
                                  color: Color(0xFFDC2626),
                                ),
                              ),
                              const SizedBox(height: 2),
                              const Text(
                                'Pickups',
                                style: TextStyle(
                                  fontSize: 12.5,
                                  fontWeight: FontWeight.w500,
                                  color: Color(0xFF64748B),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            BouncingScaleTap(
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    backgroundColor: hasDelays
                        ? const Color(0xFFDC2626)
                        : const Color(0xFF16A34A),
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    content: Row(
                      children: [
                        Icon(
                          hasDelays
                              ? Icons.warning_amber_rounded
                              : Icons.check_circle_outline,
                          color: Colors.white,
                          size: 20,
                        ),
                        const SizedBox(width: 10),
                        Text(hasDelays
                            ? 'Some deliveries are running late.'
                            : 'Fleet dispatch is running 100% on schedule!'),
                      ],
                    ),
                  ),
                );
              },
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
                decoration: BoxDecoration(
                  color:
                      hasDelays ? const Color(0xFFFEF2F2) : const Color(0xFFEDFBF3),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: hasDelays
                        ? const Color(0xFFFECACA)
                        : const Color(0xFFD1FAE5),
                    width: 1,
                  ),
                ),
                child: Row(
                  children: [
                    PulsingGlowBadge(
                      color: hasDelays
                          ? const Color(0xFFDC2626)
                          : const Color(0xFF16A34A),
                      size: 9,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        delayStatus,
                        style: TextStyle(
                          fontSize: 13.5,
                          fontWeight: FontWeight.w600,
                          color: hasDelays
                              ? const Color(0xFFDC2626)
                              : const Color(0xFF16A34A),
                        ),
                      ),
                    ),
                    Icon(
                      Icons.chevron_right_rounded,
                      color: hasDelays
                          ? const Color(0xFFDC2626)
                          : const Color(0xFF16A34A),
                      size: 20,
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildRecentActivitySection() {
    return StreamBuilder<List<Delivery>>(
      stream: _deliveryService.watchAllDeliveries(),
      builder: (context, snapshot) {
        // Show skeleton while loading
        if (snapshot.connectionState == ConnectionState.waiting &&
            !snapshot.hasData) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Recent Activity',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF0F172A),
                ),
              ),
              const SizedBox(height: 12),
              Container(
                height: 100,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                ),
                child: const Center(
                  child: CircularProgressIndicator(color: Color(0xFF4F46E5)),
                ),
              ),
            ],
          );
        }

        final deliveries = snapshot.data ?? [];

        // Sort by scheduledAt descending, take most recent 5
        final recent = [...deliveries]
          ..sort((a, b) => b.scheduledAt.compareTo(a.scheduledAt));
        final items = recent.take(5).toList();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Recent Activity',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: Color(0xFF0F172A),
              ),
            ),
            const SizedBox(height: 12),
            if (items.isEmpty)
              Container(
                padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x080F172A),
                      blurRadius: 10,
                      offset: Offset(0, 3),
                    ),
                  ],
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.inbox_outlined, size: 22, color: Color(0xFF94A3B8)),
                    SizedBox(width: 10),
                    Text(
                      'No recent deliveries or pickups',
                      style: TextStyle(
                        fontSize: 13.5,
                        color: Color(0xFF94A3B8),
                      ),
                    ),
                  ],
                ),
              )
            else
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x080F172A),
                      blurRadius: 10,
                      offset: Offset(0, 3),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    for (int i = 0; i < items.length; i++) ...[
                      StaggeredSlideFade(
                        index: i,
                        child: _buildDeliveryActivityTile(items[i]),
                      ),
                      if (i < items.length - 1)
                        const Divider(
                          height: 1,
                          thickness: 1,
                          color: Color(0xFFF8FAFC),
                          indent: 68,
                          endIndent: 16,
                        ),
                    ],
                  ],
                ),
              ),
          ],
        );
      },
    );
  }

  Widget _buildDeliveryActivityTile(Delivery delivery) {
    final isDelivery = delivery.type == DeliveryType.delivery;
    final icon = isDelivery
        ? Icons.local_shipping_outlined
        : Icons.home_outlined;
    final iconColor =
        isDelivery ? const Color(0xFF6366F1) : const Color(0xFF16A34A);
    final bgColor =
        isDelivery ? const Color(0xFFEEF2FF) : const Color(0xFFDCFCE7);

    final now = DateTime.now();
    final diff = now.difference(delivery.scheduledAt);
    String timeAgo;
    if (diff.inMinutes < 60) {
      timeAgo = '${diff.inMinutes} min ago';
    } else if (diff.inHours < 24) {
      timeAgo = '${diff.inHours}h ago';
    } else {
      timeAgo = '${diff.inDays}d ago';
    }
    if (delivery.scheduledAt.isAfter(now)) {
      timeAgo = 'Upcoming';
    }

    final label =
        isDelivery ? 'Delivery scheduled' : 'Pickup scheduled';

    return BouncingScaleTap(
      onTap: () => widget.onNavigateTab?.call(2),
      scaleDown: 0.97,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Container(
              height: 42,
              width: 42,
              decoration: BoxDecoration(color: bgColor, shape: BoxShape.circle),
              child: Icon(icon, color: iconColor, size: 20),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: const TextStyle(
                      fontSize: 14.5,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    '#${delivery.id.substring(0, delivery.id.length.clamp(0, 8))} • $timeAgo',
                    style: const TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w400,
                      color: Color(0xFF64748B),
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.chevron_right_rounded,
              color: Color(0xFF94A3B8),
              size: 20,
            ),
          ],
        ),
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
        border: Border(top: BorderSide(color: Colors.grey.shade200, width: 0.8)),
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
              isSelected: _selectedNavIndex == i,
              onTap: () {
                if (widget.onNavigateTab != null) {
                  widget.onNavigateTab!(i);
                  return;
                }
                setState(() => _selectedNavIndex = i);
                if (i == 1) {
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

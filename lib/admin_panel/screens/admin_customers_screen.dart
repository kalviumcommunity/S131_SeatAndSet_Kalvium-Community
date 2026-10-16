import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../models/customer_item.dart';
import 'admin_dashboard_screen.dart';
import 'admin_inventory_screen.dart';
import 'admin_orders_screen.dart';

class AdminCustomersScreen extends StatefulWidget {
  const AdminCustomersScreen({super.key});

  @override
  State<AdminCustomersScreen> createState() => _AdminCustomersScreenState();
}

class _AdminCustomersScreenState extends State<AdminCustomersScreen> {
  final TextEditingController _searchController = TextEditingController();
  late List<CustomerItem> _allCustomers;

  @override
  void initState() {
    super.initState();
    _allCustomers = CustomerItem.getMockCustomers();
    _searchController.addListener(_onSearchChanged);
  }

  void _onSearchChanged() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  List<CustomerItem> get _filteredCustomers {
    final query = _searchController.text.toLowerCase().trim();
    if (query.isEmpty) return _allCustomers;

    return _allCustomers.where((customer) {
      return customer.name.toLowerCase().contains(query) ||
          customer.phoneNumber.replaceAll(' ', '').contains(query.replaceAll(' ', '')) ||
          customer.initials.toLowerCase().contains(query);
    }).toList();
  }

  void _showCustomerDetailsSheet(CustomerItem customer) {
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
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: const BoxDecoration(
                    color: Color(0xFFEEF0FE),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      customer.initials,
                      style: const TextStyle(
                        color: Color(0xFF5D5FEF),
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        customer.name,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF0F172A),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        customer.phoneNumber,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF64748B),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: customer.activeRentals > 0
                        ? const Color(0xFFEEF0FE)
                        : const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    customer.rentalsLabel,
                    style: TextStyle(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w700,
                      color: customer.activeRentals > 0
                          ? const Color(0xFF5D5FEF)
                          : const Color(0xFF64748B),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            _buildDetailRow(Icons.email_outlined, 'Email Address', customer.email),
            const SizedBox(height: 10),
            _buildDetailRow(Icons.location_on_outlined, 'Delivery Address', customer.address),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: _buildDetailRow(
                    Icons.calendar_today_outlined,
                    'Member Since',
                    customer.memberSince,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _buildDetailRow(
                    Icons.payments_outlined,
                    'Total Spent',
                    customer.totalSpent,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 22),
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
                    icon: const Icon(Icons.chat_bubble_outline_rounded, size: 18),
                    label: const Text('Message'),
                    onPressed: () {
                      Navigator.pop(ctx);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Opening message to ${customer.name}...'),
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
                    icon: const Icon(Icons.call_outlined, size: 18),
                    label: const Text('Call'),
                    onPressed: () {
                      Navigator.pop(ctx);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          backgroundColor: const Color(0xFF16A34A),
                          content: Text('Dialing ${customer.name} (${customer.phoneNumber})...'),
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
    final filtered = _filteredCustomers;

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
              // Screen Header Title
              const Padding(
                padding: EdgeInsets.only(left: 20, right: 20, top: 18, bottom: 16),
                child: Text(
                  'Customers',
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF0F172A),
                    letterSpacing: -0.3,
                  ),
                ),
              ),

              // Search Bar
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Container(
                  height: 50,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x060F172A),
                        blurRadius: 10,
                        offset: Offset(0, 3),
                      ),
                    ],
                  ),
                  child: TextField(
                    controller: _searchController,
                    style: const TextStyle(
                      color: Color(0xFF0F172A),
                      fontSize: 14.5,
                    ),
                    decoration: InputDecoration(
                      isDense: true,
                      hintText: 'Search customers...',
                      hintStyle: const TextStyle(
                        color: Color(0xFF94A3B8),
                        fontSize: 14.5,
                      ),
                      prefixIcon: const Icon(
                        Icons.search_rounded,
                        color: Color(0xFF94A3B8),
                        size: 22,
                      ),
                      suffixIcon: _searchController.text.isNotEmpty
                          ? IconButton(
                              icon: const Icon(
                                Icons.clear_rounded,
                                size: 18,
                                color: Color(0xFF94A3B8),
                              ),
                              onPressed: _searchController.clear,
                            )
                          : null,
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 14,
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 18),

              // Customer Cards List
              Expanded(
                child: filtered.isEmpty
                    ? _buildEmptyState()
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        itemCount: filtered.length,
                        itemBuilder: (context, index) {
                          return _buildCustomerCard(filtered[index]);
                        },
                      ),
              ),

              // Bottom Navigation Bar with Customers selected
              _buildBottomNavigationBar(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCustomerCard(CustomerItem customer) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(
            color: Color(0x060F172A),
            blurRadius: 10,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: InkWell(
        onTap: () => _showCustomerDetailsSheet(customer),
        borderRadius: BorderRadius.circular(16),
        child: Row(
          children: [
            // Avatar with initials
            Container(
              width: 52,
              height: 52,
              decoration: const BoxDecoration(
                color: Color(0xFFEEF0FE),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  customer.initials,
                  style: const TextStyle(
                    color: Color(0xFF5D5FEF),
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),

            const SizedBox(width: 14),

            // Customer Name, Phone, and Rentals
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    customer.name,
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
                    customer.phoneNumber,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF64748B),
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    customer.rentalsLabel,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF94A3B8),
                    ),
                  ),
                ],
              ),
            ),

            // 3-dots Menu Button
            PopupMenuButton<String>(
              padding: EdgeInsets.zero,
              icon: const Icon(
                Icons.more_vert_rounded,
                color: Color(0xFF94A3B8),
                size: 20,
              ),
              onSelected: (action) {
                if (action == 'profile') {
                  _showCustomerDetailsSheet(customer);
                } else if (action == 'call') {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Calling ${customer.name} (${customer.phoneNumber})...'),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                } else if (action == 'message') {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Opening chat with ${customer.name}...'),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                }
              },
              itemBuilder: (context) => const [
                PopupMenuItem(
                  value: 'profile',
                  child: Text('View Profile'),
                ),
                PopupMenuItem(
                  value: 'call',
                  child: Text('Call Customer'),
                ),
                PopupMenuItem(
                  value: 'message',
                  child: Text('Send Message'),
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
          const Icon(
            Icons.person_search_outlined,
            size: 52,
            color: Color(0xFF94A3B8),
          ),
          const SizedBox(height: 14),
          const Text(
            'No customers found',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: Color(0xFF334155),
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Try searching for another name or phone number.',
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
              isSelected: i == 3, // Customers is selected
              onTap: () {
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
                } else if (i != 3) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      duration: const Duration(milliseconds: 900),
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      content: Text('${navItems[i].label} section coming soon!'),
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

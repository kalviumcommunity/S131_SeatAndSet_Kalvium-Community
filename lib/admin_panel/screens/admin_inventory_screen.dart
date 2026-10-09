import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/inventory_item.dart';
import '../widgets/furniture_thumbnail.dart';
import 'admin_dashboard_screen.dart';

class AdminInventoryScreen extends StatefulWidget {
  const AdminInventoryScreen({super.key});

  @override
  State<AdminInventoryScreen> createState() => _AdminInventoryScreenState();
}

class _AdminInventoryScreenState extends State<AdminInventoryScreen> {
  final TextEditingController _searchController = TextEditingController();
  final List<InventoryItem> _allItems = InventoryItem.mockItems;
  List<InventoryItem> _filteredItems = [];
  InventoryStatus? _selectedStatusFilter;

  @override
  void initState() {
    super.initState();
    _filteredItems = List.from(_allItems);
    _searchController.addListener(_filterItems);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _filterItems() {
    final query = _searchController.text.toLowerCase().trim();
    setState(() {
      _filteredItems = _allItems.where((item) {
        final matchesQuery = query.isEmpty ||
            item.name.toLowerCase().contains(query) ||
            item.sku.toLowerCase().contains(query);
        final matchesStatus =
            _selectedStatusFilter == null || item.status == _selectedStatusFilter;
        return matchesQuery && matchesStatus;
      }).toList();
    });
  }

  void _showFilterModal() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModalState) => Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Filter Inventory',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      setModalState(() => _selectedStatusFilter = null);
                      setState(() => _selectedStatusFilter = null);
                      _filterItems();
                      Navigator.pop(ctx);
                    },
                    child: const Text('Reset', style: TextStyle(color: Color(0xFF6366F1))),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: [
                  _buildFilterChip('All', _selectedStatusFilter == null, () {
                    setModalState(() => _selectedStatusFilter = null);
                    setState(() => _selectedStatusFilter = null);
                    _filterItems();
                    Navigator.pop(ctx);
                  }),
                  _buildFilterChip('Available', _selectedStatusFilter == InventoryStatus.available, () {
                    setModalState(() => _selectedStatusFilter = InventoryStatus.available);
                    setState(() => _selectedStatusFilter = InventoryStatus.available);
                    _filterItems();
                    Navigator.pop(ctx);
                  }),
                  _buildFilterChip('Rented', _selectedStatusFilter == InventoryStatus.rented, () {
                    setModalState(() => _selectedStatusFilter = InventoryStatus.rented);
                    setState(() => _selectedStatusFilter = InventoryStatus.rented);
                    _filterItems();
                    Navigator.pop(ctx);
                  }),
                  _buildFilterChip('In Transit', _selectedStatusFilter == InventoryStatus.inTransit, () {
                    setModalState(() => _selectedStatusFilter = InventoryStatus.inTransit);
                    setState(() => _selectedStatusFilter = InventoryStatus.inTransit);
                    _filterItems();
                    Navigator.pop(ctx);
                  }),
                ],
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFilterChip(String label, bool isSelected, VoidCallback onTap) {
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (_) => onTap(),
      selectedColor: const Color(0xFFEEF2FF),
      labelStyle: TextStyle(
        color: isSelected ? const Color(0xFF4F46E5) : const Color(0xFF64748B),
        fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
      ),
      backgroundColor: const Color(0xFFF1F5F9),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
            children: [
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  children: [
                    // Top App Header
                    _buildHeader(),
                    const SizedBox(height: 18),

                    // Search & Filter Row
                    _buildSearchAndFilterRow(),
                    const SizedBox(height: 18),

                    // Inventory Items List
                    if (_filteredItems.isEmpty)
                      const Center(
                        child: Padding(
                          padding: EdgeInsets.symmetric(vertical: 40),
                          child: Text(
                            'No items match your search',
                            style: TextStyle(color: Color(0xFF64748B), fontSize: 14),
                          ),
                        ),
                      )
                    else
                      ..._filteredItems.map(_buildInventoryCard),
                    const SizedBox(height: 16),
                  ],
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
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          'Inventory',
          style: TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.w800,
            color: Color(0xFF0F172A),
            letterSpacing: -0.3,
          ),
        ),
        // Notification Bell Icon with Red Dot
        Stack(
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
            Positioned(
              top: 8,
              right: 9,
              child: Container(
                height: 9,
                width: 9,
                decoration: BoxDecoration(
                  color: const Color(0xFFEF4444),
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 1.5),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSearchAndFilterRow() {
    return Row(
      children: [
        // Search Input
        Expanded(
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
              style: const TextStyle(color: Color(0xFF0F172A), fontSize: 14.5),
              decoration: InputDecoration(
                isDense: true,
                hintText: 'Search items...',
                hintStyle: const TextStyle(color: Color(0xFF94A3B8), fontSize: 14),
                prefixIcon: const Icon(
                  Icons.search_rounded,
                  color: Color(0xFF94A3B8),
                  size: 22,
                ),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, size: 18, color: Color(0xFF94A3B8)),
                        onPressed: () => _searchController.clear(),
                      )
                    : null,
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        // Filter Button
        Container(
          height: 50,
          width: 50,
          decoration: BoxDecoration(
            color: _selectedStatusFilter != null ? const Color(0xFFEEF2FF) : Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: _selectedStatusFilter != null
                ? Border.all(color: const Color(0xFF4F46E5), width: 1.2)
                : null,
            boxShadow: const [
              BoxShadow(
                color: Color(0x060F172A),
                blurRadius: 10,
                offset: Offset(0, 3),
              ),
            ],
          ),
          child: IconButton(
            icon: Icon(
              Icons.tune_rounded,
              color: _selectedStatusFilter != null
                  ? const Color(0xFF4F46E5)
                  : const Color(0xFF0F172A),
              size: 22,
            ),
            onPressed: _showFilterModal,
          ),
        ),
      ],
    );
  }

  Widget _buildInventoryCard(InventoryItem item) {
    Color badgeBg;
    Color badgeText;

    switch (item.status) {
      case InventoryStatus.rented:
        badgeBg = const Color(0xFFFEE2E2);
        badgeText = const Color(0xFFEF4444);
        break;
      case InventoryStatus.available:
        badgeBg = const Color(0xFFDCFCE7);
        badgeText = const Color(0xFF16A34A);
        break;
      case InventoryStatus.inTransit:
        badgeBg = const Color(0xFFFFEDD5);
        badgeText = const Color(0xFFEA580C);
        break;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
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
      child: Row(
        children: [
          // Thumbnail image container
          FurnitureThumbnail(type: item.type, size: 74),
          const SizedBox(width: 14),
          // Name, SKU, Status
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.name,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF0F172A),
                    letterSpacing: -0.2,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  item.sku,
                  style: const TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF94A3B8),
                  ),
                ),
                const SizedBox(height: 7),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3.5),
                  decoration: BoxDecoration(
                    color: badgeBg,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    item.statusLabel,
                    style: TextStyle(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w700,
                      color: badgeText,
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Options Menu
          PopupMenuButton<String>(
            icon: const Icon(
              Icons.more_vert_rounded,
              color: Color(0xFF94A3B8),
              size: 20,
            ),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            onSelected: (val) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  duration: const Duration(seconds: 1),
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  content: Text('$val: ${item.name}'),
                ),
              );
            },
            itemBuilder: (ctx) => [
              const PopupMenuItem(value: 'View Details', child: Text('View Details')),
              const PopupMenuItem(value: 'Edit Item', child: Text('Edit Item')),
              const PopupMenuItem(value: 'Change Status', child: Text('Change Status')),
            ],
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
              isSelected: i == 1, // Inventory is active
              onTap: () {
                if (i == 0) {
                  // Switch to Dashboard
                  Navigator.pushReplacement(
                    context,
                    PageRouteBuilder(
                      pageBuilder: (_, _, _) => const AdminDashboardScreen(),
                      transitionDuration: Duration.zero,
                    ),
                  );
                } else if (i != 1) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      duration: const Duration(milliseconds: 900),
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
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

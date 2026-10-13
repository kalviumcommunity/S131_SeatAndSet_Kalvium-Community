
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../models/inventory_item.dart';
import '../services/inventory_service.dart';
import '../widgets/furniture_thumbnail.dart';
import 'admin_dashboard_screen.dart';


class AdminInventoryScreen extends StatefulWidget {
  const AdminInventoryScreen({
    super.key,
    this.inventoryService,
  });

  final InventoryService? inventoryService;

  @override
  State<AdminInventoryScreen> createState() =>
      _AdminInventoryScreenState();
}


class _AdminInventoryScreenState extends State<AdminInventoryScreen> {
  final TextEditingController _searchController =
      TextEditingController();
  late final InventoryService _inventoryService;

  InventoryStatus? _selectedStatusFilter;

  
@override
void initState() {
  super.initState();

  _inventoryService =
      widget.inventoryService ?? InventoryService();

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

  List<InventoryItem> _filterItems(List<InventoryItem> items) {
    final query = _searchController.text.toLowerCase().trim();

    return items.where((item) {
      final matchesQuery = query.isEmpty ||
          item.name.toLowerCase().contains(query) ||
          item.sku.toLowerCase().contains(query);

      final matchesStatus = _selectedStatusFilter == null ||
          item.status == _selectedStatusFilter;

      return matchesQuery && matchesStatus;
    }).toList();
  }

  Future<void> _showAddFurnitureDialog() async {
    final formKey = GlobalKey<FormState>();
    final nameController = TextEditingController();
    final skuController = TextEditingController();

    FurnitureType selectedType = FurnitureType.sofa;
    InventoryStatus selectedStatus = InventoryStatus.available;

    final item = await showDialog<InventoryItem>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              backgroundColor: Colors.white,
              title: const Text(
                'Add Furniture',
                style: TextStyle(
                  color: Color(0xFF0F172A),
                  fontWeight: FontWeight.w800,
                ),
              ),
              content: SizedBox(
                width: 420,
                child: SingleChildScrollView(
                  child: Form(
                    key: formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        TextFormField(
                          controller: nameController,
                          style: const TextStyle(
                            color: Color(0xFF0F172A),
                          ),
                          textCapitalization: TextCapitalization.words,
                          decoration: _inputDecoration(
                            'Furniture name',
                            Icons.chair_outlined,
                          ),
                          validator: (value) {
                            if (value == null ||
                                value.trim().isEmpty) {
                              return 'Enter a furniture name';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: skuController,
                          style: const TextStyle(
                            color: Color(0xFF0F172A),
                          ),
                          textCapitalization:
                              TextCapitalization.characters,
                          inputFormatters: [
                            FilteringTextInputFormatter.allow(
                              RegExp(r'[a-zA-Z0-9_-]'),
                            ),
                          ],
                          decoration: _inputDecoration(
                            'SKU (e.g. SFA001)',
                            Icons.qr_code_rounded,
                          ),
                          validator: (value) {
                            if (value == null ||
                                value.trim().isEmpty) {
                              return 'Enter a unique SKU';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        DropdownButtonFormField<FurnitureType>(
                          initialValue: selectedType,
                          style: const TextStyle(
                            color: Color(0xFF1E293B),
                          ),
                          decoration:
                              _inputDecoration('Furniture type'),
                          items: FurnitureType.values.map((type) {
                            return DropdownMenuItem(
                              value: type,
                              child: Text(_typeLabel(type)),
                            );
                          }).toList(),
                          onChanged: (value) {
                            if (value != null) {
                              setDialogState(
                                () => selectedType = value,
                              );
                            }
                          },
                        ),
                        const SizedBox(height: 16),
                        DropdownButtonFormField<InventoryStatus>(
                          initialValue: selectedStatus,
                          style: const TextStyle(
                            color: Color(0xFF1E293B),
                          ),
                          decoration: _inputDecoration('Status'),
                          items: InventoryStatus.values.map((status) {
                            return DropdownMenuItem(
                              value: status,
                              child: Text(_statusLabel(status)),
                            );
                          }).toList(),
                          onChanged: (value) {
                            if (value != null) {
                              setDialogState(
                                () => selectedStatus = value,
                              );
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () =>
                      Navigator.pop(dialogContext),
                  child: const Text('Cancel'),
                ),
                FilledButton.icon(
                  style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xFF4F46E5),
                    foregroundColor: Colors.white,
                  ),
                  onPressed: () {
                    if (!formKey.currentState!.validate()) return;

                    final name = nameController.text.trim();
                    final sku = skuController.text.trim();

                    Navigator.pop(
                      dialogContext,
                      InventoryItem(
                        id: sku,
                        name: name,
                        sku: sku,
                        status: selectedStatus,
                        type: selectedType,
                      ),
                    );
                  },
                  icon: const Icon(Icons.save_outlined),
                  label: const Text('Save Furniture'),
                ),
              ],
            );
          },
        );
      },
    );

    // Allow the dialog's closing transition to finish before
    // disposing controllers still referenced by its form fields.
    await Future<void>.delayed(
      const Duration(milliseconds: 300),
    );
    nameController.dispose();
    skuController.dispose();

    if (item == null || !mounted) return;

    try {
      await _inventoryService.addFurniture(item);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${item.name} added successfully.'),
          backgroundColor: const Color(0xFF16A34A),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (error) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Could not add furniture: ${_friendlyError(error)}',
          ),
          backgroundColor: const Color(0xFFDC2626),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  InputDecoration _inputDecoration(
    String label, [
    IconData? icon,
  ]) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(
        color: Color(0xFF475569),
      ),
      prefixIcon:
          icon == null ? null : Icon(icon, size: 20),
      filled: true,
      fillColor: const Color(0xFFF8FAFC),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(
          color: Color(0xFF4F46E5),
          width: 1.5,
        ),
      ),
    );
  }

  String _friendlyError(Object error) {
    if (error is StateError) {
      return error.message.toString();
    }
    return error.toString();
  }

  String _typeLabel(FurnitureType type) {
    switch (type) {
      case FurnitureType.sofa:
        return 'Sofa';
      case FurnitureType.studyTable:
        return 'Study Table';
      case FurnitureType.officeChair:
        return 'Office Chair';
      case FurnitureType.bed:
        return 'Bed';
      case FurnitureType.diningTable:
        return 'Dining Table';
    }
  }

  String _statusLabel(InventoryStatus status) {
    switch (status) {
      case InventoryStatus.available:
        return 'Available';
      case InventoryStatus.rented:
        return 'Rented';
      case InventoryStatus.inTransit:
        return 'In Transit';
    }
  }

  void _showFilterModal() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(24),
        ),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 24,
        ),
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
                    setState(() => _selectedStatusFilter = null);
                    Navigator.pop(ctx);
                  },
                  child: const Text('Reset'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                _buildFilterChip(
                  'All',
                  _selectedStatusFilter == null,
                  () {
                    setState(() => _selectedStatusFilter = null);
                    Navigator.pop(ctx);
                  },
                ),
                ...InventoryStatus.values.map((status) {
                  return _buildFilterChip(
                    _statusLabel(status),
                    _selectedStatusFilter == status,
                    () {
                      setState(
                        () => _selectedStatusFilter = status,
                      );
                      Navigator.pop(ctx);
                    },
                  );
                }),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip(
    String label,
    bool isSelected,
    VoidCallback onTap,
  ) {
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (_) => onTap(),
      selectedColor: const Color(0xFFEEF2FF),
      labelStyle: TextStyle(
        color: isSelected
            ? const Color(0xFF4F46E5)
            : const Color(0xFF475569),
        fontWeight:
            isSelected ? FontWeight.w700 : FontWeight.w500,
      ),
      backgroundColor: const Color(0xFFF1F5F9),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
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
            children: [
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 16,
                  ),
                  children: [
                    _buildHeader(),
                    const SizedBox(height: 18),
                    _buildSearchAndFilterRow(),
                    const SizedBox(height: 18),
                    StreamBuilder<List<InventoryItem>>(
                      stream: _inventoryService.watchFurniture(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                                ConnectionState.waiting &&
                            !snapshot.hasData) {
                          return const Padding(
                            padding: EdgeInsets.symmetric(
                              vertical: 60,
                            ),
                            child: Center(
                              child: CircularProgressIndicator(
                                color: Color(0xFF4F46E5),
                              ),
                            ),
                          );
                        }

                        if (snapshot.hasError) {
                          return _buildMessage(
                            'Unable to load inventory. Check your '
                            'connection and Firestore permissions.',
                            icon: Icons.cloud_off_outlined,
                            action: TextButton(
                              onPressed: () => setState(() {}),
                              child: const Text('Retry'),
                            ),
                          );
                        }

                        final allItems =
                            snapshot.data ?? <InventoryItem>[];
                        final filteredItems =
                            _filterItems(allItems);

                        if (allItems.isEmpty) {
                          return _buildMessage(
                            'No furniture has been added yet. '
                            'Use the Add Furniture button to get started.',
                            icon: Icons.inventory_2_outlined,
                          );
                        }

                        if (filteredItems.isEmpty) {
                          return _buildMessage(
                            'No items match your search or filter.',
                            icon: Icons.search_off_rounded,
                          );
                        }

                        return Column(
                          children: filteredItems
                              .map(_buildInventoryCard)
                              .toList(),
                        );
                      },
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
              _buildBottomNavigationBar(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMessage(
    String message, {
    required IconData icon,
    Widget? action,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 40),
      child: Column(
        children: [
          Icon(
            icon,
            size: 38,
            color: const Color(0xFF64748B),
          ),
          const SizedBox(height: 12),
          Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Color(0xFF475569),
              fontSize: 14,
            ),
          ),
          ? action,
        ],
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
        Row(
          children: [
            Container(
              height: 44,
              width: 44,
              decoration: BoxDecoration(
                color: const Color(0xFFEFF2FE),
                shape: BoxShape.circle,
                border: Border.all(
                  color: const Color(0xFFE0E7FF),
                ),
              ),
              child: const Icon(
                Icons.notifications_none_rounded,
                color: Color(0xFF4F46E5),
                size: 22,
              ),
            ),
            const SizedBox(width: 10),
            FilledButton.icon(
              onPressed: _showAddFurnitureDialog,
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFF4F46E5),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 13,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              icon: const Icon(Icons.add, size: 20),
              label: const Text('Add'),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSearchAndFilterRow() {
    return Row(
      children: [
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
              style: const TextStyle(
                color: Color(0xFF0F172A),
                fontSize: 14.5,
              ),
              decoration: InputDecoration(
                isDense: true,
                hintText: 'Search items...',
                hintStyle: const TextStyle(
                  color: Color(0xFF64748B),
                  fontSize: 14,
                ),
                prefixIcon: const Icon(
                  Icons.search_rounded,
                  color: Color(0xFF64748B),
                  size: 22,
                ),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(
                          Icons.clear,
                          size: 18,
                          color: Color(0xFF64748B),
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
        const SizedBox(width: 12),
        Container(
          height: 50,
          width: 50,
          decoration: BoxDecoration(
            color: _selectedStatusFilter != null
                ? const Color(0xFFEEF2FF)
                : Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: _selectedStatusFilter != null
                ? Border.all(
                    color: const Color(0xFF4F46E5),
                    width: 1.2,
                  )
                : null,
          ),
          child: IconButton(
            icon: Icon(
              Icons.tune_rounded,
              color: _selectedStatusFilter != null
                  ? const Color(0xFF4F46E5)
                  : const Color(0xFF0F172A),
            ),
            onPressed: _showFilterModal,
          ),
        ),
      ],
    );
  }

  Widget _buildInventoryCard(InventoryItem item) {
    late Color badgeBg;
    late Color badgeText;

    switch (item.status) {
      case InventoryStatus.rented:
        badgeBg = const Color(0xFFFEE2E2);
        badgeText = const Color(0xFFEF4444);
      case InventoryStatus.available:
        badgeBg = const Color(0xFFDCFCE7);
        badgeText = const Color(0xFF16A34A);
      case InventoryStatus.inTransit:
        badgeBg = const Color(0xFFFFEDD5);
        badgeText = const Color(0xFFEA580C);
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
          FurnitureThumbnail(type: item.type, size: 74),
          const SizedBox(width: 14),
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
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  item.sku,
                  style: const TextStyle(
                    fontSize: 12.5,
                    color: Color(0xFF475569),
                  ),
                ),
                const SizedBox(height: 7),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 3.5,
                  ),
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
          PopupMenuButton<String>(
            icon: const Icon(
              Icons.more_vert_rounded,
              color: Color(0xFF64748B),
            ),
            onSelected: (value) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('$value: ${item.name}')),
              );
            },
            itemBuilder: (context) => const [
              PopupMenuItem(
                value: 'View Details',
                child: Text('View Details'),
              ),
              PopupMenuItem(
                value: 'Edit Item',
                child: Text('Edit Item'),
              ),
              PopupMenuItem(
                value: 'Change Status',
                child: Text('Change Status'),
              ),
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
        border: Border(
          top: BorderSide(color: Colors.grey.shade200, width: 0.8),
        ),
      ),
      padding: const EdgeInsets.only(top: 8, bottom: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          for (int i = 0; i < navItems.length; i++)
            _buildNavButton(
              item: navItems[i],
              isSelected: i == 1,
              onTap: () {
                if (i == 0) {
                  Navigator.pushReplacement(
                    context,
                    PageRouteBuilder(
                      pageBuilder: (_, _, _) =>
                          const AdminDashboardScreen(),
                      transitionDuration: Duration.zero,
                    ),
                  );
                } else if (i != 1) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        '${navItems[i].label} section coming soon!',
                      ),
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
            padding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 4,
            ),
            decoration: BoxDecoration(
              color: isSelected
                  ? const Color(0xFFEEF2FF)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              item.icon,
              size: 22,
              color: isSelected
                  ? const Color(0xFF4F46E5)
                  : const Color(0xFF64748B),
            ),
          ),
          const SizedBox(height: 2),
          Text(
            item.label,
            style: TextStyle(
              fontSize: 11,
              fontWeight:
                  isSelected ? FontWeight.w700 : FontWeight.w500,
              color: isSelected
                  ? const Color(0xFF4F46E5)
                  : const Color(0xFF64748B),
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

  const _NavItem({
    required this.icon,
    required this.label,
  });
}

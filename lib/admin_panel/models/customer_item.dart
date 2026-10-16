class CustomerItem {
  final String id;
  final String name;
  final String initials;
  final String phoneNumber;
  final int activeRentals;
  final String email;
  final String address;
  final String memberSince;
  final String totalSpent;

  const CustomerItem({
    required this.id,
    required this.name,
    required this.initials,
    required this.phoneNumber,
    required this.activeRentals,
    required this.email,
    required this.address,
    required this.memberSince,
    required this.totalSpent,
  });

  String get rentalsLabel {
    if (activeRentals == 0) return 'No active rentals';
    if (activeRentals == 1) return '1 active rental';
    return '$activeRentals active rentals';
  }

  bool matchesQuery(String cleanQuery) {
    if (cleanQuery.isEmpty) return true;
    return name.toLowerCase().contains(cleanQuery) ||
        phoneNumber.replaceAll(' ', '').contains(cleanQuery) ||
        initials.toLowerCase().contains(cleanQuery) ||
        email.toLowerCase().contains(cleanQuery);
  }

  /// Mock customers exactly matching Figma Admin 06 – Customers
  static List<CustomerItem> getMockCustomers() {
    return const [
      CustomerItem(
        id: 'CUST-001',
        name: 'Rahul Sharma',
        initials: 'RS',
        phoneNumber: '+91 98765 43210',
        activeRentals: 12,
        email: 'rahul.sharma@example.com',
        address: '402, Green Glen Layout, Bellandur, Bengaluru',
        memberSince: 'Jan 2024',
        totalSpent: '₹48,200',
      ),
      CustomerItem(
        id: 'CUST-002',
        name: 'Priya Mehta',
        initials: 'PM',
        phoneNumber: '+91 87654 32109',
        activeRentals: 3,
        email: 'priya.mehta@example.com',
        address: '88, 4th Cross, Koramangala 5th Block, Bengaluru',
        memberSince: 'Mar 2024',
        totalSpent: '₹18,500',
      ),
      CustomerItem(
        id: 'CUST-003',
        name: 'Arjun Singh',
        initials: 'AS',
        phoneNumber: '+91 76543 21098',
        activeRentals: 1,
        email: 'arjun.singh@example.com',
        address: 'Villa 14, Prestige Silver Oak, Whitefield, Bengaluru',
        memberSince: 'Jul 2024',
        totalSpent: '₹9,800',
      ),
      CustomerItem(
        id: 'CUST-004',
        name: 'Neha Kapoor',
        initials: 'NK',
        phoneNumber: '+91 65432 10987',
        activeRentals: 2,
        email: 'neha.kapoor@example.com',
        address: 'Flat 203, Orchid Enclave, HSR Layout, Bengaluru',
        memberSince: 'Feb 2025',
        totalSpent: '₹14,200',
      ),
      CustomerItem(
        id: 'CUST-005',
        name: 'Vikram Raina',
        initials: 'VR',
        phoneNumber: '+91 98760 12345',
        activeRentals: 0,
        email: 'vikram.raina@example.com',
        address: 'B-701, Sobha Dream Acres, Panathur, Bengaluru',
        memberSince: 'Aug 2025',
        totalSpent: '₹6,400',
      ),
      CustomerItem(
        id: 'CUST-006',
        name: 'Ananya Roy',
        initials: 'AR',
        phoneNumber: '+91 97420 67890',
        activeRentals: 4,
        email: 'ananya.roy@example.com',
        address: 'Tower 3, Flat 904, Godrej Woodsman, Hebbal, Bengaluru',
        memberSince: 'Nov 2024',
        totalSpent: '₹22,100',
      ),
      CustomerItem(
        id: 'CUST-007',
        name: 'Karan Patel',
        initials: 'KP',
        phoneNumber: '+91 98450 99887',
        activeRentals: 2,
        email: 'karan.patel@example.com',
        address: 'Flat 101, Brigade Gateway, Malleshwaram, Bengaluru',
        memberSince: 'Dec 2024',
        totalSpent: '₹15,800',
      ),
      CustomerItem(
        id: 'CUST-008',
        name: 'Shreya Iyer',
        initials: 'SI',
        phoneNumber: '+91 99166 77889',
        activeRentals: 0,
        email: 'shreya.iyer@example.com',
        address: 'Villa 7, Palm Meadows, Whitefield, Bengaluru',
        memberSince: 'May 2024',
        totalSpent: '₹8,900',
      ),
    ];
  }
}

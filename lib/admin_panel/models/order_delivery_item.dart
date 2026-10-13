enum OrderDeliveryType {
  deliver,
  pickup,
}

enum OrderTab {
  today,
  upcoming,
  completed,
}

class OrderDeliveryItem {
  final String id;
  final OrderDeliveryType type;
  final String furnitureName;
  final String customerName;
  final String time;
  final OrderTab tab;
  final String address;
  final String phoneNumber;
  final String status;
  final String? notes;

  const OrderDeliveryItem({
    required this.id,
    required this.type,
    required this.furnitureName,
    required this.customerName,
    required this.time,
    required this.tab,
    required this.address,
    required this.phoneNumber,
    required this.status,
    this.notes,
  });

  bool get isDeliver => type == OrderDeliveryType.deliver;
  String get typeLabel => isDeliver ? 'Deliver' : 'Pickup';
  String get partyPrefix => isDeliver ? 'To: ' : 'From: ';

  static List<OrderDeliveryItem> getMockOrders() {
    return const [
      // Today items (exact match to Figma Admin 05 Deliveries & Pickups)
      OrderDeliveryItem(
        id: 'DEL-101',
        type: OrderDeliveryType.deliver,
        furnitureName: 'Modern Sofa',
        customerName: 'Rahul Sharma',
        time: '10:00 AM',
        tab: OrderTab.today,
        address: '402, Green Glen Layout, Bellandur, Bengaluru',
        phoneNumber: '+91 98765 43210',
        status: 'Scheduled',
        notes: 'Call 15 minutes prior to arrival. Service lift available.',
      ),
      OrderDeliveryItem(
        id: 'PIC-102',
        type: OrderDeliveryType.pickup,
        furnitureName: 'Study Table',
        customerName: 'Priya Mehta',
        time: '12:30 PM',
        tab: OrderTab.today,
        address: '88, 4th Cross, Koramangala 5th Block, Bengaluru',
        phoneNumber: '+91 98451 23456',
        status: 'Scheduled',
        notes: 'Check for surface scratches upon pickup inspection.',
      ),
      OrderDeliveryItem(
        id: 'DEL-103',
        type: OrderDeliveryType.deliver,
        furnitureName: 'Dining Set',
        customerName: 'Arjun Singh',
        time: '03:00 PM',
        tab: OrderTab.today,
        address: 'Villa 14, Prestige Silver Oak, Whitefield, Bengaluru',
        phoneNumber: '+91 97312 89012',
        status: 'Scheduled',
        notes: 'Dining set includes 4 chairs and table.',
      ),
      OrderDeliveryItem(
        id: 'PIC-104',
        type: OrderDeliveryType.pickup,
        furnitureName: 'Office Chair',
        customerName: 'Neha Kapoor',
        time: '05:00 PM',
        tab: OrderTab.today,
        address: 'Flat 203, Orchid Enclave, HSR Layout Sector 2, Bengaluru',
        phoneNumber: '+91 99160 56789',
        status: 'Scheduled',
        notes: 'Rental period concluded. Security deposit clearance pending.',
      ),

      // Upcoming items
      OrderDeliveryItem(
        id: 'DEL-105',
        type: OrderDeliveryType.deliver,
        furnitureName: 'King Size Bed',
        customerName: 'Vikram Malhotra',
        time: 'Tomorrow, 11:00 AM',
        tab: OrderTab.upcoming,
        address: 'B-701, Sobha Dream Acres, Panathur, Bengaluru',
        phoneNumber: '+91 98860 12345',
        status: 'Confirmed',
        notes: 'Assembly required on site.',
      ),
      OrderDeliveryItem(
        id: 'PIC-106',
        type: OrderDeliveryType.pickup,
        furnitureName: 'Ergonomic Desk',
        customerName: 'Ananya Roy',
        time: 'Tomorrow, 02:30 PM',
        tab: OrderTab.upcoming,
        address: 'Tower 3, Flat 904, Godrej Woodsman, Hebbal, Bengaluru',
        phoneNumber: '+91 97420 67890',
        status: 'Confirmed',
        notes: 'Check hydraulic lift mechanism.',
      ),
      OrderDeliveryItem(
        id: 'DEL-107',
        type: OrderDeliveryType.deliver,
        furnitureName: 'Bookshelf Unit',
        customerName: 'Siddharth Joshi',
        time: 'Oct 15, 04:00 PM',
        tab: OrderTab.upcoming,
        address: '52, 12th Main Road, Indiranagar, Bengaluru',
        phoneNumber: '+91 99001 23456',
        status: 'Pending Dispatch',
        notes: 'Fragile glass shelves included.',
      ),

      // Completed items
      OrderDeliveryItem(
        id: 'DEL-108',
        type: OrderDeliveryType.deliver,
        furnitureName: 'Lounge Armchair',
        customerName: 'Karan Patel',
        time: 'Yesterday, 11:30 AM',
        tab: OrderTab.completed,
        address: 'Flat 101, Brigade Gateway, Malleshwaram, Bengaluru',
        phoneNumber: '+91 98450 99887',
        status: 'Delivered',
        notes: 'Delivered and acknowledged by customer signature.',
      ),
      OrderDeliveryItem(
        id: 'PIC-109',
        type: OrderDeliveryType.pickup,
        furnitureName: 'Coffee Table',
        customerName: 'Shreya Iyer',
        time: 'Yesterday, 03:15 PM',
        tab: OrderTab.completed,
        address: 'Villa 7, Palm Meadows, Whitefield, Bengaluru',
        phoneNumber: '+91 99166 77889',
        status: 'Picked Up',
        notes: 'Item returned in excellent condition. Deposit refunded.',
      ),
      OrderDeliveryItem(
        id: 'DEL-110',
        type: OrderDeliveryType.deliver,
        furnitureName: 'Wardrobe 3-Door',
        customerName: 'Rajesh Verma',
        time: 'Oct 11, 01:00 PM',
        tab: OrderTab.completed,
        address: '15, 7th Sector, HSR Layout, Bengaluru',
        phoneNumber: '+91 98801 33445',
        status: 'Delivered',
        notes: 'Installed in master bedroom.',
      ),
    ];
  }
}

import 'package:flutter/material.dart';

import '../data/bookings_controller.dart';
import '../models/booking.dart';
import '../models/furniture.dart';
import '../theme/app_colors.dart';
import '../theme/app_radius.dart';
import '../theme/app_spacing.dart';
import '../theme/app_text_styles.dart';
import 'orders_screen.dart';

/// Booking (`design_reference/08_booking.png`) — reached from Product
/// Details' "Add to Cart" button.
///
/// --- Layout (for viva) ---
/// Plain back arrow + centered "Book Now" title (same look as Furniture
/// List's header, not [ScreenHeader]'s circular button). Below that, a
/// scrollable column of cards (item summary, rental period, delivery
/// address, payment summary) with a "Confirm Booking" CTA pinned to the
/// bottom of the screen via a fixed footer rather than scrolling with the
/// content — matching the reference, where the button sits right above
/// the home indicator regardless of how short the card content is.
/// Spacing/sizes are fixed dp values measured directly off the reference
/// (it crops to the same ~393 x 852 design canvas as every other screen).
///
/// --- Pricing (for viva) ---
/// There's no payment gateway yet — "Rent" is `item price x quantity x
/// rental months` (months = ceil(days between start/end / 30), minimum
/// 1), "Delivery Charge" is a flat demo fee (matches the reference's
/// ₹99), and "Total" is their sum. Confirming saves a [Booking] into
/// [BookingsController] (in-memory, no backend) so it shows up on the My
/// Rentals screen.
class BookingScreen extends StatefulWidget {
  const BookingScreen({super.key, required this.item, required this.quantity});

  final Furniture item;
  final int quantity;

  @override
  State<BookingScreen> createState() => _BookingScreenState();
}

class _DemoAddress {
  const _DemoAddress(this.label, this.detail);
  final String label;
  final String detail;
}

class _BookingScreenState extends State<BookingScreen> {
  static const List<_DemoAddress> _addresses = [
    _DemoAddress('Home', 'Channi Himmat, Jammu'),
    _DemoAddress('Office', 'Industrial Area, Jammu'),
  ];

  static const List<String> _monthNames = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
  ];

  late DateTime _startDate;
  late DateTime _endDate;
  int _addressIndex = 0;

  @override
  void initState() {
    super.initState();
    final DateTime today = DateTime.now();
    _startDate = DateTime(today.year, today.month, today.day);
    _endDate = DateTime(_startDate.year, _startDate.month + 1, _startDate.day);
  }

  String _formatDate(DateTime date) =>
      '${date.day} ${_monthNames[date.month - 1]} ${date.year}';

  int get _rentalMonths {
    int months = (_endDate.year - _startDate.year) * 12 + (_endDate.month - _startDate.month);
    if (_endDate.day < _startDate.day) months -= 1;
    return months.clamp(1, 999);
  }

  int get _pricePerMonth {
    final match = RegExp(r'\d+').firstMatch(widget.item.price);
    return match == null ? 0 : int.parse(match.group(0)!);
  }

  int get _rent => _pricePerMonth * widget.quantity * _rentalMonths;

  static const int _deliveryCharge = 99;

  int get _total => _rent + _deliveryCharge;

  Future<void> _pickStartDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _startDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked == null) return;
    setState(() {
      _startDate = picked;
      if (!_endDate.isAfter(_startDate)) {
        _endDate = DateTime(_startDate.year, _startDate.month + 1, _startDate.day);
      }
    });
  }

  Future<void> _pickEndDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _endDate,
      firstDate: _startDate.add(const Duration(days: 1)),
      lastDate: DateTime.now().add(const Duration(days: 730)),
    );
    if (picked == null) return;
    setState(() => _endDate = picked);
  }

  Future<void> _changeAddress() async {
    final int? picked = await showModalBottomSheet<int>(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.card)),
      ),
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 12),
              Text('Delivery Address', style: AppTextStyles.subheading.copyWith(fontSize: 16)),
              const SizedBox(height: 8),
              for (var i = 0; i < _addresses.length; i++)
                ListTile(
                  leading: Icon(
                    i == _addressIndex ? Icons.radio_button_checked : Icons.radio_button_off,
                    color: i == _addressIndex ? AppColors.primaryDark : AppColors.textSecondary,
                  ),
                  title: Text(_addresses[i].label, style: AppTextStyles.body.copyWith(fontWeight: FontWeight.bold)),
                  subtitle: Text(_addresses[i].detail, style: AppTextStyles.caption),
                  onTap: () => Navigator.of(context).pop(i),
                ),
              const SizedBox(height: 12),
            ],
          ),
        );
      },
    );
    if (picked != null) setState(() => _addressIndex = picked);
  }

  void _confirmBooking() {
    final _DemoAddress address = _addresses[_addressIndex];
    BookingsController.instance.add(
      Booking(
        id: DateTime.now().microsecondsSinceEpoch.toString(),
        item: widget.item,
        quantity: widget.quantity,
        startDate: _startDate,
        endDate: _endDate,
        addressLabel: address.label,
        addressDetail: address.detail,
        rent: _rent,
        deliveryCharge: _deliveryCharge,
        total: _total,
        bookedAt: DateTime.now(),
      ),
    );
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Booking confirmed!')),
    );
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => const OrdersScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final _DemoAddress address = _addresses[_addressIndex];

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(AppSpacing.screenPadding, 12, AppSpacing.screenPadding, 0),
              child: Row(
                children: [
                  InkWell(
                    onTap: () => Navigator.of(context).maybePop(),
                    child: const Padding(
                      padding: EdgeInsets.all(4),
                      child: Icon(Icons.arrow_back, color: AppColors.textPrimary),
                    ),
                  ),
                  Expanded(
                    child: Text('Book Now', textAlign: TextAlign.center, style: AppTextStyles.subheading),
                  ),
                  const SizedBox(width: 32),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(AppSpacing.screenPadding, 18, AppSpacing.screenPadding, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _Card(
                      child: Row(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(AppRadius.input),
                            child: Image.asset(widget.item.imageAsset, width: 64, height: 64, fit: BoxFit.cover),
                          ),
                          const SizedBox(width: AppSpacing.md),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  widget.item.name,
                                  style: AppTextStyles.body.copyWith(fontWeight: FontWeight.bold, fontSize: 16),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '${widget.item.price.split('/').first} / month',
                                  style: const TextStyle(color: AppColors.primaryDark, fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    const Text('Rental Period', style: AppTextStyles.subheading),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: _DateCard(label: 'Start Date', date: _formatDate(_startDate), onTap: _pickStartDate),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _DateCard(label: 'End Date', date: _formatDate(_endDate), onTap: _pickEndDate),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    const Text('Delivery Address', style: AppTextStyles.subheading),
                    const SizedBox(height: 10),
                    _Card(
                      child: Row(
                        children: [
                          Container(
                            width: 40,
                            height: 40,
                            decoration: const BoxDecoration(color: AppColors.accentSage, shape: BoxShape.circle),
                            child: const Icon(Icons.location_on, color: AppColors.primaryDark, size: 20),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(address.label, style: AppTextStyles.body.copyWith(fontWeight: FontWeight.bold)),
                                Text(address.detail, style: AppTextStyles.caption),
                              ],
                            ),
                          ),
                          InkWell(
                            onTap: _changeAddress,
                            child: const Padding(
                              padding: EdgeInsets.all(4),
                              child: Text('Change', style: AppTextStyles.link),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    const Text('Payment Summary', style: AppTextStyles.subheading),
                    const SizedBox(height: 10),
                    _Card(
                      child: Column(
                        children: [
                          _PaymentRow(label: 'Rent ($_rentalMonths month${_rentalMonths > 1 ? 's' : ''})', value: '₹$_rent'),
                          const SizedBox(height: 14),
                          _PaymentRow(label: 'Delivery Charge', value: '₹$_deliveryCharge'),
                          const SizedBox(height: 14),
                          const Divider(height: 1, color: AppColors.divider),
                          const SizedBox(height: 14),
                          _PaymentRow(label: 'Total', value: '₹$_total', bold: true),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(AppSpacing.screenPadding, 0, AppSpacing.screenPadding, 12),
              child: Column(
                children: [
                  SizedBox(
                    width: double.infinity,
                    height: 54,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.input)),
                      ),
                      onPressed: _confirmBooking,
                      child: const Text('Confirm Booking'),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text("You won't be charged yet", style: AppTextStyles.caption),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Card extends StatelessWidget {
  const _Card({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.card),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 8, offset: const Offset(0, 3)),
        ],
      ),
      child: child,
    );
  }
}

class _DateCard extends StatelessWidget {
  const _DateCard({required this.label, required this.date, required this.onTap});

  final String label;
  final String date;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(AppRadius.card),
      onTap: onTap,
      child: _Card(
        child: Row(
          children: [
            const Icon(Icons.calendar_today_outlined, color: AppColors.primaryDark, size: 18),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label, style: AppTextStyles.caption),
                  const SizedBox(height: 2),
                  Text(date, style: AppTextStyles.body.copyWith(fontWeight: FontWeight.bold, fontSize: 14)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PaymentRow extends StatelessWidget {
  const _PaymentRow({required this.label, required this.value, this.bold = false});

  final String label;
  final String value;
  final bool bold;

  @override
  Widget build(BuildContext context) {
    final TextStyle style = bold
        ? AppTextStyles.body.copyWith(fontWeight: FontWeight.bold, fontSize: 16)
        : AppTextStyles.body.copyWith(color: bold ? null : AppColors.textSecondary);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: style),
        Text(value, style: style.copyWith(color: AppColors.textPrimary)),
      ],
    );
  }
}

import 'package:flutter/material.dart';
import '../../viewmodels/booking_viewmodel.dart';

class BookingSummaryCard extends StatelessWidget {
  final BookingViewModel vm;

  const BookingSummaryCard({super.key, required this.vm});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade100),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // ── Property row ────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: SizedBox(
                    width: 64,
                    height: 64,
                    child: vm.property.imageUrls.isNotEmpty
                        ? Image.network(vm.property.imageUrls.first,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => _imgFallback())
                        : _imgFallback(),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        vm.property.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 15,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Row(
                        children: [
                          Icon(Icons.location_on_rounded,
                              size: 12, color: Colors.grey[500]),
                          const SizedBox(width: 2),
                          Expanded(
                            child: Text(
                              vm.property.location,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                  color: Colors.grey[500], fontSize: 12),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 7, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.black87,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          vm.property.category,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          Divider(height: 1, color: Colors.grey.shade100),

          // ── Date & duration rows ────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _row('Move-in Date',
                    _fmtDate(vm.moveInDate), Icons.calendar_today_rounded),
                const SizedBox(height: 10),
                _row('Move-out Date',
                    _fmtDate(vm.moveOutDate), Icons.event_rounded),
                const SizedBox(height: 10),
                _row('Duration',
                    '${vm.durationMonths} ${vm.durationMonths == 1 ? "month" : "months"}',
                    Icons.timelapse_rounded),
                const SizedBox(height: 10),
                _row('Payment Method',
                    vm.selectedPayment.label, Icons.payment_rounded),
              ],
            ),
          ),

          Divider(height: 1, color: Colors.grey.shade100),

          // ── Price breakdown ─────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _priceRow(
                  '${vm.fmt(vm.monthlyPrice)} × ${vm.durationMonths} mo.',
                  vm.fmt(vm.rentalTotal),
                  isLight: true,
                ),
                const SizedBox(height: 8),
                _priceRow('Security Deposit', vm.fmt(vm.depositAmount),
                    isLight: true),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: Divider(color: Colors.grey.shade200),
                ),
                _priceRow('Total Amount', vm.fmt(vm.grandTotal),
                    isTotal: true),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _row(String label, String value, IconData icon) => Row(
        children: [
          Icon(icon, size: 16, color: Colors.grey[400]),
          const SizedBox(width: 8),
          Text(label,
              style: TextStyle(color: Colors.grey[600], fontSize: 13)),
          const Spacer(),
          Text(value,
              style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                  color: Colors.black87)),
        ],
      );

  Widget _priceRow(String label, String value,
      {bool isLight = false, bool isTotal = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label,
            style: TextStyle(
              fontSize: isTotal ? 15 : 13,
              fontWeight: isTotal ? FontWeight.w700 : FontWeight.w400,
              color: isTotal ? Colors.black87 : Colors.grey[600],
            )),
        Text(value,
            style: TextStyle(
              fontSize: isTotal ? 17 : 13,
              fontWeight: isTotal ? FontWeight.w800 : FontWeight.w500,
              color: isTotal ? Colors.black87 : Colors.black54,
            )),
      ],
    );
  }

  String _fmtDate(DateTime d) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${months[d.month - 1]} ${d.day}, ${d.year}';
  }

  Widget _imgFallback() => Container(
        color: Colors.grey[200],
        child: const Icon(Icons.home_rounded, color: Colors.grey, size: 28),
      );
}
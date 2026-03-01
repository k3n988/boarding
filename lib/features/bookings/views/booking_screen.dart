import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../properties/data/models/property_model.dart';
import '../data/models/payment_model.dart';
import '../viewmodels/booking_viewmodel.dart';
import 'widgets/booking_summary_card.dart';
import 'widgets/payment_method_selector.dart';

class BookingScreen extends StatelessWidget {
  // ✅ Changed to nullable '?' so it can be accessed from the Bottom Nav Bar
  final PropertyModel? property;
  
  const BookingScreen({super.key, this.property});

  @override
  Widget build(BuildContext context) {
    // ✅ If no property is passed, show the "My Bookings" list view instead
    if (property == null) {
      return const _MyBookingsList();
    }

    // Otherwise, show the Checkout Flow
    return ChangeNotifierProvider(
      create: (_) => BookingViewModel(property: property!),
      child: const _BookingView(),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// NEW: "My Bookings" Tab View (Shown when accessed from Bottom Nav)
// ─────────────────────────────────────────────────────────────────────────────
class _MyBookingsList extends StatelessWidget {
  const _MyBookingsList();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'My Bookings',
          style: TextStyle(
            color: Colors.black87,
            fontSize: 24,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.5,
          ),
        ),
        centerTitle: false,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: const BoxDecoration(
                color: Color(0xFFF5F5F7),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.calendar_today_rounded, size: 48, color: Colors.grey[400]),
            ),
            const SizedBox(height: 24),
            const Text(
              'No active bookings',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Your upcoming and past bookings\nwill appear here.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: Colors.grey[500]),
            ),
          ],
        ),
      ),
    );
  }
}


// ─────────────────────────────────────────────────────────────────────────────
// Checkout Flow (Shown when "Book Now" is tapped)
// ─────────────────────────────────────────────────────────────────────────────

class _BookingView extends StatelessWidget {
  const _BookingView();

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<BookingViewModel>();

    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FA),
      appBar: _buildAppBar(context, vm),
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 280),
        transitionBuilder: (child, anim) => SlideTransition(
          position: Tween(
            begin: const Offset(1, 0),
            end: Offset.zero,
          ).animate(CurvedAnimation(parent: anim, curve: Curves.easeOutCubic)),
          child: FadeTransition(opacity: anim, child: child),
        ),
        child: _stepBody(context, vm),
      ),
      bottomNavigationBar: _buildBottomBar(context, vm),
    );
  }

  // ── AppBar ────────────────────────────────────────────────────────────────

  AppBar _buildAppBar(BuildContext context, BookingViewModel vm) {
    final titles = {
      BookingStep.details: 'Booking Details',
      BookingStep.payment: 'Payment Method',
      BookingStep.confirm: 'Confirm Booking',
    };
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      scrolledUnderElevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.black87),
        onPressed: () {
          if (vm.step == BookingStep.details) {
            Navigator.pop(context);
          } else if (vm.step == BookingStep.payment) {
            vm.goToStep(BookingStep.details);
          } else {
            vm.goToStep(BookingStep.payment);
          }
        },
      ),
      title: Text(
        titles[vm.step]!,
        style: const TextStyle(
          color: Colors.black87,
          fontWeight: FontWeight.w800,
          fontSize: 18,
          letterSpacing: -0.3,
        ),
      ),
      centerTitle: true,
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(4),
        child: _StepProgressBar(step: vm.step),
      ),
    );
  }

  // ── Step body ─────────────────────────────────────────────────────────────

  Widget _stepBody(BuildContext context, BookingViewModel vm) {
    switch (vm.step) {
      case BookingStep.details:
        return const _DetailsStep(key: ValueKey('details'));
      case BookingStep.payment:
        return const _PaymentStep(key: ValueKey('payment'));
      case BookingStep.confirm:
        return const _ConfirmStep(key: ValueKey('confirm'));
    }
  }

  // ── Bottom bar ────────────────────────────────────────────────────────────

  Widget _buildBottomBar(BuildContext context, BookingViewModel vm) {
    String label;
    VoidCallback? onPressed;

    switch (vm.step) {
      case BookingStep.details:
        label = 'Continue to Payment';
        onPressed = () => vm.goToStep(BookingStep.payment);
        break;
      case BookingStep.payment:
        label = 'Review Booking';
        onPressed = () => vm.goToStep(BookingStep.confirm);
        break;
      case BookingStep.confirm:
        label = vm.isSubmitting ? 'Processing...' : 'Confirm & Book';
        onPressed = vm.isSubmitting
            ? null
            : () async {
                final ok = await vm.submitBooking(tenantId: 'current_user_id');
                if (!context.mounted) return;
                if (ok) {
                  _showSuccessSheet(context);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(vm.error ?? 'Booking failed')),
                  );
                }
              };
        break;
    }

    return Container(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 16,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Price preview
            if (vm.step != BookingStep.confirm)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Total',
                        style: TextStyle(
                            color: Colors.grey[500], fontSize: 13)),
                    Text(vm.fmt(vm.grandTotal),
                        style: const TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 18,
                          color: Colors.black87,
                        )),
                  ],
                ),
              ),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: onPressed,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black87,
                  disabledBackgroundColor: Colors.grey[300],
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                  elevation: 0,
                ),
                child: vm.isSubmitting
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : Text(
                        label,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          fontSize: 16,
                        ),
                      ),
              ),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  void _showSuccessSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isDismissible: false,
      enableDrag: false,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => Padding(
        padding: const EdgeInsets.fromLTRB(24, 32, 24, 48),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: Colors.green[50],
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.check_circle_rounded,
                  color: Colors.green[600], size: 40),
            ),
            const SizedBox(height: 20),
            const Text('Booking Submitted!',
                style: TextStyle(
                    fontSize: 22, fontWeight: FontWeight.w800)),
            const SizedBox(height: 8),
            Text(
              'Your booking request has been sent to the host.\nYou will be notified once confirmed.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey[500], fontSize: 14, height: 1.5),
            ),
            const SizedBox(height: 28),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.of(context)
                    ..pop() // close sheet
                    ..pop(); // close booking screen and go back
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black87,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  elevation: 0,
                ),
                child: const Text('Back to Home',
                    style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 15)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// STEP 1 — Details
// ─────────────────────────────────────────────────────────────────────────────

class _DetailsStep extends StatefulWidget {
  const _DetailsStep({super.key});
  @override
  State<_DetailsStep> createState() => _DetailsStepState();
}

class _DetailsStepState extends State<_DetailsStep> {
  final _notesController = TextEditingController();

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<BookingViewModel>();

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Property mini card ────────────────────────────────────────
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: Colors.grey.shade100),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                )
              ],
            ),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: SizedBox(
                    width: 56,
                    height: 56,
                    child: vm.property.imageUrls.isNotEmpty
                        ? Image.network(vm.property.imageUrls.first,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) =>
                                Container(color: Colors.grey[200]))
                        : Container(color: Colors.grey[200]),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(vm.property.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                              fontWeight: FontWeight.w700, fontSize: 14)),
                      const SizedBox(height: 2),
                      Text(vm.property.location,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                              color: Colors.grey[500], fontSize: 12)),
                    ],
                  ),
                ),
                Text(vm.fmt(vm.monthlyPrice),
                    style: const TextStyle(
                        fontWeight: FontWeight.w800, fontSize: 15)),
              ],
            ),
          ),

          const SizedBox(height: 28),

          // ── Move-in date ──────────────────────────────────────────────
          const _SectionLabel(label: 'Move-in Date'),
          const SizedBox(height: 10),
          GestureDetector(
            onTap: () async {
              final picked = await showDatePicker(
                context: context,
                initialDate: vm.moveInDate,
                firstDate: DateTime.now(),
                lastDate:
                    DateTime.now().add(const Duration(days: 365)),
                builder: (ctx, child) => Theme(
                  data: Theme.of(ctx).copyWith(
                    colorScheme: const ColorScheme.light(
                        primary: Colors.black87),
                  ),
                  child: child!,
                ),
              );
              if (picked != null) {
                if (context.mounted) {
                  context.read<BookingViewModel>().setMoveInDate(picked);
                }
              }
            },
            child: Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Row(
                children: [
                  const Icon(Icons.calendar_today_rounded,
                      size: 18, color: Colors.black54),
                  const SizedBox(width: 12),
                  Text(_fmtDate(vm.moveInDate),
                      style: const TextStyle(
                          fontWeight: FontWeight.w600, fontSize: 15)),
                  const Spacer(),
                  Icon(Icons.chevron_right_rounded,
                      color: Colors.grey[400]),
                ],
              ),
            ),
          ),

          const SizedBox(height: 24),

          // ── Duration ─────────────────────────────────────────────────
          const _SectionLabel(label: 'Rental Duration'),
          const SizedBox(height: 10),
          Row(
            children: BookingViewModel.durationOptions.map((months) {
              final isSelected = vm.durationMonths == months;
              return Expanded(
                child: GestureDetector(
                  onTap: () =>
                      context.read<BookingViewModel>().setDuration(months),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    margin: const EdgeInsets.only(right: 8),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    decoration: BoxDecoration(
                      color: isSelected ? Colors.black87 : Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isSelected
                            ? Colors.black87
                            : Colors.grey.shade200,
                      ),
                    ),
                    child: Column(
                      children: [
                        Text(
                          '$months',
                          style: TextStyle(
                            fontWeight: FontWeight.w800,
                            fontSize: 18,
                            color: isSelected
                                ? Colors.white
                                : Colors.black87,
                          ),
                        ),
                        Text(
                          months == 1 ? 'mo' : 'mos',
                          style: TextStyle(
                            fontSize: 11,
                            color: isSelected
                                ? Colors.white70
                                : Colors.grey[400],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
          ),

          const SizedBox(height: 24),

          // ── Calculated move-out ───────────────────────────────────────
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Row(
              children: [
                Icon(Icons.event_available_rounded,
                    color: Colors.green[600], size: 20),
                const SizedBox(width: 10),
                Text('Estimated move-out:',
                    style: TextStyle(
                        color: Colors.grey[600], fontSize: 13)),
                const Spacer(),
                Text(_fmtDate(vm.moveOutDate),
                    style: const TextStyle(
                        fontWeight: FontWeight.w700, fontSize: 13)),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // ── Notes ─────────────────────────────────────────────────────
          const _SectionLabel(label: 'Notes to Host (optional)'),
          const SizedBox(height: 10),
          TextField(
            controller: _notesController,
            onChanged: (v) =>
                context.read<BookingViewModel>().setNotes(v),
            maxLines: 3,
            decoration: InputDecoration(
              hintText: 'e.g. I will arrive around 2pm...',
              hintStyle:
                  TextStyle(color: Colors.grey[400], fontSize: 14),
              filled: true,
              fillColor: Colors.white,
              contentPadding: const EdgeInsets.all(14),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide:
                    BorderSide(color: Colors.grey.shade200),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide:
                    BorderSide(color: Colors.grey.shade200),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Colors.black54),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _fmtDate(DateTime d) {
    const m = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${m[d.month - 1]} ${d.day}, ${d.year}';
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// STEP 2 — Payment
// ─────────────────────────────────────────────────────────────────────────────

class _PaymentStep extends StatelessWidget {
  const _PaymentStep({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<BookingViewModel>();

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _SectionLabel(label: 'Select Payment Method'),
          const SizedBox(height: 14),
          PaymentMethodSelector(
            selected: vm.selectedPayment,
            onChanged: (pm) =>
                context.read<BookingViewModel>().setPayment(pm),
          ),
          const SizedBox(height: 16),
          // Note
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.amber[50],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.amber.shade200),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.info_outline_rounded,
                    color: Colors.amber[700], size: 18),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Payment details and instructions will be sent '
                    'to you after the host confirms your booking.',
                    style: TextStyle(
                        color: Colors.amber[900],
                        fontSize: 12,
                        height: 1.5),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// STEP 3 — Confirm
// ─────────────────────────────────────────────────────────────────────────────

class _ConfirmStep extends StatelessWidget {
  const _ConfirmStep({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<BookingViewModel>();

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _SectionLabel(label: 'Booking Summary'),
          const SizedBox(height: 14),
          BookingSummaryCard(vm: vm),
          const SizedBox(height: 20),
          // Terms notice
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Text(
              'By confirming, you agree to the property\'s policies '
              'and house rules. A deposit of ${vm.fmt(vm.depositAmount)} '
              'is required upon move-in.',
              style: TextStyle(
                  color: Colors.grey[600], fontSize: 12, height: 1.6),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Shared helpers
// ─────────────────────────────────────────────────────────────────────────────

class _SectionLabel extends StatelessWidget {
  final String label;
  const _SectionLabel({required this.label});

  @override
  Widget build(BuildContext context) => Text(
        label,
        style: const TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w700,
          color: Colors.black87,
        ),
      );
}

class _StepProgressBar extends StatelessWidget {
  final BookingStep step;
  const _StepProgressBar({required this.step});

  double get _progress {
    switch (step) {
      case BookingStep.details: return 1 / 3;
      case BookingStep.payment: return 2 / 3;
      case BookingStep.confirm: return 1.0;
    }
  }

  @override
  Widget build(BuildContext context) => LinearProgressIndicator(
        value: _progress,
        minHeight: 3,
        backgroundColor: Colors.grey[200],
        valueColor:
            const AlwaysStoppedAnimation<Color>(Colors.black87),
      );
}
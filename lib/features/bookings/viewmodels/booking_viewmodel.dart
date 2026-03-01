import 'package:flutter/material.dart';

import '../data/models/booking_model.dart';
import '../data/models/payment_model.dart';
import '../../properties/data/models/property_model.dart';

enum BookingStep { details, payment, confirm }

class BookingViewModel extends ChangeNotifier {
  final PropertyModel property;

  BookingViewModel({required this.property}) {
    // Default move-in: tomorrow
    _moveInDate = DateTime.now().add(const Duration(days: 1));
  }

  // ── Step ──────────────────────────────────────────────────────────────────
  BookingStep _step = BookingStep.details;
  BookingStep get step => _step;

  void goToStep(BookingStep s) {
    _step = s;
    notifyListeners();
  }

  bool get isOnDetails => _step == BookingStep.details;
  bool get isOnPayment => _step == BookingStep.payment;
  bool get isOnConfirm => _step == BookingStep.confirm;

  // ── Move-in date ──────────────────────────────────────────────────────────
  late DateTime _moveInDate;
  DateTime get moveInDate => _moveInDate;

  void setMoveInDate(DateTime date) {
    _moveInDate = date;
    notifyListeners();
  }

  DateTime get moveOutDate =>
      DateTime(_moveInDate.year, _moveInDate.month + _durationMonths, _moveInDate.day);

  // ── Duration ──────────────────────────────────────────────────────────────
  int _durationMonths = 1;
  int get durationMonths => _durationMonths;

  static const List<int> durationOptions = [1, 3, 6, 12];

  void setDuration(int months) {
    _durationMonths = months;
    notifyListeners();
  }

  // ── Payment ───────────────────────────────────────────────────────────────
  PaymentMethod _selectedPayment = PaymentMethod.all.first;
  PaymentMethod get selectedPayment => _selectedPayment;

  void setPayment(PaymentMethod pm) {
    _selectedPayment = pm;
    notifyListeners();
  }

  // ── Notes ─────────────────────────────────────────────────────────────────
  String _notes = '';
  String get notes => _notes;
  void setNotes(String v) { _notes = v; notifyListeners(); }

  // ── Price calculations ────────────────────────────────────────────────────
  double get monthlyPrice  => property.price;
  double get depositAmount => property.price;          // 1-month deposit
  double get rentalTotal   => monthlyPrice * _durationMonths;
  double get grandTotal    => rentalTotal + depositAmount;

  String fmt(double v) {
    final int i = v.truncate();
    final String t = i.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (m) => '${m[1]},',
    );
    return '₱$t';
  }

  // ── Build model for submission ────────────────────────────────────────────
  BookingModel buildBooking({required String tenantId}) => BookingModel(
        propertyId:       property.id ?? '',
        propertyTitle:    property.title,
        propertyImageUrl: property.imageUrls.isNotEmpty
                              ? property.imageUrls.first
                              : property.imageUrl,
        propertyLocation: property.location,
        hostId:           property.hostId,
        tenantId:         tenantId,
        moveInDate:       _moveInDate,
        durationMonths:   _durationMonths,
        monthlyPrice:     monthlyPrice,
        dailyPrice:       property.dailyPrice,
        paymentMethod:    _selectedPayment.label,
        totalAmount:      grandTotal,
        depositAmount:    depositAmount,
        notes:            _notes.trim().isEmpty ? null : _notes.trim(),
      );

  // ── Submission state ──────────────────────────────────────────────────────
  bool _isSubmitting = false;
  bool get isSubmitting => _isSubmitting;
  String? _error;
  String? get error => _error;

  /// In production, replace with a real Firestore write.
  Future<bool> submitBooking({required String tenantId}) async {
    _isSubmitting = true;
    _error = null;
    notifyListeners();

    await Future.delayed(const Duration(seconds: 2)); // simulate network

    // TODO: FirebaseFirestore.instance.collection('bookings').add(booking.toMap())
    _isSubmitting = false;
    notifyListeners();
    return true; // return false + set _error on failure
  }
}
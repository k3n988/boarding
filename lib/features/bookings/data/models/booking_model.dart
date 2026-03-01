import 'package:cloud_firestore/cloud_firestore.dart';

enum BookingStatus { pending, confirmed, cancelled, completed }

class BookingModel {
  final String? id;
  final String propertyId;
  final String propertyTitle;
  final String propertyImageUrl;
  final String propertyLocation;
  final String hostId;
  final String tenantId;

  final DateTime moveInDate;
  final int durationMonths;       // 1, 3, 6, 12
  final double monthlyPrice;
  final double? dailyPrice;

  final String paymentMethod;     // "GCash" | "Maya" | "Cash" | "Bank Transfer"
  final double totalAmount;
  final double depositAmount;     // typically 1 month

  final BookingStatus status;
  final String? notes;
  final DateTime? createdAt;

  const BookingModel({
    this.id,
    required this.propertyId,
    required this.propertyTitle,
    required this.propertyImageUrl,
    required this.propertyLocation,
    required this.hostId,
    required this.tenantId,
    required this.moveInDate,
    required this.durationMonths,
    required this.monthlyPrice,
    this.dailyPrice,
    required this.paymentMethod,
    required this.totalAmount,
    required this.depositAmount,
    this.status = BookingStatus.pending,
    this.notes,
    this.createdAt,
  });

  Map<String, dynamic> toMap() => {
        'propertyId':       propertyId,
        'propertyTitle':    propertyTitle,
        'propertyImageUrl': propertyImageUrl,
        'propertyLocation': propertyLocation,
        'hostId':           hostId,
        'tenantId':         tenantId,
        'moveInDate':       Timestamp.fromDate(moveInDate),
        'durationMonths':   durationMonths,
        'monthlyPrice':     monthlyPrice,
        'dailyPrice':       dailyPrice,
        'paymentMethod':    paymentMethod,
        'totalAmount':      totalAmount,
        'depositAmount':    depositAmount,
        'status':           status.name,
        'notes':            notes,
        'createdAt':        FieldValue.serverTimestamp(),
      };

  factory BookingModel.fromMap(Map<String, dynamic> map, String docId) =>
      BookingModel(
        id:               docId,
        propertyId:       map['propertyId']       ?? '',
        propertyTitle:    map['propertyTitle']     ?? '',
        propertyImageUrl: map['propertyImageUrl']  ?? '',
        propertyLocation: map['propertyLocation']  ?? '',
        hostId:           map['hostId']            ?? '',
        tenantId:         map['tenantId']          ?? '',
        moveInDate:       (map['moveInDate'] as Timestamp).toDate(),
        durationMonths:   map['durationMonths']    ?? 1,
        monthlyPrice:     (map['monthlyPrice']     ?? 0).toDouble(),
        dailyPrice:       map['dailyPrice'] != null
                              ? (map['dailyPrice'] as num).toDouble()
                              : null,
        paymentMethod:    map['paymentMethod']     ?? 'Cash',
        totalAmount:      (map['totalAmount']      ?? 0).toDouble(),
        depositAmount:    (map['depositAmount']    ?? 0).toDouble(),
        status:           BookingStatus.values.firstWhere(
                            (e) => e.name == map['status'],
                            orElse: () => BookingStatus.pending),
        notes:            map['notes'],
        createdAt:        (map['createdAt'] as Timestamp?)?.toDate(),
      );

  BookingModel copyWith({BookingStatus? status}) => BookingModel(
        id:               id,
        propertyId:       propertyId,
        propertyTitle:    propertyTitle,
        propertyImageUrl: propertyImageUrl,
        propertyLocation: propertyLocation,
        hostId:           hostId,
        tenantId:         tenantId,
        moveInDate:       moveInDate,
        durationMonths:   durationMonths,
        monthlyPrice:     monthlyPrice,
        dailyPrice:       dailyPrice,
        paymentMethod:    paymentMethod,
        totalAmount:      totalAmount,
        depositAmount:    depositAmount,
        status:           status ?? this.status,
        notes:            notes,
        createdAt:        createdAt,
      );
}
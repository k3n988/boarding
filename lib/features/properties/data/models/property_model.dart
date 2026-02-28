import 'package:cloud_firestore/cloud_firestore.dart';

class PropertyModel {
  final String? id; // Document ID (null when creating a new one)
  final String title;
  final String location;
  final double price; // Monthly price
  final double? dailyPrice; // NEW: Daily price added here
  final String imageUrl; // Main cover image
  final List<String> imageUrls;
  final String category;
  final int availableSlots;
  final String tenantPreference;
  final List<String> amenities;
  final bool isLocationPinned;
  final double? latitude;
  final double? longitude;
  final String description;
  final String policies;
  final String hostId;
  final String status;
  final DateTime? createdAt;

  PropertyModel({
    this.id,
    required this.title,
    required this.location,
    required this.price,
    this.dailyPrice, // NEW: Added to constructor
    required this.imageUrl,
    required this.imageUrls,
    required this.category,
    required this.availableSlots,
    required this.tenantPreference,
    required this.amenities,
    this.isLocationPinned = false,
    this.latitude,
    this.longitude,
    required this.description,
    required this.policies,
    required this.hostId,
    this.status = 'Active',
    this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'location': location,
      'price': price,
      'dailyPrice': dailyPrice, // NEW: Added to map for Firestore
      'imageUrl': imageUrl,
      'imageUrls': imageUrls,
      'category': category,
      'availableSlots': availableSlots,
      'tenantPreference': tenantPreference,
      'amenities': amenities,
      'isLocationPinned': isLocationPinned,
      'latitude': latitude,
      'longitude': longitude,
      'description': description,
      'policies': policies,
      'hostId': hostId,
      'status': status,
      'createdAt': FieldValue.serverTimestamp(),
    };
  }

  factory PropertyModel.fromMap(Map<String, dynamic> map, String documentId) {
    return PropertyModel(
      id: documentId,
      title: map['title'] ?? '',
      location: map['location'] ?? '',
      price: (map['price'] ?? 0).toDouble(),
      // NEW: Retrieve dailyPrice from Firestore (safely handles nulls or ints)
      dailyPrice: map['dailyPrice'] != null ? (map['dailyPrice'] as num).toDouble() : null,
      imageUrl: map['imageUrl'] ?? '',
      imageUrls: List<String>.from(map['imageUrls'] ?? []),
      category: map['category'] ?? 'Boarding House',
      availableSlots: map['availableSlots']?.toInt() ?? 0,
      tenantPreference: map['tenantPreference'] ?? 'All / Mixed',
      amenities: List<String>.from(map['amenities'] ?? []),
      isLocationPinned: map['isLocationPinned'] ?? false,
      latitude: map['latitude']?.toDouble(),
      longitude: map['longitude']?.toDouble(),
      description: map['description'] ?? '',
      policies: map['policies'] ?? '',
      hostId: map['hostId'] ?? '',
      status: map['status'] ?? 'Active',
      createdAt: (map['createdAt'] as Timestamp?)?.toDate(),
    );
  }
}
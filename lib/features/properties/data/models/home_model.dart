import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class PropertyModel {
  final String? id;
  final String title;
  final String location;
  final double price;
  final String imageUrl;
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

  // UI Helper: Provide a fallback color if the image fails to load
  final Color bgColor;

  PropertyModel({
    this.id,
    required this.title,
    required this.location,
    required this.price,
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
    this.bgColor = const Color(0xFFF5F5F7), // Default background color
  });

  // --- FROM FIRESTORE ---
  factory PropertyModel.fromMap(Map<String, dynamic> map, String documentId) {
    return PropertyModel(
      id: documentId,
      title: map['title'] ?? 'No Title',
      location: map['location'] ?? 'No Location',
      // Convert String or Int from Firestore to Double safely
      price: double.tryParse(map['price'].toString()) ?? 0.0,
      imageUrl: map['imageUrl'] ?? '',
      imageUrls: List<String>.from(map['imageUrls'] ?? []),
      category: map['category'] ?? 'Boarding House',
      availableSlots: map['availableSlots'] ?? 0,
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

  // --- TO FIRESTORE ---
  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'location': location,
      'price': price,
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
      'createdAt': createdAt ?? FieldValue.serverTimestamp(),
    };
  }
}
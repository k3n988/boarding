import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../data/models/property_model.dart';

class PropertyDetailViewModel extends ChangeNotifier {
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  Future<void> publishListing({
    required String title,
    required String fullAddress,
    required double price,
    double? dailyPrice, // ── NEW: Added dailyPrice parameter
    required int availableSlots,
    required String category,
    required String tenantPreference,
    required List<String> amenities,
    required bool isLocationPinned,
    required double? latitude,
    required double? longitude,
    required String description,
    required String policies,
    required List<File> selectedImages,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) throw Exception('You must be signed in to post.');

      // 1. Upload Images to Firebase Storage
      final List<String> uploadedImageUrls = [];
      for (final image in selectedImages) {
        final fileName = '${DateTime.now().millisecondsSinceEpoch}_${image.path.split('/').last}';
        final ref = FirebaseStorage.instance.ref().child('property_images/${user.uid}/$fileName');
        
        await ref.putFile(image);
        final downloadUrl = await ref.getDownloadURL();
        uploadedImageUrls.add(downloadUrl);
      }

      // 2. Create the Property Model
      final property = PropertyModel(
        title: title,
        location: fullAddress,
        price: price,
        dailyPrice: dailyPrice, // ── NEW: Pass dailyPrice to the model
        imageUrl: uploadedImageUrls.first, // First image acts as cover
        imageUrls: uploadedImageUrls,
        category: category,
        availableSlots: availableSlots,
        tenantPreference: tenantPreference,
        amenities: amenities,
        isLocationPinned: isLocationPinned,
        latitude: latitude,
        longitude: longitude,
        description: description,
        policies: policies,
        hostId: user.uid,
        status: 'Active', // Auto-approved for now
      );

      // 3. Save to Firestore
      await FirebaseFirestore.instance.collection('listings').add(property.toMap());

    } catch (e) {
      rethrow; // Pass error back to UI
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
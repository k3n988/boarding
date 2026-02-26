import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../data/models/property_model.dart';

class HomeViewModel extends ChangeNotifier {
  List<PropertyModel> _properties = [];
  List<PropertyModel> get properties => _properties;

  bool _isLoading = true;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  HomeViewModel() {
    fetchProperties();
  }

  // --- Fetch All Listings from Firestore ---
  Future<void> fetchProperties() async {
    _isLoading = true;
    _errorMessage = null;
    
    // Safety check to ensure we don't notify during build
    WidgetsBinding.instance.addPostFrameCallback((_) => notifyListeners());

    try {
      // ORDER: Newest posts first
      final snapshot = await FirebaseFirestore.instance
          .collection('listings')
          .orderBy('createdAt', descending: true)
          .get();

      _properties = snapshot.docs.map((doc) {
        return PropertyModel.fromMap(doc.data(), doc.id);
      }).toList();

    } catch (e) {
      _errorMessage = 'Failed to load rooms: $e';
      debugPrint(_errorMessage);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Support for Pull-to-Refresh
  Future<void> refresh() async {
    await fetchProperties();
  }
}
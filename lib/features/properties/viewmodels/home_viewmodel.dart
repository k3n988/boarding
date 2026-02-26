import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../data/models/property_model.dart';

class HomeViewModel extends ChangeNotifier {
  List<PropertyModel> _allProperties = [];
  StreamSubscription<QuerySnapshot>? _subscription;

  bool isLoading = true;
  String? errorMessage;

  String _selectedCategory = 'All';
  String _searchQuery = '';
  RangeValues _priceRange = const RangeValues(0, 20000);
  String _sortBy = 'Newest';

  String get selectedCategory => _selectedCategory;
  String get searchQuery => _searchQuery;
  RangeValues get priceRange => _priceRange;
  String get sortBy => _sortBy;

  List<PropertyModel> get filteredProperties {
    List<PropertyModel> result = List.from(_allProperties);

    if (_selectedCategory != 'All') {
      result = result
          .where((p) => p.category.toLowerCase() == _selectedCategory.toLowerCase())
          .toList();
    }

    if (_searchQuery.isNotEmpty) {
      final query = _searchQuery.toLowerCase();
      result = result
          .where((p) =>
              p.title.toLowerCase().contains(query) ||
              p.location.toLowerCase().contains(query) ||
              p.description.toLowerCase().contains(query))
          .toList();
    }

    result = result
        .where((p) => p.price >= _priceRange.start && p.price <= _priceRange.end)
        .toList();

    result.sort((a, b) {
      final aDate = a.createdAt ?? DateTime(2000);
      final bDate = b.createdAt ?? DateTime(2000);
      return bDate.compareTo(aDate);
    });

    return result;
  }

  int get totalCount => filteredProperties.length;
  bool get hasActiveFilters =>
      _selectedCategory != 'All' ||
      _searchQuery.isNotEmpty ||
      _priceRange.start > 0 ||
      _priceRange.end < 20000;

  HomeViewModel() {
    _listenToProperties();
  }

  void _listenToProperties() {
    isLoading = true;
    notifyListeners();

    _subscription = FirebaseFirestore.instance
        .collection('listings') // ← correct collection name
        .snapshots()
        .listen(
      (snapshot) {
        _allProperties = snapshot.docs
            .map((doc) => PropertyModel.fromMap(doc.data(), doc.id))
            .toList();
        isLoading = false;
        errorMessage = null;
        notifyListeners();
      },
      onError: (e) {
        errorMessage = e.toString();
        isLoading = false;
        notifyListeners();
      },
    );
  }

  void setCategory(String category) {
    _selectedCategory = (_selectedCategory == category) ? 'All' : category;
    notifyListeners();
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void setPriceRange(RangeValues range) {
    _priceRange = range;
    notifyListeners();
  }

  void setSortBy(String sort) {
    _sortBy = sort;
    notifyListeners();
  }

  void clearAllFilters() {
    _selectedCategory = 'All';
    _searchQuery = '';
    _priceRange = const RangeValues(0, 20000);
    _sortBy = 'Newest';
    notifyListeners();
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}
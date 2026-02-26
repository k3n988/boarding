import 'dart:async';
import 'package:flutter/material.dart';
import '../data/models/map_marker_model.dart';
import '../data/repositories/map_repository.dart';

class MapViewModel extends ChangeNotifier {
  final MapRepository _repository;

  MapViewModel({MapRepository? repository})
      : _repository = repository ?? MapRepository() {
    _init();
  }

  // ── State ──────────────────────────────────────────────────────────────────
  List<MapMarkerModel> _allMarkers = [];
  List<MapMarkerModel> _filteredMarkers = [];
  List<MapMarkerModel> get filteredMarkers => _filteredMarkers;

  String _selectedCategory = 'All';
  String get selectedCategory => _selectedCategory;

  bool _isLoading = true;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  MapMarkerModel? _selectedMarker;
  MapMarkerModel? get selectedMarker => _selectedMarker;

  StreamSubscription<List<MapMarkerModel>>? _streamSub;

  static const List<String> categories = [
    'All',
    'Boarding House',
    'Dormitory',
    'Apartment',
    'Bedspace',
  ];

  // ── Init: subscribe to real-time stream ───────────────────────────────────
  void _init() {
    _isLoading = true;
    _streamSub = _repository.streamPinnedListings().listen(
      (markers) {
        _allMarkers = markers;
        _applyFilter();
        _isLoading = false;
        _errorMessage = null;
        notifyListeners();
      },
      onError: (e) {
        _isLoading = false;
        _errorMessage = 'Failed to load listings: $e';
        notifyListeners();
      },
    );
  }

  // ── Filter by category ────────────────────────────────────────────────────
  void filterByCategory(String category) {
    _selectedCategory = category;
    _applyFilter();
    notifyListeners();
  }

  void _applyFilter() {
    if (_selectedCategory == 'All') {
      _filteredMarkers = List.from(_allMarkers);
    } else {
      _filteredMarkers = _allMarkers
          .where((m) => m.category == _selectedCategory)
          .toList();
    }
  }

  // ── Select / deselect a marker ────────────────────────────────────────────
  void selectMarker(MapMarkerModel? marker) {
    _selectedMarker = marker;
    notifyListeners();
  }

  void clearSelection() {
    _selectedMarker = null;
    notifyListeners();
  }

  // ── Manual refresh ────────────────────────────────────────────────────────
  Future<void> refresh() async {
    _isLoading = true;
    notifyListeners();
    try {
      final markers = await _repository.fetchPinnedListings();
      _allMarkers = markers;
      _applyFilter();
      _errorMessage = null;
    } catch (e) {
      _errorMessage = 'Refresh failed: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _streamSub?.cancel();
    super.dispose();
  }
}
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

  // mapMarkers  → what the map pins show (only category-filtered, NEVER text-hidden)
  List<MapMarkerModel> _mapMarkers = [];
  List<MapMarkerModel> get mapMarkers => _mapMarkers;

  // listMarkers → what the bottom-sheet list shows (category + text filtered)
  List<MapMarkerModel> _listMarkers = [];
  List<MapMarkerModel> get listMarkers => _listMarkers;

  // Keep for legacy callers that use filteredMarkers
  List<MapMarkerModel> get filteredMarkers => _mapMarkers;

  String _selectedCategory = 'All';
  String get selectedCategory => _selectedCategory;

  String _searchQuery = '';
  String get searchQuery => _searchQuery;

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

  // ── Init ──────────────────────────────────────────────────────────────────
  void _init() {
    _isLoading = true;
    _streamSub = _repository.streamPinnedListings().listen(
      (markers) {
        _allMarkers = markers;
        _applyFilters();
        _isLoading  = false;
        _errorMessage = null;
        notifyListeners();
      },
      onError: (e) {
        _isLoading    = false;
        _errorMessage = 'Failed to load listings: $e';
        notifyListeners();
      },
    );
  }

  // ── Category filter (affects map + list) ──────────────────────────────────
  void filterByCategory(String category) {
    _selectedCategory = category;
    _applyFilters();
    notifyListeners();
  }

  // ── Text search (affects list only — map pins stay visible) ───────────────
  void filterByText(String query) {
    _searchQuery = query.trim().toLowerCase();
    _applyFilters();
    notifyListeners();
  }

  void clearTextSearch() {
    _searchQuery = '';
    _applyFilters();
    notifyListeners();
  }

  void _applyFilters() {
    // 1. Category filter applies to BOTH map and list
    final List<MapMarkerModel> categoryFiltered =
        _selectedCategory == 'All'
            ? List.from(_allMarkers)
            : _allMarkers
                .where((m) => m.category == _selectedCategory)
                .toList();

    // 2. Map always shows category-filtered markers (text search does NOT hide pins)
    _mapMarkers = categoryFiltered;

    // 3. List additionally applies text search (title / location / category)
    if (_searchQuery.isEmpty) {
      _listMarkers = categoryFiltered;
    } else {
      _listMarkers = categoryFiltered.where((m) {
        return m.title.toLowerCase().contains(_searchQuery) ||
            m.location.toLowerCase().contains(_searchQuery) ||
            m.category.toLowerCase().contains(_searchQuery) ||
            m.tenantPreference.toLowerCase().contains(_searchQuery);
      }).toList();
    }
  }

  // ── Marker selection ──────────────────────────────────────────────────────
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
      _allMarkers   = markers;
      _applyFilters();
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
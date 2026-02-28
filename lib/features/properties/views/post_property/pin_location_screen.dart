import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';

class PinLocationScreen extends StatefulWidget {
  final String? initialAddress;

  const PinLocationScreen({super.key, this.initialAddress});

  @override
  State<PinLocationScreen> createState() => _PinLocationScreenState();
}

class _PinLocationScreenState extends State<PinLocationScreen> {
  GoogleMapController? _mapController;
  final TextEditingController _searchController = TextEditingController();

  // ⚠️ Move this to a secure backend / env config — never hard-code in production
  final String _googleApiKey = 'AIzaSyD134P-7TrEIRgx7YnwS9Rx4rBupGB70nM';

  LatLng _currentCenter = const LatLng(10.6765, 122.9509); // Default: Bacolod
  String _selectedCategory = 'All';
  bool _hasConfirmedPin = false;
  bool _isSearching = false;

  // ── Autocomplete ──────────────────────────────────────────────────────────
  Timer? _debounce;
  List<dynamic> _placePredictions = [];

  @override
  void initState() {
    super.initState();
    if (widget.initialAddress?.isNotEmpty == true) {
      _searchController.text = widget.initialAddress!;
    }
  }

  @override
  void dispose() {
    _mapController?.dispose();
    _searchController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  // ── 1. Autocomplete while typing ──────────────────────────────────────────
  void _onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 450), () async {
      if (query.trim().isEmpty) {
        setState(() => _placePredictions = []);
        return;
      }
      final url = Uri.parse(
        'https://maps.googleapis.com/maps/api/place/autocomplete/json'
        '?input=${Uri.encodeComponent(query)}'
        '&components=country:ph'
        '&key=$_googleApiKey',
      );
      try {
        final response = await http.get(url);
        if (!mounted) return;
        final data = json.decode(response.body) as Map<String, dynamic>;
        if (data['status'] == 'OK') {
          setState(() => _placePredictions =
              List<dynamic>.from(data['predictions'] ?? []));
        }
      } catch (e) {
        debugPrint('Autocomplete error: $e');
      }
    });
  }

  // ── 2. Get lat/lng from Place ID ──────────────────────────────────────────
  Future<void> _getPlaceDetails(
      String placeId, String description) async {
    setState(() {
      _searchController.text = description;
      _placePredictions = [];
      _hasConfirmedPin = false;
      _isSearching = true;
    });
    FocusScope.of(context).unfocus();

    final url = Uri.parse(
      'https://maps.googleapis.com/maps/api/place/details/json'
      '?place_id=$placeId'
      '&fields=geometry'
      '&key=$_googleApiKey',
    );
    try {
      final response = await http.get(url);
      if (!mounted) return;
      final data = json.decode(response.body) as Map<String, dynamic>;
      if (data['status'] == 'OK') {
        final loc =
            data['result']['geometry']['location'] as Map<String, dynamic>;
        final target = LatLng(
          (loc['lat'] as num).toDouble(),
          (loc['lng'] as num).toDouble(),
        );
        setState(() => _currentCenter = target);
        _mapController?.animateCamera(
            CameraUpdate.newLatLngZoom(target, 18.5));
      }
    } catch (e) {
      debugPrint('Place details error: $e');
    } finally {
      if (mounted) setState(() => _isSearching = false);
    }
  }

  // ── 3. Fallback geocode search ────────────────────────────────────────────
  Future<void> _searchPlaceFallback(String query) async {
    setState(() {
      _placePredictions = [];
      _isSearching = true;
    });
    FocusScope.of(context).unfocus();
    if (query.trim().isEmpty) {
      setState(() => _isSearching = false);
      return;
    }

    final searchQuery = query.toLowerCase().contains('bacolod')
        ? query
        : '$query, Bacolod City';
    final url = Uri.parse(
      'https://maps.googleapis.com/maps/api/geocode/json'
      '?address=${Uri.encodeComponent(searchQuery)}'
      '&key=$_googleApiKey',
    );
    try {
      final response = await http.get(url);
      if (!mounted) return;
      final data = json.decode(response.body) as Map<String, dynamic>;
      if (data['status'] == 'OK') {
        final loc = data['results'][0]['geometry']['location']
            as Map<String, dynamic>;
        final target = LatLng(
          (loc['lat'] as num).toDouble(),
          (loc['lng'] as num).toDouble(),
        );
        setState(() => _currentCenter = target);
        _mapController?.animateCamera(
            CameraUpdate.newLatLngZoom(target, 18.5));
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text(
                    'Location not found. Try picking from suggestions.')),
          );
        }
      }
    } catch (e) {
      debugPrint('Geocode error: $e');
    } finally {
      if (mounted) setState(() => _isSearching = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final photoUrl = FirebaseAuth.instance.currentUser?.photoURL;

    return Scaffold(
      body: Stack(
        children: [
          // ── Google Map ───────────────────────────────────────────────────
          GoogleMap(
            initialCameraPosition: CameraPosition(
              target: _currentCenter,
              zoom: 15.0,
            ),
            onMapCreated: (controller) {
              _mapController = controller;
              // Auto-search the pre-filled address on map load
              if (widget.initialAddress?.isNotEmpty == true) {
                Future.delayed(const Duration(milliseconds: 400), () {
                  _searchPlaceFallback(widget.initialAddress!);
                });
              }
            },
            onCameraMove: (CameraPosition position) {
              if (_currentCenter != position.target) {
                setState(() {
                  _currentCenter = position.target;
                  _hasConfirmedPin = false;
                });
              }
            },
            myLocationEnabled: true,
            myLocationButtonEnabled: false,
            zoomControlsEnabled: false,
            mapToolbarEnabled: false,
          ),

          // ── Animated Center Pin ──────────────────────────────────────────
          Center(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 40.0),
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 250),
                child: Icon(
                  Icons.location_on,
                  key: ValueKey(_hasConfirmedPin),
                  size: 50,
                  color: _hasConfirmedPin ? Colors.green : Colors.red,
                  shadows: const [
                    Shadow(
                        blurRadius: 8,
                        color: Colors.black26,
                        offset: Offset(0, 2))
                  ],
                ),
              ),
            ),
          ),

          // ── Top Overlay ──────────────────────────────────────────────────
          SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16.0, vertical: 12.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Back Button
                      _buildCircleButton(
                        child: const Icon(Icons.arrow_back,
                            color: Colors.black87, size: 22),
                        onTap: () => Navigator.pop(context),
                      ),
                      const SizedBox(width: 12),

                      // Search Field + Autocomplete Dropdown
                      Expanded(
                        child: Column(
                          children: [
                            _buildSearchBar(),
                            if (_placePredictions.isNotEmpty)
                              _buildAutocompleteDropdown(),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),

                      // User Avatar
                      _buildUserAvatar(photoUrl),
                    ],
                  ),
                ),

                // Category Chips (hidden while dropdown is visible)
                if (_placePredictions.isEmpty)
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Row(
                      children: [
                        _buildCategoryChip(
                            'Boarding House', Icons.home_outlined),
                        const SizedBox(width: 8),
                        _buildCategoryChip(
                            'Apartment', Icons.apartment_outlined),
                        const SizedBox(width: 8),
                        _buildCategoryChip(
                            'Dorm', Icons.bedroom_child_outlined),
                        const SizedBox(width: 8),
                        _buildCategoryChip(
                            'Bedspace', Icons.bed_outlined),
                      ],
                    ),
                  ),
              ],
            ),
          ),

          // ── Loading Indicator ────────────────────────────────────────────
          if (_isSearching)
            const Center(
              child: Card(
                elevation: 4,
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: SizedBox(
                    height: 28,
                    width: 28,
                    child:
                        CircularProgressIndicator(strokeWidth: 2.5),
                  ),
                ),
              ),
            ),

          // ── Coordinates Badge ────────────────────────────────────────────
          Positioned(
            bottom: 230,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.72),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '📍 ${_currentCenter.latitude.toStringAsFixed(6)}, '
                  '${_currentCenter.longitude.toStringAsFixed(6)}',
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w500),
                ),
              ),
            ),
          ),

          // ── Bottom Panel ─────────────────────────────────────────────────
          Positioned(
            bottom: 30,
            left: 16,
            right: 16,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                // Layers button (placeholder for map type toggle)
                FloatingActionButton(
                  heroTag: 'layers_pin',
                  mini: true,
                  backgroundColor: Colors.white,
                  onPressed: () {},
                  child: const Icon(Icons.layers_outlined,
                      color: Colors.black87),
                ),
                const SizedBox(height: 12),

                // My location button — re-centers to Bacolod default
                FloatingActionButton(
                  heroTag: 'location_pin',
                  backgroundColor: Colors.white,
                  onPressed: () {
                    const bacolod = LatLng(10.6765, 122.9509);
                    _mapController?.animateCamera(
                        CameraUpdate.newLatLngZoom(bacolod, 15.0));
                  },
                  child: const Icon(Icons.my_location,
                      color: Colors.blue),
                ),
                const SizedBox(height: 20),

                // Confirm Panel
                _buildConfirmPanel(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Search Bar ─────────────────────────────────────────────────────────────
  Widget _buildSearchBar() {
    return Container(
      height: 50,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.12),
              blurRadius: 8,
              offset: const Offset(0, 3)),
        ],
      ),
      child: Row(
        children: [
          const SizedBox(width: 16),
          const Icon(Icons.search, color: Colors.blue),
          const SizedBox(width: 12),
          Expanded(
            child: TextField(
              controller: _searchController,
              onChanged: _onSearchChanged,
              onSubmitted: _searchPlaceFallback,
              decoration: const InputDecoration(
                hintText: 'Search address or place',
                hintStyle:
                    TextStyle(color: Colors.grey, fontSize: 15),
                border: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.zero,
              ),
            ),
          ),
          if (_searchController.text.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.clear, color: Colors.grey),
              onPressed: () {
                _searchController.clear();
                setState(() => _placePredictions = []);
              },
            ),
        ],
      ),
    );
  }

  // ── Autocomplete Dropdown ─────────────────────────────────────────────────
  Widget _buildAutocompleteDropdown() {
    return Container(
      margin: const EdgeInsets.only(top: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 8,
              offset: const Offset(0, 3)),
        ],
      ),
      constraints: const BoxConstraints(maxHeight: 250),
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(vertical: 8),
        shrinkWrap: true,
        itemCount: _placePredictions.length,
        separatorBuilder: (_, __) => const Divider(height: 1),
        itemBuilder: (context, index) {
          final p =
              _placePredictions[index] as Map<String, dynamic>;
          return ListTile(
            dense: true,
            leading: const Icon(Icons.location_on_outlined,
                color: Colors.grey, size: 20),
            title: Text(
              p['description'] as String? ?? '',
              style: const TextStyle(fontSize: 13),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            onTap: () => _getPlaceDetails(
              p['place_id'] as String,
              p['description'] as String,
            ),
          );
        },
      ),
    );
  }

  // ── Confirm Panel ─────────────────────────────────────────────────────────
  Widget _buildConfirmPanel() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(
              color: Colors.black12,
              blurRadius: 12,
              offset: Offset(0, 4)),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 250),
                child: Icon(
                  _hasConfirmedPin
                      ? Icons.check_circle
                      : Icons.info_outline,
                  key: ValueKey(_hasConfirmedPin),
                  color: _hasConfirmedPin
                      ? Colors.green
                      : Colors.blueAccent,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  _hasConfirmedPin
                      ? 'Location confirmed! Tap Confirm again to update the pin.'
                      : 'Drag the map so the pin sits exactly on your property.',
                  style: const TextStyle(
                      fontWeight: FontWeight.w500, fontSize: 13),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: () {
                setState(() => _hasConfirmedPin = true);
                Navigator.pop(context, _currentCenter);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
                elevation: 0,
              ),
              child: const Text(
                'Confirm Location',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Category Chip ─────────────────────────────────────────────────────────
  Widget _buildCategoryChip(String label, IconData icon) {
    final bool isSelected = _selectedCategory == label;
    return GestureDetector(
      onTap: () => setState(
          () => _selectedCategory = isSelected ? 'All' : label),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? Colors.blue.shade50 : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
              color:
                  isSelected ? Colors.blue : Colors.transparent),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withValues(alpha: 0.07),
                blurRadius: 4,
                offset: const Offset(0, 2)),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon,
                size: 16,
                color:
                    isSelected ? Colors.blue : Colors.black54),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.blue : Colors.black87,
                fontWeight: FontWeight.w500,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Circle Button ─────────────────────────────────────────────────────────
  Widget _buildCircleButton(
      {required Widget child, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 8,
                offset: const Offset(0, 3)),
          ],
        ),
        child: child,
      ),
    );
  }

  // ── User Avatar ───────────────────────────────────────────────────────────
  Widget _buildUserAvatar(String? photoUrl) {
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 8,
              offset: const Offset(0, 3)),
        ],
        border: Border.all(color: Colors.white, width: 2),
      ),
      child: CircleAvatar(
        radius: 20,
        backgroundColor: Colors.grey[300],
        backgroundImage:
            photoUrl != null ? NetworkImage(photoUrl) : null,
        child: photoUrl == null
            ? const Icon(Icons.person, color: Colors.grey)
            : null,
      ),
    );
  }
}
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

  final String googleApiKey = 'AIzaSyD134P-7TrEIRgx7YnwS9Rx4rBupGB70nM';

  LatLng _currentCenter = const LatLng(10.6765, 122.9509); // Default: Bacolod
  String _selectedCategory = 'All';
  bool _hasConfirmedPin = false;

  // ── Autocomplete ──────────────────────────────────────────────────────────
  Timer? _debounce;
  List<dynamic> _placePredictions = [];

  @override
  void initState() {
    super.initState();
    if (widget.initialAddress != null && widget.initialAddress!.isNotEmpty) {
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
    _debounce = Timer(const Duration(milliseconds: 500), () async {
      if (query.isEmpty) {
        setState(() => _placePredictions = []);
        return;
      }
      final url =
          'https://maps.googleapis.com/maps/api/place/autocomplete/json?input=$query&components=country:ph&key=$googleApiKey';
      try {
        final response = await http.get(Uri.parse(url));
        final data = json.decode(response.body);
        if (data['status'] == 'OK') {
          setState(() => _placePredictions = data['predictions']);
        }
      } catch (e) {
        debugPrint('Autocomplete error: $e');
      }
    });
  }

  // ── 2. Get exact lat/lng from Place ID ───────────────────────────────────
  Future<void> _getPlaceDetails(String placeId, String description) async {
    setState(() {
      _searchController.text = description;
      _placePredictions = [];
      _hasConfirmedPin = false;
    });
    FocusScope.of(context).unfocus();

    final url =
        'https://maps.googleapis.com/maps/api/place/details/json?place_id=$placeId&key=$googleApiKey';
    try {
      final response = await http.get(Uri.parse(url));
      final data = json.decode(response.body);
      if (data['status'] == 'OK') {
        final loc = data['result']['geometry']['location'];
        final target = LatLng(loc['lat'], loc['lng']);
        setState(() => _currentCenter = target);
        _mapController?.animateCamera(CameraUpdate.newLatLngZoom(target, 18.5));
      }
    } catch (e) {
      debugPrint('Place details error: $e');
    }
  }

  // ── 3. Fallback geocode search ────────────────────────────────────────────
  Future<void> _searchPlaceFallback(String query) async {
    setState(() => _placePredictions = []);
    FocusScope.of(context).unfocus();
    if (query.isEmpty) return;

    final searchQuery = query.toLowerCase().contains('bacolod')
        ? query
        : '$query, Bacolod City';
    final url =
        'https://maps.googleapis.com/maps/api/geocode/json?address=$searchQuery&key=$googleApiKey';
    try {
      final response = await http.get(Uri.parse(url));
      final data = json.decode(response.body);
      if (data['status'] == 'OK') {
        final loc = data['results'][0]['geometry']['location'];
        final target = LatLng(loc['lat'], loc['lng']);
        setState(() => _currentCenter = target);
        _mapController?.animateCamera(CameraUpdate.newLatLngZoom(target, 18.5));
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text('Location not found. Try picking from suggestions.')),
          );
        }
      }
    } catch (e) {
      debugPrint('Geocode error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final photoUrl = FirebaseAuth.instance.currentUser?.photoURL;

    return Scaffold(
      body: Stack(
        children: [
          // ── Google Map ──────────────────────────────────────────────────
          GoogleMap(
            initialCameraPosition: CameraPosition(
              target: _currentCenter,
              zoom: 15.0,
            ),
            onMapCreated: (controller) {
              _mapController = controller;
              if (widget.initialAddress != null &&
                  widget.initialAddress!.isNotEmpty) {
                Future.delayed(const Duration(milliseconds: 300), () {
                  _searchPlaceFallback(widget.initialAddress!);
                });
              }
            },
            onCameraMove: (CameraPosition position) {
              setState(() {
                _currentCenter = position.target;
                _hasConfirmedPin = false; // Reset if user moves map
              });
            },
            myLocationEnabled: true,
            myLocationButtonEnabled: false,
            zoomControlsEnabled: false,
            mapToolbarEnabled: false,
          ),

          // ── Center Pin ──────────────────────────────────────────────────
          Center(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 40.0),
              child: Icon(
                Icons.location_on,
                size: 50,
                color: _hasConfirmedPin ? Colors.green : Colors.red,
              ),
            ),
          ),

          // ── Top Overlay ─────────────────────────────────────────────────
          SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16.0, vertical: 12.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Back Button
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  blurRadius: 8,
                                  offset: const Offset(0, 3)),
                            ],
                          ),
                          child: const Icon(Icons.arrow_back,
                              color: Colors.black87, size: 22),
                        ),
                      ),
                      const SizedBox(width: 12),

                      // Search + Dropdown
                      Expanded(
                        child: Column(
                          children: [
                            Container(
                              height: 50,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(25),
                                boxShadow: [
                                  BoxShadow(
                                      color: Colors.black.withOpacity(0.1),
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
                                        hintText: 'Search here',
                                        hintStyle: TextStyle(
                                            color: Colors.grey, fontSize: 16),
                                        border: InputBorder.none,
                                        isDense: true,
                                        contentPadding: EdgeInsets.zero,
                                      ),
                                    ),
                                  ),
                                  if (_searchController.text.isNotEmpty)
                                    IconButton(
                                      icon: const Icon(Icons.clear,
                                          color: Colors.grey),
                                      onPressed: () {
                                        _searchController.clear();
                                        setState(
                                            () => _placePredictions = []);
                                      },
                                    ),
                                ],
                              ),
                            ),

                            // Autocomplete dropdown
                            if (_placePredictions.isNotEmpty)
                              Container(
                                margin: const EdgeInsets.only(top: 8),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(16),
                                  boxShadow: [
                                    BoxShadow(
                                        color: Colors.black.withOpacity(0.1),
                                        blurRadius: 8,
                                        offset: const Offset(0, 3)),
                                  ],
                                ),
                                constraints:
                                    const BoxConstraints(maxHeight: 250),
                                child: ListView.builder(
                                  padding: EdgeInsets.zero,
                                  shrinkWrap: true,
                                  itemCount: _placePredictions.length,
                                  itemBuilder: (context, index) {
                                    final p = _placePredictions[index];
                                    return ListTile(
                                      leading: const Icon(
                                          Icons.location_on_outlined,
                                          color: Colors.grey),
                                      title: Text(
                                        p['description'],
                                        style:
                                            const TextStyle(fontSize: 14),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      onTap: () => _getPlaceDetails(
                                          p['place_id'], p['description']),
                                    );
                                  },
                                ),
                              ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),

                      // User Avatar
                      Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 8,
                                offset: const Offset(0, 3)),
                          ],
                          border: Border.all(color: Colors.white, width: 2),
                        ),
                        child: CircleAvatar(
                          radius: 20,
                          backgroundColor: Colors.grey[300],
                          backgroundImage: photoUrl != null
                              ? NetworkImage(photoUrl)
                              : null,
                          child: photoUrl == null
                              ? const Icon(Icons.person, color: Colors.grey)
                              : null,
                        ),
                      ),
                    ],
                  ),
                ),

                // Category chips (hidden while dropdown is open)
                if (_placePredictions.isEmpty)
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Row(
                      children: [
                        _buildCategoryChip('Boarding House', Icons.home),
                        const SizedBox(width: 8),
                        _buildCategoryChip('Apartment', Icons.apartment),
                        const SizedBox(width: 8),
                        _buildCategoryChip('Dorm', Icons.bedroom_child),
                        const SizedBox(width: 8),
                        _buildCategoryChip('Bedspace', Icons.bed),
                      ],
                    ),
                  ),
              ],
            ),
          ),

          // ── Coordinates Display ─────────────────────────────────────────
          Positioned(
            bottom: 220,
            left: 16,
            right: 16,
            child: Center(
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.7),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '📍 ${_currentCenter.latitude.toStringAsFixed(5)}, ${_currentCenter.longitude.toStringAsFixed(5)}',
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w500),
                ),
              ),
            ),
          ),

          // ── Bottom Panel ────────────────────────────────────────────────
          Positioned(
            bottom: 30,
            left: 16,
            right: 16,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                FloatingActionButton(
                  heroTag: 'layers_pin',
                  mini: true,
                  backgroundColor: Colors.white,
                  onPressed: () {},
                  child: const Icon(Icons.layers, color: Colors.black87),
                ),
                const SizedBox(height: 12),
                FloatingActionButton(
                  heroTag: 'location_pin',
                  backgroundColor: Colors.white,
                  onPressed: () {
                    _mapController?.animateCamera(
                      CameraUpdate.newLatLngZoom(
                          const LatLng(10.6765, 122.9509), 15.0),
                    );
                  },
                  child: const Icon(Icons.my_location, color: Colors.blue),
                ),
                const SizedBox(height: 24),

                // Confirm Panel
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: const [
                      BoxShadow(
                          color: Colors.black12,
                          blurRadius: 10,
                          offset: Offset(0, 4)),
                    ],
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Icon(
                            _hasConfirmedPin
                                ? Icons.check_circle
                                : Icons.info_outline,
                            color: _hasConfirmedPin
                                ? Colors.green
                                : Colors.blueAccent,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              _hasConfirmedPin
                                  ? 'Location confirmed! Tap again to repin.'
                                  : 'Drag the map to move the pin to your exact property location.',
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
                          // ✅ Returns LatLng back to posting_form.dart
                          // posting_form saves it to Firestore on publish
                          onPressed: () {
                            setState(() => _hasConfirmedPin = true);
                            Navigator.pop(context, _currentCenter);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.black,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12)),
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
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryChip(String label, IconData icon) {
    final bool isSelected = _selectedCategory == label;
    return GestureDetector(
      onTap: () =>
          setState(() => _selectedCategory = isSelected ? 'All' : label),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? Colors.blue[50] : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border:
              Border.all(color: isSelected ? Colors.blue : Colors.transparent),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 4,
                offset: const Offset(0, 2)),
          ],
        ),
        child: Row(
          children: [
            Icon(icon,
                size: 16,
                color: isSelected ? Colors.blue : Colors.black54),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.blue : Colors.black87,
                fontWeight: FontWeight.w500,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
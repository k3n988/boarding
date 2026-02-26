import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

// map_screen.dart is at: lib/features/map/views/map_screen.dart
// ✅ properties is a sibling of map, so go up 2 levels (views → map → features) then into properties
import '../../properties/data/models/property_model.dart';
// ✅ viewmodels is a sibling of views inside map, so go up 1 level
import '../viewmodels/map_viewmodel.dart';
// ✅ data is a sibling of views inside map, so go up 1 level
import '../data/models/map_marker_model.dart';
// ✅ widgets is a subfolder of views, so no ../
import 'widgets/map_filter_bar.dart';
import 'widgets/safety_heatmap_layer.dart';

// ── Entry point ───────────────────────────────────────────────────────────────
class MapScreen extends StatelessWidget {
  const MapScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => MapViewModel(),
      child: const _MapScreenView(),
    );
  }
}

class _MapScreenView extends StatefulWidget {
  const _MapScreenView();

  @override
  State<_MapScreenView> createState() => _MapScreenViewState();
}

class _MapScreenViewState extends State<_MapScreenView> {
  GoogleMapController? _mapController;
  final TextEditingController _searchController = TextEditingController();
  final String _googleApiKey = 'AIzaSyD134P-7TrEIRgx7YnwS9Rx4rBupGB70nM';
  static const LatLng _bacolodCenter = LatLng(10.6765, 122.9509);

  Timer? _debounce;
  List<dynamic> _placePredictions = [];

  @override
  void dispose() {
    _mapController?.dispose();
    _searchController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  Set<Marker> _buildMarkers(List<MapMarkerModel> listings, MapViewModel vm) {
    return listings.map((item) {
      return Marker(
        markerId: MarkerId(item.id),
        position: LatLng(item.lat, item.lng),
        icon: BitmapDescriptor.defaultMarkerWithHue(_markerHue(item.category)),
        infoWindow: InfoWindow(
          title: item.title,
          snippet: '₱${item.price.toStringAsFixed(0)}/mo · ${item.category}',
        ),
        onTap: () {
          vm.selectMarker(item);
          _mapController?.animateCamera(
            CameraUpdate.newLatLngZoom(LatLng(item.lat, item.lng), 17.0),
          );
        },
      );
    }).toSet();
  }

  double _markerHue(String category) {
    switch (category) {
      case 'Boarding House': return BitmapDescriptor.hueRed;
      case 'Dormitory':      return BitmapDescriptor.hueBlue;
      case 'Apartment':      return BitmapDescriptor.hueGreen;
      case 'Bedspace':       return BitmapDescriptor.hueOrange;
      default:               return BitmapDescriptor.hueRed;
    }
  }

  // ── Autocomplete ──────────────────────────────────────────────────────────
  void _onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () async {
      if (query.isEmpty) { setState(() => _placePredictions = []); return; }
      final url =
          'https://maps.googleapis.com/maps/api/place/autocomplete/json?input=$query&components=country:ph&key=$_googleApiKey';
      try {
        final response = await http.get(Uri.parse(url));
        final data = json.decode(response.body);
        if (data['status'] == 'OK') setState(() => _placePredictions = data['predictions']);
      } catch (e) { debugPrint('Autocomplete error: $e'); }
    });
  }

  Future<void> _getPlaceDetails(String placeId, String description) async {
    setState(() { _searchController.text = description; _placePredictions = []; });
    FocusScope.of(context).unfocus();
    final url =
        'https://maps.googleapis.com/maps/api/place/details/json?place_id=$placeId&key=$_googleApiKey';
    try {
      final response = await http.get(Uri.parse(url));
      final data = json.decode(response.body);
      if (data['status'] == 'OK') {
        final loc = data['result']['geometry']['location'];
        _mapController?.animateCamera(
          CameraUpdate.newLatLngZoom(LatLng(loc['lat'], loc['lng']), 16.0),
        );
      }
    } catch (e) { debugPrint('Place details error: $e'); }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<MapViewModel>(
      builder: (context, vm, _) {
        final markers = _buildMarkers(vm.filteredMarkers, vm);

        return Scaffold(
          body: Stack(
            children: [
              // ── Google Map ────────────────────────────────────────────────
              GoogleMap(
                initialCameraPosition: const CameraPosition(target: _bacolodCenter, zoom: 13.0),
                onMapCreated: (c) => _mapController = c,
                markers: markers,
                myLocationEnabled: true,
                myLocationButtonEnabled: false,
                zoomControlsEnabled: false,
                mapToolbarEnabled: false,
                onTap: (_) => vm.clearSelection(),
              ),

              const SafetyHeatmapLayer(),

              // ── Loading ───────────────────────────────────────────────────
              if (vm.isLoading)
                Container(
                  color: Colors.white.withValues(alpha: 0.6),
                  child: const Center(child: CircularProgressIndicator(color: Colors.black)),
                ),

              // ── Error ─────────────────────────────────────────────────────
              if (vm.errorMessage != null)
                Positioned(
                  top: 110, left: 16, right: 16,
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.red.shade50,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.red.shade200),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.error_outline, color: Colors.red, size: 18),
                        const SizedBox(width: 8),
                        Expanded(child: Text(vm.errorMessage!,
                            style: const TextStyle(color: Colors.red, fontSize: 13))),
                        GestureDetector(
                          onTap: vm.refresh,
                          child: const Text('Retry',
                              style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
                        ),
                      ],
                    ),
                  ),
                ),

              // ── Search + Filter ───────────────────────────────────────────
              SafeArea(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                      child: Column(
                        children: [
                          // Search bar
                          Container(
                            height: 50,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(25),
                              boxShadow: [
                                BoxShadow(color: Colors.black.withValues(alpha: 0.1),
                                    blurRadius: 10, offset: const Offset(0, 3)),
                              ],
                            ),
                            child: Row(
                              children: [
                                const SizedBox(width: 16),
                                const Icon(Icons.search, color: Colors.blue),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: TextField(
                                    controller: _searchController,
                                    onChanged: _onSearchChanged,
                                    decoration: const InputDecoration(
                                      hintText: 'Search barangay or street...',
                                      hintStyle: TextStyle(color: Colors.grey, fontSize: 14),
                                      border: InputBorder.none,
                                      isDense: true,
                                      contentPadding: EdgeInsets.zero,
                                    ),
                                  ),
                                ),
                                if (_searchController.text.isNotEmpty)
                                  IconButton(
                                    icon: const Icon(Icons.clear, color: Colors.grey, size: 20),
                                    onPressed: () {
                                      _searchController.clear();
                                      setState(() => _placePredictions = []);
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
                                  BoxShadow(color: Colors.black.withValues(alpha: 0.1),
                                      blurRadius: 8, offset: const Offset(0, 3)),
                                ],
                              ),
                              constraints: const BoxConstraints(maxHeight: 220),
                              child: ListView.builder(
                                padding: EdgeInsets.zero,
                                shrinkWrap: true,
                                itemCount: _placePredictions.length,
                                itemBuilder: (context, i) {
                                  final p = _placePredictions[i];
                                  return ListTile(
                                    leading: const Icon(Icons.location_on_outlined,
                                        color: Colors.grey, size: 18),
                                    title: Text(p['description'],
                                        style: const TextStyle(fontSize: 13),
                                        maxLines: 2, overflow: TextOverflow.ellipsis),
                                    onTap: () => _getPlaceDetails(p['place_id'], p['description']),
                                  );
                                },
                              ),
                            ),
                        ],
                      ),
                    ),

                    // Category filter chips
                    if (_placePredictions.isEmpty) MapFilterBar(viewModel: vm),
                  ],
                ),
              ),

              // ── Listing count badge ───────────────────────────────────────
              if (!vm.isLoading && _placePredictions.isEmpty)
                Positioned(
                  top: 132, left: 0, right: 0,
                  child: Center(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.72),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        vm.filteredMarkers.isEmpty
                            ? 'No listings in this area'
                            : '${vm.filteredMarkers.length} listing${vm.filteredMarkers.length == 1 ? '' : 's'} on map',
                        style: const TextStyle(color: Colors.white, fontSize: 12),
                      ),
                    ),
                  ),
                ),

              // ── FABs ──────────────────────────────────────────────────────
              Positioned(
                bottom: vm.selectedMarker != null ? 290 : 110,
                right: 16,
                child: Column(
                  children: [
                    FloatingActionButton(
                      heroTag: 'map_refresh',
                      mini: true,
                      backgroundColor: Colors.white,
                      onPressed: vm.refresh,
                      child: const Icon(Icons.refresh, color: Colors.black87, size: 20),
                    ),
                    const SizedBox(height: 10),
                    FloatingActionButton(
                      heroTag: 'map_recenter',
                      backgroundColor: Colors.white,
                      onPressed: () => _mapController?.animateCamera(
                        CameraUpdate.newLatLngZoom(_bacolodCenter, 13.0),
                      ),
                      child: const Icon(Icons.my_location, color: Colors.blue),
                    ),
                  ],
                ),
              ),

              // ── Property bottom card ──────────────────────────────────────
              if (vm.selectedMarker != null)
                Positioned(
                  bottom: 0, left: 0, right: 0,
                  child: _PropertyBottomCard(
                    marker: vm.selectedMarker!,
                    onClose: vm.clearSelection,
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}

// ── Property bottom card ──────────────────────────────────────────────────────
class _PropertyBottomCard extends StatelessWidget {
  final MapMarkerModel marker;
  final VoidCallback onClose;

  const _PropertyBottomCard({required this.marker, required this.onClose});

  Color _categoryColor(String category) {
    switch (category) {
      case 'Boarding House': return Colors.red.shade600;
      case 'Dormitory':      return Colors.blue.shade600;
      case 'Apartment':      return Colors.green.shade600;
      case 'Bedspace':       return Colors.orange.shade600;
      default:               return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 20, offset: Offset(0, -4)),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag handle
          Padding(
            padding: const EdgeInsets.only(top: 12),
            child: Container(
              width: 40, height: 4,
              decoration: BoxDecoration(
                  color: Colors.grey[300], borderRadius: BorderRadius.circular(2)),
            ),
          ),

          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Image
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: marker.imageUrl.isNotEmpty
                      ? Image.network(marker.imageUrl, width: 90, height: 85,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => _placeholder())
                      : _placeholder(),
                ),
                const SizedBox(width: 14),

                // Details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(marker.title,
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                                maxLines: 1, overflow: TextOverflow.ellipsis),
                          ),
                          GestureDetector(
                            onTap: onClose,
                            child: const Icon(Icons.close, size: 20, color: Colors.grey),
                          ),
                        ],
                      ),
                      const SizedBox(height: 5),

                      // Category badge
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: _categoryColor(marker.category).withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(
                              color: _categoryColor(marker.category).withValues(alpha: 0.4)),
                        ),
                        child: Text(marker.category,
                            style: TextStyle(
                                fontSize: 11,
                                color: _categoryColor(marker.category),
                                fontWeight: FontWeight.w600)),
                      ),
                      const SizedBox(height: 6),

                      // Location
                      Row(
                        children: [
                          const Icon(Icons.location_on_outlined, size: 12, color: Colors.grey),
                          const SizedBox(width: 3),
                          Expanded(
                            child: Text(marker.location,
                                style: const TextStyle(fontSize: 12, color: Colors.grey),
                                maxLines: 1, overflow: TextOverflow.ellipsis),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),

                      // Price + Slots
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('₱${marker.price.toStringAsFixed(0)}/mo',
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 17)),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: marker.availableSlots > 0
                                  ? Colors.green.shade50
                                  : Colors.red.shade50,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              marker.availableSlots > 0
                                  ? '${marker.availableSlots} slots left'
                                  : 'Full',
                              style: TextStyle(
                                  fontSize: 11,
                                  color: marker.availableSlots > 0
                                      ? Colors.green.shade700
                                      : Colors.red,
                                  fontWeight: FontWeight.w600),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // View Details button
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
            child: SizedBox(
              width: double.infinity,
              height: 46,
              child: ElevatedButton(
                onPressed: () {
                  context.push(
                    '/property/${marker.id}',
                    extra: PropertyModel(
                      id: marker.id,
                      title: marker.title,
                      location: marker.location,
                      price: marker.price,
                      imageUrl: marker.imageUrl,
                      imageUrls: [marker.imageUrl],
                      category: marker.category,
                      availableSlots: marker.availableSlots,
                      tenantPreference: marker.tenantPreference,
                      amenities: const [],
                      isLocationPinned: true,
                      latitude: marker.lat,
                      longitude: marker.lng,
                      description: '',
                      policies: '',
                      hostId: '',
                    ),
                  );
                  onClose();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 0,
                ),
                child: const Text('View Details',
                    style: TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _placeholder() => Container(
        width: 90, height: 85,
        decoration: BoxDecoration(
            color: Colors.grey[200], borderRadius: BorderRadius.circular(12)),
        child: const Icon(Icons.home_rounded, color: Colors.grey, size: 32),
      );
}
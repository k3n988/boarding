import 'dart:async';
import 'dart:convert';
import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

import '../../properties/data/models/property_model.dart';
import '../viewmodels/map_viewmodel.dart';
import '../data/models/map_marker_model.dart';
import 'widgets/map_filter_bar.dart';
import 'widgets/safety_heatmap_layer.dart';

// ─────────────────────────────────────────────────────────────────────────────
// pubspec.yaml — add under dependencies:
//   geolocator: ^11.0.0
//
// android/app/src/main/AndroidManifest.xml — add inside <manifest>:
//   <uses-permission android:name="android.permission.ACCESS_FINE_LOCATION" />
//   <uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION" />
//
// ios/Runner/Info.plist — add:
//   <key>NSLocationWhenInUseUsageDescription</key>
//   <string>We need your location to show directions to properties.</string>
// ─────────────────────────────────────────────────────────────────────────────

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

// ── Custom marker painter ─────────────────────────────────────────────────────
final Map<String, BitmapDescriptor> _markerCache = {};

Future<BitmapDescriptor> _buildCustomMarker(
    String category, bool isSelected) async {
  final key = '$category-${isSelected ? 'sel' : 'def'}';
  if (_markerCache.containsKey(key)) return _markerCache[key]!;

  const double W = 120, H = 104;
  const double cx = W / 2, r = 40.0, cy = r, tipH = 24.0;
  final Color    bg   = _categoryColor(category);
  final IconData icon = _categoryIcon(category);

  final recorder = ui.PictureRecorder();
  final canvas   = Canvas(recorder, Rect.fromLTWH(0, 0, W, H));

  // Shadow
  canvas.drawCircle(Offset(cx + 2, cy + 3), r,
      Paint()
        ..color      = Colors.black.withValues(alpha: 0.25)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5));
  // Fill
  canvas.drawCircle(Offset(cx, cy), r, Paint()..color = bg);
  // Border
  canvas.drawCircle(Offset(cx, cy), r,
      Paint()
        ..color       = Colors.white
        ..style       = PaintingStyle.stroke
        ..strokeWidth = isSelected ? 5 : 3);
  // Tip
  final tip = Path()
    ..moveTo(cx - 13, cy + r - 4)
    ..lineTo(cx + 13, cy + r - 4)
    ..lineTo(cx, cy + r + tipH)
    ..close();
  canvas.drawPath(tip, Paint()..color = bg);
  // Icon glyph
  final tp = TextPainter(textDirection: TextDirection.ltr)
    ..text = TextSpan(
      text: String.fromCharCode(icon.codePoint),
      style: TextStyle(
          fontSize: 34, fontFamily: icon.fontFamily,
          package: icon.fontPackage, color: Colors.white),
    )
    ..layout();
  tp.paint(canvas, Offset(cx - tp.width / 2, cy - tp.height / 2));

  final img = await recorder.endRecording().toImage(W.toInt(), H.toInt());
  final bd  = await img.toByteData(format: ui.ImageByteFormat.png);
  final descriptor =
      BitmapDescriptor.bytes(bd!.buffer.asUint8List(), imagePixelRatio: 2.5);
  _markerCache[key] = descriptor;
  return descriptor;
}

// ── Blue "My Location" dot marker ────────────────────────────────────────────
Future<BitmapDescriptor> _buildUserMarker() async {
  const String key = 'user_location';
  if (_markerCache.containsKey(key)) return _markerCache[key]!;

  const double size = 60;
  final recorder = ui.PictureRecorder();
  final canvas   = Canvas(recorder, Rect.fromLTWH(0, 0, size, size));
  const double cx = size / 2, cy = size / 2, r = 18;

  // Outer glow ring
  canvas.drawCircle(Offset(cx, cy), r + 8,
      Paint()..color = const Color(0xFF4285F4).withValues(alpha: 0.2));
  // White border
  canvas.drawCircle(Offset(cx, cy), r + 2,
      Paint()..color = Colors.white);
  // Blue fill
  canvas.drawCircle(Offset(cx, cy), r,
      Paint()..color = const Color(0xFF4285F4));
  // Inner white dot
  canvas.drawCircle(Offset(cx, cy), r * 0.4,
      Paint()..color = Colors.white);

  final img = await recorder.endRecording().toImage(size.toInt(), size.toInt());
  final bd  = await img.toByteData(format: ui.ImageByteFormat.png);
  final descriptor =
      BitmapDescriptor.bytes(bd!.buffer.asUint8List(), imagePixelRatio: 2.5);
  _markerCache[key] = descriptor;
  return descriptor;
}

// ── Category helpers ──────────────────────────────────────────────────────────
Color _categoryColor(String cat) {
  switch (cat) {
    case 'Boarding House': return const Color(0xFFE53935);
    case 'Dormitory':      return const Color(0xFF1E88E5);
    case 'Apartment':      return const Color(0xFF43A047);
    case 'Bedspace':       return const Color(0xFFFB8C00);
    default:               return const Color(0xFF757575);
  }
}

IconData _categoryIcon(String cat) {
  switch (cat) {
    case 'Boarding House': return Icons.home_rounded;
    case 'Dormitory':      return Icons.bedroom_child_rounded;
    case 'Apartment':      return Icons.apartment_rounded;
    case 'Bedspace':       return Icons.bed_rounded;
    default:               return Icons.home_rounded;
  }
}

String _fmtPrice(double p) => p
    .toStringAsFixed(0)
    .replaceAllMapped(
        RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]},');

// ── Polyline decoder (no extra package needed) ────────────────────────────────
List<LatLng> _decodePolyline(String encoded) {
  final List<LatLng> points = [];
  int index = 0, lat = 0, lng = 0;
  while (index < encoded.length) {
    int b, shift = 0, result = 0;
    do {
      b = encoded.codeUnitAt(index++) - 63;
      result |= (b & 0x1f) << shift;
      shift += 5;
    } while (b >= 0x20);
    lat += (result & 1) != 0 ? ~(result >> 1) : (result >> 1);
    shift = 0; result = 0;
    do {
      b = encoded.codeUnitAt(index++) - 63;
      result |= (b & 0x1f) << shift;
      shift += 5;
    } while (b >= 0x20);
    lng += (result & 1) != 0 ? ~(result >> 1) : (result >> 1);
    points.add(LatLng(lat / 1e5, lng / 1e5));
  }
  return points;
}

// ── Route result data class ───────────────────────────────────────────────────
class _RouteInfo {
  final List<LatLng> points;
  final String distance;
  final String duration;
  final String destination;
  const _RouteInfo({
    required this.points,
    required this.distance,
    required this.duration,
    required this.destination,
  });
}

// ── Main view ─────────────────────────────────────────────────────────────────
class _MapScreenView extends StatefulWidget {
  const _MapScreenView();
  @override
  State<_MapScreenView> createState() => _MapScreenViewState();
}

class _MapScreenViewState extends State<_MapScreenView> {
  GoogleMapController?  _mapController;
  final TextEditingController _searchController = TextEditingController();
  final String _apiKey = 'AIzaSyD134P-7TrEIRgx7YnwS9Rx4rBupGB70nM';
  static const LatLng _bacolod = LatLng(10.6765, 122.9509);

  Timer? _debounce;
  List<dynamic> _suggestions  = [];
  bool _showResultsSheet       = false;

  bool _markersReady           = false;
  final Map<String, BitmapDescriptor> _icons = {};

  // ── Location & route state ────────────────────────────────────────────────
  LatLng?    _userLocation;
  _RouteInfo? _activeRoute;     // currently drawn route
  bool        _isLoadingRoute  = false;
  String?     _locationError;

  @override
  void initState() {
    super.initState();
    _preloadIcons();
    _initUserLocation();
  }

  Future<void> _preloadIcons() async {
    const cats = ['Boarding House', 'Dormitory', 'Apartment', 'Bedspace'];
    for (final cat in cats) {
      _icons[cat]          = await _buildCustomMarker(cat, false);
      _icons['${cat}_sel'] = await _buildCustomMarker(cat, true);
    }
    _icons['user'] = await _buildUserMarker();
    if (mounted) setState(() => _markersReady = true);
  }

  // ── Request location permission + get current position ───────────────────
  Future<void> _initUserLocation() async {
    try {
      LocationPermission perm = await Geolocator.checkPermission();
      if (perm == LocationPermission.denied) {
        perm = await Geolocator.requestPermission();
      }
      if (perm == LocationPermission.deniedForever) {
        if (mounted) {
          setState(() => _locationError = 'Location permission denied.');
        }
        return;
      }
      final pos = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);
      if (mounted) {
        setState(() => _userLocation = LatLng(pos.latitude, pos.longitude));
      }
    } catch (e) {
      debugPrint('Location error: $e');
    }
  }

  @override
  void dispose() {
    _mapController?.dispose();
    _searchController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  // ── Build all markers (property pins + user blue dot) ────────────────────
  Set<Marker> _buildMarkers(List<MapMarkerModel> listings, MapViewModel vm) {
    final markers = <Marker>{};

    // ── Property markers ────────────────────────────────────────────────────
    if (_markersReady) {
      for (final item in listings) {
        final sel  = vm.selectedMarker?.id == item.id;
        final icon = _icons[sel ? '${item.category}_sel' : item.category]
            ?? BitmapDescriptor.defaultMarkerWithHue(_hue(item.category));
        markers.add(Marker(
          markerId:   MarkerId(item.id),
          position:   LatLng(item.lat, item.lng),
          icon:       icon,
          zIndex:     sel ? 2 : 1,
          infoWindow: InfoWindow(
            title:   item.title,
            snippet: '₱${_fmtPrice(item.price)}/mo · ${item.category}',
          ),
          onTap: () {
            vm.selectMarker(item);
            setState(() {
              _showResultsSheet = false;
              _activeRoute      = null; // clear route when tapping new pin
            });
            _mapController?.animateCamera(
                CameraUpdate.newLatLngZoom(LatLng(item.lat, item.lng), 17.0));
          },
        ));
      }
    }

    // ── Blue user location dot ───────────────────────────────────────────────
    if (_userLocation != null && _markersReady) {
      final userIcon = _icons['user'];
      markers.add(Marker(
        markerId: const MarkerId('user_location'),
        position: _userLocation!,
        icon:     userIcon ?? BitmapDescriptor.defaultMarkerWithHue(
            BitmapDescriptor.hueBlue),
        zIndex:   10,
        infoWindow: const InfoWindow(title: 'My Location'),
        onTap: () => _mapController?.animateCamera(
            CameraUpdate.newLatLngZoom(_userLocation!, 16.0)),
      ));
    }

    return markers;
  }

  double _hue(String cat) {
    switch (cat) {
      case 'Boarding House': return BitmapDescriptor.hueRed;
      case 'Dormitory':      return BitmapDescriptor.hueBlue;
      case 'Apartment':      return BitmapDescriptor.hueGreen;
      case 'Bedspace':       return BitmapDescriptor.hueOrange;
      default:               return BitmapDescriptor.hueRed;
    }
  }

  // ── Get route from Google Directions API + draw polyline on map ───────────
  Future<void> _getDirectionsOnMap(
      double destLat, double destLng, String title) async {
    if (_userLocation == null) {
      // Try to get location first
      await _initUserLocation();
      if (_userLocation == null) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text(
                'Location unavailable. Please enable location permissions.'),
            backgroundColor: Colors.red[700],
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10)),
          ),
        );
        return;
      }
    }

    setState(() {
      _isLoadingRoute   = true;
      _activeRoute      = null;
      _showResultsSheet = false;
    });

    final origin = '${_userLocation!.latitude},${_userLocation!.longitude}';
    final dest   = '$destLat,$destLng';

    final url = Uri.parse(
      'https://maps.googleapis.com/maps/api/directions/json'
      '?origin=$origin'
      '&destination=$dest'
      '&mode=driving'
      '&key=$_apiKey',
    );

    try {
      final res  = await http.get(url);
      if (!mounted) return;
      final data = json.decode(res.body) as Map<String, dynamic>;

      if (data['status'] == 'OK') {
        final route    = (data['routes'] as List).first as Map<String, dynamic>;
        final leg      = (route['legs']   as List).first as Map<String, dynamic>;
        final encoded  = route['overview_polyline']['points'] as String;
        final points   = _decodePolyline(encoded);
        final distance = leg['distance']['text'] as String;
        final duration = leg['duration']['text'] as String;

        setState(() {
          _activeRoute = _RouteInfo(
            points:      points,
            distance:    distance,
            duration:    duration,
            destination: title,
          );
          _isLoadingRoute = false;
        });

        // Fit camera to show full route
        if (points.isNotEmpty) {
          double minLat = points.first.latitude;
          double maxLat = points.first.latitude;
          double minLng = points.first.longitude;
          double maxLng = points.first.longitude;
          for (final p in points) {
            if (p.latitude  < minLat) minLat = p.latitude;
            if (p.latitude  > maxLat) maxLat = p.latitude;
            if (p.longitude < minLng) minLng = p.longitude;
            if (p.longitude > maxLng) maxLng = p.longitude;
          }
          const pad = 0.01;
          _mapController?.animateCamera(
            CameraUpdate.newLatLngBounds(
              LatLngBounds(
                southwest: LatLng(minLat - pad, minLng - pad),
                northeast: LatLng(maxLat + pad, maxLng + pad),
              ),
              90,
            ),
          );
        }
      } else {
        setState(() => _isLoadingRoute = false);
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Could not get directions: ${data['status']}'),
            backgroundColor: Colors.orange[700],
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10)),
          ),
        );
      }
    } catch (e) {
      setState(() => _isLoadingRoute = false);
      debugPrint('Directions error: $e');
    }
  }

  void _clearRoute() => setState(() => _activeRoute = null);

  // ── Camera pan to property cluster ───────────────────────────────────────
  void _panCameraToMarkers(List<MapMarkerModel> markers) {
    if (markers.isEmpty || _mapController == null) return;
    if (markers.length == 1) {
      _mapController!.animateCamera(CameraUpdate.newLatLngZoom(
          LatLng(markers.first.lat, markers.first.lng), 16.0));
      return;
    }
    double minLat = markers.first.lat, maxLat = markers.first.lat;
    double minLng = markers.first.lng, maxLng = markers.first.lng;
    for (final m in markers) {
      if (m.lat < minLat) minLat = m.lat;
      if (m.lat > maxLat) maxLat = m.lat;
      if (m.lng < minLng) minLng = m.lng;
      if (m.lng > maxLng) maxLng = m.lng;
    }
    const pad = 0.008;
    _mapController!.animateCamera(
      CameraUpdate.newLatLngBounds(
        LatLngBounds(
          southwest: LatLng(minLat - pad, minLng - pad),
          northeast: LatLng(maxLat + pad, maxLng + pad),
        ),
        80,
      ),
    );
  }

  // ── Search ────────────────────────────────────────────────────────────────
  void _onSearchChanged(String query) {
    final vm = context.read<MapViewModel>();
    vm.filterByText(query);
    setState(() => _showResultsSheet = query.trim().isNotEmpty);
    if (query.trim().isNotEmpty) _panCameraToMarkers(vm.mapMarkers);

    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 450), () async {
      if (query.trim().isEmpty) {
        setState(() => _suggestions = []);
        return;
      }
      final url = Uri.parse(
        'https://maps.googleapis.com/maps/api/place/autocomplete/json'
        '?input=${Uri.encodeComponent(query)}&components=country:ph&key=$_apiKey',
      );
      try {
        final res  = await http.get(url);
        if (!mounted) return;
        final data = json.decode(res.body) as Map<String, dynamic>;
        if (data['status'] == 'OK') {
          setState(() =>
              _suggestions = List<dynamic>.from(data['predictions'] ?? []));
        }
      } catch (e) {
        debugPrint('Autocomplete: $e');
      }
    });
  }

  Future<void> _selectSuggestion(String placeId, String description) async {
    final vm = context.read<MapViewModel>();
    setState(() {
      _searchController.text = description;
      _suggestions           = [];
      _showResultsSheet      = true;
    });
    FocusScope.of(context).unfocus();
    vm.filterByText(description);
    _panCameraToMarkers(vm.mapMarkers);
  }

  void _clearSearch() {
    _searchController.clear();
    setState(() {
      _suggestions      = [];
      _showResultsSheet = false;
    });
    context.read<MapViewModel>().clearTextSearch();
    FocusScope.of(context).unfocus();
  }

  void _panTo(MapMarkerModel item, MapViewModel vm) {
    vm.selectMarker(item);
    setState(() => _showResultsSheet = false);
    _mapController?.animateCamera(
        CameraUpdate.newLatLngZoom(LatLng(item.lat, item.lng), 17.0));
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<MapViewModel>(
      builder: (context, vm, _) {
        final markers   = _buildMarkers(vm.mapMarkers, vm);
        final polylines = _activeRoute != null
            ? <Polyline>{
                Polyline(
                  polylineId: const PolylineId('route'),
                  points:     _activeRoute!.points,
                  color:      const Color(0xFF4285F4),
                  width:      5,
                  patterns:   [],
                  jointType:  JointType.round,
                  endCap:     Cap.roundCap,
                  startCap:   Cap.roundCap,
                ),
              }
            : <Polyline>{};

        return Scaffold(
          body: Stack(
            children: [
              // ── Google Map ─────────────────────────────────────────────
              GoogleMap(
                initialCameraPosition:
                    const CameraPosition(target: _bacolod, zoom: 13.0),
                onMapCreated:            (c) => _mapController = c,
                markers:                 markers,
                polylines:               polylines,
                myLocationEnabled:       false, // using custom blue dot
                myLocationButtonEnabled: false,
                zoomControlsEnabled:     false,
                mapToolbarEnabled:       false,
                onTap: (_) {
                  vm.clearSelection();
                  setState(() => _showResultsSheet =
                      _searchController.text.trim().isNotEmpty);
                },
              ),

              const SafetyHeatmapLayer(),

              // ── Loading map ────────────────────────────────────────────
              if (vm.isLoading)
                Container(
                  color: Colors.white.withValues(alpha: 0.6),
                  child: const Center(
                      child: CircularProgressIndicator(color: Colors.black)),
                ),

              // ── Route loading spinner ──────────────────────────────────
              if (_isLoadingRoute)
                Positioned(
                  top: 0, left: 0, right: 0, bottom: 0,
                  child: Container(
                    color: Colors.black.withValues(alpha: 0.25),
                    child: Center(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 24, vertical: 18),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            CircularProgressIndicator(color: Color(0xFF4285F4)),
                            SizedBox(height: 12),
                            Text('Getting directions…',
                                style: TextStyle(
                                    fontWeight: FontWeight.w500)),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),

              // ── Error banner ───────────────────────────────────────────
              if (vm.errorMessage != null)
                Positioned(
                  top: 120, left: 16, right: 16,
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.red.shade50,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.red.shade200),
                    ),
                    child: Row(children: [
                      const Icon(Icons.error_outline,
                          color: Colors.red, size: 18),
                      const SizedBox(width: 8),
                      Expanded(
                          child: Text(vm.errorMessage!,
                              style: const TextStyle(
                                  color: Colors.red, fontSize: 13))),
                      GestureDetector(
                        onTap: vm.refresh,
                        child: const Text('Retry',
                            style: TextStyle(
                                color: Colors.red,
                                fontWeight: FontWeight.bold)),
                      ),
                    ]),
                  ),
                ),

              // ── Search bar + chips ─────────────────────────────────────
              SafeArea(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 12),
                      child: Column(children: [
                        // Search bar
                        Container(
                          height: 50,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(25),
                            boxShadow: [
                              BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.12),
                                  blurRadius: 10,
                                  offset: const Offset(0, 3)),
                            ],
                          ),
                          child: Row(children: [
                            const SizedBox(width: 16),
                            const Icon(Icons.search, color: Colors.blue),
                            const SizedBox(width: 10),
                            Expanded(
                              child: TextField(
                                controller:      _searchController,
                                onChanged:       _onSearchChanged,
                                textInputAction: TextInputAction.search,
                                onSubmitted:     _onSearchChanged,
                                decoration: const InputDecoration(
                                  hintText:
                                      'Search barangay, school or type...',
                                  hintStyle: TextStyle(
                                      color: Colors.grey, fontSize: 14),
                                  border: InputBorder.none,
                                  isDense: true,
                                  contentPadding: EdgeInsets.zero,
                                ),
                              ),
                            ),
                            if (_searchController.text.isNotEmpty)
                              IconButton(
                                icon: const Icon(Icons.clear,
                                    color: Colors.grey, size: 20),
                                onPressed: _clearSearch,
                              ),
                          ]),
                        ),

                        // Autocomplete dropdown
                        if (_suggestions.isNotEmpty)
                          Container(
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
                            constraints: const BoxConstraints(maxHeight: 200),
                            child: ListView.separated(
                              padding:
                                  const EdgeInsets.symmetric(vertical: 6),
                              shrinkWrap: true,
                              itemCount: _suggestions.length,
                              separatorBuilder: (_, __) =>
                                  const Divider(height: 1),
                              itemBuilder: (ctx, i) {
                                final p = _suggestions[i]
                                    as Map<String, dynamic>;
                                return ListTile(
                                  dense: true,
                                  leading: const Icon(
                                      Icons.location_on_outlined,
                                      color: Colors.grey,
                                      size: 18),
                                  title: Text(
                                      p['description'] as String,
                                      style: const TextStyle(fontSize: 13),
                                      maxLines:  2,
                                      overflow:  TextOverflow.ellipsis),
                                  onTap: () => _selectSuggestion(
                                      p['place_id']    as String,
                                      p['description'] as String),
                                );
                              },
                            ),
                          ),
                      ]),
                    ),

                    if (_suggestions.isEmpty && !_showResultsSheet)
                      MapFilterBar(viewModel: vm),
                  ],
                ),
              ),

              // ── Active route info banner ───────────────────────────────
              if (_activeRoute != null)
                Positioned(
                  top: 0, left: 0, right: 0,
                  child: SafeArea(
                    bottom: false,
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 68, 16, 0),
                      child: _RouteBanner(
                        route:       _activeRoute!,
                        onClose:     _clearRoute,
                        userLocation: _userLocation,
                      ),
                    ),
                  ),
                ),

              // ── Listing count badge ────────────────────────────────────
              if (!vm.isLoading && !_showResultsSheet &&
                  _suggestions.isEmpty && _activeRoute == null)
                Positioned(
                  top: 132, left: 0, right: 0,
                  child: Center(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.72),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        vm.mapMarkers.isEmpty
                            ? 'No listings in this area'
                            : '${vm.mapMarkers.length} '
                              'listing${vm.mapMarkers.length == 1 ? '' : 's'} on map',
                        style: const TextStyle(
                            color: Colors.white, fontSize: 12),
                      ),
                    ),
                  ),
                ),

              // ── FABs ──────────────────────────────────────────────────
              if (vm.selectedMarker == null && !_showResultsSheet)
                Positioned(
                  bottom: _activeRoute != null ? 16 : 110,
                  right: 16,
                  child: Column(children: [
                    FloatingActionButton(
                      heroTag:         'map_refresh',
                      mini:            true,
                      backgroundColor: Colors.white,
                      onPressed:       vm.refresh,
                      child: const Icon(Icons.refresh,
                          color: Colors.black87, size: 20),
                    ),
                    const SizedBox(height: 10),
                    // Re-center to user location
                    FloatingActionButton(
                      heroTag:         'map_myLocation',
                      backgroundColor: Colors.white,
                      onPressed: () {
                        if (_userLocation != null) {
                          _mapController?.animateCamera(
                              CameraUpdate.newLatLngZoom(
                                  _userLocation!, 16.0));
                        } else {
                          _initUserLocation();
                        }
                      },
                      child: const Icon(Icons.my_location,
                          color: Color(0xFF4285F4)),
                    ),
                    const SizedBox(height: 10),
                    FloatingActionButton(
                      heroTag:         'map_recenter',
                      mini:            true,
                      backgroundColor: Colors.white,
                      onPressed: () => _mapController?.animateCamera(
                          CameraUpdate.newLatLngZoom(_bacolod, 13.0)),
                      child: const Icon(Icons.location_city,
                          color: Colors.black54, size: 20),
                    ),
                  ]),
                ),

              // ── Legend (when idle) ─────────────────────────────────────
              if (!vm.isLoading && vm.mapMarkers.isNotEmpty &&
                  vm.selectedMarker == null && !_showResultsSheet &&
                  _suggestions.isEmpty && _activeRoute == null)
                Positioned(bottom: 20, left: 16, child: _buildLegend()),

              // ── Single-pin card ────────────────────────────────────────
              if (vm.selectedMarker != null && !_showResultsSheet &&
                  _activeRoute == null)
                Positioned(
                  bottom: 0, left: 0, right: 0,
                  child: _PropertyCard(
                    marker:        vm.selectedMarker!,
                    onClose:       vm.clearSelection,
                    onDirections:  (lat, lng, title) =>
                        _getDirectionsOnMap(lat, lng, title),
                    userLocation:  _userLocation,
                  ),
                ),

              // ── Search results half-sheet ──────────────────────────────
              if (_showResultsSheet && _suggestions.isEmpty)
                _ResultsSheet(
                  allMarkers:  vm.mapMarkers,
                  listMarkers: vm.listMarkers,
                  searchQuery: _searchController.text,
                  onTapItem:  (item) => _panTo(item, vm),
                  onClose:     _clearSearch,
                  onDirections: (lat, lng, title) =>
                      _getDirectionsOnMap(lat, lng, title),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildLegend() {
    const items = [
      ('Boarding House', Color(0xFFE53935)),
      ('Dormitory',      Color(0xFF1E88E5)),
      ('Apartment',      Color(0xFF43A047)),
      ('Bedspace',       Color(0xFFFB8C00)),
    ];
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.93),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 8,
              offset: const Offset(0, 2)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ...items.map((item) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 3),
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                Container(
                    width: 12, height: 12,
                    decoration: BoxDecoration(
                        color: item.$2, shape: BoxShape.circle)),
                const SizedBox(width: 8),
                Text(item.$1, style: const TextStyle(fontSize: 11)),
              ]),
            );
          }),
          // My location indicator
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 3),
            child: Row(mainAxisSize: MainAxisSize.min, children: [
              Container(
                  width: 12, height: 12,
                  decoration: const BoxDecoration(
                      color: Color(0xFF4285F4), shape: BoxShape.circle)),
              const SizedBox(width: 8),
              const Text('My Location',
                  style: TextStyle(fontSize: 11)),
            ]),
          ),
        ],
      ),
    );
  }
}

// ── Route info banner (shown at top of screen while route is active) ──────────
class _RouteBanner extends StatelessWidget {
  final _RouteInfo  route;
  final VoidCallback onClose;
  final LatLng?     userLocation;

  const _RouteBanner({
    required this.route,
    required this.onClose,
    this.userLocation,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF4285F4),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.2),
              blurRadius: 10,
              offset: const Offset(0, 4)),
        ],
      ),
      child: Row(children: [
        const Icon(Icons.directions, color: Colors.white, size: 28),
        const SizedBox(width: 12),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(
              route.destination,
              style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 14),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 2),
            Row(children: [
              const Icon(Icons.access_time, color: Colors.white70, size: 13),
              const SizedBox(width: 4),
              Text(route.duration,
                  style: const TextStyle(
                      color: Colors.white70, fontSize: 12)),
              const SizedBox(width: 12),
              const Icon(Icons.straighten, color: Colors.white70, size: 13),
              const SizedBox(width: 4),
              Text(route.distance,
                  style: const TextStyle(
                      color: Colors.white70, fontSize: 12)),
            ]),
          ]),
        ),
        // Close route
        GestureDetector(
          onTap: onClose,
          child: Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                shape: BoxShape.circle),
            child: const Icon(Icons.close, color: Colors.white, size: 18),
          ),
        ),
      ]),
    );
  }
}

// ── Search results half-sheet ─────────────────────────────────────────────────
class _ResultsSheet extends StatefulWidget {
  final List<MapMarkerModel> allMarkers;
  final List<MapMarkerModel> listMarkers;
  final String searchQuery;
  final void Function(MapMarkerModel) onTapItem;
  final VoidCallback onClose;
  final void Function(double lat, double lng, String title) onDirections;

  const _ResultsSheet({
    required this.allMarkers,
    required this.listMarkers,
    required this.searchQuery,
    required this.onTapItem,
    required this.onClose,
    required this.onDirections,
  });

  @override
  State<_ResultsSheet> createState() => _ResultsSheetState();
}

class _ResultsSheetState extends State<_ResultsSheet> {
  String _sheetCategory = 'All';

  static const List<String> _cats = [
    'All', 'Boarding House', 'Dormitory', 'Apartment', 'Bedspace',
  ];

  List<MapMarkerModel> get _displayList {
    final base = widget.listMarkers.isNotEmpty
        ? widget.listMarkers
        : widget.allMarkers;
    if (_sheetCategory == 'All') return base;
    return base.where((m) => m.category == _sheetCategory).toList();
  }

  @override
  Widget build(BuildContext context) {
    final list = _displayList;

    return DraggableScrollableSheet(
      initialChildSize: 0.50,
      minChildSize:     0.25,
      maxChildSize:     0.88,
      snap:             true,
      snapSizes:        const [0.25, 0.50, 0.88],
      builder: (context, scroll) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
            boxShadow: [
              BoxShadow(
                  color: Colors.black12,
                  blurRadius: 20,
                  offset: Offset(0, -4)),
            ],
          ),
          child: Column(children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
              child: Column(children: [
                // Drag handle
                Container(
                    width: 40, height: 4,
                    decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(2))),
                const SizedBox(height: 12),

                // Header row
                Row(children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${list.length} propert${list.length == 1 ? 'y' : 'ies'} in Bacolod City',
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                        if (widget.searchQuery.trim().isNotEmpty)
                          Text(
                            widget.listMarkers.isEmpty
                                ? 'Showing all — no exact match for "${widget.searchQuery}"'
                                : 'Results for "${widget.searchQuery}"',
                            style: TextStyle(
                                fontSize: 12,
                                color: widget.listMarkers.isEmpty
                                    ? Colors.orange[700]
                                    : Colors.grey[600]),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                      ],
                    ),
                  ),
                  GestureDetector(
                    onTap: widget.onClose,
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                          color: Colors.grey[100],
                          shape: BoxShape.circle),
                      child: const Icon(Icons.close,
                          size: 18, color: Colors.black54),
                    ),
                  ),
                ]),

                const SizedBox(height: 12),

                // ── Category filter chips ─────────────────────────────
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: _cats.map((cat) {
                      final sel = _sheetCategory == cat;
                      return GestureDetector(
                        onTap: () => setState(() => _sheetCategory = cat),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 180),
                          margin: const EdgeInsets.only(right: 8),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 8),
                          decoration: BoxDecoration(
                            color: sel
                                ? (cat == 'All'
                                    ? Colors.black87
                                    : _categoryColor(cat))
                                : Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: sel
                                  ? Colors.transparent
                                  : Colors.grey.shade300,
                            ),
                            boxShadow: [
                              BoxShadow(
                                  color: Colors.black.withValues(
                                      alpha: sel ? 0.12 : 0.04),
                                  blurRadius: 4,
                                  offset: const Offset(0, 2)),
                            ],
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                cat == 'All'
                                    ? Icons.grid_view_rounded
                                    : _categoryIcon(cat),
                                size:  14,
                                color: sel ? Colors.white : Colors.black54,
                              ),
                              const SizedBox(width: 5),
                              Text(cat,
                                  style: TextStyle(
                                    fontSize:   12,
                                    fontWeight: sel
                                        ? FontWeight.bold
                                        : FontWeight.w500,
                                    color: sel ? Colors.white : Colors.black87,
                                  )),
                              if (sel) ...[
                                const SizedBox(width: 5),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 5, vertical: 1),
                                  decoration: BoxDecoration(
                                    color: Colors.white
                                        .withValues(alpha: 0.3),
                                    borderRadius:
                                        BorderRadius.circular(10),
                                  ),
                                  child: Text('${list.length}',
                                      style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 10,
                                          fontWeight: FontWeight.bold)),
                                ),
                              ],
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ]),
            ),

            const SizedBox(height: 8),
            const Divider(height: 1),

            Expanded(
              child: list.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.search_off_rounded,
                              size: 52, color: Colors.grey[300]),
                          const SizedBox(height: 10),
                          Text(
                            _sheetCategory == 'All'
                                ? 'No listings found'
                                : 'No $_sheetCategory found',
                            style: TextStyle(
                                color: Colors.grey[500],
                                fontWeight: FontWeight.w500),
                          ),
                        ],
                      ),
                    )
                  : ListView.separated(
                      controller:       scroll,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      itemCount:        list.length,
                      separatorBuilder: (_, __) => const Divider(height: 1),
                      itemBuilder: (ctx, i) => _ListCard(
                        marker:      list[i],
                        onTap:       () => widget.onTapItem(list[i]),
                        onDirections: widget.onDirections,
                      ),
                    ),
            ),
          ]),
        );
      },
    );
  }
}

// ── List card ─────────────────────────────────────────────────────────────────
class _ListCard extends StatelessWidget {
  final MapMarkerModel marker;
  final VoidCallback   onTap;
  final void Function(double lat, double lng, String title) onDirections;

  const _ListCard({
    required this.marker,
    required this.onTap,
    required this.onDirections,
  });

  @override
  Widget build(BuildContext context) {
    final cc = _categoryColor(marker.category);
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: marker.imageUrl.isNotEmpty
                ? Image.network(marker.imageUrl,
                    width: 82, height: 82, fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => _thumb())
                : _thumb(),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(marker.title,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 14),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 7, vertical: 2),
                  decoration: BoxDecoration(
                    color:  cc.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(5),
                    border: Border.all(color: cc.withValues(alpha: 0.35)),
                  ),
                  child: Text(marker.category,
                      style: TextStyle(
                          fontSize: 10, color: cc,
                          fontWeight: FontWeight.w600)),
                ),
                const SizedBox(height: 5),
                Row(children: [
                  const Icon(Icons.location_on_outlined,
                      size: 11, color: Colors.grey),
                  const SizedBox(width: 2),
                  Expanded(
                    child: Text(marker.location,
                        style: const TextStyle(
                            fontSize: 11, color: Colors.grey),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis),
                  ),
                ]),
                const SizedBox(height: 6),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                      Text('₱${_fmtPrice(marker.price)}/mo',
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 14)),
                      if (marker.dailyPrice != null &&
                          marker.dailyPrice! > 0)
                        Text('₱${_fmtPrice(marker.dailyPrice!)}/day',
                            style: TextStyle(
                                fontSize: 10, color: Colors.grey[600])),
                    ]),
                    Row(children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 7, vertical: 2),
                        decoration: BoxDecoration(
                          color: marker.availableSlots > 0
                              ? Colors.green.shade50
                              : Colors.red.shade50,
                          borderRadius: BorderRadius.circular(5),
                        ),
                        child: Text(
                          marker.availableSlots > 0
                              ? '${marker.availableSlots} slots'
                              : 'Full',
                          style: TextStyle(
                              fontSize: 10,
                              color: marker.availableSlots > 0
                                  ? Colors.green.shade700
                                  : Colors.red,
                              fontWeight: FontWeight.w600),
                        ),
                      ),
                      const SizedBox(width: 8),
                      // ✅ In-app directions button
                      GestureDetector(
                        onTap: () => onDirections(
                            marker.lat, marker.lng, marker.title),
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: const Color(0xFF4285F4).withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                                color: const Color(0xFF4285F4).withValues(alpha: 0.4)),
                          ),
                          child: const Icon(Icons.directions,
                              size: 16, color: Color(0xFF4285F4)),
                        ),
                      ),
                    ]),
                  ],
                ),
              ],
            ),
          ),
          const Icon(Icons.chevron_right, color: Colors.grey, size: 20),
        ]),
      ),
    );
  }

  Widget _thumb() => Container(
        width: 82, height: 82,
        decoration: BoxDecoration(
            color: Colors.grey[200],
            borderRadius: BorderRadius.circular(10)),
        child: const Icon(Icons.home_rounded, color: Colors.grey, size: 28));
}

// ── Single-pin bottom card ────────────────────────────────────────────────────
class _PropertyCard extends StatelessWidget {
  final MapMarkerModel marker;
  final VoidCallback   onClose;
  final LatLng?        userLocation;
  final void Function(double lat, double lng, String title) onDirections;

  const _PropertyCard({
    required this.marker,
    required this.onClose,
    required this.onDirections,
    this.userLocation,
  });

  @override
  Widget build(BuildContext context) {
    final cc = _categoryColor(marker.category);
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 20, offset: Offset(0, -4)),
        ],
      ),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Padding(
          padding: const EdgeInsets.only(top: 12, bottom: 4),
          child: Container(
              width: 40, height: 4,
              decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2))),
        ),

        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
          child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: marker.imageUrl.isNotEmpty
                  ? Image.network(marker.imageUrl,
                      width: 90, height: 90, fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => _ph())
                  : _ph(),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(children: [
                    Expanded(
                      child: Text(marker.title,
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 15),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis),
                    ),
                    GestureDetector(
                        onTap: onClose,
                        child: const Icon(Icons.close,
                            size: 20, color: Colors.grey)),
                  ]),
                  const SizedBox(height: 5),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color:  cc.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: cc.withValues(alpha: 0.4)),
                    ),
                    child: Text(marker.category,
                        style: TextStyle(
                            fontSize: 11, color: cc,
                            fontWeight: FontWeight.w600)),
                  ),
                  const SizedBox(height: 6),
                  Row(children: [
                    const Icon(Icons.location_on_outlined,
                        size: 12, color: Colors.grey),
                    const SizedBox(width: 3),
                    Expanded(
                      child: Text(marker.location,
                          style: const TextStyle(
                              fontSize: 12, color: Colors.grey),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis),
                    ),
                  ]),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                        Text('₱${_fmtPrice(marker.price)}/mo',
                            style: const TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 16)),
                        if (marker.dailyPrice != null &&
                            marker.dailyPrice! > 0)
                          Text('₱${_fmtPrice(marker.dailyPrice!)}/day',
                              style: TextStyle(
                                  fontSize: 11, color: Colors.grey[600])),
                      ]),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: marker.availableSlots > 0
                              ? Colors.green.shade50
                              : Colors.red.shade50,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          marker.availableSlots > 0
                              ? '${marker.availableSlots} slots'
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
          ]),
        ),

        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
          child: Row(children: [
            // ✅ In-app directions button
            Expanded(
              flex: 2,
              child: SizedBox(
                height: 46,
                child: ElevatedButton.icon(
                  onPressed: () => onDirections(
                      marker.lat, marker.lng, marker.title),
                  icon: const Icon(Icons.directions,
                      size: 18, color: Colors.white),
                  label: const Text('Directions',
                      style: TextStyle(
                          color:      Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize:   14)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4285F4),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    elevation: 0,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              flex: 3,
              child: SizedBox(
                height: 46,
                child: ElevatedButton(
                  onPressed: () {
                    context.push(
                      '/property/${marker.id}',
                      extra: PropertyModel(
                        id:               marker.id,
                        title:            marker.title,
                        location:         marker.location,
                        price:            marker.price,
                        dailyPrice:       marker.dailyPrice,
                        imageUrl:         marker.imageUrl,
                        imageUrls:        [marker.imageUrl],
                        category:         marker.category,
                        availableSlots:   marker.availableSlots,
                        tenantPreference: marker.tenantPreference,
                        amenities:        marker.amenities,
                        highlights:       marker.highlights,
                        isLocationPinned: true,
                        latitude:         marker.lat,
                        longitude:        marker.lng,
                        description:      marker.description,
                        policies:         marker.policies,
                        hostId:           marker.hostId,
                      ),
                    );
                    onClose();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    elevation: 0,
                  ),
                  child: const Text('View Details',
                      style: TextStyle(
                          color:      Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize:   14)),
                ),
              ),
            ),
          ]),
        ),
      ]),
    );
  }

  Widget _ph() => Container(
        width: 90, height: 90,
        decoration: BoxDecoration(
            color: Colors.grey[200],
            borderRadius: BorderRadius.circular(12)),
        child: const Icon(Icons.home_rounded, color: Colors.grey, size: 32));
}
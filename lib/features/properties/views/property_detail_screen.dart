import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../data/models/property_model.dart';
import '../../bookings/views/booking_screen.dart';

// ── Simple model to hold fetched host data ────────────────────────────────────
class _HostProfile {
  final String name;
  final String? completeName; // e.g. "Juan dela Cruz" built from firstName+lastName
  final String? photoUrl;

  const _HostProfile({required this.name, this.completeName, this.photoUrl});
}

class PropertyDetailScreen extends StatefulWidget {
  final PropertyModel property;

  const PropertyDetailScreen({super.key, required this.property});

  @override
  State<PropertyDetailScreen> createState() => _PropertyDetailScreenState();
}

class _PropertyDetailScreenState extends State<PropertyDetailScreen> {
  // ── Host profile state ────────────────────────────────────────────────────
  _HostProfile? _hostProfile;
  bool _hostLoading = true;

  // ── Google Map ────────────────────────────────────────────────────────────
  GoogleMapController? _mapController;
  bool _mapExpanded = false;

  // Bacolod City fallback coordinates
  static const double _defaultLat = 10.6840;
  static const double _defaultLng = 122.9560;

  // ── Location tab state ────────────────────────────────────────────────────
  int _selectedLocationTab = 0;
  final List<String> _locationTabs = ['Landmarks', 'Transport', 'Essentials'];

  // ── Static nearby data for Bacolod City (tab-indexed) ─────────────────────
  static const List<List<Map<String, dynamic>>> _nearbyData = [
    // Landmarks
    [
      {'icon': Icons.account_balance, 'name': 'Barangay Sang Virgen Chapel', 'dist': '1.38 km'},
      {'icon': Icons.park, 'name': 'Capitol Lagoon Park', 'dist': '1.94 km'},
      {'icon': Icons.nature, 'name': 'Negros Forests & Ecological Foundation', 'dist': '3.53 km'},
      {'icon': Icons.museum, 'name': 'Dizon-Ramos Museum', 'dist': '3.70 km'},
      {'icon': Icons.account_balance_wallet, 'name': 'New Government Center', 'dist': '4.09 km'},
    ],
    // Transport
    [
      {'icon': Icons.directions_bus, 'name': 'Libertad Jeepney Terminal', 'dist': '0.85 km'},
      {'icon': Icons.local_taxi, 'name': 'Bacolod Taxi Stand – Lacson', 'dist': '1.20 km'},
      {'icon': Icons.motorcycle, 'name': 'Habal-Habal Terminal (Mansilingan)', 'dist': '0.40 km'},
      {'icon': Icons.flight, 'name': 'Bacolod-Silay International Airport', 'dist': '14.5 km'},
      {'icon': Icons.directions_boat, 'name': 'Banago Wharf / Port', 'dist': '3.80 km'},
    ],
    // Essentials
    [
      {'icon': Icons.local_grocery_store, 'name': 'SM City Bacolod', 'dist': '3.10 km'},
      {'icon': Icons.local_hospital, 'name': 'Bacolod Queen of Mercy Hospital', 'dist': '2.50 km'},
      {'icon': Icons.school, 'name': 'University of St. La Salle', 'dist': '2.30 km'},
      {'icon': Icons.local_pharmacy, 'name': 'Mercury Drug – Lacson', 'dist': '1.60 km'},
      {'icon': Icons.restaurant, 'name': 'Manokan Country (Food Strip)', 'dist': '4.00 km'},
    ],
  ];

  @override
  void initState() {
    super.initState();
    _fetchHostProfile();
  }

  // ── Fetch host document from Firestore ────────────────────────────────────
  // Assumes hosts are stored in a top-level "users" collection.
  // Adjust the collection name / field names to match your schema.
  Future<void> _fetchHostProfile() async {
    final hostId = widget.property.hostId;
    if (hostId.isEmpty) {
      setState(() {
        _hostProfile = const _HostProfile(name: 'Property Owner');
        _hostLoading = false;
      });
      return;
    }

    try {
      final doc = await FirebaseFirestore.instance
          .collection('users')   // ← change if your collection is named differently
          .doc(hostId)
          .get();

      if (doc.exists) {
        final data = doc.data()!;

        // Display / short name
        final name = (data['name'] as String?)?.trim() ??
            (data['displayName'] as String?)?.trim() ??
            (data['fullName'] as String?)?.trim() ??
            'Property Owner';

        // Complete name — try a dedicated field first, then build from parts
        final firstName = (data['firstName'] as String?)?.trim() ?? '';
        final middleName = (data['middleName'] as String?)?.trim() ?? '';
        final lastName = (data['lastName'] as String?)?.trim() ?? '';

        String? completeName = (data['completeName'] as String?)?.trim() ??
            (data['fullName'] as String?)?.trim();

        if ((completeName == null || completeName.isEmpty) &&
            (firstName.isNotEmpty || lastName.isNotEmpty)) {
          // Build "First Middle Last" — omit middle if empty
          completeName = [firstName, middleName, lastName]
              .where((s) => s.isNotEmpty)
              .join(' ');
        }

        // If completeName is the same as name, no need to show it twice
        if (completeName == name) completeName = null;

        // Optional profile photo
        final photoUrl = data['photoUrl'] as String? ??
            data['profileImageUrl'] as String? ??
            data['avatarUrl'] as String?;

        setState(() {
          _hostProfile = _HostProfile(
              name: name, completeName: completeName, photoUrl: photoUrl);
          _hostLoading = false;
        });
      } else {
        setState(() {
          _hostProfile = const _HostProfile(name: 'Property Owner');
          _hostLoading = false;
        });
      }
    } catch (_) {
      setState(() {
        _hostProfile = const _HostProfile(name: 'Property Owner');
        _hostLoading = false;
      });
    }
  }

  // ── Map highlight label → icon ─────────────────────────────────────────────
  IconData _highlightIcon(String label) {
    const map = {
      'Hygiene Plus': Icons.health_and_safety,
      'Sparkling Clean': Icons.cleaning_services,
      'Top Value': Icons.verified,
      '24-Hour Check-in': Icons.access_time,
      'Pet Friendly': Icons.pets,
      'Near School': Icons.school,
      'Near Market': Icons.storefront,
      'With Parking': Icons.local_parking,
      'With Security Guard': Icons.security,
      'Bills Included': Icons.receipt_long,
    };
    final lower = label.toLowerCase();
    if (lower.contains('clean')) return Icons.cleaning_services;
    if (lower.contains('wifi') || lower.contains('wi-fi')) return Icons.wifi;
    if (lower.contains('park')) return Icons.local_parking;
    if (lower.contains('school')) return Icons.school;
    if (lower.contains('check')) return Icons.access_time;
    if (lower.contains('security') || lower.contains('guard')) return Icons.security;
    if (lower.contains('value')) return Icons.verified;
    if (lower.contains('hygiene')) return Icons.health_and_safety;
    if (lower.contains('pet')) return Icons.pets;
    if (lower.contains('bill') || lower.contains('included')) return Icons.receipt_long;
    return map[label] ?? Icons.star_outline;
  }

  IconData _categoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'apartment':
        return Icons.apartment;
      case 'dormitory':
      case 'dorm':
        return Icons.bedroom_child;
      case 'bedspace':
        return Icons.bed;
      case 'boarding house':
      default:
        return Icons.home;
    }
  }

  @override
  Widget build(BuildContext context) {
    final property = widget.property;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
        titleSpacing: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            children: [
              const Icon(Icons.search, size: 18, color: Colors.black54),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      property.title,
                      style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      property.category,
                      style: const TextStyle(fontSize: 11, color: Colors.black54),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        actions: [
          IconButton(icon: const Icon(Icons.share_outlined), onPressed: () {}),
          IconButton(icon: const Icon(Icons.favorite_border), onPressed: () {}),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── 1. HEADER IMAGE ──────────────────────────────────────────────
            Stack(
              children: [
                property.imageUrl.isNotEmpty
                    ? Image.network(
                        property.imageUrl,
                        height: 250,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => _imageFallback(),
                      )
                    : _imageFallback(),
                Positioned(
                  bottom: 16,
                  right: 16,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.6),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '1/${property.imageUrls.isNotEmpty ? property.imageUrls.length : 1}',
                      style: const TextStyle(
                          color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),

            // ── 2. TITLE, CATEGORY & RATING ──────────────────────────────────
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          property.title,
                          style: const TextStyle(
                              fontSize: 22, fontWeight: FontWeight.bold),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.red.shade200),
                        ),
                        child: const Icon(Icons.favorite_border,
                            color: Colors.red, size: 20),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      ...List.generate(5,
                          (_) => const Icon(Icons.star, color: Colors.deepOrange, size: 16)),
                      const SizedBox(width: 8),
                      Container(width: 1, height: 12, color: Colors.grey),
                      const SizedBox(width: 8),
                      Icon(_categoryIcon(property.category),
                          color: Colors.grey, size: 16),
                      const SizedBox(width: 4),
                      Text(
                        property.category,
                        style: TextStyle(color: Colors.grey[700], fontSize: 13),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.blue[50],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(Icons.map_outlined,
                            color: Colors.blue, size: 24),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              property.location,
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 15),
                            ),
                            Text(
                              'Bacolod City, Negros Occidental',
                              style:
                                  TextStyle(color: Colors.grey[600], fontSize: 13),
                            ),
                          ],
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          const Text('9.2 Exceptional',
                              style: TextStyle(
                                  color: Colors.blue,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15)),
                          Text('57 reviews',
                              style:
                                  TextStyle(color: Colors.grey[600], fontSize: 13)),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),

            _buildSectionDivider(),

            // ── 3. HIGHLIGHTS ─────────────────────────────────────────────────
            if (property.highlights.isNotEmpty) ...[
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Highlights',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 16),
                    ...property.highlights.map(
                      (h) => _buildHighlightItem(_highlightIcon(h), h),
                    ),
                  ],
                ),
              ),
              _buildSectionDivider(),
            ],

            // ── 4. TOP AMENITIES ──────────────────────────────────────────────
            if (property.amenities.isNotEmpty) ...[
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Top Amenities',
                            style: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold)),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Wrap(
                      spacing: 16,
                      runSpacing: 12,
                      children: property.amenities
                          .map((a) => _buildAmenityItem(_amenityIcon(a), a))
                          .toList(),
                    ),
                  ],
                ),
              ),
              _buildSectionDivider(),
            ],

            // ── 5. AVAILABILITY & SLOTS ───────────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Availability',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      _buildInfoChip(
                        icon: Icons.people_outline,
                        label: 'Accepts',
                        value: property.tenantPreference,
                        color: Colors.blue,
                      ),
                      const SizedBox(width: 12),
                      _buildInfoChip(
                        icon: Icons.bed_outlined,
                        label: 'Available Slots',
                        value: '${property.availableSlots}',
                        color: property.availableSlots > 0
                            ? Colors.green
                            : Colors.red,
                      ),
                    ],
                  ),
                ],
              ),
            ),

            _buildSectionDivider(),

            // ── 6. LOCATION & SURROUNDINGS ────────────────────────────────────
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Location',
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold)),
                      GestureDetector(
                        onTap: () =>
                            setState(() => _mapExpanded = !_mapExpanded),
                        child: Text(
                          _mapExpanded ? 'Collapse' : 'See map',
                          style: TextStyle(
                              color: Colors.blue[700],
                              fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // ── Location score + address card ──────────────────────
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 12),
                    decoration: BoxDecoration(
                      color: Colors.grey[50],
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey.shade200),
                    ),
                    child: Row(children: [
                      Container(
                        width: 40, height: 40,
                        decoration: BoxDecoration(
                          color: Colors.blue.shade50,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(Icons.location_on,
                            color: Colors.blue.shade700, size: 22),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('8.8 Excellent',
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 15,
                                    color: Colors.blue)),
                            const Text('Location rating score',
                                style: TextStyle(
                                    fontSize: 11, color: Colors.grey)),
                            const SizedBox(height: 4),
                            Text(
                              property.location,
                              style: const TextStyle(
                                  fontSize: 13, color: Colors.black87),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ]),
                  ),
                  const SizedBox(height: 12),

                  // ── Interactive Google Map ─────────────────────────────
                  _buildPropertyMap(property),
                  const SizedBox(height: 8),

                  // Tabs
                  Row(
                    children: List.generate(_locationTabs.length, (i) {
                      return Expanded(
                        child: GestureDetector(
                          onTap: () =>
                              setState(() => _selectedLocationTab = i),
                          child: Column(
                            children: [
                              Text(
                                _locationTabs[i],
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: _selectedLocationTab == i
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                                  color: _selectedLocationTab == i
                                      ? Colors.blue[700]
                                      : Colors.grey[600],
                                ),
                              ),
                              const SizedBox(height: 6),
                              AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                height: 2,
                                color: _selectedLocationTab == i
                                    ? Colors.blue[700]
                                    : Colors.transparent,
                              ),
                            ],
                          ),
                        ),
                      );
                    }),
                  ),
                  Divider(height: 1, color: Colors.grey.shade200),
                  const SizedBox(height: 8),

                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 220),
                    child: Column(
                      key: ValueKey(_selectedLocationTab),
                      children: [
                        ..._nearbyData[_selectedLocationTab].map(
                          (place) => _buildNearbyPlaceItem(
                            place['icon'] as IconData,
                            place['name'] as String,
                            place['dist'] as String,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: GestureDetector(
                            onTap: () {},
                            child: Text(
                              'See all',
                              style: TextStyle(
                                  color: Colors.blue[700],
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            _buildSectionDivider(),

            // ── 7. PROPERTY DESCRIPTION ───────────────────────────────────────
            if (property.description.isNotEmpty) ...[
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Property Description',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 12),
                    _ExpandableText(text: property.description),
                  ],
                ),
              ),
              _buildSectionDivider(),
            ],

            // ── 8. POLICIES & RULES ───────────────────────────────────────────
            if (property.policies.isNotEmpty) ...[
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Policies & Rules',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 12),
                    _ExpandableText(text: property.policies),
                  ],
                ),
              ),
              _buildSectionDivider(),
            ],

            // ── 9. HOST PROFILE (dynamic) ─────────────────────────────────────
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Host Profile',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.grey[50],
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: _hostLoading
                        // ── Loading skeleton ──────────────────────────────────
                        ? const Center(
                            child: Padding(
                              padding: EdgeInsets.symmetric(vertical: 16),
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                          )
                        // ── Loaded host card ──────────────────────────────────
                        : Column(
                            children: [
                              // Avatar: real photo if available, else fallback
                              CircleAvatar(
                                radius: 40,
                                backgroundColor: Colors.grey.shade300,
                                backgroundImage:
                                    (_hostProfile?.photoUrl?.isNotEmpty ?? false)
                                        ? NetworkImage(_hostProfile!.photoUrl!)
                                        : null,
                                child:
                                    (_hostProfile?.photoUrl?.isNotEmpty ?? false)
                                        ? null
                                        : const Icon(Icons.person,
                                            size: 40, color: Colors.white),
                              ),
                              const SizedBox(height: 12),

                              // ── Host name (fetched from Firestore) ──────────
                              Text(
                                _hostProfile?.name ?? 'Property Owner',
                                style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold),
                              ),

                              // ── Complete name (shown only when available) ───
                              if ((_hostProfile?.completeName?.isNotEmpty ??
                                  false)) ...[
                                const SizedBox(height: 3),
                                Text(
                                  _hostProfile!.completeName!,
                                  style: TextStyle(
                                      fontSize: 13,
                                      color: Colors.grey[600]),
                                ),
                              ],
                              const SizedBox(height: 8),

                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: const [
                                  Icon(Icons.emoji_events,
                                      color: Colors.green, size: 18),
                                  SizedBox(width: 4),
                                  Text('9.5 Exceptional',
                                      style: TextStyle(
                                          color: Colors.green,
                                          fontWeight: FontWeight.bold)),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(Icons.verified,
                                      color: Colors.green, size: 16),
                                  const SizedBox(width: 4),
                                  Text('Verified Host',
                                      style: TextStyle(
                                          color: Colors.grey[700],
                                          fontSize: 13)),
                                ],
                              ),
                              const SizedBox(height: 20),
                              SizedBox(
                                width: double.infinity,
                                child: ElevatedButton.icon(
                                  onPressed: () {},
                                  icon: const Icon(Icons.chat, size: 20),
                                  label: const Text('Contact Host',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 15)),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.blue[700],
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 12),
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(8)),
                                    elevation: 0,
                                  ),
                                ),
                              ),
                            ],
                          ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),
          ],
        ),
      ),

      // ── BOTTOM BAR ────────────────────────────────────────────────────────
      bottomNavigationBar: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border(top: BorderSide(color: Colors.grey.shade200)),
        ),
        child: SafeArea(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      Text(
                        '₱${_formatPrice(property.price)}',
                        style: const TextStyle(
                            color: Colors.black87,
                            fontWeight: FontWeight.bold,
                            fontSize: 20),
                      ),
                      Text(' / month',
                          style: TextStyle(
                              color: Colors.grey[600], fontSize: 13)),
                    ],
                  ),
                  if (property.dailyPrice != null &&
                      property.dailyPrice! > 0) ...[
                    const SizedBox(height: 2),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      textBaseline: TextBaseline.alphabetic,
                      children: [
                        Text(
                          '₱${_formatPrice(property.dailyPrice!)}',
                          style: TextStyle(
                              color: Colors.grey[700],
                              fontWeight: FontWeight.w600,
                              fontSize: 14),
                        ),
                        Text(' / day',
                            style: TextStyle(
                                color: Colors.grey[500], fontSize: 12)),
                      ],
                    ),
                  ],
                ],
              ),
              ElevatedButton(
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => BookingScreen(property: property),
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue[700],
                  padding: const EdgeInsets.symmetric(
                      horizontal: 24, vertical: 12),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8)),
                ),
                child: const Text(
                  'Book Now',
                  style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Helpers ────────────────────────────────────────────────────────────────

  // ── dispose ───────────────────────────────────────────────────────────────
  @override
  void dispose() {
    _mapController?.dispose();
    super.dispose();
  }

  // ── Interactive property map ───────────────────────────────────────────────
  Widget _buildPropertyMap(PropertyModel property) {
    final double lat = property.latitude ?? _defaultLat;
    final double lng = property.longitude ?? _defaultLng;
    final bool hasPinnedLocation = property.isLocationPinned &&
        property.latitude != null &&
        property.longitude != null;

    final LatLng position = LatLng(lat, lng);

    final Set<Marker> markers = {
      Marker(
        markerId: const MarkerId('property'),
        position: position,
        infoWindow: InfoWindow(
          title: property.title,
          snippet: property.location,
        ),
      ),
    };

    // Collapsed height: 180 — expanded: 320
    final double mapHeight = _mapExpanded ? 320 : 180;

    return Column(
      children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          height: mapHeight,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.grey.shade200),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.06),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Stack(
              children: [
                GoogleMap(
                  initialCameraPosition: CameraPosition(
                    target: position,
                    zoom: 15.5,
                  ),
                  markers: markers,
                  onMapCreated: (controller) {
                    _mapController = controller;
                    // Apply a subtle light style if needed
                  },
                  zoomControlsEnabled: false,
                  mapToolbarEnabled: false,
                  myLocationButtonEnabled: false,
                  scrollGesturesEnabled: _mapExpanded,
                  zoomGesturesEnabled: _mapExpanded,
                  rotateGesturesEnabled: false,
                  tiltGesturesEnabled: false,
                  liteModeEnabled: !_mapExpanded, // lite mode when collapsed
                ),

                // ── "Not pinned" overlay ─────────────────────────────────
                if (!hasPinnedLocation)
                  Positioned(
                    bottom: 10, left: 0, right: 0,
                    child: Center(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.orange.shade700,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.info_outline,
                                color: Colors.white, size: 14),
                            SizedBox(width: 6),
                            Text('Approximate location',
                                style: TextStyle(
                                    color: Colors.white, fontSize: 12)),
                          ],
                        ),
                      ),
                    ),
                  ),

                // ── Expand / collapse tap layer (collapsed only) ─────────
                if (!_mapExpanded)
                  Positioned.fill(
                    child: GestureDetector(
                      onTap: () => setState(() => _mapExpanded = true),
                      child: Container(color: Colors.transparent),
                    ),
                  ),

                // ── Zoom-in pill (expanded mode) ─────────────────────────
                if (_mapExpanded)
                  Positioned(
                    top: 10, right: 10,
                    child: Column(children: [
                      _mapIconBtn(
                        Icons.add,
                        () => _mapController?.animateCamera(
                            CameraUpdate.zoomIn()),
                      ),
                      const SizedBox(height: 6),
                      _mapIconBtn(
                        Icons.remove,
                        () => _mapController?.animateCamera(
                            CameraUpdate.zoomOut()),
                      ),
                      const SizedBox(height: 6),
                      _mapIconBtn(
                        Icons.my_location,
                        () => _mapController?.animateCamera(
                          CameraUpdate.newLatLngZoom(position, 15.5),
                        ),
                      ),
                    ]),
                  ),
              ],
            ),
          ),
        ),

        // ── Open in Maps external link ─────────────────────────────────
        if (_mapExpanded) ...[
          const SizedBox(height: 8),
          GestureDetector(
            onTap: () {
              // Opens Google Maps externally — requires url_launcher
              // launch('https://maps.google.com/?q=$lat,$lng');
            },
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.open_in_new,
                    size: 14, color: Colors.blue[700]),
                const SizedBox(width: 4),
                Text('Open in Google Maps',
                    style: TextStyle(
                        color: Colors.blue[700],
                        fontSize: 12,
                        fontWeight: FontWeight.w600)),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _mapIconBtn(IconData icon, VoidCallback onTap) => GestureDetector(
        onTap: onTap,
        child: Container(
          width: 34, height: 34,
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                  color: Colors.black.withOpacity(0.15),
                  blurRadius: 6,
                  offset: const Offset(0, 2)),
            ],
          ),
          child: Icon(icon, size: 18, color: Colors.black87),
        ),
      );

  String _formatPrice(double price) {
    final int intPart = price.truncate();
    final double dec = price - intPart;
    final String thousands = intPart.toString().replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (m) => '${m[1]},',
        );
    if (dec == 0) return thousands;
    return '$thousands${dec.toStringAsFixed(2).substring(1)}';
  }

  Widget _imageFallback() => Container(
        height: 250,
        color: Colors.grey[200],
        child: const Icon(Icons.image_not_supported,
            size: 60, color: Colors.grey),
      );

  Widget _buildSectionDivider() =>
      Container(height: 8, color: Colors.blue.withValues(alpha: 0.05));

  Widget _buildHighlightItem(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        children: [
          Icon(icon, color: Colors.green[700], size: 22),
          const SizedBox(width: 12),
          Expanded(child: Text(text, style: const TextStyle(fontSize: 15))),
        ],
      ),
    );
  }

  Widget _buildAmenityItem(IconData icon, String text) {
    return SizedBox(
      width: 160,
      child: Row(
        children: [
          Icon(icon, color: Colors.grey[700], size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: Text(text,
                style: TextStyle(color: Colors.grey[800], fontSize: 13),
                maxLines: 1,
                overflow: TextOverflow.ellipsis),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoChip({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.07),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withValues(alpha: 0.25)),
        ),
        child: Row(
          children: [
            Icon(icon, size: 20, color: color),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style:
                        TextStyle(fontSize: 11, color: Colors.grey[600])),
                Text(value,
                    style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: color)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNearbyPlaceItem(
      IconData icon, String name, String distance) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.black87),
          const SizedBox(width: 16),
          Expanded(
            child: Text(name,
                style: const TextStyle(fontSize: 14, color: Colors.black87)),
          ),
          Text(distance,
              style: TextStyle(fontSize: 14, color: Colors.grey[600])),
        ],
      ),
    );
  }

  IconData _amenityIcon(String amenity) {
    final lower = amenity.toLowerCase();
    if (lower.contains('wifi') || lower.contains('wi-fi')) return Icons.wifi;
    if (lower.contains('aircon') || lower.contains('air con')) return Icons.ac_unit;
    if (lower.contains('bath') || lower.contains('toilet')) return Icons.bathroom;
    if (lower.contains('curfew')) return Icons.access_time;
    if (lower.contains('cook')) return Icons.kitchen;
    if (lower.contains('cctv')) return Icons.videocam;
    if (lower.contains('study')) return Icons.menu_book;
    if (lower.contains('water')) return Icons.water_drop;
    if (lower.contains('electr')) return Icons.electric_bolt;
    if (lower.contains('park')) return Icons.local_parking;
    if (lower.contains('gym') || lower.contains('fitness')) return Icons.fitness_center;
    if (lower.contains('garden') || lower.contains('yard')) return Icons.yard;
    if (lower.contains('pool')) return Icons.pool;
    if (lower.contains('security') || lower.contains('guard')) return Icons.security;
    return Icons.check_circle_outline;
  }
}

// ── Expandable text widget ────────────────────────────────────────────────────
class _ExpandableText extends StatefulWidget {
  final String text;
  const _ExpandableText({required this.text});

  @override
  State<_ExpandableText> createState() => _ExpandableTextState();
}

class _ExpandableTextState extends State<_ExpandableText> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AnimatedSize(
          duration: const Duration(milliseconds: 220),
          child: Text(
            widget.text,
            maxLines: _expanded ? null : 4,
            overflow:
                _expanded ? TextOverflow.visible : TextOverflow.ellipsis,
            style: TextStyle(
                color: Colors.grey[800], fontSize: 14, height: 1.5),
          ),
        ),
        if (widget.text.length > 200) ...[
          const SizedBox(height: 6),
          GestureDetector(
            onTap: () => setState(() => _expanded = !_expanded),
            child: Text(
              _expanded ? 'Show less' : 'Read more',
              style: TextStyle(
                  color: Colors.blue[700],
                  fontWeight: FontWeight.bold,
                  fontSize: 13),
            ),
          ),
        ],
      ],
    );
  }
}
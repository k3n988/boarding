import 'package:flutter/material.dart';
import '../data/models/property_model.dart';

class PropertyDetailScreen extends StatelessWidget {
  final PropertyModel property;

  const PropertyDetailScreen({super.key, required this.property});

  @override
  Widget build(BuildContext context) {
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
          padding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
                    const Text(
                      "Feb 20 - Feb 21, 2 guests",
                      style:
                          TextStyle(fontSize: 11, color: Colors.black54),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        actions: [
          IconButton(
              icon: const Icon(Icons.share_outlined), onPressed: () {}),
          IconButton(
              icon: const Icon(Icons.favorite_border), onPressed: () {}),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── 1. HEADER IMAGE ─────────────────────────────────────────────
            Stack(
              children: [
                Image.network(
                  property.imageUrl,
                  height: 250,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    height: 250,
                    color: Colors.grey[200],
                    child: const Icon(Icons.image_not_supported,
                        size: 60, color: Colors.grey),
                  ),
                ),
                Positioned(
                  bottom: 16,
                  right: 16,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.6),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text("1/23",
                        style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),

            // ── 2. TITLE & RATING ────────────────────────────────────────────
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
                              fontSize: 22,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border:
                              Border.all(color: Colors.red.shade200),
                        ),
                        child: const Icon(Icons.favorite_border,
                            color: Colors.red, size: 20),
                      )
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      ...List.generate(
                          5,
                          (_) => const Icon(Icons.star,
                              color: Colors.deepOrange, size: 16)),
                      const SizedBox(width: 8),
                      Container(
                          width: 1, height: 12, color: Colors.grey),
                      const SizedBox(width: 8),
                      const Icon(Icons.apartment,
                          color: Colors.grey, size: 16),
                      const SizedBox(width: 4),
                      Text("Apartment/Flat",
                          style: TextStyle(
                              color: Colors.grey[700], fontSize: 13)),
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
                            Text(property.location,
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16)),
                            Text("710 meters from city center",
                                style: TextStyle(
                                    color: Colors.grey[600],
                                    fontSize: 13)),
                          ],
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          const Text("9.2 Exceptional",
                              style: TextStyle(
                                  color: Colors.blue,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15)),
                          Text("57 reviews",
                              style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 13)),
                        ],
                      )
                    ],
                  ),
                ],
              ),
            ),

            _buildSectionDivider(),

            // ── 3. HIGHLIGHTS ────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Highlights",
                      style: TextStyle(
                          fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  _buildHighlightItem(
                      Icons.health_and_safety, "Hygiene Plus"),
                  _buildHighlightItem(
                      Icons.cleaning_services, "Sparkling clean"),
                  _buildHighlightItem(
                      Icons.park, "250 meters to Capitol Lagoon Park"),
                  _buildHighlightItem(Icons.verified, "Top Value"),
                  _buildHighlightItem(
                      Icons.door_front_door, "Check-in [24-hour]"),
                ],
              ),
            ),

            _buildSectionDivider(),

            // ── 4. TOP AMENITIES ─────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text("Top Amenities",
                          style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold)),
                      Text("See all",
                          style: TextStyle(
                              color: Colors.blue[700],
                              fontWeight: FontWeight.bold)),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 16,
                    runSpacing: 12,
                    children: [
                      _buildAmenityItem(Icons.wifi, "Free Wi-Fi"),
                      _buildAmenityItem(Icons.pool, "Swimming pool"),
                      _buildAmenityItem(
                          Icons.access_time, "Check-in [24-hour]"),
                      _buildAmenityItem(
                          Icons.fitness_center, "Fitness center"),
                      _buildAmenityItem(
                          Icons.local_taxi, "Airport transfer"),
                      _buildAmenityItem(Icons.kitchen, "Kitchen"),
                      _buildAmenityItem(Icons.yard, "Garden"),
                      _buildAmenityItem(Icons.local_parking,
                          "Paid parking available"),
                    ],
                  ),
                ],
              ),
            ),

            _buildSectionDivider(),

            // ── 5. NEW: LOCATION & SURROUNDINGS ──────────────────────────────
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text("Location",
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold)),
                      Text("See map",
                          style: TextStyle(
                              color: Colors.blue[700],
                              fontWeight: FontWeight.bold)),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // Fake Map Container
                  Container(
                    height: 140,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.map, size: 40, color: Colors.black45),
                          SizedBox(height: 8),
                          Text("Map View", style: TextStyle(color: Colors.black54)),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Simulated Tabs
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildLocationTab("Landmarks", isSelected: true),
                      _buildLocationTab("Transport", isSelected: false),
                      _buildLocationTab("Essentials", isSelected: false),
                    ],
                  ),
                  const Divider(height: 24, thickness: 1),
                  // List of Nearby Places
                  _buildNearbyPlaceItem(Icons.account_balance, "Barangay Sang Virgen Chapel", "1.38 km"),
                  _buildNearbyPlaceItem(Icons.park, "Capitol Lagoon Park", "1.94 km"),
                  _buildNearbyPlaceItem(Icons.local_hospital, "Bacolod Queen of Mercy Hospital", "2.50 km"),
                  _buildNearbyPlaceItem(Icons.shopping_bag, "SM City Bacolod", "3.10 km"),
                ],
              ),
            ),

            _buildSectionDivider(),

            // ── 6. PROPERTY DESCRIPTION ──────────────────────────────────────
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Property Description",
                      style: TextStyle(
                          fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  Text(
                    "Get your trip off to a great start with a stay at this property, "
                    "which offers free Wi-Fi in all rooms. Conveniently situated in the "
                    "Mandalagan part of Bacolod. The property provides a clean, safe "
                    "environment perfect for students and professionals alike.",
                    style: TextStyle(
                        color: Colors.grey[800],
                        fontSize: 14,
                        height: 1.5),
                  ),
                ],
              ),
            ),

            _buildSectionDivider(),

            // ── 7. POLICIES & RULES ──────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Policies & Rules",
                      style: TextStyle(
                          fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  Text(
                    "• Infant 0-1 year(s): Stay for free if using existing bedding. "
                    "Note, if you need a cot, it may incur an extra charge.\n"
                    "• No smoking allowed indoors.\n"
                    "• Visitors must log in at the front desk.",
                    style: TextStyle(
                        color: Colors.grey[800],
                        fontSize: 14,
                        height: 1.5),
                  ),
                ],
              ),
            ),

            _buildSectionDivider(),

            // ── 8. HOST PROFILE ──────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Host Profile",
                      style: TextStyle(
                          fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.grey[50],
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      children: [
                        const CircleAvatar(
                          radius: 40,
                          backgroundImage: NetworkImage(
                            "https://images.unsplash.com/photo-1580489944761-15a19d654956"
                            "?ixlib=rb-4.0.3&auto=format&fit=crop&w=200&q=80",
                          ),
                        ),
                        const SizedBox(height: 12),
                        const Text("Jennifer Linga",
                            style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold)),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: const [
                            Icon(Icons.emoji_events,
                                color: Colors.green, size: 18),
                            SizedBox(width: 4),
                            Text("9.5 Exceptional",
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
                            Text("Verified Host",
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
                            label: const Text("Contact Host",
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
                  )
                ],
              ),
            ),

            const SizedBox(height: 24),
          ],
        ),
      ),

      // ── UPDATED: GUEST BOTTOM BAR ──────────────────────────────────────────
      bottomNavigationBar: Container(
        padding:
            const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
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
                  Text("Total Price",
                      style: TextStyle(
                          color: Colors.grey[600], fontSize: 13)),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      // NOTE: You can replace '₱5,000' with your property variable
                      // Example: Text("₱${property.price}", ...)
                      const Text("₱5,000",
                          style: TextStyle(
                              color: Colors.black87,
                              fontWeight: FontWeight.bold,
                              fontSize: 20)),
                      Text(" / month",
                          style: TextStyle(
                              color: Colors.grey[600], fontSize: 14)),
                    ],
                  ),
                ],
              ),
              ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue[700],
                  padding: const EdgeInsets.symmetric(
                      horizontal: 24, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  "Book Now",
                  style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  // ── Helper Widgets ─────────────────────────────────────────────────────────

  Widget _buildSectionDivider() =>
      Container(height: 8, color: Colors.blue.withValues(alpha: 0.05));

  Widget _buildHighlightItem(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        children: [
          Icon(icon, color: Colors.green[700], size: 22),
          const SizedBox(width: 12),
          Text(text, style: const TextStyle(fontSize: 15)),
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
                style:
                    TextStyle(color: Colors.grey[800], fontSize: 13),
                maxLines: 1,
                overflow: TextOverflow.ellipsis),
          ),
        ],
      ),
    );
  }

  // ── NEW HELPER WIDGETS FOR LOCATION SECTION ────────────────────────────────

  Widget _buildLocationTab(String title, {required bool isSelected}) {
    return Column(
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 15,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            color: isSelected ? Colors.blue[700] : Colors.grey[600],
          ),
        ),
        const SizedBox(height: 4),
        if (isSelected)
          Container(
            height: 2,
            width: 80,
            color: Colors.blue[700],
          )
      ],
    );
  }

  Widget _buildNearbyPlaceItem(IconData icon, String name, String distance) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.black87),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              name,
              style: const TextStyle(fontSize: 14, color: Colors.black87),
            ),
          ),
          Text(
            distance,
            style: TextStyle(fontSize: 14, color: Colors.grey[700]),
          ),
        ],
      ),
    );
  }
}
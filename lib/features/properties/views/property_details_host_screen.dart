import 'package:flutter/material.dart';
import '../data/models/property_model.dart';

class PropertyDetailsHostScreen extends StatelessWidget {
  final PropertyModel property;

  const PropertyDetailsHostScreen({super.key, required this.property});

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
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            children: [
              const Icon(Icons.home_work_outlined, size: 18, color: Colors.black54),
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
                      "Your Active Listing",
                      style: TextStyle(fontSize: 11, color: Colors.black54),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        actions: [
          IconButton(
              icon: const Icon(Icons.edit_outlined, color: Colors.blue), 
              onPressed: () {}),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── 1. HEADER IMAGE ──
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
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.6),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text("Manage Photos",
                        style: TextStyle(
                            color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
                  ),
                ),
              ],
            ),

            // ── 2. TITLE & RATING ──
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    property.title,
                    style: const TextStyle(
                        fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      ...List.generate(
                          5,
                          (_) => const Icon(Icons.star,
                              color: Colors.deepOrange, size: 16)),
                      const SizedBox(width: 8),
                      Container(width: 1, height: 12, color: Colors.grey),
                      const SizedBox(width: 8),
                      const Icon(Icons.apartment, color: Colors.grey, size: 16),
                      const SizedBox(width: 4),
                      Text("Apartment/Flat",
                          style: TextStyle(color: Colors.grey[700], fontSize: 13)),
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
                                    fontWeight: FontWeight.bold, fontSize: 16)),
                            Text("710 meters from city center",
                                style: TextStyle(
                                    color: Colors.grey[600], fontSize: 13)),
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
                                  color: Colors.grey[600], fontSize: 13)),
                        ],
                      )
                    ],
                  ),
                ],
              ),
            ),

            _buildSectionDivider(),

            // ── 3. HIGHLIGHTS ──
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Highlights",
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  _buildHighlightItem(Icons.health_and_safety, "Hygiene Plus"),
                  _buildHighlightItem(Icons.cleaning_services, "Sparkling clean"),
                  _buildHighlightItem(Icons.park, "250 meters to Capitol Lagoon Park"),
                ],
              ),
            ),

            _buildSectionDivider(),

            // ── 4. TOP AMENITIES ──
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text("Amenities",
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      Text("Edit Amenities",
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
                      _buildAmenityItem(Icons.access_time, "Check-in [24-hour]"),
                      _buildAmenityItem(Icons.kitchen, "Kitchen"),
                    ],
                  ),
                ],
              ),
            ),

            _buildSectionDivider(),

            // ── 5. SEPARATED: DESCRIPTION ──
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "Property Description",
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      Text("Edit", style: TextStyle(color: Colors.blue[700], fontWeight: FontWeight.bold)),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    "Get your trip off to a great start with a stay at this property, "
                    "which offers free Wi-Fi in all rooms. Conveniently situated in the "
                    "Mandalagan part of Bacolod. The property provides a clean, safe "
                    "environment perfect for students and professionals alike.",
                    style: TextStyle(
                        color: Colors.grey[800], fontSize: 14, height: 1.5),
                  ),
                ],
              ),
            ),

            _buildSectionDivider(),

            // ── 6. SEPARATED: POLICIES ──
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "Policies & Rules",
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      Text("Edit", style: TextStyle(color: Colors.blue[700], fontWeight: FontWeight.bold)),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    "• Infant 0-1 year(s): Stay for free if using existing bedding.\n"
                    "• No smoking allowed indoors.\n"
                    "• Visitors must log in at the front desk.",
                    style: TextStyle(
                        color: Colors.grey[800], fontSize: 14, height: 1.5),
                  ),
                ],
              ),
            ),

            _buildSectionDivider(),

            // ── 7. HOST PROFILE (Simplified for Host) ──
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Your Public Profile",
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
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
                            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: const [
                            Icon(Icons.emoji_events, color: Colors.green, size: 18),
                            SizedBox(width: 4),
                            Text("9.5 Exceptional Host",
                                style: TextStyle(
                                    color: Colors.green, fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ],
                    ),
                  )
                ],
              ),
            ),

            const SizedBox(height: 100),
          ],
        ),
      ),
      // ── HOST BOTTOM BAR ──
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
                  Text("Status",
                      style: TextStyle(color: Colors.grey[600], fontSize: 13)),
                  const Text("Active / Listed",
                      style: TextStyle(
                          color: Colors.green,
                          fontWeight: FontWeight.bold,
                          fontSize: 16)),
                ],
              ),
              ElevatedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.edit, size: 18),
                label: const Text("Edit Listing"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12)
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  // ── Helper Widgets ──

  Widget _buildSectionDivider() {
    return Container(height: 8, color: Colors.blue.withValues(alpha: 0.05));
  }

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
                style: TextStyle(color: Colors.grey[800], fontSize: 13),
                maxLines: 1,
                overflow: TextOverflow.ellipsis),
          ),
        ],
      ),
    );
  }
}
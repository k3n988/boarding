import 'package:flutter/material.dart';

import '../data/mock_properties.dart';
import 'widgets/property_card.dart';
import '../../map/views/map_screen.dart';
import 'widgets/ai_banner.dart';
import 'widgets/room_filter_sheet.dart'; // Agoda-style list screen
// ADDED: Import the FilterScreen (Yung Agoda-style list mo)

// Import the detail screen


class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 12),

            // HEADER: Ken Stays + Notifications
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Rently",
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.5,
                      color: Colors.black87,
                    ),
                  ),
                  _buildIconWithBadge(Icons.notifications_none_rounded, "2"),
                ],
              ),
            ),

            // CATEGORIES: Naka-link na papunta sa RoomFilterSheet
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _buildCategoryItem(
                      context,
                      Icons.home_rounded,
                      "Boarding House",
                      // Ipasa ang location para may lumabas na data
                      const RoomFilterSheet(selectedArea: 'Mandalagan'), 
                    ),
                    const SizedBox(width: 20),
                    _buildCategoryItem(
                      context,
                      Icons.bedroom_child_rounded,
                      "Dorm",
                      const RoomFilterSheet(selectedArea: 'Lacson St.'), 
                    ),
                    const SizedBox(width: 20),
                    _buildCategoryItem(
                      context,
                      Icons.apartment_rounded,
                      "Apartment",
                      const RoomFilterSheet(selectedArea: 'Lacson St.'), 
                    ),
                    const SizedBox(width: 20),
                    _buildCategoryItem(
                      context,
                      Icons.bed_rounded,
                      "Bedspace",
                      const RoomFilterSheet(selectedArea: 'Alijis'), 
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 8),

            // SEARCH BAR: Naka-link na rin papunta sa RoomFilterSheet
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const RoomFilterSheet(selectedArea: 'Lacson St.'),
                    ),
                  );
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF5F5F7),
                    borderRadius: BorderRadius.circular(28),
                    border: Border.all(color: Colors.grey.shade200),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.04),
                        blurRadius: 12,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.search_rounded, color: Colors.grey[600], size: 22),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Text(
                          "Search reviews, locations...",
                          style: TextStyle(
                            color: Colors.grey,
                            fontSize: 15,
                          ),
                        ),
                      ),
                      Container(height: 22, width: 1, color: Colors.grey.shade300),
                      const SizedBox(width: 14),
                      GestureDetector(
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const MapScreen(),
                          ),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              "Map",
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                                color: Colors.black87,
                              ),
                            ),
                            SizedBox(width: 6),
                            Icon(Icons.map_outlined, color: Colors.black87, size: 20),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            const SizedBox(height: 16),

            // AI BANNER
            const AIBanner(),

            const SizedBox(height: 20),

            // AVAILABLE ROOMS
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Available Rooms",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: Colors.black87,
                    ),
                  ),
                  Icon(Icons.tune_rounded, color: Colors.grey[500], size: 24),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // PROPERTY GRID: In-update para pumunta sa RoomFilterSheet!
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: GridView.builder(
                  physics: const BouncingScrollPhysics(),
                  itemCount: mockProperties.length,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.72,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 18,
                  ),
                  itemBuilder: (context, index) {
                    final property = mockProperties[index];
                    return GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            // DITO ANG FIX: Tatawagin ang RoomFilterSheet gamit ang location ng property
                            builder: (context) => RoomFilterSheet(selectedArea: property.location),
                          ),
                        );
                      },
                      child: PropertyCard(property: property),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryItem(
    BuildContext context,
    IconData icon,
    String label,
    Widget targetScreen,
  ) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => targetScreen),
        );
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFF3F5F7),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Icon(icon, color: Colors.black87, size: 26),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIconWithBadge(IconData icon, String count) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Icon(icon, size: 28, color: Colors.black87),
        Positioned(
          right: 0,
          top: 0,
          child: Container(
            padding: const EdgeInsets.all(4),
            decoration: const BoxDecoration(
              color: Color(0xFFFF4848),
              shape: BoxShape.circle,
            ),
            constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
            child: Center(
              child: Text(
                count,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
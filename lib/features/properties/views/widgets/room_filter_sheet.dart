import 'package:flutter/material.dart';

import '../../data/models/property_model.dart';
import '../../data/mock_properties.dart';
import '../property_details_host_screen.dart';


class RoomFilterSheet extends StatefulWidget {
  final String selectedArea;

  const RoomFilterSheet({super.key, required this.selectedArea});

  @override
  State<RoomFilterSheet> createState() => _RoomFilterSheetState();
}

class _RoomFilterSheetState extends State<RoomFilterSheet> {
  List<PropertyModel> filteredProperties = [];

  RangeValues _budgetRange = const RangeValues(0, 69610);
  String _selectedSort = "Best match";

  final List<String> _sortOptions = [
    "Best match",
    "Lowest price",
    "Highest price",
    "Top guest ratings",
    "Stars (5 to 0)"
  ];

  @override
  void initState() {
    super.initState();
    // Pansamantalang logic: Kung walang mahanap, ipapakita lahat para sa testing
    filteredProperties = mockProperties.where((p) => p.location.contains(widget.selectedArea)).toList();
    if (filteredProperties.isEmpty) {
        filteredProperties = mockProperties;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: SafeArea(
        child: Column(
          children: [
            // ── Top Header ──────────────────────────────────────────────────
            Container(
              decoration: BoxDecoration(
                color: Colors.pink[50],
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(30),
                  bottomRight: Radius.circular(30),
                ),
              ),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16.0, vertical: 8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildCircularIconButton(
                            Icons.arrow_back, () => Navigator.pop(context)),
                        Row(
                          children: [
                            _buildCircularIconButton(
                                Icons.currency_exchange, () {}),
                            const SizedBox(width: 12),
                            _buildCircularIconButton(Icons.favorite, () {}),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24.0, vertical: 8.0),
                    child: Row(
                      children: [
                        const Icon(Icons.search, size: 28),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    "Bacolod (${widget.selectedArea})",
                                    style: const TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    "(${filteredProperties.length})",
                                    style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.grey[600]),
                                  ),
                                  const SizedBox(width: 8),
                                  const Text("Edit",
                                      style: TextStyle(
                                          color: Colors.blue,
                                          fontWeight: FontWeight.w600)),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text(
                                "Fri, Feb 20 - Sat, Feb 21 • 2 Guests",
                                style: TextStyle(
                                    color: Colors.grey[700], fontSize: 13),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16.0, vertical: 12.0),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.05),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          )
                        ],
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          // NA-LINK NA ANG MGA BOTTOM SHEETS DITO!
                          _buildFilterChip("Filters", onTap: _showFiltersSheet),
                          _buildFilterChip("Price", onTap: _showBudgetSheet),
                          _buildFilterChip("Sort", onTap: _showSortSheet),
                          _buildFilterChip("Area", onTap: _showAreaSheet),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // ── Promo Banner ────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.green[50],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.local_offer, color: Colors.green),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("ONE-HOUR KENSTAYSALE!",
                              style: TextStyle(
                                  color: Colors.green,
                                  fontWeight: FontWeight.bold)),
                          Text(
                              "Claim now to instantly lower prices by up to 10%",
                              style: TextStyle(
                                  color: Colors.green, fontSize: 12)),
                        ],
                      ),
                    ),
                    TextButton(
                      onPressed: () {},
                      child: const Text("CLAIM",
                          style: TextStyle(fontWeight: FontWeight.bold)),
                    )
                  ],
                ),
              ),
            ),

            // ── Notice Bar ──────────────────────────────────────────────────
            Container(
              width: double.infinity,
              padding:
                  const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
              color: const Color(0xFF1E2738),
              child: const Row(
                children: [
                  Icon(Icons.star, color: Colors.white, size: 16),
                  SizedBox(width: 8),
                  Text("Book now and secure your room!",
                      style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 13)),
                ],
              ),
            ),

            // ── Property List ───────────────────────────────────────────────
            Expanded(
              child: filteredProperties.isEmpty
                  ? Center(
                      child: Text(
                        "No properties found in ${widget.selectedArea}.",
                        style: TextStyle(color: Colors.grey[500]),
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: filteredProperties.length,
                      itemBuilder: (context, index) =>
                          _buildPropertyCard(filteredProperties[index]),
                    ),
            ),
          ],
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: Container(
        padding:
            const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.location_on, color: Colors.blue[700], size: 20),
            const SizedBox(width: 8),
            Text("Map",
                style: TextStyle(
                    color: Colors.blue[700], fontWeight: FontWeight.bold)),
            const SizedBox(width: 12),
            Container(width: 1, height: 20, color: Colors.grey[300]),
            const SizedBox(width: 12),
            const Icon(Icons.favorite, color: Colors.blue, size: 20),
            const SizedBox(width: 8),
            const Text("Saved",
                style: TextStyle(
                    color: Colors.blue, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  // ── Bottom Sheets (Dropdowns) ────────────────────────────────────────────

  void _showFiltersSheet() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text("More Filters", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(context)),
                ],
              ),
              const SizedBox(height: 16),
              // Dummy checkboxes bilang examples para sa Filters
              _buildCheckboxOption("Wi-Fi included"),
              _buildCheckboxOption("Air conditioning"),
              _buildCheckboxOption("Private Bathroom"),
              _buildCheckboxOption("Female Only"),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue[800],
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: () => Navigator.pop(context),
                  child: const Text("Apply Filters", style: TextStyle(color: Colors.white, fontSize: 16)),
                ),
              )
            ],
          ),
        );
      },
    );
  }

  void _showBudgetSheet() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) {
        return StatefulBuilder(builder: (ctx, setModal) {
          return Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.pop(ctx)),
                    const Text("Budget",
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(width: 48),
                  ],
                ),
                const SizedBox(height: 24),
                Text(
                  "₱ ${_budgetRange.start.toInt()} - ₱ ${_budgetRange.end.toInt()}",
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 16),
                ),
                SliderTheme(
                  data: SliderTheme.of(context).copyWith(
                    activeTrackColor: Colors.blue[700],
                    inactiveTrackColor: Colors.grey[300],
                    thumbColor: Colors.white,
                    overlayColor: Colors.blue.withValues(alpha: 0.2),
                  ),
                  child: RangeSlider(
                    values: _budgetRange,
                    min: 0,
                    max: 20000, // In-adjust para mas makatotohanan sa rent
                    onChanged: (values) {
                      setModal(() => _budgetRange = values);
                      setState(() => _budgetRange = values);
                    },
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TextButton(
                      onPressed: () => setModal(
                          () => _budgetRange = const RangeValues(0, 20000)),
                      child: Text("Clear",
                          style: TextStyle(
                              color: Colors.blue[700], fontSize: 16)),
                    ),
                    ElevatedButton(
                      onPressed: () => Navigator.pop(ctx),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue[700],
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 40, vertical: 12),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20)),
                      ),
                      child: const Text("Filter",
                          style: TextStyle(fontSize: 16)),
                    )
                  ],
                )
              ],
            ),
          );
        });
      },
    );
  }

  void _showSortSheet() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 20.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.pop(ctx)),
                    const Text("Sort by:",
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(width: 48),
                  ],
                ),
              ),
              const Divider(),
              ..._sortOptions.map((option) {
                final bool isSelected = _selectedSort == option;
                return ListTile(
                  title: Text(option,
                      style: TextStyle(
                        fontWeight: isSelected
                            ? FontWeight.bold
                            : FontWeight.normal,
                        color: isSelected
                            ? Colors.blue[700]
                            : Colors.black87,
                      )),
                  trailing: isSelected
                      ? Icon(Icons.check, color: Colors.blue[700])
                      : null,
                  onTap: () {
                    setState(() => _selectedSort = option);
                    Navigator.pop(ctx);
                  },
                );
              }),
            ],
          ),
        );
      },
    );
  }

  void _showAreaSheet() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 20.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(context)),
                    const Text("Select Area", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(width: 48),
                  ],
                ),
              ),
              const Divider(),
              ListTile(
                title: const Text("Mandalagan"),
                onTap: () {
                  // Logic para palitan ang Area (needs state update later)
                  Navigator.pop(context);
                },
              ),
              ListTile(
                title: const Text("Lacson St."),
                onTap: () => Navigator.pop(context),
              ),
              ListTile(
                title: const Text("Alijis"),
                onTap: () => Navigator.pop(context),
              ),
              ListTile(
                title: const Text("Bata"),
                onTap: () => Navigator.pop(context),
              ),
            ],
          ),
        );
      },
    );
  }

  // ── Helper Widgets ─────────────────────────────────────────────────────────

  // NA-UPDATE: Gumamit ng GestureDetector para maging clickable
  Widget _buildFilterChip(String label, {required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap, // Ito ang nagko-connect sa Bottom Sheets
      child: Container(
        color: Colors.transparent, // Para ang buong space ay clickable
        child: Row(
          children: [
            Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
            const Icon(Icons.keyboard_arrow_down, size: 18),
          ],
        ),
      ),
    );
  }

  Widget _buildCheckboxOption(String title) {
    return Row(
      children: [
        Checkbox(
          value: false, // Gawing dynamic ito later
          onChanged: (value) {},
          activeColor: Colors.blue[800],
        ),
        Text(title),
      ],
    );
  }

  Widget _buildCircularIconButton(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: const BoxDecoration(
            color: Colors.white, shape: BoxShape.circle),
        child: Icon(icon, color: Colors.black87, size: 22),
      ),
    );
  }

  Widget _buildPropertyCard(PropertyModel property) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            // NOTE: Kung PropertyDetailScreen ang gusto mong gamitin para sa users, palitan ito:
            // builder: (_) => PropertyDetailScreen(property: property),
            builder: (_) =>
                PropertyDetailsHostScreen(property: property),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            )
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(12),
                    bottomLeft: Radius.circular(12),
                  ),
                  child: Image.network(
                    property.imageUrl,
                    height: 200,
                    width: 130,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      height: 200,
                      width: 130,
                      color: Colors.grey[200],
                      child: const Icon(Icons.image_not_supported,
                          color: Colors.grey),
                    ),
                  ),
                ),
                Positioned(
                  top: 8,
                  right: 8,
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: const BoxDecoration(
                        color: Colors.white, shape: BoxShape.circle),
                    child: const Icon(Icons.favorite_border, size: 18),
                  ),
                ),
              ],
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(property.title,
                        style: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    Text("${property.location} - 0.71 km to center",
                        style: TextStyle(
                            fontSize: 12, color: Colors.grey[700])),
                    const SizedBox(height: 8),
                    Row(children: [
                      const Icon(Icons.apartment, size: 14, color: Colors.green),
                      const SizedBox(width: 4),
                      Text(property.category, // Ginawa kong dynamic base sa model
                          style: const TextStyle(
                              fontSize: 12, color: Colors.black87)),
                    ]),
                    const SizedBox(height: 4),
                    Row(children: const [
                      Icon(Icons.verified, size: 14, color: Colors.green),
                      SizedBox(width: 4),
                      Text("Verified Host",
                          style: TextStyle(
                              fontSize: 12, color: Colors.black87)),
                    ]),
                    const SizedBox(height: 8),
                    const Row(children: [
                      Icon(Icons.star, size: 12, color: Colors.orange),
                      Icon(Icons.star, size: 12, color: Colors.orange),
                      Icon(Icons.star, size: 12, color: Colors.orange),
                      Icon(Icons.star, size: 12, color: Colors.orange),
                      Icon(Icons.star_half,
                          size: 12, color: Colors.orange),
                    ]),
                    const SizedBox(height: 4),
                    Row(children: [
                      const Text("9.2 Exceptional ",
                          style: TextStyle(
                              color: Colors.blue,
                              fontWeight: FontWeight.bold,
                              fontSize: 13)),
                      Text("57 reviews",
                          style: TextStyle(
                              color: Colors.grey[600], fontSize: 12)),
                    ]),
                    const SizedBox(height: 4),
                    Text(
                      "\"Very accomodating, clean unit and good experience.\"",
                      style: TextStyle(
                          fontSize: 11,
                          color: Colors.grey[600],
                          fontStyle: FontStyle.italic),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "₱ ${property.price} / month",
                      style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          color: Colors.black87),
                    ),
                    const SizedBox(height: 4),
                    Row(children: [
                      Icon(Icons.bed, size: 14, color: Colors.grey[600]),
                      const SizedBox(width: 4),
                      Text("${property.availableSlots} slots left", // Ginawa kong dynamic
                          style: TextStyle(
                              fontSize: 11, color: Colors.grey[600])),
                    ]),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 2),
                      color: Colors.blue[50],
                      child: Text("Rare Find",
                          style: TextStyle(
                              color: Colors.blue[800],
                              fontSize: 10,
                              fontWeight: FontWeight.bold)),
                    )
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
import 'package:flutter/material.dart';

class FilterScreen extends StatefulWidget {
  const FilterScreen({super.key});

  @override
  State<FilterScreen> createState() => _FilterScreenState();
}

class _FilterScreenState extends State<FilterScreen> {
  // --- STATE VARIABLES FOR FILTERS ---
  
  // Property Types
  final List<String> _propertyTypes = ["Boarding House", "Dormitory", "Apartment", "Bedspace"];
  final List<String> _selectedPropertyTypes = [];

  // Star Rating (1 to 5, allow only one selection based on prompt)
  int? _selectedStarRating;

  // Budget
  RangeValues _budgetRange = const RangeValues(0, 20000);

  // Neighborhoods (Bacolod Barangays)
  final Map<String, String> _neighborhoods = {
    "Mandalagan": "Nature, Top attractions",
    "Bacolod Downtown": "Top attractions, Nature, Foodie haven",
    "Taculing": "Quiet, Residential",
    "Villamonte": "Local vibe, Convenient",
    "Bata": "Near terminals",
    "Estefania": "Suburban, Peaceful",
  };
  final List<String> _selectedNeighborhoods = [];

  // Facilities
  final List<String> _facilities = ["Swimming pool", "Internet", "Car park", "Gym/fitness"];
  final List<String> _selectedFacilities = [];

  // Special
  final List<String> _specials = ["Great for Families", "Great for Groups", "Pets allowed"];
  final List<String> _selectedSpecials = [];

  // Room Amenities
  final List<String> _amenities = ["Air conditioning", "Private bathroom", "Kitchen", "Balcony"];
  final List<String> _selectedAmenities = [];

  // Payment Options
  final List<String> _paymentOptions = ["Pay now", "Pay at the property"];
  final List<String> _selectedPaymentOptions = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.blue[700],
        foregroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text("Filter", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        actions: [
          TextButton(
            onPressed: () {
              // Action when "Show list" is clicked
              Navigator.pop(context);
            },
            child: const Text("Show list", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // --- PROPERTY TYPE ---
              _buildSectionTitle("Property Type"),
              _buildCheckboxList(_propertyTypes, _selectedPropertyTypes),
              const Divider(height: 32),

              // --- STAR RATING ---
              _buildSectionTitle("Star rating"),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: List.generate(5, (index) {
                  int rating = index + 1;
                  bool isSelected = _selectedStarRating == rating;
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        // Toggle off if already selected, otherwise select it
                        _selectedStarRating = isSelected ? null : rating;
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: isSelected ? Colors.blue[50] : Colors.white,
                        border: Border.all(color: isSelected ? Colors.blue : Colors.grey.shade300),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          Text("$rating", style: TextStyle(fontWeight: FontWeight.bold, color: isSelected ? Colors.blue : Colors.black87)),
                          const SizedBox(width: 4),
                          Icon(Icons.star, size: 16, color: isSelected ? Colors.blue : Colors.black87),
                        ],
                      ),
                    ),
                  );
                }),
              ),
              const Divider(height: 40),

              // --- BUDGET ---
              _buildSectionTitle("Budget"),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("₱ ${_budgetRange.start.toInt()}", style: const TextStyle(fontWeight: FontWeight.bold)),
                  Text("₱ ${_budgetRange.end.toInt()}", style: const TextStyle(fontWeight: FontWeight.bold)),
                ],
              ),
              SliderTheme(
                data: SliderTheme.of(context).copyWith(
                  activeTrackColor: Colors.blue,
                  inactiveTrackColor: Colors.grey[300],
                  thumbColor: Colors.white,
                  overlayColor: Colors.blue.withOpacity(0.2),
                  valueIndicatorColor: Colors.blue,
                ),
                child: RangeSlider(
                  values: _budgetRange,
                  min: 0,
                  max: 20000,
                  divisions: 200, // Steps of 100
                  labels: RangeLabels(
                    "₱${_budgetRange.start.toInt()}",
                    "₱${_budgetRange.end.toInt()}",
                  ),
                  onChanged: (RangeValues values) {
                    setState(() {
                      _budgetRange = values;
                    });
                  },
                ),
              ),
              const Divider(height: 40),

              // --- NEIGHBORHOODS ---
              _buildSectionTitle("Neighborhoods"),
              const SizedBox(height: 8),
              ..._neighborhoods.entries.map((entry) {
                return _buildCustomCheckboxTile(
                  title: entry.key,
                  subtitle: entry.value,
                  value: _selectedNeighborhoods.contains(entry.key),
                  onChanged: (bool? val) {
                    setState(() {
                      if (val == true) {
                        _selectedNeighborhoods.add(entry.key);
                      } else {
                        _selectedNeighborhoods.remove(entry.key);
                      }
                    });
                  },
                );
              }),
              _buildShowMoreText(),
              const Divider(height: 32),

              // --- FACILITIES ---
              _buildSectionTitle("Facilities"),
              _buildCheckboxList(_facilities, _selectedFacilities),
              _buildShowMoreText(),
              const Divider(height: 32),

              // --- LOOKING FOR SOMETHING SPECIAL ---
              _buildSectionTitle("Looking for something special?"),
              _buildCheckboxList(_specials, _selectedSpecials),
              const Divider(height: 32),

              // --- ROOM AMENITIES ---
              _buildSectionTitle("Room amenities"),
              _buildCheckboxList(_amenities, _selectedAmenities),
              const Divider(height: 32),

              // --- PAYMENT OPTIONS ---
              _buildSectionTitle("Payment option"),
              _buildCheckboxList(_paymentOptions, _selectedPaymentOptions),
              
              const SizedBox(height: 40), // Bottom padding
            ],
          ),
        ),
      ),
    );
  }

  // --- HELPER WIDGETS ---

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87),
    );
  }

  Widget _buildShowMoreText() {
    return Padding(
      padding: const EdgeInsets.only(top: 8.0, left: 12.0),
      child: Row(
        children: [
          Icon(Icons.keyboard_arrow_down, color: Colors.blue[700], size: 20),
          const SizedBox(width: 4),
          Text("Show more", style: TextStyle(color: Colors.blue[700], fontWeight: FontWeight.bold, fontSize: 14)),
        ],
      ),
    );
  }

  // Generates a simple list of checkboxes without subtitles
  Widget _buildCheckboxList(List<String> items, List<String> selectedList) {
    return Column(
      children: items.map((item) {
        return _buildCustomCheckboxTile(
          title: item,
          value: selectedList.contains(item),
          onChanged: (bool? val) {
            setState(() {
              if (val == true) {
                selectedList.add(item);
              } else {
                selectedList.remove(item);
              }
            });
          },
        );
      }).toList(),
    );
  }

  // Custom Checkbox Tile to match the exact look of Agoda's thin gray boxes
  Widget _buildCustomCheckboxTile({
    required String title,
    String? subtitle,
    required bool value,
    required ValueChanged<bool?> onChanged,
  }) {
    return InkWell(
      onTap: () => onChanged(!value),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: 24,
              width: 24,
              child: Checkbox(
                value: value,
                onChanged: onChanged,
                activeColor: Colors.blue[700],
                side: BorderSide(color: Colors.grey.shade400, width: 1.5),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(3)),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontSize: 15, color: Colors.black87)),
                  if (subtitle != null) ...[
                    const SizedBox(height: 2),
                    Text(subtitle, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                  ]
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
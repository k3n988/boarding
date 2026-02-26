import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../viewmodels/home_viewmodel.dart';
import '../data/models/property_model.dart';
import 'property_detail_screen.dart';
import 'widgets/property_card.dart';
import 'widgets/ai_banner.dart';
import '../../map/views/map_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late HomeViewModel _vm;
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    _vm = HomeViewModel();
    _vm.addListener(_onVmChange);
  }

  void _onVmChange() => setState(() {});

  @override
  void dispose() {
    _vm.removeListener(_onVmChange);
    _vm.dispose();
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
        if (_isSearching && _searchController.text.isEmpty) {
          setState(() => _isSearching = false);
        }
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          bottom: false,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 12),
              _buildHeader(context),
              _buildCategoryTabs(),
              const SizedBox(height: 8),
              _buildSearchBar(context),
              const SizedBox(height: 16),
              const AIBanner(),
              const SizedBox(height: 20),
              _buildSectionTitle(),
              const SizedBox(height: 16),
              Expanded(child: _buildPropertyGrid(context)),
            ],
          ),
        ),
      ),
    );
  }

  // ── Header ───────────────────────────────────────────────────────────────────
  Widget _buildHeader(BuildContext context) {
    return Padding(
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
          Stack(
            clipBehavior: Clip.none,
            children: [
              const Icon(Icons.notifications_none_rounded, size: 28, color: Colors.black87),
              Positioned(
                right: 0,
                top: 0,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(color: Color(0xFFFF4848), shape: BoxShape.circle),
                  constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
                  child: const Center(
                    child: Text("2",
                        style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w700)),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ── Category Tabs ────────────────────────────────────────────────────────────
  Widget _buildCategoryTabs() {
    final categories = [
      {'label': 'All', 'icon': Icons.grid_view_rounded},
      {'label': 'Boarding House', 'icon': Icons.home_rounded},
      {'label': 'Dormitory', 'icon': Icons.bedroom_child_rounded},
      {'label': 'Apartment', 'icon': Icons.apartment_rounded},
      {'label': 'Bedspace', 'icon': Icons.bed_rounded},
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: List.generate(categories.length, (i) {
            final label = categories[i]['label'] as String;
            final icon = categories[i]['icon'] as IconData;
            final isSelected = _vm.selectedCategory == label;

            return Padding(
              padding: EdgeInsets.only(right: i < categories.length - 1 ? 20.0 : 0),
              child: GestureDetector(
                onTap: () => _vm.setCategory(label),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: isSelected ? Colors.black87 : const Color(0xFFF3F5F7),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: isSelected ? 0.18 : 0.04),
                            blurRadius: isSelected ? 10 : 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Icon(icon, color: isSelected ? Colors.white : Colors.black87, size: 24),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      label == 'Boarding House' ? 'Boarding\nHouse' : label,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                        color: isSelected ? Colors.black87 : Colors.black54,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
        ),
      ),
    );
  }

  // ── Search Bar ───────────────────────────────────────────────────────────────
  Widget _buildSearchBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 4),
        decoration: BoxDecoration(
          color: const Color(0xFFF5F5F7),
          borderRadius: BorderRadius.circular(28),
          border: Border.all(
            color: _isSearching ? Colors.black45 : Colors.grey.shade200,
            width: _isSearching ? 1.5 : 1,
          ),
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
            Expanded(
              child: TextField(
                controller: _searchController,
                focusNode: _searchFocusNode,
                decoration: InputDecoration(
                  hintText: "Search by name, location...",
                  hintStyle: TextStyle(color: Colors.grey[400], fontSize: 15),
                  border: InputBorder.none,
                  isDense: true,
                  contentPadding: const EdgeInsets.symmetric(vertical: 10),
                ),
                onChanged: (val) {
                  _vm.setSearchQuery(val);
                  setState(() => _isSearching = val.isNotEmpty);
                },
                onTap: () => setState(() => _isSearching = true),
              ),
            ),
            if (_isSearching && _searchController.text.isNotEmpty)
              GestureDetector(
                onTap: () {
                  _searchController.clear();
                  _vm.setSearchQuery('');
                  setState(() => _isSearching = false);
                  FocusScope.of(context).unfocus();
                },
                child: Icon(Icons.close_rounded, color: Colors.grey[500], size: 20),
              )
            else ...[
              Container(height: 22, width: 1, color: Colors.grey.shade300),
              const SizedBox(width: 14),
              GestureDetector(
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const MapScreen()),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text("Map",
                        style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: Colors.black87)),
                    SizedBox(width: 6),
                    Icon(Icons.map_outlined, color: Colors.black87, size: 20),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  // ── Section Title ─────────────────────────────────────────────────────────────
  Widget _buildSectionTitle() {
    final label = _vm.selectedCategory == 'All' ? 'Available Rooms' : _vm.selectedCategory;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label,
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: Colors.black87)),
              if (!_vm.isLoading)
                Text(
                  '${_vm.totalCount} ${_vm.totalCount == 1 ? 'listing' : 'listings'} found',
                  style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                ),
            ],
          ),
          Row(
            children: [
              if (_vm.hasActiveFilters)
                GestureDetector(
                  onTap: () {
                    _vm.clearAllFilters();
                    _searchController.clear();
                    setState(() => _isSearching = false);
                  },
                  child: Container(
                    margin: const EdgeInsets.only(right: 10),
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: Colors.black87,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text('Clear',
                        style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600)),
                  ),
                ),
              GestureDetector(
                onTap: () => _showSortFilterSheet(context),
                child: Icon(Icons.tune_rounded, color: Colors.grey[500], size: 24),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ── Property Grid ─────────────────────────────────────────────────────────────
  Widget _buildPropertyGrid(BuildContext context) {
    if (_vm.isLoading) {
      return const Center(child: CircularProgressIndicator(color: Colors.black87, strokeWidth: 2));
    }

    if (_vm.errorMessage != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.cloud_off_rounded, size: 48, color: Colors.grey[400]),
            const SizedBox(height: 12),
            Text('Could not load listings',
                style: TextStyle(color: Colors.grey[600], fontWeight: FontWeight.w600)),
            const SizedBox(height: 6),
            Text(_vm.errorMessage!,
                style: TextStyle(color: Colors.grey[400], fontSize: 12), textAlign: TextAlign.center),
          ],
        ),
      );
    }

    final properties = _vm.filteredProperties;

    if (properties.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.search_off_rounded, size: 56, color: Colors.grey[300]),
            const SizedBox(height: 16),
            const Text('No listings found',
                style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600, color: Colors.black54)),
            const SizedBox(height: 6),
            Text('Try adjusting your filters or search',
                style: TextStyle(fontSize: 13, color: Colors.grey[400])),
            if (_vm.hasActiveFilters) ...[
              const SizedBox(height: 16),
              TextButton(
                onPressed: () {
                  _vm.clearAllFilters();
                  _searchController.clear();
                  setState(() => _isSearching = false);
                },
                child: const Text('Clear filters'),
              ),
            ],
          ],
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: GridView.builder(
        physics: const BouncingScrollPhysics(),
        itemCount: properties.length,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 0.72,
          crossAxisSpacing: 16,
          mainAxisSpacing: 18,
        ),
        itemBuilder: (context, index) {
          final property = properties[index];
          return GestureDetector(
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => PropertyDetailScreen(property: property)),
            ),
            child: PropertyCard(property: property),
          );
        },
      ),
    );
  }

  // ── Sort / Filter Bottom Sheet ────────────────────────────────────────────────
  void _showSortFilterSheet(BuildContext context) {
    RangeValues tempRange = _vm.priceRange;
    String tempSort = _vm.sortBy;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModal) => Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          padding: EdgeInsets.only(
            left: 24, right: 24, top: 24,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 32,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40, height: 4,
                  decoration: BoxDecoration(
                      color: Colors.grey[300], borderRadius: BorderRadius.circular(2)),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Sort & Filter',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
                  TextButton(
                    onPressed: () => setModal(() {
                      tempRange = const RangeValues(0, 20000);
                      tempSort = 'Newest';
                    }),
                    child: Text('Reset', style: TextStyle(color: Colors.grey[500])),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              const Text('Sort By', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
              const SizedBox(height: 12),
              Wrap(
                spacing: 10,
                children: ['Newest', 'Lowest Price', 'Highest Price'].map((s) {
                  final isSelected = tempSort == s;
                  return GestureDetector(
                    onTap: () => setModal(() => tempSort = s),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: isSelected ? Colors.black87 : Colors.grey[100],
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                            color: isSelected ? Colors.black87 : Colors.grey.shade300),
                      ),
                      child: Text(s,
                          style: TextStyle(
                            color: isSelected ? Colors.white : Colors.black87,
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                          )),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Price Range',
                      style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                  Text('₱${tempRange.start.toInt()} – ₱${tempRange.end.toInt()}',
                      style: TextStyle(
                          color: Colors.grey[600], fontSize: 13, fontWeight: FontWeight.w500)),
                ],
              ),
              const SizedBox(height: 8),
              SliderTheme(
                data: SliderTheme.of(context).copyWith(
                  activeTrackColor: Colors.black87,
                  inactiveTrackColor: Colors.grey[200],
                  thumbColor: Colors.black87,
                  overlayColor: Colors.black.withValues(alpha: 0.1),
                  rangeThumbShape: const RoundRangeSliderThumbShape(enabledThumbRadius: 10),
                ),
                child: RangeSlider(
                  values: tempRange,
                  min: 0,
                  max: 20000,
                  divisions: 40,
                  onChanged: (values) => setModal(() => tempRange = values),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('₱0', style: TextStyle(fontSize: 11, color: Colors.grey[400])),
                  Text('₱20,000', style: TextStyle(fontSize: 11, color: Colors.grey[400])),
                ],
              ),
              const SizedBox(height: 28),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: () {
                    _vm.setPriceRange(tempRange);
                    _vm.setSortBy(tempSort);
                    Navigator.pop(ctx);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black87,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    elevation: 0,
                  ),
                  child: const Text('Apply',
                      style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
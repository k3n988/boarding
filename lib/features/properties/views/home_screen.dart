import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';

import '../viewmodels/home_viewmodel.dart';
import '../../saved/viewmodels/saved_viewmodel.dart';
import 'property_detail_screen.dart';
import 'widgets/property_card.dart';
import 'widgets/ai_banner.dart';
import '../../map/views/map_screen.dart';
import 'widgets/filter_dropdown.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Rently Brand Colors  (from logo: deep navy + green gradient + gold keyhole)
// ─────────────────────────────────────────────────────────────────────────────
class _R {
  // Navy (left leg of the R / text)
  static const navy       = Color(0xFF1B2A6B);
  static const navyLight  = Color(0xFF243580);

  // Green (roof / right side of R)
  static const green      = Color(0xFF2EB85C);
  static const greenDark  = Color(0xFF1E9448);
  static const greenLight = Color(0xFFE8F8EE);

  // Gold (keyhole accent)
  static const gold       = Color(0xFFE8A020);

  // Neutrals
  static const bg         = Color(0xFFF7F9FC);
  static const card       = Colors.white;
  static const divider    = Color(0xFFE8EDF2);
  static const textMain   = Color(0xFF0D1B3E);
  static const textSub    = Color(0xFF6B7A99);
}

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

  PropertyFilter _activeFilter = PropertyFilter.empty();

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

  void _toggleSave(property) {
    if (property?.id == null) return;
    final savedVm = context.read<SavedViewModel>();
    final nowSaved = savedVm.toggle(property);

    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(children: [
          Icon(
            nowSaved ? Icons.favorite_rounded : Icons.favorite_border_rounded,
            color: nowSaved ? Colors.red[300] : Colors.grey[400],
            size: 18,
          ),
          const SizedBox(width: 10),
          Text(
            nowSaved ? 'Added to Saved' : 'Removed from Saved',
            style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
          ),
        ]),
        backgroundColor: _R.navy,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      ),
    );
  }

  Future<void> _openFilterScreen() async {
    final result = await Navigator.push<PropertyFilter>(
      context,
      MaterialPageRoute(
        fullscreenDialog: true,
        builder: (_) => FilterScreen(initialFilter: _activeFilter),
      ),
    );
    if (result == null || !mounted) return;
    setState(() => _activeFilter = result);
    _vm.setSortBy(result.sortBy);
    _vm.setPriceRange(result.priceRange);
    if (result.propertyTypes.length == 1) {
      _vm.setCategory(result.propertyTypes.first);
    } else {
      _vm.setCategory('All');
    }
  }

  void _clearAll() {
    _vm.clearAllFilters();
    _searchController.clear();
    setState(() {
      _isSearching = false;
      _activeFilter = PropertyFilter.empty();
    });
  }

  bool get _hasAnyActiveFilter =>
      _vm.hasActiveFilters || _activeFilter.hasActiveFilters;

  @override
  Widget build(BuildContext context) {
    final savedVm = context.watch<SavedViewModel>();

    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
        if (_isSearching && _searchController.text.isEmpty) {
          setState(() => _isSearching = false);
        }
      },
      child: Scaffold(
        backgroundColor: _R.bg,
        body: SafeArea(
          bottom: false,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 12),
              _buildHeader(savedVm),
              _buildCategoryTabs(),
              const SizedBox(height: 8),
              _buildSearchBar(),
              const SizedBox(height: 14),
              const AIBanner(),
              const SizedBox(height: 18),
              _buildSectionTitle(),
              const SizedBox(height: 14),
              Expanded(child: _buildPropertyGrid(savedVm)),
            ],
          ),
        ),
      ),
    );
  }

  // ── Header ─────────────────────────────────────────────────────────────────
  Widget _buildHeader(SavedViewModel savedVm) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Logo image + wordmark
          Row(
            children: [
              // Actual logo from assets
              Image.asset(
                'public/images/logo.png',
                width: 42,
                height: 42,
                fit: BoxFit.contain,
                errorBuilder: (_, __, ___) => Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [_R.navy, _R.green],
                    ),
                    borderRadius: BorderRadius.circular(11),
                  ),
                  child: const Icon(Icons.home_rounded,
                      color: Colors.white, size: 22),
                ),
              ),
              const SizedBox(width: 10),
              // Wordmark using Poppins — matches logo's bold rounded letterforms
              Text(
                'Rently',
                style: GoogleFonts.poppins(
                  fontSize: 26,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.5,
                  color: _R.navy,
                ),
              ),
            ],
          ),

          Row(
            children: [
              // Saved count pill
              if (savedVm.savedCount > 0)
                AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  curve: Curves.easeOut,
                  margin: const EdgeInsets.only(right: 14),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: _R.greenLight,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                        color: _R.green.withOpacity(0.3)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.favorite_rounded,
                          size: 13, color: _R.green),
                      const SizedBox(width: 5),
                      Text(
                        '${savedVm.savedCount}',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: _R.green,
                        ),
                      ),
                    ],
                  ),
                ),

              // Notification bell
              Stack(
                clipBehavior: Clip.none,
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: _R.navy.withOpacity(0.08),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: const Icon(Icons.notifications_none_rounded,
                        size: 22, color: _R.navy),
                  ),
                  Positioned(
                    right: 2,
                    top: 2,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                          color: Color(0xFFFF4848),
                          shape: BoxShape.circle),
                      constraints: const BoxConstraints(
                          minWidth: 16, minHeight: 16),
                      child: const Center(
                        child: Text('2',
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 9,
                                fontWeight: FontWeight.w700)),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ── Category Tabs ──────────────────────────────────────────────────────────
  Widget _buildCategoryTabs() {
    final categories = [
      {'label': 'All',            'icon': Icons.grid_view_rounded},
      {'label': 'Boarding House', 'icon': Icons.home_rounded},
      {'label': 'Dormitory',      'icon': Icons.bedroom_child_rounded},
      {'label': 'Apartment',      'icon': Icons.apartment_rounded},
      {'label': 'Bedspace',       'icon': Icons.bed_rounded},
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: List.generate(categories.length, (i) {
            final label      = categories[i]['label'] as String;
            final icon       = categories[i]['icon']  as IconData;
            final isSelected = _vm.selectedCategory == label;

            return Padding(
              padding: EdgeInsets.only(
                  right: i < categories.length - 1 ? 20.0 : 0),
              child: GestureDetector(
                onTap: () => _vm.setCategory(label),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        // Selected = green gradient, unselected = white card
                        gradient: isSelected
                            ? const LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [_R.green, _R.greenDark],
                              )
                            : null,
                        color: isSelected ? null : Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: isSelected
                                ? _R.green.withOpacity(0.35)
                                : _R.navy.withOpacity(0.06),
                            blurRadius: isSelected ? 12 : 8,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Icon(icon,
                          color: isSelected
                              ? Colors.white
                              : _R.navy.withOpacity(0.7),
                          size: 24),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      label == 'Boarding House'
                          ? 'Boarding\nHouse'
                          : label,
                      textAlign: TextAlign.center,
                      style: GoogleFonts.poppins(
                        fontSize: 11,
                        fontWeight: isSelected
                            ? FontWeight.w700
                            : FontWeight.w500,
                        color: isSelected ? _R.green : _R.textSub,
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

  // ── Search Bar ─────────────────────────────────────────────────────────────
  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 4),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(28),
          border: Border.all(
            color: _isSearching
                ? _R.green
                : _R.divider,
            width: _isSearching ? 1.5 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: _R.navy.withOpacity(0.06),
              blurRadius: 12,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Icon(Icons.search_rounded,
                color: _isSearching ? _R.green : _R.textSub, size: 22),
            const SizedBox(width: 12),
            Expanded(
              child: TextField(
                controller: _searchController,
                focusNode: _searchFocusNode,
                decoration: InputDecoration(
                  hintText: 'Search by name, location...',
                  hintStyle:
                      TextStyle(color: Colors.grey[400], fontSize: 15),
                  border:         InputBorder.none,
                  isDense:        true,
                  contentPadding:
                      const EdgeInsets.symmetric(vertical: 10),
                ),
                cursorColor: _R.green,
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
                child: Icon(Icons.close_rounded,
                    color: Colors.grey[500], size: 20),
              )
            else ...[
              Container(
                  height: 22, width: 1, color: _R.divider),
              const SizedBox(width: 14),
              GestureDetector(
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const MapScreen()),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('Map',
                        style: TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 14,
                            color: _R.green)),
                    const SizedBox(width: 5),
                    const Icon(Icons.map_outlined,
                        color: _R.green, size: 20),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  // ── Section Title ──────────────────────────────────────────────────────────
  Widget _buildSectionTitle() {
    final label = _vm.selectedCategory == 'All'
        ? 'Available Rooms'
        : _vm.selectedCategory;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label,
                  style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: _R.textMain)),
              if (!_vm.isLoading)
                Text(
                  '${_vm.totalCount} '
                  '${_vm.totalCount == 1 ? 'listing' : 'listings'} found',
                  style: const TextStyle(
                      fontSize: 12, color: _R.textSub),
                ),
            ],
          ),
          Row(
            children: [
              // Clear filter pill
              if (_hasAnyActiveFilter)
                GestureDetector(
                  onTap: _clearAll,
                  child: Container(
                    margin: const EdgeInsets.only(right: 10),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [_R.green, _R.greenDark],
                      ),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: _R.green.withOpacity(0.3),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: const Text('Clear',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.w700)),
                  ),
                ),

              // Filter icon
              GestureDetector(
                onTap: _openFilterScreen,
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: _activeFilter.hasActiveFilters
                            ? _R.greenLight
                            : Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: _activeFilter.hasActiveFilters
                              ? _R.green.withOpacity(0.4)
                              : _R.divider,
                        ),
                      ),
                      child: Icon(
                        Icons.tune_rounded,
                        size: 20,
                        color: _activeFilter.hasActiveFilters
                            ? _R.green
                            : _R.textSub,
                      ),
                    ),
                    if (_activeFilter.activeCount > 0)
                      Positioned(
                        right: -4,
                        top: -4,
                        child: Container(
                          width: 17,
                          height: 17,
                          decoration: const BoxDecoration(
                              color: _R.green,
                              shape: BoxShape.circle),
                          child: Center(
                            child: Text(
                              '${_activeFilter.activeCount}',
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 9,
                                  fontWeight: FontWeight.w700),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ── Property Grid ──────────────────────────────────────────────────────────
  Widget _buildPropertyGrid(SavedViewModel savedVm) {
    if (_vm.isLoading) {
      return const Center(
          child: CircularProgressIndicator(
              color: _R.green, strokeWidth: 2.5));
    }

    if (_vm.errorMessage != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.cloud_off_rounded,
                size: 48, color: Colors.grey[300]),
            const SizedBox(height: 12),
            const Text('Could not load listings',
                style: TextStyle(
                    color: _R.textSub,
                    fontWeight: FontWeight.w600)),
            const SizedBox(height: 6),
            Text(_vm.errorMessage!,
                style: const TextStyle(
                    color: _R.textSub, fontSize: 12),
                textAlign: TextAlign.center),
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
            Icon(Icons.search_off_rounded,
                size: 56, color: Colors.grey[300]),
            const SizedBox(height: 16),
            const Text('No listings found',
                style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    color: _R.textMain)),
            const SizedBox(height: 6),
            const Text('Try adjusting your filters or search',
                style: TextStyle(fontSize: 13, color: _R.textSub)),
            if (_hasAnyActiveFilter) ...[
              const SizedBox(height: 16),
              TextButton(
                onPressed: _clearAll,
                style: TextButton.styleFrom(
                  foregroundColor: _R.green,
                ),
                child: const Text('Clear filters',
                    style: TextStyle(fontWeight: FontWeight.w600)),
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
          crossAxisCount:   2,
          childAspectRatio: 0.72,
          crossAxisSpacing: 16,
          mainAxisSpacing:  18,
        ),
        itemBuilder: (context, index) {
          final property = properties[index];
          final isSaved  = savedVm.isSaved(property.id);

          return GestureDetector(
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (_) =>
                      PropertyDetailScreen(property: property)),
            ),
            child: PropertyCard(
              property:     property,
              isSaved:      isSaved,
              onSaveToggle: () => _toggleSave(property),
            ),
          );
        },
      ),
    );
  }
}
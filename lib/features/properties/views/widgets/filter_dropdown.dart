import 'package:flutter/material.dart';

// ── Filter data class (passed back to HomeScreen / HomeViewModel) ─────────────
class PropertyFilter {
  final List<String> propertyTypes;
  final List<String> neighborhoods;
  final List<String> amenities;
  final List<String> tenantPreferences;
  final RangeValues  priceRange;
  final bool         availableOnly;
  final bool         locationPinnedOnly;
  final String       sortBy;

  const PropertyFilter({
    this.propertyTypes     = const [],
    this.neighborhoods     = const [],
    this.amenities         = const [],
    this.tenantPreferences = const [],
    this.priceRange        = const RangeValues(0, 20000),
    this.availableOnly     = false,
    this.locationPinnedOnly = false,
    this.sortBy            = 'Newest',
  });

  bool get hasActiveFilters =>
      propertyTypes.isNotEmpty ||
      neighborhoods.isNotEmpty ||
      amenities.isNotEmpty ||
      tenantPreferences.isNotEmpty ||
      availableOnly ||
      locationPinnedOnly ||
      sortBy != 'Newest' ||
      priceRange.start != 0 ||
      priceRange.end != 20000;

  int get activeCount {
    int count = 0;
    if (propertyTypes.isNotEmpty)     count++;
    if (neighborhoods.isNotEmpty)     count++;
    if (amenities.isNotEmpty)         count++;
    if (tenantPreferences.isNotEmpty) count++;
    if (availableOnly)                count++;
    if (locationPinnedOnly)           count++;
    if (sortBy != 'Newest')           count++;
    if (priceRange.start != 0 || priceRange.end != 20000) count++;
    return count;
  }

  PropertyFilter copyWith({
    List<String>?  propertyTypes,
    List<String>?  neighborhoods,
    List<String>?  amenities,
    List<String>?  tenantPreferences,
    RangeValues?   priceRange,
    bool?          availableOnly,
    bool?          locationPinnedOnly,
    String?        sortBy,
  }) {
    return PropertyFilter(
      propertyTypes:      propertyTypes     ?? this.propertyTypes,
      neighborhoods:      neighborhoods     ?? this.neighborhoods,
      amenities:          amenities         ?? this.amenities,
      tenantPreferences:  tenantPreferences ?? this.tenantPreferences,
      priceRange:         priceRange        ?? this.priceRange,
      availableOnly:      availableOnly     ?? this.availableOnly,
      locationPinnedOnly: locationPinnedOnly ?? this.locationPinnedOnly,
      sortBy:             sortBy            ?? this.sortBy,
    );
  }

  static PropertyFilter empty() => const PropertyFilter();
}

// ── Main Filter Screen ────────────────────────────────────────────────────────
class FilterScreen extends StatefulWidget {
  final PropertyFilter initialFilter;

  const FilterScreen({
    super.key,
    this.initialFilter = const PropertyFilter(),
  });

  @override
  State<FilterScreen> createState() => _FilterScreenState();
}

class _FilterScreenState extends State<FilterScreen> {
  late PropertyFilter _filter;
  final ScrollController _scroll = ScrollController();

  // ── Options ──────────────────────────────────────────────────────────────
  static const _propertyTypes = [
    'Boarding House', 'Dormitory', 'Apartment', 'Bedspace',
  ];
  static const _neighborhoods = [
    'Mandalagan', 'Villamonte', 'Taculing', 'Bata',
    'Estefania', 'Singcang', 'Banago', 'Sum-ag',
    'Downtown Bacolod', 'Alijis', 'Tangub', 'Handumanan',
  ];
  static const _amenities = [
    'Wi-Fi',            'Air Conditioning', 'Private Bathroom',
    'Kitchen',          'CCTV / Security',  'Laundry Area',
    'Study Room',       'Parking',          'Gym / Fitness',
    'Common Area',      'Balcony',          'Water Included',
    'Electric Included','Refrigerator',     'Washing Machine',
  ];
  static const _tenantPrefs = [
    'All / Mixed', 'Female Only', 'Male Only',
  ];
  static const _sortOptions = [
    'Newest', 'Lowest Price', 'Highest Price', 'Most Available Slots',
  ];

  bool _showAllNeighborhoods = false;
  bool _showAllAmenities     = false;

  @override
  void initState() {
    super.initState();
    _filter = widget.initialFilter;
  }

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  void _reset() => setState(() => _filter = PropertyFilter.empty());

  void _apply() => Navigator.pop(context, _filter);

  // ── Toggle helpers ────────────────────────────────────────────────────────
  void _toggleType(String v) {
    final list = List<String>.from(_filter.propertyTypes);
    list.contains(v) ? list.remove(v) : list.add(v);
    setState(() => _filter = _filter.copyWith(propertyTypes: list));
  }

  void _toggleNeighborhood(String v) {
    final list = List<String>.from(_filter.neighborhoods);
    list.contains(v) ? list.remove(v) : list.add(v);
    setState(() => _filter = _filter.copyWith(neighborhoods: list));
  }

  void _toggleAmenity(String v) {
    final list = List<String>.from(_filter.amenities);
    list.contains(v) ? list.remove(v) : list.add(v);
    setState(() => _filter = _filter.copyWith(amenities: list));
  }

  void _toggleTenant(String v) {
    final list = List<String>.from(_filter.tenantPreferences);
    list.contains(v) ? list.remove(v) : list.add(v);
    setState(() => _filter = _filter.copyWith(tenantPreferences: list));
  }

  @override
  Widget build(BuildContext context) {
    final activeCount = _filter.activeCount;

    return Scaffold(
      backgroundColor: Colors.white,
      // ── AppBar ─────────────────────────────────────────────────────────────
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.close, color: Colors.black87, size: 22),
        ),
        title: Column(
          children: [
            const Text(
              'Filters',
              style: TextStyle(
                  color: Colors.black87,
                  fontSize: 17,
                  fontWeight: FontWeight.w700),
            ),
            if (activeCount > 0)
              Text(
                '$activeCount active',
                style: TextStyle(
                    color: Colors.grey[500],
                    fontSize: 11,
                    fontWeight: FontWeight.w400),
              ),
          ],
        ),
        centerTitle: true,
        actions: [
          if (_filter.hasActiveFilters)
            TextButton(
              onPressed: _reset,
              child: const Text(
                'Reset',
                style: TextStyle(
                    color: Colors.black54,
                    fontWeight: FontWeight.w600,
                    fontSize: 14),
              ),
            ),
        ],
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(1),
          child: Divider(height: 1, thickness: 1, color: Color(0xFFF0F0F0)),
        ),
      ),

      // ── Body ───────────────────────────────────────────────────────────────
      body: CustomScrollView(
        controller: _scroll,
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 120),
            sliver: SliverList(
              delegate: SliverChildListDelegate([

                // ── SORT BY ─────────────────────────────────────────────────
                _SectionHeader(title: 'Sort By'),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _sortOptions.map((s) {
                    final sel = _filter.sortBy == s;
                    return _ChoiceChip(
                      label: s,
                      selected: sel,
                      onTap: () => setState(
                          () => _filter = _filter.copyWith(sortBy: s)),
                    );
                  }).toList(),
                ),
                _Divider(),

                // ── QUICK TOGGLES ───────────────────────────────────────────
                _SectionHeader(title: 'Quick Filters'),
                const SizedBox(height: 12),
                _ToggleTile(
                  icon: Icons.check_circle_outline_rounded,
                  label: 'Available slots only',
                  subtitle: 'Hide fully booked properties',
                  value: _filter.availableOnly,
                  onChanged: (v) => setState(
                      () => _filter = _filter.copyWith(availableOnly: v)),
                ),
                const SizedBox(height: 8),
                _ToggleTile(
                  icon: Icons.location_on_outlined,
                  label: 'Has map pin only',
                  subtitle: 'Only show properties with pinned location',
                  value: _filter.locationPinnedOnly,
                  onChanged: (v) => setState(() =>
                      _filter = _filter.copyWith(locationPinnedOnly: v)),
                ),
                _Divider(),

                // ── PROPERTY TYPE ───────────────────────────────────────────
                _SectionHeader(
                  title: 'Property Type',
                  count: _filter.propertyTypes.length,
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _propertyTypes.map((t) {
                    final sel = _filter.propertyTypes.contains(t);
                    return _ChoiceChip(
                      label: t,
                      selected: sel,
                      icon: _typeIcon(t),
                      onTap: () => _toggleType(t),
                    );
                  }).toList(),
                ),
                _Divider(),

                // ── TENANT PREFERENCE ───────────────────────────────────────
                _SectionHeader(
                  title: 'Tenant Preference',
                  count: _filter.tenantPreferences.length,
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _tenantPrefs.map((t) {
                    final sel = _filter.tenantPreferences.contains(t);
                    return _ChoiceChip(
                      label: t,
                      selected: sel,
                      icon: t == 'Female Only'
                          ? Icons.female_rounded
                          : t == 'Male Only'
                              ? Icons.male_rounded
                              : Icons.people_outline_rounded,
                      onTap: () => _toggleTenant(t),
                    );
                  }).toList(),
                ),
                _Divider(),

                // ── BUDGET ──────────────────────────────────────────────────
                _SectionHeader(
                  title: 'Monthly Budget',
                  badge: _filter.priceRange.start != 0 ||
                          _filter.priceRange.end != 20000
                      ? '₱${_fmtK(_filter.priceRange.start)} – ₱${_fmtK(_filter.priceRange.end)}'
                      : null,
                ),
                const SizedBox(height: 16),

                // Min / Max input display
                Row(children: [
                  Expanded(
                    child: _PriceBox(
                      label: 'Min',
                      value:
                          '₱ ${_filter.priceRange.start.toInt()}',
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Container(
                        width: 20, height: 1.5,
                        color: Colors.grey[300]),
                  ),
                  Expanded(
                    child: _PriceBox(
                      label: 'Max',
                      value: _filter.priceRange.end >= 20000
                          ? '₱ 20,000+'
                          : '₱ ${_filter.priceRange.end.toInt()}',
                    ),
                  ),
                ]),
                const SizedBox(height: 8),

                SliderTheme(
                  data: SliderTheme.of(context).copyWith(
                    activeTrackColor:   Colors.black87,
                    inactiveTrackColor: const Color(0xFFEEEEEE),
                    thumbColor:         Colors.black87,
                    overlayColor:
                        Colors.black.withValues(alpha: 0.08),
                    rangeThumbShape:
                        const RoundRangeSliderThumbShape(
                            enabledThumbRadius: 11),
                    trackHeight: 3,
                  ),
                  child: RangeSlider(
                    values:    _filter.priceRange,
                    min:       0,
                    max:       20000,
                    divisions: 200,
                    onChanged: (v) => setState(
                        () => _filter = _filter.copyWith(priceRange: v)),
                  ),
                ),

                // Quick price preset chips
                const SizedBox(height: 4),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _pricePreset('Under ₱2k',
                          const RangeValues(0, 2000), _filter, (v) {
                        setState(() =>
                            _filter = _filter.copyWith(priceRange: v));
                      }),
                      _pricePreset('₱2k–₱5k',
                          const RangeValues(2000, 5000), _filter, (v) {
                        setState(() =>
                            _filter = _filter.copyWith(priceRange: v));
                      }),
                      _pricePreset('₱5k–₱10k',
                          const RangeValues(5000, 10000), _filter, (v) {
                        setState(() =>
                            _filter = _filter.copyWith(priceRange: v));
                      }),
                      _pricePreset('Over ₱10k',
                          const RangeValues(10000, 20000), _filter, (v) {
                        setState(() =>
                            _filter = _filter.copyWith(priceRange: v));
                      }),
                    ],
                  ),
                ),
                _Divider(),

                // ── NEIGHBORHOODS ────────────────────────────────────────────
                _SectionHeader(
                  title: 'Neighborhood / Barangay',
                  count: _filter.neighborhoods.length,
                ),
                const SizedBox(height: 12),
                ...(_showAllNeighborhoods
                        ? _neighborhoods
                        : _neighborhoods.take(6))
                    .map((n) => _CheckRow(
                          label: n,
                          checked: _filter.neighborhoods.contains(n),
                          onTap: () => _toggleNeighborhood(n),
                        )),
                if (_neighborhoods.length > 6)
                  _ShowMoreButton(
                    expanded: _showAllNeighborhoods,
                    count:    _neighborhoods.length - 6,
                    onTap: () => setState(
                        () => _showAllNeighborhoods = !_showAllNeighborhoods),
                  ),
                _Divider(),

                // ── AMENITIES ────────────────────────────────────────────────
                _SectionHeader(
                  title: 'Amenities',
                  count: _filter.amenities.length,
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: (_showAllAmenities
                          ? _amenities
                          : _amenities.take(8))
                      .map((a) => _AmenityChip(
                            label:    a,
                            selected: _filter.amenities.contains(a),
                            onTap:    () => _toggleAmenity(a),
                          ))
                      .toList(),
                ),
                if (_amenities.length > 8)
                  _ShowMoreButton(
                    expanded: _showAllAmenities,
                    count:    _amenities.length - 8,
                    onTap: () => setState(
                        () => _showAllAmenities = !_showAllAmenities),
                  ),
              ]),
            ),
          ),
        ],
      ),

      // ── Bottom Apply bar ────────────────────────────────────────────────────
      bottomNavigationBar: Container(
        padding: EdgeInsets.fromLTRB(
            20, 12, 20, MediaQuery.of(context).padding.bottom + 12),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border(
              top: BorderSide(color: Colors.grey.shade100, width: 1.5)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 12,
              offset: const Offset(0, -3),
            ),
          ],
        ),
        child: Row(children: [
          // Reset link
          if (_filter.hasActiveFilters) ...[
            GestureDetector(
              onTap: _reset,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.refresh_rounded,
                      color: Colors.black54, size: 20),
                  const SizedBox(height: 2),
                  Text('Reset',
                      style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 11,
                          fontWeight: FontWeight.w500)),
                ],
              ),
            ),
            const SizedBox(width: 16),
          ],

          // Apply button
          Expanded(
            child: SizedBox(
              height: 52,
              child: ElevatedButton(
                onPressed: _apply,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black87,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                  elevation: 0,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('Show Results',
                        style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700)),
                    if (activeCount > 0) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.22),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          '$activeCount',
                          style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ]),
      ),
    );
  }

  IconData _typeIcon(String t) {
    switch (t) {
      case 'Boarding House': return Icons.home_rounded;
      case 'Dormitory':      return Icons.bedroom_child_rounded;
      case 'Apartment':      return Icons.apartment_rounded;
      case 'Bedspace':       return Icons.bed_rounded;
      default:               return Icons.home_rounded;
    }
  }

  String _fmtK(double v) {
    if (v >= 1000) {
      return '${(v / 1000).toStringAsFixed(v % 1000 == 0 ? 0 : 1)}k';
    }
    return v.toInt().toString();
  }
}

// ── Small reusable sub-widgets ────────────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  final String  title;
  final int?    count;
  final String? badge;
  const _SectionHeader({required this.title, this.count, this.badge});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 4),
      child: Row(children: [
        Text(title,
            style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: Colors.black87)),
        const Spacer(),
        if (badge != null)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: Colors.black87,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(badge!,
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.w600)),
          )
        else if (count != null && count! > 0)
          Container(
            width: 20, height: 20,
            decoration: const BoxDecoration(
                color: Colors.black87, shape: BoxShape.circle),
            child: Center(
              child: Text('$count',
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.w700)),
            ),
          ),
      ]),
    );
  }
}

class _Divider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 22),
      child: Divider(height: 1, thickness: 1, color: Color(0xFFF2F2F2)),
    );
  }
}

class _ChoiceChip extends StatelessWidget {
  final String   label;
  final bool     selected;
  final IconData? icon;
  final VoidCallback onTap;
  const _ChoiceChip({
    required this.label,
    required this.selected,
    required this.onTap,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
        decoration: BoxDecoration(
          color:        selected ? Colors.black87 : Colors.white,
          borderRadius: BorderRadius.circular(24),
          border:       Border.all(
            color: selected ? Colors.black87 : Colors.grey.shade300,
            width: selected ? 1.5 : 1,
          ),
          boxShadow: selected
              ? [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.12),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  )
                ]
              : [],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(icon,
                  size: 14,
                  color: selected ? Colors.white : Colors.black54),
              const SizedBox(width: 6),
            ],
            Text(label,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight:
                      selected ? FontWeight.w600 : FontWeight.w500,
                  color: selected ? Colors.white : Colors.black87,
                )),
          ],
        ),
      ),
    );
  }
}

class _AmenityChip extends StatelessWidget {
  final String     label;
  final bool       selected;
  final VoidCallback onTap;
  const _AmenityChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        decoration: BoxDecoration(
          color: selected ? Colors.black87 : const Color(0xFFF5F5F7),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: selected ? Colors.black87 : Colors.transparent,
          ),
        ),
        child: Text(label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: selected ? Colors.white : Colors.black54,
            )),
      ),
    );
  }
}

class _CheckRow extends StatelessWidget {
  final String     label;
  final bool       checked;
  final VoidCallback onTap;
  const _CheckRow({required this.label, required this.checked, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Row(children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 160),
            width: 22, height: 22,
            decoration: BoxDecoration(
              color:  checked ? Colors.black87 : Colors.white,
              border: Border.all(
                color: checked ? Colors.black87 : Colors.grey.shade300,
                width: 1.5,
              ),
              borderRadius: BorderRadius.circular(5),
            ),
            child: checked
                ? const Icon(Icons.check_rounded,
                    size: 14, color: Colors.white)
                : null,
          ),
          const SizedBox(width: 14),
          Text(label,
              style: TextStyle(
                fontSize: 14,
                color: checked ? Colors.black87 : Colors.black54,
                fontWeight:
                    checked ? FontWeight.w600 : FontWeight.w400,
              )),
        ]),
      ),
    );
  }
}

class _ToggleTile extends StatelessWidget {
  final IconData icon;
  final String   label;
  final String   subtitle;
  final bool     value;
  final ValueChanged<bool> onChanged;
  const _ToggleTile({
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onChanged(!value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: value ? Colors.black87 : const Color(0xFFF8F8F8),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: value ? Colors.black87 : Colors.grey.shade200,
          ),
        ),
        child: Row(children: [
          Icon(icon,
              size: 20,
              color: value ? Colors.white : Colors.black45),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: value ? Colors.white : Colors.black87,
                    )),
                Text(subtitle,
                    style: TextStyle(
                      fontSize: 11,
                      color: value
                          ? Colors.white.withValues(alpha: 0.65)
                          : Colors.grey[500],
                    )),
              ],
            ),
          ),
          AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            width: 46, height: 26,
            decoration: BoxDecoration(
              color: value
                  ? Colors.white.withValues(alpha: 0.25)
                  : Colors.grey.shade300,
              borderRadius: BorderRadius.circular(13),
            ),
            child: AnimatedAlign(
              duration: const Duration(milliseconds: 180),
              alignment:
                  value ? Alignment.centerRight : Alignment.centerLeft,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 3),
                child: Container(
                  width: 20, height: 20,
                  decoration: BoxDecoration(
                    color: value ? Colors.white : Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                          color: Colors.black.withValues(alpha: 0.15),
                          blurRadius: 3),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ]),
      ),
    );
  }
}

class _PriceBox extends StatelessWidget {
  final String label;
  final String value;
  const _PriceBox({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F8F8),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: TextStyle(
                  fontSize: 10,
                  color: Colors.grey[500],
                  fontWeight: FontWeight.w500)),
          const SizedBox(height: 2),
          Text(value,
              style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: Colors.black87)),
        ],
      ),
    );
  }
}

// Price preset chip
Widget _pricePreset(
  String label,
  RangeValues target,
  PropertyFilter current,
  void Function(RangeValues) onTap,
) {
  final sel = current.priceRange.start == target.start &&
      current.priceRange.end == target.end;
  return GestureDetector(
    onTap: () => onTap(sel
        ? const RangeValues(0, 20000)
        : target), // toggle off if already selected
    child: AnimatedContainer(
      duration: const Duration(milliseconds: 160),
      margin: const EdgeInsets.only(right: 8, top: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: sel ? Colors.black87 : const Color(0xFFF2F2F2),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: sel ? Colors.white : Colors.black54,
          )),
    ),
  );
}

class _ShowMoreButton extends StatelessWidget {
  final bool     expanded;
  final int      count;
  final VoidCallback onTap;
  const _ShowMoreButton({
    required this.expanded,
    required this.count,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.only(top: 10),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Icon(
            expanded
                ? Icons.keyboard_arrow_up_rounded
                : Icons.keyboard_arrow_down_rounded,
            size: 18,
            color: Colors.black54,
          ),
          const SizedBox(width: 4),
          Text(
            expanded ? 'Show less' : 'Show $count more',
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Colors.black54,
            ),
          ),
        ]),
      ),
    );
  }
}
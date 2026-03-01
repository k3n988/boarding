import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../data/models/property_model.dart';

class PropertyCard extends StatefulWidget {
  final PropertyModel property;
  final bool isSaved;
  final VoidCallback? onSaveToggle;

  const PropertyCard({
    super.key,
    required this.property,
    this.isSaved = false,
    this.onSaveToggle,
  });

  @override
  State<PropertyCard> createState() => _PropertyCardState();
}

class _PropertyCardState extends State<PropertyCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _heartCtrl;
  late Animation<double> _heartScale;
  late bool _saved;

  @override
  void initState() {
    super.initState();
    _saved = widget.isSaved;
    _heartCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    );
    _heartScale = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween(begin: 1.0, end: 1.45)
            .chain(CurveTween(curve: Curves.easeOut)),
        weight: 45,
      ),
      TweenSequenceItem(
        tween: Tween(begin: 1.45, end: 1.0)
            .chain(CurveTween(curve: Curves.elasticOut)),
        weight: 55,
      ),
    ]).animate(_heartCtrl);
  }

  @override
  void didUpdateWidget(PropertyCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isSaved != _saved) {
      setState(() => _saved = widget.isSaved);
    }
  }

  @override
  void dispose() {
    _heartCtrl.dispose();
    super.dispose();
  }

  void _toggleSave() {
    HapticFeedback.lightImpact();
    setState(() => _saved = !_saved);
    _heartCtrl.forward(from: 0);
    widget.onSaveToggle?.call();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Cover Image ──────────────────────────────────────────────────
          Expanded(
            flex: 6,
            child: Stack(
              children: [
                // Photo
                ClipRRect(
                  borderRadius: const BorderRadius.only(
                    topLeft:  Radius.circular(16),
                    topRight: Radius.circular(16),
                  ),
                  child: property.imageUrl.isNotEmpty
                      ? Image.network(
                          property.imageUrl,
                          width: double.infinity,
                          height: double.infinity,
                          fit: BoxFit.cover,
                          errorBuilder: (_, _e, _s) => _imageFallback(),
                        )
                      : _imageFallback(),
                ),

                // Subtle bottom gradient
                Positioned(
                  bottom: 0, left: 0, right: 0,
                  child: ClipRRect(
                    child: SizedBox(
                      height: 48,
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.bottomCenter,
                            end: Alignment.topCenter,
                            colors: [
                              Colors.black.withValues(alpha: 0.38),
                              Colors.transparent,
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),

                // Category badge — top left
                Positioned(
                  top: 10, left: 10,
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.65),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      _shortCategory(property.category),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.3,
                      ),
                    ),
                  ),
                ),

                // ── Heart / Save button — top right ──────────────────────
                Positioned(
                  top: 8, right: 8,
                  child: GestureDetector(
                    onTap: _toggleSave,
                    behavior: HitTestBehavior.opaque,
                    child: AnimatedBuilder(
                      animation: _heartScale,
                      builder: (_, _w) => Transform.scale(
                        scale: _heartScale.value,
                        child: Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            color: _saved
                                ? Colors.red.withValues(alpha: 0.92)
                                : Colors.white.withValues(alpha: 0.88),
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.18),
                                blurRadius: 6,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Icon(
                            _saved
                                ? Icons.favorite_rounded
                                : Icons.favorite_border_rounded,
                            size: 17,
                            color: _saved ? Colors.white : Colors.grey[600],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),

                // Tenant badge — bottom left
                if (property.tenantPreference != 'All / Mixed')
                  Positioned(
                    bottom: 8, left: 10,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 7, vertical: 3),
                      decoration: BoxDecoration(
                        color: property.tenantPreference == 'Female Only'
                            ? Colors.pink.withValues(alpha: 0.88)
                            : Colors.blue.withValues(alpha: 0.88),
                        borderRadius: BorderRadius.circular(7),
                      ),
                      child: Text(
                        property.tenantPreference == 'Female Only'
                            ? '♀ Female'
                            : '♂ Male',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 9,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),

          // ── Info Panel ───────────────────────────────────────────────────
          Expanded(
            flex: 4,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(10, 8, 10, 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Title
                  Text(
                    property.title,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: Colors.black87,
                      height: 1.2,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),

                  // Location
                  Row(
                    children: [
                      Icon(Icons.location_on_outlined,
                          size: 11, color: Colors.grey[500]),
                      const SizedBox(width: 3),
                      Expanded(
                        child: Text(
                          property.location,
                          style: TextStyle(
                              fontSize: 10, color: Colors.grey[500]),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),

                  // Price + Slots
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '₱${_formatPrice(property.price)}/mo',
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w800,
                                color: Colors.black87,
                              ),
                            ),
                            if (property.dailyPrice != null &&
                                property.dailyPrice! > 0)
                              Text(
                                '₱${_formatPrice(property.dailyPrice!)}/day',
                                style: TextStyle(
                                  fontSize: 9,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.grey[500],
                                ),
                              ),
                          ],
                        ),
                      ),
                      if (property.availableSlots > 0)
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 3),
                          decoration: BoxDecoration(
                            color: Colors.green[50],
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            '${property.availableSlots} left',
                            style: TextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.w700,
                              color: Colors.green[700],
                            ),
                          ),
                        )
                      else
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 3),
                          decoration: BoxDecoration(
                            color: Colors.red[50],
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            'Full',
                            style: TextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.w700,
                              color: Colors.red[400],
                            ),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  PropertyModel get property => widget.property;

  Widget _imageFallback() => Container(
        width: double.infinity,
        height: double.infinity,
        color: const Color(0xFFF3F5F7),
        child: Center(
          child: Icon(Icons.home_work_outlined,
              size: 36, color: Colors.grey[400]),
        ),
      );

  String _shortCategory(String cat) {
    switch (cat) {
      case 'Boarding House': return 'BH';
      case 'Dormitory':      return 'Dorm';
      case 'Apartment':      return 'Apt';
      case 'Bedspace':       return 'Bed';
      default:               return cat;
    }
  }

  String _formatPrice(double price) {
    if (price >= 1000) {
      return '${(price / 1000).toStringAsFixed(price % 1000 == 0 ? 0 : 1)}k';
    }
    return price.toStringAsFixed(0);
  }
}
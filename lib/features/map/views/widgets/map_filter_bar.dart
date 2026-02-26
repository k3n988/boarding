import 'package:flutter/material.dart';

// ✅ Correct path: from views/widgets → go up two levels to viewmodels/
import '../../viewmodels/map_viewmodel.dart';

class MapFilterBar extends StatelessWidget {
  final MapViewModel viewModel;

  const MapFilterBar({super.key, required this.viewModel});

  Color _chipColor(String category, bool isSelected) {
    if (!isSelected) return Colors.white;
    switch (category) {
      case 'Boarding House': return Colors.red.shade600;
      case 'Dormitory': return Colors.blue.shade600;
      case 'Apartment': return Colors.green.shade600;
      case 'Bedspace': return Colors.orange.shade600;
      default: return Colors.black;
    }
  }

  IconData _chipIcon(String category) {
    switch (category) {
      case 'Boarding House': return Icons.home_rounded;
      case 'Dormitory': return Icons.bedroom_child_rounded;
      case 'Apartment': return Icons.apartment_rounded;
      case 'Bedspace': return Icons.bed_rounded;
      default: return Icons.map_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Row(
        children: MapViewModel.categories.map((category) {
          final isSelected = viewModel.selectedCategory == category;
          final chipColor = _chipColor(category, isSelected);

          return GestureDetector(
            onTap: () => viewModel.filterByCategory(category),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.only(right: 8),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: chipColor,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(isSelected ? 0.15 : 0.06),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
                border: Border.all(
                  color: isSelected ? Colors.transparent : Colors.grey.shade200,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    _chipIcon(category),
                    size: 15,
                    color: isSelected ? Colors.white : Colors.black54,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    category,
                    style: TextStyle(
                      color: isSelected ? Colors.white : Colors.black87,
                      fontWeight:
                          isSelected ? FontWeight.bold : FontWeight.w500,
                      fontSize: 13,
                    ),
                  ),
                  if (isSelected) ...[
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 1),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        '${viewModel.filteredMarkers.length}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
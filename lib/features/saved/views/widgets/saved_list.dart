import 'package:flutter/material.dart';

import '../../data/models/saved_item_model.dart';
import 'saved_property_card.dart';

class SavedList extends StatelessWidget {
  final List<SavedItemModel> items;
  final void Function(String propertyId)? onUnsave;
  final void Function(String propertyId)? onTap;   // ← NEW

  const SavedList({
    super.key,
    required this.items,
    this.onUnsave,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) return const _EmptyState();

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        return SavedPropertyCard(
          item:     item,
          onUnsave: onUnsave != null ? () => onUnsave!(item.id) : null,
          onTap:    onTap    != null ? () => onTap!(item.id)    : null, // ← NEW
        );
      },
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: Colors.grey[100],
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.favorite_border_rounded,
                size: 36, color: Colors.grey[400]),
          ),
          const SizedBox(height: 16),
          const Text(
            'Nothing saved yet',
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w700,
              color: Colors.black54,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Tap the ♡ on any listing to save it here',
            style: TextStyle(fontSize: 13, color: Colors.grey[400]),
          ),
        ],
      ),
    );
  }
}
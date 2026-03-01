import 'package:flutter/material.dart';

import '../../properties/data/models/property_model.dart';
import '../data/models/saved_item_model.dart';

class SavedViewModel extends ChangeNotifier {
  final Map<String, PropertyModel> _saved = {};

  bool get isEmpty    => _saved.isEmpty;
  int  get savedCount => _saved.length;

  bool isSaved(String? propertyId) {
    if (propertyId == null || propertyId.isEmpty) return false;
    return _saved.containsKey(propertyId);
  }

  bool toggle(PropertyModel property) {
    final id = property.id ?? '';
    if (id.isEmpty) return false;
    if (_saved.containsKey(id)) {
      _saved.remove(id);
      notifyListeners();
      return false;
    } else {
      _saved[id] = property;
      notifyListeners();
      return true;
    }
  }

  void unsaveById(String id) {
    if (_saved.containsKey(id)) {
      _saved.remove(id);
      notifyListeners();
    }
  }

  /// Returns the full PropertyModel for navigation — used by SavedScreen.
  PropertyModel? getById(String id) => _saved[id];

  void clearAll() {
    _saved.clear();
    notifyListeners();
  }

  // ── Filtered lists ────────────────────────────────────────────────────────

  List<SavedItemModel> get _allItems =>
      _saved.values.map((p) => SavedItemModel.fromProperty(p)).toList();

  List<SavedItemModel> _byType(String type) =>
      _allItems.where((i) => i.type == type).toList();

  List<SavedItemModel> get allItems           => _allItems;
  List<SavedItemModel> get boardingHouseItems => _byType('Boarding House');
  List<SavedItemModel> get dormItems          => _byType('Dormitory');
  List<SavedItemModel> get apartmentItems     => _byType('Apartment');
  List<SavedItemModel> get bedspaceItems      => _byType('Bedspace');
}
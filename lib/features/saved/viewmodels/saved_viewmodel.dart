import 'package:flutter/foundation.dart';

import '../data/models/saved_item_model.dart';
import '../data/repositories/saved_repository.dart';
import '../data/repositories/saved_repository_impl.dart';

class SavedViewModel extends ChangeNotifier {
  final SavedRepository _repository = SavedRepositoryImpl();

  List<SavedItemModel> _boardingHouseItems = [];
  List<SavedItemModel> _dormItems = [];
  List<SavedItemModel> _apartmentItems = [];
  List<SavedItemModel> _bedspaceItems = [];

  bool _isLoading = false;

  List<SavedItemModel> get boardingHouseItems => _boardingHouseItems;
  List<SavedItemModel> get dormItems => _dormItems;
  List<SavedItemModel> get apartmentItems => _apartmentItems;
  List<SavedItemModel> get bedspaceItems => _bedspaceItems;
  bool get isLoading => _isLoading;

  Future<void> loadSaved() async {
    _isLoading = true;
    notifyListeners();

    try {
      _boardingHouseItems = await _repository.getSavedBoardingHouses();
      _dormItems = await _repository.getSavedDorms();
      _apartmentItems = await _repository.getSavedApartments();
      _bedspaceItems = await _repository.getSavedBedspaces();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}

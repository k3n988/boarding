import '../models/saved_item_model.dart';

abstract class SavedRepository {
  Future<List<SavedItemModel>> getSavedBoardingHouses();
  Future<List<SavedItemModel>> getSavedDorms();
  Future<List<SavedItemModel>> getSavedApartments();
  Future<List<SavedItemModel>> getSavedBedspaces();
}

import '../models/property_model.dart';

abstract class PropertyRepository {
  Future<List<PropertyModel>> getProperties();
}

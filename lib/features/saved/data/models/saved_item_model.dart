import '../../../properties/data/models/property_model.dart';

class SavedItemModel {
  final String id;
  final String title;
  final String imageUrl;
  final String location;
  final String type;         // mapped from PropertyModel.category
  final List<String> tags;   // mapped from PropertyModel.amenities
  final String price;
  final String originalPrice;

  const SavedItemModel({
    required this.id,
    required this.title,
    required this.imageUrl,
    required this.location,
    required this.type,
    required this.tags,
    required this.price,
    required this.originalPrice,
  });

  factory SavedItemModel.fromProperty(PropertyModel p) {
    final rawPrice     = p.price.toInt();
    final fakeOriginal = (p.price * 1.15).toInt();

    // Use first imageUrls entry, fall back to imageUrl
    final image = p.imageUrls.isNotEmpty ? p.imageUrls.first : p.imageUrl;

    return SavedItemModel(
      id:            p.id            ?? '',
      title:         p.title,
      imageUrl:      image,
      location:      p.location,
      type:          p.category,     // e.g. "Boarding House", "Dormitory"
      tags:          p.amenities,
      price:         rawPrice.toString(),
      originalPrice: fakeOriginal.toString(),
    );
  }
}
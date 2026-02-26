/// Model for a saved/wishlisted property item.
class SavedItemModel {
  final String title;
  final String location;
  final String price;
  final String originalPrice;
  final String rating;
  final String reviewCount;
  final String imageUrl;
  final List<String> tags;

  const SavedItemModel({
    required this.title,
    required this.location,
    required this.price,
    required this.originalPrice,
    required this.rating,
    required this.reviewCount,
    required this.imageUrl,
    required this.tags,
  });
}

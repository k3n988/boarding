class MapMarkerModel {
  final String id;
  final double lat;
  final double lng;
  final String title;
  final String category;
  final double price;
  final String imageUrl;
  final String location;
  final int availableSlots;
  final String tenantPreference;
  final String status;

  const MapMarkerModel({
    required this.id,
    required this.lat,
    required this.lng,
    required this.title,
    required this.category,
    required this.price,
    required this.imageUrl,
    required this.location,
    required this.availableSlots,
    required this.tenantPreference,
    this.status = 'Active',
  });

  factory MapMarkerModel.fromMap(Map<String, dynamic> map, String documentId) {
    return MapMarkerModel(
      id: documentId,
      lat: (map['latitude'] ?? 0).toDouble(),
      lng: (map['longitude'] ?? 0).toDouble(),
      title: map['title'] ?? '',
      category: map['category'] ?? 'Boarding House',
      price: (map['price'] ?? 0).toDouble(),
      imageUrl: map['imageUrl'] ?? '',
      location: map['location'] ?? '',
      availableSlots: map['availableSlots']?.toInt() ?? 0,
      tenantPreference: map['tenantPreference'] ?? 'All / Mixed',
      status: map['status'] ?? 'Active',
    );
  }
}
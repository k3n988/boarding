class MapMarkerModel {
  final String id;
  final double lat;
  final double lng;
  final String title;
  final String category;
  final double price;
  final double? dailyPrice;
  final String imageUrl;
  final String location;
  final int availableSlots;
  final String tenantPreference;
  final List<String> amenities;
  final List<String> highlights;
  final String description;
  final String policies;
  final String hostId;
  final String status;

  const MapMarkerModel({
    required this.id,
    required this.lat,
    required this.lng,
    required this.title,
    required this.category,
    required this.price,
    this.dailyPrice,
    required this.imageUrl,
    required this.location,
    required this.availableSlots,
    required this.tenantPreference,
    this.amenities = const [],
    this.highlights = const [],
    this.description = '',
    this.policies = '',
    this.hostId = '',
    this.status = 'Active',
  });

  factory MapMarkerModel.fromMap(
      Map<String, dynamic> map, String documentId) {
    return MapMarkerModel(
      id: documentId,
      lat: (map['latitude'] ?? 0).toDouble(),
      lng: (map['longitude'] ?? 0).toDouble(),
      title: map['title'] ?? '',
      category: map['category'] ?? 'Boarding House',
      price: (map['price'] ?? 0).toDouble(),
      dailyPrice: map['dailyPrice'] != null
          ? (map['dailyPrice'] as num).toDouble()
          : null,
      imageUrl: map['imageUrl'] ?? '',
      location: map['location'] ?? '',
      availableSlots: map['availableSlots']?.toInt() ?? 0,
      tenantPreference: map['tenantPreference'] ?? 'All / Mixed',
      amenities: List<String>.from(map['amenities'] ?? []),
      highlights: List<String>.from(map['highlights'] ?? []),
      description: map['description'] ?? '',
      policies: map['policies'] ?? '',
      hostId: map['hostId'] ?? '',
      status: map['status'] ?? 'Active',
    );
  }
}
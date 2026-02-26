import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/map_marker_model.dart';

class MapRepository {
  final FirebaseFirestore _firestore;

  MapRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  /// Fetches all Active listings that have lat/lng pinned
  Future<List<MapMarkerModel>> fetchPinnedListings({String? category}) async {
    Query query = _firestore
        .collection('listings')
        .where('status', isEqualTo: 'Active')
        .where('isLocationPinned', isEqualTo: true);

    if (category != null && category != 'All') {
      query = query.where('category', isEqualTo: category);
    }

    final snapshot = await query.get();

    return snapshot.docs
        .map((doc) => MapMarkerModel.fromMap(
            doc.data() as Map<String, dynamic>, doc.id))
        .where((m) => m.lat != 0 && m.lng != 0) // safety check
        .toList();
  }

  /// Real-time stream of all pinned listings (auto-updates when new ones are posted)
  Stream<List<MapMarkerModel>> streamPinnedListings() {
    return _firestore
        .collection('listings')
        .where('status', isEqualTo: 'Active')
        .where('isLocationPinned', isEqualTo: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => MapMarkerModel.fromMap(
                doc.data(), doc.id))
            .where((m) => m.lat != 0 && m.lng != 0)
            .toList());
  }
}
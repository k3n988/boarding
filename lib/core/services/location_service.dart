abstract class LocationService {
  Future<void> requestPermission();
  Future<({double lat, double lng})?> getCurrentLocation();
}

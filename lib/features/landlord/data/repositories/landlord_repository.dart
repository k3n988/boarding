import '../models/host_model.dart';

abstract class LandlordRepository {
  Future<HostModel?> getHostProfile();
}

import '../models/booking_model.dart';

abstract class BookingRepository {
  Future<List<BookingModel>> getBookings();
}

import '../../app/core/network/api_client.dart';
import '../models/booking_model.dart';
import '../models/table_model.dart';

class BookingRepository {
  final ApiClient _apiClient;

  BookingRepository(this._apiClient);

  Future<List<TableModel>> checkAvailability({
    required String date,
    required String startTime,
    int guestCount = 2,
  }) async {
    final response = await _apiClient.get('/bookings/availability', queryParameters: {
      'date': date,
      'startTime': startTime,
      'guestCount': guestCount.toString(),
    });
    final List<dynamic> list = response.data['data'];
    return list.map((json) => TableModel.fromJson(json)).toList();
  }

  Future<void> createHold({
    required String tableId,
    required String bookingDate,
    required String startTime,
    required String endTime,
  }) async {
    await _apiClient.post('/bookings/hold', data: {
      'tableId': tableId,
      'bookingDate': bookingDate,
      'startTime': startTime,
      'endTime': endTime,
    });
  }

  Future<BookingModel> createBooking({
    required String tableId,
    required int guestCount,
    required String bookingDate,
    required String startTime,
    required String endTime,
  }) async {
    final response = await _apiClient.post('/bookings', data: {
      'tableId': tableId,
      'guestCount': guestCount,
      'bookingDate': bookingDate,
      'startTime': startTime,
      'endTime': endTime,
    });
    return BookingModel.fromJson(response.data['data']);
  }

  Future<List<BookingModel>> getMyBookings() async {
    final response = await _apiClient.get('/bookings/my');
    final List<dynamic> list = response.data['data'];
    return list.map((json) => BookingModel.fromJson(json)).toList();
  }
}

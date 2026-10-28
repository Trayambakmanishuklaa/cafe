import '../../app/core/network/api_client.dart';
import '../models/order_model.dart';

class OrderRepository {
  final ApiClient _apiClient;

  OrderRepository(this._apiClient);

  Future<OrderModel> createOrder({
    required String orderType,
    String? tableId,
    String? bookingId,
    String? couponCode,
    required List<Map<String, dynamic>> items,
  }) async {
    final response = await _apiClient.post('/orders', data: {
      'orderType': orderType,
      'tableId': tableId,
      'bookingId': bookingId,
      'couponCode': couponCode,
      'items': items,
    });
    return OrderModel.fromJson(response.data['data']);
  }

  Future<List<OrderModel>> getMyOrders() async {
    final response = await _apiClient.get('/orders/my');
    final List<dynamic> list = response.data['data'];
    return list.map((json) => OrderModel.fromJson(json)).toList();
  }

  Future<List<OrderModel>> getStaffQueue() async {
    final response = await _apiClient.get('/orders/staff/queue');
    final List<dynamic> list = response.data['data'];
    return list.map((json) => OrderModel.fromJson(json)).toList();
  }

  Future<OrderModel> updateStatus(String orderId, String status) async {
    final response = await _apiClient.patch('/orders/$orderId/status', data: {
      'status': status,
    });
    return OrderModel.fromJson(response.data['data']);
  }
}

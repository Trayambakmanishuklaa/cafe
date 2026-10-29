import '../../app/core/network/api_client.dart';
import '../models/order_model.dart';

class OrderRepository {
  final ApiClient _apiClient;

  OrderRepository(this._apiClient);

  Map<String, dynamic> _extractMap(dynamic responseData) {
    if (responseData is Map) {
      if (responseData['data'] is Map) {
        return Map<String, dynamic>.from(responseData['data']);
      }
      return Map<String, dynamic>.from(responseData);
    }
    return <String, dynamic>{};
  }

  List<dynamic> _extractList(dynamic responseData) {
    if (responseData is Map && responseData['data'] is List) {
      return responseData['data'] as List<dynamic>;
    }
    if (responseData is List) {
      return responseData;
    }
    return <dynamic>[];
  }

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
    return OrderModel.fromJson(_extractMap(response.data));
  }

  Future<List<OrderModel>> getMyOrders() async {
    final response = await _apiClient.get('/orders/my');
    final list = _extractList(response.data);
    return list.map((json) => OrderModel.fromJson(json)).toList();
  }

  Future<List<OrderModel>> getStaffQueue() async {
    final response = await _apiClient.get('/orders/staff/queue');
    final list = _extractList(response.data);
    return list.map((json) => OrderModel.fromJson(json)).toList();
  }

  Future<OrderModel> updateStatus(String orderId, String status) async {
    final response = await _apiClient.patch('/orders/$orderId/status', data: {
      'status': status,
    });
    return OrderModel.fromJson(_extractMap(response.data));
  }
}

import 'package:dio/dio.dart';

class ErrorUtils {
  static String getCleanMessage(dynamic e) {
    if (e is DioException) {
      if (e.error != null && e.error.toString().isNotEmpty) {
        return e.error.toString();
      }
      if (e.response?.data != null && e.response?.data is Map) {
        final data = e.response?.data as Map;
        if (data['message'] != null) {
          return data['message'].toString();
        }
      }
      return e.message ?? 'Network error occurred';
    }
    return e.toString().replaceAll('Exception: ', '');
  }
}

import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:get/get.dart' as get_x;

import '../constants/api_constants.dart';
import '../storage/storage_service.dart';

class ApiClient {
  late final Dio _dio;

  ApiClient() {
    _dio = Dio(
      BaseOptions(
        baseUrl: ApiConstants.baseUrl,
        connectTimeout: const Duration(seconds: 35), // Extended for Render free tier cold start
        receiveTimeout: const Duration(seconds: 35),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final storageService = get_x.Get.find<StorageService>();
          final token = await storageService.getToken();
          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          return handler.next(options);
        },
        onResponse: (response, handler) {
          if (response.data is String) {
            try {
              response.data = json.decode(response.data as String);
            } catch (_) {
              // Server returned HTML or non-JSON string
            }
          }
          return handler.next(response);
        },
        onError: (DioException e, handler) {
          final statusCode = e.response?.statusCode;
          dynamic resData = e.response?.data;

          if (resData is String) {
            try {
              resData = json.decode(resData);
            } catch (_) {
              resData = null;
            }
          }

          String message = 'Network error occurred';
          if (resData is Map && resData['message'] != null) {
            message = resData['message'].toString();
          } else if (e.message != null && e.message!.isNotEmpty) {
            message = e.message!;
          }

          if (statusCode == 401) {
            final storageService = get_x.Get.find<StorageService>();
            storageService.clearAll();
          }

          return handler.next(
            DioException(
              requestOptions: e.requestOptions,
              response: e.response,
              type: e.type,
              error: message,
            ),
          );
        },
      ),
    );
  }

  Future<Response> get(String path, {Map<String, dynamic>? queryParameters}) async {
    return await _dio.get(path, queryParameters: queryParameters);
  }

  Future<Response> post(String path, {dynamic data}) async {
    return await _dio.post(path, data: data);
  }

  Future<Response> patch(String path, {dynamic data}) async {
    return await _dio.patch(path, data: data);
  }

  Future<Response> delete(String path) async {
    return await _dio.delete(path);
  }
}

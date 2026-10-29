import '../../app/core/network/api_client.dart';
import '../models/category_model.dart';
import '../models/product_model.dart';

class MenuRepository {
  final ApiClient _apiClient;

  MenuRepository(this._apiClient);

  List<dynamic> _extractList(dynamic responseData) {
    if (responseData is Map && responseData['data'] is List) {
      return responseData['data'] as List<dynamic>;
    }
    if (responseData is List) {
      return responseData;
    }
    return <dynamic>[];
  }

  Future<List<CategoryModel>> getCategories() async {
    final response = await _apiClient.get('/categories');
    final list = _extractList(response.data);
    return list.map((json) => CategoryModel.fromJson(json)).toList();
  }

  Future<List<ProductModel>> getProducts({String? categorySlug, String? search}) async {
    final query = <String, dynamic>{};
    if (categorySlug != null && categorySlug.isNotEmpty) {
      query['categorySlug'] = categorySlug;
    }
    if (search != null && search.isNotEmpty) {
      query['search'] = search;
    }

    final response = await _apiClient.get('/products', queryParameters: query);
    final list = _extractList(response.data);
    return list.map((json) => ProductModel.fromJson(json)).toList();
  }
}

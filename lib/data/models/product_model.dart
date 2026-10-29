class ProductModel {
  final String id;
  final String categoryId;
  final String name;
  final String description;
  final double price;
  final String? imageUrl;
  final bool isAvailable;
  final int stockCount;
  final bool isVeg;
  final int prepTimeMinutes;

  ProductModel({
    required this.id,
    required this.categoryId,
    required this.name,
    required this.description,
    required this.price,
    this.imageUrl,
    this.isAvailable = true,
    this.stockCount = 100,
    this.isVeg = true,
    this.prepTimeMinutes = 10,
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
      id: json['id'] ?? '',
      categoryId: json['categoryId'] ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      imageUrl: json['imageUrl'],
      isAvailable: json['isAvailable'] ?? true,
      stockCount: (json['stockCount'] as num?)?.toInt() ?? 100,
      isVeg: json['isVeg'] ?? true,
      prepTimeMinutes: (json['prepTimeMinutes'] as num?)?.toInt() ?? 10,
    );
  }
}

class CategoryModel {
  final String id;
  final String name;
  final String slug;
  final String? description;
  final String? icon;
  final int sortOrder;

  CategoryModel({
    required this.id,
    required this.name,
    required this.slug,
    this.description,
    this.icon,
    this.sortOrder = 0,
  });

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      slug: json['slug'] ?? '',
      description: json['description'],
      icon: json['icon'],
      sortOrder: json['sortOrder'] ?? 0,
    );
  }
}

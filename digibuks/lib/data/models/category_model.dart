class CategoryModel {
  final String id;
  final String name;
  final String? parentId;

  CategoryModel({
    required this.id,
    required this.name,
    this.parentId,
  });

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      parentId: json['parent_id']?.toString(),
    );
  }
}

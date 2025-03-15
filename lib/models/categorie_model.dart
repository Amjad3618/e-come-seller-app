/// Model class for Category
class CategorieModel {
  final String id;
  final String name;
  final String image;
  final int priority;

  CategorieModel({
    required this.id,
    required this.name,
    required this.image,
    required this.priority,
  });

  /// Create a CategoryModel from JSON
  factory CategorieModel.fromJson(Map<String, dynamic> json) {
    return CategorieModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      image: json['image'] ?? '',
      priority: json['priority'] ?? 0,
    );
  }

  /// Convert CategoryModel to JSON
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'image': image,
      'priority': priority,
    };
  }

  /// Create a copy of CategoryModel with some changes
  CategorieModel copyWith({
    String? id,
    String? name,
    String? image,
    int? priority,
  }) {
    return CategorieModel(
      id: id ?? this.id,
      name: name ?? this.name,
      image: image ?? this.image,
      priority: priority ?? this.priority,
    );
  }
}
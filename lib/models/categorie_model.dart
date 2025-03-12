class CategorieModel {
  String name;
  int id;
  String image;
  int priority;

  CategorieModel({
    required this.name,
    required this.id,
    required this.image,
    required this.priority,
  });

  // Factory constructor to create an instance from JSON
  factory CategorieModel.fromJson(Map<String, dynamic> json) {
    return CategorieModel(
      name: json['name'],
      id: json['id'],
      image: json['image'],
      priority: json['priority'],
    );
  }

  // Method to convert an instance to JSON
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'id': id,
      'image': image,
      'priority': priority,
    };
  }
}
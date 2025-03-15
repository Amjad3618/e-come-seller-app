import 'package:cloud_firestore/cloud_firestore.dart';

class ProductsModel {
  String name;
  String description;
  List<String> images; // Change `image` to `images` (List of image URLs)
  int old_price;
  int new_price;
  String category;
  String id;
  int maxQuantity;

  ProductsModel({
    required this.name,
    required this.description,
    required this.images,
    required this.old_price,
    required this.new_price,
    required this.category,
    required this.id,
    required this.maxQuantity,
  });

  // Convert JSON to object model
  factory ProductsModel.fromJson(Map<String, dynamic> json, String id) {
    return ProductsModel(
      name: json["name"] ?? "",
      description: json["desc"] ?? "No description",
      images: (json["images"] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
      new_price: json["new_price"] ?? 0,
      old_price: json["old_price"] ?? 0,
      category: json["category"] ?? "",
      maxQuantity: json["quantity"] ?? 0,
      id: id,
    );
  }

  // Convert List<QueryDocumentSnapshot> to List<ProductModel>
  static List<ProductsModel> fromJsonList(List<QueryDocumentSnapshot> list) {
    return list.map((e) => ProductsModel.fromJson(e.data() as Map<String, dynamic>, e.id)).toList();
  }

  // Convert object to JSON for Firestore
  Map<String, dynamic> toJson() {
    return {
      "name": name,
      "desc": description,
      "images": images, // Store multiple images as a list
      "new_price": new_price,
      "old_price": old_price,
      "category": category,
      "quantity": maxQuantity,
    };
  }
}

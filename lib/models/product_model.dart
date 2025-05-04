import 'package:cloud_firestore/cloud_firestore.dart';

class ProductsModel {
  final String id;
  final String name;
  final String description;
  final List<String> images;
  final int oldPrice;
  final int newPrice;
  final String category;
  final String categoryId;   // Added category ID field
  final int quantity;
  final String sellerId;
  final DateTime createdAt;
  final DateTime? updatedAt;

  ProductsModel({
    required this.id,
    required this.name,
    required this.description,
    required this.images,
    required this.oldPrice,
    required this.newPrice,
    required this.category,
    required this.categoryId, // Added category ID field
    required this.quantity,
    required this.sellerId,
    required this.createdAt,
    this.updatedAt,
  });

  // Factory constructor to create a ProductsModel from Firestore document
  factory ProductsModel.fromJson(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    
    return ProductsModel(
      id: doc.id,
      name: data['name'] ?? '',
      description: data['desc'] ?? '',
      images: List<String>.from(data['images'] ?? []),
      oldPrice: data['old_price'] ?? 0,
      newPrice: data['new_price'] ?? 0,
      category: data['category'] ?? '',
      categoryId: data['category_id'] ?? '', // Extract category ID
      quantity: data['quantity'] ?? 0,
      sellerId: data['seller_id'] ?? '',
      createdAt: (data['created_at'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updated_at'] as Timestamp?)?.toDate(),
    );
  }

  // Convert list of Firestore documents to list of ProductsModel
  static List<ProductsModel> fromJsonList(List<DocumentSnapshot> docs) {
    return docs.map((doc) => ProductsModel.fromJson(doc)).toList();
  }

  // Convert ProductsModel to JSON
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'desc': description,
      'images': images,
      'old_price': oldPrice,
      'new_price': newPrice,
      'category': category,
      'category_id': categoryId, // Include category ID in JSON
      'quantity': quantity,
      'seller_id': sellerId,
      'created_at': Timestamp.fromDate(createdAt),
      'updated_at': updatedAt != null ? Timestamp.fromDate(updatedAt!) : null,
    };
  }
}
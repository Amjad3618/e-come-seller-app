import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../Services/db_services.dart';
import '../Services/storage_services.dart';
import '../models/product_model.dart';


/// Repository class for handling Product operations
class ProductRepository {
  final DbService _dbService;
  final StorageService _storageService;

  ProductRepository({
    DbService? dbService,
    StorageService? storageService,
  }) : 
    _dbService = dbService ?? DbService(),
    _storageService = storageService ?? StorageService();

  /// Get stream of products
  Stream<List<ProductsModel>> getProducts() {
    return _dbService.readProducts().map((QuerySnapshot snapshot) {
      return ProductsModel.fromJsonList(snapshot.docs);
    });
  }

  /// Create a new product
  Future<void> createProduct({
    required String name,
    required String description,
    required int oldPrice,
    required int newPrice,
    required String category,
    required int maxQuantity,
    required List<File> imageFiles,
  }) async {
    List<String> imageUrls = [];
    
    // Upload each image and get URLs
    for (var imageFile in imageFiles) {
      String imageUrl = await _storageService.uploadFile(
        file: imageFile,
        path: 'products',
        fileName: '${DateTime.now().millisecondsSinceEpoch}_${imageFiles.indexOf(imageFile)}',
      );
      imageUrls.add(imageUrl);
    }

    final product = ProductsModel(
      name: name,
      description: description,
      images: imageUrls,
      oldprice: oldPrice,
      newprice: newPrice,
      category: category,
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      maxQuantity: maxQuantity,
    );

    await _dbService.createProduct(data: product.toJson());
  }

  /// Update an existing product
  Future<void> updateProduct({
    required String docId,
    required String name,
    required String description,
    required int oldPrice,
    required int newPrice,
    required String category,
    required int maxQuantity,
    List<File>? newImageFiles,
    List<String>? existingImageUrls,
    List<String>? imagesToDelete,
  }) async {
    List<String> finalImageUrls = [];
    
    // Keep existing images that weren't deleted
    if (existingImageUrls != null) {
      finalImageUrls = List.from(existingImageUrls);
      
      // Remove images that should be deleted
      if (imagesToDelete != null && imagesToDelete.isNotEmpty) {
        for (var imageUrl in imagesToDelete) {
          finalImageUrls.remove(imageUrl);
          await _storageService.deleteFile(imageUrl);
        }
      }
    }
    
    // Upload new images if any
    if (newImageFiles != null && newImageFiles.isNotEmpty) {
      for (var imageFile in newImageFiles) {
        String imageUrl = await _storageService.uploadFile(
          file: imageFile,
          path: 'products',
          fileName: '${DateTime.now().millisecondsSinceEpoch}_${newImageFiles.indexOf(imageFile)}',
        );
        finalImageUrls.add(imageUrl);
      }
    }

    final updatedData = {
      'name': name,
      'desc': description,
      'old_price': oldPrice,
      'new_price': newPrice,
      'category': category,
      'quantity': maxQuantity,
      'images': finalImageUrls,
    };

    await _dbService.updateProduct(docId: docId, data: updatedData);
  }

  /// Delete a product
  Future<void> deleteProduct({
    required String docId,
    required List<String> imageUrls,
  }) async {
    // Delete all images from storage
    for (var imageUrl in imageUrls) {
      if (imageUrl.isNotEmpty) {
        await _storageService.deleteFile(imageUrl);
      }
    }
    
    await _dbService.deleteProduct(docId: docId);
  }
}
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../Services/db_services.dart';
import '../Services/storage_services.dart';
import '../models/categorie_model.dart';


/// Repository class for handling Category operations
class CategoryRepository {
  final DbService _dbService;
  final StorageService _storageService;

  CategoryRepository({
    DbService? dbService,
    StorageService? storageService,
  }) : 
    _dbService = dbService ?? DbService(),
    _storageService = storageService ?? StorageService();

  /// Get stream of categories
  Stream<List<CategorieModel>> getCategories() {
    return _dbService.readCategories().map((QuerySnapshot snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return CategorieModel.fromJson({
          ...data,
          'id': doc.id,
        });
      }).toList();
    });
  }

  /// Create a new category
  Future<void> createCategory({
    required String name,
    required int priority,
    File? imageFile,
  }) async {
    String? imageUrl;
    
    if (imageFile != null) {
      imageUrl = await _storageService.uploadFile(
        file: imageFile,
        path: 'categories',
      );
    }

    final category = CategorieModel(
      name: name,
      priority: priority,
      image: imageUrl ?? '',
      id: DateTime.now().millisecondsSinceEpoch.toString(),
    );

    await _dbService.createCategory(data: category.toJson());
  }

  /// Update an existing category
  Future<void> updateCategory({
    required String docId,
    required String name,
    required int priority,
    File? imageFile,
    String? existingImageUrl,
  }) async {
    String? imageUrl = existingImageUrl;
    
    if (imageFile != null) {
      // Delete existing image if there is one
      if (existingImageUrl != null && existingImageUrl.isNotEmpty) {
        await _storageService.deleteFile(existingImageUrl);
      }
      
      // Upload new image
      imageUrl = await _storageService.uploadFile(
        file: imageFile,
        path: 'categories',
      );
    }

    final updatedData = {
      'name': name,
      'priority': priority,
      if (imageUrl != null) 'image': imageUrl,
    };

    await _dbService.updateCategory(docId: docId, data: updatedData);
  }

  /// Delete a category
  Future<void> deleteCategory({
    required String docId,
    String? imageUrl,
  }) async {
    // Delete image from storage if it exists
    if (imageUrl != null && imageUrl.isNotEmpty) {
      await _storageService.deleteFile(imageUrl);
    }
    
    await _dbService.deleteCategory(docId: docId);
  }
}
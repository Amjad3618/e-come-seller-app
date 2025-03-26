import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:e_come_seller_1/models/categorie_model.dart';

import '../Services/db_services.dart';
import '../Services/storage_services.dart';


class CategoryProvider extends ChangeNotifier {
  final DbService _dbService = DbService();
  final StorageService _storageService = StorageService();
  
  List<CategorieModel> _categories = [];
  bool _isLoading = false;
  String? _error;
  
  List<CategorieModel> get categories => _categories;
  bool get isLoading => _isLoading;
  String? get error => _error;
  
  // Method to load categories
  void loadCategories() {
    _dbService.readCategories().listen((snapshot) {
      _categories = snapshot.docs.map((doc) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        return CategorieModel.fromJson({
          'id': doc.id,
          ...data,
        });
      }).toList();
      notifyListeners();
    }, onError: (error) {
      _error = error.toString();
      notifyListeners();
    });
  }
  
  // Method to add a new category
  Future<bool> addCategory(String name, int priority, File image) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    try {
      // Upload image to Firebase Storage
      final String imageUrl = await _storageService.uploadFile(
        file: image,
        path: 'categories',
        fileName: 'category_${DateTime.now().millisecondsSinceEpoch}',
      );
      
      // Create category data
      final categoryData = {
        'name': name,
        'image': imageUrl,
        'priority': priority,
      };
      
      // Add category to Firestore
      await _dbService.createcategory(data: categoryData);
      
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }
  
  // Method to update a category
  Future<bool> updateCategory(CategorieModel category, {File? newImage}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    try {
      Map<String, dynamic> data = {
        'name': category.name,
        'priority': category.priority,
      };
      
      // If a new image is provided, upload it
      if (newImage != null) {
        // If there's an existing image, delete it
        if (category.image.isNotEmpty) {
          try {
            await _storageService.deleteFile(category.image);
          } catch (e) {
            print("Error deleting old image: $e");
          }
        }
        
        // Upload the new image
        final String imageUrl = await _storageService.uploadFile(
          file: newImage,
          path: 'categories',
          fileName: 'category_${DateTime.now().millisecondsSinceEpoch}',
        );
        
        data['image'] = imageUrl;
      }
      
      // Update the category in Firestore
      await _dbService.updateCategories(docId: category.id, data: data);
      
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }
  
  // Method to delete a category
Future<bool> deleteCategory(String categoryId, String imageUrl) async {
  try {
    // Delete category from Firestore
    await FirebaseFirestore.instance
        .collection('shop_categories')
        .doc(categoryId)
        .delete();

    // Extract file path from URL
    String filePath = Uri.decodeFull(imageUrl.split('?').first.split('/o/').last);

    // Reference to Firebase Storage
    final storageRef = FirebaseStorage.instance.ref().child(filePath);

    // Check if file exists before deleting
    try {
      await storageRef.getMetadata(); // This will throw an error if file doesn't exist
      await storageRef.delete(); // Delete if it exists
    } catch (e) {
      print('File deletion error: $e');
      // Not necessarily an error if file doesn't exist
    }

    // Explicitly reload categories
    loadCategories();

    notifyListeners();
    return true;
  } catch (e) {
    print('Category deletion error: $e');
    _error = e.toString();
    notifyListeners();
    return false;
  }
}
}

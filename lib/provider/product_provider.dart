import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Added for Auth

import '../Services/db_services.dart';
import '../models/product_model.dart';

class ProductProvider with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance; // Added for Auth
  final DbService _dbService = DbService();

  List<ProductsModel> _products = [];
  List<String> _categories = [];
  bool _isLoading = false;
  String? _error;

  // Getters
  List<ProductsModel> get products => _products;
  List<String> get categories => _categories;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Fetch Products
  Future<void> fetchProducts() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final querySnapshot =
          await _firestore.collection("shop_products").orderBy("name").get();

      _products = ProductsModel.fromJsonList(querySnapshot.docs);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  // Fetch Categories
  Future<void> fetchCategories() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final querySnapshot =
          await _firestore.collection("shop_categories").get();

      _categories =
          querySnapshot.docs.map((doc) => doc['name'] as String).toList();

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  // Upload Product with Multiple Images and User UID
  Future<bool> uploadProduct({
    required String name,
    required String description,
    required List<File> images,
    required int oldPrice,
    required int newPrice,
    required String category,
    required int maxQuantity,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Get current user ID
      final User? currentUser = _auth.currentUser;
      if (currentUser == null) {
        throw Exception("User not authenticated");
      }
      final String uid = currentUser.uid;

      // Upload images to Firebase Storage
      List<String> imageUrls = [];
      for (var image in images) {
        final storageRef = _storage.ref().child(
          'products/${uid}_${DateTime.now().millisecondsSinceEpoch}_${image.path.split('/').last}',
        );

        await storageRef.putFile(image);
        final imageUrl = await storageRef.getDownloadURL();
        imageUrls.add(imageUrl);
      }

      // Prepare product data with user ID
      final productData = {
        "name": name,
        "desc": description,
        "images": imageUrls,
        "new_price": newPrice,
        "old_price": oldPrice,
        "category": category,
        "quantity": maxQuantity,
        "product_id": uid, // Add user ID to product data
        "created_at": FieldValue.serverTimestamp(),
      };

      // Add to Firestore
      await _dbService.createProducts(data: productData);

      // Refresh products list
      await fetchProducts();

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

  // Update Product with UID
  Future<bool> updateProduct({
    required String productId,
    required String name,
    required String description,
    required List<File> images,
    required List<dynamic> existingImages,
    required int oldPrice,
    required int newPrice,
    required String category,
    required int maxQuantity,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Get current user ID
      final User? currentUser = _auth.currentUser;
      if (currentUser == null) {
        throw Exception("User not authenticated");
      }
      final String uid = currentUser.uid;

      // Upload new images to Firebase Storage
      List<String> newImageUrls = [];
      for (var image in images) {
        final storageRef = _storage.ref().child(
          'products/${uid}_${DateTime.now().millisecondsSinceEpoch}_${image.path.split('/').last}',
        );

        await storageRef.putFile(image);
        final imageUrl = await storageRef.getDownloadURL();
        newImageUrls.add(imageUrl);
      }

      // Combine existing and new image URLs
      List<String> allImageUrls = List.from(existingImages);
      allImageUrls.addAll(newImageUrls);

      // Limit to 5 images
      if (allImageUrls.length > 5) {
        // Remove excess images from storage
        for (var i = 5; i < allImageUrls.length; i++) {
          await FirebaseStorage.instance.refFromURL(allImageUrls[i]).delete();
        }
        allImageUrls = allImageUrls.take(5).toList();
      }

      // Prepare updated product data with user ID
      final updatedProductData = {
        "name": name,
        "desc": description,
        "images": allImageUrls,
        "new_price": newPrice,
        "old_price": oldPrice,
        "category": category,
        "quantity": maxQuantity,
        "user_id": uid, // Add user ID to product data
        "updated_at": FieldValue.serverTimestamp(),
      };

      // Update in Firestore
      await _dbService.updateproducts(docid: productId, data: updatedProductData);

      // Refresh products list
      await fetchProducts();

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

  // Delete Product
  Future<bool> deleteProduct(String productId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // First, find the product to delete its images
      final productDoc =
          await _firestore.collection("shop_products").doc(productId).get();

      final productData = productDoc.data();

      // Delete product images from storage
      if (productData?['images'] != null) {
        for (String imageUrl in productData!['images']) {
          await FirebaseStorage.instance.refFromURL(imageUrl).delete();
        }
      }

      // Delete product from Firestore
      await _dbService.deleteproducts(docid: productId);

      // Refresh products list
      await fetchProducts();

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

  // Fetch user's products only
  Future<void> fetchUserProducts() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final User? currentUser = _auth.currentUser;
      if (currentUser == null) {
        throw Exception("User not authenticated");
      }
      final String uid = currentUser.uid;

      final querySnapshot = await _firestore
          .collection("shop_products")
          .where("user_id", isEqualTo: uid)
          .orderBy("name")
          .get();

      _products = ProductsModel.fromJsonList(querySnapshot.docs);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  // Initial load of products and categories
  Future<void> initialize() async {
    await Future.wait([fetchProducts(), fetchCategories()]);
  }
}
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

import '../Services/db_services.dart';
import '../models/product_model.dart';

class ProductProvider with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
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

  // Upload Product with Multiple Images
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
      // Upload images to Firebase Storage
      List<String> imageUrls = [];
      for (var image in images) {
        final storageRef = _storage.ref().child(
          'products/${DateTime.now().millisecondsSinceEpoch}_${image.path.split('/').last}',
        );

        await storageRef.putFile(image);
        final imageUrl = await storageRef.getDownloadURL();
        imageUrls.add(imageUrl);
      }

      // Prepare product data
      final productData = {
        "name": name,
        "desc": description,
        "images": imageUrls,
        "new_price": newPrice,
        "old_price": oldPrice,
        "category": category,
        "quantity": maxQuantity,
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

  // Update Product
  Future<bool> updateProduct({
    required String productId,
    required Map<String, dynamic> updatedData,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _dbService.updateproducts(docid: productId, data: updatedData);

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

  // Initial load of products and categories
  Future<void> initialize() async {
    await Future.wait([fetchProducts(), fetchCategories()]);
  }
}

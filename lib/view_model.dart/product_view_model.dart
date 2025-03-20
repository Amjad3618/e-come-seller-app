import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../Repositories/produxt_repo.dart';
import '../models/product_model.dart';

/// ViewModel for managing Product data and UI state
class ProductViewModel extends ChangeNotifier {
  final ProductRepository _repository;
  
  // State variables
  bool _isLoading = false;
  String? _errorMessage;
  List<ProductsModel> _products = [];
  
  // Form variables
  final nameController = TextEditingController();
  final descriptionController = TextEditingController();
  final oldPriceController = TextEditingController();
  final newPriceController = TextEditingController();
  final categoryController = TextEditingController();
  final maxQuantityController = TextEditingController();
  
  List<File> selectedImages = [];
  List<String> existingImages = [];
  List<String> imagesToDelete = [];
  
  // Category list
  List<String> _categories = [];
  
  // Getters
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  List<ProductsModel> get products => _products;
  List<String> get categories => _categories;
  
  ProductViewModel({
    ProductRepository? repository,
  }) : _repository = repository ?? ProductRepository() {
    // Initialize by loading products
    _loadProducts();
  }

  void _loadProducts() {
    _repository.getProducts().listen(
      (productsList) {
        _products = productsList;
        notifyListeners();
      },
      onError: (error) {
        _errorMessage = "Error loading products: $error";
        notifyListeners();
      }
    );
  }

// Method to fetch categories from Firebase
Future<List<String>> fetchCategories() async {
  try {
    // Reference to the categories collection in Firestore
    final categoriesCollection = FirebaseFirestore.instance.collection('shop_categories');
    
    // Get all documents from the categories collection
    final querySnapshot = await categoriesCollection.get();
    
    // Extract category names from documents
    _categories = querySnapshot.docs.map((doc) {
      // Get the category name from the 'name' field in each document
      // Assuming your category documents have a 'name' field
      return doc.data()['name'] as String;
      
      // If you're not finding the category names, check what fields your documents have:
      // Map<String, dynamic> data = doc.data();
      // print("Category document data: $data");
      // return data['name'] as String; // Use the correct field name
    }).toList();
    
    // Sort categories alphabetically
    _categories.sort();
    
    return _categories;
  } catch (e) {
    // Handle error
    print('Error fetching categories: $e');
    _errorMessage = "Error loading categories: $e";
    notifyListeners();
    return [];
  }
}

  Future<void> addProduct() async {
    if (!_validateForm()) return;

    if (selectedImages.isEmpty) {
      _errorMessage = "Please add at least one product image";
      notifyListeners();
      return;
    }

    _setLoading(true);
    try {
      await _repository.createProduct(
        name: nameController.text,
        description: descriptionController.text,
        oldPrice: int.parse(oldPriceController.text),
        newPrice: int.parse(newPriceController.text),
        category: categoryController.text,
        maxQuantity: int.parse(maxQuantityController.text),
        imageFiles: selectedImages,
      );
      _clearForm();
    } catch (e) {
      _errorMessage = "Error creating product: $e";
    } finally {
      _setLoading(false);
    }
  }

  Future<void> updateProduct(String docId) async {
    if (!_validateForm()) return;

    if (selectedImages.isEmpty && existingImages.isEmpty) {
      _errorMessage = "Please add at least one product image";
      notifyListeners();
      return;
    }

    _setLoading(true);
    try {
      await _repository.updateProduct(
        docId: docId,
        name: nameController.text,
        description: descriptionController.text,
        oldPrice: int.parse(oldPriceController.text),
        newPrice: int.parse(newPriceController.text),
        category: categoryController.text,
        maxQuantity: int.parse(maxQuantityController.text),
        newImageFiles: selectedImages.isNotEmpty ? selectedImages : null,
        existingImageUrls: existingImages,
        imagesToDelete: imagesToDelete.isNotEmpty ? imagesToDelete : null,
      );
      _clearForm();
    } catch (e) {
      _errorMessage = "Error updating product: $e";
    } finally {
      _setLoading(false);
    }
  }

  Future<void> deleteProduct(String docId, List<String> imageUrls) async {
    _setLoading(true);
    try {
      await _repository.deleteProduct(
        docId: docId,
        imageUrls: imageUrls,
      );
    } catch (e) {
      _errorMessage = "Error deleting product: $e";
    } finally {
      _setLoading(false);
    }
  }

  bool _validateForm() {
    if (nameController.text.isEmpty ||
        descriptionController.text.isEmpty ||
        oldPriceController.text.isEmpty ||
        newPriceController.text.isEmpty ||
        categoryController.text.isEmpty ||
        maxQuantityController.text.isEmpty) {
      _errorMessage = "Please fill all required fields";
      notifyListeners();
      return false;
    }
    
    // Validate price and quantity are numbers
    try {
      int.parse(oldPriceController.text);
      int.parse(newPriceController.text);
      int.parse(maxQuantityController.text);
    } catch (e) {
      _errorMessage = "Price and quantity must be valid numbers";
      notifyListeners();
      return false;
    }
    
    return true;
  }

  void addImage(File image) {
    selectedImages.add(image);
    notifyListeners();
  }

  void removeSelectedImage(int index) {
    if (index >= 0 && index < selectedImages.length) {
      selectedImages.removeAt(index);
      notifyListeners();
    }
  }

  void removeExistingImage(String imageUrl) {
    if (existingImages.contains(imageUrl)) {
      existingImages.remove(imageUrl);
      imagesToDelete.add(imageUrl);
      notifyListeners();
    }
  }

  void setFormData(ProductsModel product) {
    nameController.text = product.name;
    descriptionController.text = product.description;
    oldPriceController.text = product.oldprice.toString();
    newPriceController.text = product.newprice.toString();
    categoryController.text = product.category;
    maxQuantityController.text = product.maxQuantity.toString();
    
    // Set existing images
    existingImages = List.from(product.images);
    
    // Reset new selected images and images to delete
    selectedImages = [];
    imagesToDelete = [];
    
    notifyListeners();
  }

  void _clearForm() {
    nameController.clear();
    descriptionController.clear();
    oldPriceController.clear();
    newPriceController.clear();
    categoryController.clear();
    maxQuantityController.clear();
    
    selectedImages = [];
    existingImages = [];
    imagesToDelete = [];
    
    _errorMessage = null;
    notifyListeners();
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  @override
  void dispose() {
    nameController.dispose();
    descriptionController.dispose();
    oldPriceController.dispose();
    newPriceController.dispose();
    categoryController.dispose();
    maxQuantityController.dispose();
    super.dispose();
  }
}
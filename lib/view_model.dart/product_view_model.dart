import 'dart:io';
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
  
  // Getters
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  List<ProductsModel> get products => _products;
  
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
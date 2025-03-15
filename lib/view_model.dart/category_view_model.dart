import 'dart:io';
import 'package:e_come_seller_1/models/categorie_model.dart';
import 'package:flutter/material.dart';
import '../Repositories/category_repo.dart';


/// ViewModel for managing Category data and UI state
class CategoryViewModel extends ChangeNotifier {
  final CategoryRepository _repository;
  
  // State variables
  bool _isLoading = false;
  String? _errorMessage;
  List<CategorieModel> _categories = [];
  
  // Form variables
  final nameController = TextEditingController();
  final priorityController = TextEditingController();
  File? selectedImage;
  
  // Getters
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  List<CategorieModel> get categories => _categories;
  
  CategoryViewModel({
    CategoryRepository? repository,
  }) : _repository = repository ?? CategoryRepository() {
    // Initialize by loading categories
    _loadCategories();
  }

  void _loadCategories() {
    _repository.getCategories().listen(
      (categoriesList) {
        _categories = categoriesList;
        notifyListeners();
      },
      onError: (error) {
        _errorMessage = "Error loading categories: $error";
        notifyListeners();
      }
    );
  }

  Future<void> addCategory() async {
    if (nameController.text.isEmpty || priorityController.text.isEmpty) {
      _errorMessage = "Please fill all required fields";
      notifyListeners();
      return;
    }

    _setLoading(true);
    try {
      await _repository.createCategory(
        name: nameController.text,
        priority: int.parse(priorityController.text),
        imageFile: selectedImage,
      );
      clearForm();
    } catch (e) {
      _errorMessage = "Error creating category: $e";
    } finally {
      _setLoading(false);
    }
  }

  Future<void> updateCategory(String docId, {String? existingImageUrl}) async {
    if (nameController.text.isEmpty || priorityController.text.isEmpty) {
      _errorMessage = "Please fill all required fields";
      notifyListeners();
      return;
    }

    _setLoading(true);
    try {
      await _repository.updateCategory(
        docId: docId,
        name: nameController.text,
        priority: int.parse(priorityController.text),
        imageFile: selectedImage,
        existingImageUrl: existingImageUrl,
      );
      clearForm();
    } catch (e) {
      _errorMessage = "Error updating category: $e";
    } finally {
      _setLoading(false);
    }
  }

  Future<void> deleteCategory(String docId, {String? imageUrl}) async {
    _setLoading(true);
    try {
      await _repository.deleteCategory(
        docId: docId,
        imageUrl: imageUrl,
      );
    } catch (e) {
      _errorMessage = "Error deleting category: $e";
    } finally {
      _setLoading(false);
    }
  }

  void setImage(File image) {
    selectedImage = image;
    notifyListeners();
  }

  void setFormData(CategorieModel category) {
    nameController.text = category.name;
    priorityController.text = category.priority.toString();
    selectedImage = null; // Reset selected image
    notifyListeners();
  }
 void clearForm() {
    nameController.clear();
    priorityController.clear();
    selectedImage = null;
    notifyListeners();
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  @override
  void dispose() {
    nameController.dispose();
    priorityController.dispose();
    super.dispose();
  }
}
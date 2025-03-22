import 'dart:io';
import 'package:flutter/foundation.dart';
import '../Services/banner_services.dart';
import '../models/promo_banner_model.dart';


class BannerViewModel extends ChangeNotifier {
  final BannerService _service;
  
  bool _isLoading = false;
  String? _errorMessage;
  List<BannerModel> _banners = [];
  List<BannerModel> _activeBanners = [];
  
  BannerViewModel({BannerService? service}) 
      : _service = service ?? BannerService();

  // Getters
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  List<BannerModel> get banners => _banners;
  List<BannerModel> get activeBanners => _activeBanners;
  
  // Initialize the ViewModel
  void init() {
    // Listen to all banners
    _service.getAllBanners().listen(
      (banners) {
        _banners = banners;
        notifyListeners();
      },
      onError: (error) {
        _errorMessage = 'Failed to load banners: $error';
        notifyListeners();
      }
    );
    
    // Listen to active banners
    _service.getActiveBanners().listen(
      (activeBanners) {
        _activeBanners = activeBanners;
        notifyListeners();
      },
      onError: (error) {
        _errorMessage = 'Failed to load active banners: $error';
        notifyListeners();
      }
    );
  }
  
  // Create a new banner
  Future<void> createBanner({
    required File imageFile,
    required String link,
    required bool isActive,
  }) async {
    _setLoading(true);
    try {
      await _service.createBanner(
        imageFile: imageFile,
        link: link,
        isActive: isActive,
      );
      _clearError();
    } catch (e) {
      _setError('Failed to create banner: $e');
    } finally {
      _setLoading(false);
    }
  }
  
  // Update an existing banner
  Future<void> updateBanner({
    required String id,
    String? link,
    bool? isActive,
    File? newImageFile,
    String? currentImageUrl,
  }) async {
    _setLoading(true);
    try {
      await _service.updateBanner(
        id: id,
        link: link,
        isActive: isActive,
        newImageFile: newImageFile,
        currentImageUrl: currentImageUrl,
      );
      _clearError();
    } catch (e) {
      _setError('Failed to update banner: $e');
    } finally {
      _setLoading(false);
    }
  }
  
  // Toggle banner active status
  Future<void> toggleBannerStatus(String id, bool isActive) async {
    _setLoading(true);
    try {
      await _service.toggleBannerStatus(id, isActive);
      _clearError();
    } catch (e) {
      _setError('Failed to toggle banner status: $e');
    } finally {
      _setLoading(false);
    }
  }
  
  // Delete a banner
  Future<void> deleteBanner(String id, String imageUrl) async {
    _setLoading(true);
    try {
      await _service.deleteBanner(id, imageUrl);
      _clearError();
    } catch (e) {
      _setError('Failed to delete banner: $e');
    } finally {
      _setLoading(false);
    }
  }
  
  // Helper methods
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }
  
  void _setError(String message) {
    _errorMessage = message;
    notifyListeners();
  }
  
  void _clearError() {
    _errorMessage = null;
    notifyListeners();
  }
  
  @override
  void dispose() {
    // Clean up any resources
    super.dispose();
  }
}
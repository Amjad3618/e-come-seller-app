import 'dart:io';
import '../Repositories/banner_repo.dart';
import '../models/promo_banner_model.dart';


class BannerService {
  final BannerRepository _repository;

  BannerService({BannerRepository? repository}) 
      : _repository = repository ?? BannerRepository();

  // Get all banners
  Stream<List<BannerModel>> getAllBanners() {
    return _repository.getAllBanners();
  }

  // Get active banners only
  Stream<List<BannerModel>> getActiveBanners() {
    return _repository.getActiveBanners();
  }

  // Get banner by ID
  Stream<BannerModel?> getBannerById(String id) {
    return _repository.getBannerById(id);
  }

  // Create a new banner with image upload
  Future<String> createBanner({
    required File imageFile,
    required String link,
    required bool isActive,
  }) async {
    // Upload image first
    final imageUrl = await _repository.uploadBannerImage(imageFile);
    
    // Create banner with the image URL
    final banner = BannerModel(
      id: '', // Will be set by Firestore
      imageUrl: imageUrl,
      link: link,
      isActive: isActive,
    );
    
    return await _repository.createBanner(banner);
  }

  // Update an existing banner
  Future<void> updateBanner({
    required String id,
    String? link,
    bool? isActive,
    File? newImageFile,
    String? currentImageUrl,
  }) async {
    String imageUrl = currentImageUrl ?? '';
    
    // If there's a new image, upload it and delete the old one
    if (newImageFile != null) {
      // Upload new image
      imageUrl = await _repository.uploadBannerImage(newImageFile);
      
      // Delete old image if it exists
      if (currentImageUrl != null && currentImageUrl.isNotEmpty) {
        await _repository.deleteBannerImage(currentImageUrl);
      }
    }
    
    // Create updated banner object
    final banner = BannerModel(
      id: id,
      imageUrl: imageUrl,
      link: link ?? '',
      isActive: isActive ?? false,
    );
    
    await _repository.updateBanner(banner);
  }

  // Toggle banner active status
  Future<void> toggleBannerStatus(String id, bool isActive) async {
    await _repository.toggleBannerStatus(id, isActive);
  }

  // Delete a banner with its image
  Future<void> deleteBanner(String id, String imageUrl) async {
    // Delete the image first
    if (imageUrl.isNotEmpty) {
      await _repository.deleteBannerImage(imageUrl);
    }
    
    // Then delete the banner document
    await _repository.deleteBanner(id);
  }
}
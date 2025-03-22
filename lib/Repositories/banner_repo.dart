import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';
import 'package:path/path.dart' as path;

import '../models/promo_banner_model.dart';

class BannerRepository {
  final FirebaseFirestore _firestore;
  final FirebaseStorage _storage;
  final String collectionPath = 'shop_banners';

  BannerRepository({
    FirebaseFirestore? firestore,
    FirebaseStorage? storage,
  }) : _firestore = firestore ?? FirebaseFirestore.instance,
       _storage = storage ?? FirebaseStorage.instance;

  // Convert QuerySnapshot to List of BannerModel
  List<BannerModel> _snapshotToBannerList(QuerySnapshot snapshot) {
    return snapshot.docs.map((doc) {
      return BannerModel.fromFirestore(doc);
    }).toList();
  }

  // Get all banners
  Stream<List<BannerModel>> getAllBanners() {
    return _firestore
        .collection(collectionPath)
        .orderBy('created_at', descending: true)
        .snapshots()
        .map(_snapshotToBannerList);
  }

  // Get active banners only
  Stream<List<BannerModel>> getActiveBanners() {
    return _firestore
        .collection(collectionPath)
        .where('isActive', isEqualTo: true)
        .orderBy('created_at', descending: true)
        .snapshots()
        .map(_snapshotToBannerList);
  }

  // Get a single banner by ID
  Stream<BannerModel?> getBannerById(String id) {
    return _firestore
        .collection(collectionPath)
        .doc(id)
        .snapshots()
        .map((doc) {
          if (doc.exists) {
            return BannerModel.fromFirestore(doc);
          }
          return null;
        });
  }

  // Create a new banner
  Future<String> createBanner(BannerModel banner) async {
    try {
      final docRef = await _firestore.collection(collectionPath).add({
        ...banner.toJson(),
        'created_at': FieldValue.serverTimestamp(),
        'updated_at': FieldValue.serverTimestamp(),
      });
      return docRef.id;
    } catch (e) {
      throw Exception('Failed to create banner: $e');
    }
  }

  // Update an existing banner
  Future<void> updateBanner(BannerModel banner) async {
    try {
      await _firestore.collection(collectionPath).doc(banner.id).update({
        ...banner.toJson(),
        'updated_at': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Failed to update banner: $e');
    }
  }

  // Toggle banner active status
  Future<void> toggleBannerStatus(String id, bool isActive) async {
    try {
      await _firestore.collection(collectionPath).doc(id).update({
        'isActive': isActive,
        'updated_at': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Failed to toggle banner status: $e');
    }
  }

  // Delete a banner
  Future<void> deleteBanner(String id) async {
    try {
      await _firestore.collection(collectionPath).doc(id).delete();
    } catch (e) {
      throw Exception('Failed to delete banner: $e');
    }
  }

  // Upload banner image to Firebase Storage
  Future<String> uploadBannerImage(File imageFile) async {
    try {
      final fileName = '${DateTime.now().millisecondsSinceEpoch}_${path.basename(imageFile.path)}';
      final ref = _storage.ref().child('banners/$fileName');
      final uploadTask = ref.putFile(imageFile);
      final snapshot = await uploadTask;
      return await snapshot.ref.getDownloadURL();
    } catch (e) {
      throw Exception('Failed to upload image: $e');
    }
  }

  // Delete banner image from Firebase Storage
  Future<void> deleteBannerImage(String imageUrl) async {
    try {
      if (imageUrl.isNotEmpty) {
        await _storage.refFromURL(imageUrl).delete();
      }
    } catch (e) {
      throw Exception('Failed to delete image: $e');
    }
  }
}
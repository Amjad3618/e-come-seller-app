import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';

/// Service class for handling Firebase Storage operations
class StorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;

  /// Upload a file to Firebase Storage
  /// Returns download URL of the uploaded file
  Future<String> uploadFile({
    required File file,
    required String path,
    String? fileName,
  }) async {
    final String timestamp = DateTime.now().millisecondsSinceEpoch.toString();
    final name = fileName ?? timestamp;
    
    // Create reference to the file location
    final Reference ref = _storage.ref().child('$path/$name');
    
    // Upload the file
    final UploadTask uploadTask = ref.putFile(file);
    
    // Wait for upload to complete
    final TaskSnapshot taskSnapshot = await uploadTask;
    
    // Get and return the download URL
    final String downloadUrl = await taskSnapshot.ref.getDownloadURL();
    return downloadUrl;
  }

  /// Delete a file from Firebase Storage
  Future<void> deleteFile(String fileUrl) async {
    try {
      // Create reference from the URL
      final Reference ref = _storage.refFromURL(fileUrl);
      await ref.delete();
    } catch (e) {
      // Handle errors or file not found
      print("Error deleting file: $e");
      rethrow;
    }
  }
}
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'dart:async';
import 'dart:math'; // Added for random string generation

import '../models/user_model.dart';

class AuthController extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _usersCollection = 'users';
  
  UserModel? _currentUser;
  bool _isLoading = false;
  String? _error;
  
  // Getters
  UserModel? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isAuthenticated => _auth.currentUser != null;
  String? get currentUserId => _auth.currentUser?.uid;
  Stream<User?> get authStateChanges => _auth.authStateChanges();
  
  // Constructor - initialize by trying to load current user
  AuthController() {
    _initCurrentUser();
    // Listen to auth state changes
    _auth.authStateChanges().listen((User? user) {
      if (user == null) {
        _currentUser = null;
        notifyListeners();
      } else {
        _loadCurrentUser();
      }
    });
  }
  
  // Initialize current user on startup
  Future<void> _initCurrentUser() async {
    if (_auth.currentUser != null) {
      await _loadCurrentUser();
    }
  }
  
  // Load current user data from Firestore
  Future<void> _loadCurrentUser() async {
    if (_auth.currentUser == null) return;
    
    try {
      _setLoading(true);
      DocumentSnapshot doc = await _firestore
          .collection(_usersCollection)
          .doc(_auth.currentUser!.uid)
          .get();
      
      if (doc.exists) {
        _currentUser = UserModel.fromJson(doc.data() as Map<String, dynamic>);
        notifyListeners();
      }
      _setLoading(false);
    } catch (e) {
      _setError('Error loading user data: $e');
      _setLoading(false);
    }
  }
  
  // Helper: Generate a random UID
  String _generateRandomUID() {
    const chars = 'abcdefghijklmnopqrstuvwxyz0123456789';
    final random = Random();
    return String.fromCharCodes(
      Iterable.generate(
        20, // Length of the random UID
        (_) => chars.codeUnitAt(random.nextInt(chars.length)),
      ),
    );
  }
  
  // Register new user
  Future<bool> registerUser({
    required String name,
    required String email,
    required String password,
  }) async {
    try {
      _setLoading(true);
      _clearError();
      
      // 1. Create auth user with email & password
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      // 2. Generate a random custom UID
      String customUID = _generateRandomUID();
      
      // 3. Create user model
      _currentUser = UserModel(
        name: name,
        uid: customUID, // Use the random UID instead of sequential ID
        email: email,
        password: '',
        confirmpassword: '', // Don't store actual password in Firestore for security
      );
      
      // 4. Store in Firestore using auth UID as doc ID
      await _firestore
          .collection(_usersCollection)
          .doc(userCredential.user!.uid)
          .set(_currentUser!.toJson());
      
      _setLoading(false);
      notifyListeners();
      return true;
    } on FirebaseAuthException catch (e) {
      _setError(_handleAuthException(e));
      _setLoading(false);
      return false;
    } catch (e) {
      _setError('Registration failed: $e');
      _setLoading(false);
      return false;
    }
  }

  // Login user
  Future<bool> loginUser({
    required String email,
    required String password,
  }) async {
    try {
      _setLoading(true);
      _clearError();
      
      // Sign in with email & password
      await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      // User data will be loaded by the auth state listener
      _setLoading(false);
      return true;
    } on FirebaseAuthException catch (e) {
      _setError(_handleAuthException(e));
      _setLoading(false);
      return false;
    } catch (e) {
      _setError('Login failed: $e');
      _setLoading(false);
      return false;
    }
  }

  // Logout user
  Future<bool> logoutUser() async {
    try {
      _setLoading(true);
      _clearError();
      
      await _auth.signOut();
      _currentUser = null;
      
      _setLoading(false);
      notifyListeners();
      return true;
    } catch (e) {
      _setError('Logout failed: $e');
      _setLoading(false);
      return false;
    }
  }

  // Reset password
  Future<bool> resetPassword(String email) async {
    try {
      _setLoading(true);
      _clearError();
      
      await _auth.sendPasswordResetEmail(email: email);
      
      _setLoading(false);
      return true;
    } on FirebaseAuthException catch (e) {
      _setError(_handleAuthException(e));
      _setLoading(false);
      return false;
    } catch (e) {
      _setError('Password reset failed: $e');
      _setLoading(false);
      return false;
    }
  }

  // Update user profile
  Future<bool> updateUserProfile(UserModel user) async {
    if (_auth.currentUser == null) {
      _setError('Not authenticated');
      return false;
    }
    
    try {
      _setLoading(true);
      _clearError();
      
      // Don't store actual password in Firestore
      Map<String, dynamic> userData = user.toJson();
      userData['password'] = '';
      
      await _firestore
          .collection(_usersCollection)
          .doc(_auth.currentUser!.uid)
          .update(userData);
      
      // Update email if it changed
      if (_auth.currentUser!.email != user.email) {
        await _auth.currentUser!.updateEmail(user.email);
      }
      
      // Update current user
      _currentUser = user;
      
      _setLoading(false);
      notifyListeners();
      return true;
    } catch (e) {
      _setError('Profile update failed: $e');
      _setLoading(false);
      return false;
    }
  }

  // Change password
  Future<bool> changePassword(String currentPassword, String newPassword) async {
    if (_auth.currentUser == null) {
      _setError('Not authenticated');
      return false;
    }
    
    try {
      _setLoading(true);
      _clearError();
      
      // Re-authenticate user before changing password
      AuthCredential credential = EmailAuthProvider.credential(
        email: _auth.currentUser!.email!,
        password: currentPassword,
      );
      
      await _auth.currentUser!.reauthenticateWithCredential(credential);
      await _auth.currentUser!.updatePassword(newPassword);
      
      _setLoading(false);
      return true;
    } on FirebaseAuthException catch (e) {
      _setError(_handleAuthException(e));
      _setLoading(false);
      return false;
    } catch (e) {
      _setError('Password change failed: $e');
      _setLoading(false);
      return false;
    }
  }

  // Delete user account
  Future<bool> deleteAccount(String password) async {
    if (_auth.currentUser == null) {
      _setError('Not authenticated');
      return false;
    }
    
    try {
      _setLoading(true);
      _clearError();
      
      // Re-authenticate user before deletion
      AuthCredential credential = EmailAuthProvider.credential(
        email: _auth.currentUser!.email!,
        password: password,
      );
      
      await _auth.currentUser!.reauthenticateWithCredential(credential);
      
      // Delete from Firestore first
      await _firestore.collection(_usersCollection).doc(_auth.currentUser!.uid).delete();
      
      // Then delete auth account
      await _auth.currentUser!.delete();
      
      _currentUser = null;
      
      _setLoading(false);
      notifyListeners();
      return true;
    } on FirebaseAuthException catch (e) {
      _setError(_handleAuthException(e));
      _setLoading(false);
      return false;
    } catch (e) {
      _setError('Account deletion failed: $e');
      _setLoading(false);
      return false;
    }
  }

  // Helper: Handle Firebase Auth exceptions
  String _handleAuthException(FirebaseAuthException e) {
    print('Firebase Auth Error: ${e.code}');
    
    switch (e.code) {
      case 'user-not-found':
        return 'No user found with this email.';
      case 'wrong-password':
        return 'Incorrect password.';
      case 'email-already-in-use':
        return 'Email is already in use by another account.';
      case 'weak-password':
        return 'Password is too weak. Use at least 6 characters.';
      case 'invalid-email':
        return 'Invalid email address.';
      case 'user-disabled':
        return 'This account has been disabled.';
      case 'too-many-requests':
        return 'Too many attempts. Please try again later.';
      case 'operation-not-allowed':
        return 'Operation not allowed. Please contact support.';
      case 'requires-recent-login':
        return 'This operation requires recent authentication. Please log in again.';
      default:
        return 'Authentication error. Please try again.';
    }
  }
  
  // State management helpers
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }
  
  void _setError(String? errorMessage) {
    _error = errorMessage;
    notifyListeners();
  }
  
  void _clearError() {
    _error = null;
    notifyListeners();
  }
}
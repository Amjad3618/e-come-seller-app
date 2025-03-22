import 'package:cloud_firestore/cloud_firestore.dart';

/// Service class for handling all Firestore database operations
class DbService {
  // ignore: unused_field
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Collection references
  final CollectionReference _categoriesCollection;
  final CollectionReference _productsCollection;
  final CollectionReference _promosCollection;
  final CollectionReference _bannersCollection;
  final CollectionReference _couponsCollection;
  final CollectionReference _ordersCollection;

  DbService() : 
    _categoriesCollection = FirebaseFirestore.instance.collection("shop_categories"),
    _productsCollection = FirebaseFirestore.instance.collection("shop_products"),
    _promosCollection = FirebaseFirestore.instance.collection("shop_promos"),
    _bannersCollection = FirebaseFirestore.instance.collection("shop_banners"),
    _couponsCollection = FirebaseFirestore.instance.collection("shop_coupons"),
    _ordersCollection = FirebaseFirestore.instance.collection("shop_orders");

  // CATEGORIES
  Stream<QuerySnapshot> readCategories() {
    return _categoriesCollection
        .orderBy("priority", descending: true)
        .snapshots();
  }

  Future<void> createCategory({required Map<String, dynamic> data}) async {
    await _categoriesCollection.add(data);
  }

  Future<void> updateCategory({
    required String docId, 
    required Map<String, dynamic> data
  }) async {
    await _categoriesCollection.doc(docId).update(data);
  }

  Future<void> deleteCategory({required String docId}) async {
    await _categoriesCollection.doc(docId).delete();
  }

  // PRODUCTS
  Stream<QuerySnapshot> readProducts() {
    return _productsCollection
        .orderBy("category", descending: true)
        .snapshots();
  }

  Future<void> createProduct({required Map<String, dynamic> data}) async {
    await _productsCollection.add(data);
  }

  Future<void> updateProduct({
    required String docId, 
    required Map<String, dynamic> data
  }) async {
    await _productsCollection.doc(docId).update(data);
  }

  Future<void> deleteProduct({required String docId}) async {
    await _productsCollection.doc(docId).delete();
  }

  // BANNERS - Specific Banner methods
  Stream<QuerySnapshot> readBanners() {
    return _bannersCollection
        .orderBy("created_at", descending: true)
        .snapshots();
  }

  Stream<QuerySnapshot> readActiveBanners() {
    return _bannersCollection
        .where('isActive', isEqualTo: true)
        .orderBy("created_at", descending: true)
        .snapshots();
  }

  Future<void> createBanner({required Map<String, dynamic> data}) async {
    // Add timestamp
    data['created_at'] = FieldValue.serverTimestamp();
    data['updated_at'] = FieldValue.serverTimestamp();
    
    await _bannersCollection.add(data);
  }

  Future<void> updateBanner({
    required String docId, 
    required Map<String, dynamic> data
  }) async {
    // Add updated timestamp
    data['updated_at'] = FieldValue.serverTimestamp();
    
    await _bannersCollection.doc(docId).update(data);
  }

  Future<void> deleteBanner({required String docId}) async {
    await _bannersCollection.doc(docId).delete();
  }

  // PROMOS & BANNERS (legacy method, maintained for compatibility)
  Stream<QuerySnapshot> readPromosOrBanners(bool isPromo) {
    return isPromo 
        ? _promosCollection.snapshots()
        : _bannersCollection.snapshots();
  }

  Future<void> createPromoOrBanner({
    required Map<String, dynamic> data, 
    required bool isPromo
  }) async {
    final collection = isPromo ? _promosCollection : _bannersCollection;
    
    // Add timestamp
    data['created_at'] = FieldValue.serverTimestamp();
    data['updated_at'] = FieldValue.serverTimestamp();
    
    await collection.add(data);
  }

  Future<void> updatePromoOrBanner({
    required Map<String, dynamic> data,
    required bool isPromo,
    required String id
  }) async {
    final collection = isPromo ? _promosCollection : _bannersCollection;
    
    // Add updated timestamp
    data['updated_at'] = FieldValue.serverTimestamp();
    
    await collection.doc(id).update(data);
  }

  Future<void> deletePromoOrBanner({
    required bool isPromo, 
    required String id
  }) async {
    final collection = isPromo ? _promosCollection : _bannersCollection;
    await collection.doc(id).delete();
  }

  // COUPONS
  Stream<QuerySnapshot> readCoupons() {
    return _couponsCollection.snapshots();
  }

  Future<void> createCoupon({required Map<String, dynamic> data}) async {
    await _couponsCollection.add(data);
  }

  Future<void> updateCoupon({
    required String docId, 
    required Map<String, dynamic> data
  }) async {
    await _couponsCollection.doc(docId).update(data);
  }

  Future<void> deleteCoupon({required String docId}) async {
    await _couponsCollection.doc(docId).delete();
  }

  // ORDERS
  Stream<QuerySnapshot> readOrders() {
    return _ordersCollection
        .orderBy("created_at", descending: true)
        .snapshots();
  }

  Future<void> updateOrderStatus({
    required String docId, 
    required Map<String, dynamic> data
  }) async {
    await _ordersCollection.doc(docId).update(data);
  }
  
  Stream<QuerySnapshot> readCategoriess() {
    return _firestore
        .collection('shop_categories')
        .orderBy('name')
        .snapshots();
  }
  
  Stream<QuerySnapshot> getcategories() {
    return _firestore
        .collection('shop_categories')
        .orderBy('name')
        .snapshots();
  }
}
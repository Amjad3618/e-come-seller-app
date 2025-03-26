import 'package:cloud_firestore/cloud_firestore.dart';

/// Service class for handling all Firestore database operations
class DbService {
  // CATEGORIES
  ///////////////////////////////////// READE CATEGORIES////////////////////////////////////////
  // read categories from database
  Stream<QuerySnapshot> readCategories() {
    return FirebaseFirestore.instance
        .collection("shop_categories")
        .orderBy("priority", descending: true)
        .snapshots();
  }

  ///////////////////////////////////// READE PRODUCTS////////////////////////////////////////
  // read products from database
  Stream<QuerySnapshot> readProducts() {
    return FirebaseFirestore.instance
        .collection("shop_products")
        .orderBy("category", descending: true)
        .snapshots();
  }

  ///////////////////////////////////// READE PROMO BANNERS////////////////////////////////////////
  // read promos and banners
  Stream<QuerySnapshot> readpromobanners({required bool ispromo}) {
    return FirebaseFirestore.instance
        .collection(ispromo ? "shop_promos" : "shop_banners")
        .snapshots();
  }

  ///////////////////////////////////// READE COUPONS////////////////////////////////////////
  //read coupons from database
  Stream<QuerySnapshot> readcoupomns() {
    return FirebaseFirestore.instance.collection("shop_coupons").snapshots();
  }
  ///////////////////////////////////// READE ORDERS////////////////////////////////////////

  //read orders from database
  Stream<QuerySnapshot> readOrders() {
    return FirebaseFirestore.instance
        .collection("shop_orders")
        .orderBy("created at ", descending: true)
        .snapshots();
  }

  // read Everything from database
  //////////////////////////////////////////Get all products and getegories services///////////////////////////////////////////////////////////
  ///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
  ////////////////////////////////////////////////////////////////////////////////////////////////////////////
  // make new category
  Future<void> createcategory({required Map<String, dynamic> data}) {
    return FirebaseFirestore.instance.collection("shop_categories").add(data);
  }

  //update category
  Future<void> updateCategories({
    required docId,
    required Map<String, dynamic> data,
  }) {
    return FirebaseFirestore.instance
        .collection("shop_categories")
        .doc(docId)
        .update(data);
  }

  //delete category
  Future<void> deleteCategories({required docId}) {
    return FirebaseFirestore.instance
        .collection("Shop_categories")
        .doc(docId)
        .delete();
  }
  ///////////////////////// Category services//////////////////////////////////////////////////////////

  // create a new product
  Future<void> createProducts({required Map<String, dynamic> data}) {
    return FirebaseFirestore.instance.collection("shop_products").add(data);
  }

  // update the product
  Future<void> updateproducts({
    required docid,
    required Map<String, dynamic> data,
  }) {
    return FirebaseFirestore.instance
        .collection("shop_products")
        .doc(docid)
        .update(data);
  }

  // delete the product
  Future<void> deleteproducts({required docid}) {
    return FirebaseFirestore.instance
        .collection("shop_products")
        .doc(docid)
        .delete();
  }
  /////////////////////////products services //////////////////////////////////////////////////////////

  /// promos and banners
  Future<void> createpromobanners({
    required Map<String, dynamic> data,
    required bool ispromo,
  }) {
    return FirebaseFirestore.instance
        .collection(ispromo ? "shop_promos" : "shop_banners")
        .add(data);
  }

  // update the promos and banners
  Future<void> updatepromobanners({
    required docid,
    required Map<String, dynamic> data,
    required bool ispromo,
  }) {
    return FirebaseFirestore.instance
        .collection(ispromo ? "shop_promos" : "shop_banners")
        .doc(docid)
        .update(data);
  }

  // delete the promos and banners
  Future<void> deletepromobanners({required docid, required bool ispromo}) {
    return FirebaseFirestore.instance
        .collection(ispromo ? "shop_promos" : "shop_banners")
        .doc(docid)
        .delete();
  }
  /////////////////////////PROMO BANNER SERVICES //////////////////////////////////////////////////////////

  //coupon services
  /// create a new coupon
  Future<void> createCoupon({required Map<String, dynamic> data}) {
    return FirebaseFirestore.instance
        .collection("shop_coupons")
        .doc()
        .set(data);
  }

  // update the coupon
  Future<void> updatecoupons({
    required docid,
    required Map<String, dynamic> data,
  }) {
    return FirebaseFirestore.instance
        .collection("shop_coupons")
        .doc(docid)
        .delete();
  }

  // delete the coupon
  Future<void> deleteCoupons({required docid}) {
    return FirebaseFirestore.instance
        .collection("shop_coupons")
        .doc(docid)
        .delete();
  }
  /////////////////////////COUPONS SERVICES //////////////////////////////////////////////////////////

  //order services
  //update the order
  Future<void> updateOrders({
    required docid,
    required Map<String, dynamic> data,
  }) {
    return FirebaseFirestore.instance
        .collection("shop_orders")
        .doc(docid)
        .update(data);
  }
  /////////////////////////ORDERS SERVICES //////////////////////////////////////////////////////////
}

import 'package:cloud_firestore/cloud_firestore.dart';

/// Service class for handling all Firestore database operations
class DbService {
  // CATEGORIES
  // read categories from database
  Stream<QuerySnapshot> readCategories() {
    return FirebaseFirestore.instance
        .collection("shop_categories")
        .orderBy("priority", descending: true)
        .snapshots();
  }

  // make new category

  Future<void> createcategory({required Map<String, dynamic> data}) {
    return FirebaseFirestore.instance.collection("shop_categories").add(data);
  }

  Stream<QuerySnapshot> readProducts() {
    return FirebaseFirestore.instance
        .collection("shop_products")
        .orderBy("category", descending: true)
        .snapshots();
  }

  // create a new product
  Future createProduct({required Map<String, dynamic> data}) async {
    await FirebaseFirestore.instance.collection("shop_products").add(data);
  }

  // update the product
  Future updateProduct({
    required String docId,
    required Map<String, dynamic> data,
  }) async {
    await FirebaseFirestore.instance
        .collection("shop_products")
        .doc(docId)
        .update(data);
  }

  // delete the product
  Future deleteProduct({required String docId}) async {
    await FirebaseFirestore.instance
        .collection("shop_products")
        .doc(docId)
        .delete();
  }

  // update category
  Future updateCategories({
    required String docId,
    required Map<String, dynamic> data,
  }) async {
    await FirebaseFirestore.instance
        .collection("shop_categories")
        .doc(docId)
        .update(data);
  }

  // delete category
  Future deleteCategories({required String docId}) async {
    await FirebaseFirestore.instance
        .collection("shop_categories")
        .doc(docId)
        .delete();
  }

  Stream<QuerySnapshot> readOrders() {
    return FirebaseFirestore.instance
        .collection("shop_orders")
        .orderBy("created_at", descending: true)
        .snapshots();
  }

  // update the status of order
  Future updateOrderStatus({
    required String docId,
    required Map<String, dynamic> data,
  }) async {
    await FirebaseFirestore.instance
        .collection("shop_orders")
        .doc(docId)
        .update(data);
  }
}

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/product_models.dart';

class HustleamRepository {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Stream<User?> get userStream => _auth.authStateChanges();
  User? get currentUser => _auth.currentUser;

  // AUTH
  Future<void> login(String e, String p) =>
      _auth.signInWithEmailAndPassword(email: e, password: p);
  Future<void> signUp(String e, String p, String u, String a) async {
    UserCredential res = await _auth.createUserWithEmailAndPassword(
      email: e,
      password: p,
    );
    await _db.collection('users').doc(res.user!.uid).set({
      'uid': res.user!.uid,
      'email': e,
      'username': u,
      'savedAddresses': [a],
      'selectedAddress': a,
      'profileImageUrl': null,
    });
  }

  Future<void> logout() => _auth.signOut();
  Future<void> updatePassword(String p) => _auth.currentUser!.updatePassword(p);
  Future<void> sendPasswordResetEmail(String e) =>
      _auth.sendPasswordResetEmail(email: e);

  // DATA
  Stream<DocumentSnapshot<Map<String, dynamic>>> getUserData(String uid) =>
      _db.collection('users').doc(uid).snapshots();
  Stream<QuerySnapshot> cartStream(String uid) {
    return _db.collection('users').doc(uid).collection('cart').snapshots();
  }

  // ADDRESS
  Future<void> selectAddress(
    String uid,
    String addr, {
    bool isNew = false,
  }) async {
    final data = isNew
        ? {
            'savedAddresses': FieldValue.arrayUnion([addr]),
            'selectedAddress': addr,
          }
        : {'selectedAddress': addr};
    await _db.collection('users').doc(uid).update(data);
  }

  Future<void> deleteAddress(String uid, String addr) =>
      _db.collection('users').doc(uid).update({
        'savedAddresses': FieldValue.arrayRemove([addr]),
      });

  // CART ACTION
  Future<void> addToCart(String uid, CartItem item) async {
    final String docId = "${item.id}_${item.selectedSize}";

    print(
      "FIREBASE: Attempting to add ${item.name} to path: users/$uid/cart/$docId",
    );

    try {
      final docRef =
          _db.collection('users').doc(uid).collection('cart').doc(docId);

      await docRef.set(item.toFirestore(), SetOptions(merge: true));

      print("FIREBASE: Successfully wrote to database!");
    } catch (e) {
      print("FIREBASE ERROR: $e");
    }
  }

  Future<void> removeItem(String uid, CartItem item) => _db
      .collection('users')
      .doc(uid)
      .collection('cart')
      .doc("${item.id}_${item.selectedSize}")
      .delete();
  Future<void> updateItemQuantity(String uid, CartItem item, int q) => _db
      .collection('users')
      .doc(uid)
      .collection('cart')
      .doc("${item.id}_${item.selectedSize}")
      .update({'quantity': q});
  Future<void> clearLocalCart(String uid) async {
    final snap =
        await _db.collection('users').doc(uid).collection('cart').get();
    for (var d in snap.docs) {
      await d.reference.delete();
    }
  }

  // ORDERS
  Future<void> placeOrder(Map<String, dynamic> orderData) async {
    String orderId =
        "ORD-${DateTime.now().millisecondsSinceEpoch.toString().substring(8)}";

    // E'add sa data map bago e'save sa Firestore
    orderData['orderId'] = orderId;

    await _db.collection('orders').add(orderData);
  }

  // ---  ACCEPT ORDER & DECREASE STOCK ---
  Future<void> acceptOrder(String orderDocId, List items) async {
    try {
      WriteBatch batch = _db.batch();

      // Update status to Accepted
      batch.update(_db.collection('orders').doc(orderDocId), {
        'status': 'Accepted',
      });

      // Decrease Stock
      for (var item in items) {
        String? pId = item['productId'];
        int qty = (item['quantity'] ?? 1) as int;

        if (pId != null) {
          DocumentReference pRef = _db.collection('products').doc(pId);
          batch.update(pRef, {'stock': FieldValue.increment(-qty)});
        }
      }

      await batch.commit().timeout(const Duration(seconds: 15));
      print("DEBUG: Order accepted successfully.");
    } catch (e) {
      print("FIREBASE ERROR: $e");
      throw Exception(e.toString());
    }
  }

  // ---  CANCEL / REJECT ORDER ---
  Future<void> rejectOrder(String orderDocId) async {
    await _db.collection('orders').doc(orderDocId).update({
      'status': 'Cancelled',
    });
  }
}

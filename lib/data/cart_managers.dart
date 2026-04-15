import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:hustleamapp/data/models/product_models.dart';

class CartManager extends ChangeNotifier {
  List<CartItem> _items = [];
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  StreamSubscription<QuerySnapshot>? _cartSubscription;

  CartManager() {
    _auth.authStateChanges().listen((user) {
      if (user != null) {
        _startCartListener(user.uid);
      } else {
        _stopCartListener();
      }
    });
  }

  List<CartItem> get items => List.unmodifiable(_items);
  int get itemCount => _items.fold(0, (sum, item) => sum + item.quantity);

  double get totalPrice =>
      _items.fold(0.0, (sum, item) => sum + (item.price * item.quantity));

  void _startCartListener(String userId) {
    _cartSubscription?.cancel();
    _cartSubscription = _firestore
        .collection('users')
        .doc(userId)
        .collection('cart')
        .snapshots()
        .listen((snapshot) {
      _items = snapshot.docs.map((doc) => CartItem.fromFirestore(doc)).toList();
      notifyListeners();
    });
  }

  void _stopCartListener() {
    _cartSubscription?.cancel();
    _items = [];
    notifyListeners();
  }

  Future<void> addItem(Product product, String size) async {
    final user = _auth.currentUser;
    if (user == null) return;
    final String docId = "${product.id}_$size";
    final docRef = _firestore
        .collection('users')
        .doc(user.uid)
        .collection('cart')
        .doc(docId);
    final doc = await docRef.get();
    if (doc.exists) {
      await docRef.update({'quantity': FieldValue.increment(1)});
    } else {
      await docRef.set(
        CartItem(
          id: product.id,
          name: product.name,
          image: product.image,
          price: product.price,
          selectedSize: size,
        ).toFirestore(),
      );
    }
  }

  Future<void> removeItem(CartItem item) async {
    final user = _auth.currentUser;
    if (user == null) return;
    await _firestore
        .collection('users')
        .doc(user.uid)
        .collection('cart')
        .doc("${item.id}_${item.selectedSize}")
        .delete();
  }

  Future<void> updateItemQuantity(CartItem item, int newQty) async {
    final user = _auth.currentUser;
    if (user == null) return;
    if (newQty <= 0) {
      await removeItem(item);
    } else {
      await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('cart')
          .doc("${item.id}_${item.selectedSize}")
          .update({'quantity': newQty});
    }
  }

  Future<void> clearLocalCart() async {
    final user = _auth.currentUser;
    if (user == null) return;

    try {
      final cartRef =
          _firestore.collection('users').doc(user.uid).collection('cart');
      final snapshots = await cartRef.get();

      for (var doc in snapshots.docs) {
        await doc.reference.delete();
      }
      notifyListeners();
    } catch (e) {
      print("Error clearing cart: $e");
    }
  }
}

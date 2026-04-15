// import 'package:cloud_firestore/cloud_firestore.dart';

// class Product {
//   final String id, name, image, description, tag;
//   final double price;
//   final List<String> availableSizes, availableColors;
//   final int stock;

//   Product({
//     required this.id,
//     required this.name,
//     required this.image,
//     required this.price,
//     this.description = '',
//     this.availableSizes = const ['S', 'M', 'L', 'XL'],
//     this.availableColors = const ['Black'],
//     this.stock = 0,
//     this.tag = '',
//   });

//   factory Product.fromFirestore(DocumentSnapshot doc) {
//     Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
//     return Product(
//       id: doc.id,
//       name: data['name'] ?? '',
//       image: data['image'] ?? '',
//       price: (data['price'] ?? 0.0).toDouble(),
//       description: data['description'] ?? '',
//       availableSizes: List<String>.from(data['availableSizes'] ?? []),
//       availableColors: List<String>.from(data['availableColors'] ?? []),
//       stock: (data['stock'] ?? 0).toInt(),
//       tag: data['tag'] ?? '',
//     );
//   }
// }

// class CartItem {
//   final String id, name, image, selectedSize;
//   final double price;
//   final int quantity;

//   CartItem({
//     required this.id,
//     required this.name,
//     required this.image,
//     required this.price,
//     required this.selectedSize,
//     this.quantity = 1,
//   });

//   // ALIGNED: Uses 'productId' to match your database screenshot
//   Map<String, dynamic> toFirestore() => {
//     'productId': id,
//     'name': name,
//     'image': image,
//     'price': price,
//     'selectedSize': selectedSize,
//     'quantity': quantity,
//   };

//   factory CartItem.fromFirestore(DocumentSnapshot doc) {
//     Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
//     return CartItem(
//       // Ensure these strings match your Firebase Console EXACTLY (case-sensitive)
//       id: data['productId'] ?? doc.id,
//       name: data['name'] ?? 'Unnamed Item',
//       image: data['image'] ?? '',
//       // Use 'num' and 'toDouble' to prevent crashes with Firestore numbers
//       price: (data['price'] as num? ?? 0.0).toDouble(),
//       selectedSize: data['selectedSize'] ?? 'M',
//       quantity: (data['quantity'] as num? ?? 1).toInt(),
//     );
//   }
// }
import 'package:cloud_firestore/cloud_firestore.dart';

class Product {
  final String id, name, image, description, tag;
  final double price;
  final List<String> availableSizes, availableColors;
  final int stock;

  Product({
    required this.id,
    required this.name,
    required this.image,
    required this.price,
    this.description = '',
    this.availableSizes = const ['S', 'M', 'L', 'XL'],
    this.availableColors = const ['Black'],
    this.stock = 0,
    this.tag = '',
  });

  factory Product.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return Product(
      id: doc.id,
      name: data['name'] ?? '',
      image: data['image'] ?? '',
      price: (data['price'] ?? 0.0).toDouble(),
      description: data['description'] ?? '',
      availableSizes: List<String>.from(data['availableSizes'] ?? []),
      availableColors: List<String>.from(data['availableColors'] ?? []),
      stock: (data['stock'] ?? 0).toInt(),
      tag: data['tag'] ?? '',
    );
  }
}

class CartItem {
  final String id, name, image, selectedSize;
  final double price;
  final int quantity;

  CartItem({
    required this.id,
    required this.name,
    required this.image,
    required this.price,
    required this.selectedSize,
    this.quantity = 1,
  });

  // Gamit to for SQLite (Local)
  Map<String, dynamic> toMap() => {
        'productId': id,
        'name': name,
        'image': image,
        'price': price,
        'selectedSize': selectedSize,
        'quantity': quantity,
      };

  // Gamit to for Firebase (Orders)
  Map<String, dynamic> toFirestore() => {
        'productId': id,
        'name': name,
        'image': image,
        'price': price,
        'selectedSize': selectedSize,
        'quantity': quantity,
      };

  factory CartItem.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map<String, dynamic>;
    return CartItem(
      id: data['productId'] ?? doc.id,
      name: data['name'] ?? '',
      image: data['image'] ?? '',
      price: (data['price'] ?? 0.0).toDouble(),
      selectedSize: data['selectedSize'] ?? 'M',
      quantity: (data['quantity'] ?? 1).toInt(),
    );
  }
}

// import 'package:sqflite/sqflite.dart';
// import 'package:path/path.dart';
// import '../models/product.dart';

// class LocalDatabase {
//   static final LocalDatabase instance = LocalDatabase._init();
//   static Database? _database;

//   LocalDatabase._init();

//   Future<Database> get database async {
//     if (_database != null) return _database!;
//     _database = await _initDB('hustleam.db');
//     return _database!;
//   }

//   Future<Database> _initDB(String filePath) async {
//     final dbPath = await getDatabasesPath();
//     final path = join(dbPath, filePath);

//     return await openDatabase(path, version: 1, onCreate: _createDB);
//   }

//   Future _createDB(Database db, int version) async {
//     // Existing Favorites table
//     await db.execute('''
//     CREATE TABLE favorites (
//       id TEXT PRIMARY KEY,
//       name TEXT,
//       image TEXT,
//       price REAL
//     )
//   ''');

//     // NEW: Cart table (100% Offline stable)
//     await db.execute('''
//     CREATE TABLE cart (
//       id TEXT PRIMARY KEY,
//       productId TEXT,
//       name TEXT,
//       image TEXT,
//       price REAL,
//       selectedSize TEXT,
//       quantity INTEGER
//     )
//   ''');
//   }

// // --- NEW CART OPERATIONS ---

//   Future<void> addToLocalCart(CartItem item) async {
//     final db = await instance.database;
//     // Unique ID for the row (Product + Size combo)
//     final String docId = "${item.id}_${item.selectedSize}";

//     final existing =
//         await db.query('cart', where: 'id = ?', whereArgs: [docId]);

//     if (existing.isNotEmpty) {
//       int currentQty = existing.first['quantity'] as int;
//       await db.update('cart', {'quantity': currentQty + 1},
//           where: 'id = ?', whereArgs: [docId]);
//     } else {
//       await db.insert('cart', {
//         'id': docId,
//         'productId': item.id, // Ensure this matches getLocalCart below
//         'name': item.name,
//         'image': item.image,
//         'price': item.price,
//         'selectedSize': item.selectedSize,
//         'quantity': item.quantity,
//       });
//     }
//   }

//   Future<List<CartItem>> getLocalCart() async {
//     final db = await instance.database;
//     final result = await db.query('cart');

//     // DEBUG PRINT: Check your terminal to see if data exists
//     print("SQLITE: Found ${result.length} items in local cart");

//     return result
//         .map((json) => CartItem(
//               id: json['productId'] as String, // Must use 'productId' key
//               name: json['name'] as String,
//               image: json['image'] as String,
//               price: (json['price'] as num).toDouble(),
//               selectedSize: json['selectedSize'] as String,
//               quantity: json['quantity'] as int,
//             ))
//         .toList();
//   }

//   Future<void> updateLocalQty(String productId, String size, int newQty) async {
//     final db = await instance.database;
//     final id = "${productId}_$size";
//     if (newQty <= 0) {
//       await db.delete('cart', where: 'id = ?', whereArgs: [id]);
//     } else {
//       await db.update('cart', {'quantity': newQty},
//           where: 'id = ?', whereArgs: [id]);
//     }
//   }

//   Future<void> clearLocalCart() async {
//     final db = await instance.database;
//     await db.delete('cart');
//   }
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/product_models.dart';

class LocalDatabase {
  static final LocalDatabase instance = LocalDatabase._init();
  static Database? _database;
  LocalDatabase._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('hustleam.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    return await openDatabase(join(dbPath, filePath),
        version: 1, onCreate: _createDB);
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE cart (
        id TEXT PRIMARY KEY, 
        productId TEXT,
        name TEXT,
        image TEXT,
        price REAL,
        selectedSize TEXT,
        quantity INTEGER
      )
    ''');
  }

  Future<void> addToLocalCart(CartItem item) async {
    final db = await instance.database;
    final String docId = "${item.id}_${item.selectedSize}";
    final existing =
        await db.query('cart', where: 'id = ?', whereArgs: [docId]);
    if (existing.isNotEmpty) {
      await db.update(
          'cart', {'quantity': (existing.first['quantity'] as int) + 1},
          where: 'id = ?', whereArgs: [docId]);
    } else {
      var map = item.toMap();
      map['id'] = docId;
      await db.insert('cart', map);
    }
  }

  Future<List<CartItem>> getLocalCart() async {
    final db = await instance.database;
    final res = await db.query('cart');
    return res
        .map((json) => CartItem(
              id: json['productId'] as String,
              name: json['name'] as String,
              image: json['image'] as String,
              price: (json['price'] as num).toDouble(),
              selectedSize: json['selectedSize'] as String,
              quantity: json['quantity'] as int,
            ))
        .toList();
  }

  Future<void> updateLocalQty(String productId, String size, int newQty) async {
    final db = await instance.database;
    final id = "${productId}_$size";
    if (newQty <= 0) {
      await db.delete('cart', where: 'id = ?', whereArgs: [id]);
    } else {
      await db.update('cart', {'quantity': newQty},
          where: 'id = ?', whereArgs: [id]);
    }
  }

  Future<void> clearLocalCart() async {
    final db = await instance.database;
    await db.delete('cart');
  }

  // --- CRUD OPERATION ---

  Future<void> addFavorite(Product product) async {
    final db = await instance.database;
    await db.insert(
        'favorites',
        {
          'id': product.id,
          'name': product.name,
          'image': product.image,
          'price': product.price,
        },
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<void> removeFavorite(String id) async {
    final db = await instance.database;
    await db.delete('favorites', where: 'id = ?', whereArgs: [id]);
  }

  Future<List<Product>> getFavorites() async {
    final db = await instance.database;
    final result = await db.query('favorites');

    return result
        .map(
          (json) => Product(
            id: json['id'] as String,
            name: json['name'] as String,
            image: json['image'] as String,
            price: json['price'] as double,
          ),
        )
        .toList();
  }

  Future<bool> isFavorite(String id) async {
    final db = await instance.database;
    final maps = await db.query('favorites', where: 'id = ?', whereArgs: [id]);
    return maps.isNotEmpty;
  }
}

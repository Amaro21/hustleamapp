// import 'dart:async';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:equatable/equatable.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import '../../data/models/product.dart';
// import '../../data/repositories/hustleam_repository.dart';
// import '../../data/dataresources/local_db.dart';

// abstract class CartEvent {}

// class LoadCart extends CartEvent {
//   final String uid;
//   LoadCart(this.uid);
// }

// class AddItem extends CartEvent {
//   final CartItem item;
//   AddItem(this.item);
// }

// class RemoveItem extends CartEvent {
//   final CartItem item;
//   RemoveItem(this.item);
// }

// class UpdateQty extends CartEvent {
//   final CartItem item;
//   final int newQty;
//   UpdateQty(this.item, this.newQty);
// }

// class ClearCartEvent extends CartEvent {}

// class _UpdateUI extends CartEvent {
//   final List<CartItem> items;
//   _UpdateUI(this.items);
// }

// // STATE
// class CartState extends Equatable {
//   final List<CartItem> items;
//   final bool isLoading;
//   const CartState({this.items = const [], this.isLoading = false});

//   double get total => items.fold(0.0, (sum, i) => sum + (i.price * i.quantity));
//   int get count => items.fold(0, (sum, i) => sum + i.quantity);

//   @override
//   List<Object?> get props => [items, isLoading];
// }

// // BLOC
// class CartBloc extends Bloc<CartEvent, CartState> {
//   CartBloc() : super(const CartState(isLoading: false)) {
//     on<LoadCart>((event, emit) async {
//       // 1. Show spinner
//       emit(const CartState(items: [], isLoading: true));

//       try {
//         // 2. Fetch from local SQLite
//         final items = await LocalDatabase.instance.getLocalCart();

//         // 3. Emit LOADED state and turn OFF spinner
//         emit(CartState(items: items, isLoading: false));
//       } catch (e) {
//         print("SQLITE ERROR: $e");
//         // Stop loading even on error
//         emit(const CartState(items: [], isLoading: false));
//       }
//     });

//     on<AddItem>((event, emit) async {
//       // 1. Wait for the database to finish saving
//       await LocalDatabase.instance.addToLocalCart(event.item);

//       // 2. Refresh the list from the database
//       final freshItems = await LocalDatabase.instance.getLocalCart();

//       // 3. Emit the NEW state directly (Fastest way to update UI)
//       emit(CartState(items: freshItems, isLoading: false));
//     });

//     on<RemoveItem>((event, emit) async {
//       await LocalDatabase.instance
//           .updateLocalQty(event.item.id, event.item.selectedSize, 0);
//       add(LoadCart(""));
//     });

//     on<UpdateQty>((event, emit) async {
//       await LocalDatabase.instance
//           .updateLocalQty(event.item.id, event.item.selectedSize, event.newQty);
//       add(LoadCart(""));
//     });

//     on<ClearCartEvent>((event, emit) async {
//       await LocalDatabase.instance.clearLocalCart();
//       emit(const CartState(items: [], isLoading: false));
//     });
//   }
// }
import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../data/models/product_models.dart';
import '../../data/repositories/hustleam_repository.dart';

// ---  EVENTS ---
abstract class CartEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class LoadCart extends CartEvent {
  final String source;
  LoadCart(this.source);

  @override
  List<Object?> get props => [source];
}

class AddItem extends CartEvent {
  final CartItem item;
  AddItem(this.item);
  @override
  List<Object?> get props => [item];
}

class RemoveItem extends CartEvent {
  final CartItem item;
  RemoveItem(this.item);
  @override
  List<Object?> get props => [item];
}

class UpdateQty extends CartEvent {
  final CartItem item;
  final int newQty;
  UpdateQty(this.item, this.newQty);
  @override
  List<Object?> get props => [item, newQty];
}

class ClearCartEvent extends CartEvent {}

class _UpdateUI extends CartEvent {
  final List<CartItem> items;
  _UpdateUI(this.items);
  @override
  List<Object?> get props => [items];
}

// --- STATE ---
class CartState extends Equatable {
  final List<CartItem> items;
  final bool isLoading;
  const CartState({this.items = const [], this.isLoading = false});

  double get total => items.fold(0.0, (sum, i) => sum + (i.price * i.quantity));
  int get count => items.fold(0, (sum, i) => sum + i.quantity);

  @override
  List<Object?> get props => [items, isLoading];
}

// --- BLOC ---
class CartBloc extends Bloc<CartEvent, CartState> {
  final HustleamRepository repo;
  StreamSubscription? _subscription;

  CartBloc(this.repo) : super(const CartState(isLoading: false)) {
    on<LoadCart>((event, emit) async {
      emit(const CartState(items: [], isLoading: true));

      if (repo.currentUser != null) {
        await _subscription?.cancel();
        _subscription = repo.cartStream(repo.currentUser!.uid).listen((snap) {
          final items =
              snap.docs.map((d) => CartItem.fromFirestore(d)).toList();
          add(_UpdateUI(items));
        });
      }
    });

    on<_UpdateUI>(
        (event, emit) => emit(CartState(items: event.items, isLoading: false)));

    on<AddItem>((event, emit) async {
      if (repo.currentUser != null)
        await repo.addToCart(repo.currentUser!.uid, event.item);
    });

    on<RemoveItem>((event, emit) async {
      if (repo.currentUser != null)
        await repo.removeItem(repo.currentUser!.uid, event.item);
    });

    on<UpdateQty>((event, emit) async {
      if (repo.currentUser != null)
        await repo.updateItemQuantity(
            repo.currentUser!.uid, event.item, event.newQty);
    });

    on<ClearCartEvent>((event, emit) async {
      await _subscription?.cancel();
      if (repo.currentUser != null)
        await repo.clearLocalCart(repo.currentUser!.uid);
      emit(const CartState(items: [], isLoading: false));
    });
  }

  @override
  Future<void> close() {
    _subscription?.cancel();
    return super.close();
  }
}

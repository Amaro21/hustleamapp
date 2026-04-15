import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../data/models/product_models.dart';
import '../../data/repositories/hustleam_repository.dart';

// --- EVENTS ---
abstract class OrderEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class PlaceOrderRequested extends OrderEvent {
  final List<CartItem> items;
  final double total;
  final String address;
  final bool isCartCheckout;

  PlaceOrderRequested({
    required this.items,
    required this.total,
    required this.address,
    required this.isCartCheckout,
  });

  @override
  List<Object?> get props => [items, total, address, isCartCheckout];
}

// --- STATES ---
abstract class OrderState extends Equatable {
  @override
  List<Object?> get props => [];
}

class OrderInitial extends OrderState {}

class OrderProcessing extends OrderState {}

class OrderSuccess extends OrderState {
  final String orderId;
  OrderSuccess(this.orderId);

  @override
  List<Object?> get props => [orderId];
}

class OrderFailure extends OrderState {
  final String error;
  OrderFailure(this.error);

  @override
  List<Object?> get props => [error];
}

// --- BLOC ---
class OrderBloc extends Bloc<OrderEvent, OrderState> {
  final HustleamRepository repo;

  OrderBloc(this.repo) : super(OrderInitial()) {
    on<PlaceOrderRequested>((event, emit) async {
      emit(OrderProcessing());
      try {
        final user = repo.currentUser;
        if (user == null) throw Exception("User not authenticated");

        String orderId =
            "ORD-${DateTime.now().millisecondsSinceEpoch.toString().substring(8)}";

        final orderData = {
          'userId': user.uid,
          'orderId': orderId,
          'items': event.items.map((item) => item.toFirestore()).toList(),
          'totalPrice': event.total,
          'deliveryAddress': event.address,
          'status': 'Processing',
          'createdAt': FieldValue.serverTimestamp(),
        };

        await repo.placeOrder(orderData);

        if (event.isCartCheckout) {
          await repo.clearLocalCart(user.uid);
        }
        emit(OrderSuccess(orderId));
      } catch (e) {
        emit(OrderFailure(e.toString()));
      }
    });
  }
}

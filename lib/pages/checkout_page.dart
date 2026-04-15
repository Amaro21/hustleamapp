import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hustleamapp/data/models/product_models.dart';
import '../data/repositories/hustleam_repository.dart';
import '../logic/order/order_bloc.dart';
import '../logic/cart/cart_bloc.dart';

class CheckoutPage extends StatelessWidget {
  final List<CartItem> itemsToBuy;
  final bool isCartCheckout;

  const CheckoutPage({
    super.key,
    required this.itemsToBuy,
    this.isCartCheckout = false,
  });

  @override
  Widget build(BuildContext context) {
    final repo = context.read<HustleamRepository>();

    double subTotal = itemsToBuy.fold(
      0.0,
      (sum, item) => sum + (item.price * item.quantity),
    );
    double shippingFee = 50.0;
    double total = subTotal + shippingFee;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F8F8),
      appBar: AppBar(
        title: const Text(
          "CHECKOUT",
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
          ),
        ),
        backgroundColor: Colors.white,
        centerTitle: true,
        elevation: 0.5,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
        stream: repo.getUserData(repo.currentUser!.uid),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: Colors.black),
            );
          }

          final userData = snapshot.data?.data();
          final String email =
              userData?['email'] ?? repo.currentUser?.email ?? 'Unknown Email';
          List<dynamic> savedAddresses = userData?['savedAddresses'] ?? [];

          String deliveryAddress = userData?['selectedAddress'] ??
              (savedAddresses.isNotEmpty
                  ? savedAddresses.first.toString()
                  : '');

          return Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "ORDER SUMMARY",
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w900,
                          color: Colors.grey,
                          letterSpacing: 1.5,
                        ),
                      ),
                      const SizedBox(height: 12),
                      ...itemsToBuy
                          .map((item) => _buildOrderItem(item))
                          .toList(),
                      const SizedBox(height: 30),
                      const Text(
                        "DELIVERY DETAILS",
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w900,
                          color: Colors.grey,
                          letterSpacing: 1.5,
                        ),
                      ),
                      const SizedBox(height: 12),
                      _buildInfoCard(
                        Icons.email_outlined,
                        "Contact Email",
                        email,
                      ),
                      const SizedBox(height: 12),
                      _buildInfoCard(
                        Icons.location_on_outlined,
                        "Shipping Address",
                        deliveryAddress.isEmpty
                            ? "No address added"
                            : deliveryAddress,
                        trailing: savedAddresses.length > 1
                            ? TextButton(
                                onPressed: () => _showAddressSelector(
                                  context,
                                  savedAddresses,
                                  deliveryAddress,
                                  repo,
                                ),
                                child: const Text(
                                  "CHANGE",
                                  style: TextStyle(
                                    color: Colors.blue,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              )
                            : null,
                      ),
                      const SizedBox(height: 30),
                      const Text(
                        "PAYMENT SUMMARY",
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w900,
                          color: Colors.grey,
                          letterSpacing: 1.5,
                        ),
                      ),
                      const SizedBox(height: 12),
                      _buildReceipt(subTotal, shippingFee, total),
                    ],
                  ),
                ),
              ),
              _buildStickyFooter(context, total, deliveryAddress, repo)
            ],
          );
        },
      ),
    );
  }

  Widget _buildStickyFooter(
    BuildContext context,
    double total,
    String addr,
    HustleamRepository repo,
  ) {
    return Container(
      padding: const EdgeInsets.all(25),
      decoration: const BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 10,
            offset: Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        child: BlocConsumer<OrderBloc, OrderState>(
          listener: (context, state) {
            if (state is OrderSuccess) {
              _showSuccess(context, addr, itemsToBuy);
            }
            if (state is OrderFailure) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text("Error: ${state.error}"),
                  backgroundColor: Colors.red,
                ),
              );
            }
          },
          builder: (context, state) {
            bool isLoading = state is OrderProcessing;

            // return ElevatedButton(
            //   // Button is disabled if address is missing OR if order is processing
            //   onPressed: (addr.isEmpty || isLoading)
            //       ? null
            //       : () {
            //           context.read<OrderBloc>().add(
            //                 PlaceOrderRequested(
            //                   items: itemsToBuy,
            //                   total: total,
            //                   address: addr,
            //                   isCartCheckout:
            //                       isCartCheckout, // <--- Pass the parameter from the widget
            //                 ),
            //               );
            //         },
            return ElevatedButton(
              onPressed: addr.isEmpty
                  ? null
                  : () async {
                      try {
                        await repo.placeOrder({
                          'userId': repo.currentUser!.uid,
                          'items': itemsToBuy
                              .map((item) => item.toFirestore())
                              .toList(),
                          'totalPrice': total,
                          'deliveryAddress': addr,
                          'status': 'Processing',
                          'createdAt': FieldValue.serverTimestamp(),
                        });

                        context.read<CartBloc>().add(ClearCartEvent());

                        // SHOW SUCCESS
                        if (context.mounted) {
                          _showSuccess(context, addr, itemsToBuy);
                        }
                      } catch (e) {
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                                content: Text("Order Failed: $e"),
                                backgroundColor: Colors.red),
                          );
                        }
                      }
                    },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                minimumSize: const Size(double.infinity, 55),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
              child: isLoading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : const Text(
                      "PLACE ORDER",
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.5,
                      ),
                    ),
            );
          },
        ),
      ),
    );
  }

  // --- UI HELPERS ---

  Widget _buildOrderItem(CartItem item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: item.image.startsWith('http')
                ? Image.network(
                    item.image,
                    width: 60,
                    height: 60,
                    fit: BoxFit.cover,
                  )
                : Image.asset(
                    'assets/images/placeholder.jpg',
                    width: 60,
                    height: 60,
                  ),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.name.toUpperCase(),
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                Text(
                  "Size: ${item.selectedSize} | Qty: ${item.quantity}",
                  style: const TextStyle(color: Colors.grey, fontSize: 12),
                ),
              ],
            ),
          ),
          Text(
            "₱${(item.price * item.quantity).toStringAsFixed(2)}",
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard(
    IconData icon,
    String title,
    String content, {
    Widget? trailing,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.black),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.grey,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  content,
                  style: const TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          if (trailing != null) trailing,
        ],
      ),
    );
  }

  Widget _buildReceipt(double sub, double ship, double total) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        children: [
          _row("Subtotal", sub),
          const SizedBox(height: 10),
          _row("Shipping Fee", ship),
          const Divider(height: 30),
          _row("Total Amount", total, isBold: true),
        ],
      ),
    );
  }

  Widget _row(String label, double val, {bool isBold = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            fontSize: isBold ? 18 : 14,
          ),
        ),
        Text(
          "₱${val.toStringAsFixed(2)}",
          style: TextStyle(
            fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            fontSize: isBold ? 18 : 14,
          ),
        ),
      ],
    );
  }

  void _showAddressSelector(
    BuildContext context,
    List<dynamic> addresses,
    String current,
    HustleamRepository repo,
  ) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text("Select Address"),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        content: SizedBox(
          width: double.maxFinite,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: addresses
                .map(
                  (addr) => RadioListTile<String>(
                    title: Text(addr.toString()),
                    value: addr.toString(),
                    groupValue: current,
                    activeColor: Colors.black,
                    onChanged: (val) {
                      if (val != null) {
                        repo.selectAddress(
                          repo.currentUser!.uid,
                          val,
                          isNew: false,
                        );
                        Navigator.pop(dialogContext);
                      }
                    },
                  ),
                )
                .toList(),
          ),
        ),
      ),
    );
  }

  void _showSuccess(BuildContext context, String addr, List<CartItem> items) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        child: Container(
          padding: const EdgeInsets.all(25),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircleAvatar(
                radius: 40,
                backgroundColor: Color(0xFFE8F5E9),
                child: Icon(
                  Icons.check_circle,
                  color: Color(0xFF00B761),
                  size: 60,
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                "THANK YOU!",
                style: TextStyle(
                  fontWeight: FontWeight.w900,
                  fontSize: 20,
                  letterSpacing: 2,
                ),
              ),
              const Divider(height: 40),
              const Text(
                "ORDER RECAP",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 15),
              SizedBox(
                height: 70,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: items.length,
                  itemBuilder: (context, index) => Container(
                    margin: const EdgeInsets.only(right: 10),
                    width: 70,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF6F6F6),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: items[index].image.startsWith('http')
                          ? Image.network(
                              items[index].image,
                              fit: BoxFit.contain,
                            )
                          : Image.asset('assets/images/placeholder.jpg'),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 30),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  minimumSize: const Size(double.infinity, 55),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
                child: const Text(
                  "BACK TO SHOP",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

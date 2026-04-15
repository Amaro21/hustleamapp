import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../logic/cart/cart_bloc.dart';
import 'package:hustleamapp/data/models/product_models.dart';
import 'package:hustleamapp/pages/checkout_page.dart';

class CartPage extends StatelessWidget {
  const CartPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFBFBFC),
      appBar: AppBar(
        title: const Text("MY BAG", style: TextStyle(letterSpacing: 4)),
      ),
      body: BlocBuilder<CartBloc, CartState>(
        builder: (context, state) {
          if (state.isLoading)
            return const Center(
              child: CircularProgressIndicator(color: Colors.black),
            );
          // if (state.items.isEmpty)
          //   return const Center(
          //     child: Text(
          //       "BAG IS EMPTY",
          //       style: TextStyle(
          //         fontWeight: FontWeight.bold,
          //         color: Colors.grey,
          //       ),
          //     ),
          //   );

          return Column(
            children: [
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(20),
                  itemCount: state.items.length,
                  itemBuilder: (context, i) =>
                      _buildItem(context, state.items[i]),
                ),
              ),
              _buildSummary(context, state),
            ],
          );
        },
      ),
    );
  }

  Widget _buildItem(BuildContext context, CartItem item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 15),
        ],
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(15),
            child: Image.network(
              item.image,
              width: 80,
              height: 80,
              fit: BoxFit.contain,
              errorBuilder: (c, e, s) => const Icon(Icons.image),
            ),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.name.toUpperCase(),
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(
                  "Size: ${item.selectedSize}",
                  style: const TextStyle(color: Colors.grey, fontSize: 12),
                ),
                Text(
                  "₱${item.price.toStringAsFixed(2)}",
                  style: const TextStyle(fontWeight: FontWeight.w900),
                ),
              ],
            ),
          ),
          Column(
            children: [
              IconButton(
                icon: const Icon(
                  Icons.remove_circle_outline,
                  color: Colors.grey,
                ),
                onPressed: () => context.read<CartBloc>().add(RemoveItem(item)),
              ),
              Row(
                children: [
                  _qty(
                    Icons.remove,
                    () => context.read<CartBloc>().add(
                          UpdateQty(item, item.quantity - 1),
                        ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: Text("${item.quantity}"),
                  ),
                  _qty(
                    Icons.add,
                    () => context.read<CartBloc>().add(
                          UpdateQty(item, item.quantity + 1),
                        ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _qty(IconData icon, VoidCallback tap) =>
      InkWell(onTap: tap, child: Icon(icon, size: 18));

  Widget _buildSummary(BuildContext context, CartState state) {
    return Container(
      padding: const EdgeInsets.fromLTRB(30, 30, 30, 40),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Total",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              Text(
                "₱${state.total.toStringAsFixed(2)}",
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            height: 55,
            child: ElevatedButton(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => CheckoutPage(
                    itemsToBuy: state.items,
                    isCartCheckout: true,
                  ),
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
              child: const Text(
                "CHECKOUT",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

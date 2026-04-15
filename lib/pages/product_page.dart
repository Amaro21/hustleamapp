import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hustleamapp/data/models/product_models.dart';
import 'package:hustleamapp/logic/cart/cart_bloc.dart';
import 'package:hustleamapp/pages/checkout_page.dart';

class ProductPage extends StatefulWidget {
  final String productId;

  const ProductPage({super.key, required this.productId});

  @override
  State<ProductPage> createState() => _ProductPageState();
}

class _ProductPageState extends State<ProductPage> {
  String selectedSize = "M";
  bool showSizeChart = false;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance
          .collection('products')
          .doc(widget.productId)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData || !snapshot.data!.exists) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator(color: Colors.black)),
          );
        }

        var data = snapshot.data!.data() as Map<String, dynamic>;
        String name = data['name'] ?? 'Exclusive Item';
        double price = (data['price'] ?? 0.0).toDouble();
        String description = data['description'] ?? '';
        String imageUrl = data['image'] ?? '';
        List<dynamic> sizes = data['availableSizes'] ?? ['S', 'M', 'L', 'XL'];
        int stock = data['stock'] ?? 0;

        return Scaffold(
          backgroundColor: Colors.white,
          extendBodyBehindAppBar: true,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            leading: Padding(
              padding: const EdgeInsets.all(8.0),
              child: CircleAvatar(
                backgroundColor: Colors.white.withOpacity(0.9),
                child: IconButton(
                  icon: const Icon(Icons.arrow_back_ios_new,
                      size: 18, color: Colors.black),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
            ),
          ),
          body: Stack(
            children: [
              SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // --- PRODUCT IMAGE ---
                    Container(
                      width: double.infinity,
                      height: MediaQuery.of(context).size.height * 0.55,
                      decoration: BoxDecoration(
                        color: const Color(0xFFF6F6F6),
                        image: DecorationImage(
                          image: NetworkImage(imageUrl),
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),

                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 25.0, vertical: 30),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "HUSTLEAM CLOTHING CO.",
                            style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w800,
                                color: Colors.grey,
                                letterSpacing: 2),
                          ),
                          const SizedBox(height: 10),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  name.toUpperCase(),
                                  style: const TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.w900,
                                      letterSpacing: -0.5),
                                ),
                              ),
                              Text(
                                '₱${price.toStringAsFixed(2)}',
                                style: const TextStyle(
                                    fontSize: 20, fontWeight: FontWeight.w400),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),

                          // ---  STOCK STATUS ---
                          Row(
                            children: [
                              Container(
                                width: 8,
                                height: 8,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: stock > 5
                                      ? Colors.green
                                      : (stock > 0
                                          ? Colors.orange
                                          : Colors.red),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                stock > 5
                                    ? "IN STOCK"
                                    : (stock > 0
                                        ? "ONLY $stock LEFT - LOW STOCK"
                                        : "OUT OF STOCK"),
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: stock > 5
                                      ? Colors.green
                                      : (stock > 0
                                          ? Colors.orange
                                          : Colors.red),
                                  letterSpacing: 1,
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 35),

                          // --- SIZE SELECTOR ---
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text("SELECT SIZE",
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 13,
                                      letterSpacing: 1)),
                              GestureDetector(
                                onTap: () =>
                                    setState(() => showSizeChart = true),
                                child: const Text("SIZE GUIDE",
                                    style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                        decoration: TextDecoration.underline)),
                              ),
                            ],
                          ),
                          const SizedBox(height: 15),
                          Wrap(
                            spacing: 12,
                            runSpacing: 12,
                            children: sizes
                                .map((size) => _buildSizeBox(size.toString()))
                                .toList(),
                          ),

                          const SizedBox(height: 40),

                          // --- ACTION BUTTONS ---
                          _buildMainActionBtn(
                            label: stock > 0 ? "ADD TO BAG" : "OUT OF STOCK",
                            color: Colors.black,
                            textColor: Colors.white,
                            onTap: stock <= 0
                                ? null
                                : () {
                                    CartItem newItem = CartItem(
                                      id: widget.productId,
                                      name: name,
                                      image: imageUrl,
                                      price: price,
                                      selectedSize: selectedSize,
                                      quantity: 1,
                                    );

                                    context
                                        .read<CartBloc>()
                                        .add(AddItem(newItem));

                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                            "${name.toUpperCase()} ADDED TO BAG"),
                                        behavior: SnackBarBehavior.floating,
                                        backgroundColor: Colors.black,
                                        margin: const EdgeInsets.all(20),
                                      ),
                                    );
                                  },
                          ),
                          const SizedBox(height: 12),
                          _buildMainActionBtn(
                            label: "BUY IT NOW",
                            color: Colors.white,
                            textColor: Colors.black,
                            isOutlined: true,
                            onTap: stock <= 0
                                ? null
                                : () {
                                    CartItem item = CartItem(
                                      id: widget.productId,
                                      name: name,
                                      image: imageUrl,
                                      price: price,
                                      selectedSize: selectedSize,
                                      quantity: 1,
                                    );
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => CheckoutPage(
                                          itemsToBuy: [item],
                                          isCartCheckout: false,
                                        ),
                                      ),
                                    );
                                  },
                          ),

                          const SizedBox(height: 40),

                          // --- DESCRIPTION ---
                          const Text("PRODUCT DETAILS",
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                  letterSpacing: 1)),
                          const SizedBox(height: 15),
                          Text(
                            description,
                            style: TextStyle(
                                fontSize: 15,
                                height: 1.6,
                                color: Colors.black.withOpacity(0.7)),
                          ),
                          const SizedBox(height: 60),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              // OVERLAYS
              if (showSizeChart) _buildSizeChartOverlay(),
            ],
          ),
        );
      },
    );
  }

  // --- UI HELPERS ---

  Widget _buildSizeBox(String size) {
    bool isSelected = selectedSize == size;
    return GestureDetector(
      onTap: () => setState(() => selectedSize = size),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 60,
        height: 50,
        decoration: BoxDecoration(
          color: isSelected ? Colors.black : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
              color: isSelected ? Colors.black : Colors.grey.shade300,
              width: 1.5),
        ),
        alignment: Alignment.center,
        child: Text(
          size,
          style: TextStyle(
              color: isSelected ? Colors.white : Colors.black,
              fontWeight: FontWeight.w700,
              fontSize: 15),
        ),
      ),
    );
  }

  Widget _buildMainActionBtn(
      {required String label,
      required Color color,
      required Color textColor,
      bool isOutlined = false,
      required VoidCallback? onTap}) {
    return SizedBox(
      width: double.infinity,
      height: 55,
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          disabledBackgroundColor: Colors.grey.shade200,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
            side: isOutlined
                ? const BorderSide(color: Colors.black, width: 1.5)
                : BorderSide.none,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
              color: textColor,
              fontWeight: FontWeight.w900,
              fontSize: 15,
              letterSpacing: 1.5),
        ),
      ),
    );
  }

  Widget _buildSizeChartOverlay() {
    return Container(
      color: Colors.black.withOpacity(0.85),
      alignment: Alignment.center,
      child: Container(
        width: MediaQuery.of(context).size.width * 0.85,
        padding: const EdgeInsets.all(25),
        decoration: BoxDecoration(
            color: Colors.white, borderRadius: BorderRadius.circular(25)),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('SIZE GUIDE',
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1)),
            const SizedBox(height: 20),
            ClipRRect(
              borderRadius: BorderRadius.circular(15),
              child: Image.asset(
                'assets/images/sizechart.jpg',
                errorBuilder: (c, e, s) =>
                    const Icon(Icons.image_not_supported, size: 50),
              ),
            ),
            const SizedBox(height: 25),
            _buildMainActionBtn(
              label: "GOT IT",
              color: Colors.black,
              textColor: Colors.white,
              onTap: () => setState(() => showSizeChart = false),
            ),
          ],
        ),
      ),
    );
  }
}

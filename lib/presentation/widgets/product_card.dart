// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import '../../data/models/product_models.dart';
// import '../../pages/product_page.dart';
// import '../../logic/favorites/favorites_bloc.dart';

// class ProductCard extends StatelessWidget {
//   final Product product;

//   const ProductCard({super.key, required this.product});

//   @override
//   Widget build(BuildContext context) {
//     return InkWell(
//       onTap: () => Navigator.push(
//         context,
//         MaterialPageRoute(builder: (_) => ProductPage(productId: product.id)),
//       ),
//       child: Container(
//         margin: const EdgeInsets.fromLTRB(5, 0, 15, 15),
//         decoration: BoxDecoration(
//           color: Colors.white,
//           borderRadius: BorderRadius.circular(25),
//           boxShadow: [
//             BoxShadow(
//               color: Colors.black.withOpacity(0.03),
//               blurRadius: 20,
//               offset: const Offset(0, 10),
//             ),
//           ],
//         ),
//         child: Column(
//           children: [
//             Expanded(
//               child: Stack(
//                 children: [
//                   ClipRRect(
//                     borderRadius: const BorderRadius.vertical(
//                       top: Radius.circular(25),
//                     ),
//                     child: Container(
//                       width: double.infinity,
//                       color: const Color(0xFFF3F3F3),
//                       child: Image.network(product.image, fit: BoxFit.contain),
//                     ),
//                   ),
//                   Positioned(
//                     top: 10,
//                     right: 10,
//                     child: BlocBuilder<FavoritesBloc, FavoritesState>(
//                       builder: (context, state) {
//                         bool isFav =
//                             state.items.any((item) => item.id == product.id);

//                         return GestureDetector(
//                           onTap: () {
//                             context
//                                 .read<FavoritesBloc>()
//                                 .add(ToggleFavorite(product));
//                           },
//                           child: CircleAvatar(
//                             backgroundColor: Colors.white.withOpacity(0.8),
//                             radius: 15,
//                             child: Icon(
//                               isFav ? Icons.favorite : Icons.favorite_border,
//                               color: isFav ? Colors.red : Colors.black,
//                               size: 16,
//                             ),
//                           ),
//                         );
//                       },
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//             Padding(
//               padding: const EdgeInsets.all(20),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text(
//                     product.name.toUpperCase(),
//                     style: const TextStyle(
//                       fontWeight: FontWeight.w900,
//                       fontSize: 14,
//                       letterSpacing: 0.5,
//                     ),
//                   ),
//                   const SizedBox(height: 5),
//                   Text(
//                     "₱${product.price.toStringAsFixed(2)}",
//                     style: TextStyle(
//                       color: Colors.grey.shade600,
//                       fontWeight: FontWeight.bold,
//                       fontSize: 13,
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/models/product_models.dart';
import '../../presentation/pages/pages.dart';
import '../../logic/favorites/favorites_bloc.dart';

class ProductCard extends StatelessWidget {
  final Product product;

  const ProductCard({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(5, 0, 15, 15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 20,
            offset: const Offset(0, 10),
          )
        ],
      ),
      child: Stack(
        children: [
          InkWell(
            borderRadius: BorderRadius.circular(25),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (_) => ProductPage(productId: product.id)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: ClipRRect(
                    borderRadius:
                        const BorderRadius.vertical(top: Radius.circular(25)),
                    child: Container(
                      width: double.infinity,
                      color: const Color(0xFFF3F3F3),
                      child: product.image.startsWith('http')
                          ? Image.network(product.image, fit: BoxFit.contain)
                          : Image.asset('assets/images/placeholder.jpg'),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        product.name.toUpperCase(),
                        style: const TextStyle(
                            fontWeight: FontWeight.w900,
                            fontSize: 13,
                            letterSpacing: 0.5),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 5),
                      Text(
                        "₱${product.price.toStringAsFixed(2)}",
                        style: TextStyle(
                            color: Colors.grey.shade600,
                            fontWeight: FontWeight.bold,
                            fontSize: 12),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            top: 10,
            right: 10,
            child: BlocBuilder<FavoritesBloc, FavoritesState>(
              builder: (context, state) {
                bool isFav = state.items.any((item) => item.id == product.id);

                return CircleAvatar(
                  backgroundColor: Colors.white.withOpacity(0.9),
                  radius: 18,
                  child: IconButton(
                    padding: EdgeInsets.zero,
                    icon: Icon(
                      isFav ? Icons.favorite : Icons.favorite_border,
                      color: isFav ? Colors.red : Colors.black,
                      size: 18,
                    ),
                    onPressed: () {
                      print("DEBUG: Toggled Favorite for ${product.name}");

                      context
                          .read<FavoritesBloc>()
                          .add(ToggleFavorite(product));
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

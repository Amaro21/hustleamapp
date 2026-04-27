// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:hustleamapp/core/theme.dart';
// import 'package:device_preview/device_preview.dart';
// import 'package:firebase_core/firebase_core.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import '../data/repositories/hustleam_repository.dart';
// import 'logic/cart/cart_bloc.dart';
// import 'firebase_options.dart';
// import '../logic/order/order_bloc.dart';
// import 'package:hustleamapp/presentation/pages/pages.dart';
// import 'package:hustleamapp/logic/favorites/favorites_bloc.dart';

// void main() async {
//   WidgetsFlutterBinding.ensureInitialized();
//   await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
//   final repo = HustleamRepository();
//   runApp(
//     // DevicePreview(
//     //   enabled: true,
//     //   builder: (context) =>
//     MultiBlocProvider(
//       providers: [
//         RepositoryProvider.value(value: repo),
//         BlocProvider(create: (_) => CartBloc(repo)..add(LoadCart("local"))),
//         BlocProvider(create: (_) => OrderBloc(repo)),
//         BlocProvider(create: (_) => FavoritesBloc()..add(LoadFavorites())),
//       ],
//       child: const HustleamApp(),
//     ),
//     // ),
//   );
// }

// class HustleamApp extends StatelessWidget {
//   const HustleamApp({super.key});
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       useInheritedMediaQuery: true,
//       builder: DevicePreview.appBuilder,
//       debugShowCheckedModeBanner: false,
//       theme: AppTheme.lightTheme,
//       //ThemeData(scaffoldBackgroundColor: const Color(0xFFFBFBFC)),
//       home: const AuthWrapper(),
//     );
//   }
// }

// class AuthWrapper extends StatelessWidget {
//   const AuthWrapper({super.key});

//   @override
//   Widget build(BuildContext context) {
//     final repo = context.read<HustleamRepository>();

//     return StreamBuilder<User?>(
//       stream: repo.userStream,
//       builder: (context, snapshot) {
//         if (snapshot.connectionState == ConnectionState.waiting) {
//           return const Scaffold(
//             body: Center(child: CircularProgressIndicator(color: Colors.black)),
//           );
//         }

//         // if (snapshot.hasData && snapshot.data != null) {
//         //   final String uid = snapshot.data!.uid;

//         //   // --- TRIGGER CART LOAD SAFELY ---
//         //   // This ensures the BLoC is told to start listening to Firestore
//         //   // the moment the user is confirmed.
//         //   final cartBloc = context.read<CartBloc>();
//         //   if (cartBloc.state.isLoading || cartBloc.state.items.isEmpty) {
//         //     cartBloc.add(LoadCart(uid));
//         //   }

//         //   return const MainNavigation();
//         // }

//         if (snapshot.hasData && snapshot.data != null) {
//           // masabi sa bag na mag load from the phone memory
//           context.read<CartBloc>().add(LoadCart("local"));
//           return const MainNavigation();
//         }

//         return const LoginPage();
//       },
//     );
//   }
// }

// class MainNavigation extends StatefulWidget {
//   const MainNavigation({super.key});
//   @override
//   State<MainNavigation> createState() => _MainNavigationState();
// }

// class _MainNavigationState extends State<MainNavigation> {
//   int _index = 0;
//   final _screens = [
//     const HomePage(),
//     const OrdersPage(),
//     const CartPage(),
//     const ProfilePage(),
//   ];
//   @override
//   Widget build(BuildContext context) {
//     final cartState = context.watch<CartBloc>().state;
//     return Scaffold(
//       body: IndexedStack(index: _index, children: _screens),
//       bottomNavigationBar: BottomNavigationBar(
//         currentIndex: _index,
//         onTap: (i) => setState(() => _index = i),
//         type: BottomNavigationBarType.fixed,
//         selectedItemColor: Colors.black,
//         items: [
//           const BottomNavigationBarItem(
//             icon: Icon(Icons.home_outlined),
//             label: "Home",
//           ),
//           const BottomNavigationBarItem(
//             icon: Icon(Icons.receipt_long_outlined),
//             label: "Orders",
//           ),
//           BottomNavigationBarItem(
//             icon: BlocBuilder<CartBloc, CartState>(
//               builder: (context, state) {
//                 return Badge(
//                   // state.count is the helper we added to CartState earlier
//                   label: Text(state.count.toString()),
//                   isLabelVisible: state.count > 0,
//                   backgroundColor: Colors.black,
//                   child: const Icon(Icons.shopping_bag_outlined),
//                 );
//               },
//             ),
//             label: "Cart",
//           ),
//           const BottomNavigationBarItem(
//             icon: Icon(Icons.person_outline),
//             label: "Profile",
//           ),
//         ],
//       ),
//     );
//   }
// }
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:hustleamapp/core/theme.dart';
import 'package:hustleamapp/data/repositories/hustleam_repository.dart';
import 'package:hustleamapp/logic/cart/cart_bloc.dart';
import 'package:hustleamapp/logic/order/order_bloc.dart';
import 'package:hustleamapp/logic/favorites/favorites_bloc.dart';
import 'package:hustleamapp/presentation/pages/pages.dart';
import 'package:hustleamapp/firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  final repo = HustleamRepository();

  runApp(
    MultiBlocProvider(
      providers: [
        RepositoryProvider.value(value: repo),
        BlocProvider(create: (_) => CartBloc(repo)..add(LoadCart("local"))),
        BlocProvider(create: (_) => OrderBloc(repo)),
        BlocProvider(create: (_) => FavoritesBloc()..add(LoadFavorites())),
      ],
      child: const HustleamApp(),
    ),
  );
}

class HustleamApp extends StatelessWidget {
  const HustleamApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: const AuthWrapper(),
    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    final repo = context.read<HustleamRepository>();

    return StreamBuilder<User?>(
      stream: repo.userStream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator(color: Colors.black)),
          );
        }

        // if (snapshot.hasData && snapshot.data != null) {
        //   WidgetsBinding.instance.addPostFrameCallback((_) {
        //     final cartBloc = context.read<CartBloc>();

        //     if (!cartBloc.state.isLoading && cartBloc.state.items.isEmpty) {
        //       cartBloc.add(LoadCart("local"));
        //     }
        //   });

        final user = snapshot.data;

        if (user != null) {
          Future.microtask(() {
            if (context.mounted) {
              context.read<CartBloc>().add(LoadCart(user.uid));
            }
          });

          return const MainNavigation();
        }

        return const LoginPage();
      },
    );
  }
}

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});
  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _index = 0;

  final _screens = [
    const HomePage(),
    const OrdersPage(),
    const CartPage(),
    const ProfilePage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _index, children: _screens),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _index,
        onTap: (i) => setState(() => _index = i),
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.black,
        unselectedItemColor: Colors.grey.shade400,
        showSelectedLabels: true,
        showUnselectedLabels: true,
        items: [
          const BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined),
              activeIcon: Icon(Icons.home),
              label: "Home"),
          const BottomNavigationBarItem(
              icon: Icon(Icons.receipt_long_outlined),
              activeIcon: Icon(Icons.receipt_long),
              label: "Orders"),
          BottomNavigationBarItem(
            icon: BlocBuilder<CartBloc, CartState>(
              builder: (context, state) {
                return Badge(
                  label: Text(state.count.toString()),
                  isLabelVisible: state.count > 0,
                  backgroundColor: Colors.black,
                  child: const Icon(Icons.shopping_bag_outlined),
                );
              },
            ),
            label: "Cart",
          ),
          const BottomNavigationBarItem(
              icon: Icon(Icons.person_outline),
              activeIcon: Icon(Icons.person),
              label: "Profile"),
        ],
      ),
    );
  }
}

// lib/widgets/app_bar_actions.dart
import 'package:flutter/material.dart';
import '../models/cart.dart';
import '../screens/cart_screen.dart';
import '../screens/login_screen.dart';
import '../screens/favorites_screen.dart';

class AppBarActions extends StatelessWidget {
  const AppBarActions({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Favorites button with tooltip
        Tooltip(
          message: 'My Favorites',
          child: Container(
            
            child: IconButton(
              icon: const Icon(
                Icons.favorite,
                color: Colors.deepOrange,
                size: 28,
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => FavoritesScreen()),
                );
              },
            ),
          ),
        ),
        const SizedBox(width: 0), // Add some spacing
        // Cart Icon with badge
        Stack(
          children: [
            IconButton(
              icon: const Icon(Icons.shopping_cart_outlined, color: Colors.deepOrange),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const CartScreen()),
                );
              },
            ),
            Positioned(
              right: 4,
              top: 4,
              // Use ValueListenableBuilder to listen for changes in the cart count
              child: ValueListenableBuilder<int>(
                valueListenable: Cart.totalItemsNotifier,
                builder: (context, totalItems, _) {
                  return CircleAvatar(
                    radius: 10,
                    backgroundColor: const Color.fromARGB(255, 255, 255, 255),
                    child: Text(
                      '$totalItems',
                      style: const TextStyle(fontSize: 12, color: Colors.black),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
        IconButton(
          icon: const Icon((Icons.logout),
                            color: Colors.deepOrange,),
          onPressed: () {
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (_) => LoginScreen()),
              (route) => false,
            );
          },
        ),
      ],
    );
  }
}

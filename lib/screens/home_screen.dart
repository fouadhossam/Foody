import 'package:flutter/material.dart';
import 'food_detail_screen.dart';
import 'profile_screen.dart';
import '../../widgets/app_bar_actions.dart';

class HomeScreen extends StatelessWidget {
  // List of food categories
  final List<Map<String, dynamic>> categories = [
    {'name': 'Burger', 'icon': Icons.lunch_dining},
    {'name': 'Pizza', 'icon': Icons.local_pizza},
    {'name': 'Pasta', 'icon': Icons.dinner_dining},
    {'name': 'Salad', 'icon': Icons.eco},
    {'name': 'Soup', 'icon': Icons.soup_kitchen},
    {'name': 'Cake', 'icon': Icons.cake},
    {'name': 'Hot Drinks', 'icon': Icons.emoji_food_beverage},
    {'name': 'Cold Drinks', 'icon': Icons.local_drink},

  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Categories',
          style: TextStyle(color: Colors.deepOrange),
        ),
        actions: const [AppBarActions()],
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2, // Two cards per row
            childAspectRatio: 1,
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
          ),
          itemCount: categories.length,
          itemBuilder: (context, index) {
            final category = categories[index];
            return Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 4,
              child: InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => FoodDetailScreen(
                        categoryName: category['name'],
                      ),
                    ),
                  );
                },
                borderRadius: BorderRadius.circular(16),
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        category['icon'],
                        size: 48,
                        color: Colors.deepOrange,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        category['name'],
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.deepOrange,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
      // Bottom Navigation Bar with Profile, Cart (with badge), and Logout buttons
      bottomNavigationBar: BottomAppBar(
        
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              // Profile button
              IconButton(
                icon: const Icon(Icons.person, color: Colors.deepOrange, size: 55),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => const ProfileScreen()),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

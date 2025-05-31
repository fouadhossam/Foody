import 'package:flutter/material.dart';
import '../../models/cart.dart';
import '../../widgets/app_bar_actions.dart';
import '../services/cart_service.dart';
import '../services/food_service.dart';

class FoodDetailScreen extends StatefulWidget {
  final String categoryName;

  const FoodDetailScreen({Key? key, required this.categoryName})
      : super(key: key);

  @override
  State<FoodDetailScreen> createState() => _FoodDetailScreenState();
}

class _FoodDetailScreenState extends State<FoodDetailScreen> {
  final CartService _cartService = CartService();
  final FoodService _foodService = FoodService();
  // Dummy data for food items per category (example)
  final Map<String, List<Map<String, dynamic>>> allFoodItems = {
    'Pizza': [
      {
        'id': 'pizza1',
        'name': 'The Classic',
        'description': "With this pizza, you won't be hungry for days...",
        'price': 99.00,
        'oldPrice': 150.00,
        'tags': ['VEG', 'SPICY'],
        'image': 'assets/images/pizza1.png',
      },
      {
        'id': 'pizza2',
        'name': 'The Beast',
        'description': 'This is the best cheesy pizza you will ever have!',
        'price': 100.00,
        'oldPrice': 125.00,
        'tags': ['NON-VEG', 'BLAND'],
        'image': 'assets/images/pizza2.png',
      },
      {
        'id': 'pizza3',
        'name': 'Meat Overload',
        'description': "Packed with all the meaty goodness you can imagine!",
        'price': 135.00,
        'oldPrice': 150.00,
        'tags': ['NON-VEG', 'SPICY'],
        'image': 'assets/images/pizza4.png',
      },
      {
        'id': 'pizza4',
        'name': 'Cheesy Marvel',
        'description': 'Simple & sometimes the best choice!',
        'price': 90.00,
        'oldPrice': 129.99,
        'tags': ['VEG', 'BALANCE'],
        'image': 'assets/images/pizza3.png',
      },
      {
        'id': 'pizza5',
        'name': 'Four Cheese Bliss',
        'description': 'A dream come true for all cheese lovers!',
        'price': 115.00,
        'oldPrice': 139.99,
        'tags': ['VEG', 'BLAND'],
        'image': 'assets/images/pizza5.png',
      },
      {
        'id': 'pizza6',
        'name': 'Meet Lover',
        'description': 'A taste of the Mediterranean with fresh Meet & feta cheese!',
        'price': 199.99,
        'oldPrice': 275.00,
        'tags': ['NON-VEG', 'BALANCE'],
        'image': 'assets/images/pizza6.png',
      }
    ],
    'Burger': [
      {
        'id': 'burger1',
        'name': 'Cheeseburger',
        'description': 'A classic cheeseburger with lettuce, tomato, and onion.',
        'price': 69.99,
        'oldPrice': 80.00,
        'tags': ['NON-VEG', 'SPICY'],
        'image': 'assets/images/burger1.png',
      },
      {
        'id': 'burger2',
        'name': 'Bacon Burger',
        'description': 'Burger topped with crispy bacon.',
        'price': 85.00,
        'oldPrice': 109.00,
        'tags': ['NON-VEG'],
        'image': 'assets/images/burger2.png',
      },
      {
      'id': 'burger3',
      'name': 'Veggie Supreme',
      'description': 'A delicious plant-based patty with fresh veggies.',
      'price': 75.00,
      'oldPrice': 95.00,
      'tags': ['VEG', 'BALANCE'],
      'image': 'assets/images/burger3.png', // Assuming you have burger images named accordingly
      },
      {
        'id': 'burger4',
        'name': 'Spicy Chicken Burger',
        'description': 'Crispy chicken patty with a fiery kick!',
        'price': 79.50,
        'oldPrice': 90.00,
        'tags': ['NON-VEG', 'SPICY'],
        'image': 'assets/images/burger4.png',
      },
      {
        'id': 'burger5',
        'name': 'Mushroom Swiss',
        'description': 'Juicy patty topped with sautéed mushrooms and melted swiss cheese.',
        'price': 92.00,
        'oldPrice': 115.00,
        'tags': ['NON-VEG', 'BLAND'],
        'image': 'assets/images/burger5.png',
      },
      {
        'id': 'burger6',
        'name': 'BBQ Burger',
        'description': 'Tender Beef smothered in smoky BBQ sauce.',
        'price': 98.00,
        'oldPrice': 120.00,
        'tags': ['NON-VEG'],
        'image': 'assets/images/burger6.png',
      },
    ],
    'Pasta': [
      {
        'id': 'pasta1',
        'name': 'Spaghetti Bolognese',
        'description': 'Classic spaghetti with a rich meat sauce.',
        'price': 85.00,
        'oldPrice': 100.00,
        'tags': ['NON-VEG', 'BALANCE'],
        'image': 'assets/images/pasta1.png', // Assuming pasta1.png exists
      },
      {
        'id': 'pasta2',
        'name': 'Fettuccine Alfredo',
        'description': 'Creamy alfredo sauce tossed with fettuccine.',
        'price': 90.00,
        'oldPrice': 110.00,
        'tags': ['VEG', 'BLAND'],
        'image': 'assets/images/pasta2.png', // Assuming pasta2.png exists
      },
      {
        'id': 'pasta3',
        'name': 'Penne Arrabbiata',
        'description': 'Penne pasta with a spicy tomato sauce.',
        'price': 78.00,
        'oldPrice': 90.00,
        'tags': ['VEG', 'SPICY'],
        'image': 'assets/images/pasta3.png', // Assuming pasta3.png exists
      },
      {
        'id': 'pasta4',
        'name': 'Chicken Pesto Pasta',
        'description': 'Penne or fusilli with grilled chicken and basil pesto.',
        'price': 95.00,
        'oldPrice': 115.00,
        'tags': ['NON-VEG', 'BALANCE'],
        'image': 'assets/images/pasta4.png', // Assuming pasta4.png exists
      },
      {
        'id': 'pasta5',
        'name': 'Lasagna',
        'description': 'Layers of pasta, meat sauce, and cheese baked to perfection.',
        'price': 110.00,
        'oldPrice': 130.00,
        'tags': ['NON-VEG'],
        'image': 'assets/images/pasta5.png', // Assuming pasta5.png exists
      },
    ],
      'Salad': [
      {
        'id': 'salad1',
        'name': 'Caesar Salad',
        'description': 'Crisp romaine lettuce, croutons, parmesan cheese, and Caesar dressing.',
        'price': 60.00,
        'oldPrice': 70.00,
        'tags': ['VEG', 'COLD', 'BLAND'], // Added 'COLD' tag
        'image': 'assets/images/salad1.png', // Assuming salad1.png exists
      },
      {
        'id': 'salad2',
        'name': 'Greek Salad',
        'description': 'Fresh tomatoes, cucumbers, red onion, feta cheese, and olives with a light vinaigrette.',
        'price': 65.00,
        'oldPrice': 75.00,
        'tags': ['VEG', 'COLD', 'BALANCE'], // Added 'COLD' tag
        'image': 'assets/images/salad2.png', // Assuming salad2.png exists
      },
      {
        'id': 'salad3',
        'name': 'Grilled Chicken Salad',
        'description': 'Mixed greens topped with grilled chicken breast.',
        'price': 85.00,
        'oldPrice': 100.00,
        'tags': ['NON-VEG', 'COLD', 'BALANCE'], // Added 'COLD' tag
        'image': 'assets/images/salad3.png', // Assuming salad3.png exists
      },
      {
        'id': 'salad4',
        'name': 'Caprese Salad',
        'description': 'Simple yet delicious with fresh mozzarella, tomatoes, and basil.',
        'price': 70.00,
        'oldPrice': 85.00,
        'tags': ['VEG', 'COLD', 'BLAND'], // Added 'COLD' tag
        'image': 'assets/images/salad4.png', // Assuming salad4.png exists
      },
      {
        'id': 'salad5',
        'name': 'Tuna Salad',
        'description': 'Flaky tuna mixed with mayonnaise and served on a bed of lettuce.',
        'price': 78.00,
        'oldPrice': 90.00,
        'tags': ['NON-VEG', 'COLD'], // Added 'COLD' tag
        'image': 'assets/images/salad5.png', // Assuming salad5.png exists
      },
    ],
    'Soup': [
    {
      'id': 'soup1',
      'name': 'Tomato Basil Soup',
      'description': 'Creamy tomato soup with fresh basil.',
      'price': 45.00,
      'oldPrice': 55.00,
      'tags': ['VEG', 'HOT', 'BLAND'], // Added 'HOT' tag
      'image': 'assets/images/soup1.png', // Assuming soup1.png exists
    },
    {
      'id': 'soup2',
      'name': 'Chicken Noodle Soup',
      'description': 'Comforting chicken broth with noodles and vegetables.',
      'price': 50.00,
      'oldPrice': 60.00,
      'tags': ['NON-VEG', 'HOT', 'BALANCE'], // Added 'HOT' tag
      'image': 'assets/images/soup2.png', // Assuming soup2.png exists
    },
    {
      'id': 'soup3',
      'name': 'Lentil Soup',
      'description': 'Hearty and nutritious lentil soup.',
      'price': 48.00,
      'oldPrice': 58.00,
      'tags': ['VEG', 'HOT', 'BALANCE'], // Added 'HOT' tag
      'image': 'assets/images/soup3.png', // Assuming soup3.png exists
    },
    {
      'id': 'soup4',
      'name': 'Broccoli Cheddar Soup',
      'description': 'Rich and cheesy broccoli soup.',
      'price': 55.00,
      'oldPrice': 65.00,
      'tags': ['VEG', 'HOT', 'BLAND'], // Added 'HOT' tag
      'image': 'assets/images/soup4.png', // Assuming soup4.png exists
    },
  ],
  'Cake': [
      {
        'id': 'cake1',
        'name': 'Chocolate Lava Cake',
        'description': 'Warm chocolate cake with a molten chocolate center.',
        'price': 55.00,
        'oldPrice': 65.00,
        'tags': ['VEG', 'HOT', 'SWEET'], // Added 'SWEET' tag
        'image': 'assets/images/cake1.png', // Assuming cake1.png exists
      },
      {
        'id': 'cake2',
        'name': 'New York Cheesecake',
        'description': 'Rich and creamy classic cheesecake.',
        'price': 60.00,
        'oldPrice': 70.00,
        'tags': ['VEG', 'COLD', 'SWEET', 'BLAND'], // Added 'SWEET' tag
        'image': 'assets/images/cake2.png', // Assuming cake2.png exists
      },
      {
        'id': 'cake3',
        'name': 'Red Velvet Cake',
        'description': 'Moist red velvet cake with cream cheese frosting.',
        'price': 58.00,
        'oldPrice': 68.00,
        'tags': ['VEG', 'SWEET'], // Added 'SWEET' tag
        'image': 'assets/images/cake3.png', // Assuming cake3.png exists
      },
      {
        'id': 'cake4',
        'name': 'Carrot Cake',
        'description': 'Spiced carrot cake with walnuts and cream cheese frosting.',
        'price': 52.00,
        'oldPrice': 62.00,
        'tags': ['VEG', 'SWEET', 'BALANCE'], // Added 'SWEET' tag
        'image': 'assets/images/cake4.png', // Assuming cake4.png exists
      },
      {
        'id': 'cake5',
        'name': 'Lemon Drizzle Cake',
        'description': 'Tangy lemon cake with a sweet glaze.',
        'price': 48.00,
        'oldPrice': 58.00,
        'tags': ['VEG', 'SWEET', 'COLD'], // Added 'SWEET' tag
        'image': 'assets/images/cake5.png', // Assuming cake5.png exists
      },
    ],
    'Hot Drinks': [
      {
        'id': 'hotdrink1',
        'name': 'Cappuccino',
        'description': 'Espresso with steamed milk and foam.',
        'price': 35.00,
        'oldPrice': 40.00,
        'tags': ['BLAND'],
        'image': 'assets/images/hotdrink1.png', // Assuming hotdrink1.png exists
      },
      {
        'id': 'hotdrink2',
        'name': 'Latte',
        'description': 'Espresso with a large amount of steamed milk.',
        'price': 35.00,
        'oldPrice': 40.00,
        'tags': ['BLAND'],
        'image': 'assets/images/hotdrink2.png', // Assuming hotdrink2.png exists
      },
      {
        'id': 'hotdrink3',
        'name': 'Americano',
        'description': 'Espresso diluted with hot water.',
        'price': 30.00,
        'oldPrice': 35.00,
        'tags': [],
        'image': 'assets/images/hotdrink3.png', // Assuming hotdrink3.png exists
      },
      {
        'id': 'hotdrink4',
        'name': 'Hot Chocolate',
        'description': 'Rich and creamy hot chocolate topped with whipped cream.',
        'price': 40.00,
        'oldPrice': 45.00,
        'tags': ['SWEET'], // Using 'SWEET' tag from cakes, or you can add a 'DRINK' tag
        'image': 'assets/images/hotdrink4.png', // Assuming hotdrink4.png exists
      },
      {
        'id': 'hotdrink5',
        'name': 'Espresso',
        'description': 'A concentrated shot of coffee.',
        'price': 28.00,
        'oldPrice': 32.00,
        'tags': [],
        'image': 'assets/images/hotdrink5.png', // Assuming hotdrink5.png exists
      },
      {
        'id': 'hotdrink6',
        'name': 'Green Tea',
        'description': 'Refreshing hot green tea.',
        'price': 25.00,
        'oldPrice': 28.00,
        'tags': ['BALANCE'],
        'image': 'assets/images/hotdrink6.png', // Assuming hotdrink6.png exists
      },
    ],
    'Cold Drinks': [
      {
        'id': 'colddrink1',
        'name': 'Iced Tea',
        'description': 'Chilled brewed tea, unsweetened or sweetened.',
        'price': 20.00,
        'oldPrice': 25.00,
        'tags': ['BALANCE'],
        'image': 'assets/images/colddrink1.png', // Assuming colddrink1.png exists
      },
      {
        'id': 'colddrink2',
        'name': 'Cola',
        'description': 'Classic carbonated cola drink.',
        'price': 22.00,
        'oldPrice': 28.00,
        'tags': ['SWEET'],
        'image': 'assets/images/colddrink2.png', // Assuming colddrink2.png exists
      },
      {
        'id': 'colddrink3',
        'name': 'Orange Juice',
        'description': 'Freshly squeezed orange juice.',
        'price': 30.00,
        'oldPrice': 35.00,
        'tags': ['BALANCE'],
        'image': 'assets/images/colddrink3.png', // Assuming colddrink3.png exists
      },
      {
        'id': 'colddrink4',
        'name': 'Strawberry Smoothie',
        'description': 'Blended strawberries with yogurt or milk.',
        'price': 45.00,
        'oldPrice': 50.00,
        'tags': ['SWEET'],
        'image': 'assets/images/colddrink4.png', // Assuming colddrink4.png exists
      },
      {
        'id': 'colddrink5',
        'name': 'Bottled Water',
        'description': 'Plain bottled water.',
        'price': 15.00,
        'oldPrice': 18.00,
        'tags': ['BLAND'],
        'image': 'assets/images/colddrink5.png', // Assuming colddrink5.png exists
      },
    ],
  };

  // Map certain tags to specific colors (optional)
  final Map<String, Color> tagColors = {
    'NON-VEG': Colors.orange,
    'SPICY': Colors.red,
    'BLAND': Colors.blueGrey,
    'VEG': Colors.green,
    'BALANCE': Colors.teal,
    'COLD': Colors.lightBlue,
    'HOT': Colors.red,
    'SWEET': Colors.pink,
  };

  // The set of currently selected tags
  Set<String> selectedTags = {};

  // All possible tags for this category
  late Set<String> allTags;

    @override
  void initState() {
    super.initState();
    // Gather all items for this category
    final items = allFoodItems[widget.categoryName] ?? [];
    // Extract all tags from these items
    allTags = {};
    for (var item in items) {
      final tags = item['tags'] as List<dynamic>;
      allTags.addAll(tags.cast<String>());
    }
  }

  // Return color for each tag; default to deepOrange if not found
  Color _getTagColor(String tag) {
    return tagColors[tag] ?? Colors.deepOrange;
  }

  // Filter items based on selectedTags (logical "OR" filter)
  // If selectedTags is empty, show all items
  // Otherwise, show items that have at least one of the selected tags
  List<Map<String, dynamic>> _filteredItems() {
    final items = allFoodItems[widget.categoryName] ?? [];
    if (selectedTags.isEmpty) return items;

    return items.where((item) {
      final itemTags = item['tags'] as List<dynamic>;
      // "OR" approach: check if there's any overlap
      return itemTags.any((tag) => selectedTags.contains(tag));
    }).toList();
  }

@override
Widget build(BuildContext context) {
   final filteredItems = _filteredItems();
  return Scaffold(
    appBar: AppBar(
      title: Text((widget.categoryName),
      style: TextStyle(color: Colors.deepOrange)),
      actions: const [AppBarActions()],
    ),
    body: filteredItems.isEmpty
        ? Center(
            child: Text('No items available for ${widget.categoryName} yet'),
          )
        : Column(
            children: [
              // Filter Chips row
              _buildFilterChips(),
              // Grid of filtered items
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: GridView.builder(
                    itemCount: filteredItems.length,
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,      // 2 items per row
                      crossAxisSpacing: 6,   // Horizontal space
                      mainAxisSpacing: 16,    // Vertical space
                      childAspectRatio: 0.5, // Adjust as needed
                    ),
                    itemBuilder: (context, index) {
                      final item = filteredItems[index];
                      return _buildFoodCard(item);
                    },
                  ),
                ),
              ),
            ],
          ),
  );
}

Widget _buildFilterChips() {
  return SingleChildScrollView(
    scrollDirection: Axis.horizontal,
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
    child: Row(
      children: allTags.map((tag) {
        return Container(
          margin: const EdgeInsets.only(right: 8),
          child: FilterChip(
            label: Text(tag),
            selected: selectedTags.contains(tag),
            onSelected: (bool selected) {
              setState(() {
                if (selected) {
                  selectedTags.add(tag);
                } else {
                  selectedTags.remove(tag);
                }
              });
            },
            backgroundColor: _getTagColor(tag).withOpacity(0.15),
            selectedColor: _getTagColor(tag).withOpacity(0.35),
            checkmarkColor: Colors.white,
            labelStyle: const TextStyle(color: Colors.black),
          ),
        );
      }).toList(),
    ),
  );
}

Widget _buildFoodCard(Map<String, dynamic> item) {
  return Card(
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(16),
    ),
    elevation: 4,
    child: Padding(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image with favorite button overlay
          Stack(
            children: [
              // Food image
              Center(
                child: Container(
                  height: 180,
                  width: 180,
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage(item['image']),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
              // Favorite button
              Positioned(
                top: 0,
                right: 0,
                child: StreamBuilder<bool>(
                  stream: _foodService.isFavorite(item['id']),
                  builder: (context, snapshot) {
                    final isFavorite = snapshot.data ?? false;
                    return IconButton(
                      icon: Icon(
                        isFavorite ? Icons.favorite : Icons.favorite_border,
                        color: isFavorite ? Colors.red : Colors.white,
                      ),
                      onPressed: () async {
                        try {
                          await _foodService.toggleFavorite(item['id']);
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  isFavorite
                                      ? '${item['name']} removed from favorites'
                                      : '${item['name']} added to favorites',
                                ),
                                backgroundColor: Colors.deepOrange,
                              ),
                            );
                          }
                        } catch (e) {
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Error updating favorite: $e'),
                                backgroundColor: Colors.red,
                              ),
                            );
                          }
                        }
                      },
                    );
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          // 2. Row of tags
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: (item['tags'] as List<dynamic>).map((tag) {
                return Container(
                  margin: const EdgeInsets.only(right: 4),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: _getTagColor(tag),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    tag,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 8),
          // 3. Title and description
          Text(
            item['name'],
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.deepOrange,
            ),
          ),
          const SizedBox(height: 4),
          Expanded(
            child: Text(
              item['description'],
              style: const TextStyle(
                fontSize: 13,
                color: Colors.white,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          // 4. Row for price, old price, and add button
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Prices
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '\£${item['price'].toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: Colors.deepOrange,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '\£${item['oldPrice'].toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontSize: 13,
                      color: Colors.grey,
                      decoration: TextDecoration.lineThrough,
                    ),
                  ),
                ],
              ),
              // Add button
              InkWell(
                onTap: () async {
                  try {
                    await _cartService.addItem(item);
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('${item['name']} added to cart'),
                          showCloseIcon: true,
                          duration: const Duration(milliseconds: 1300),
                          behavior: SnackBarBehavior.floating,
                          backgroundColor: Colors.deepOrange,
                          closeIconColor: Colors.black,
                        ),
                      );
                    }
                  } catch (e) {
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Error adding item to cart: $e'),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  }
                },
                child: Container(
                  padding: const EdgeInsets.all(3),
                  decoration: BoxDecoration(
                    color: Colors.deepOrange,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.add,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    ),
  );
}
  }
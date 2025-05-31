import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';
import '../models/food_item.dart';

class FoodService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final String _collection = 'food_items';
  final _uuid = Uuid();

  // Get local directory for food images
  Future<Directory> get _localDirectory async {
    final directory = await getApplicationDocumentsDirectory();
    final imageDir = Directory('${directory.path}/food_images');
    if (!await imageDir.exists()) {
      await imageDir.create(recursive: true);
    }
    return imageDir;
  }

  // Get local file path for food image
  Future<String> _getLocalImagePath(String foodId) async {
    final dir = await _localDirectory;
    return '${dir.path}/$foodId.jpg';
  }

  // Add new food item
  Future<FoodItem> addFoodItem({
    required String name,
    required String description,
    required double price,
    required String category,
    required List<String> ingredients,
    required String imagePath,
  }) async {
    try {
      final now = DateTime.now();
      final foodId = _uuid.v4();

      final foodItem = FoodItem(
        id: foodId,
        name: name,
        description: description,
        price: price,
        category: category,
        imagePath: imagePath,
        ingredients: ingredients,
        createdAt: now,
        updatedAt: now,
      );

      // Save to Firestore
      await _firestore
          .collection(_collection)
          .doc(foodId)
          .set(foodItem.toMap());

      return foodItem;
    } catch (e) {
      print('Error adding food item: $e');
      throw Exception('Failed to add food item: $e');
    }
  }

  // Update food item
  Future<FoodItem> updateFoodItem({
    required String id,
    String? name,
    String? description,
    double? price,
    String? category,
    List<String>? ingredients,
    String? imagePath,
    bool? isAvailable,
  }) async {
    try {
      final doc = await _firestore.collection(_collection).doc(id).get();
      if (!doc.exists) {
        throw Exception('Food item not found');
      }

      final currentItem = FoodItem.fromMap(doc.data()!);
      final updatedItem = currentItem.copyWith(
        name: name,
        description: description,
        price: price,
        category: category,
        imagePath: imagePath,
        ingredients: ingredients,
        isAvailable: isAvailable,
        updatedAt: DateTime.now(),
      );

      // Update in Firestore
      await _firestore
          .collection(_collection)
          .doc(id)
          .update(updatedItem.toMap());

      return updatedItem;
    } catch (e) {
      print('Error updating food item: $e');
      throw Exception('Failed to update food item: $e');
    }
  }

  // Delete food item
  Future<void> deleteFoodItem(String id) async {
    try {
      // Delete image if exists
      final imagePath = await _getLocalImagePath(id);
      final imageFile = File(imagePath);
      if (await imageFile.exists()) {
        await imageFile.delete();
      }

      // Delete from Firestore
      await _firestore.collection(_collection).doc(id).delete();
    } catch (e) {
      print('Error deleting food item: $e');
      throw Exception('Failed to delete food item: $e');
    }
  }

  // Get all food items
  Stream<List<FoodItem>> getFoodItems() {
    return _firestore
        .collection(_collection)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => FoodItem.fromMap(doc.data()))
          .toList();
    });
  }

  // Get food items by category
  Stream<List<FoodItem>> getFoodItemsByCategory(String category) {
    return _firestore
        .collection(_collection)
        .where('category', isEqualTo: category)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => FoodItem.fromMap(doc.data()))
          .toList();
    });
  }

  // Get food item by ID
  Future<FoodItem?> getFoodItemById(String id) async {
    try {
      final doc = await _firestore.collection(_collection).doc(id).get();
      if (!doc.exists) return null;
      return FoodItem.fromMap(doc.data()!);
    } catch (e) {
      print('Error getting food item: $e');
      throw Exception('Failed to get food item: $e');
    }
  }

  // Update food item rating
  Future<void> updateFoodItemRating(String id, double rating) async {
    try {
      final doc = await _firestore.collection(_collection).doc(id).get();
      if (!doc.exists) {
        throw Exception('Food item not found');
      }

      final currentItem = FoodItem.fromMap(doc.data()!);
      final newRatingCount = currentItem.ratingCount + 1;
      final newRating = ((currentItem.rating * currentItem.ratingCount) + rating) / newRatingCount;

      await _firestore.collection(_collection).doc(id).update({
        'rating': newRating,
        'ratingCount': newRatingCount,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Error updating food item rating: $e');
      throw Exception('Failed to update food item rating: $e');
    }
  }

  // Toggle favorite status for a food item
  Future<void> toggleFavorite(String foodItemId) async {
    try {
      final userId = _auth.currentUser?.uid;
      if (userId == null) throw Exception('User not authenticated');

      // Get user's current favorites
      final userDoc = await _firestore.collection('users').doc(userId).get();
      if (!userDoc.exists) throw Exception('User not found');

      final userData = userDoc.data()!;
      final favorites = List<String>.from(userData['favorites'] ?? []);

      if (favorites.contains(foodItemId)) {
        // Remove from favorites
        favorites.remove(foodItemId);
      } else {
        // Add to favorites
        favorites.add(foodItemId);
      }

      // Update user's favorites
      await _firestore.collection('users').doc(userId).update({
        'favorites': favorites,
      });
    } catch (e) {
      print('Error toggling favorite: $e');
      throw Exception('Failed to toggle favorite: $e');
    }
  }

  // Check if a food item is favorited by the current user
  Stream<bool> isFavorite(String foodItemId) {
    final userId = _auth.currentUser?.uid;
    if (userId == null) return Stream.value(false);

    return _firestore
        .collection('users')
        .doc(userId)
        .snapshots()
        .map((doc) {
      if (!doc.exists) return false;
      final favorites = List<String>.from(doc.data()?['favorites'] ?? []);
      return favorites.contains(foodItemId);
    });
  }

  // Get user's favorite food items
  Stream<List<Map<String, dynamic>>> getFavoriteFoodItems() {
    final userId = _auth.currentUser?.uid;
    if (userId == null) return Stream.value([]);

    return _firestore
        .collection('users')
        .doc(userId)
        .snapshots()
        .map((userDoc) {
      if (!userDoc.exists) return [];
      
      final favorites = List<String>.from(userDoc.data()?['favorites'] ?? []);
      if (favorites.isEmpty) return [];

      // Get all food items from static data
      final allFoodItems = {
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
        ],
      };

      // Flatten all food items into a single list
      final allItems = allFoodItems.values.expand((items) => items).toList();

      // Filter to only include favorite items
      return allItems.where((item) => favorites.contains(item['id'])).toList();
    });
  }
} 
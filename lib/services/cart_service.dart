import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/cart.dart';

class CartService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final String _collection = 'carts';

  // Get the current user's cart document reference
  DocumentReference get _cartRef {
    final userId = _auth.currentUser?.uid;
    if (userId == null) throw Exception('User not authenticated');
    return _firestore.collection(_collection).doc(userId);
  }

  // Stream of cart items for the current user
  Stream<List<CartItem>> getCartItems() {
    return _cartRef.snapshots().map((doc) {
      if (!doc.exists) return [];
      
      final data = doc.data() as Map<String, dynamic>;
      final items = (data['items'] as List<dynamic>?) ?? [];
      
      return items.map((item) => CartItem(
        item: Map<String, dynamic>.from(item['item']),
        quantity: item['quantity'] as int,
      )).toList();
    });
  }

  // Add item to cart
  Future<void> addItem(Map<String, dynamic> item) async {
    try {
      final doc = await _cartRef.get();
      final data = doc.data() as Map<String, dynamic>? ?? {'items': []};
      final items = List<Map<String, dynamic>>.from(data['items'] ?? []);

      // Check if item already exists
      final existingIndex = items.indexWhere(
        (cartItem) => cartItem['item']['name'] == item['name']
      );

      if (existingIndex >= 0) {
        // Update quantity if item exists
        items[existingIndex]['quantity'] = 
          (items[existingIndex]['quantity'] as int) + 1;
      } else {
        // Add new item
        items.add({
          'item': item,
          'quantity': 1,
        });
      }

      // Update Firestore
      await _cartRef.set({'items': items}, SetOptions(merge: true));
      
      // Update local cart
      Cart.clear();
      for (var cartItem in items) {
        Cart.addItem(cartItem['item']);
      }
    } catch (e) {
      print('Error adding item to cart: $e');
      throw Exception('Failed to add item to cart: $e');
    }
  }

  // Remove item from cart
  Future<void> removeItem(Map<String, dynamic> item) async {
    try {
      final doc = await _cartRef.get();
      final data = doc.data() as Map<String, dynamic>? ?? {'items': []};
      final items = List<Map<String, dynamic>>.from(data['items'] ?? []);

      // Remove item
      items.removeWhere(
        (cartItem) => cartItem['item']['name'] == item['name']
      );

      // Update Firestore
      await _cartRef.set({'items': items}, SetOptions(merge: true));
      
      // Update local cart
      Cart.clear();
      for (var cartItem in items) {
        Cart.addItem(cartItem['item']);
      }
    } catch (e) {
      print('Error removing item from cart: $e');
      throw Exception('Failed to remove item from cart: $e');
    }
  }

  // Clear cart
  Future<void> clearCart() async {
    try {
      await _cartRef.delete();
      Cart.clear();
    } catch (e) {
      print('Error clearing cart: $e');
      throw Exception('Failed to clear cart: $e');
    }
  }

  // Update item quantity
  Future<void> updateQuantity(Map<String, dynamic> item, int quantity) async {
    try {
      // Update local state immediately
      final localItem = Cart.items.firstWhere(
        (i) => i.item['name'] == item['name'],
        orElse: () => CartItem(item: item, quantity: 0),
      );
      
      if (quantity <= 0) {
        Cart.items.remove(localItem);
      } else {
        localItem.quantity = quantity;
      }
      // Notify listeners immediately
      Cart.totalItemsNotifier.value = Cart.getTotalItems();

      // Then sync with Firestore in the background
      final doc = await _cartRef.get();
      final data = doc.data() as Map<String, dynamic>? ?? {'items': []};
      final items = List<Map<String, dynamic>>.from(data['items'] ?? []);

      final index = items.indexWhere(
        (cartItem) => cartItem['item']['name'] == item['name']
      );

      if (index >= 0) {
        if (quantity <= 0) {
          items.removeAt(index);
        } else {
          items[index]['quantity'] = quantity;
        }

        // Update Firestore
        await _cartRef.set({'items': items}, SetOptions(merge: true));
      }
    } catch (e) {
      // If Firestore update fails, revert local changes
      Cart.clear();
      final doc = await _cartRef.get();
      final data = doc.data() as Map<String, dynamic>? ?? {'items': []};
      final items = List<Map<String, dynamic>>.from(data['items'] ?? []);
      
      for (var cartItem in items) {
        Cart.addItem(cartItem['item']);
        final localItem = Cart.items.firstWhere(
          (i) => i.item['name'] == cartItem['item']['name'],
          orElse: () => CartItem(item: cartItem['item'], quantity: 0),
        );
        localItem.quantity = cartItem['quantity'] as int;
      }
      Cart.totalItemsNotifier.value = Cart.getTotalItems();
      
      print('Error updating item quantity: $e');
      throw Exception('Failed to update item quantity: $e');
    }
  }
} 
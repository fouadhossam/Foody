import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:uuid/uuid.dart';
import '../models/order.dart' as app_order;
import '../models/cart.dart';
import 'cart_service.dart';

class OrderService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final CartService _cartService = CartService();
  final String _collection = 'orders';
  final _uuid = Uuid();

  // Get current user's orders
  Stream<List<app_order.Order>> getUserOrders() {
    final userId = _auth.currentUser?.uid;
    if (userId == null) throw Exception('User not authenticated');

    return _firestore
        .collection(_collection)
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => app_order.Order.fromMap(doc.data()))
          .toList();
    });
  }

  // Create new order from cart
  Future<app_order.Order> createOrder({
    required String deliveryAddress,
    String? specialInstructions,
    required String paymentMethod,
  }) async {
    try {
      final userId = _auth.currentUser?.uid;
      if (userId == null) throw Exception('User not authenticated');

      // Get current cart items
      final cartDoc = await _firestore.collection('carts').doc(userId).get();
      if (!cartDoc.exists) throw Exception('Cart is empty');

      final cartData = cartDoc.data() as Map<String, dynamic>;
      final items = (cartData['items'] as List<dynamic>).map((item) => CartItem(
        item: Map<String, dynamic>.from(item['item']),
        quantity: item['quantity'] as int,
      )).toList();

      if (items.isEmpty) throw Exception('Cart is empty');

      // Calculate total
      final totalAmount = items.fold<double>(
        0,
        (sum, item) => sum + ((item.item['price'] as num).toDouble() * item.quantity),
      );

      // Create order
      final orderId = _uuid.v4();
      final now = DateTime.now();
      
      final order = app_order.Order(
        id: orderId,
        userId: userId,
        items: items,
        totalAmount: totalAmount,
        status: app_order.OrderStatus.pending,
        createdAt: now,
        deliveryAddress: deliveryAddress,
        specialInstructions: specialInstructions,
        paymentMethod: paymentMethod,
      );

      // Save to Firestore
      await _firestore
          .collection(_collection)
          .doc(orderId)
          .set(order.toMap());

      // Update user's orders array
      await _firestore.collection('users').doc(userId).update({
        'orders': FieldValue.arrayUnion([orderId])
      });

      // Clear cart after successful order
      await _cartService.clearCart();

      return order;
    } catch (e) {
      print('Error creating order: $e');
      throw Exception('Failed to create order: $e');
    }
  }

  // Update order status (admin only)
  Future<void> updateOrderStatus(String orderId, app_order.OrderStatus status) async {
    try {
      await _firestore.collection(_collection).doc(orderId).update({
        'status': status.toString().split('.').last,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Error updating order status: $e');
      throw Exception('Failed to update order status: $e');
    }
  }

  // Get order by ID
  Future<app_order.Order?> getOrderById(String orderId) async {
    try {
      final doc = await _firestore.collection(_collection).doc(orderId).get();
      if (!doc.exists) return null;
      return app_order.Order.fromMap(doc.data()!);
    } catch (e) {
      print('Error getting order: $e');
      throw Exception('Failed to get order: $e');
    }
  }

  // Cancel order
  Future<void> cancelOrder(String orderId) async {
    try {
      final order = await getOrderById(orderId);
      if (order == null) throw Exception('Order not found');
      
      // Only allow cancellation of pending orders
      if (order.status != app_order.OrderStatus.pending) {
        throw Exception('Cannot cancel order in ${order.status} status');
      }

      await updateOrderStatus(orderId, app_order.OrderStatus.cancelled);
    } catch (e) {
      print('Error cancelling order: $e');
      throw Exception('Failed to cancel order: $e');
    }
  }

  Stream<List<app_order.Order>> getAllOrders() {
    return _firestore
        .collection('orders')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => app_order.Order.fromMap(doc.data()))
            .toList());
  }
} 
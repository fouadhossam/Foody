import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_preferences.dart';
import 'firebase_service.dart';

class UserPreferencesService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseService _firebaseService = FirebaseService();
  final String _collection = 'user_preferences';

  // Get user preferences stream
  Stream<UserPreferences> getUserPreferences() {
    final userId = _firebaseService.getCurrentUserId();
    if (userId == null) {
      throw Exception('No user logged in');
    }

    return _firestore
        .collection(_collection)
        .doc(userId)
        .snapshots()
        .map((doc) {
      if (!doc.exists) {
        return UserPreferences.empty();
      }
      return UserPreferences.fromMap(doc.data() as Map<String, dynamic>);
    });
  }

  // Get user preferences once
  Future<UserPreferences> getUserPreferencesOnce() async {
    final userId = _firebaseService.getCurrentUserId();
    if (userId == null) {
      throw Exception('No user logged in');
    }

    final doc = await _firestore
        .collection(_collection)
        .doc(userId)
        .get();

    if (!doc.exists) {
      return UserPreferences.empty();
    }
    return UserPreferences.fromMap(doc.data() as Map<String, dynamic>);
  }

  // Create or update user preferences
  Future<void> updatePreferences({
    String? defaultDeliveryAddress,
    String? defaultPaymentMethod,
  }) async {
    final userId = _firebaseService.getCurrentUserId();
    if (userId == null) {
      throw Exception('No user logged in');
    }

    final docRef = _firestore.collection(_collection).doc(userId);
    final doc = await docRef.get();

    if (!doc.exists) {
      // Create new preferences
      await docRef.set({
        'defaultDeliveryAddress': defaultDeliveryAddress,
        'defaultPaymentMethod': defaultPaymentMethod,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } else {
      // Update existing preferences
      final updates = <String, dynamic>{
        'updatedAt': FieldValue.serverTimestamp(),
      };

      if (defaultDeliveryAddress != null) {
        updates['defaultDeliveryAddress'] = defaultDeliveryAddress;
      }
      if (defaultPaymentMethod != null) {
        updates['defaultPaymentMethod'] = defaultPaymentMethod;
      }

      await docRef.update(updates);
    }
  }

  // Update default delivery address
  Future<void> updateDefaultDeliveryAddress(String address) async {
    final userId = _firebaseService.getCurrentUserId();
    if (userId == null) {
      throw Exception('No user logged in');
    }

    final docRef = _firestore.collection(_collection).doc(userId);
    final doc = await docRef.get();

    if (!doc.exists) {
      // Create new preferences with just the address
      await docRef.set({
        'defaultDeliveryAddress': address,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } else {
      // Update existing preferences
      await docRef.update({
        'defaultDeliveryAddress': address,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    }
  }

  // Update default payment method
  Future<void> updateDefaultPaymentMethod(String paymentMethod) async {
    final userId = _firebaseService.getCurrentUserId();
    if (userId == null) {
      throw Exception('No user logged in');
    }

    final docRef = _firestore.collection(_collection).doc(userId);
    final doc = await docRef.get();

    if (!doc.exists) {
      // Create new preferences with just the payment method
      await docRef.set({
        'defaultPaymentMethod': paymentMethod,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } else {
      // Update existing preferences
      await docRef.update({
        'defaultPaymentMethod': paymentMethod,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    }
  }

  // Delete user preferences
  Future<void> deletePreferences() async {
    final userId = _firebaseService.getCurrentUserId();
    if (userId == null) {
      throw Exception('No user logged in');
    }

    await _firestore
        .collection(_collection)
        .doc(userId)
        .delete();
  }
} 
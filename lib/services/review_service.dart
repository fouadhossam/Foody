import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:uuid/uuid.dart';
import '../models/review.dart';

class ReviewService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final String _collection = 'reviews';
  final _uuid = Uuid();

  // Get reviews for a food item
  Stream<List<Review>> getFoodItemReviews(String foodItemId) {
    return _firestore
        .collection(_collection)
        .where('foodItemId', isEqualTo: foodItemId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => Review.fromMap(doc.data()))
          .toList();
    });
  }

  // Get user's reviews
  Stream<List<Review>> getUserReviews() {
    final userId = _auth.currentUser?.uid;
    if (userId == null) throw Exception('User not authenticated');

    return _firestore
        .collection(_collection)
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => Review.fromMap(doc.data()))
          .toList();
    });
  }

  // Create a new review
  Future<Review> createReview({
    required String foodItemId,
    required int rating,
    required String comment,
  }) async {
    try {
      final userId = _auth.currentUser?.uid;
      if (userId == null) throw Exception('User not authenticated');

      // Get user's username
      final userDoc = await _firestore.collection('users').doc(userId).get();
      if (!userDoc.exists) throw Exception('User profile not found');
      
      final username = userDoc.data()?['username'] as String?;
      if (username == null) throw Exception('Username not found');

      final reviewId = _uuid.v4();
      final now = DateTime.now();

      final review = Review(
        id: reviewId,
        userId: userId,
        foodItemId: foodItemId,
        username: username,
        rating: rating,
        comment: comment,
        createdAt: now,
      );

      // Save review to Firestore
      await _firestore
          .collection(_collection)
          .doc(reviewId)
          .set(review.toMap());

      // Update food item's average rating
      await _updateFoodItemRating(foodItemId);

      return review;
    } catch (e) {
      print('Error creating review: $e');
      throw Exception('Failed to create review: $e');
    }
  }

  // Update an existing review
  Future<void> updateReview({
    required String reviewId,
    required int rating,
    required String comment,
  }) async {
    try {
      final userId = _auth.currentUser?.uid;
      if (userId == null) throw Exception('User not authenticated');

      // Get the review
      final reviewDoc = await _firestore.collection(_collection).doc(reviewId).get();
      if (!reviewDoc.exists) throw Exception('Review not found');

      final review = Review.fromMap(reviewDoc.data()!);
      
      // Check if user owns the review or is admin
      if (review.userId != userId) {
        final userDoc = await _firestore.collection('users').doc(userId).get();
        if (!userDoc.exists || !(userDoc.data()?['isAdmin'] ?? false)) {
          throw Exception('Not authorized to update this review');
        }
      }

      // Update review
      await _firestore.collection(_collection).doc(reviewId).update({
        'rating': rating,
        'comment': comment,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      // Update food item's average rating
      await _updateFoodItemRating(review.foodItemId);
    } catch (e) {
      print('Error updating review: $e');
      throw Exception('Failed to update review: $e');
    }
  }

  // Delete a review
  Future<void> deleteReview(String reviewId) async {
    try {
      final userId = _auth.currentUser?.uid;
      if (userId == null) throw Exception('User not authenticated');

      // Get the review
      final reviewDoc = await _firestore.collection(_collection).doc(reviewId).get();
      if (!reviewDoc.exists) throw Exception('Review not found');

      final review = Review.fromMap(reviewDoc.data()!);
      
      // Check if user owns the review or is admin
      if (review.userId != userId) {
        final userDoc = await _firestore.collection('users').doc(userId).get();
        if (!userDoc.exists || !(userDoc.data()?['isAdmin'] ?? false)) {
          throw Exception('Not authorized to delete this review');
        }
      }

      // Delete review
      await _firestore.collection(_collection).doc(reviewId).delete();

      // Update food item's average rating
      await _updateFoodItemRating(review.foodItemId);
    } catch (e) {
      print('Error deleting review: $e');
      throw Exception('Failed to delete review: $e');
    }
  }

  // Helper method to update food item's average rating
  Future<void> _updateFoodItemRating(String foodItemId) async {
    try {
      // Get all reviews for the food item
      final reviewsSnapshot = await _firestore
          .collection(_collection)
          .where('foodItemId', isEqualTo: foodItemId)
          .get();

      if (reviewsSnapshot.docs.isEmpty) return;

      // Calculate average rating
      double totalRating = 0;
      for (var doc in reviewsSnapshot.docs) {
        totalRating += doc.data()['rating'] as int;
      }
      final averageRating = totalRating / reviewsSnapshot.docs.length;

      // Update food item
      await _firestore.collection('food_items').doc(foodItemId).update({
        'rating': averageRating,
        'ratingCount': reviewsSnapshot.docs.length,
      });
    } catch (e) {
      print('Error updating food item rating: $e');
      // Don't throw the error as this is a background operation
    }
  }

  Stream<List<Review>> getAllReviews() {
    return _firestore
        .collection('reviews')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Review.fromMap(doc.data()))
            .toList());
  }
} 
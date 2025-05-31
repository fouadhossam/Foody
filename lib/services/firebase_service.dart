import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import '../models/user.dart' as app_user;
import '../models/food_item.dart';

class FirebaseService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Get current user
  User? get currentUser => _auth.currentUser;

  // Get current app user with admin status
  Stream<app_user.User?> get currentAppUser {
    if (currentUser == null) return Stream.value(null);
    
    return _firestore
        .collection('users')
        .doc(currentUser!.uid)
        .snapshots()
        .map((doc) {
      if (!doc.exists) return null;
      return app_user.User.fromMap(doc.data()!);
    });
  }

  // Check if current user is admin
  Future<bool> isCurrentUserAdmin() async {
    final user = await currentAppUser.first;
    return user?.isAdmin ?? false;
  }

  // Get local app directory for storing images
  Future<Directory> get _localDirectory async {
    final directory = await getApplicationDocumentsDirectory();
    final imageDir = Directory('${directory.path}/profile_images');
    if (!await imageDir.exists()) {
      await imageDir.create(recursive: true);
    }
    return imageDir;
  }

  // Get local file path for user's profile picture
  Future<String> _getLocalImagePath() async {
    if (currentUser == null) throw Exception('No user logged in');
    final dir = await _localDirectory;
    return '${dir.path}/${currentUser!.uid}.jpg';
  }

  // Upload profile picture
  Future<String> uploadProfilePicture(File imageFile) async {
    if (currentUser == null) throw Exception('No user logged in');

    try {
      print('Saving profile picture locally for UID: ${currentUser!.uid}');
      
      // Get the local file path
      final localPath = await _getLocalImagePath();
      
      // Copy the image file to local storage
      await imageFile.copy(localPath);
      
      // Update the user's profile with the local file path
      await updateUserProfile({'profilePictureUrl': localPath});
      
      print('Successfully saved profile picture locally');
      return localPath;
    } catch (e) {
      print('Error saving profile picture: $e');
      throw Exception('Failed to save profile picture: $e');
    }
  }

  // Get profile picture
  Future<File?> getProfilePicture() async {
    try {
      final localPath = await _getLocalImagePath();
      final file = File(localPath);
      if (await file.exists()) {
        return file;
      }
      return null;
    } catch (e) {
      print('Error getting profile picture: $e');
      return null;
    }
  }

  // Delete profile picture
  Future<void> deleteProfilePicture() async {
    try {
      final localPath = await _getLocalImagePath();
      final file = File(localPath);
      if (await file.exists()) {
        await file.delete();
        await updateUserProfile({'profilePictureUrl': null});
      }
    } catch (e) {
      print('Error deleting profile picture: $e');
      throw Exception('Failed to delete profile picture: $e');
    }
  }

  // Sign up with email and password
  Future<UserCredential> signUpWithEmailAndPassword(
      String email, String password, String username) async {
    UserCredential? authResult;
    try {
      print('Starting registration process for email: ${email.trim()}');
      
      // First, create the user in Firebase Auth
      authResult = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      
      print('User created in Firebase Auth with UID: ${authResult.user?.uid}');

      if (authResult.user == null) {
        throw Exception('Failed to create user in Firebase Auth');
      }

      // Create user data map with explicit types
      final userData = app_user.User(
        id: authResult.user!.uid,
        email: email.trim(),
        username: username.trim(),
        isAdmin: false, // Default to non-admin
        favorites: [],
        orders: [],
        createdAt: DateTime.now(),
      ).toMap();

      print('Creating user document in Firestore with data: $userData');

      // Create the user document in Firestore
      await _firestore
          .collection('users')
          .doc(authResult.user!.uid)
          .set(userData);

      print('User document created successfully in Firestore');
      return authResult;

    } on FirebaseAuthException catch (e) {
      print('FirebaseAuthException during registration: ${e.code} - ${e.message}');
      String message;
      switch (e.code) {
        case 'email-already-in-use':
          message = 'An account already exists with this email.';
          break;
        case 'invalid-email':
          message = 'The email address is not valid.';
          break;
        case 'operation-not-allowed':
          message = 'Email/password accounts are not enabled.';
          break;
        case 'weak-password':
          message = 'The password is too weak.';
          break;
        default:
          message = 'An error occurred during sign up: ${e.message}';
      }
      throw Exception(message);
    } catch (e, stack) {
      print('Unexpected error during registration: $e');
      print('Stack trace: $stack');
      if (authResult?.user != null) {
        try {
          await authResult!.user!.delete();
          print('Cleaned up user after failed registration');
        } catch (deleteError) {
          print('Error cleaning up user: $deleteError');
        }
      }
      throw Exception('Failed to sign up: $e');
    }
  }

  // Sign in with email and password
  Future<app_user.User?> signInWithEmailAndPassword(
      String email, String password) async {
    try {
      print('Attempting to sign in with email: ${email.trim()}');
      
      final userCredential = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      print('Successfully signed in with Firebase Auth');

      // Get user data from Firestore
      final userDoc = await _firestore
          .collection('users')
          .doc(userCredential.user!.uid)
          .get();

      if (!userDoc.exists) {
        print('User document not found in Firestore');
        await _auth.signOut();
        throw Exception('User profile not found');
      }

      print('User document found in Firestore');
      return app_user.User.fromMap(userDoc.data()!);
    } on FirebaseAuthException catch (e) {
      print('FirebaseAuthException during sign in: ${e.code} - ${e.message}');
      String message;
      switch (e.code) {
        case 'user-not-found':
          message = 'No user found with this email.';
          break;
        case 'wrong-password':
          message = 'Wrong password provided.';
          break;
        case 'invalid-email':
          message = 'The email address is not valid.';
          break;
        case 'user-disabled':
          message = 'This user account has been disabled.';
          break;
        default:
          message = 'An error occurred during sign in: ${e.message}';
      }
      throw Exception(message);
    } catch (e) {
      print('Unexpected error during sign in: $e');
      throw Exception('Failed to sign in: $e');
    }
  }

  // Get user profile
  Future<app_user.User?> getUserProfile() async {
    if (currentUser == null) return null;
    
    try {
      print('Fetching user profile for UID: ${currentUser!.uid}');
      
      final doc = await _firestore
          .collection('users')
          .doc(currentUser!.uid)
          .get();
      
      if (!doc.exists) {
        print('User profile not found in Firestore');
        throw Exception('User profile not found');
      }
      
      final data = doc.data();
      if (data == null) {
        print('User profile data is null');
        throw Exception('User profile data is null');
      }
      
      print('Successfully retrieved user profile');
      return app_user.User.fromMap(data);
    } catch (e) {
      print('Error getting user profile: $e');
      throw Exception('Failed to get user profile: $e');
    }
  }

  // Update user profile
  Future<void> updateUserProfile(Map<String, dynamic> data) async {
    if (currentUser == null) return;
    
    try {
      print('Updating user profile for UID: ${currentUser!.uid}');
      await _firestore
          .collection('users')
          .doc(currentUser!.uid)
          .update(data);
      print('Successfully updated user profile');
    } catch (e) {
      print('Error updating user profile: $e');
      throw Exception('Failed to update profile: $e');
    }
  }

  // Update username
  Future<void> updateUsername(String newUsername) async {
    try {
      final user = _auth.currentUser;
      if (user == null) throw Exception('No user logged in');

      // Update username in Firestore
      await _firestore.collection('users').doc(user.uid).update({
        'username': newUsername,
      });
    } catch (e) {
      throw Exception('Failed to update username: $e');
    }
  }

  // Sign out
  Future<void> signOut() async {
    try {
      print('Signing out user');
      await _auth.signOut();
      print('Successfully signed out');
    } catch (e) {
      print('Error signing out: $e');
      throw Exception('Failed to sign out: $e');
    }
  }

  // Get all food items
  Stream<List<FoodItem>> getFoodItems() {
    return _firestore
        .collection('food_items')
        .orderBy('name')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => FoodItem.fromMap(doc.data()))
            .toList());
  }

  // Add a new food item
  Future<void> addFoodItem(FoodItem foodItem) async {
    try {
      await _firestore
          .collection('food_items')
          .doc(foodItem.id)
          .set(foodItem.toMap());
    } catch (e) {
      print('Error adding food item: $e');
      throw Exception('Failed to add food item: $e');
    }
  }

  // Update an existing food item
  Future<void> updateFoodItem(FoodItem foodItem) async {
    try {
      await _firestore
          .collection('food_items')
          .doc(foodItem.id)
          .update(foodItem.toMap());
    } catch (e) {
      print('Error updating food item: $e');
      throw Exception('Failed to update food item: $e');
    }
  }

  // Delete a food item
  Future<void> deleteFoodItem(String foodItemId) async {
    try {
      await _firestore
          .collection('food_items')
          .doc(foodItemId)
          .delete();
    } catch (e) {
      print('Error deleting food item: $e');
      throw Exception('Failed to delete food item: $e');
    }
  }

  // Get current user ID
  String? getCurrentUserId() {
    return _auth.currentUser?.uid;
  }
} 
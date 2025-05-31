import 'package:cloud_firestore/cloud_firestore.dart';

class User {
  final String id;
  final String email;
  String username;
  final bool isAdmin;
  String? profilePictureUrl;
  final List<String> favorites;
  final List<String> orders;
  final DateTime createdAt;

  User({
    required this.id,
    required this.email,
    required this.username,
    this.isAdmin = false,
    this.profilePictureUrl,
    required this.favorites,
    required this.orders,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'email': email,
      'username': username,
      'isAdmin': isAdmin,
      'profilePictureUrl': profilePictureUrl,
      'favorites': favorites,
      'orders': orders,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['id'] ?? '',
      email: map['email'] ?? '',
      username: map['username'] ?? '',
      isAdmin: map['isAdmin'] ?? false,
      profilePictureUrl: map['profilePictureUrl'],
      favorites: List<String>.from(map['favorites'] ?? []),
      orders: List<String>.from(map['orders'] ?? []),
      createdAt: (map['createdAt'] as Timestamp).toDate(),
    );
  }

  User copyWith({
    String? id,
    String? email,
    String? username,
    bool? isAdmin,
    String? profilePictureUrl,
    List<String>? favorites,
    List<String>? orders,
    DateTime? createdAt,
  }) {
    return User(
      id: id ?? this.id,
      email: email ?? this.email,
      username: username ?? this.username,
      isAdmin: isAdmin ?? this.isAdmin,
      profilePictureUrl: profilePictureUrl ?? this.profilePictureUrl,
      favorites: favorites ?? this.favorites,
      orders: orders ?? this.orders,
      createdAt: createdAt ?? this.createdAt,
    );
  }
} 
import 'package:cloud_firestore/cloud_firestore.dart';

class UserPreferences {
  final String? defaultDeliveryAddress;
  final String? defaultPaymentMethod;
  final DateTime createdAt;
  final DateTime updatedAt;

  const UserPreferences({
    this.defaultDeliveryAddress,
    this.defaultPaymentMethod,
    required this.createdAt,
    required this.updatedAt,
  });

  factory UserPreferences.empty() {
    return UserPreferences(
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }

  factory UserPreferences.fromMap(Map<String, dynamic> map) {
    return UserPreferences(
      defaultDeliveryAddress: map['defaultDeliveryAddress'] as String?,
      defaultPaymentMethod: map['defaultPaymentMethod'] as String?,
      createdAt: (map['createdAt'] as Timestamp).toDate(),
      updatedAt: (map['updatedAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'defaultDeliveryAddress': defaultDeliveryAddress,
      'defaultPaymentMethod': defaultPaymentMethod,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  UserPreferences copyWith({
    String? defaultDeliveryAddress,
    String? defaultPaymentMethod,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserPreferences(
      defaultDeliveryAddress: defaultDeliveryAddress ?? this.defaultDeliveryAddress,
      defaultPaymentMethod: defaultPaymentMethod ?? this.defaultPaymentMethod,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
} 
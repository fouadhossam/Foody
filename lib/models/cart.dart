import 'package:flutter/material.dart';

class CartItem {
  Map<String, dynamic> item;
  int quantity;

  CartItem({required this.item, this.quantity = 1});
}

class Cart {
  static final List<CartItem> items = [];
  static final ValueNotifier<int> totalItemsNotifier = ValueNotifier<int>(0);

  static void addItem(Map<String, dynamic> item) {
    try {
      var existing = items.firstWhere(
        (cartItem) => cartItem.item['name'] == item['name'],
      );
      existing.quantity++;
    } catch (e) {
      items.add(CartItem(item: item));
    }
    totalItemsNotifier.value = getTotalItems();
  }

  static void removeItem(Map<String, dynamic> item) {
    items.removeWhere((cartItem) => cartItem.item['name'] == item['name']);
    totalItemsNotifier.value = getTotalItems();
  }

  static double getTotalPrice() {
    double total = 0;
    for (var cartItem in items) {
      total += (cartItem.item['price'] as num).toDouble() * cartItem.quantity;
    }
    return total;
  }

  static int getTotalItems() {
    int count = 0;
    for (var cartItem in items) {
      count += cartItem.quantity;
    }
    return count;
  }

  static void clear() {
    items.clear();
    totalItemsNotifier.value = 0;
  }
}

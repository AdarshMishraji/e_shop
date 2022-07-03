import '../providers/carts.dart';
import 'package:flutter/material.dart';

class OrderItem {
  final String id;
  final num amount;
  final List<CartItem> products;
  final DateTime dateTime;

  const OrderItem({
    required this.amount,
    required this.dateTime,
    required this.id,
    required this.products,
  });
}

class Orders with ChangeNotifier {
  List<OrderItem> _orders = [];

  List<OrderItem> get orders {
    return _orders.toList();
  }

  void addOrders(List<CartItem> cartProducts, num total) {
    _orders.add(OrderItem(
      amount: total,
      dateTime: DateTime.now(),
      id: DateTime.now().toString(),
      products: cartProducts,
    ));
    notifyListeners();
  }

  void clear() {
    _orders = [];
    notifyListeners();
  }
}

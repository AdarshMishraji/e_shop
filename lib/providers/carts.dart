import 'package:flutter/material.dart';

enum CartItemProperties {
  id('id'),
  title('title'),
  quantity('quantity'),
  price('price');

  const CartItemProperties(this.name);
  final String name;
}

class CartItem {
  final String id;
  final String title;
  int quantity = 0;
  final num price;

  CartItem({
    required this.id,
    required this.title,
    required this.price,
    this.quantity = 0,
  });

  @override
  String toString() {
    return '$id, $title, $price, $quantity x';
  }
}

class Carts with ChangeNotifier {
  late Map<String, CartItem> _items = {};

  Map<String, CartItem> get items {
    return {..._items};
  }

  int get numberOfItemsInCart {
    return _items.length;
  }

  num get totalAmount {
    num amount = 0;
    _items.forEach((_, value) => amount += value.price * value.quantity);
    return num.parse(amount.toStringAsFixed(2));
  }

  void addItem(String productId, num price, String title) {
    if (_items.containsKey(productId)) {
      _items.update(
        productId,
        (value) => CartItem(
          id: value.id,
          title: value.title,
          price: value.price,
          quantity: value.quantity + 1,
        ),
      );
    } else {
      _items.putIfAbsent(
        productId,
        () => CartItem(
            id: DateTime.now().toString(),
            title: title,
            price: price,
            quantity: 1),
      );
    }
    notifyListeners();
  }

  void removeItem(String productId) {
    _items.remove(productId);
    notifyListeners();
  }

  void removeSingleItem(String productId) {
    if (_items.containsKey(productId)) {
      if (_items[productId]!.quantity == 1) {
        _items.remove(productId);
        notifyListeners();
        return;
      }
      _items.update(
          productId,
          (value) => CartItem(
              id: value.id,
              title: value.title,
              price: value.price,
              quantity: value.quantity + 1));
    }
    notifyListeners();
  }

  void clear() {
    _items = {};
    notifyListeners();
  }
}

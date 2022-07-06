import 'dart:convert';

import 'package:e_shop/network/endpoints.dart';
import 'package:e_shop/network/index.dart';

import '../providers/carts.dart';
import 'package:flutter/material.dart';

enum OrderItemProperties {
  id('id'),
  amount('amount'),
  products('products'),
  orderAt('orderAt');

  const OrderItemProperties(this.name);
  final String name;
}

class OrderItem {
  final String id;
  final num amount;
  final List<CartItem> products;
  final DateTime orderAt;

  const OrderItem({
    required this.amount,
    required this.orderAt,
    required this.id,
    required this.products,
  });
}

class Orders with ChangeNotifier {
  List<OrderItem> _orders = [];

  List<OrderItem> get orders {
    return _orders.toList();
  }

  final String? _token;
  final String? _userId;

  Orders(this._orders, this._token, this._userId);

  Future addOrders(List<CartItem> cartProducts, num total) async {
    try {
      final orderAt = DateTime.now();
      final requestMap = {
        OrderItemProperties.amount.name: total,
        OrderItemProperties.orderAt.name: orderAt.toIso8601String(),
        OrderItemProperties.products.name: cartProducts
            .map((e) => {
                  CartItemProperties.id.name: e.id,
                  CartItemProperties.title.name: e.title,
                  CartItemProperties.price.name: e.price,
                  CartItemProperties.quantity.name: e.quantity,
                })
            .toList(),
      };
      final response = await Http.post(
          Http.baseURL,
          '${Endpoints.usersOrders.url.replaceAll('userId', _userId!)}$_token}',
          json.encode(requestMap));

      final orderId = json.decode(response.body)['name'];
      if (orderId != null) {
        _orders.add(OrderItem(
          amount: total,
          orderAt: orderAt,
          id: orderId,
          products: cartProducts,
        ));
        notifyListeners();
        return true;
      }
    } catch (e) {
      print(e);
      return false;
    }
  }

  Future fetchCreatedOrders() async {
    try {
      final Map<String, dynamic> response = await Http.get(Http.baseURL,
              '${Endpoints.usersOrders.url.replaceAll('userId', _userId!)}$_token}')
          .then((res) => json.decode(res.body));
      print(response);
      if (response.isEmpty || response == null || response['error'] != null) {
        return false;
      }
      final List<OrderItem> extractedData = [];
      response.forEach(
        (key, value) {
          extractedData.add(
            OrderItem(
              amount: value[OrderItemProperties.amount.name],
              orderAt: DateTime.parse(value[OrderItemProperties.orderAt.name]),
              id: key,
              products:
                  (value[OrderItemProperties.products.name] as List<dynamic>)
                      .map((val) {
                final cartItem = CartItem(
                  id: val[CartItemProperties.id.name],
                  title: val[CartItemProperties.title.name],
                  price: val[CartItemProperties.price.name],
                  quantity: val[CartItemProperties.quantity.name],
                );
                print(cartItem);
                return cartItem;
              }).toList(),
            ),
          );
        },
      );
      _orders = extractedData.reversed.toList();
      notifyListeners();
      return true;
    } catch (e) {
      print(e);
      return false;
    }
  }

  void clear() {
    _orders = [];
    notifyListeners();
  }
}

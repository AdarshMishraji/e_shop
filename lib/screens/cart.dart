import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/carts.dart';
import '../providers/orders.dart';
import '../screens/order.dart';

class CartScreen extends StatelessWidget {
  static const String routeName = '/cart';

  const CartScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final cart = Provider.of<Carts>(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Your cart'),
      ),
      body: Column(
        children: [
          Card(
            margin: const EdgeInsets.all(15),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Total',
                    style: TextStyle(
                      fontSize: 20,
                    ),
                  ),
                  const Spacer(),
                  Chip(
                    label: Text(
                      '\$${cart.totalAmount}',
                      style: const TextStyle(
                        color: Colors.white,
                      ),
                    ),
                    backgroundColor: Theme.of(context).primaryColor,
                  ),
                  TextButton(
                      onPressed: () {
                        Provider.of<Orders>(context, listen: false).addOrders(
                            cart.items.values.toList(), cart.totalAmount);
                        cart.clear();
                        Navigator.of(context).pushNamed(OrdersScreen.routeName);
                      },
                      child: const Text('ORDER NOW'))
                ],
              ),
            ),
          ),
          Expanded(
              child: ListView.builder(
            itemBuilder: (_, index) {
              return CartItemWidget(
                cartItem: cart.items.values.toList()[index],
                onRemoveCartItem: () =>
                    cart.removeItem(cart.items.keys.toList()[index]),
              );
            },
            itemCount: cart.items.length,
          ))
        ],
      ),
    );
  }
}

class CartItemWidget extends StatelessWidget {
  final CartItem cartItem;
  final Function onRemoveCartItem;
  const CartItemWidget(
      {Key? key, required this.cartItem, required this.onRemoveCartItem})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      background: Container(
        margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 4),
        color: Colors.redAccent,
        padding: const EdgeInsets.only(right: 24),
        alignment: Alignment.centerRight,
        child: const Icon(
          Icons.delete,
          color: Colors.white,
          size: 40,
        ),
      ),
      direction: DismissDirection.endToStart,
      onDismissed: (direction) {
        onRemoveCartItem();
      },
      key: ValueKey(cartItem.id),
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 4),
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: ListTile(
            leading: Chip(
              label: Text(
                '\$ ${cartItem.price}',
                style: const TextStyle(
                  color: Colors.white,
                ),
              ),
              backgroundColor: Theme.of(context).primaryColor,
            ),
            title: Text(cartItem.title),
            subtitle: Text(
                'Total: \$${(cartItem.quantity * cartItem.price).toStringAsFixed(2)}'),
            trailing: Text('${cartItem.quantity}x'),
          ),
        ),
      ),
    );
  }
}

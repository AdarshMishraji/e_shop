import 'package:e_shop/widgets/Loader.dart';
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
                  OrderButton(cart: cart),
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

class OrderButton extends StatefulWidget {
  const OrderButton({
    Key? key,
    required this.cart,
  }) : super(key: key);

  final Carts cart;

  @override
  State<OrderButton> createState() => _OrderButtonState();
}

class _OrderButtonState extends State<OrderButton> {
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: widget.cart.totalAmount > 0
          ? () {
              setState(() {
                _isLoading = true;
              });
              Provider.of<Orders>(context, listen: false)
                  .addOrders(widget.cart.items.values.toList(),
                      widget.cart.totalAmount)
                  .then((isSuccess) {
                if (isSuccess) {
                  Navigator.of(context).pushNamed(OrdersScreen.routeName);
                  widget.cart.clear();
                }
              }).whenComplete(() {
                setState(() {
                  _isLoading = false;
                });
              });
            }
          : null,
      child: _isLoading
          ? const Loader(
              isFullScreen: false,
              isLoading: true,
            )
          : const Text('ORDER NOW'),
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
      confirmDismiss: (_) {
        return showDialog(
          context: context,
          builder: (ctx) {
            return AlertDialog(
              title: const Text('Are u sure?'),
              content: const Text('Do u want 2 remove the item from cart?'),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(ctx).pop(true);
                  },
                  child: const Text('Yes'),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.of(ctx).pop(false);
                  },
                  child: const Text('No'),
                ),
              ],
            );
          },
        );
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

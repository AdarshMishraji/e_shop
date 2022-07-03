import 'dart:math';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../providers/carts.dart';
import '../providers/orders.dart';
import '../widgets/AppDrawer.dart';

class OrdersScreen extends StatelessWidget {
  static const String routeName = '/orders';

  const OrdersScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final orderData = Provider.of<Orders>(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text("Orders"),
      ),
      body: ListView.builder(
        itemBuilder: (_, index) =>
            OrderItemWidget(order: orderData.orders[index]),
        itemCount: orderData.orders.length,
      ),
      drawer: const AppDrawer(),
    );
  }
}

class OrderItemWidget extends StatefulWidget {
  final OrderItem order;

  const OrderItemWidget({Key? key, required this.order}) : super(key: key);

  @override
  State<OrderItemWidget> createState() => _OrderItemWidgetState();
}

class _OrderItemWidgetState extends State<OrderItemWidget> {
  bool expanded = false;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(12),
      child: Column(
        children: [
          ListTile(
            title: Text('\$${widget.order.amount}'),
            subtitle: Text(
                DateFormat('dd-MM-yyyy hh:mm').format(widget.order.dateTime)),
            trailing: IconButton(
              icon: Icon(
                expanded ? Icons.expand_less : Icons.expand_more,
                size: 32,
              ),
              onPressed: () {
                setState(() {
                  expanded = !expanded;
                });
              },
            ),
          ),
          if (expanded)
            SizedBox(
              height: min(
                widget.order.products.length * 20 + 20,
                180,
              ),
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                itemBuilder: (_, index) {
                  return ProductItem(product: widget.order.products[index]);
                },
                itemCount: widget.order.products.length,
              ),
            )
        ],
      ),
    );
  }
}

class ProductItem extends StatelessWidget {
  final CartItem product;
  const ProductItem({Key? key, required this.product}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(product.title,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        Text('(${product.quantity}x) \$${product.price}'),
      ],
    );
  }
}

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/carts.dart';
import '../providers/orders.dart';
import '../screens/cart.dart';
import '../screens/order.dart';
import './screens/productsOverview.dart';
import './screens/productDetail.dart';
import './providers/products.dart';

void main() => runApp(const Root());

class Root extends StatelessWidget {
  const Root({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // it's the convention that when we have a ChangeNotifierProvider with a new data intantiated (for example, below we instantiated Products());
    // we use ChangeNotifierProvider with create prop;
    // but if we have to listen for the values which have already intantiated, we should use ChangeNotifierProvider.value();

    // MultiProvider is simply the collection of mulitple proveiders, used when there are mulitple providers and we not want to use nested ChangeNotifierProvider;
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => Products(),
        ),
        ChangeNotifierProvider(
          create: (_) => Carts(),
        ),
        ChangeNotifierProvider(
          create: (_) => Orders(),
        )
      ],
      child: MaterialApp(
        title: 'E-Shop',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        routes: {
          '/': (_) => ProductsOverviewScreen(),
          ProductsOverviewScreen.routeName: (_) => ProductsOverviewScreen(),
          ProductDetailScreen.routeName: (_) => const ProductDetailScreen(),
          CartScreen.routeName: (_) => const CartScreen(),
          OrdersScreen.routeName: (_) => const OrdersScreen(),
        },
      ),
    );
  }
}

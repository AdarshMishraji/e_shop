import 'package:e_shop/providers/auth.dart';
import 'package:e_shop/screens/auth.dart';
import 'package:e_shop/screens/editProduct.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/carts.dart';
import '../providers/orders.dart';
import '../screens/cart.dart';
import '../screens/order.dart';
import './screens/productsOverview.dart';
import './screens/productDetail.dart';
import './providers/products.dart';
import '../screens/userProdcuts.dart';

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
          create: (_) => Auth(),
        ),
        ChangeNotifierProxyProvider<Auth, Products>(
          update: (_, auth, prevState) => Products(
              prevState == null ? [] : prevState.items,
              auth.token ?? '',
              auth.userId ?? ''),
          create: (_) => Products([], '', ''),
        ),
        ChangeNotifierProvider(
          create: (_) => Carts(),
        ),
        ChangeNotifierProxyProvider<Auth, Orders>(
          update: (_, auth, prevState) => Orders(
              prevState == null ? [] : prevState.orders,
              auth.token ?? '',
              auth.userId ?? ''),
          create: (_) => Orders([], '', ''),
        )
      ],
      child: Consumer<Auth>(builder: (_, auth, __) {
        print('builded');
        return MaterialApp(
          title: 'E-Shop',
          theme: ThemeData(
            primarySwatch: Colors.blue,
          ),
          home: auth.isUserAuthenticated
              ? const ProductsOverviewScreen()
              : FutureBuilder<dynamic>(
                  future: auth.tryAutoLogin(),
                  builder: (_, resp) {
                    if (resp.connectionState == ConnectionState.waiting) {
                      return Container(); //splash
                    }
                    if (resp.data == false) {
                      return const AuthScreen();
                    } else {
                      return Container(); //splash
                    }
                  }),
          routes: {
            ProductsOverviewScreen.routeName: (_) =>
                const ProductsOverviewScreen(),
            ProductDetailScreen.routeName: (_) => const ProductDetailScreen(),
            CartScreen.routeName: (_) => const CartScreen(),
            OrdersScreen.routeName: (_) => const OrdersScreen(),
            UserProductsScreen.routeName: (_) => const UserProductsScreen(),
            EditProductScreen.routeName: (_) => const EditProductScreen(),
            AuthScreen.routeName: (_) => const AuthScreen(),
          },
        );
      }),
    );
  }
}

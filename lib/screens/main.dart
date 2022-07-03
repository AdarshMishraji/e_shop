import 'package:flutter/material.dart';

import '../screens/productsOverview.dart';

class Main extends StatelessWidget {
  static const String routeName = '/';
  const Main({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const ProductsOverviewScreen();
  }
}

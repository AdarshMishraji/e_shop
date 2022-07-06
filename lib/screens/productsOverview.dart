import 'dart:async';

import 'package:e_shop/providers/auth.dart';
import 'package:e_shop/widgets/Loader.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/carts.dart';
import '../screens/cart.dart';
import '../widgets/AppDrawer.dart';
import '../widgets/badge.dart';
import '../providers/products.dart';
import '../screens/productDetail.dart';

enum FilterOptions { favorites, all }

class ProductsOverviewScreen extends StatefulWidget {
  static const String routeName = '/products-overview';

  const ProductsOverviewScreen({Key? key}) : super(key: key);

  @override
  State<ProductsOverviewScreen> createState() => _ProductsOverviewScreenState();
}

class _ProductsOverviewScreenState extends State<ProductsOverviewScreen> {
  bool _showFavoritesOnly = false;

  // @override
  // void didChangeDependencies() {
  //   if (!_init) {
  //     _loading = true;
  //     Provider.of<Products>(context).fetchCreatedProducts().then((isSucceed) {
  //       print(isSucceed);
  //       setState(() {
  //         _loading = false;
  //       });
  //     });
  //   }
  //   _init = true;
  //   super.didChangeDependencies();
  // }

  late Future _productFuture;
  Future _fetchOrderData() {
    return Provider.of<Products>(context, listen: false).fetchCreatedProducts();
  }

  @override
  void initState() {
    _productFuture = _fetchOrderData();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('E-Shop'),
        actions: [
          PopupMenuButton(
            icon: const Icon(Icons.more_vert),
            itemBuilder: (_) => [
              const PopupMenuItem(
                  value: FilterOptions.favorites,
                  child: Text('Only Favorites')),
              const PopupMenuItem(
                value: FilterOptions.all,
                child: Text('Show All'),
              ),
            ],
            onSelected: (FilterOptions selectedValue) {
              if (selectedValue == FilterOptions.favorites) {
                setState(() => _showFavoritesOnly = true);
              } else {
                setState(() => _showFavoritesOnly = false);
              }
            },
          ),
          Consumer<Carts>(
            builder: (_, cart, child) => Badge(
              value: cart.numberOfItemsInCart.toString(),
              child: IconButton(
                onPressed: () {
                  Navigator.of(context).pushNamed(CartScreen.routeName);
                },
                icon: child!,
              ),
            ),
            child: const Icon(
              Icons.shopping_cart,
            ),
          ),
        ],
      ),
      body: FutureBuilder(
          future: _productFuture,
          builder: (
            _,
            productsAsync,
          ) {
            if (productsAsync.connectionState == ConnectionState.waiting) {
              return const Loader(
                isFullScreen: true,
                isLoading: true,
              );
            } else {
              if (productsAsync.hasError) {
                return Container();
              }
              return ProductGrid(showFavoritesOnly: _showFavoritesOnly);
            }
          }),
      drawer: const AppDrawer(),
    );
  }
}

class ProductGrid extends StatelessWidget {
  final bool showFavoritesOnly;
  const ProductGrid({Key? key, this.showFavoritesOnly = false})
      : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Consumer<Products>(builder: (_, products, __) {
      final favoritesOnlyProducts =
          showFavoritesOnly ? products.favoritesItems : [];
      final productsToShow =
          showFavoritesOnly ? favoritesOnlyProducts : products.items;
      return GridView.builder(
        padding: const EdgeInsets.all(10),
        itemCount: productsToShow.length,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 1.5,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10),
        itemBuilder: (_, index) {
          //// like here we use ChangeNotifierProvider.value because we need to listen to the values which already have been instantiated.
          return ChangeNotifierProvider<Product>.value(
            value: productsToShow[index],
            child: ProductItem(),
          );
        },
      );
    });
  }
}

class ProductItem extends StatelessWidget {
  Timer? _debounce;
  int count = 0;

  ProductItem({Key? key}) : super(key: key);

  void _onItemPress(BuildContext context, String productId) {
    Navigator.of(context)
        .pushNamed(ProductDetailScreen.routeName, arguments: productId);
  }

  @override
  Widget build(BuildContext context) {
    final product = Provider.of<Product>(context, listen: false);
    final snackbar = ScaffoldMessenger.of(context).showSnackBar;
    final authData = Provider.of<Auth>(context);

    //// just like consumer in react context, we have consumer here as well, which automatically rerenders when the data belongs to it changes;
    //// this is the syntatic sugar for Provider.of<Product>(context) and use product in the widget;
    return ClipRRect(
      borderRadius: BorderRadius.circular(15),
      child: GridTile(
        footer: GridTileBar(
          title: Text(
            product.title,
            textAlign: TextAlign.center,
          ),
          leading: Consumer<Product>(
            // as Provider.of(context) calls the build method on change.
            // but if we want to listen an subpart of the widget we just wrap the subpart with consumer and make (listen:false) in Provider.of(context, listen:false);

            // here __ is the child which is actually the child prop of consumer.
            // __ never rebuild and it should be a static widget , and we can use the __(child) inside builderFunction to only render the dynamic part not the static part;
            builder: (_, product, __) => IconButton(
              icon: Icon(
                product.isFavorite ? Icons.favorite : Icons.favorite_border,
                color: Colors.redAccent,
              ),
              onPressed: () {
                if (_debounce?.isActive ?? false) _debounce?.cancel();
                _debounce = Timer(const Duration(milliseconds: 250), () async {
                  print(++count);
                  try {
                    await product.toggleFavorite(
                        authData.token ?? '', authData.userId ?? '');
                  } catch (e) {
                    snackbar(SnackBar(
                        content: Text(
                      e.toString(),
                      textAlign: TextAlign.center,
                    )));
                  }
                });
              },
            ),
            child: null,
          ),
          trailing: Consumer<Carts>(
            builder: (_, cart, __) => IconButton(
              icon: const Icon(Icons.shopping_cart,
                  color: Colors.lightBlueAccent),
              onPressed: () {
                cart.addItem(product.id, product.price, product.title);
                final snackBar = ScaffoldMessenger.of(context);
                snackBar.hideCurrentSnackBar();
                snackBar.showSnackBar(SnackBar(
                  content: const Text('Item added to cart'),
                  duration: const Duration(seconds: 2),
                  action: SnackBarAction(
                    label: 'Undo',
                    onPressed: () {
                      cart.removeSingleItem(product.id);
                    },
                  ),
                ));
              },
            ),
          ),
          backgroundColor: Colors.black87,
        ),
        child: GestureDetector(
          onTap: () => _onItemPress(context, product.id),
          child: Image.network(
            product.imageUrl,
            fit: BoxFit.cover,
          ),
        ),
      ),
    );
  }
}

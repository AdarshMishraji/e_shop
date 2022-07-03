import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/carts.dart';
import '../screens/cart.dart';
import '../widgets/AppDrawer.dart';
import '../widgets/badge.dart';
import '../providers/products.dart';
import '../screens/productDetail.dart';
import '../providers/product.dart';

enum FilterOptions { favorites, all }

class ProductsOverviewScreen extends StatefulWidget {
  static const String routeName = '/products-overview';

  const ProductsOverviewScreen({Key? key}) : super(key: key);

  @override
  State<ProductsOverviewScreen> createState() => _ProductsOverviewScreenState();
}

class _ProductsOverviewScreenState extends State<ProductsOverviewScreen> {
  bool showFavoritesOnly = false;

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
                // products.showFavoritesOnly = true;
                setState(() => showFavoritesOnly = true);
              } else {
                // products.showFavoritesOnly = false;
                setState(() => showFavoritesOnly = false);
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
      body: ProductGrid(showFavoritesOnly: showFavoritesOnly),
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
    final products = Provider.of<Products>(context);
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
          child: const ProductItem(),
        );
      },
    );
  }
}

class ProductItem extends StatelessWidget {
  const ProductItem({Key? key}) : super(key: key);

  void _onItemPress(BuildContext context, String productId) {
    Navigator.of(context)
        .pushNamed(ProductDetailScreen.routeName, arguments: productId);
  }

  @override
  Widget build(BuildContext context) {
    final product = Provider.of<Product>(context, listen: false);

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
                product.toggleFavorite();
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

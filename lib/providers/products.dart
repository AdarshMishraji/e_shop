import 'dart:convert';

import 'package:e_shop/models/httpExpection.dart';
import 'package:e_shop/network/endpoints.dart';
import 'package:e_shop/network/index.dart';
import 'package:flutter/material.dart';

enum ProductProperties {
  id('id'),
  title('title'),
  description('description'),
  price('price'),
  imageUrl('imageUrl'),
  isFavorite('isFavorite');

  const ProductProperties(this.name);
  final String name;
}

class Product with ChangeNotifier {
  String id;
  final String title;
  final String description;
  final num price;
  final String imageUrl;
  bool isFavorite;

  Product({
    this.id = '',
    required this.title,
    required this.description,
    required this.price,
    required this.imageUrl,
    this.isFavorite = false,
  });

  Future toggleFavorite(String token, String userId) async {
    final bool previousFavoriteValue = isFavorite;
    isFavorite = !previousFavoriteValue;
    notifyListeners();
    final response = await Http.put(
        Http.baseURL,
        '${Endpoints.userFavoriteProduct.url.replaceFirst('userId', userId).replaceFirst('productId', id)}$token',
        json.encode(isFavorite));
    if (response.statusCode >= 400) {
      isFavorite = previousFavoriteValue;
      notifyListeners();
      throw const HttpException('Unable to set favorite');
    }
  }
}

// mixin is a type of class which can be used with "with" keyword and it just copy the properties of itself into the caller class
// in below class products, we use ChangeNotifier using "with" keyword, it helps the Products class to use the properties of ChangeNotifier

class Products with ChangeNotifier {
  List<Product> _items = [];

  // bool _showFavoritesOnly = false;

  // set showFavoritesOnly(bool flag) {
  //   _showFavoritesOnly = flag;
  //   notifyListeners();
  // }

  List<Product> get items {
    // return _showFavoritesOnly
    //     ? _items.where((element) => element.isFavorite).toList()
    //     : _items.toList();
    return _items.toList();
  }

  final String? _token;
  final String? _userId;

  Products(this._items, this._token, this._userId);

  List<Product> get favoritesItems {
    return items.where((element) => element.isFavorite).toList();
  }

  Product findById(String productId) {
    return _items.firstWhere((element) => element.id == productId);
  }

  Future fetchCreatedProducts() async {
    try {
      final Map<String, dynamic> response =
          await Http.get(Http.baseURL, '${Endpoints.products.url}$_token')
              .then((value) => json.decode(value.body));
      if (response.isEmpty || response == null || response['error'] != null) {
        return false;
      }
      final favoriteResponse = await Http.get(Http.baseURL,
              '${Endpoints.userFavorites.url.replaceAll('userId', _userId ?? '')}$_token')
          .then((value) => json.decode(value.body));
      final List<Product> extractedData = [];
      response.forEach((key, value) {
        extractedData.add(
          Product(
            id: key,
            title: value[ProductProperties.title.name],
            description: value[ProductProperties.description.name],
            price: value[ProductProperties.price.name],
            imageUrl: value[ProductProperties.imageUrl.name],
            isFavorite: favoriteResponse == null
                ? false
                : favoriteResponse[key] ?? false,
          ),
        );
      });
      _items = extractedData.toList();
      notifyListeners();
      return true;
    } catch (e) {
      print(e);
      return false;
    }
  }

  Future addProduct(Product product) async {
    try {
      final response = await Http.post(
        Http.baseURL,
        '${Endpoints.products.url}$_token',
        json.encode(
          {
            ProductProperties.title.name: product.title,
            ProductProperties.description.name: product.description,
            ProductProperties.imageUrl.name: product.imageUrl,
            ProductProperties.price.name: product.price,
          },
        ),
      );
      print(response.body);
      final id = json.decode(response.body)['name'];
      if (id != null) {
        product.id = id;
        _items.add(product);
        notifyListeners();
        return true;
      }
    } catch (e) {
      print(e);
      return false;
    }
  }

  Future editProduct(Product product) async {
    try {
      await Http.patch(
        Http.baseURL,
        '${Endpoints.productsWithId.url}$_token'
            .replaceFirst('id', '/${product.id}'),
        json.encode(
          {
            ProductProperties.title.name: product.title,
            ProductProperties.description.name: product.description,
            ProductProperties.imageUrl.name: product.imageUrl,
            ProductProperties.price.name: product.price,
          },
        ),
      );
      int index = _items.indexWhere((element) => element.id == product.id);
      if (index >= 0) {
        _items[index] = product;
      }
      notifyListeners();
      return true;
    } catch (e) {
      return false;
    }
  }

  Future deleteProduct(String productId) async {
    final existingProductIndex =
        _items.indexWhere((element) => element.id == productId);
    final existingProduct = _items[existingProductIndex];
    _items.removeWhere((element) => element.id == productId);
    notifyListeners();
    final response = await Http.delete(
        Http.baseURL,
        '${Endpoints.productsWithId.url}$_token'
            .replaceFirst('id', '/$productId'),
        null);

    if (response.statusCode >= 400) {
      _items.insert(existingProductIndex, existingProduct);
      notifyListeners();
      throw const HttpException('Could not delete product');
    }
  }
}

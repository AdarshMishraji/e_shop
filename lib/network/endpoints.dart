enum Endpoints {
  products("/products.json?auth="),
  productsWithId("/products/id.json?auth="),

  userFavoriteProduct("/userFavorites/userId/productId.json?auth="),
  userFavorites("/userFavorites/userId.json?auth="),

  order("/orders.json?auth="),
  usersOrders("/orders/userId.json?auth="),

  signup(':signUp?key='),
  login(':signInWithPassword?key=');

  const Endpoints(this.url);
  final String url;
}

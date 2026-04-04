import 'product.dart';

// Class for each item inside the cart
class CartItem {
  final Product product; // Represents the product in cart
  int quantity; // Represents how many of that product in the cart

  CartItem({required this.product, this.quantity = 1}); // Defauly quantity is 1
}

// Class that represents the whole shopping cart
class Cart {
  static final List<CartItem> items =
      []; // A list that holds all items in the cart

// Adds a product to the cart, if the product is already in the cart, it increases the quantity
  static void add(Product product) {
    // Checks if product is already in the cart
    final index = items.indexWhere((item) => item.product.id == product.id);

    if (index != -1) {
      // Item already in cart
      int newQuantity = items[index].quantity + 1;

      if (newQuantity > product.stock) {
        // If the new amount exceeds stock, set it to the maximum available stock
        items[index].quantity = product.stock;
      } else {
        items[index].quantity = newQuantity;
      }
    } else {
      // Item not in cart, add it with quantity 1 (or 0 if out of stock)
      int initialQuantity = product.stock > 0 ? 1 : 0;

// Adds item to cart
      items.add(
        CartItem(
          product: product,
          quantity: initialQuantity,
        ),
      );
    }
  }

// Removes a product from the cart
  static void remove(Product product) {
    // Removes the matching product from the cart
    items.removeWhere((item) => item.product.id == product.id);
  }
}

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

// Adds a product to the cart, if it already exists it increases the quantity by 1
  static void add(Product product) {
    // Checks if product is already in the cart
    final index = items.indexWhere((item) => item.product == product);

// Products is alread in the cart, increase quantity, otherwise add new product to cart
    if (index != -1) {
      items[index].quantity += 1;
    } else {
      items.add(CartItem(product: product));
    }
  }

// Removes a product from the cart
  static void remove(Product product) {
    // Removes the matching product from the cart
    items.removeWhere((item) => item.product == product);
  }
}

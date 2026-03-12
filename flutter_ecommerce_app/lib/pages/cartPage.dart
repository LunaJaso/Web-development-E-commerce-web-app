import 'package:flutter/material.dart';
import '../models/cart.dart';

class CartPage extends StatefulWidget {
  const CartPage({super.key});

  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Cart')),
      body: Cart.items.isEmpty // If cart is empty shows empty message
          ? const Center(child: Text('Your cart is empty'))
          : ListView.builder(
              itemCount: Cart.items.length,
              itemBuilder: (context, index) {
                final cartItem = Cart.items[index];
                final product = cartItem.product;

                return Container(
                  margin:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 6,
                        offset: Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [

                      // Product image
                      Image.asset(
                        product.image,
                        width: 120,
                        height: 120,
                        fit: BoxFit.cover,
                      ),
                      const SizedBox(width: 16),

                      // Product info and quantity
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              product.name,
                              style: const TextStyle(
                                  fontSize: 20, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              '\$${product.price.toStringAsFixed(2)} x ${cartItem.quantity}',
                              style: const TextStyle(
                                  fontSize: 18, color: Colors.grey),
                            ),
                          ],
                        ),
                      ),

                      // Quanitty buttons
                      Column(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.arrow_drop_up),
                            onPressed: () {
                              setState(() {
                                cartItem.quantity += 1;
                              });
                            },
                          ),
                          IconButton(
                            icon: const Icon(Icons.arrow_drop_down),
                            onPressed: () {
                              setState(() {
                                cartItem.quantity -= 1;
                                // Removes item if quantity goes below 1
                                if (cartItem.quantity < 1) {
                                  Cart.items.removeAt(index);
                                }
                              });
                            },
                          ),
                        ],
                      ),

                      // Delete button
                      IconButton(
                        icon: const Icon(Icons.delete, size: 28),
                        onPressed: () {
                          setState(() {
                            Cart.items.removeAt(index);
                          });
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content:
                                  Text('${product.name} removed from cart'),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                );
              },
            ),

            // Order buttom
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
        color: Colors.white,
        child: ElevatedButton(
          onPressed: () {

            // Placeholder for order placement
          },
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 16),
            backgroundColor: Colors.green,
          ),
          child: const Text(
            'Place Order',
            style: TextStyle(fontSize: 20),
          ),
        ),
      ),
    );
  }
}

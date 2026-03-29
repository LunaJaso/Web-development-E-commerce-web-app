import 'package:flutter/material.dart';
import '../models/cart.dart';
import '../models/order.dart';
import '../auth/authentication.dart';
import '../services/orders_service.dart';
import '../models/address.dart';

class OrderPlacementPage extends StatefulWidget {
  const OrderPlacementPage({super.key});

  @override
  State<OrderPlacementPage> createState() => _OrderPlacementPageState();
}

class _OrderPlacementPageState extends State<OrderPlacementPage> {
  // Controllers for address input fields
  final street = TextEditingController();
  final city = TextEditingController();
  final state = TextEditingController();
  final zipCode = TextEditingController();
  final country = TextEditingController();

  // Calculate total amount from cart items
  double getTotalAmount() {
    double total = 0;
    // Loop through cart items and sum up total
    for (var item in Cart.items) {
      total += item.product.price * item.quantity;
    }
    return total;
  }

  @override
  Widget build(BuildContext context) {
    // Get total amount and auth service instance
    final totalAmount = getTotalAmount();
    final authService = AuthService();

    return Scaffold(
      appBar: AppBar(title: const Text('Finalize Order')),
      body: Column(
        children: [
          Expanded(
            child: Cart.items.isEmpty
                // Empty cart message if no items, otherwise show list of cart items
                ? const Center(child: Text('Your cart is empty'))
                : ListView.builder(
                    itemCount: Cart.items.length,
                    itemBuilder: (context, index) {
                      final cartItem = Cart.items[index];
                      final product = cartItem.product;
                      return ListTile(
                        // Product Image, name, quantity, price, and total
                        leading: Image.asset(product.image,
                            width: 60, height: 60, fit: BoxFit.cover),
                        title: Text(product.name,
                            style: const TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 16)),
                        subtitle: Text(
                            '${cartItem.quantity} x \$${product.price.toStringAsFixed(2)}'),
                        trailing: Text(
                            '\$${(product.price * cartItem.quantity).toStringAsFixed(2)}'),
                      );
                    },
                  ),
          ),
          const Divider(thickness: 1),

          // Address input
          const SizedBox(height: 16),
          TextField(
            controller: street,
            decoration: const InputDecoration(labelText: 'Street Address'),
          ),
          TextField(
            controller: city,
            decoration: const InputDecoration(labelText: 'City'),
          ),
          TextField(
            controller: state,
            decoration: const InputDecoration(labelText: 'State'),
          ),
          TextField(
            controller: zipCode,
            decoration: const InputDecoration(labelText: 'Zip Code'),
            keyboardType: TextInputType.number,
          ),
          TextField(
            controller: country,
            decoration: const InputDecoration(labelText: 'Country'),
          ),
          const SizedBox(height: 16),

          // Displays subtotal, tax, and total amount, and a button to confirm order
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                // Subtotal
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Subtotal', style: TextStyle(fontSize: 18)),
                    Text('\$${totalAmount.toStringAsFixed(2)}',
                        style: const TextStyle(fontSize: 18)),
                  ],
                ),
                const SizedBox(height: 8),

                // Tax (5% is default)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Tax (5%)', style: TextStyle(fontSize: 18)),
                    Text('\$${(totalAmount * 0.05).toStringAsFixed(2)}',
                        style: const TextStyle(fontSize: 18)),
                  ],
                ),
                const Divider(thickness: 1, height: 24),

                // Total amount (subtotal + tax)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Total',
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold)),
                    Text('\$${(totalAmount * 1.05).toStringAsFixed(2)}',
                        style: const TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold)),
                  ],
                ),
                const SizedBox(height: 16),

                // Confirm button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () async {
                      // Check if cart is empty
                      if (Cart.items.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text(
                                  'Cannot place an order with an empty cart')),
                        );
                        return;
                      }

                      // Checka if address fields are filled in
                      if (street.text.isEmpty ||
                          city.text.isEmpty ||
                          state.text.isEmpty ||
                          zipCode.text.isEmpty ||
                          country.text.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text('Please fill in all fields')),
                        );
                        return;
                      }

                      // Checks if user is logged in
                      if (!authService.isLoggedIn) {
                        showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text('Not Logged In'),
                            content:
                                const Text('Please log in to place an order.'),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: const Text('OK'),
                              ),
                            ],
                          ),
                        );
                        return;
                      }

                      // Creates order object with data input
                      final order = Order(
                        orderId:
                            DateTime.now().millisecondsSinceEpoch.toString(),
                        userId: authService.userId!,
                        productIds:
                            Cart.items.map((item) => item.product.id).toList(),
                        quantities:
                            Cart.items.map((item) => item.quantity).toList(),
                        totalAmount: totalAmount * 1.05,
                        orderDate: DateTime.now(),
                        address: Address(
                          street: street.text,
                          city: city.text,
                          state: state.text,
                          zipCode: zipCode.text,
                          country: country.text,
                        ),
                      );

                      // Process into database
                      try {
                        await OrdersService().createOrder(order);

                        // Clears cart
                        Cart.items.clear();

                        // UI refresh
                        setState(() {});

                        // Confirmation dialog
                        showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text('Order Placed'),
                            content: Text(
                                'Thank you ${authService.userName ?? ''}, your order has been placed!'),
                            actions: [
                              TextButton(
                                onPressed: () {
                                  // Closes dialog
                                  Navigator.pop(context);

                                  // returns to previous page
                                  Navigator.pop(context, true);
                                },
                                child: const Text('OK'),
                              ),
                            ],
                          ),
                        );
                      } catch (e) {
                        // Error message if order placement fails
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Failed to place order: $e')),
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      backgroundColor: Colors.green,
                    ),
                    child: const Text('Confirm Order',
                        style: TextStyle(fontSize: 20)),
                  ),
                )
              ],
            ),
          )
        ],
      ),
    );
  }

  // Dispose controllers
  @override
  void dispose() {
    street.dispose();
    city.dispose();
    state.dispose();
    zipCode.dispose();
    country.dispose();
    super.dispose();
  }
}

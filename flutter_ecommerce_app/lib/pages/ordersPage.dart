import 'package:flutter/material.dart';
import '../models/order.dart';
import '../services/orders_service.dart';
import '../auth/authentication.dart';
import 'orderDetailsPage.dart';
import '../services/products_service.dart';

class OrdersPage extends StatefulWidget {
  const OrdersPage({super.key});

  @override
  State<OrdersPage> createState() => _OrdersPageState();
}

// Stateful widget for the orders page, which displays a list of the user's orders and allows them to view details for each order
class _OrdersPageState extends State<OrdersPage> {
  // List of orders and loading state
  List<Order> orders = [];
  // Loading state to prevent multiple loads at once
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    // Load orders when the page is initialized
    loadOrders();
  }

// Loads orders for current user
  Future<void> loadOrders() async {
    // Authenticates current user
    final authService = AuthService();
    // Fetch orders for current userId
    final fetchedOrders = await OrdersService().getOrders(authService.userId!);

// Refreshes UI
    setState(() {
      orders = fetchedOrders;
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Orders')),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : orders.isEmpty
              ? const Center(child: Text('No orders'))
              // List of orders displayed using ListView.builder
              : ListView.builder(
                  itemCount: orders.length, // Number of orders to display
                  itemBuilder: (context, index) {
                    // Get the order for the current index
                    final order = orders[index];

                    return Card(
                      margin: const EdgeInsets.all(10),
                      child: ListTile(
                        // Order total
                        title: Text(
                            'Order \$${order.totalAmount.toStringAsFixed(2)}'),
                        subtitle: Column(
                          // Order details: number of items, date, and shipping city/state
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Items: ${order.productIds.length}'),
                            Text(
                                'Date: ${order.orderDate.toLocal().toString().split(' ')[0]}'),
                            Text(
                                'Ship to: ${order.address.city}, ${order.address.state}'),
                          ],
                        ),
                        onTap: () async {
                          // When an order is tapped, fetch the products for that order
                          final products = await ProductsService()
                              .getProductsByIds(order.productIds);

                          // Navigates to the OrderDetailsPage, passing the order and its products
                          final result = await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => OrderDetailsPage(
                                order: order,
                                products: products,
                              ),
                            ),
                          );

                          // Reloads all orders
                          if (result == true) {
                            await loadOrders();
                          }
                        },
                      ),
                    );
                  },
                ),
    );
  }
}

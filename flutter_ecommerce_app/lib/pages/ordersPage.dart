import 'package:flutter/material.dart';
import '../models/order.dart';
import '../services/orders_service.dart';
import '../auth/authentication.dart';
import 'orderDetailsPage.dart';
import 'orderPlacementPage.dart';
import 'adminOrderEditPage.dart';
import '../services/products_service.dart';

class OrdersPage extends StatefulWidget {
  final bool isAdmin;

  const OrdersPage({super.key, required this.isAdmin});

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

    List<Order> fetchedOrders;

    if (widget.isAdmin) {
      // If user is admin, fetch all orders
      fetchedOrders = await OrdersService().getAllOrders();
    } else {
      // If user is not admin, fetch only users orders
      fetchedOrders = await OrdersService().getOrders(authService.userId!);
    }

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
                          // Order details (number of items, date, shipping city/state, and order status)
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Items: ${order.productIds.length}'),
                            Text(
                                'Date: ${order.orderDate.toLocal().toString().split(' ')[0]}'),
                            Text(
                                'Ship to: ${order.address.city}, ${order.address.state}'),
                            Text(
                              'Status: ${order.isCancelled ? 'Cancelled' : order.isShipped ? 'Shipped' : 'Pending'}',
                              style:
                                  const TextStyle(fontWeight: FontWeight.w600),
                            ),
                          ],
                        ),
                        // If user is admin, show popup menu with options to edit, ship, cancel, or delete the order
                        trailing: widget.isAdmin
                            ? PopupMenuButton<String>(
                                onSelected: (value) async {
                                  try {
                                    if (value == 'edit') {
                                      final result = await Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) =>
                                              AdminOrderEditPage(order: order),
                                        ),
                                      );
                                      if (result == true) {
                                        await loadOrders();
                                      }
                                    } else if (value == 'ship') {
                                      await OrdersService()
                                          .markOrderAsShipped(order.orderId);
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(const SnackBar(
                                              content: Text(
                                                  'Order marked as shipped')));
                                    } else if (value == 'cancel') {
                                      await OrdersService()
                                          .cancelOrder(order.orderId);
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(const SnackBar(
                                              content: Text(
                                                  'Order cancelled successfully')));
                                    } else if (value == 'delete') {
                                      await OrdersService()
                                          .deleteOrder(order.orderId);
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(const SnackBar(
                                              content: Text(
                                                  'Order deleted successfully')));
                                    }
                                    await loadOrders();
                                  } catch (e) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                            content: Text(
                                                'Error updating order: $e')));
                                  }
                                },
                                itemBuilder: (context) {
                                  return [
                                    const PopupMenuItem(
                                      value: 'edit',
                                      child: Text('Edit Order'),
                                    ),
                                    if (!order.isShipped && !order.isCancelled)
                                      const PopupMenuItem(
                                        value: 'ship',
                                        child: Text('Mark as Shipped'),
                                      ),
                                    if (!order.isCancelled && !order.isShipped)
                                      const PopupMenuItem(
                                        value: 'cancel',
                                        child: Text('Cancel Order'),
                                      ),
                                    const PopupMenuItem(
                                      value: 'delete',
                                      child: Text('Delete Order'),
                                    ),
                                  ];
                                },
                              )
                            : null,
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
      // If user is admin, show button to add new order
      floatingActionButton: widget.isAdmin
          ? FloatingActionButton(
              onPressed: () async {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const OrderPlacementPage(),
                  ),
                );
                if (result == true) {
                  await loadOrders();
                }
              },
              child: const Icon(Icons.add),
              tooltip: 'Add Order',
            )
          : null,
    );
  }
}

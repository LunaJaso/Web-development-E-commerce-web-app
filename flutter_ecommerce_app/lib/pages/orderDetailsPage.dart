import 'package:flutter/material.dart';
import '../models/order.dart';
import '../models/product.dart';

class OrderDetailsPage extends StatelessWidget {
  // Order object
  final Order order;

  // List of products
  final List<Product> products;

  const OrderDetailsPage({
    super.key,
    required this.order,
    required this.products,
  });

 // Formats DateTime object
  String formatDate(DateTime date) {
    // Month names
    final months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December'
    ];
    
    // Convert to 12-hour format
    int hour = date.hour;
    final minute = date.minute.toString().padLeft(2, '0');

    // am/pm suffix
    final amPm = hour >= 12 ? 'PM' : 'AM';

    // Convert to 12-hour format
    if (hour == 0) {
      hour = 12; } 
    else if (hour > 12) {
      hour -= 12; }

// Final formatted string
    return '${months[date.month - 1]} ${date.day}, ${date.year} – ${hour.toString().padLeft(2, '0')}:$minute $amPm';
  }

  @override
  Widget build(BuildContext context) {
    // Display date and time in local time zone
    final dateFormatted = formatDate(order.orderDate.toLocal());

    return Scaffold(
      appBar: AppBar(title: const Text('Order Details')),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Total Amount
            Card(
              elevation: 3,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    const Icon(Icons.attach_money,
                        size: 30, color: Colors.green),
                    const SizedBox(width: 10),
                    // Total amount with 2 decimal places
                    Text(
                      '\$${order.totalAmount.toStringAsFixed(2)}',
                      style: const TextStyle(
                          fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Order Date
            Row(
              children: [
                const Icon(Icons.calendar_today,
                    size: 20, color: Colors.blueGrey),
                const SizedBox(width: 8),
                // Formatted date string
                Text(
                  'Date: $dateFormatted',
                  style: const TextStyle(fontSize: 16),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // Shipping Address
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Shipping address header
                    const Text(
                      'Shipping Address',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 10),

                    // address icon and label
                    Row(
                      children: const [
                        Icon(Icons.location_on,
                            size: 20, color: Colors.redAccent),
                        SizedBox(width: 8),
                        Text('Street:'),
                      ],
                    ),

                    // Shipping address details
                    Text(order.address.street),
                    Text(
                        '${order.address.city}, ${order.address.state} ${order.address.zipCode}'),
                    Text(order.address.country),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Products List
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Products header
                    const Text(
                      'Products',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 10),

                    // List of products in the order (uses spread operator to insert widgets for each product)
                    ...products.asMap().entries.map(
                      (entry) {
                        final index = entry.key;
                        final product = entry.value;
                        final quantity = order.quantities.isNotEmpty &&
                                index < order.quantities.length
                            ? order.quantities[index]
                            : 1;
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Product Image
                              if (product.image.isNotEmpty)
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: Image.network(
                                    product.image,
                                    width: 60,
                                    height: 60,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              const SizedBox(width: 12),
                              // Product Details
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // Product name, price, and description (if isNotEmpty)
                                    Text(
                                      product.name,
                                      style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold),
                                    ),
                                    Text(
                                        '\$${product.price.toStringAsFixed(2)}',
                                        style: const TextStyle(
                                            color: Colors.green)),
                                    if (product.desc.isNotEmpty)
                                      Text(
                                        product.desc,
                                        style: const TextStyle(
                                            color: Colors.grey),
                                      ),
                                    const SizedBox(height: 4),
                                    // Quantity display
                                    Text(
                                      'Quantity: $quantity',
                                      style: const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                        color: Colors.blueGrey,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

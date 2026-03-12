// imports Flutter design widgets
import 'package:flutter/material.dart';

// imports prodcut.dart
import '../models/product.dart';

// imports cart.dart
import '../models/cart.dart';

// Product Details page, StatelessWidget means the UI cannot change while running
class ProductDetailsPage extends StatelessWidget {
  // The product on display
  final Product product;

  // Passes prodcut into contructor
  const ProductDetailsPage({super.key, required this.product});

  // UI for the page
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // AppBar displaying product name
      appBar: AppBar(title: Text(product.name)),

      body: LayoutBuilder(
        builder: (context, constraints) {
          final bool isWide = constraints.maxWidth > 900;

          Widget content = ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 700),

            // Scrollable page
            child: ListView(
              shrinkWrap: isWide,
              padding: const EdgeInsets.only(bottom: 256),
              children: [
                // Displays product image
                Image.asset(
                  product.image,
                  height: 300, // Height
                  width: double.infinity, // Width
                  fit: BoxFit.cover, // Crop image
                ),

                // Padding below image
                Padding(
                  padding: const EdgeInsets.all(16.0),

                  // Column will stack widgets vertically
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start, // Left aligning content
                    children: [
                      // Displays product name
                      Text(
                        product.name,
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),

                      // Added vertical space
                      const SizedBox(height: 8),

                      // Displays price, formated to 2 decimal points
                      Text(
                        '\$${product.price.toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      // More vertical spacing
                      const SizedBox(height: 16),

                      // Need to inmplement product description text
                      Text(product.desc),

                      // Spacing
                      const SizedBox(height: 24),

                      // Full screen widht button
                      SizedBox(
                        width: double.infinity,

                        // Add to cart button, still needs coding logic
                        child: ElevatedButton(
                          onPressed: () {
                            Cart.add(product);

                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                  content:
                                      Text('${product.name} added to cart')),
                            );
                          },
                          child: const Text('Add to Cart'),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );

          if (isWide) {
            return Center(
              child: Material(
                elevation: 4,
                borderRadius: BorderRadius.circular(16),
                clipBehavior: Clip.antiAlias,
                  child: content,
              ),
            );
          }

          return Center(child: content);
        },
      ),
    );
  }
}

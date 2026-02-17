// Imports flutter design widgets
import 'package:flutter/material.dart';

// Imports products.dart
import '../data/products.dart';

// Imports prodcut.dart
import '../models/product.dart';

// Imports productDetailsPage.dart
import 'productDetailsPage.dart';

// Stateless page that forms a 2 box wide grid
// It is stateless becuase this page does not manage internal data
class ProductsPage extends StatelessWidget {
  const ProductsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // App bar at top of the screen, centered
      appBar: AppBar(title: const Text('Shop'), centerTitle: true),

      // Padding around the outside of the entire grid
      body: Padding(
        padding: const EdgeInsets.all(8.0),

        // Creates the grid
        child: GridView.builder(
          // Number of products in the grid
          itemCount: products.length,

          // grid layout (2 columns, maybe it should be 3 at a certain width)
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 0.7,
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
          ),

          // Builds each individual grid item
          itemBuilder: (context, index) {
            // Retrieves current product from list
            final Product product = products[index];

            return GestureDetector(
              // Runs when user taps the product
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    // Passes product to productDetailsPage, opens add to cart menu
                    builder: (_) => ProductDetailsPage(product: product),
                  ),
                );
              },

              // UI for each product
              child: Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12), // Rounds corners
                ),
                elevation: 3, // Creates a shadow effect
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AspectRatio(
                      aspectRatio: 1, // square box
                      child: ClipRRect(
                        // Rounds only the top corners of the image
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(12),
                        ),

                        // Displays product image
                        child: Image.asset(
                          product.image,
                          fit: BoxFit.cover, // crops the dice image
                        ),
                      ),
                    ),

                    // Product name and padding
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        product.name,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),

                    // Product price and padding, rounded to 2 decimals
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: Text('\$${product.price.toStringAsFixed(2)}'),
                    ),

                    // Extra space at the bottom of the page
                    const SizedBox(height: 8),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

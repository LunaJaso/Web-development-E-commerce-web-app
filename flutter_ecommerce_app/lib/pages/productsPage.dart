// Imports flutter design widgets
import 'package:flutter/material.dart';

// Imports product model and Firebase-backed service
import '../models/product.dart';
import '../services/products_service.dart';

// Imports productDetailsPage.dart
import 'productDetailsPage.dart';

// Stateless page that forms a 2 box wide grid
// It is stateless becuase this page does not manage internal data
class ProductsPage extends StatelessWidget {
  const ProductsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Shop'), centerTitle: true),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        // Future builder object that waits for the list of products to be retrieved from Firebase
        child: FutureBuilder<List<Product>>(
          // Calls Firebase service
          future: ProductsService().getAllProducts(),
          builder: (context, snapshot) {
            // Loading screen
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            // Displayes error message
            if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            }
            // Load products list, or return empty if null
            final products = snapshot.data ?? [];
            return GridView.builder(
              itemCount: products.length,
              gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                maxCrossAxisExtent: 220,
                childAspectRatio: 0.7,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
              ),
              itemBuilder: (context, index) {
                final Product product = products[index];
                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ProductDetailsPage(product: product),
                      ),
                    );
                  },
                  child: Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 3,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        AspectRatio(
                          aspectRatio: 1,
                          child: ClipRRect(
                            borderRadius: const BorderRadius.vertical(
                              top: Radius.circular(12),
                            ),
                            // Will load from online assets first as thats the proper way, if not online it will load locally
                            child: product.image.startsWith('http')
                                ? Image.network(product.image, fit: BoxFit.cover)
                                : Image.asset(product.image, fit: BoxFit.cover),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            product.name,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8.0),
                          child: Text('\$${product.price.toStringAsFixed(2)}'),
                        ),
                        const SizedBox(height: 8),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}

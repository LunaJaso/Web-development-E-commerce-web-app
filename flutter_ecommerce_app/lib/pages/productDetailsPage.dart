import 'package:flutter/material.dart';
import '../models/product.dart';

// This is the page you are taken too when clicking on a product, implementation is not finished
class ProductDetailsPage extends StatelessWidget {
  // The product on display
  final Product product;

  const ProductDetailsPage({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Displays product name
      appBar: AppBar(title: Text(product.name)),
      body: ListView(
        children: [
          Image.asset(
            product.image,
            height: 300, // Height
            width: double.infinity, // Width
            fit: BoxFit.cover, // Crop image
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.name,
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 8),
                Text(
                  '\$${product.price.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Default description',
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {},
                    child: const Text('Add to Cart'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

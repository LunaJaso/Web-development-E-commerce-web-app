import 'package:flutter/material.dart';
import '../models/product.dart';
import '../services/products_service.dart';
import '../auth/authentication.dart';

// default stateful widget for admin tools page
class MyAdminToolsPage extends StatefulWidget {
  const MyAdminToolsPage({super.key});

  @override
  State<MyAdminToolsPage> createState() => _MyAdminToolsPageState();
}

class _MyAdminToolsPageState extends State<MyAdminToolsPage> {
  // Auth serice instance that allows access to the current user's ID for product uploads
  final auth = AuthService();

  final _formKey = GlobalKey<FormState>();

  // Controllers for the form fields
  final _nameController = TextEditingController();
  final _priceController = TextEditingController();
  final _imageController = TextEditingController();
  final _descController = TextEditingController();
  final _stockController = TextEditingController();

  // Valdiates in case the user somehow uploads more than one product at a time
  bool _loading = false;

  // Track if form is shown
  bool _showForm = false;
  // tracks if user is editing a product
  String? _editingProductId;

  // Shows product form
  void _showProductForm({Product? product}) {
    setState(() {
      _showForm = true;
      _editingProductId = product?.id;

      if (product != null) {
        // Pre-fill form with existing product data if editing
        _nameController.text = product.name;
        _priceController.text = product.price.toString();
        _imageController.text = product.image;
        _descController.text = product.desc;
        _stockController.text = product.stock.toString();
      } else {
        // Clear form for new product if not editing
        _nameController.clear();
        _priceController.clear();
        _imageController.clear();
        _descController.clear();
        _stockController.clear();
      }
    });
  }

  // Hides the form and resets form data
  void _hideForm() {
    setState(() {
      _showForm = false;
      _editingProductId = null;
      _nameController.clear();
      _priceController.clear();
      _imageController.clear();
      _descController.clear();
      _stockController.clear();
    });
  }

  // Upload products to Firebase using the ProductsService and the current user's ID from the AuthService
  Future<void> _uploadProduct() async {
    // Validates form inputs
    if (!_formKey.currentState!.validate()) return;

    // sets loading to true
    setState(() => _loading = true);

    try {
      final product = Product(
        id: _editingProductId ?? '',
        name: _nameController.text.trim(),
        price: double.parse(_priceController.text.trim()),
        image: _imageController.text.trim(),
        desc: _descController.text.trim(),
        userId: auth.userId!,
        stock: int.parse(_stockController.text.trim()),
      );

      // Use the service to add or update products
      if (_editingProductId != null) {
        // Updates existing product
        await ProductsService().updateProduct(_editingProductId!, product);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Product updated successfully!')),
        );
      } else {
        // Adds new products
        await ProductsService().addProduct(product);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Product uploaded successfully!')),
        );
      }

      _hideForm();
    } catch (e) {
      // Error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error saving product: $e')),
      );
    } finally {
      // laoding set to false
      setState(() => _loading = false);
    }
  }

  // Deletes a product
  Future<void> _deleteProduct(String productId) async {
    // Asks the user if they are sure they want to delete a product
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Product'),
        content: const Text('Are you sure you want to delete this product?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              try {
                await ProductsService().deleteProduct(productId);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                      content: Text('Product deleted successfully!')),
                );
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Error deleting product: $e')),
                );
              }
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Admin Tools')),
      body: _loading
          // Loading indicator, (this is awesome)
          ? const Center(child: CircularProgressIndicator())
          : _showForm
              ? _buildProductForm()
              : _buildProductsList(),
      floatingActionButton: _showForm
          ? null
          : FloatingActionButton(
              onPressed: () => _showProductForm(),
              child: const Icon(Icons.add),
            ),
    );
  }

  // Builds the form for adding and editing products
  Widget _buildProductForm() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Form(
        key: _formKey,
        child: ListView(
          children: [
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Product Name'),
              validator: (value) => value!.isEmpty ? 'Enter a name' : null,
            ),
            TextFormField(
              controller: _priceController,
              decoration: const InputDecoration(labelText: 'Price'),
              keyboardType: TextInputType.number,
              validator: (value) => value!.isEmpty ? 'Enter a price' : null,
            ),
            TextFormField(
              controller: _imageController,
              decoration: const InputDecoration(labelText: 'Image URL'),
              validator: (value) =>
                  value!.isEmpty ? 'Enter an image URL' : null,
            ),
            TextFormField(
              controller: _descController,
              decoration: const InputDecoration(labelText: 'Description'),
              validator: (value) =>
                  value!.isEmpty ? 'Enter a description' : null,
            ),
            TextFormField(
              controller: _stockController,
              decoration: const InputDecoration(labelText: 'Stock'),
              keyboardType: TextInputType.number,
              validator: (value) =>
                  value!.isEmpty ? 'Enter amount of stock' : null,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _uploadProduct,
              child: Text(
                _editingProductId != null ? 'Update Product' : 'Upload Product',
              ),
            ),
            const SizedBox(height: 10),
            TextButton(
              onPressed: _hideForm,
              child: const Text('Cancel'),
            ),
          ],
        ),
      ),
    );
  }

  // Builds the view for products
  Widget _buildProductsList() {
    return FutureBuilder<List<Product>>(
      future: ProductsService().getAllProducts(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(
            child: Text('Error loading products: ${snapshot.error}'),
          );
        }

        final products = snapshot.data ?? [];

        if (products.isEmpty) {
          return const Center(
            child: Text('No products yet. Tap + to add one!'),
          );
        }
// Displays products in a grid view with edit/delete options
        return Padding(
          padding: const EdgeInsets.all(8.0),
          child: GridView.builder(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.75,
              mainAxisSpacing: 8,
              crossAxisSpacing: 8,
            ),
            itemCount: products.length,
            itemBuilder: (context, index) {
              final product = products[index];
              return GestureDetector(
                onTap: () => _showProductActionDialog(product),
                child: Card(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Container(
                          width: double.infinity,
                          color: Colors.grey[200],
                          child: Image.network(
                            product.image,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) =>
                                const Icon(Icons.image_not_supported),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              product.name,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              '\$${product.price.toStringAsFixed(2)}',
                              style: const TextStyle(
                                color: Colors.green,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

// Shows a dialog with options to edit or delete a product when a product card is tapped
  void _showProductActionDialog(Product product) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(product.name),
        content: Text(product.desc),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _showProductForm(product: product);
            },
            child: const Text('Edit'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _deleteProduct(product.id);
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  // Frees memory
  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    _imageController.dispose();
    _descController.dispose();
    super.dispose();
  }
}

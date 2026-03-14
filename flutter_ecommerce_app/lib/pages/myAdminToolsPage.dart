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

// Valdiates in case the user somehow uploads more than one product at a time
  bool _loading = false;

// Upload products to Firebase using the ProductsService and the current user's ID from the AuthService
  Future<void> _uploadProduct() async {
    // Validates form inputs
    if (!_formKey.currentState!.validate()) return;

// sets loading to true
    setState(() => _loading = true);

    try {
      final newProduct = Product(
        id: '',
        name: _nameController.text.trim(),
        price: double.parse(_priceController.text.trim()),
        image: _imageController.text.trim(),
        desc: _descController.text.trim(),
        userId: auth.userId!,
      );

      // Use the service to add the product
      await ProductsService().addProduct(newProduct);

// Show success message and clear form
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Product uploaded successfully!')),
      );

      _nameController.clear();
      _priceController.clear();
      _imageController.clear();
      _descController.clear();
    } catch (e) {
      // Error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error uploading product: $e')),
      );
    } finally {
      // laoding set to false
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Admin Tools')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: _loading
            // Loading indicator, (this is awesome)
            ? const Center(child: CircularProgressIndicator())
            : Form(
                key: _formKey,
                child: ListView(
                  children: [
                    TextFormField(
                      controller: _nameController,
                      decoration:
                          const InputDecoration(labelText: 'Product Name'),
                      validator: (value) =>
                          value!.isEmpty ? 'Enter a name' : null,
                    ),
                    TextFormField(
                      controller: _priceController,
                      decoration: const InputDecoration(labelText: 'Price'),
                      keyboardType: TextInputType.number,
                      validator: (value) =>
                          value!.isEmpty ? 'Enter a price' : null,
                    ),
                    TextFormField(
                      controller: _imageController,
                      decoration: const InputDecoration(labelText: 'Image URL'),
                      validator: (value) =>
                          value!.isEmpty ? 'Enter an image URL' : null,
                    ),
                    TextFormField(
                      controller: _descController,
                      decoration:
                          const InputDecoration(labelText: 'Description'),
                      validator: (value) =>
                          value!.isEmpty ? 'Enter a description' : null,
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: _uploadProduct,
                      child: const Text('Upload Product'),
                    ),
                  ],
                ),
              ),
      ),
    );
  }

// Frees memory when form is unused
  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    _imageController.dispose();
    _descController.dispose();
    super.dispose();
  }
}

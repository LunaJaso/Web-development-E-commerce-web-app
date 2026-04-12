import 'package:flutter/material.dart';
import '../models/order.dart';
import '../models/address.dart';
import '../models/product.dart';
import '../services/orders_service.dart';
import '../services/products_service.dart';

class AdminOrderEditPage extends StatefulWidget {
  final Order order;

  const AdminOrderEditPage({super.key, required this.order});

  @override
  State<AdminOrderEditPage> createState() => _AdminOrderEditPageState();
}

class _AdminOrderEditPageState extends State<AdminOrderEditPage> {
  final _formKey = GlobalKey<FormState>();

  // Controllers for address fields
  late final TextEditingController _streetController;
  late final TextEditingController _cityController;
  late final TextEditingController _stateController;
  late final TextEditingController _zipCodeController;
  late final TextEditingController _countryController;

  // Local state for statuses
  late bool _isCancelled;
  late bool _isShipped;

  // Retrieved products and quantities for the order
  Map<String, int> _selectedProducts = {};
  Map<String, TextEditingController> _quantityControllers = {};
  List<Product> _allProducts = [];
  bool _loadingProducts = true;

  // Loading state
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    // Initialize controllers with selected order data
    _streetController =
        TextEditingController(text: widget.order.address.street);
    _cityController = TextEditingController(text: widget.order.address.city);
    _stateController = TextEditingController(text: widget.order.address.state);
    _zipCodeController =
        TextEditingController(text: widget.order.address.zipCode);
    _countryController =
        TextEditingController(text: widget.order.address.country);

    _isCancelled = widget.order.isCancelled;
    _isShipped = widget.order.isShipped;

    // Select products from the order
    for (int i = 0; i < widget.order.productIds.length; i++) {
      String productId = widget.order.productIds[i];
      int quantity = widget.order.quantities[i];
      _selectedProducts[productId] = quantity;
      _quantityControllers[productId] =
          TextEditingController(text: quantity.toString());
    }

    // Load products
    _loadProducts();
  }

// Loads all products to allow admin to add/remove products from the order
  Future<void> _loadProducts() async {
    try {
      _allProducts = await ProductsService().getAllProducts();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading products: $e')),
      );
    } finally {
      setState(() => _loadingProducts = false);
    }
  }

  // Save the order
  Future<void> _saveOrder() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    try {
      // Calculate new total
      double newTotalAmount = 0;
      List<String> newProductIds = _selectedProducts.keys.toList();
      List<int> newQuantities = [];

      for (String productId in newProductIds) {
        int quantity =
            int.tryParse(_quantityControllers[productId]?.text ?? '1') ?? 1;
        newQuantities.add(quantity);
        Product? product = _allProducts.firstWhere((p) => p.id == productId);
        newTotalAmount += product.price * quantity;
      }

      // Create updated order
      final updatedOrder = Order(
        orderId: widget.order.orderId,
        userId: widget.order.userId,
        productIds: newProductIds,
        quantities: newQuantities,
        totalAmount: newTotalAmount,
        orderDate: widget.order.orderDate,
        address: Address(
          street: _streetController.text.trim(),
          city: _cityController.text.trim(),
          state: _stateController.text.trim(),
          zipCode: _zipCodeController.text.trim(),
          country: _countryController.text.trim(),
        ),
        isCancelled: _isCancelled,
        isShipped: _isShipped,
      );

      // Update stock
      await _updateStockForOrderChanges(updatedOrder);

      // Update Firebase
      await OrdersService().updateOrder(updatedOrder);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Order updated successfully!')),
      );

      // Return to previous page
      Navigator.pop(context, true);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error updating order: $e')),
      );
    } finally {
      setState(() => _isSaving = false);
    }
  }

  Future<void> _updateStockForOrderChanges(Order updatedOrder) async {
    // Get original product quantities
    Map<String, int> oldQuantities = {};
    for (int i = 0; i < widget.order.productIds.length; i++) {
      oldQuantities[widget.order.productIds[i]] = widget.order.quantities[i];
    }

    // For each product in taht order
    for (String productId in oldQuantities.keys) {
      int oldQty = oldQuantities[productId]!;
      int newQty = updatedOrder.productIds.contains(productId)
          ? updatedOrder.quantities[updatedOrder.productIds.indexOf(productId)]
          : 0;

      int qtyDiff = oldQty - newQty;
      if (qtyDiff > 0) {
        // If quantity decreased, add back to stock
        await _adjustStock(productId, qtyDiff);
      } else if (qtyDiff < 0) {
        // If quantity increased, reduce stock
        await _adjustStock(productId, qtyDiff); // negative
      }
    }

    // For additional products not in original order
    for (int i = 0; i < updatedOrder.productIds.length; i++) {
      String productId = updatedOrder.productIds[i];
      if (!oldQuantities.containsKey(productId)) {
        // Add new product and decrease its stock
        await _adjustStock(productId, -updatedOrder.quantities[i]);
      }
    }
  }

// Helper method to adjust stock for a product
  Future<void> _adjustStock(String productId, int quantityChange) async {
    await OrdersService().adjustStock(productId, quantityChange);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Edit Order')),
      body: _isSaving
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: ListView(
                  children: [
                    // Order ID (these fields are read-only))
                    TextFormField(
                      initialValue: widget.order.orderId,
                      decoration: const InputDecoration(labelText: 'Order ID'),
                      readOnly: true,
                      enabled: false,
                    ),
                    const SizedBox(height: 16),

                    // User ID
                    TextFormField(
                      initialValue: widget.order.userId,
                      decoration: const InputDecoration(labelText: 'User ID'),
                      readOnly: true,
                      enabled: false,
                    ),
                    const SizedBox(height: 16),

                    // Total Amount
                    TextFormField(
                      initialValue: _calculateTotalAmount().toStringAsFixed(2),
                      decoration:
                          const InputDecoration(labelText: 'Total Amount'),
                      readOnly: true,
                      enabled: false,
                    ),
                    const SizedBox(height: 16),

                    // Order DateTime
                    TextFormField(
                      initialValue: widget.order.orderDate.toLocal().toString(),
                      decoration:
                          const InputDecoration(labelText: 'Order Date'),
                      readOnly: true,
                      enabled: false,
                    ),
                    const SizedBox(height: 24),

                    // User Address
                    const Text(
                      'Shipping Address',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 16),

                    TextFormField(
                      controller: _streetController,
                      decoration: const InputDecoration(labelText: 'Street'),
                      validator: (value) =>
                          value!.isEmpty ? 'Enter a street' : null,
                    ),
                    TextFormField(
                      controller: _cityController,
                      decoration: const InputDecoration(labelText: 'City'),
                      validator: (value) =>
                          value!.isEmpty ? 'Enter a city' : null,
                    ),
                    TextFormField(
                      controller: _stateController,
                      decoration: const InputDecoration(labelText: 'State'),
                      validator: (value) =>
                          value!.isEmpty ? 'Enter a state' : null,
                    ),
                    TextFormField(
                      controller: _zipCodeController,
                      decoration: const InputDecoration(labelText: 'Zip Code'),
                      validator: (value) =>
                          value!.isEmpty ? 'Enter a zip code' : null,
                    ),
                    TextFormField(
                      controller: _countryController,
                      decoration: const InputDecoration(labelText: 'Country'),
                      validator: (value) =>
                          value!.isEmpty ? 'Enter a country' : null,
                    ),
                    const SizedBox(height: 24),

                    // Products
                    const Text(
                      'Products',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 16),

                    if (_loadingProducts)
                      const Center(child: CircularProgressIndicator())
                    else if (_selectedProducts.isEmpty)
                      const Text('No products selected')
                    else
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: _selectedProducts.length,
                        itemBuilder: (context, index) {
                          String productId =
                              _selectedProducts.keys.elementAt(index);
                          int quantity = _selectedProducts[productId]!;
                          Product? product = _allProducts.firstWhere(
                            (p) => p.id == productId,
                            orElse: () => Product(
                                id: '',
                                name: 'Unknown',
                                price: 0,
                                image: '',
                                desc: '',
                                userId: '',
                                stock: 0),
                          );
                          // Each product in the order with editable quantity and option to remove from order
                          return Card(
                            margin: const EdgeInsets.symmetric(vertical: 4),
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(product.name,
                                            style: const TextStyle(
                                                fontWeight: FontWeight.bold)),
                                        Text(
                                            '\$${product.price.toStringAsFixed(2)}'),
                                      ],
                                    ),
                                  ),
                                  SizedBox(
                                    width: 60,
                                    child: TextFormField(
                                      controller:
                                          _quantityControllers[productId],
                                      keyboardType: TextInputType.number,
                                      onChanged: (value) {
                                        int? newQty = int.tryParse(value);
                                        if (newQty != null && newQty > 0) {
                                          setState(() {
                                            _selectedProducts[productId] =
                                                newQty;
                                          });
                                        }
                                      },
                                      decoration: const InputDecoration(
                                        labelText: 'Qty',
                                        isDense: true,
                                      ),
                                    ),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.remove_circle,
                                        color: Colors.red),
                                    onPressed: () {
                                      setState(() {
                                        _selectedProducts.remove(productId);
                                        _quantityControllers[productId]
                                            ?.dispose();
                                        _quantityControllers.remove(productId);
                                      });
                                    },
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    // Button to add more products to the order
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: _showAddProductDialog,
                      child: const Text('Add Product'),
                    ),

                    const SizedBox(height: 24),
                    // Order Statuses
                    CheckboxListTile(
                      title: const Text('Cancelled'),
                      value: _isCancelled,
                      onChanged: (value) =>
                          setState(() => _isCancelled = value ?? false),
                    ),
                    CheckboxListTile(
                      title: const Text('Shipped'),
                      value: _isShipped,
                      onChanged: (value) =>
                          setState(() => _isShipped = value ?? false),
                    ),
                    const SizedBox(height: 24),
                    // Save and Cancel buttons
                    ElevatedButton(
                      onPressed: _saveOrder,
                      child: const Text('Update Order'),
                    ),
                    const SizedBox(height: 10),
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Cancel'),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  // Helper method to calculate total amount based on selected products and their quantities
  double _calculateTotalAmount() {
    double total = 0;
    _selectedProducts.forEach((productId, _) {
      int quantity =
          int.tryParse(_quantityControllers[productId]?.text ?? '1') ?? 1;
      Product? product = _allProducts.firstWhere(
        (p) => p.id == productId,
        orElse: () => Product(
            id: '',
            name: 'Unknown',
            price: 0,
            image: '',
            desc: '',
            userId: '',
            stock: 0),
      );
      total += product.price * quantity;
    });
    return total;
  }

  // Shows a dialog to add more products to the order, allowing selection of product and quantity
  void _showAddProductDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Product'),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: _allProducts.length,
            itemBuilder: (context, index) {
              Product product = _allProducts[index];
              bool isSelected = _selectedProducts.containsKey(product.id);
              // Prevents adding the same product twice
              return ListTile(
                leading: Image.network(
                  product.image,
                  width: 40,
                  height: 40,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) =>
                      const Icon(Icons.image),
                ),
                title: Text(product.name),
                subtitle: Text(
                    '\$${product.price.toStringAsFixed(2)} (Stock: ${product.stock})'),
                trailing: isSelected
                    ? const Icon(Icons.check, color: Colors.green)
                    : null,
                onTap: () {
                  if (!isSelected) {
                    setState(() {
                      _selectedProducts[product.id] = 1;
                      _quantityControllers[product.id] =
                          TextEditingController(text: '1');
                    });
                  }
                  Navigator.pop(context);
                },
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  // Dispose controllers to prevent memory leaks
  @override
  void dispose() {
    _streetController.dispose();
    _cityController.dispose();
    _stateController.dispose();
    _zipCodeController.dispose();
    _countryController.dispose();
    for (var controller in _quantityControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }
}

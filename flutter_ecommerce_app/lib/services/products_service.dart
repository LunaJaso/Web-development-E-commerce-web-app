// Imports Firebase Realtime Database package
import 'package:firebase_database/firebase_database.dart';

// Imports product model
import '../models/product.dart';

// Class for reading product data (I'm learning this is called the singleton pattern)
class ProductsService {
  // creats a single instance for use across the whole application
  static final ProductsService _instance = ProductsService._internal();
  // Prevents multiple instances of ProductsService from being created
  factory ProductsService() => _instance;
  // Creates the singleton
  ProductsService._internal();

// Creates a reference for products data in Firebase
  final DatabaseReference _ref = FirebaseDatabase.instance.ref('products');

// Returns a list of product objects from the database
  Future<List<Product>> getAllProducts() async {
    // retrives product data
    final snap = await _ref.get();
    // If no products exist, return an empty list
    if (!snap.exists) return [];
    // Converts product data to a map
    final data = snap.value as Map<dynamic, dynamic>;
    // Converts the map of products to a list of Product objects
    return data.entries.map((e) {
      // Goes through each product entry and for its data
      final id = e.key.toString();
      // Converts product data to a map
      final map = Map<String, dynamic>.from(e.value as Map);
      // Returns a Product object with the data
      return Product.fromMap(map, id);
      // Converts the data to a list object
    }).toList();
  }

// Add a new product to the database
  Future<void> addProduct(Product product) async {
    // Generates a new key
    final newRef = _ref.push();
    // Sets product data in the database
    await newRef.set(product.toJson());
  }

// Returns a list of products created by a specific userId (this is needed for admin tools page)
  Future<List<Product>> getProductsByUser(String userId) async {
    final all = await getAllProducts();
    return all.where((p) => p.userId == userId).toList();
  }

// Returns a list of products with their IDs
  Future<List<Product>> getProductsByIds(List<String> ids) async {
    final allProducts = await getAllProducts();
    return allProducts.where((product) => ids.contains(product.id)).toList();
  }
}

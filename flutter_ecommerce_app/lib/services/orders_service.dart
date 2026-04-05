import 'package:firebase_database/firebase_database.dart';
import '../models/order.dart';
import '../models/address.dart';

class OrdersService {
  static final OrdersService _instance = OrdersService._internal();
  factory OrdersService() => _instance;
  OrdersService._internal();

  // Firebase reference for orders and products (I should rename this)
  final DatabaseReference _ref = FirebaseDatabase.instance.ref('orders');
  final DatabaseReference _productsRef =
      FirebaseDatabase.instance.ref('products');

  // Create a new order in Firebase
  Future<bool> createOrder(Order order) async {
    // Save the order first
    await _ref.child(order.orderId).set({
      'userId': order.userId,
      'productIds': order.productIds,
      'quantities': order.quantities,
      'totalAmount': order.totalAmount,
      'orderDate': order.orderDate.toIso8601String(),
      'address': {
        'street': order.address.street,
        'city': order.address.city,
        'state': order.address.state,
        'zipCode': order.address.zipCode,
        'country': order.address.country,
      },
    });

    // Reduce stock for each product
    for (int i = 0; i < order.productIds.length; i++) {
      String productId = order.productIds[i];
      int quantityOrdered = order.quantities[i];

      // Fetch current stock for the product
      final productSnapshot = await _productsRef.child(productId).get();
      //If the product exists, update the stock
      if (productSnapshot.exists) {
        final productData =
            Map<String, dynamic>.from(productSnapshot.value as dynamic);

        // Calculate new stock
        int currentStock = productData['stock'] ?? 0;
        // Calculate new stock after order
        int newStock = currentStock - quantityOrdered;

        // Prevents negative stock
        if (newStock < 0) newStock = 0;

        // Update the stock in Firebase
        await _productsRef.child(productId).update({
          'stock': newStock,
        });
      }
    }

    return true;
  }

// Fetches orders for a specific userId from Firebase
  Future<List<Order>> getOrders(String userId) async {
    final snapshot = await _ref.get();

    if (!snapshot.exists) return [];

    final data = Map<String, dynamic>.from(snapshot.value as dynamic);

    final List<Order> orders = [];

    data.forEach((key, value) {
      final orderData = Map<String, dynamic>.from(value);
// Only adds orders that match the current userId
      if (orderData['userId'] == userId) {
        orders.add(
          Order(
            orderId: key,
            userId: orderData['userId'],
            productIds: List<String>.from(orderData['productIds']),
            quantities: orderData['quantities'] != null
                ? List<int>.from(orderData['quantities'])
                : [],
            totalAmount: orderData['totalAmount'],
            orderDate: DateTime.parse(orderData['orderDate']),
            address: Address(
              street: orderData['address']['street'],
              city: orderData['address']['city'],
              state: orderData['address']['state'],
              zipCode: orderData['address']['zipCode'],
              country: orderData['address']['country'],
            ),
          ),
        );
      }
    });
// Returns the list of orders for the current user
    return orders;
  }

// Checks if an order can be cancelled (within 24 hours of placing the order)
  bool canCancelOrder(Order order) {
    final now = DateTime.now();
    final difference = now.difference(order.orderDate);
    return difference.inHours < 24;
  }

// Cancels an order by marking it as cancelled and restoring stock for the products in the order
  Future<void> cancelOrder(String orderId) async {
    final snapshot = await _ref.child(orderId).get();
    if (!snapshot.exists) return;

    final orderData = Map<String, dynamic>.from(snapshot.value as dynamic);

    // Checks if order is already cancelled to prevent duplicate cancellations
    if (orderData['isCancelled'] == true) {
      throw Exception('Order is already cancelled');
    }

    final List<String> productIds = List<String>.from(orderData['productIds']);
    final List<int> quantities = List<int>.from(orderData['quantities']);

    // Restores stock for each product
    for (int i = 0; i < productIds.length; i++) {
      final productId = productIds[i];
      final quantity = quantities[i];

      final productSnapshot = await _productsRef.child(productId).get();
      if (productSnapshot.exists) {
        final productData =
            Map<String, dynamic>.from(productSnapshot.value as dynamic);
        int currentStock = productData['stock'] ?? 0;
        await _productsRef
            .child(productId)
            .update({'stock': currentStock + quantity});
      }
    }

    // Marks order as cancelled
    await _ref.child(orderId).update({'isCancelled': true});
  }
}

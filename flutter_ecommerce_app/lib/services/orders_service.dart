import 'package:firebase_database/firebase_database.dart';
import '../models/order.dart';
import '../models/address.dart';

class OrdersService {
  static final OrdersService _instance = OrdersService._internal();
  factory OrdersService() => _instance;
  OrdersService._internal();

  // Firebase reference
  final DatabaseReference _ref = FirebaseDatabase.instance.ref('orders');

  // Create a new order in Firebase
  Future<bool> createOrder(Order order) async {
    await _ref.child(order.orderId).set({
      'userId': order.userId,
      'productIds': order.productIds,
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
}

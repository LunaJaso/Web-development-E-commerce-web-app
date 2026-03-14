import 'package:firebase_database/firebase_database.dart';
import '../models/order.dart';

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
    });
    return true;
  }
}
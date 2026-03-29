import 'address.dart';

// Class for orders
class Order {
  final String orderId;
  final String userId;
  final List<String> productIds;
  final List<int> quantities;
  final double totalAmount;
  final DateTime orderDate;
  final Address address;

  Order({
    required this.orderId,
    required this.userId,
    required this.productIds,
    required this.totalAmount,
    required this.orderDate,
    required this.address,
    this.quantities = const [],
  });
}
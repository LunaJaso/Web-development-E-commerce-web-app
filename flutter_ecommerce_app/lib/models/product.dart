// Class for every product
class Product {
  final String id;
  final String name;
  final double price;
  final String image;
  final String desc;

  Product({
    required this.id,
    required this.name,
    required this.price,
    required this.image,
    required this.desc,
  });

// Converts product data to a JSON for storage in Firebase
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'price': price,
      'image': image,
      'desc': desc,
    };
  }

// Converts data from Firebase into a Product object
  factory Product.fromMap(Map<String, dynamic> map, String id) {
    return Product(
      id: id,
      name: map['name'] as String? ?? '',
      price: (map['price'] is num)
          ? (map['price'] as num).toDouble()
          : double.tryParse('${map['price']}') ?? 0.0,
      image: map['image'] as String? ?? '',
      desc: map['desc'] as String? ?? '',
    );
  }
}

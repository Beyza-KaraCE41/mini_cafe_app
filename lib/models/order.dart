import 'product.dart';

class Order {
  final String id;
  final String userId;
  final List<Product> items;
  final double total;
  final DateTime orderDate;
  final String status;

  Order({
    required this.id,
    required this.userId,
    required this.items,
    required this.total,
    required this.orderDate,
    required this.status,
  });

  factory Order.fromFirestore(Map<String, dynamic> json) {
    List<Product> items = [];
    if (json['items'] != null && json['items'] is List) {
      items = (json['items'] as List).map((item) {
        return Product(
          id: item['id'] ?? '',
          name: item['name'] ?? '',
          price: item['price'] ?? 0,
          category: item['category'] ?? '',
          imagePath: item['imagePath'] ?? '',
          stock: 0,
          quantity: item['quantity'] ?? 0,
        );
      }).toList();
    }

    return Order(
      id: json['id'] ?? '',
      userId: json['userId'] ?? '',
      items: items,
      total: (json['total'] ?? 0).toDouble(),
      orderDate: json['orderDate'] != null
          ? DateTime.parse(json['orderDate'].toDate().toString())
          : DateTime.now(),
      status: json['status'] ?? 'Beklemede',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'items': items.map((item) => item.toJson()).toList(),
      'total': total,
      'orderDate': orderDate,
      'status': status,
    };
  }

  int getTotalItems() {
    return items.fold(0, (sum, item) => sum + item.quantity);
  }
}

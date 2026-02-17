import 'product.dart';

class Order {
  final String id;
  final String userId;
  final List<Product> items;
  final double total;
  final DateTime orderDate;
  String status;
  String? cargoNumber;

  Order({
    required this.id,
    required this.userId,
    required this.items,
    required this.total,
    required this.orderDate,
    required this.status,
    this.cargoNumber,
  });

  factory Order.fromFirestore(Map<String, dynamic> json, String docId) {
    List<Product> items = [];
    if (json['items'] != null && json['items'] is List) {
      items = (json['items'] as List).map((item) {
        return Product(
          id: item['productId'] ?? item['id'] ?? '',
          name: item['name'] ?? '',
          price: (item['price'] ?? 0).toDouble(),
          category: item['category'] ?? '',
          imagePath: item['imagePath'] ?? '',
          stock: item['stock'] ?? 0,
          quantity: item['quantity'] ?? 0,
        );
      }).toList();
    }

    return Order(
      id: docId,
      userId: json['userId'] ?? '',
      items: items,
      total: (json['total'] ?? 0).toDouble(),
      orderDate: json['orderDate'] != null
          ? json['orderDate'].toDate()
          : DateTime.now(),
      status: json['status'] ?? 'Beklemede',
      cargoNumber: json['cargoNumber'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'items': items
          .where((item) => item.quantity > 0)
          .map((item) => {
                'productId': item.id,
                'name': item.name,
                'price': item.price,
                'quantity': item.quantity,
              })
          .toList(),
      'total': total,
      'orderDate': orderDate,
      'status': status,
      'cargoNumber': cargoNumber ?? '',
    };
  }

  int getTotalItems() {
    return items.fold(0, (sum, item) => sum + item.quantity);
  }
}

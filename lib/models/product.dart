class Product {
  final String id;
  final String name;
  final int price;
  final String category;
  final String imagePath;
  final int stock;
  int quantity;

  Product({
    required this.id,
    required this.name,
    required this.price,
    required this.category,
    required this.imagePath,
    required this.stock,
    this.quantity = 0,
  });

  // Stok kontrolü
  bool get isOutOfStock => stock <= 0;

  factory Product.fromFirestore(Map<String, dynamic> json, String docId) {
    return Product(
      id: docId,
      name: json['name'] ?? '',
      price: json['price'] ?? 0,
      category: json['category'] ?? '',
      imagePath: json['imagePath'] ?? '',
      stock: json['stock'] ?? 0,
      quantity: 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'price': price,
      'category': category,
      'imagePath': imagePath,
      'stock': stock,
      'quantity': quantity,
    };
  }
}

List<Product> products = [
  Product(
    id: '1',
    name: 'Cappuccino',
    price: 85,
    category: 'Kahve',
    imagePath: 'assets/images/cappuccino.png',
    stock: 55,
  ),
  Product(
    id: '2',
    name: 'Türk Kahvesi',
    price: 65,
    category: 'Kahve',
    imagePath: 'assets/images/turk_kahvesi.png',
    stock: 50,
  ),
  Product(
    id: '3',
    name: 'Çay',
    price: 25,
    category: 'Çay',
    imagePath: 'assets/images/cay.png',
    stock: 60,
  ),
  Product(
    id: '4',
    name: 'Papatya Çayı',
    price: 35,
    category: 'Çay',
    imagePath: 'assets/images/papatya_cayi.png',
    stock: 85,
  ),
  Product(
    id: '5',
    name: 'Ihlamur',
    price: 30,
    category: 'Çay',
    imagePath: 'assets/images/ihlamur.png',
    stock: 80,
  ),
  Product(
    id: '6',
    name: 'Chai Tea Latte',
    price: 75,
    category: 'Kahve',
    imagePath: 'assets/images/chai_latte.png',
    stock: 90,
  ),
  Product(
    id: '7',
    name: 'Sütlaç',
    price: 45,
    category: 'Tatlı',
    imagePath: 'assets/images/sutlac.png',
    stock: 90,
  ),
  Product(
    id: '8',
    name: 'Supangle',
    price: 50,
    category: 'Tatlı',
    imagePath: 'assets/images/supangle.png',
    stock: 90,
  ),
  Product(
    id: '9',
    name: 'Trileçe',
    price: 55,
    category: 'Tatlı',
    imagePath: 'assets/images/trilece.png',
    stock: 95,
  ),
  Product(
    id: '10',
    name: 'San Sebastian Cheesecake',
    price: 95,
    category: 'Tatlı',
    imagePath: 'assets/images/cheesecake.png',
    stock: 140,
  ),
  Product(
    id: '11',
    name: 'Profiterol',
    price: 70,
    category: 'Tatlı',
    imagePath: 'assets/images/profiterol.png',
    stock: 125,
  ),
  Product(
    id: '12',
    name: 'Mozaik Pasta',
    price: 85,
    category: 'Tatlı',
    imagePath: 'assets/images/mozaik_pasta.png',
    stock: 160,
  ),
  Product(
    id: '13',
    name: 'Meyveli Pasta',
    price: 75,
    category: 'Tatlı',
    imagePath: 'assets/images/meyveli_pasta.png',
    stock: 70,
  ),
];

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
    name: 'Kahve',
    price: 150,
    category: 'İçecek',
    imagePath: 'assets/images/Kahve.png',
    stock: 50,
  ),
  Product(
    id: '2',
    name: 'Çay',
    price: 30,
    category: 'İçecek',
    imagePath: 'assets/images/Cay.png',
    stock: 60,
  ),
  Product(
    id: '3',
    name: 'Tatlı',
    price: 90,
    category: 'Tatlı',
    imagePath: 'assets/images/Tatli.png',
    stock: 45,
  ),
  Product(
    id: '4',
    name: 'Kahve',
    price: 165,
    category: 'Kahve',
    imagePath: 'assets/images/',
    stock: 55,
  ),
  Product(
    id: '5',
    name: 'Kahve',
    price: 135,
    category: 'İçecek',
    imagePath: 'assets7images/',
    stock: 60,
  ),
  Product(
    id: '6',
    name: 'Kahve',
    price: 125,
    category: 'İçecek',
    imagePath: 'assets/images/',
    stock: 70,
  ),
  Product(
    id: '7',
    name: 'Papatya Çayı',
    price: 160,
    category: 'İçecek',
    imagePath: 'assets/images/',
    stock: 85,
  ),
  Product(
    id: '8',
    name: 'Ihlamur',
    price: 65,
    category: 'İçecek',
    imagePath: 'assets/images',
    stock: 80,
  ),
  Product(
    id: '9',
    name: 'Chai Tea Latte',
    price: 170,
    category: 'İçecek',
    imagePath: 'assets/images/',
    stock: 90,
  ),
  Product(
    id: '10',
    name: 'Sütlaç',
    price: 80,
    category: 'Tatlı',
    imagePath: 'assets/images/',
    stock: 90,
  ),
  Product(
    id: '11',
    name: 'Supangle',
    price: 100,
    category: 'Tatlı',
    imagePath: 'assets/images/',
    stock: 90,
  ),
  Product(
    id: '12',
    name: 'Trileçe',
    price: 120,
    category: 'Tatlı',
    imagePath: 'assets/images/',
    stock: 95,
  ),
  Product(
    id: '13',
    name: 'Magnolia',
    price: 150,
    category: 'Tatlı',
    imagePath: 'assets/images/',
    stock: 95,
  ),
  Product(
    id: '14',
    name: 'Makaron',
    price: 130,
    category: 'Tatlı',
    imagePath: 'assets/images/',
    stock: 85,
  ),
  Product(
    id: '15',
    name: 'San Sebastian Cheesecake',
    price: 185,
    category: 'Tatlı',
    imagePath: 'assets/images/',
    stock: 140,
  ),
  Product(
    id: '16',
    name: 'Profiterol',
    price: 165,
    category: 'Tatlı',
    imagePath: 'assets/images/',
    stock: 125,
  ),
  Product(
    id: '17',
    name: 'Mozaik Pasta',
    price: 190,
    category: 'Tatlı',
    imagePath: 'assets/images/',
    stock: 160,
  ),
  Product(
    id: '18',
    name: 'Meyveli Pasta',
    price: 175,
    category: 'Tatlı',
    imagePath: 'assets/images/',
    stock: 70,
  ),
  Product(
    id: '11',
    name: 'Supangle',
    price: 100,
    category: 'Tatlı',
    imagePath: 'assets/images/',
    stock: 90,
  ),
];

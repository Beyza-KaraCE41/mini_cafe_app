import 'package:flutter/material.dart';
import '../models/product.dart';
import '../widgets/product_item.dart';
import '../services/auth_service.dart';
import 'cart_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String selectedCategory = 'Tümü';
  final AuthService _authService = AuthService();
  int cartItemCount = 0;

  @override
  Widget build(BuildContext context) {
    List<Product> displayedProducts = selectedCategory == 'Tümü'
        ? products
        : products.where((p) => p.category == selectedCategory).toList();

    cartItemCount = products.fold(0, (sum, item) => sum + item.quantity);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mini Cafe ☕',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24)),
        elevation: 0,
        centerTitle: false,
        actions: [
          Stack(
            children: [
              IconButton(
                icon: const Icon(Icons.shopping_cart, size: 28),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => CartScreen(cartItems: products)),
                  ).then((_) {
                    setState(() {
                      cartItemCount =
                          products.fold(0, (sum, item) => sum + item.quantity);
                    });
                  });
                },
              ),
              if (cartItemCount > 0)
                Positioned(
                  right: 6,
                  top: 6,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: Colors.red.shade600,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.red.withOpacity(0.4),
                          blurRadius: 8,
                        ),
                      ],
                    ),
                    constraints:
                        const BoxConstraints(minWidth: 24, minHeight: 24),
                    child: Center(
                      child: Text(
                        '$cartItemCount',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ),
            ],
          ),
          IconButton(
            icon: const Icon(Icons.logout, size: 24),
            onPressed: () => _showLogoutDialog(),
            tooltip: 'Çıkış Yap',
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFFFE0B2), Color(0xFFFFF8E1)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Column(
          children: [
            // Category Filter
            SizedBox(
              height: 60,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                children: ['Tümü', 'Kahve', 'İçecek', 'Tatlı'].map((category) {
                  bool isSelected = category == selectedCategory;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: GestureDetector(
                      onTap: () => setState(() => selectedCategory = category),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 8),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? Colors.brown.shade800
                              : Colors.white.withOpacity(0.6),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: isSelected
                                ? Colors.amber.shade400
                                : Colors.transparent,
                            width: 2,
                          ),
                          boxShadow: isSelected
                              ? [
                                  BoxShadow(
                                    color: Colors.brown.withOpacity(0.25),
                                    blurRadius: 12,
                                    offset: const Offset(0, 4),
                                  ),
                                ]
                              : [],
                        ),
                        child: Center(
                          child: Text(
                            category,
                            style: TextStyle(
                              color: isSelected
                                  ? Colors.white
                                  : Colors.brown.shade800,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),

            // Products Grid
            Expanded(
              child: displayedProducts.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.inventory_2_outlined,
                            size: 80,
                            color: Colors.brown.withOpacity(0.2),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Bu kategoride ürün yok',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w500,
                              color: Colors.brown.withOpacity(0.5),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '😔',
                            style: TextStyle(
                              fontSize: 32,
                              color: Colors.brown.withOpacity(0.3),
                            ),
                          ),
                        ],
                      ),
                    )
                  : GridView.builder(
                      padding: const EdgeInsets.all(16),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        mainAxisSpacing: 16,
                        crossAxisSpacing: 16,
                        childAspectRatio: 0.75,
                      ),
                      itemCount: displayedProducts.length,
                      itemBuilder: (context, index) {
                        final product = displayedProducts[index];
                        return ProductItem(
                          product: product,
                          onAdd: () {
                            setState(() {
                              if (product.quantity < product.stock) {
                                product.quantity++;
                              }
                            });
                          },
                          onRemove: () {
                            setState(() {
                              if (product.quantity > 0) {
                                product.quantity--;
                              }
                            });
                          },
                          onAddToCart: () {
                            setState(() {
                              cartItemCount = products.fold(
                                  0, (sum, item) => sum + item.quantity);
                            });
                          },
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(
          'Çıkış Yap',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
        ),
        content: const Text(
          'Çıkış yapmak istediğinizden emin misiniz?',
          style: TextStyle(fontSize: 16),
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        actionsPadding: const EdgeInsets.all(16),
        actions: [
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(
                  'İptal',
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  _authService.signOut();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red.shade600,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                ),
                child: const Text(
                  'Çıkış Yap',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

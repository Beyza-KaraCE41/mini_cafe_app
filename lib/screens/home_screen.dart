import 'package:flutter/material.dart';
import '../models/product.dart';
import '../widgets/product_item.dart';
import '../services/auth_service.dart';
import 'cart_screen.dart';
import 'favorites_screen.dart';
import 'orders_screen_user.dart';
import 'profile_screen.dart';
import 'login_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedNavIndex = 0;
  int _selectedCategoryIndex = 0;
  final AuthService _authService = AuthService();

  // Sepet ürünleri
  final List<Product> cartItems = [];

  final List<String> categories = ['Tümü', 'Kahve', 'Çay', 'Tatlı'];

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 600;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Mini Cafe ☕',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
        ),
        elevation: 2,
        actions: [
          // 🛒 CART BUTTON
          Stack(
            children: [
              IconButton(
                icon: const Icon(Icons.shopping_cart),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => CartScreen(cartItems: cartItems),
                    ),
                  );
                },
              ),
              if (cartItems.any((p) => p.quantity > 0))
                Positioned(
                  right: 8,
                  top: 8,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    constraints:
                        const BoxConstraints(minWidth: 20, minHeight: 20),
                    child: Text(
                      '${cartItems.fold<int>(0, (sum, p) => sum + p.quantity)}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
            ],
          ),
          // 🔴 LOGOUT
          IconButton(
            icon: const Icon(Icons.logout, size: 20),
            onPressed: _logout,
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
        child: _selectedNavIndex == 0
            ? _buildProductsScreen(isMobile)
            : _selectedNavIndex == 1
                ? const FavoritesScreen()
                : _selectedNavIndex == 2
                    ? const OrdersScreenUser()
                    : const ProfileScreen(),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedNavIndex,
        onTap: (index) => setState(() => _selectedNavIndex = index),
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Anasayfa',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite),
            label: 'Favoriler',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_bag),
            label: 'Siparişlerim',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.account_circle),
            label: 'Profil',
          ),
        ],
      ),
    );
  }

  Widget _buildProductsScreen(bool isMobile) {
    // Kategoriye göre filtrele
    List<Product> filteredProducts = _selectedCategoryIndex == 0
        ? products
        : products
            .where((p) => p.category == categories[_selectedCategoryIndex])
            .toList();

    return Column(
      children: [
        // 🏷️ KATEGORİ FİLTRELERİ
        SizedBox(
          height: 60,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            itemCount: categories.length,
            itemBuilder: (context, index) {
              final isSelected = _selectedCategoryIndex == index;
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: FilterChip(
                  label: Text(
                    categories[index],
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: isSelected ? Colors.white : Colors.brown,
                      fontSize: 12,
                    ),
                  ),
                  selected: isSelected,
                  onSelected: (selected) {
                    setState(() => _selectedCategoryIndex = index);
                  },
                  backgroundColor: Colors.white,
                  selectedColor: Colors.amber.shade700,
                  side: BorderSide(
                    color: isSelected
                        ? Colors.amber.shade700
                        : Colors.amber.shade200,
                    width: isSelected ? 2 : 1,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
              );
            },
          ),
        ),

        // 📦 ÜRÜNLER GRID
        Expanded(
          child: filteredProducts.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.search_off,
                        size: 80,
                        color: Colors.brown.withOpacity(0.2),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Bu kategoride ürün yok',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.brown,
                        ),
                      ),
                    ],
                  ),
                )
              : GridView.builder(
                  padding: const EdgeInsets.all(12),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: MediaQuery.of(context).size.width > 800
                        ? 4
                        : MediaQuery.of(context).size.width > 600
                            ? 3
                            : 2,
                    childAspectRatio: 0.75,
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                  ),
                  itemCount: filteredProducts.length,
                  itemBuilder: (context, index) {
                    final product = filteredProducts[index];
                    return ProductItem(
                      product: product,
                      onAdd: () {
                        setState(() => product.quantity++);
                      },
                      onRemove: () {
                        if (product.quantity > 0) {
                          setState(() => product.quantity--);
                        }
                      },
                      onAddToCart: () {
                        setState(() {});
                      },
                    );
                  },
                ),
        ),
      ],
    );
  }

  Future<void> _logout() async {
    try {
      await _authService.signOut();
      if (mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const LoginScreen()),
          (route) => false,
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Çıkış hatası: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}

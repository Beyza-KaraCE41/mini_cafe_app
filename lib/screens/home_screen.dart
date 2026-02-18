import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../services/firestore_service.dart';
import '../models/product.dart';
import '../widgets/product_item.dart';
import 'cart_screen.dart';
import 'favorites_screen.dart';
import 'orders_screen_user.dart';
import 'profile_screen.dart';
import 'login_screen.dart';

class HomeScreen extends StatefulWidget {
  final int initialIndex;

  const HomeScreen({super.key, this.initialIndex = 0});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late int _selectedNavIndex;
  int _selectedCategoryIndex = 0;
  final AuthService _authService = AuthService();
  final FirestoreService _firestoreService = FirestoreService();
  final List<String> categories = ['Tümü', 'Kahve', 'Çay', 'Tatlı'];

  List<String> _favoriteProductIds = [];
  int _favoriteCount = 0;
  bool _hasViewedFavorites = false; // YENİ: Rozeti kontrol etmek için

  @override
  void initState() {
    super.initState();
    _selectedNavIndex = (widget.initialIndex >= 0 && widget.initialIndex <= 3)
        ? widget.initialIndex
        : 0;
    _listenToFavorites();
  }

  void _listenToFavorites() {
    final user = _authService.currentUser;
    if (user != null) {
      try {
        _firestoreService.getUserFavorites(user.uid).listen((snapshot) {
          if (mounted) {
            setState(() {
              _favoriteCount = snapshot.docs.length;
              _favoriteProductIds = snapshot.docs.map((doc) => doc.id).toList();

              // Eğer yeni favori eklendiyse ve şu an favoriler ekranında değilsek, rozeti tekrar yak
              if (_selectedNavIndex != 1) {
                _hasViewedFavorites = false;
              }
            });
          }
        });
      } catch (e) {
        print('Favori sayısı yükleme hatası: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 600;
    final cartCount = products.fold<int>(0, (sum, p) => sum + p.quantity);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Mini Cafe ☕',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
        ),
        elevation: 2,
        actions: [
          Stack(
            children: [
              IconButton(
                icon: const Icon(Icons.shopping_cart),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => CartScreen(
                        cartItems:
                            products.where((p) => p.quantity > 0).toList(),
                      ),
                    ),
                  ).then((_) {
                    setState(() {});
                  });
                },
              ),
              if (cartCount > 0)
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
                      '$cartCount',
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
        onTap: (index) {
          setState(() {
            _selectedNavIndex = index;
            // Favoriler sekmesine (index 1) tıklandıysa, görüldü yap
            if (index == 1) {
              _hasViewedFavorites = true;
            }
          });
        },
        type: BottomNavigationBarType.fixed,
        items: [
          const BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Anasayfa',
          ),
          BottomNavigationBarItem(
            icon: Stack(
              children: [
                const Icon(Icons.favorite),
                // Rozet mantığı: Sayı > 0 VE Henüz bakılmadıysa göster
                if (_favoriteCount > 0 &&
                    !_hasViewedFavorites &&
                    _selectedNavIndex != 1)
                  Positioned(
                    right: -2,
                    top: -2,
                    child: Container(
                      padding: const EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      constraints:
                          const BoxConstraints(minWidth: 16, minHeight: 16),
                      child: Text(
                        '$_favoriteCount',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
              ],
            ),
            label: 'Favoriler',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.shopping_bag),
            label: 'Siparişlerim',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.account_circle),
            label: 'Profil',
          ),
        ],
      ),
    );
  }

  Widget _buildProductsScreen(bool isMobile) {
    List<Product> filteredProducts = _selectedCategoryIndex == 0
        ? products
        : products
            .where((p) => p.category == categories[_selectedCategoryIndex])
            .toList();

    return Column(
      children: [
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
                    crossAxisCount: isMobile ? 2 : 3,
                    childAspectRatio: 0.75,
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                  ),
                  itemCount: filteredProducts.length,
                  itemBuilder: (context, index) {
                    final product = filteredProducts[index];
                    final isFavorite = _favoriteProductIds.contains(product.id);

                    return ProductItem(
                      product: product,
                      isInitialFavorite: isFavorite,
                      firestoreService: _firestoreService,
                      onAdd: () {
                        setState(() {
                          product.quantity++;
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
                        setState(() {});
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              '${product.name} x${product.quantity} sepete eklendi ☕',
                              style: const TextStyle(fontSize: 13),
                            ),
                            duration: const Duration(seconds: 2),
                            backgroundColor: Colors.green.shade600,
                            behavior: SnackBarBehavior.floating,
                            margin: const EdgeInsets.all(8),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        );
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
      for (var product in products) {
        product.quantity = 0;
      }

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

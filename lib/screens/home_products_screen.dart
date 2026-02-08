import 'package:flutter/material.dart';
import '../models/product.dart';
import '../widgets/product_item.dart';

class HomeProductsScreen extends StatefulWidget {
  const HomeProductsScreen({super.key});

  @override
  State<HomeProductsScreen> createState() => _HomeProductsScreenState();
}

class _HomeProductsScreenState extends State<HomeProductsScreen> {
  // Tüm kategoriler - Sadece 3 ana kategori
  final List<String> categories = ['Tümü', 'Kahve', 'Çay', 'Tatlı'];
  String _selectedCategory = 'Tümü';

  @override
  Widget build(BuildContext context) {
    // Seçili kategoriye göre ürünleri filtrele
    List<Product> filteredProducts = _selectedCategory == 'Tümü'
        ? products
        : products.where((p) => p.category == _selectedCategory).toList();

    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFFFFE0B2), Color(0xFFFFF8E1)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: Column(
        children: [
          // Kategori Filtreleri
          SizedBox(
            height: 60,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              itemCount: categories.length,
              itemBuilder: (context, index) {
                final category = categories[index];
                final isSelected = _selectedCategory == category;

                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    label: Text(
                      category,
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: isSelected ? Colors.white : Colors.brown,
                        fontSize: 13,
                      ),
                    ),
                    selected: isSelected,
                    onSelected: (selected) {
                      setState(() => _selectedCategory = category);
                    },
                    backgroundColor: Colors.white,
                    selectedColor: Colors.amber.shade700,
                    side: BorderSide(
                      color: isSelected
                          ? Colors.amber.shade700
                          : Colors.amber.shade200,
                      width: 1.5,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                );
              },
            ),
          ),

          // Ürünler Listesi
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
                            fontWeight: FontWeight.w500,
                            color: Colors.brown,
                          ),
                        ),
                      ],
                    ),
                  )
                : GridView.builder(
                    padding: const EdgeInsets.all(12),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount:
                          MediaQuery.of(context).size.width > 600 ? 3 : 2,
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
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                '${product.name} sepete eklendi ☕',
                                style: const TextStyle(fontSize: 12),
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
      ),
    );
  }
}

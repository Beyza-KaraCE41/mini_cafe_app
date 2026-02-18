import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/firestore_service.dart';
import '../models/product.dart'; // Global products listesini kullanmak için ekledik

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  final FirestoreService _firestoreService = FirestoreService();

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.lock_outline,
                size: 80, color: Colors.brown.withOpacity(0.2)),
            const SizedBox(height: 16),
            const Text('Giriş yapmanız gerekiyor'),
          ],
        ),
      );
    }

    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFFFFE0B2), Color(0xFFFFF8E1)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: StreamBuilder(
        stream: _firestoreService.getUserFavorites(user.uid),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.favorite_outline,
                      size: 100, color: Colors.brown.withOpacity(0.2)),
                  const SizedBox(height: 24),
                  const Text('Henüz Favori Yok',
                      style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.brown)),
                  const SizedBox(height: 12),
                  Text('Beğendiğin ürünleri favorilere ekle ❤️',
                      style: TextStyle(
                          fontSize: 14, color: Colors.brown.withOpacity(0.6))),
                ],
              ),
            );
          }

          final favorites = snapshot.data!.docs;

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: favorites.length,
            itemBuilder: (context, index) {
              final favDoc = favorites[index];
              final favData = favDoc.data() as Map<String, dynamic>;

              // Firestore'daki ID
              final productId = favDoc.id;

              // 🛠️ DÜZELTME: Canlı veriyi Global 'products' listesinden buluyoruz
              // Eğer global listede bulamazsa (silinmişse) favorideki eski veriyi kullanır.
              Product product;
              try {
                product = products.firstWhere((p) => p.id == productId);
              } catch (e) {
                // Ürün global listeden silinmişse favorideki yedek veriyi kullan
                product = Product(
                  id: productId,
                  name: favData['name'] ?? 'Bilinmeyen Ürün',
                  price: favData['price'] ?? 0,
                  category: favData['category'] ?? '',
                  imagePath: favData['imagePath'] ?? '',
                  stock: favData['stock'] ?? 0,
                );
              }

              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                    side: BorderSide(color: Colors.red.shade200, width: 1.5),
                  ),
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    child: Row(
                      children: [
                        // 🖼️ RESİM DÜZELTMESİ
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Container(
                            width: 80,
                            height: 80,
                            color: Colors.grey.shade100,
                            child: Image.asset(
                              product.imagePath,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return const Icon(Icons.coffee,
                                    size: 40, color: Colors.grey);
                              },
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),

                        // BİLGİLER
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(product.name,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                      color: Colors.brown),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis),
                              const SizedBox(height: 4),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                    color: Colors.amber.shade100,
                                    borderRadius: BorderRadius.circular(6)),
                                child: Text(product.category,
                                    style: TextStyle(
                                        fontSize: 10,
                                        color: Colors.brown.shade700,
                                        fontWeight: FontWeight.w600)),
                              ),
                              const SizedBox(height: 8),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text('${product.price} TL',
                                      style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.amber.shade700)),

                                  // 📦 CANLI STOK GÖSTERİMİ
                                  Text(
                                      product.stock == 0
                                          ? 'Tükendi'
                                          : 'Stok: ${product.stock}',
                                      style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                          color: product.stock == 0
                                              ? Colors.red
                                              : Colors.grey.shade600)),
                                ],
                              ),
                            ],
                          ),
                        ),

                        // SİLME BUTONU
                        IconButton(
                          icon: Icon(Icons.delete_outline,
                              color: Colors.red.shade400, size: 28),
                          onPressed: () {
                            _firestoreService.removeFavorite(
                                user.uid, productId);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                  content: Text(
                                      '${product.name} favorilerden kaldırıldı'),
                                  backgroundColor: Colors.red.shade600,
                                  duration: const Duration(seconds: 1)),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

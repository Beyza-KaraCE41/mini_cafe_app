import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/product.dart';
import '../services/firestore_service.dart';

class ProductItem extends StatefulWidget {
  final Product product;
  final VoidCallback onAdd;
  final VoidCallback onRemove;
  final VoidCallback? onAddToCart;
  final FirestoreService? firestoreService;
  final bool isInitialFavorite; // YENİ PARAMETRE

  const ProductItem({
    super.key,
    required this.product,
    required this.onAdd,
    required this.onRemove,
    this.onAddToCart,
    this.firestoreService,
    this.isInitialFavorite = false, // Varsayılan false
  });

  @override
  State<ProductItem> createState() => _ProductItemState();
}

class _ProductItemState extends State<ProductItem> {
  bool _isHovered = false;
  late bool _isFavorite; // late olarak tanımladık

  @override
  void initState() {
    super.initState();
    // Başlangıç değerini home_screen'den gelen bilgiye göre ayarla
    _isFavorite = widget.isInitialFavorite;
  }

  // Parent rebuild olduğunda favori durumunu güncelle
  @override
  void didUpdateWidget(covariant ProductItem oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isInitialFavorite != oldWidget.isInitialFavorite) {
      _isFavorite = widget.isInitialFavorite;
    }
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: Colors.brown.withOpacity(_isHovered ? 0.4 : 0.18),
              blurRadius: _isHovered ? 28 : 14,
              spreadRadius: _isHovered ? 4 : 0,
              offset: Offset(0, _isHovered ? 14 : 6),
            ),
          ],
        ),
        child: Card(
          elevation: 0,
          color: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
            side: BorderSide(
              color: _isHovered ? Colors.amber.shade500 : Colors.amber.shade100,
              width: _isHovered ? 3 : 1.5,
            ),
          ),
          child: AnimatedScale(
            scale: _isHovered ? 1.04 : 1.0,
            duration: const Duration(milliseconds: 300),
            child: Column(
              children: [
                // IMAGE SECTION
                ClipRRect(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(18),
                    topRight: Radius.circular(18),
                  ),
                  child: Stack(
                    children: [
                      Container(
                        height: 110,
                        width: double.infinity,
                        color: Colors.grey.shade200,
                        child: Image.asset(
                          widget.product.imagePath,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              color: Colors.amber.shade300,
                              child: Center(
                                child: Icon(
                                  Icons.coffee,
                                  size: 40,
                                  color: Colors.white.withOpacity(0.7),
                                ),
                              ),
                            );
                          },
                        ),
                      ),

                      // FAVORITE BUTTON
                      Positioned(
                        top: 8,
                        left: 8,
                        child: GestureDetector(
                          onTap: () async {
                            final user = FirebaseAuth.instance.currentUser;

                            if (user == null) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Giriş yapmanız gerekiyor'),
                                  backgroundColor: Colors.red,
                                ),
                              );
                              return;
                            }

                            // Optimistik UI Update (Hemen tepki ver)
                            setState(() => _isFavorite = !_isFavorite);

                            try {
                              if (!_isFavorite) {
                                // Ters mantık çünkü yukarıda değiştirdik
                                await widget.firestoreService!.removeFavorite(
                                    user.uid, widget.product.id);
                              } else {
                                await widget.firestoreService!.addFavorite(
                                  user.uid,
                                  widget.product.id,
                                  widget.product,
                                );
                              }
                            } catch (e) {
                              // Hata olursa geri al
                              setState(() => _isFavorite = !_isFavorite);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Hata: $e')),
                              );
                            }
                          },
                          child: Container(
                            width: 32,
                            height: 32,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(10),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.15),
                                  blurRadius: 6,
                                ),
                              ],
                            ),
                            child: Icon(
                              _isFavorite
                                  ? Icons.favorite
                                  : Icons.favorite_outline,
                              color: Colors.red.shade400,
                              size: 18,
                            ),
                          ),
                        ),
                      ),

                      // OUT OF STOCK
                      if (widget.product.stock == 0)
                        Container(
                          color: Colors.black.withOpacity(0.5),
                          child: Center(
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.red.shade600,
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: const Text('Tükendi',
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 11)),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),

                // CONTENT SECTION
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Flexible(
                          child: Text(
                            widget.product.name,
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: Colors.brown,
                              height: 1.1,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Text(
                          '${widget.product.price.toStringAsFixed(0)} TL',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: Colors.amber.shade700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // ACTION BUTTON
                Padding(
                  padding: const EdgeInsets.all(6),
                  child: SizedBox(
                    height: 34,
                    child: widget.product.quantity == 0
                        ? SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              onPressed: widget.product.stock > 0
                                  ? () {
                                      widget.onAdd();
                                      widget.onAddToCart?.call();
                                    }
                                  : null,
                              icon:
                                  const Icon(Icons.add_shopping_cart, size: 12),
                              label: const Text('Ekle',
                                  style: TextStyle(fontSize: 10)),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.amber.shade700,
                                foregroundColor: Colors.white,
                                disabledBackgroundColor: Colors.grey.shade400,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                elevation: 0,
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 6, vertical: 2),
                              ),
                            ),
                          )
                        : Container(
                            decoration: BoxDecoration(
                              color: Colors.amber.shade50,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: Colors.amber.shade300,
                                width: 1,
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                GestureDetector(
                                  onTap: widget.onRemove,
                                  child: Icon(
                                    Icons.remove_circle_outline,
                                    color: Colors.brown.shade700,
                                    size: 16,
                                  ),
                                ),
                                Container(
                                  width: 24,
                                  height: 24,
                                  decoration: BoxDecoration(
                                    color: Colors.amber.shade700,
                                    borderRadius: BorderRadius.circular(3),
                                  ),
                                  child: Center(
                                    child: Text(
                                      '${widget.product.quantity}',
                                      style: const TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ),
                                GestureDetector(
                                  onTap: widget.product.quantity <
                                          widget.product.stock
                                      ? () {
                                          widget.onAdd();
                                          widget.onAddToCart?.call();
                                        }
                                      : null,
                                  child: Icon(
                                    Icons.add_circle,
                                    color: widget.product.quantity <
                                            widget.product.stock
                                        ? Colors.amber.shade700
                                        : Colors.grey,
                                    size: 16,
                                  ),
                                ),
                              ],
                            ),
                          ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

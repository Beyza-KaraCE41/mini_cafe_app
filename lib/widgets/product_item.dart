import 'package:flutter/material.dart';
import '../models/product.dart';

class ProductItem extends StatefulWidget {
  final Product product;
  final VoidCallback onAdd;
  final VoidCallback onRemove;
  final VoidCallback? onAddToCart;

  const ProductItem({
    super.key,
    required this.product,
    required this.onAdd,
    required this.onRemove,
    this.onAddToCart,
  });

  @override
  State<ProductItem> createState() => _ProductItemState();
}

class _ProductItemState extends State<ProductItem> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.brown.withOpacity(_isHovered ? 0.35 : 0.15),
              blurRadius: _isHovered ? 25 : 12,
              spreadRadius: _isHovered ? 3 : 0,
              offset: Offset(0, _isHovered ? 12 : 6),
            ),
          ],
        ),
        child: Card(
          elevation: 0,
          color: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
            side: BorderSide(
              color: Colors.amber.shade300.withOpacity(_isHovered ? 0.8 : 0.3),
              width: _isHovered ? 2 : 1,
            ),
          ),
          child: AnimatedScale(
            scale: _isHovered ? 1.03 : 1.0,
            duration: const Duration(milliseconds: 300),
            child: Column(
              children: [
                // Image Section
                ClipRRect(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(24),
                    topRight: Radius.circular(24),
                  ),
                  child: Stack(
                    children: [
                      Container(
                        height: 180,
                        width: double.infinity,
                        color: Colors.grey.shade200,
                        child: Image.asset(
                          widget.product.imagePath,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Center(
                              child: Icon(
                                Icons.image_not_supported,
                                size: 50,
                                color: Colors.grey.shade400,
                              ),
                            );
                          },
                        ),
                      ),
                      // Stock Badge
                      Positioned(
                        top: 12,
                        right: 12,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: widget.product.stock > 0
                                ? Colors.green.shade600
                                : Colors.red.shade600,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.2),
                                blurRadius: 8,
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                widget.product.stock > 0
                                    ? Icons.check_circle
                                    : Icons.block,
                                color: Colors.white,
                                size: 14,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                widget.product.stock > 0
                                    ? 'Stok: ${widget.product.stock}'
                                    : 'Tükendi',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Content Section
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Product Name
                        Text(
                          widget.product.name,
                          style: const TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                            color: Colors.brown,
                            height: 1.2,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 8),

                        // Category
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.amber.shade100,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            widget.product.category,
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.brown.shade800,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),

                        const Spacer(),

                        // Price
                        Text(
                          '${widget.product.price} TL',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.amber.shade700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Action Button Section
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: widget.product.quantity == 0
                      ? SizedBox(
                          width: double.infinity,
                          height: 44,
                          child: ElevatedButton.icon(
                            onPressed: widget.product.stock > 0
                                ? () {
                                    widget.onAdd();
                                    widget.onAddToCart?.call();
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          '${widget.product.name} sepete eklendi! ☕',
                                        ),
                                        duration: const Duration(seconds: 2),
                                        backgroundColor: Colors.green.shade600,
                                        behavior: SnackBarBehavior.floating,
                                        margin: const EdgeInsets.all(12),
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(12),
                                        ),
                                      ),
                                    );
                                  }
                                : null,
                            icon: const Icon(Icons.add_shopping_cart),
                            label: const Text('Sepete Ekle'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.amber.shade700,
                              foregroundColor: Colors.white,
                              disabledBackgroundColor: Colors.grey.shade400,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: 0,
                            ),
                          ),
                        )
                      : Container(
                          decoration: BoxDecoration(
                            color: Colors.amber.shade50,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: Colors.amber.shade300,
                              width: 1.5,
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              IconButton(
                                icon: Icon(
                                  Icons.remove_circle_outline,
                                  color: Colors.brown.shade700,
                                  size: 24,
                                ),
                                onPressed: widget.onRemove,
                                splashRadius: 20,
                              ),
                              Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  color: Colors.amber.shade700,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Center(
                                  child: Text(
                                    '${widget.product.quantity}',
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                              IconButton(
                                icon: Icon(
                                  Icons.add_circle,
                                  color: Colors.amber.shade700,
                                  size: 24,
                                ),
                                onPressed: widget.product.quantity <
                                        widget.product.stock
                                    ? widget.onAdd
                                    : null,
                                splashRadius: 20,
                              ),
                            ],
                          ),
                        ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}

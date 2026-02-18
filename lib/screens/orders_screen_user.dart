import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/order.dart' as order_model;
import '../models/product.dart'; // Resimleri bulmak için ekledik
import '../services/firestore_service.dart';

class OrdersScreenUser extends StatefulWidget {
  const OrdersScreenUser({super.key});

  @override
  State<OrdersScreenUser> createState() => _OrdersScreenUserState();
}

class _OrdersScreenUserState extends State<OrdersScreenUser> {
  final FirestoreService _firestoreService = FirestoreService();

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.lock_outline,
                  size: 80, color: Colors.brown.withOpacity(0.2)),
              const SizedBox(height: 16),
              const Text('Giriş yapmanız gerekiyor'),
            ],
          ),
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
      child: StreamBuilder<List<order_model.Order>>(
        stream: _firestoreService.getUserOrders(user.uid),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return const Center(child: Text('Bir hata oluştu'));
          }

          final orders = snapshot.data ?? [];

          if (orders.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.inbox_outlined,
                      size: 100, color: Colors.brown.withOpacity(0.15)),
                  const SizedBox(height: 24),
                  const Text('Henüz Sipariş Yok',
                      style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.brown)),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: orders.length,
            itemBuilder: (context, index) {
              final order = orders[index];
              return _buildOrderCard(order);
            },
          );
        },
      ),
    );
  }

  Widget _buildOrderCard(order_model.Order order) {
    Color statusColor = _getStatusColor(order.status);
    IconData statusIcon = _getStatusIcon(order.status);

    String orderId = order.id.length > 8
        ? order.id.substring(0, 8).toUpperCase()
        : order.id.toUpperCase();

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: statusColor.withOpacity(0.3), width: 1.5),
        ),
        child: ExpansionTile(
          leading: Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(statusIcon, color: statusColor, size: 24),
          ),
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Sipariş #$orderId',
                  style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Colors.brown)),
              Text(_formatDate(order.orderDate),
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
            ],
          ),
          trailing: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.15),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(order.status,
                style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: statusColor)),
          ),
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Column(
                children: [
                  const Divider(),
                  // 🛒 ÜRÜN LİSTESİ (RESİMLİ)
                  ...order.items.map((item) {
                    // Ürün isminden veya ID'den global ürünü bulmaya çalışıyoruz
                    // (Sipariş geçmişinde productId varsa onu kullanmak en doğrusudur,
                    // yoksa isimden eşleştirmeye çalışıyoruz)
                    Product? matchedProduct;
                    try {
                      // Önce isme göre deneyelim (basit çözüm)
                      matchedProduct =
                          products.firstWhere((p) => p.name == item.name);
                    } catch (e) {
                      matchedProduct = null;
                    }

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8, top: 8),
                      child: Row(
                        children: [
                          // 🖼️ ÜRÜN RESMİ
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Container(
                              width: 40,
                              height: 40,
                              color: Colors.grey.shade200,
                              child: matchedProduct != null
                                  ? Image.asset(matchedProduct.imagePath,
                                      fit: BoxFit.cover)
                                  : const Icon(Icons.coffee,
                                      size: 20, color: Colors.grey),
                            ),
                          ),
                          const SizedBox(width: 12),

                          // İSİM VE ADET
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(item.name,
                                    style: const TextStyle(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 14)),
                                Text('${item.quantity} adet x ${item.price} TL',
                                    style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey.shade600)),
                              ],
                            ),
                          ),

                          // TOPLAM FİYAT
                          Text(
                              '${(item.price * item.quantity).toStringAsFixed(0)} TL',
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.brown)),
                        ],
                      ),
                    );
                  }).toList(),

                  const Divider(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Toplam Tutar',
                          style: TextStyle(fontWeight: FontWeight.bold)),
                      Text('${order.total.toStringAsFixed(2)} TL',
                          style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: Colors.green)),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}.${date.month.toString().padLeft(2, '0')}.${date.year} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Beklemede':
        return Colors.orange;
      case 'Hazırlanıyor':
        return Colors.blue;
      case 'Hazır':
        return Colors.purple;
      case 'Teslim Edildi':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status) {
      case 'Beklemede':
        return Icons.schedule;
      case 'Hazırlanıyor':
        return Icons.local_cafe;
      case 'Hazır':
        return Icons.done;
      case 'Teslim Edildi':
        return Icons.check_circle;
      default:
        return Icons.info;
    }
  }
}

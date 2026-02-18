import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/order.dart' as order_model;
import '../models/product.dart'; // Global products listesi
import '../services/firestore_service.dart';

class OrdersScreenUser extends StatefulWidget {
  const OrdersScreenUser({super.key});

  @override
  State<OrdersScreenUser> createState() => _OrdersScreenUserState();
}

class _OrdersScreenUserState extends State<OrdersScreenUser> {
  final FirestoreService _firestoreService = FirestoreService();

  // İptal İşlemi
  void _cancelOrder(String orderId) async {
    bool? confirm = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Siparişi İptal Et'),
        content:
            const Text('Siparişinizi iptal etmek istediğinize emin misiniz?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Hayır')),
          TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Evet, İptal Et',
                  style: TextStyle(color: Colors.red))),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await _firestoreService.cancelOrder(orderId);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Sipariş iptal edildi.')));
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context)
              .showSnackBar(SnackBar(content: Text('Hata: $e')));
        }
      }
    }
  }

  // İade İşlemi
  void _requestReturn(String orderId) async {
    bool? confirm = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('İade Talebi'),
        content: const Text(
            'Bu sipariş için iade talebi oluşturmak istiyor musunuz?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Vazgeç')),
          TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('İade Et')),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await _firestoreService.requestReturn(orderId);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text(
                    'İade talebi alındı. Kod: TR-IADE-${orderId.substring(0, 4)}')),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context)
              .showSnackBar(SnackBar(content: Text('Hata: $e')));
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return const Center(child: Text('Giriş yapmanız gerekiyor'));
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
            return const Center(
                child: Text('Henüz sipariş yok',
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.brown)));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: orders.length,
            itemBuilder: (context, index) {
              return _buildOrderCard(orders[index]);
            },
          );
        },
      ),
    );
  }

  Widget _buildOrderCard(order_model.Order order) {
    Color statusColor = _getStatusColor(order.status);
    IconData statusIcon = _getStatusIcon(order.status);
    String orderIdShort =
        order.id.length > 8 ? order.id.substring(0, 8).toUpperCase() : order.id;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: ExpansionTile(
          leading: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
                color: statusColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10)),
            child: Icon(statusIcon, color: statusColor),
          ),
          title: Text('Sipariş #$orderIdShort',
              style: const TextStyle(
                  fontWeight: FontWeight.bold, color: Colors.brown)),
          subtitle: Text(_formatDate(order.orderDate),
              style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
          trailing: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
                color: statusColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12)),
            child: Text(order.status,
                style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: statusColor)),
          ),
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  ...order.items.map((item) {
                    // GÖRSEL EŞLEŞTİRME MANTIĞI
                    // 1. Önce ID'ye göre bulmaya çalış, 2. Bulamazsan isme göre bul, 3. Hiçbiri yoksa null
                    Product? matchedProduct;
                    try {
                      matchedProduct =
                          products.firstWhere((p) => p.name == item.name);
                    } catch (e) {
                      matchedProduct = null;
                    }

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Row(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: SizedBox(
                              width: 50,
                              height: 50,
                              child: matchedProduct != null
                                  ? Image.asset(matchedProduct.imagePath,
                                      fit: BoxFit.cover)
                                  : const Icon(Icons.fastfood,
                                      color: Colors.grey),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(item.name,
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold)),
                                Text(
                                    '${item.quantity} adet x ${item.price} TL'),
                              ],
                            ),
                          ),
                          Text(
                              '${(item.quantity * item.price).toStringAsFixed(0)} TL',
                              style:
                                  const TextStyle(fontWeight: FontWeight.bold)),
                        ],
                      ),
                    );
                  }).toList(),
                  const Divider(),

                  // KARGO BİLGİSİ (Varsa Göster)
                  if (order.cargoNumber != null &&
                      order.cargoNumber!.isNotEmpty)
                    Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                          color: Colors.blue.shade50,
                          borderRadius: BorderRadius.circular(8)),
                      child: Row(
                        children: [
                          const Icon(Icons.local_shipping, color: Colors.blue),
                          const SizedBox(width: 10),
                          Expanded(
                              child: Text('Kargo No: ${order.cargoNumber}',
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.blue))),
                        ],
                      ),
                    ),

                  // AKSİYON BUTONLARI (Duruma göre çıkar)
                  if (order.status == 'Beklemede')
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: () => _cancelOrder(order.id),
                        icon: const Icon(Icons.cancel, size: 18),
                        label: const Text('Siparişi İptal Et'),
                        style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.red,
                            side: const BorderSide(color: Colors.red)),
                      ),
                    ),

                  if (order.status == 'Teslim Edildi')
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: () => _requestReturn(order.id),
                        icon: const Icon(Icons.assignment_return, size: 18),
                        label: const Text('İade Talebi Oluştur'),
                        style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.orange,
                            side: const BorderSide(color: Colors.orange)),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) => '${date.day}.${date.month}.${date.year}';

  Color _getStatusColor(String status) {
    if (status == 'Beklemede') return Colors.orange;
    if (status == 'Hazırlanıyor') return Colors.blue;
    if (status == 'Hazır') return Colors.purple;
    if (status == 'Teslim Edildi') return Colors.green;
    if (status == 'İptal Edildi') return Colors.red;
    return Colors.grey;
  }

  IconData _getStatusIcon(String status) {
    if (status == 'Beklemede') return Icons.access_time;
    if (status == 'Hazırlanıyor') return Icons.microwave;
    if (status == 'Hazır') return Icons.check;
    if (status == 'Teslim Edildi') return Icons.home;
    if (status == 'İptal Edildi') return Icons.cancel;
    return Icons.info;
  }
}

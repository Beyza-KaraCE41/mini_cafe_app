import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/product.dart';
import '../models/order.dart' as order_model;

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Ürünleri getir
  Future<List<Product>> getProducts() async {
    try {
      QuerySnapshot querySnapshot =
          await _firestore.collection('products').get();

      return querySnapshot.docs
          .map((doc) {
            try {
              final data = doc.data();
              if (data is! Map<String, dynamic>) {
                return null;
              }
              return Product.fromFirestore(data, doc.id);
            } catch (e) {
              print('Ürün parsing hatası: $e');
              return null;
            }
          })
          .whereType<Product>()
          .toList();
    } catch (e) {
      throw Exception('Ürünleri getirme hatası: $e');
    }
  }

  // Sipariş oluştur
  Future<void> createOrder(
    String userId,
    List<Product> cartItems,
    double total,
  ) async {
    try {
      // Boş sepet kontrolü
      if (cartItems.isEmpty) {
        throw Exception('Sepet boş, sipariş oluşturulamaz');
      }

      // Sipariş ID'si
      String orderId = DateTime.now().millisecondsSinceEpoch.toString();

      // Ürün verilerini hazırla
      List<Map<String, dynamic>> itemsData = [];
      for (var item in cartItems) {
        if (item.quantity > 0) {
          itemsData.add({
            'id': item.id,
            'name': item.name,
            'price': item.price,
            'quantity': item.quantity,
            'category': item.category,
            'imagePath': item.imagePath,
          });
        }
      }

      // Sipariş verisini oluştur
      Map<String, dynamic> orderData = {
        'id': orderId,
        'userId': userId,
        'items': itemsData,
        'total': total,
        'orderDate': FieldValue.serverTimestamp(),
        'status': 'Beklemede',
        'createdAt': FieldValue.serverTimestamp(),
      };

      // Firestore'a kaydet
      await _firestore.collection('orders').doc(orderId).set(orderData);

      print('Sipariş başarıyla oluşturuldu: $orderId');
    } catch (e) {
      throw Exception('Sipariş oluşturma hatası: $e');
    }
  }

  // Kullanıcının siparişlerini al (Stream) - orderBy kaldırıldı
  Stream<List<order_model.Order>> getUserOrders(String userId) {
    try {
      return _firestore
          .collection('orders')
          .where('userId', isEqualTo: userId)
          .snapshots()
          .map((snapshot) {
        print('📦 Siparişler yüklendi: ${snapshot.docs.length} adet');

        // Siparişleri tarihe göre sırala (client-side)
        final orders = snapshot.docs
            .map((doc) {
              try {
                final data = doc.data();
                return order_model.Order.fromFirestore(data);
              } catch (e) {
                print('❌ Sipariş parsing hatası: $e');
                return null;
              }
            })
            .whereType<order_model.Order>()
            .toList();

        // En yeni siparışları öne al
        orders.sort((a, b) => b.orderDate.compareTo(a.orderDate));
        return orders;
      }).handleError((error) {
        print('🔴 Sipariş stream hatası: $error');
        throw Exception('Siparişleri yükleyemedi: $error');
      });
    } catch (e) {
      print('🔴 Stream oluşturma hatası: $e');
      throw Exception('Stream oluşturma hatası: $e');
    }
  }

  // Sipariş durumunu güncelle
  Future<void> updateOrderStatus(String orderId, String newStatus) async {
    try {
      await _firestore.collection('orders').doc(orderId).update({
        'status': newStatus,
        'updatedAt': FieldValue.serverTimestamp(),
      });
      print('Sipariş durumu güncellendi: $orderId -> $newStatus');
    } catch (e) {
      throw Exception('Sipariş durumu güncelleme hatası: $e');
    }
  }

  // Tüm siparişleri getir (Admin için)
  Stream<List<order_model.Order>> getAllOrders() {
    try {
      return _firestore
          .collection('orders')
          .orderBy('orderDate', descending: true)
          .snapshots()
          .map((snapshot) {
        return snapshot.docs
            .map((doc) {
              try {
                final data = doc.data();
                return order_model.Order.fromFirestore(data);
              } catch (e) {
                print('Sipariş parsing hatası: $e');
                return null;
              }
            })
            .whereType<order_model.Order>()
            .toList();
      });
    } catch (e) {
      throw Exception('Tüm siparişler alınamadı: $e');
    }
  }

  // Belirli bir siparişi getir
  Future<order_model.Order?> getOrder(String orderId) async {
    try {
      DocumentSnapshot doc =
          await _firestore.collection('orders').doc(orderId).get();

      if (!doc.exists) {
        return null;
      }

      final data = doc.data();
      if (data == null) return null;

      return order_model.Order.fromFirestore(data as Map<String, dynamic>);
    } catch (e) {
      throw Exception('Sipariş getirme hatası: $e');
    }
  }

  // Kategori bazında ürünleri getir
  Future<List<Product>> getProductsByCategory(String category) async {
    try {
      QuerySnapshot querySnapshot = await _firestore
          .collection('products')
          .where('category', isEqualTo: category)
          .get();

      return querySnapshot.docs
          .map((doc) {
            try {
              final data = doc.data();
              if (data is! Map<String, dynamic>) {
                return null;
              }
              return Product.fromFirestore(data, doc.id);
            } catch (e) {
              print('Ürün parsing hatası: $e');
              return null;
            }
          })
          .whereType<Product>()
          .toList();
    } catch (e) {
      throw Exception('Kategori ürünleri getirme hatası: $e');
    }
  }

  // Ürün güncelle (Stok vb.)
  Future<void> updateProduct(
      String productId, Map<String, dynamic> data) async {
    try {
      await _firestore.collection('products').doc(productId).update(data);
      print('Ürün güncellendi: $productId');
    } catch (e) {
      throw Exception('Ürün güncelleme hatası: $e');
    }
  }

  // Sipariş sil
  Future<void> deleteOrder(String orderId) async {
    try {
      await _firestore.collection('orders').doc(orderId).delete();
      print('Sipariş silindi: $orderId');
    } catch (e) {
      throw Exception('Sipariş silme hatası: $e');
    }
  }
}

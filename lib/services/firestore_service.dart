import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/product.dart';
import '../models/order.dart' as order_model;

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // ORDERS
  Future<void> createOrder(
    String userId,
    List<Product> items,
    double total,
  ) async {
    try {
      final orderItems = items.where((p) => p.quantity > 0).map((p) {
        return {
          'productId': p.id,
          'name': p.name,
          'price': p.price,
          'quantity': p.quantity,
        };
      }).toList();

      await _firestore.collection('orders').add({
        'userId': userId,
        'items': orderItems,
        'total': total,
        'status': 'Beklemede',
        'cargoNumber': '',
        'orderDate': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Sipariş oluşturma hatası: $e');
    }
  }

  // KULLANICI SİPARİŞLERİ
  Stream<List<order_model.Order>> getUserOrders(String userId) {
    return _firestore
        .collection('orders')
        .where('userId', isEqualTo: userId)
        .orderBy('orderDate', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return order_model.Order.fromFirestore(doc.data(), doc.id);
      }).toList();
    });
  }

  // ADMIN - TÜM SİPARİŞLER
  Stream<List<order_model.Order>> getAllOrders() {
    return _firestore
        .collection('orders')
        .orderBy('orderDate', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return order_model.Order.fromFirestore(doc.data(), doc.id);
      }).toList();
    });
  }

  // ADMIN - SİPARİŞ DURUMUNU GÜNCELLE
  Future<void> updateOrderStatus(String orderId, String newStatus) async {
    try {
      await _firestore.collection('orders').doc(orderId).update({
        'status': newStatus,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Sipariş durumu güncelleme hatası: $e');
    }
  }

  // ADMIN - KARGO NUMARASI EKLE
  Future<void> updateCargoNumber(String orderId, String cargoNumber) async {
    try {
      await _firestore.collection('orders').doc(orderId).update({
        'cargoNumber': cargoNumber,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Kargo numarası güncelleme hatası: $e');
    }
  }

  // REVIEWS
  Future<void> addReview(
    String productId,
    String userId,
    String userName,
    int rating,
    String comment,
  ) async {
    try {
      await _firestore
          .collection('products')
          .doc(productId)
          .collection('reviews')
          .add({
        'userId': userId,
        'userName': userName,
        'rating': rating,
        'comment': comment,
        'date': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Yorum ekleme hatası: $e');
    }
  }

  Stream<QuerySnapshot> getProductReviews(String productId) {
    return _firestore
        .collection('products')
        .doc(productId)
        .collection('reviews')
        .orderBy('date', descending: true)
        .snapshots();
  }

  // FAVORITES
  Future<void> addFavorite(
    String userId,
    String productId,
    Product product,
  ) async {
    try {
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('favorites')
          .doc(productId)
          .set({
        'name': product.name,
        'price': product.price,
        'category': product.category,
        'imagePath': product.imagePath,
        'stock': product.stock,
      });
    } catch (e) {
      throw Exception('Favori ekleme hatası: $e');
    }
  }

  Future<void> removeFavorite(String userId, String productId) async {
    try {
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('favorites')
          .doc(productId)
          .delete();
    } catch (e) {
      throw Exception('Favori silme hatası: $e');
    }
  }

  Stream<QuerySnapshot> getUserFavorites(String userId) {
    return _firestore
        .collection('users')
        .doc(userId)
        .collection('favorites')
        .snapshots();
  }

  // PROMO CODES
  Future<Map<String, dynamic>?> validatePromoCode(String code) async {
    try {
      final doc = await _firestore
          .collection('promos')
          .where('code', isEqualTo: code.toUpperCase())
          .where('active', isEqualTo: true)
          .limit(1)
          .get();

      if (doc.docs.isEmpty) return null;

      return doc.docs.first.data();
    } catch (e) {
      throw Exception('Promosyon kodu kontrol hatası: $e');
    }
  }

  // USER PROFILE
  Future<void> updateUserProfile(
    String userId,
    String name,
    String phone,
    String address,
  ) async {
    try {
      await _firestore.collection('users').doc(userId).set(
        {
          'name': name,
          'phone': phone,
          'address': address,
          'updatedAt': FieldValue.serverTimestamp(),
        },
        SetOptions(merge: true),
      );
    } catch (e) {
      throw Exception('Profil güncelleme hatası: $e');
    }
  }

  Future<Map<String, dynamic>?> getUserProfile(String userId) async {
    try {
      final doc = await _firestore.collection('users').doc(userId).get();
      if (doc.exists) {
        return doc.data();
      }
      return null;
    } catch (e) {
      throw Exception('Profil yükleme hatası: $e');
    }
  }
}

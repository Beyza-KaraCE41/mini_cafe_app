import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  User? get currentUser => _firebaseAuth.currentUser;
  String get userEmail => currentUser?.email ?? '';
  String get userId => currentUser?.uid ?? '';

  // ⭐ ROL BİLGİSİ
  Future<String> getUserRole() async {
    try {
      DocumentSnapshot doc =
          await _firestore.collection('users').doc(userId).get();
      return doc['role'] ?? 'customer';
    } catch (e) {
      return 'customer';
    }
  }

  bool get isLoggedIn => _firebaseAuth.currentUser != null;

  Stream<User?> get authStateChanges => _firebaseAuth.authStateChanges();

  // 📝 KAYIT OL (GÜNCELLENDİ: Profil bilgileriyle birlikte)
  Future<UserCredential?> signUpWithEmail(
    String email,
    String password,
    String role,
    String name, // Yeni parametre
    String phone, // Yeni parametre
    String address, // Yeni parametre
  ) async {
    try {
      UserCredential userCredential =
          await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Firestore'a user bilgisi kaydet (DOLU OLARAK)
      await _firestore.collection('users').doc(userCredential.user!.uid).set({
        'email': email,
        'role': role,
        'name': name, // Kaydediliyor
        'phone': phone, // Kaydediliyor
        'address': address, // Kaydediliyor
        'createdAt': FieldValue.serverTimestamp(),
      });

      return userCredential;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        throw 'Şifre çok zayıf (en az 6 karakter).';
      } else if (e.code == 'email-already-in-use') {
        throw 'Bu email zaten kullanılıyor.';
      } else if (e.code == 'invalid-email') {
        throw 'Geçersiz email adresi.';
      }
      throw e.message ?? 'Kayıt hatası';
    } catch (e) {
      throw 'Kayıt hatası: $e';
    }
  }

  // 🔐 GİRİŞ YAP
  Future<UserCredential?> signInWithEmail(String email, String password) async {
    try {
      UserCredential userCredential =
          await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return userCredential;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        throw 'Bu email kullanıcı bulunamadı.';
      } else if (e.code == 'wrong-password') {
        throw 'Yanlış şifre.';
      } else if (e.code == 'invalid-email') {
        throw 'Geçersiz email adresi.';
      } else if (e.code == 'user-disabled') {
        throw 'Bu hesap devre dışı bırakılmıştır.';
      }
      throw e.message ?? 'Giriş başarısız';
    } catch (e) {
      throw 'Giriş hatası: $e';
    }
  }

  // 🔴 ÇIKIŞ YAP
  Future<void> signOut() async {
    try {
      await _firebaseAuth.signOut();
    } catch (e) {
      throw 'Çıkış hatası: $e';
    }
  }

  // 🔑 ŞİFRE SIFIRLA
  Future<void> resetPassword(String email) async {
    try {
      await _firebaseAuth.sendPasswordResetEmail(email: email);
    } catch (e) {
      throw 'Şifre sıfırlama hatası: $e';
    }
  }
}

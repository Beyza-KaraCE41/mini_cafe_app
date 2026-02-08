import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  // Singleton pattern
  static final AuthService _instance = AuthService._internal();

  factory AuthService() {
    return _instance;
  }

  AuthService._internal();

  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  User? get currentUser => _firebaseAuth.currentUser;

  String get userEmail => currentUser?.email ?? '';

  String get userId => currentUser?.uid ?? '';

  // Role kontrolü - Email'e göre admin olup olmadığını kontrol et
  bool get isAdmin {
    // admin@minicafe.com formatında giren hesaplar admin
    return currentUser?.email?.contains('admin') ?? false;
  }

  // Auth state changes - Stream olarak sabır dinle
  Stream<User?> get authStateChanges => _firebaseAuth.authStateChanges();

  // Kayıt ol
  Future<UserCredential?> signUpWithEmail(String email, String password) async {
    try {
      UserCredential userCredential = await _firebaseAuth
          .createUserWithEmailAndPassword(email: email, password: password);
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

  // Giriş yap
  Future<UserCredential?> signInWithEmail(String email, String password) async {
    try {
      UserCredential userCredential = await _firebaseAuth
          .signInWithEmailAndPassword(email: email, password: password);
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

  // Çıkış yap - ÖNEMLİ!
  Future<void> signOut() async {
    try {
      print('🔴 Çıkış yapılıyor...');
      await _firebaseAuth.signOut();
      print('✅ Çıkış başarılı!');
    } catch (e) {
      throw 'Çıkış hatası: $e';
    }
  }

  // Şifre sıfırla
  Future<void> resetPassword(String email) async {
    try {
      await _firebaseAuth.sendPasswordResetEmail(email: email);
    } catch (e) {
      throw 'Şifre sıfırlama hatası: $e';
    }
  }

  // Mevcut kullanıcıyı kontrol et
  bool get isLoggedIn => _firebaseAuth.currentUser != null;
}

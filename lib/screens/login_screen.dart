import 'package:flutter/material.dart';
import '../services/auth_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final AuthService _authService = AuthService();

  bool _obscurePassword = true;
  bool _isLoading = false;
  bool _isSignUp = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _nameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  // EMAIL'E GÖRE ROL BELİRLE
  String _determineRole(String email) {
    if (email.toLowerCase().contains('admin')) {
      return 'admin';
    }
    return 'customer';
  }

  Future<void> _handleAuth() async {
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
      _showSnackBar('Lütfen email ve şifre girin', isError: true);
      return;
    }

    if (_isSignUp && _nameController.text.isEmpty) {
      _showSnackBar('Lütfen adınızı girin', isError: true);
      return;
    }

    setState(() => _isLoading = true);

    try {
      final email = _emailController.text.trim();

      if (_isSignUp) {
        // KAYIT OL
        // 1. Rol otomatik belirle
        final role = _determineRole(email);

        // 2. Firebase Auth'a kayıt (3 parametre: email, password, role)
        await _authService.signUpWithEmail(
          email,
          _passwordController.text,
          role,
        );

        _showSnackBar('✅ Kayıt başarılı! Giriş yapılıyor...');

        // 3. Otomatik giriş yap
        await Future.delayed(const Duration(milliseconds: 500));
        await _authService.signInWithEmail(email, _passwordController.text);

        if (mounted) {
          _emailController.clear();
          _passwordController.clear();
          _nameController.clear();
          _phoneController.clear();
          _addressController.clear();
          print('✅ Kayıt + Login OK - Role: $role');
        }
      } else {
        // GİRİŞ YAP
        await _authService.signInWithEmail(email, _passwordController.text);
        _showSnackBar('✅ Giriş başarılı!');
        print('✅ Login OK - Email: $email');
      }
    } catch (e) {
      _showSnackBar('❌ Hata: ${e.toString()}', isError: true);
      print('❌ Error: $e');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.brown.shade800, Colors.brown.shade600],
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // ☕ LOGO - TWEETY RESMİ
                Container(
                  width: 180,
                  height: 180,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.amber.shade400,
                      width: 6,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.5),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Container(
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white,
                    ),
                    padding: const EdgeInsets.all(8),
                    child: ClipOval(
                      child: Image.asset(
                        'assets/images/tweety.png',
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 40),

                // ☕ BAŞLIK
                Text(
                  'Mini Cafe ☕',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: 1.2,
                    shadows: [
                      Shadow(
                        blurRadius: 5,
                        color: Colors.black.withOpacity(0.5),
                        offset: const Offset(2, 2),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  _isSignUp ? 'Kayıt Ol' : 'Giriş Yap',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.amber.shade400,
                    letterSpacing: 1.2,
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  _isSignUp
                      ? 'Yeni hesap oluşturun'
                      : 'Giriş yaparak devam edin',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.white70,
                  ),
                ),
                const SizedBox(height: 35),

                // KAYIT DURUMUNDA AD
                if (_isSignUp) ...[
                  TextField(
                    controller: _nameController,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: 'Ad Soyad',
                      hintStyle: const TextStyle(color: Colors.white70),
                      prefixIcon:
                          const Icon(Icons.person, color: Colors.white70),
                      filled: true,
                      fillColor: Colors.white.withOpacity(0.1),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: Colors.amber.shade400,
                          width: 2,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],

                // EMAIL
                TextField(
                  controller: _emailController,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: 'E-posta',
                    hintStyle: const TextStyle(color: Colors.white70),
                    prefixIcon: const Icon(Icons.email, color: Colors.white70),
                    filled: true,
                    fillColor: Colors.white.withOpacity(0.1),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: Colors.amber.shade400,
                        width: 2,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // ŞİFRE
                TextField(
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: 'Şifre',
                    hintStyle: const TextStyle(color: Colors.white70),
                    prefixIcon: const Icon(Icons.lock, color: Colors.white70),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword
                            ? Icons.visibility_off
                            : Icons.visibility,
                        color: Colors.white70,
                      ),
                      onPressed: () =>
                          setState(() => _obscurePassword = !_obscurePassword),
                    ),
                    filled: true,
                    fillColor: Colors.white.withOpacity(0.1),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: Colors.amber.shade400,
                        width: 2,
                      ),
                    ),
                  ),
                ),

                // KAYIT DURUMUNDA TELEFON
                if (_isSignUp) ...[
                  const SizedBox(height: 16),
                  TextField(
                    controller: _phoneController,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: 'Telefon',
                      hintStyle: const TextStyle(color: Colors.white70),
                      prefixIcon:
                          const Icon(Icons.phone, color: Colors.white70),
                      filled: true,
                      fillColor: Colors.white.withOpacity(0.1),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: Colors.amber.shade400,
                          width: 2,
                        ),
                      ),
                    ),
                  ),
                ],

                // KAYIT DURUMUNDA ADRES
                if (_isSignUp) ...[
                  const SizedBox(height: 16),
                  TextField(
                    controller: _addressController,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: 'Adres',
                      hintStyle: const TextStyle(color: Colors.white70),
                      prefixIcon:
                          const Icon(Icons.location_on, color: Colors.white70),
                      filled: true,
                      fillColor: Colors.white.withOpacity(0.1),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: Colors.amber.shade400,
                          width: 2,
                        ),
                      ),
                    ),
                    maxLines: 2,
                  ),
                ],

                const SizedBox(height: 32),

                // BUTTON
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _handleAuth,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.amber.shade700,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: _isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : Text(
                            _isSignUp ? 'Kayıt Ol ☕' : 'Giriş Yap ☕',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                  ),
                ),
                const SizedBox(height: 20),

                // TOGGLE
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      _isSignUp
                          ? 'Zaten hesabınız var mı? '
                          : 'Hesabınız yok mu? ',
                      style: const TextStyle(color: Colors.white70),
                    ),
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          _isSignUp = !_isSignUp;
                          _emailController.clear();
                          _passwordController.clear();
                          _nameController.clear();
                          _phoneController.clear();
                          _addressController.clear();
                        });
                      },
                      child: Text(
                        _isSignUp ? 'Giriş Yap' : 'Kayıt Ol',
                        style: TextStyle(
                          color: Colors.amber.shade400,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

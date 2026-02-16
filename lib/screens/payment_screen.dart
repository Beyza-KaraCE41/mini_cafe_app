import 'package:flutter/material.dart';
import '../models/product.dart';

class PaymentScreen extends StatefulWidget {
  final double total;
  final List<Product> cartItems;

  const PaymentScreen({
    super.key,
    required this.total,
    required this.cartItems,
  });

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  final _cardNumberController = TextEditingController();
  final _cardHolderController = TextEditingController();
  final _expiryController = TextEditingController();
  final _cvcController = TextEditingController();

  bool _isProcessing = false;
  bool _obscureCVC = true;

  @override
  void dispose() {
    _cardNumberController.dispose();
    _cardHolderController.dispose();
    _expiryController.dispose();
    _cvcController.dispose();
    super.dispose();
  }

  void _processPayment() {
    if (_cardNumberController.text.isEmpty ||
        _cardHolderController.text.isEmpty ||
        _expiryController.text.isEmpty ||
        _cvcController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Lütfen tüm alanları doldurun'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isProcessing = true);

    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        Navigator.pop(context, true);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Güvenli Ödeme',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context, false),
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFFFE0B2), Color(0xFFFFF8E1)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Sipariş Özeti
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.08),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Sipariş Özeti',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: Colors.brown.shade800,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '${widget.cartItems.where((p) => p.quantity > 0).length} ürün',
                          style: TextStyle(
                            color: Colors.brown.shade600,
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.green.shade50,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: Colors.green.shade200,
                              width: 1.5,
                            ),
                          ),
                          child: Text(
                            '${widget.total.toStringAsFixed(2)} TL',
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              color: Colors.green.shade700,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 28),

              // Kart Bilgileri
              Text(
                'Kart Bilgileri',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Colors.brown.shade800,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 16),

              // Kart Numarası
              _buildTextField(
                controller: _cardNumberController,
                hint: '1234 5678 9012 3456',
                label: 'Kart Numarası',
                icon: Icons.credit_card,
                keyboardType: TextInputType.number,
                maxLength: 19,
                onChanged: (value) {
                  if (value.length == 4 ||
                      value.length == 9 ||
                      value.length == 14) {
                    _cardNumberController.text = '$value ';
                    _cardNumberController.selection =
                        TextSelection.fromPosition(
                      TextPosition(offset: _cardNumberController.text.length),
                    );
                  }
                },
              ),
              const SizedBox(height: 16),

              // Kart Sahibi
              _buildTextField(
                controller: _cardHolderController,
                hint: 'Örn: AHMET YILMAZ',
                label: 'Kart Sahibi Adı',
                icon: Icons.person,
              ),
              const SizedBox(height: 16),

              // Son Kullanma Tarihi ve CVC
              Row(
                children: [
                  Expanded(
                    child: _buildTextField(
                      controller: _expiryController,
                      hint: 'AA/YY',
                      label: 'Tarih',
                      icon: Icons.calendar_today,
                      keyboardType: TextInputType.number,
                      maxLength: 5,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildTextField(
                      controller: _cvcController,
                      hint: '123',
                      label: 'CVC',
                      icon: Icons.lock,
                      keyboardType: TextInputType.number,
                      maxLength: 3,
                      obscureText: _obscureCVC,
                      onSuffixPressed: () =>
                          setState(() => _obscureCVC = !_obscureCVC),
                      showSuffix: true,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),

              // Ödeme Butonu
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton.icon(
                  onPressed: _isProcessing ? null : _processPayment,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.amber.shade700,
                    disabledBackgroundColor: Colors.grey.shade400,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    elevation: 0,
                  ),
                  icon: _isProcessing
                      ? SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 3,
                          ),
                        )
                      : const Icon(Icons.check_circle, size: 24),
                  label: Text(
                    _isProcessing
                        ? 'İşleniyor...'
                        : '${widget.total.toStringAsFixed(2)} TL Öde ☕',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // İptal Butonu
              SizedBox(
                width: double.infinity,
                height: 50,
                child: OutlinedButton.icon(
                  onPressed: _isProcessing
                      ? null
                      : () => Navigator.pop(context, false),
                  icon: const Icon(Icons.close, size: 20),
                  label: const Text('İptal Et'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.brown.shade700,
                    side: BorderSide(
                      color: Colors.brown.shade700,
                      width: 2,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Güvenlik Bilgisi
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Colors.blue.shade300,
                    width: 1.5,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(Icons.lock_outline,
                        color: Colors.blue.shade700, size: 22),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        '🔒 Kart bilgileri SSL şifrelemesi ile korunmaktadır.',
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.blue.shade700,
                          fontWeight: FontWeight.w500,
                          height: 1.4,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    required String label,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    int? maxLength,
    Function(String)? onChanged,
    bool obscureText = false,
    bool showSuffix = false,
    VoidCallback? onSuffixPressed,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.brown.shade700,
            letterSpacing: 0.3,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          obscureText: obscureText,
          maxLength: maxLength,
          onChanged: onChanged,
          style: TextStyle(
            color: Colors.brown.shade800,
            fontSize: 15,
            fontWeight: FontWeight.w500,
          ),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(
              color: Colors.brown.shade300,
              fontSize: 14,
              fontWeight: FontWeight.w400,
            ),
            prefixIcon: Icon(icon, color: Colors.amber.shade700, size: 22),
            suffixIcon: showSuffix
                ? IconButton(
                    icon: Icon(
                      obscureText ? Icons.visibility_off : Icons.visibility,
                      color: Colors.brown.shade600,
                      size: 20,
                    ),
                    onPressed: onSuffixPressed,
                  )
                : null,
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: Colors.amber.shade700,
                width: 2,
              ),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
          ),
        ),
      ],
    );
  }
}

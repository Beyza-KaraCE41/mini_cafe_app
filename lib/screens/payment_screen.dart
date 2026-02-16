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
        Navigator.pop(context, true); // true = ödeme başarılı
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ödeme',
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
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 8,
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Sipariş Özeti',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.brown,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '${widget.cartItems.where((p) => p.quantity > 0).length} ürün',
                          style: TextStyle(
                            color: Colors.brown.shade600,
                            fontSize: 14,
                          ),
                        ),
                        Text(
                          '${widget.total.toStringAsFixed(2)} TL',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.green,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Kart Bilgileri
              const Text(
                'Kart Bilgileri',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.brown,
                ),
              ),
              const SizedBox(height: 16),

              // Kart Numarası
              TextField(
                controller: _cardNumberController,
                style: const TextStyle(color: Colors.brown),
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  hintText: '1234 5678 9012 3456',
                  hintStyle: const TextStyle(color: Colors.brown),
                  prefixIcon:
                      const Icon(Icons.credit_card, color: Colors.brown),
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
                ),
                maxLength: 19,
                onChanged: (value) {
                  // Otomatik boşluk ekle
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
              TextField(
                controller: _cardHolderController,
                style: const TextStyle(color: Colors.brown),
                decoration: InputDecoration(
                  hintText: 'Kart Sahibi Adı',
                  hintStyle: const TextStyle(color: Colors.brown),
                  prefixIcon: const Icon(Icons.person, color: Colors.brown),
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
                ),
              ),
              const SizedBox(height: 16),

              // Son Kullanma Tarihi ve CVC
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _expiryController,
                      style: const TextStyle(color: Colors.brown),
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        hintText: 'AA/YY',
                        hintStyle: const TextStyle(color: Colors.brown),
                        prefixIcon: const Icon(Icons.calendar_today,
                            color: Colors.brown),
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
                      ),
                      maxLength: 5,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextField(
                      controller: _cvcController,
                      style: const TextStyle(color: Colors.brown),
                      keyboardType: TextInputType.number,
                      obscureText: _obscureCVC,
                      decoration: InputDecoration(
                        hintText: 'CVC',
                        hintStyle: const TextStyle(color: Colors.brown),
                        prefixIcon: const Icon(Icons.lock, color: Colors.brown),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscureCVC
                                ? Icons.visibility_off
                                : Icons.visibility,
                            color: Colors.brown,
                          ),
                          onPressed: () =>
                              setState(() => _obscureCVC = !_obscureCVC),
                        ),
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
                      ),
                      maxLength: 3,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),

              // Ödeme Butonu
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton.icon(
                  onPressed: _isProcessing ? null : _processPayment,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.amber.shade700,
                    disabledBackgroundColor: Colors.grey.shade400,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  icon: _isProcessing
                      ? SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2.5,
                          ),
                        )
                      : const Icon(Icons.check, size: 22),
                  label: Text(
                    _isProcessing
                        ? 'İşleniyor...'
                        : '${widget.total.toStringAsFixed(2)} TL Öde ☕',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // İptal Butonu
              SizedBox(
                width: double.infinity,
                height: 44,
                child: OutlinedButton(
                  onPressed: _isProcessing
                      ? null
                      : () => Navigator.pop(context, false),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.brown.shade700,
                    side: BorderSide(
                      color: Colors.brown.shade700,
                      width: 1.5,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text('İptal'),
                ),
              ),
              const SizedBox(height: 20),

              // Güvenlik Uyarısı
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: Colors.blue.shade200,
                    width: 1,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(Icons.lock, color: Colors.blue.shade600, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Kart bilgileri güvenli şekilde işlenmektedir',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.blue.shade700,
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
}

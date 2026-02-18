class Promo {
  final String id;
  final String code; // "KUPA10"
  final int discount; // 10 (%10)
  final String description;
  final bool active;
  final DateTime? expiryDate;

  Promo({
    required this.id,
    required this.code,
    required this.discount,
    required this.description,
    this.active = true,
    this.expiryDate,
  });

  factory Promo.fromFirestore(Map<String, dynamic> json, String docId) {
    return Promo(
      id: docId,
      code: json['code'] ?? '',
      discount: json['discount'] ?? 0,
      description: json['description'] ?? '',
      active: json['active'] ?? true,
      expiryDate: json['expiryDate'] != null
          ? (json['expiryDate'] as dynamic).toDate()
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'code': code,
      'discount': discount,
      'description': description,
      'active': active,
      'expiryDate': expiryDate,
    };
  }

  bool isValid() {
    if (!active) return false;
    if (expiryDate != null && DateTime.now().isAfter(expiryDate!)) {
      return false;
    }
    return true;
  }
}

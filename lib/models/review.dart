import 'package:cloud_firestore/cloud_firestore.dart';

class Review {
  final String id;
  final String userId;
  final String userName;
  final int rating; // 1-5
  final String comment;
  final DateTime date;
  final String productId;

  Review({
    required this.id,
    required this.userId,
    required this.userName,
    required this.rating,
    required this.comment,
    required this.date,
    required this.productId,
  });

  factory Review.fromFirestore(Map<String, dynamic> json, String docId) {
    return Review(
      id: docId,
      userId: json['userId'] ?? '',
      userName: json['userName'] ?? 'Anonim',
      rating: json['rating'] ?? 0,
      comment: json['comment'] ?? '',
      date: (json['date'] as Timestamp?)?.toDate() ?? DateTime.now(),
      productId: json['productId'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'userName': userName,
      'rating': rating,
      'comment': comment,
      'date': FieldValue.serverTimestamp(),
      'productId': productId,
    };
  }

  // Star gösterimi (★★★★☆)
  String getStarDisplay() {
    String stars = '★' * rating;
    stars += '☆' * (5 - rating);
    return stars;
  }
}

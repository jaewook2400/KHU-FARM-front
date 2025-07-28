// lib/model/review.dart

import 'package:khu_farm/model/order.dart';

class ReviewInfo {
  final String title;
  final String userId; // userId 필드 추가
  final String content;
  final String imageUrl;
  final int rating;
  final String createdAt;
  final String? replyContent; // reply 필드 추가 (nullable)

  ReviewInfo({
    required this.title,
    required this.userId, // 생성자에 추가
    required this.content,
    required this.imageUrl,
    required this.rating,
    required this.createdAt,
    this.replyContent, // 생성자에 추가
  });

  factory ReviewInfo.fromJson(Map<String, dynamic> json) {
    return ReviewInfo(
      title: json['title'] ?? '',
      userId: json['userId'] ?? '알 수 없음', // fromJson에 추가
      content: json['content'] ?? '',
      imageUrl: json['imageUrl'] ?? '',
      rating: (json['rating'] as num?)?.toInt() ?? 0,
      createdAt: json['createdAt'] ?? '',
      replyContent: json['reply']?['content'], // fromJson에 추가
    );
  }
}

class Review {
  final Order fruitResponse;
  final ReviewInfo reviewResponse;

  Review({
    required this.fruitResponse,
    required this.reviewResponse,
  });

  factory Review.fromJson(Map<String, dynamic> json) {
    return Review(
      fruitResponse: Order.fromJson(json['fruitResponse'] ?? {}),
      reviewResponse: ReviewInfo.fromJson(json['reviewResponse'] ?? {}),
    );
  }
}
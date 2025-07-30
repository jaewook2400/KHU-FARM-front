import 'package:khu_farm/model/order.dart';

class ReviewInfo {
  final int reviewId;
  final String title;
  final String userId;
  final String content;
  final String imageUrl;
  final int rating;
  final String createdAt;
  final String? replyContent;

  ReviewInfo({
    required this.reviewId,
    required this.title,
    required this.userId,
    required this.content,
    required this.imageUrl,
    required this.rating,
    required this.createdAt,
    this.replyContent,
  });

  factory ReviewInfo.fromJson(Map<String, dynamic> json) {
    return ReviewInfo(
      reviewId: json['id'] ?? 0,
      title: json['title'] ?? '',
      userId: json['userId'] ?? '알 수 없음',
      content: json['content'] ?? '',
      imageUrl: json['imageUrl'] ?? '',
      rating: (json['rating'] as num?)?.toInt() ?? 0,
      createdAt: json['createdAt'] ?? '',
      replyContent: json['reply']?['content'],
    );
  }
  
  // ✨ toString() 메서드 추가
  @override
  String toString() {
    return 'ReviewInfo(title: $title, userId: $userId, content: $content, imageUrl: $imageUrl, rating: $rating, createdAt: $createdAt, replyContent: $replyContent)';
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

  // ✨ toString() 메서드 추가
  @override
  String toString() {
    return 'Review(fruitResponse: $fruitResponse, reviewResponse: $reviewResponse)';
  }
}
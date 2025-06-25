import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class Review {
  final String title;
  final String author;
  final String content;
  final int rating;
  final String date;
  final String sellerReply;

  Review({
    required this.title,
    required this.author,
    required this.content,
    required this.rating,
    required this.date,
    required this.sellerReply,
  });
}

class Inquiry {
  final String question;
  final String answer;
  final String date;
  final bool answered;
  Inquiry({
    required this.question,
    required this.answer,
    required this.date,
    required this.answered,
  });
}

class ProductDetailScreen extends StatelessWidget {
  final String imagePath;
  final String producer;
  final String title;
  final String price;
  final String unit;
  final bool liked;

  const ProductDetailScreen({
    Key? key,
    required this.imagePath,
    required this.producer,
    required this.title,
    required this.price,
    required this.unit,
    required this.liked,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
      ),
    );

    final double screenWidth = MediaQuery.of(context).size.width;
    final double screenHeight = MediaQuery.of(context).size.height;
    final double statusBarHeight = MediaQuery.of(context).padding.top;
    final double bottomPadding = MediaQuery.of(context).padding.bottom;
    const double buttonHeight = 50;
    final double rating = 5.0;
    final List<String> infoFlags = ['택배확인', '무료배송', '01.01까지 판매 종료 예정'];

    final inquiries = [
      Inquiry(
        question: '문의내용 문의내용 문의내용 문의내용 문의내용',
        answer: '답변내용이 여기에 표시됩니다.',
        date: '2025.01.01',
        answered: true,
      ),
      Inquiry(
        question: '다른 문의내용입니다.',
        answer: '',
        date: '2025.01.01',
        answered: false,
      ),
      // 추가 예시
    ];

    final List<Review> reviews = [
      Review(
        title: '정말 맛있는 꿀사과 리뷰입니다',
        author: '홍길동',
        content: '과즙이 풍부하고 신선합니다.',
        rating: 5,
        date: '2025.01.01',
        sellerReply: '감사합니다! 앞으로도 신선한 과일 제공하겠습니다.',
      ),
      Review(
        title: '가격 대비 훌륭해요',
        author: '김영희',
        content: '가성비 최고입니다.',
        rating: 4,
        date: '2025.01.02',
        sellerReply: '좋은 평가 감사합니다!',
      ),
      // 더 많은 샘플 리뷰
    ];

    void _showPurchaseModal() {
      final int unitPrice = int.parse(price.replaceAll(RegExp(r'[^0-9]'), ''));
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (context) {
          int quantity = 1;
          String formatPrice(int value) {
            final s = value.toString();
            return s.replaceAllMapped(
              RegExp(r"\B(?=(\d{3})+(?!\d))"),
              (m) => ',',
            );
          }

          return GestureDetector(
            onTap: () => Navigator.of(context).pop(),
            child: Container(
              color: Colors.black54,
              child: GestureDetector(
                onTap: () {},
                child: Align(
                  alignment: Alignment.bottomCenter,
                  child: StatefulBuilder(
                    builder: (context, setModalState) {
                      final int total = unitPrice * quantity;
                      return Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(12),
                          ),
                        ),
                        padding: EdgeInsets.only(
                          top: 16,
                          left: 16,
                          right: 16,
                          bottom: bottomPadding + 16,
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 40,
                              height: 4,
                              decoration: BoxDecoration(
                                color: Colors.grey[300],
                                borderRadius: BorderRadius.circular(2),
                              ),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              title,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 16),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                IconButton(
                                  onPressed: () {
                                    if (quantity > 1)
                                      setModalState(() => quantity--);
                                  },
                                  icon: const Icon(Icons.remove),
                                ),
                                Text(
                                  quantity.toString(),
                                  style: const TextStyle(fontSize: 16),
                                ),
                                IconButton(
                                  onPressed:
                                      () => setModalState(() => quantity++),
                                  icon: const Icon(Icons.add),
                                ),
                                const SizedBox(width: 8),
                                const Text(
                                  '박스',
                                  style: TextStyle(fontSize: 14),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            Text(
                              '총 상품금액(무료배송)',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.red.shade400,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${formatPrice(total)}원',
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 16),
                            Row(
                              children: [
                                Expanded(
                                  child: OutlinedButton(
                                    onPressed: () {},
                                    style: OutlinedButton.styleFrom(
                                      side: BorderSide(
                                        color: Colors.green.shade400,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(30),
                                      ),
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 14,
                                      ),
                                    ),
                                    child: const Text(
                                      '장바구니',
                                      style: TextStyle(
                                        fontSize: 16,
                                        color: Colors.green,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: ElevatedButton(
                                    onPressed: () {},
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.green.shade400,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(30),
                                      ),
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 14,
                                      ),
                                    ),
                                    child: const Text(
                                      '구매하기',
                                      style: TextStyle(
                                        fontSize: 16,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
          );
        },
      );
    }

    void _showReviewDetailModal(BuildContext context, Review rv) {
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (ctx) {
          return GestureDetector(
            onTap: () => Navigator.of(ctx).pop(),
            child: Container(
              color: Colors.black54,
              child: GestureDetector(
                onTap: () {},
                child: DraggableScrollableSheet(
                  initialChildSize: 0.7,
                  minChildSize: 0.5,
                  maxChildSize: 0.9,
                  builder:
                      (_, controller) => Container(
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.vertical(
                            top: Radius.circular(12),
                          ),
                        ),
                        child: Column(
                          children: [
                            const SizedBox(height: 8),
                            Container(
                              width: 40,
                              height: 4,
                              decoration: BoxDecoration(
                                color: Colors.grey[300],
                                borderRadius: BorderRadius.circular(2),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Text(
                                  '리뷰',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const Spacer(),
                                GestureDetector(
                                  onTap: () => Navigator.of(ctx).pop(),
                                  child: const Padding(
                                    padding: EdgeInsets.only(right: 16),
                                    child: Icon(Icons.close),
                                  ),
                                ),
                              ],
                            ),
                            const Divider(height: 1),
                            Expanded(
                              child: SingleChildScrollView(
                                controller: controller,
                                padding: const EdgeInsets.all(16),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(12),
                                      child: Image.asset(
                                        imagePath,
                                        width: double.infinity,
                                        height: 200,
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                    const SizedBox(height: 16),
                                    Text(
                                      rv.title,
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Row(
                                      children: [
                                        for (int k = 0; k < rv.rating; k++)
                                          const Icon(
                                            Icons.star,
                                            size: 16,
                                            color: Colors.red,
                                          ),
                                        const SizedBox(width: 4),
                                        Text(
                                          rv.rating.toString(),
                                          style: const TextStyle(fontSize: 12),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      rv.date,
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey,
                                      ),
                                    ),
                                    const SizedBox(height: 16),
                                    Text(
                                      rv.content,
                                      style: const TextStyle(
                                        fontSize: 13,
                                        color: Colors.black87,
                                      ),
                                    ),
                                    const SizedBox(height: 16),
                                    Container(
                                      width: double.infinity,
                                      decoration: BoxDecoration(
                                        color: Colors.grey[100],
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      padding: const EdgeInsets.all(12),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          const Text(
                                            '판매자 답변',
                                            style: TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          const SizedBox(height: 8),
                                          Text(
                                            rv.sellerReply,
                                            style: const TextStyle(
                                              fontSize: 13,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                ),
              ),
            ),
          );
        },
      );
    }

    void _showAllReviewsModal(BuildContext context, List<Review> reviews) {
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (ctx) {
          return GestureDetector(
            onTap: () => Navigator.of(ctx).pop(),
            child: Container(
              color: Colors.black54,
              child: GestureDetector(
                onTap: () {},
                child: DraggableScrollableSheet(
                  initialChildSize: 0.6,
                  minChildSize: 0.4,
                  maxChildSize: 0.9,
                  builder:
                      (_, controller) => Container(
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.vertical(
                            top: Radius.circular(12),
                          ),
                        ),
                        child: Column(
                          children: [
                            const SizedBox(height: 8),
                            Container(
                              width: 40,
                              height: 4,
                              decoration: BoxDecoration(
                                color: Colors.grey[300],
                                borderRadius: BorderRadius.circular(2),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Text(
                                  '리뷰',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const Spacer(),
                                GestureDetector(
                                  onTap: () => Navigator.of(ctx).pop(),
                                  child: const Padding(
                                    padding: EdgeInsets.only(right: 16),
                                    child: Icon(Icons.close),
                                  ),
                                ),
                              ],
                            ),
                            const Divider(height: 1),
                            Expanded(
                              child: ListView.builder(
                                controller: controller,
                                padding: const EdgeInsets.all(16),
                                itemCount: reviews.length,
                                itemBuilder: (_, i) {
                                  final rv = reviews[i];
                                  return GestureDetector(
                                    onTap: () {
                                      Navigator.of(ctx).pop();
                                      _showReviewDetailModal(context, rv);
                                    },
                                    child: _ReviewDetailCard(
                                      imagePath: imagePath,
                                      review: rv,
                                      onTapClose: () {},
                                    ),
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                ),
              ),
            ),
          );
        },
      );
    }

    void _showInquiryModal(BuildContext ctx) {
      showModalBottomSheet(
        context: ctx,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder:
            (_) => InquiryModalContent(
              inquiries: inquiries,
              imagePath: imagePath,
              title: title,
              producer: producer,
              price: price,
              unit: unit,
            ),
      );
    }

    return Scaffold(
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          // 노치 배경
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: statusBarHeight + screenHeight * 0.06,
            child: Image.asset('assets/notch/morning.png', fit: BoxFit.cover),
          ),

          // 우상단 이미지
          Positioned(
            top: 0,
            right: 0,
            height: statusBarHeight * 1.2,
            child: Image.asset(
              'assets/notch/morning_right_up_cloud.png',
              fit: BoxFit.cover,
              alignment: Alignment.topRight,
            ),
          ),

          // 좌하단 이미지
          Positioned(
            top: statusBarHeight,
            left: 0,
            height: screenHeight * 0.06,
            child: Image.asset(
              'assets/notch/morning_left_down_cloud.png',
              fit: BoxFit.cover,
              alignment: Alignment.topRight,
            ),
          ),

          Positioned(
            top: statusBarHeight,
            height: statusBarHeight + screenHeight * 0.02,
            left: screenWidth * 0.05,
            right: screenWidth * 0.05,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                GestureDetector(
                  onTap: () {
                    Navigator.pushNamedAndRemoveUntil(
                      context,
                      '/consumer/main',
                      (route) => false,
                    );
                  },
                  child: const Text(
                    'KHU:FARM',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                    ),
                  ),
                ),
                Row(
                  children: [
                    GestureDetector(
                      onTap: () {
                        Navigator.pushNamed(
                          context,
                          '/consumer/notification/list',
                        );
                      },
                      child: Image.asset(
                        'assets/top_icons/notice.png',
                        width: 24,
                        height: 24,
                      ),
                    ),
                    const SizedBox(width: 12),
                    GestureDetector(
                      onTap: () {
                        // TODO: 찜 화면으로
                      },
                      child: Image.asset(
                        'assets/top_icons/dibs.png',
                        width: 24,
                        height: 24,
                      ),
                    ),
                    const SizedBox(width: 12),
                    GestureDetector(
                      onTap: () {
                        // TODO: 장바구니 화면으로
                      },
                      child: Image.asset(
                        'assets/top_icons/cart.png',
                        width: 24,
                        height: 24,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Content
          Positioned(
            top: statusBarHeight + screenHeight * 0.06 + 16,
            left: 16,
            right: 16,
            bottom: bottomPadding + buttonHeight + 16,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Product Image
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.asset(
                      imagePath,
                      width: double.infinity,
                      height: screenHeight * 0.3,
                      fit: BoxFit.cover,
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Title
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  // Rating and action icons
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          for (int i = 0; i < 5; i++)
                            const Icon(Icons.star, size: 20, color: Colors.red),
                          const SizedBox(width: 4),
                          Text(
                            rating.toStringAsFixed(1),
                            style: const TextStyle(fontSize: 14),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          GestureDetector(
                            onTap: () {},
                            child: const Icon(Icons.favorite_border, size: 24),
                          ),
                          const SizedBox(width: 12),
                          GestureDetector(
                            onTap: () {},
                            child: const Icon(Icons.share, size: 24),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // Price and tag
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        price,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '/ $unit',
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.grey,
                        ),
                      ),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border.all(color: Colors.grey.shade300),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          producer,
                          style: const TextStyle(fontSize: 12),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  // Info flags
                  Wrap(
                    spacing: 8,
                    children:
                        infoFlags.map((flag) {
                          return Text(
                            '• $flag',
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
                            ),
                          );
                        }).toList(),
                  ),
                  const SizedBox(height: 24),
                  // Review header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        '리뷰',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      GestureDetector(
                        onTap: () => _showAllReviewsModal(context, reviews),
                        child: const Text(
                          '더보기>',
                          style: TextStyle(fontSize: 14, color: Colors.grey),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  // Review Cards
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children:
                          reviews.map((rv) {
                            return GestureDetector(
                              onTap: () => _showReviewDetailModal(context, rv),
                              child: Container(
                                width: screenWidth * 0.7,
                                margin: const EdgeInsets.only(right: 16),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(12),
                                      child: Image.asset(
                                        imagePath,
                                        width: double.infinity,
                                        height: 120,
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      rv.content,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(fontSize: 13),
                                    ),
                                    const SizedBox(height: 4),
                                    Row(
                                      children: [
                                        for (int k = 0; k < rv.rating; k++)
                                          const Icon(
                                            Icons.star,
                                            size: 16,
                                            color: Colors.red,
                                          ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }).toList(),
                    ),
                  ),
                  const SizedBox(height: 24),
                  // 상세 정보
                  const Text(
                    '상세 정보',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Center(
                    child: Text(
                      '🍎 $title 🍎',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    '농장 고정고객분들께만 보내드리는 정품 꿀사과입니다. 농장에서 바로 보내드리는 사과는 조금이라도 다릅니다! 1인가구를 위한 소포장 구성도 추가하여 부담없이 드실 수 있어요. 서늘하고 일교차가 큰 충북괴산 사과 재배에 최적화됩니다😊',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 13, color: Colors.black87),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        '🍏 상품 문의',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      GestureDetector(
                        onTap: () => _showInquiryModal(context),
                        child: const Text(
                          '더보기>',
                          style: TextStyle(fontSize: 14, color: Colors.grey),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
          // Floating back button
          Positioned(
            top: statusBarHeight + screenHeight * 0.06 + 16,
            left: 16,
            child: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                padding: const EdgeInsets.all(8),
                child: Image.asset(
                  'assets/icons/goback.png',
                  width: 18,
                  height: 18,
                ),
              ),
            ),
          ),
          // Purchase button
          Positioned(
            bottom: bottomPadding + 16,
            left: 16,
            right: 16,
            child: SizedBox(
              height: buttonHeight,
              child: ElevatedButton(
                onPressed: _showPurchaseModal,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green.shade400,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: const Text(
                  '구매하기',
                  style: TextStyle(fontSize: 16, color: Colors.white),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ReviewDetailCard extends StatelessWidget {
  final String imagePath;
  final Review review;
  final VoidCallback onTapClose;

  const _ReviewDetailCard({
    Key? key,
    required this.imagePath,
    required this.review,
    required this.onTapClose,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
            child: Image.asset(imagePath, height: 180, fit: BoxFit.cover),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      review.title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Row(
                      children: [
                        for (int i = 0; i < review.rating; i++)
                          const Icon(Icons.star, size: 16, color: Colors.red),
                        const SizedBox(width: 4),
                        Text(
                          review.rating.toString(),
                          style: const TextStyle(fontSize: 12),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  review.date,
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
                const SizedBox(height: 8),
                Text(
                  review.content,
                  style: const TextStyle(fontSize: 13, color: Colors.black87),
                ),
                const SizedBox(height: 12),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        '판매자 답변',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        review.sellerReply,
                        style: const TextStyle(fontSize: 13),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// 모달 내부에서 리스트 ↔ 상세 전환 수행
class InquiryModalContent extends StatefulWidget {
  final List<Inquiry> inquiries;
  final String imagePath, title, producer, price, unit;

  const InquiryModalContent({
    Key? key,
    required this.inquiries,
    required this.imagePath,
    required this.title,
    required this.producer,
    required this.price,
    required this.unit,
  }) : super(key: key);

  @override
  _InquiryModalContentState createState() => _InquiryModalContentState();
}

class _InquiryModalContentState extends State<InquiryModalContent> {
  Inquiry? _selected; // null이면 리스트, non-null이면 상세

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).padding.bottom;
    return GestureDetector(
      onTap: () => Navigator.of(context).pop(),
      child: Container(
        color: Colors.black54,
        child: GestureDetector(
          onTap: () {},
          child: DraggableScrollableSheet(
            initialChildSize: 0.7,
            minChildSize: 0.4,
            maxChildSize: 0.9,
            builder:
                (_, controller) => Container(
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(12),
                    ),
                  ),
                  child: Column(
                    children: [
                      const SizedBox(height: 8),
                      Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      const SizedBox(height: 8),

                      // 2) 헤더: 뒤로가기 + 중앙 타이틀
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Row(
                          children: [
                            GestureDetector(
                              onTap: () {
                                if (_selected != null) {
                                  setState(() => _selected = null);
                                } else {
                                  Navigator.of(context).pop();
                                }
                              },
                              child: const Icon(Icons.arrow_back),
                            ),
                            Expanded(
                              child: Center(
                                child: Text(
                                  _selected == null ? '문의' : '문의 상세',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 24),
                          ],
                        ),
                      ),
                      const Divider(height: 1),

                      // 1) 제품 요약 카드 고정
                      const SizedBox(height: 8),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: _ProductSummaryCard(
                          imagePath: widget.imagePath,
                          title: widget.title,
                          producer: widget.producer,
                          price: widget.price,
                          unit: widget.unit,
                        ),
                      ),
                      const SizedBox(height: 8),

                      // 3-A) 리스트 모드
                      if (_selected == null) ...[
                        Expanded(
                          child: ListView.builder(
                            controller: controller,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                            itemCount: widget.inquiries.length,
                            itemBuilder: (_, i) {
                              final iq = widget.inquiries[i];
                              return _InquiryListCard(
                                inquiry: iq,
                                onTapMore: () => setState(() => _selected = iq),
                              );
                            },
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.only(
                            left: 16,
                            right: 16,
                            bottom: bottomPadding + 16,
                          ),
                          child: SizedBox(
                            height: 48,
                            child: ElevatedButton(
                              onPressed: () {
                                showModalBottomSheet(
                                  context: context,
                                  isScrollControlled: true,
                                  backgroundColor: Colors.transparent,
                                  builder: (_) => const NewInquiryModal(),
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF6FCF4B),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(30),
                                ),
                              ),
                              child: const Text(
                                '새 문의하기',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],

                      // 3-B) 상세 모드
                      if (_selected != null) ...[
                        Expanded(
                          child: SingleChildScrollView(
                            controller: controller,
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'Q: ',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Expanded(
                                      child: Text(
                                        _selected!.question,
                                        style: const TextStyle(fontSize: 13),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      _selected!.date,
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 16),
                                Container(
                                  width: double.infinity,
                                  decoration: BoxDecoration(
                                    color: Colors.grey[100],
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  padding: const EdgeInsets.all(12),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'A: ${_selected!.answer}',
                                        style: const TextStyle(
                                          fontSize: 13,
                                          color: Colors.black87,
                                        ),
                                      ),
                                      const SizedBox(height: 12),
                                      Row(
                                        children: [
                                          Text(
                                            '000농조합',
                                            style: const TextStyle(
                                              fontSize: 12,
                                              color: Colors.grey,
                                            ),
                                          ),
                                          const Spacer(),
                                          Text(
                                            _selected!.date,
                                            style: const TextStyle(
                                              fontSize: 12,
                                              color: Colors.grey,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
          ),
        ),
      ),
    );
  }
}

class _ProductSummaryCard extends StatelessWidget {
  final String imagePath, title, producer, price, unit;
  const _ProductSummaryCard({
    required this.imagePath,
    required this.title,
    required this.producer,
    required this.price,
    required this.unit,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Row(
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    producer,
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                  const SizedBox(height: 8),
                  const Text('1박스', style: TextStyle(fontSize: 12)),
                  const SizedBox(height: 4),
                  Text(
                    '$price / $unit',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
          ClipRRect(
            borderRadius: const BorderRadius.horizontal(
              right: Radius.circular(12),
            ),
            child: Image.asset(
              imagePath,
              width: 80,
              height: 80,
              fit: BoxFit.cover,
            ),
          ),
        ],
      ),
    );
  }
}

class _InquiryListCard extends StatelessWidget {
  final Inquiry inquiry;
  final VoidCallback onTapMore;
  const _InquiryListCard({required this.inquiry, required this.onTapMore});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    'Q: ${inquiry.question}',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 13),
                  ),
                ),
                GestureDetector(
                  onTap: onTapMore,
                  child: const Text(
                    '더보기>',
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'A: ${inquiry.answered ? inquiry.answer : '답변 대기중'}',
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 12,
                color: inquiry.answered ? Colors.black87 : Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class NewInquiryModal extends StatelessWidget {
  const NewInquiryModal({super.key});

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).padding.bottom;
    final controller = TextEditingController();

    return GestureDetector(
      onTap: () => Navigator.of(context).pop(),
      child: Container(
        color: Colors.black54,
        child: GestureDetector(
          onTap: () {},
          child: DraggableScrollableSheet(
            initialChildSize: 0.6,
            minChildSize: 0.4,
            maxChildSize: 0.9,
            builder:
                (_, scrollController) => Container(
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(16),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 8),
                      Center(
                        child: Container(
                          width: 40,
                          height: 4,
                          decoration: BoxDecoration(
                            color: Colors.grey[300],
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Row(
                          children: [
                            GestureDetector(
                              onTap: () => Navigator.of(context).pop(),
                              child: const Icon(Icons.arrow_back),
                            ),
                            const Spacer(),
                            const Text(
                              '문의',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const Spacer(),
                            const SizedBox(width: 24),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: const Text(
                          '내용',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.grey[50],
                            border: Border.all(color: Colors.grey.shade300),
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black12,
                                blurRadius: 2,
                                offset: Offset(0, 1),
                              ),
                            ],
                          ),
                          child: TextField(
                            controller: controller,
                            maxLines: 6,
                            decoration: const InputDecoration(
                              contentPadding: EdgeInsets.all(12),
                              hintText: '내용을 입력해 주세요.',
                              border: InputBorder.none,
                            ),
                          ),
                        ),
                      ),
                      const Spacer(),
                      Padding(
                        padding: EdgeInsets.fromLTRB(
                          16,
                          8,
                          16,
                          bottomPadding + 16,
                        ),
                        child: SizedBox(
                          width: double.infinity,
                          height: 48,
                          child: ElevatedButton(
                            onPressed: () {},
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF6FCF4B),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                            ),
                            child: const Text(
                              '문의 업로드하기',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
          ),
        ),
      ),
    );
  }
}

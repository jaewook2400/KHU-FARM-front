import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CartItem {
  final String title;
  final String producer;
  final String price;
  final String unit;
  final String imagePath;
  final int quantity;
  final bool selected;

  CartItem({
    required this.title,
    required this.producer,
    required this.price,
    required this.unit,
    required this.imagePath,
    required this.quantity,
    required this.selected,
  });
}

class ConsumerCartScreen extends StatelessWidget {
  const ConsumerCartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
      ),
    );

    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final statusBarHeight = MediaQuery.of(context).padding.top;

    final List<CartItem> cartItems = [
      CartItem(
        title: '못난이 꿀사과 5kg 가정용 특가',
        producer: '라이코스 농협',
        price: '10,000원',
        unit: '5kg',
        imagePath: 'assets/mascot/login_mascot.png',
        quantity: 1,
        selected: true,
      ),
      CartItem(
        title: '사과 꿀맛 과즙폭발 세척',
        producer: '정직한 농장',
        price: '15,000원',
        unit: '5kg',
        imagePath: 'assets/mascot/login_mascot.png',
        quantity: 2,
        selected: true,
      ),
      CartItem(
        title: '사과 꿀맛 과즙폭발 세척',
        producer: '정직한 농장',
        price: '15,000원',
        unit: '5kg',
        imagePath: 'assets/mascot/login_mascot.png',
        quantity: 2,
        selected: true,
      ),
      CartItem(
        title: '사과 꿀맛 과즙폭발 세척',
        producer: '정직한 농장',
        price: '15,000원',
        unit: '5kg',
        imagePath: 'assets/mascot/login_mascot.png',
        quantity: 2,
        selected: true,
      ),
      CartItem(
        title: '사과 꿀맛 과즙폭발 세척',
        producer: '정직한 농장',
        price: '15,000원',
        unit: '5kg',
        imagePath: 'assets/mascot/login_mascot.png',
        quantity: 2,
        selected: true,
      ),
      CartItem(
        title: '사과 꿀맛 과즙폭발 세척',
        producer: '정직한 농장',
        price: '15,000원',
        unit: '5kg',
        imagePath: 'assets/mascot/login_mascot.png',
        quantity: 2,
        selected: true,
      ),
      CartItem(
        title: '사과 꿀맛 과즙폭발 세척',
        producer: '정직한 농장',
        price: '15,000원',
        unit: '5kg',
        imagePath: 'assets/mascot/login_mascot.png',
        quantity: 2,
        selected: true,
      ),
      CartItem(
        title: '사과 꿀맛 과즙폭발 세척',
        producer: '정직한 농장',
        price: '15,000원',
        unit: '5kg',
        imagePath: 'assets/mascot/login_mascot.png',
        quantity: 2,
        selected: true,
      ),
      CartItem(
        title: '사과 꿀맛 과즙폭발 세척',
        producer: '정직한 농장',
        price: '15,000원',
        unit: '5kg',
        imagePath: 'assets/mascot/login_mascot.png',
        quantity: 2,
        selected: true,
      ),
    ];

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
                        Navigator.pushNamed(context, '/consumer/dib/list');
                      },
                      child: Image.asset(
                        'assets/top_icons/dibs.png',
                        width: 24,
                        height: 24,
                      ),
                    ),
                    const SizedBox(width: 12),
                    GestureDetector(
                      onTap: () {},
                      child: Image.asset(
                        'assets/top_icons/cart_selected_morning.png',
                        width: 24,
                        height: 24,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          Padding(
            padding: EdgeInsets.only(
              top: statusBarHeight + screenHeight * 0.06 + 20,
              left: screenWidth * 0.08,
              right: screenWidth * 0.08,
              bottom: 20,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ← 뒤로 + 제목
                Row(
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Image.asset(
                        'assets/icons/goback.png',
                        width: 18,
                        height: 18,
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      '장바구니',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),

                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Checkbox(value: true, onChanged: (_) {}),
                            const Text('전체선택', style: TextStyle(fontSize: 14)),
                          ],
                        ),
                        const SizedBox(height: 8),
                        ...cartItems.map((item) {
                          return Container(
                            margin: const EdgeInsets.only(bottom: 16),
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black12,
                                  blurRadius: 4,
                                  offset: Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Row(
                              children: [
                                Column(
                                  children: [
                                    Checkbox(
                                      value: item.selected,
                                      onChanged: (_) {},
                                    ),
                                    Row(
                                      children: [
                                        IconButton(
                                          onPressed: () {},
                                          icon: const Icon(Icons.remove),
                                        ),
                                        Text(item.quantity.toString()),
                                        IconButton(
                                          onPressed: () {},
                                          icon: const Icon(Icons.add),
                                        ),
                                      ],
                                    ),
                                    const Text('박스'),
                                  ],
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        item.title,
                                        style: const TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        item.producer,
                                        style: const TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        '${item.price} / ${item.unit}',
                                        style: const TextStyle(fontSize: 14),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 8),
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: Image.asset(
                                    item.imagePath,
                                    width: 80,
                                    height: 80,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                        const Divider(thickness: 1.0, height: 32),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: const [
                            Text(
                              '결제 예상 금액',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            Text(
                              '15,000원',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: const [Text('상품 금액'), Text('10,000원')],
                        ),
                        const SizedBox(height: 4),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: const [Text('배송비'), Text('5,000원')],
                        ),
                        const SizedBox(height: 80),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            bottom: 16,
            left: 16,
            right: 16,
            child: SizedBox(
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
                  '15,000원 결제하기',
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

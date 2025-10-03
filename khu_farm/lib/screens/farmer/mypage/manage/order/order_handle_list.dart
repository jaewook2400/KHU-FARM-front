import 'package:flutter/material.dart';
import 'package:khu_farm/shared/text_styles.dart';

enum OrderSection { newOrder, shipping, refund, cancelled }

class OrderPageArgs {
  final OrderSection section;
  const OrderPageArgs(this.section);
}


class OrderHandleListPage extends StatefulWidget {
  const OrderHandleListPage({Key? key}) : super(key: key);

  @override
  State<OrderHandleListPage> createState() => _OrderHandleListPageState();
}

class _OrderHandleListPageState extends State<OrderHandleListPage> {
  String? selectedPeriod;
  String? selectedStatus;

  final List<String> periodOptions = ['1개월', '2개월', '4개월', '6개월'];

  final Map<String, String> statusOptions = {
    '결제 완료': 'ORDER_COMPLETED',
    '배송 중': 'SHIPPING',
    '배송 완료': 'SHIPMENT_COMPLETED',
    '결제 취소': 'ORDER_CANCELLED',
    '환불 대기': 'REFUND_REQUESTED',
  };

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final statusBarHeight = MediaQuery.of(context).padding.top;
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return Scaffold(
      extendBodyBehindAppBar: true, // 요구사항 반영
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
                      '/farmer/main',
                          (route) => false,
                    );
                  },
                  child: const Text(
                    'KHU:FARM',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: 'LogoFont',
                      fontSize: 22,
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
                          '/farmer/notification/list',
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
                        Navigator.pushNamed(context, '/farmer/dib/list');
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
                        Navigator.pushNamed(context, '/farmer/cart/list');
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
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: screenHeight*0.1,),
                Row(
                  children: [
                    const SizedBox(width: 8),
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Image.asset(
                        'assets/icons/goback.png',
                        width: 18,
                        height: 18,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '주문 내역 / 환불 대기',
                      style: AppTextStyles.pretendard_black,
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                // 주문 내역 확인 텍스트
                Text(
                  "주문 내역 확인",
                  style: AppTextStyles.pretendard_black,
                ),

                const SizedBox(height: 10),

                // 컨테이너 4개 (각 색상 적용)
                _buildOrderButton(
                  color: const Color(0xFF4CCCEE),
                  title: "NEW! 신규 주문",
                  subtitle: "결제가 완료된 신규 주문 목록입니다. 배송 작업을 진행해주세요.",
                  onTap: () {
                    Navigator.pushNamed(
                      context,
                      '/farmer/mypage/manage/order',
                      arguments: const OrderPageArgs(OrderSection.newOrder),
                    );
                  },
                ),
                _buildOrderButton(
                  color: const Color(0xFF75EBA7),
                  title: "배송 현황",
                  subtitle: "상품 배송 현황을 확인하세요.",
                  onTap: () {
                    Navigator.pushNamed(
                      context,
                      '/farmer/mypage/manage/order',
                      arguments: const OrderPageArgs(OrderSection.shipping),
                    );
                  },
                ),

                const SizedBox(height: 20),
                Text(
                  "환불 관리",
                  style: AppTextStyles.pretendard_black,
                ),

                const SizedBox(height: 10),

                _buildOrderButton(
                  color: const Color(0xFFFD7F7F),
                  title: "환불 처리",
                  subtitle: "환불 내역을 확인하고 승인할 수 있습니다.",
                  onTap: () {
                    Navigator.pushNamed(
                      context,
                      '/farmer/mypage/manage/order',
                      arguments: const OrderPageArgs(OrderSection.refund),
                    );
                  },
                ),
                _buildOrderButton(
                  color: const Color(0xFFB3B0B0),
                  title: "결제 취소",
                  subtitle: "환불 처리 후 결제가 취소된 주문 목록입니다.",
                  onTap: () {
                    Navigator.pushNamed(
                      context,
                      '/farmer/mypage/manage/order',
                      arguments: const OrderPageArgs(OrderSection.cancelled),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderButton({
    required Color color,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        title: Text(title, style: AppTextStyles.pretendard_black_white),
        subtitle: Text(subtitle, style: AppTextStyles.pretendard_regular,),
        trailing: const Icon(Icons.arrow_forward_ios, size: 17, color: Color(0xFFFFFFFF),),
        onTap: onTap,
      ),
    );
  }
}

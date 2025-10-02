import 'package:flutter/material.dart';

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
    return Scaffold(
      extendBodyBehindAppBar: true, // 요구사항 반영
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
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
                      '주문 내역 / 환불 대기',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16,),
                // 드롭다운 (기간 / 상태)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // 기간 선택
                    DropdownButton<String>(
                      hint: const Text("기간"),
                      value: selectedPeriod,
                      items: periodOptions.map((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                      onChanged: (String? newValue) {
                        setState(() {
                          selectedPeriod = newValue;
                        });
                      },
                    ),
                    // 상태 선택
                    DropdownButton<String>(
                      hint: const Text("상태"),
                      value: selectedStatus,
                      items: statusOptions.entries.map((entry) {
                        return DropdownMenuItem<String>(
                          value: entry.value,
                          child: Text(entry.key),
                        );
                      }).toList(),
                      onChanged: (String? newValue) {
                        setState(() {
                          selectedStatus = newValue;
                        });
                      },
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                // 주문 내역 확인 텍스트
                const Text(
                  "주문 내역 확인",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
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
                const Text(
                  "환불 관리",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),

                const SizedBox(height: 10),

                _buildOrderButton(
                  color: const Color(0xFFFD7FDF),
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
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: onTap,
      ),
    );
  }
}

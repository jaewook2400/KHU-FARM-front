import 'package:flutter/material.dart';

class CheckoutScreen extends StatelessWidget {
  const CheckoutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('결제하기', style: TextStyle(color: Colors.black)),
        centerTitle: false,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      bottomNavigationBar: Container(
        height: 60,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: ElevatedButton(
          onPressed: () {},
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFB9804F),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30),
            ),
          ),
          child: const Text('15,000원 결제하기', style: TextStyle(fontSize: 16)),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),
            const Text('배송지', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('홍길동 | 010-0000-0000'),
                  const Text('서울시 OO구 OO동 123-12 101호 [00000]'),
                  const SizedBox(height: 8),
                  Align(
                    alignment: Alignment.centerRight,
                    child: OutlinedButton(
                      onPressed: () {},
                      child: const Text('수정'),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: const [
                Text('주문 상품', style: TextStyle(fontWeight: FontWeight.bold)),
                Text('1개'),
              ],
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(color: Colors.black12, blurRadius: 4),
                ],
              ),
              child: Row(
                children: [
                  Expanded(
                    flex: 7,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text('못난이 꿀사과 5kg 가정용 특가',
                            style: TextStyle(fontWeight: FontWeight.bold)),
                        SizedBox(height: 4),
                        Text('라이코스 농협', style: TextStyle(color: Colors.grey)),
                        SizedBox(height: 8),
                        Text('1박스'),
                        SizedBox(height: 4),
                        Text('10,000원 / 5kg',
                            style: TextStyle(fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.asset(
                      'assets/sample/apple.jpg', // 실제 이미지 경로로 교체
                      width: 80,
                      height: 80,
                      fit: BoxFit.cover,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            const Text('결제 수단', style: TextStyle(fontWeight: FontWeight.bold)),
            Column(
              children: [
                RadioListTile(
                  title: const Text('토스페이'),
                  value: 'toss',
                  groupValue: 'toss',
                  onChanged: (_) {},
                ),
                RadioListTile(
                  title: const Text('카카오페이'),
                  value: 'kakao',
                  groupValue: 'toss',
                  onChanged: (_) {},
                ),
                RadioListTile(
                  title: const Text('계좌 간편결제'),
                  value: 'account',
                  groupValue: 'toss',
                  onChanged: (_) {},
                ),
              ],
            ),
            const Divider(height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: const [
                Text('총 결제금액', style: TextStyle(fontWeight: FontWeight.bold)),
                Text('10,000원', style: TextStyle(fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: const [Text('상품 금액'), Text('10,000원')],
            ),
            const Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [Text('배송비'), Text('무료', style: TextStyle(color: Colors.red))],
            ),
            const Divider(height: 32),
            const Text('▢ 주문 내용을 확인 및 결제 모두 동의'),
            const SizedBox(height: 8),
            const Text('▢ (필수) 개인정보 수집, 이용 동의  >', style: TextStyle(fontSize: 12)),
            const Text('▢ (필수) 제3자 정보 제공 동의       >', style: TextStyle(fontSize: 12)),
            const Text('▢ (필수) 전자금융 서비스 이용약관 동의 >', style: TextStyle(fontSize: 12)),
            const Text('▢ (필수) 공통 결제대행 개인정보 수집 및 이용 동의 >',
                style: TextStyle(fontSize: 12)),
            const SizedBox(height: 120),
          ],
        ),
      ),
    );
  }
}

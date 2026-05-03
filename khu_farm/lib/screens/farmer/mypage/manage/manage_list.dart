import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../shared/widgets/top_norch_header.dart';

class FarmerManageListScreen extends StatelessWidget {
  const FarmerManageListScreen({super.key});

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

    return Scaffold(
      extendBodyBehindAppBar: true,

      body: Stack(
        children: [
          FarmerTopNotchHeader(),

          // 콘텐츠
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
                      '우리 농가 관리하기',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                // 상품 관리 섹션
                const Text(
                  '상품 관리',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                _SectionItem(label: '제품 추가하기', onTap: () {
                  Navigator.pushNamed(context, '/farmer/mypage/manage/product/add');
                }),
                _SectionItem(label: '제품 관리하기', onTap: () {
                  Navigator.pushNamed(context, '/farmer/mypage/manage/product');
                }),
                _SectionItem(label: '리뷰 관리', onTap: () {
                  Navigator.pushNamed(context, '/farmer/mypage/manage/review');
                }),
                _SectionItem(label: '받은 문의', onTap: () {
                  Navigator.pushNamed(context, '/farmer/mypage/manage/inquiry');
                }),
                const Divider(height: 30),

                // 농가 관리 섹션
                // const Text(
                //   '농가 관리',
                //   style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                // ),
                // const SizedBox(height: 10),
                // _SectionItem(label: '우리 농가 설명', onTap: () {
                //   // TODO: 우리 농가 설명 화면으로 이동
                // }),
                // const Divider(),
                const Text(
                  '주문 관리',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                _SectionItem(label: '주문 내역 / 환불 대기', onTap: () {
                  Navigator.pushNamed(context, '/farmer/mypage/manage/neworder');
                }),
              ],
            ),
          )
        ],
      ),
    );
  }
}

class _SectionItem extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _SectionItem({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 14),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: const TextStyle(fontSize: 16)),
            const Icon(Icons.chevron_right, size: 20),
          ],
        ),
      ),
    );
  }
}
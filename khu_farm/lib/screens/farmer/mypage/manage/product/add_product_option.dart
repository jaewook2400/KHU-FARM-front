import 'package:flutter/material.dart';
import 'package:khu_farm/shared/widgets/top_norch_header.dart';

class AddProductOptionPage extends StatefulWidget {
  final String productName;

  const AddProductOptionPage({
    super.key,
    required this.productName,
  });

  @override
  State<AddProductOptionPage> createState() => _AddProductOptionPageState();
}

class _AddProductOptionPageState extends State<AddProductOptionPage> {
  final _titleController = TextEditingController();
  // 중량 세트 데이터 리스트
  final List<Map<String, TextEditingController>> _weightSets = [];

  @override
  void initState() {
    super.initState();
    _addWeightSet(); // 기본 1세트 추가
  }

  // 중량 세트 추가
  void _addWeightSet() {
    setState(() {
      _weightSets.add({
        'weight': TextEditingController(),
        'price': TextEditingController(),
        'stock': TextEditingController(),
      });
    });
  }

  // 중량 세트 제거
  void _removeWeightSet(int index) {
    setState(() {
      _weightSets.removeAt(index);
    });
  }

  // 데이터 저장
  void _saveOption() {
    final Map<String, dynamic> optionList = {};
    final List<Map<String, dynamic>> weightList = [];

    for (var set in _weightSets) {
      final weight = set['weight']!.text.trim();
      final price = set['price']!.text.trim();
      final stock = set['stock']!.text.trim();

      if (weight.isEmpty || price.isEmpty || stock.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('모든 항목을 입력해주세요.')),
        );
        return;
      }

      weightList.add({
        'weight': int.parse(weight),
        'price': int.parse(price),
        'stock': int.parse(stock),
      });
    }

    optionList['weight'] = weightList;

    if (_titleController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('상품 제목을 입력해주세요.')),
      );
      return;
    }
    optionList['title'] = _titleController.text.trim();

    Navigator.pop(context, optionList);
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final statusBarHeight = MediaQuery.of(context).padding.top;
    final bottomPadding = MediaQuery.of(context).padding.bottom;
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          FarmerTopNotchHeader(),

          /// 상단 제목 + 뒤로가기
          Positioned(
            top: statusBarHeight + screenHeight * 0.06 + 20,
            left: screenWidth * 0.08,
            right: screenWidth * 0.08,
            child: Row(
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
                  '옵션 설정하기',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Spacer(),
                Text(
                  widget.productName ?? '', //아직 name을 적지 않았을 경우
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.black54,
                  ),
                ),
                SizedBox(width: screenWidth*0.2),
              ],
            ),
          ),

          /// 콘텐츠 영역
          Positioned.fill(
            top: statusBarHeight + screenHeight * 0.08 + 60,
            bottom: bottomPadding + 80,
            left: screenWidth * 0.06,
            right: screenWidth * 0.06,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                /// 옵션 제목 라벨
                const Text(
                  '옵션 제목',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 6),

                /// 옵션 제목 입력창
                TextField(
                  controller: _titleController,
                  keyboardType: TextInputType.text,
                  decoration: InputDecoration(
                    hintText: '제목을 입력해 주세요. (예: 못난이 꿀사과, 정품 꿀사과)',
                    hintStyle: TextStyle(
                      color: Color(0xFFBDBDBD), // 더 연한 힌트 텍스트 (#BDBDBD~C8C8C8 느낌)
                      fontSize: 14,
                    ),
                    filled: true,
                    fillColor: Color(0xFFFAFAFA), // 더 밝은 회색 (스크린샷 느낌)
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14), // 더 큰 radius → UI와 동일
                      borderSide: const BorderSide(
                        color: Color(0xFFEDEDED), // 아주 연한 회색 border
                        width: 1,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: const BorderSide(
                        color: Color(0xFFBDBDBD), // 포커스 시에도 너무 진해지지 않게
                        width: 1,
                      ),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      vertical: 9, // 더 세로로 여유 있게, UI와 비슷하게
                      horizontal: 16,
                    ),
                  ),
                ),

                const SizedBox(height: 18),

                /// 중량 리스트
                Expanded(
                  child: ListView.builder(
                    itemCount: _weightSets.length,
                    itemBuilder: (context, index) {
                      final set = _weightSets[index];
                      return Container(
                        margin: const EdgeInsets.only(bottom: 20),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Color(0xFFF5F5F5),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            /// 상품 n 라벨 + 삭제 버튼
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  '상품 ${index + 1}',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 15,
                                  ),
                                ),
                                if (_weightSets.length > 1)
                                  IconButton(
                                    icon: const Icon(Icons.delete_outline),
                                    onPressed: () => _removeWeightSet(index),
                                    color: Colors.grey,
                                  ),
                              ],
                            ),

                            const SizedBox(height: 12),

                            /// 상품 중량
                            const Text(
                              '상품 중량 (수량 1개)',
                              style: TextStyle(
                                fontWeight: FontWeight.w500,
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(height: 6),
                            TextField(
                              controller: set['weight'],
                              keyboardType: TextInputType.number,
                              decoration: InputDecoration(
                                hintText: 'kg단위, 숫자만 입력해 주세요.',
                                hintStyle: const TextStyle(
                                  color: Color(0xFFBDBDBD), // 연한 hint 텍스트
                                  fontSize: 14,
                                ),
                                suffixText: 'kg',
                                suffixStyle: const TextStyle(
                                  color: Colors.black87,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                ),
                                filled: true,
                                fillColor: const Color(0xFFFAFAFA), // 더 밝은 회색 배경
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(14),
                                  borderSide: const BorderSide(
                                    color: Color(0xFFEDEDED), // 아주 연한 border
                                    width: 1,
                                  ),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(14),
                                  borderSide: const BorderSide(
                                    color: Color(0xFFBDBDBD),
                                    width: 1,
                                  ),
                                ),
                                contentPadding: const EdgeInsets.symmetric(
                                  vertical: 9,
                                  horizontal: 16,
                                ),
                              ),
                            ),

                            const SizedBox(height: 16),

                            /// 상품 가격
                            const Text(
                              '상품 가격',
                              style: TextStyle(
                                fontWeight: FontWeight.w500,
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(height: 6),
                            TextField(
                              controller: set['price'],
                              keyboardType: TextInputType.number,
                              decoration: InputDecoration(
                                hintText: '상품 가격을 입력해 주세요.',
                                hintStyle: const TextStyle(
                                  color: Color(0xFFBDBDBD),
                                  fontSize: 14,
                                ),
                                suffixText: '원',
                                suffixStyle: const TextStyle(
                                  color: Colors.black87,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                ),
                                filled: true,
                                fillColor: Color(0xFFFAFAFA),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(14),
                                  borderSide: BorderSide(
                                    color: Color(0xFFEDEDED),
                                    width: 1,
                                  ),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(14),
                                  borderSide: BorderSide(
                                    color: Color(0xFFBDBDBD),
                                    width: 1,
                                  ),
                                ),
                                contentPadding: const EdgeInsets.symmetric(
                                  vertical: 9,   // ✅ 요청한 세로 padding 9
                                  horizontal: 16,
                                ),
                              ),
                            ),

                            const SizedBox(height: 16),

                            /// 재고
                            const Text(
                              '준비된 재고',
                              style: TextStyle(
                                fontWeight: FontWeight.w500,
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(height: 6),
                            TextField(
                              controller: set['stock'],
                              keyboardType: TextInputType.number,
                              decoration: InputDecoration(
                                hintText: '박스단위, 숫자만 입력해 주세요.',
                                hintStyle: const TextStyle(
                                  color: Color(0xFFBDBDBD), // 연한 회색 힌트
                                  fontSize: 14,
                                ),
                                suffixText: '박스',
                                suffixStyle: const TextStyle(
                                  color: Colors.black87,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                ),
                                filled: true,
                                fillColor: Color(0xFFFAFAFA), // 아주 밝은 회색 배경
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(14), // 더 둥근 radius (스크린샷 스타일)
                                  borderSide: BorderSide(
                                    color: Color(0xFFEDEDED), // 매우 연한 border
                                    width: 1,
                                  ),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(14),
                                  borderSide: BorderSide(
                                    color: Color(0xFFBDBDBD),
                                    width: 1,
                                  ),
                                ),
                                contentPadding: const EdgeInsets.symmetric(
                                  vertical: 9,     // ✅ 요청한 padding 9
                                  horizontal: 16,
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),

                /// 중량 추가하기 버튼
                OutlinedButton(
                  onPressed: _addWeightSet,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.green.shade700,
                    side: BorderSide(color: Colors.green.shade400),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    minimumSize: const Size(double.infinity, 48),
                  ),
                  child: const Text('+ 중량 추가하기'),
                ),

                const SizedBox(height: 20),
              ],
            ),
          ),

          /// 하단 고정 버튼
          Positioned(
            bottom: bottomPadding + 20,
            left: 20,
            right: 20,
            child: ElevatedButton(
              onPressed: _saveOption,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF6FCF4B),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                minimumSize: const Size(double.infinity, 50),
              ),
              child: const Text(
                '다음',
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

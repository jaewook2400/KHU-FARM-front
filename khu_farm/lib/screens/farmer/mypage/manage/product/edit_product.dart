import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:khu_farm/constants.dart';
import 'package:khu_farm/model/fruit.dart';

class FarmerEditProductScreen extends StatefulWidget {
  const FarmerEditProductScreen({super.key});

  @override
  State<FarmerEditProductScreen> createState() => _FarmerEditProductScreenState();
}

class _FarmerEditProductScreenState extends State<FarmerEditProductScreen> {
  late Fruit _fruit;
  bool _isInitialized = false;

  int? selectedCategory;
  int? selectedType; // 'daily' or 'stock'
  String? _horizontalImagePath;
  String? _squareImagePath;
  String? _selectedCourierId;

  final _titleController = TextEditingController();
  final _priceController = TextEditingController();
  final _weightController = TextEditingController();
  final _stockController = TextEditingController();
  final _normalShippingController = TextEditingController();
  final _islandShippingController = TextEditingController();
  final _maxDeliveryController = TextEditingController();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    
    if (!_isInitialized) {
      // ModalRoute로부터 Fruit 객체를 가져옵니다.
      _fruit = ModalRoute.of(context)!.settings.arguments as Fruit;
      _initializeFields();
      // 초기화가 끝났음을 표시
      _isInitialized = true;
    }
  }

  void _initializeFields() {
    _titleController.text = _fruit.title;
    _priceController.text = _fruit.price.toString();
    _weightController.text = _fruit.weight.toString();
    _stockController.text = _fruit.stock.toString();

    // ✅ 최대 배송 준비 기간을 fruit.deliveryDay 값으로 설정
    _maxDeliveryController.text = _fruit.deliveryDay.toString();

    // ✅ 배송비 필드를 '0'으로 초기화
    _normalShippingController.text = '0';
    _islandShippingController.text = '0';

    selectedCategory = _fruit.fruitCategoryId;
    selectedType = _fruit.wholesaleRetailCategoryId;

    _horizontalImagePath = _fruit.widthImageUrl;
    _squareImagePath = _fruit.squareImageUrl;

    final courier = deliveryCompany.firstWhere(
      (c) {
        final String? companyId = c['id'];
        if (companyId == null) return false;

        // "kr.epost" -> "EPOST" 형태로 변환
        final transformedId = companyId.replaceFirst('kr.', '').toUpperCase();
        
        // 변환된 ID와 fruit 객체의 deliveryCompany 값을 비교
        return transformedId == _fruit.deliveryCompany;
      },
      orElse: () => {}, // 일치하는 항목이 없으면 빈 Map 반환
    );
    
    if (courier.isNotEmpty) {
      _selectedCourierId = courier['id'];
    }
  }


  @override
  void dispose() {
    _titleController.dispose();
    _priceController.dispose();
    _weightController.dispose();
    _stockController.dispose();
    _normalShippingController.dispose();
    _islandShippingController.dispose();
    _maxDeliveryController.dispose();
    super.dispose();
  }

  bool get _allFieldsFilled {
    return _titleController.text.isNotEmpty &&
      _priceController.text.isNotEmpty &&
      _weightController.text.isNotEmpty &&
      _stockController.text.isNotEmpty &&
      _selectedCourierId != null &&
      _normalShippingController.text.isNotEmpty &&
      _islandShippingController.text.isNotEmpty &&
      _maxDeliveryController.text.isNotEmpty &&
      selectedCategory != null;
  }

  Future<void> _pickImage(ValueChanged<String> onImageSelected) async {
    final picked = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (picked != null) onImageSelected(picked.path);
  }

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
    final bottomPadding = MediaQuery.of(context).padding.bottom;
  
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
                    // GestureDetector(
                    //   onTap: () {
                    //     Navigator.pushNamed(
                    //       context,
                    //       '/farmer/notification/list',
                    //     );
                    //   },
                    //   child: Image.asset(
                    //     'assets/top_icons/notice.png',
                    //     width: 24,
                    //     height: 24,
                    //   ),
                    // ),
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

          Positioned(
            top: statusBarHeight + screenHeight * 0.06 + 20,
            left: screenWidth * 0.08,
            right: screenWidth * 0.08,
            child: Row(
              children: [
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Image.asset('assets/icons/goback.png', width: 18, height: 18),
                ),
                const SizedBox(width: 8),
                const Text('제품 수정하기', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
              ],
            ),
          ),

          // 콘텐츠
          Positioned.fill(
            top: statusBarHeight + screenHeight * 0.06 + 60,
            bottom: 48 + 30 + bottomPadding,
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 분류 드롭다운
                  Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(30),
                      color: Colors.white,
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 4,
                          offset: Offset(1, 2),
                        )
                      ],
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<int>(
                        hint: const Text('분류를 선택해 주세요.'),
                        value: selectedCategory,
                        isExpanded: true,
                        onChanged: (value) => setState(() => selectedCategory = value),
                        items: fruitsCategory.map((fruit) {
                          return DropdownMenuItem<int>(
                            // value는 고유한 값이어야 하므로 index 대신 fruitId를 사용하는 것이 좋습니다.
                            value: fruit['fruitId'] as int,
                            child: Text(fruit['fruitName'] as String),
                          );
                        }).toList(),
                      ),
                    ),
                  ),

                  // 소매 / 도매 토글 버튼
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildToggleButton('Daily(소매)', 2),
                      const SizedBox(width: 10),
                      _buildToggleButton('Stock(도매)', 1),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // 미리보기 이미지 업로드 (가로형 + 정방형)
                  _buildImageUpload(
                    label: '미리보기 이미지 (가로형)',
                    imagePath: _horizontalImagePath,
                    onImageSelected: (path) => setState(() => _horizontalImagePath = path),
                  ),
                  _buildImageUpload(
                    label: '미리보기 이미지 (정방형)',
                    imagePath: _squareImagePath,
                    onImageSelected: (path) => setState(() => _squareImagePath = path),
                  ),

                  buildLabeledTextField(
                    "상품 제목",
                    "제목을 입력해 주세요.",
                    controller: _titleController,
                  ),
                  buildLabeledTextField(
                    "상품 가격",
                    "상품 가격을 입력해 주세요.",
                    controller: _priceController,
                  ),
                  buildLabeledTextField(
                    "상품 중량 (수량 1개)",
                    "kg단위, 숫자만 입력해 주세요.",
                    suffix: "kg",
                    controller: _weightController,
                  ),
                  buildLabeledTextField(
                    "준비된 재고",
                    "박스단위, 숫자만 입력해 주세요.",
                    suffix: "박스",
                    controller: _stockController,
                  ),
                  _buildCourierDropdown(),
                  Row(
                    children: [
                      Expanded(
                        child: buildLabeledTextField(
                          "일반 택배비용",
                          "일반 택배비용",
                          controller: _normalShippingController,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: buildLabeledTextField(
                          "도서산간 택배비용",
                          "도서산간 택배비용",
                          controller: _islandShippingController,
                        ),
                      ),
                    ],
                  ),
                  buildLabeledTextField(
                    "최대 배송 준비기간",
                    "N",
                    suffix: "일",
                    controller: _maxDeliveryController,
                  ),
                ],
              ),
            ),
          ),

          // 고정된 하단 버튼
          Positioned(
            bottom: bottomPadding + 20,
            left: 24,
            right: 24,
            child: SizedBox(
              height: 48,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  // _allFieldsFilled getter가 버튼 활성화 여부를 결정합니다.
                  backgroundColor: _allFieldsFilled ? const Color(0xFF6FCF4B) : Colors.grey.shade400,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                onPressed: _allFieldsFilled
                    ? () {
                        final selectedCourier = deliveryCompany.firstWhere(
                          (company) => company['id'] == _selectedCourierId,
                          orElse: () => {},
                        );
                        final courierName = selectedCourier['name'];
                        
                        // --- 🔽 arguments에 기존 _fruit 객체 추가 🔽 ---
                        Navigator.pushNamed(
                          context,
                          // TODO: 추후 '/farmer/mypage/manage/product/add/detail' 경로를 수정 경로로 변경해야 합니다.
                          '/farmer/mypage/manage/product/edit/detail',
                          arguments: {
                            // 기존 상품 정보
                            'originalFruit': _fruit, 
                            // 사용자가 수정한 정보
                            'editedData': {
                              'category': selectedCategory,
                              'type': selectedType,
                              'horizontalImagePath': _horizontalImagePath,
                              'squareImagePath': _squareImagePath,
                              'title': _titleController.text,
                              'price': _priceController.text,
                              'weight': _weightController.text,
                              'stock': _stockController.text,
                              'courier': courierName,
                              'normalShipping': _normalShippingController.text,
                              'islandShipping': _islandShippingController.text,
                              'maxDelivery': _maxDeliveryController.text,
                            },
                          },
                        );
                        // --- 🔼 수정 끝 🔼 ---
                      }
                    : null,
                child: const Text(
                  '다음', // 또는 '수정하기'
                  style: TextStyle(fontSize: 16, color: Colors.white),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCourierDropdown() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('택배사', style: TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(height: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.grey),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: _selectedCourierId,
                isExpanded: true,
                hint: const Text('이용하시는 택배사를 선택해 주세요.'),
                onChanged: (String? newValue) {
                  setState(() {
                    _selectedCourierId = newValue;
                  });
                },
                items: deliveryCompany.map<DropdownMenuItem<String>>((company) {
                  return DropdownMenuItem<String>(
                    value: company['id'],
                    child: Text(company['name']!),
                  );
                }).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildToggleButton(String label, int type) {
    final selected = selectedType == type;
    return GestureDetector(
      onTap: () => setState(() => selectedType = type),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? Colors.green[100] : Colors.transparent,
          border: Border.all(color: Colors.green),
          borderRadius: BorderRadius.circular(30),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: Colors.green[800],
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Widget _buildImageUpload({
    required String label,
    required String? imagePath,
    required ValueChanged<String> onImageSelected,
  }) {
    Widget imageWidget;
    if (imagePath == null || imagePath.isEmpty) {
      imageWidget = const SizedBox(); // 이미지가 없는 경우
    } else if (imagePath.startsWith('http')) {
      // 네트워크 URL인 경우 Image.network 사용
      imageWidget = Image.network(imagePath, width: 80, height: 80, fit: BoxFit.cover);
    } else {
      // 로컬 파일 경로인 경우 Image.file 사용
      imageWidget = Image.file(File(imagePath), width: 80, height: 80, fit: BoxFit.cover);
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
        const SizedBox(height: 6),
        Row(
          children: [
            ElevatedButton(
              onPressed: () => _pickImage(onImageSelected),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF6FCF4B),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              ),
              child: const Text(
                '사진 업로드하기',
                style: TextStyle(fontSize: 14, color: Colors.white),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: imagePath != null && imagePath.isNotEmpty
                  // --- 🔽 기존 Image.file을 imageWidget으로 교체 🔽 ---
                  ? Center(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: imageWidget, // 동적으로 선택된 이미지 위젯 사용
                      ),
                    )
                  // --- 🔼 수정 끝 🔼 ---
                  : const SizedBox(),
            ),
          ],
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  Widget buildLabeledTextField(
    String label,
    String hint, {
    String? suffix,
    TextEditingController? controller,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(height: 6),
          TextField(
            controller: controller,
            onChanged: (_) => setState(() {}),
            decoration: InputDecoration(
              hintText: hint,
              suffixText: suffix,
              filled: true,
              fillColor: Colors.white,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: const BorderSide(color: Colors.grey),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: const BorderSide(color: Colors.green),
              ),
              isDense: true,
            ),
          ),
        ],
      ),
    );
  }
}
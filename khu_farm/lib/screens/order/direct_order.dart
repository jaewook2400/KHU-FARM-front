import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:khu_farm/model/fruit.dart';
import 'package:khu_farm/model/address.dart';
import 'package:khu_farm/model/user_info.dart';
import 'package:khu_farm/services/storage_service.dart';
import 'package:khu_farm/constants.dart';
import 'package:khu_farm/screens/order/payment.dart';
import 'package:portone_flutter/model/payment_data.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_markdown/flutter_markdown.dart';


class DirectOrderScreen extends StatefulWidget {
  const DirectOrderScreen({super.key});

  @override
  State<DirectOrderScreen> createState() => _DirectOrderScreenState();
}

class _DirectOrderScreenState extends State<DirectOrderScreen> {
  final TextEditingController _orderRequestController = TextEditingController();
  int _selectedPaymentMethod = 1;
  bool _agreeAll = false;
  List<bool> _agreements = List.generate(paymentAgreements.length, (_) => false);

  Address? _shippingAddress;
  UserInfo? _userInfo;

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  @override
  void dispose() {
    _orderRequestController.dispose();
    super.dispose();
  }

  Future<void> _navigateToEditAddress() async {
    if (_shippingAddress == null) return;

    // 수정 화면으로 이동하고, 수정된 Address 객체를 반환받을 때까지 기다립니다.
    final updatedAddress = await Navigator.pushNamed(
      context,
      '/order/edit/address', // TODO: 실제 라우트 경로 확인 필요
      arguments: _shippingAddress,
    );

    // 수정된 Address 객체가 반환되면, 화면의 배송지 정보를 업데이트합니다.
    if (updatedAddress != null && updatedAddress is Address) {
      setState(() {
        _shippingAddress = updatedAddress;
      });
    }
  }
  
  Future<void> _navigateAndSelectAddress() async {
    // 주소 목록/수정 화면으로 이동하고, 결과를 기다립니다.
    final result = await Navigator.pushNamed(
      context,
      '/order/address', // ✨ 요청하신 경로로 변경
      arguments: _shippingAddress,
    );

    // 주소 목록 화면에서 새로운 주소를 선택했거나, 수정 화면에서 주소를 수정한 경우
    // Address 객체가 반환됩니다.
    if (result != null && result is Address) {
      setState(() {
        _shippingAddress = result;
      });
    }
  }

  Future<void> _loadInitialData() async {
    final addresses = await StorageService().getAddresses();
    final userInfo = await StorageService().getUserInfo();
    Address? defaultAddress; // 로컬 변수로 기본 주소 저장

    if (addresses != null && addresses.isNotEmpty) {
      try {
        // isDefault가 true인 첫 번째 주소를 찾습니다.
        defaultAddress = addresses.firstWhere((addr) => addr.isDefault);
      } catch (e) {
        // 기본 주소가 없으면 defaultAddress는 null로 유지됩니다.
        // 이 경우, 화면에는 "배송지를 선택해주세요"가 표시됩니다.
      }
    }

    if (mounted) {
      setState(() {
        _userInfo = userInfo;
        _shippingAddress = defaultAddress; // 찾은 주소 또는 null로 상태 업데이트
      });
    }
  }

  void _onAgreeAll(bool? value) {
    setState(() {
      _agreeAll = value ?? false;
      // 이 로직은 _agreements 리스트의 길이에 따라 자동으로 동작하므로 수정할 필요가 없습니다.
      for (int i = 0; i < _agreements.length; i++) {
        _agreements[i] = _agreeAll;
      }
    });
  }

  void _onAgreementChanged(int index, bool? value) {
    setState(() {
      _agreements[index] = value ?? false;
      _agreeAll = _agreements.every((agreed) => agreed);
    });
  }

  void showTermsModal(BuildContext context, String title, String content) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) {
        return DraggableScrollableSheet(
          initialChildSize: 0.6,
          minChildSize: 0.4,
          maxChildSize: 0.95,
          builder: (context, scrollController) {
            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 20.0),
                    child: Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  ),
                  const SizedBox(height: 12),
                  Expanded(
                    child: SingleChildScrollView(
                      controller: scrollController,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: _buildTermsWidgets(content),
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.fromLTRB(20, 12, 20, MediaQuery.of(context).padding.bottom + 12),
                    child: SizedBox(
                      width: double.infinity,
                      height: 40,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.black,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        onPressed: () => Navigator.pop(context),
                        child: const Text('닫기', style: TextStyle(color: Colors.white)),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  List<Widget> _buildTermsWidgets(String markdown) {
    final List<Widget> widgets = [];
    const summaryDelimiter = '-       요      약      본      -';
    const fullTextDelimiter = '-       전      문      -';

    if (markdown.contains(summaryDelimiter)) {
      final parts = markdown.split(summaryDelimiter);
      if (parts[0].trim().isNotEmpty) {
        widgets.add(MarkdownBody(data: parts[0]));
      }
      widgets.add(
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 16.0),
          child: Center(child: Text(summaryDelimiter, style: const TextStyle(fontWeight: FontWeight.bold))),
        ),
      );
      
      if (parts[1].contains(fullTextDelimiter)) {
        final subParts = parts[1].split(fullTextDelimiter);
        if (subParts[0].trim().isNotEmpty) {
          widgets.add(MarkdownBody(data: subParts[0]));
        }
        widgets.add(
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16.0),
            child: Center(child: Text(fullTextDelimiter, style: const TextStyle(fontWeight: FontWeight.bold))),
          ),
        );
        if (subParts[1].trim().isNotEmpty) {
          widgets.add(MarkdownBody(data: subParts[1]));
        }
      } else {
        widgets.add(MarkdownBody(data: parts[1]));
      }
    } else {
      widgets.add(MarkdownBody(data: markdown));
    }
    
    return widgets;
  }

  Future<void> _handlePayment(Fruit fruit, int quantity, int finalPayment) async {
    if (_shippingAddress == null || _userInfo == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('배송지 또는 사용자 정보가 없습니다.')),
      );
      return;
    }

    final accessToken = await StorageService.getAccessToken();
    if (accessToken == null) return;

    // STEP 1: Register the order with your server
    final preOrderUri = Uri.parse('$baseUrl/order/directOrder');
    final headers = {
      'Authorization': 'Bearer $accessToken',
      'Content-Type': 'application/json',
    };
    final body = jsonEncode({
      "fruitId": fruit.id,
      "orderCount": quantity,
      "totalPrice": finalPayment,
      "shippingInfo": {
        "addressName": _shippingAddress!.addressName,
        "portCode": _shippingAddress!.portCode,
        "address": _shippingAddress!.address,
        "detailAddress": _shippingAddress!.detailAddress,
        "recipient": _shippingAddress!.recipient,
        "phoneNumber": _shippingAddress!.phoneNumber,
        "orderRequest": _orderRequestController.text
      }
    });

    final prettyBody = const JsonEncoder.withIndent('  ').convert(jsonDecode(body));
    debugPrint('📦 Request body:\n$prettyBody');

    try {
      final preOrderResponse = await http.post(preOrderUri, headers: headers, body: body);
      final preOrderData = jsonDecode(utf8.decode(preOrderResponse.bodyBytes));

      if (preOrderResponse.statusCode == 200 && preOrderData['isSuccess'] == true) {
        final orderResult = preOrderData['result'];
        final paymentData = PaymentData(
          pg: 'html5_inicis',
          payMethod: 'card',
          name: fruit.title,
          merchantUid: orderResult['merchantUid'],
          amount: orderResult['totalPrice'],
          buyerName: orderResult['recipient'],
          buyerTel: orderResult['phoneNumber'],
          buyerEmail: _userInfo!.email,
          buyerAddr: '${orderResult['address']} ${orderResult['detailAddress']}',
          buyerPostcode: orderResult['portCode'],
          appScheme: 'khufarm',
          confirmUrl: '$baseUrl/payment/confirm'
        );

        // --- This part is updated ---
        // Navigate to the payment screen without waiting for a result.
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PaymentScreen(paymentData: paymentData),
          ),
        );
        // --- End of update ---

      } else {
        throw Exception('Failed to create order on server: ${preOrderData['message']}');
      }
    } catch (e) {
      print('An error occurred during payment prep: $e');
      if(mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('주문 생성에 실패했습니다. 다시 시도해주세요.')),
        );
      }
    }
  }

  String _getMainRoute() {
    switch (_userInfo?.userType) {
      case 'ROLE_INDIVIDUAL':
        return '/consumer/main';
      case 'ROLE_BUSINESS':
        return '/retailer/main';
      case 'ROLE_FARMER':
        return '/farmer/main';
      default:
        return '/';
    }
  }

  String _getDibsRoute() {
    switch (_userInfo?.userType) {
      case 'ROLE_INDIVIDUAL':
        return '/consumer/dib/list';
      case 'ROLE_BUSINESS':
        return '/retailer/dib/list';
      case 'ROLE_FARMER':
        return '/farmer/dib/list';
      default:
        return '/';
    }
  }

  String _getCartRoute() {
    switch (_userInfo?.userType) {
      case 'ROLE_INDIVIDUAL':
        return '/consumer/cart/list';
      case 'ROLE_BUSINESS':
        return '/retailer/cart/list';
      case 'ROLE_FARMER':
        return '/farmer/cart/list';
      default:
        return '/';
    }
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
    final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    final Fruit fruit = args['fruit'];
    final int quantity = args['quantity'];

    final formatter = NumberFormat('#,###');
    final productTotal = fruit.price * quantity;
    final deliveryFee = 0;
    // final deliveryFee = productTotal > 0 ? 5000 : 0; // Example fee
    final finalPayment = productTotal + deliveryFee;


    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final statusBarHeight = MediaQuery.of(context).padding.top;

    final bool canProceed = _agreements.every((agreed) => agreed);

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
                  onTap: () => Navigator.pushNamedAndRemoveUntil(context, _getMainRoute(), (route) => false),
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
                      onTap: () => Navigator.pushNamed(context, _getDibsRoute()),
                      child: Image.asset('assets/top_icons/dibs.png', width: 24, height: 24),
                    ),
                    const SizedBox(width: 12),
                    GestureDetector(
                      onTap: () => Navigator.pushNamed(context, _getCartRoute()),
                      child: Image.asset('assets/top_icons/cart.png', width: 24, height: 24),
                    ),
                  ],
                ),
              ],
            ),
          ),

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
                      '결제하기',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),

                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.only(top: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildSectionHeader(
                          '배송지',
                          actionText: '배송지 변경 >',
                          onActionTap: _navigateAndSelectAddress,
                        ),
                        // _shippingAddress 상태 변수를 위젯에 전달
                        _buildShippingInfoCard(
                          address: _shippingAddress,
                          onEdit: _navigateToEditAddress,
                        ),
                        const SizedBox(height: 18),
                        const Divider(),
                        const SizedBox(height: 6),
                        _buildSectionHeader('주문 상품', actionText: '$quantity개'),
                        _buildProductCard(fruit: fruit, quantity: quantity), // Pass data to card
                        const SizedBox(height: 18),
                        const Divider(),
                        const SizedBox(height: 12),
                        const Text('주문 요청사항', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 12),
                        TextField(
                          controller: _orderRequestController,
                          maxLines: 4,
                          decoration: const InputDecoration(
                            hintText: '내용을 입력해주세요.',
                            border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(12))),
                          ),
                        ),
                        const SizedBox(height: 18),
                        const Divider(),
                        const SizedBox(height: 12),
                        const Text('결제 수단', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                        _buildPaymentMethod(1, '카드/간편결제'),
                        // _buildPaymentMethod(2, '카카오페이'),
                        // _buildPaymentMethod(3, '계좌 간편결제'),
                        const SizedBox(height: 8),
                        const Divider(),
                        const SizedBox(height: 12),
                        _AmountRow(
                        label: '총 결제금액',
                        amount: '${formatter.format(finalPayment)}원',
                        isTotal: true,
                      ),
                      const SizedBox(height: 12),
                      _AmountRow(
                        label: '상품 금액',
                        amount: '${formatter.format(productTotal)}원',
                      ),
                      const SizedBox(height: 8),
                      _AmountRow(
                        label: '배송비',
                        amount: deliveryFee > 0 ? '${formatter.format(deliveryFee)}원' : '무료',
                        isFree: deliveryFee == 0,
                      ),
                      const SizedBox(height: 12),
                      const Divider(),
                      const SizedBox(height: 12),

                      // Agreements Section
                      _buildAgreementRow(
                        isAll: true,
                        value: _agreeAll,
                        onChanged: _onAgreeAll,
                        label: '주문내용 확인 및 결제 모두 동의',
                      ),
                      const SizedBox(height: 8),

                      // paymentAgreements 리스트를 기반으로 동적으로 약관 위젯 생성
                      for (int i = 0; i < paymentAgreements.length; i++)
                          Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: _buildAgreementRow(
                              value: _agreements[i],
                              onChanged: (val) => _onAgreementChanged(i, val),
                              label: paymentAgreements[i]['name'] as String,
                              // '더보기' 버튼을 눌렀을 때 모달창을 띄우는 콜백 연결
                              onMoreTap: () => showTermsModal(
                                context,
                                paymentAgreements[i]['name'] as String,
                                paymentAgreements[i]['content'] as String,
                              ),
                            ),
                          ),
                      const SizedBox(height: 120),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          Positioned(
            left: 0, right: 0, bottom: 0,
            child: Container(
              padding: EdgeInsets.fromLTRB(20, 12, 20, MediaQuery.of(context).padding.bottom + 12),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10)]
              ),
              child: ElevatedButton(
                // --- onPressed is updated ---
                onPressed: canProceed ? () => _handlePayment(fruit, quantity, finalPayment) : null,
                // --- End of update ---
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFB6832B),
                  disabledBackgroundColor: Colors.grey.shade300,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: Text('${formatter.format(finalPayment)}원 결제하기', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, {String? actionText, VoidCallback? onActionTap}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          if (actionText != null)
            GestureDetector(
              onTap: onActionTap,
              child: Text(actionText, style: const TextStyle(fontSize: 14, color: Colors.grey)),
            ),
        ],
      ),
    );
  }

  Widget _buildShippingInfoCard({Address? address, required VoidCallback onEdit}) {
    if (address == null) {
      return Container(
        width: double.infinity, // 카드가 부모의 너비를 채우도록 설정
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Center(child: Text('배송지를 선택해주세요.')), // 요청된 문구로 변경
      );
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(address.addressName, style: const TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text('${address.recipient} | ${address.phoneNumber}'),
          const SizedBox(height: 4),
          Text('${address.address} ${address.detailAddress} [${address.portCode}]'),
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.centerLeft,
            child: OutlinedButton(
              onPressed: onEdit, // ✨ 콜백 함수 연결
              child: const Text('수정'),
              style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  side: BorderSide(color: Colors.grey.shade400)),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildProductCard({required Fruit fruit, required int quantity}) {
    final formatter = NumberFormat('#,###');
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(fruit.title, style: const TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text(fruit.brandName ?? '알 수 없음', style: const TextStyle(fontSize: 12, color: Colors.grey)),
                const SizedBox(height: 12),
                Text('${quantity}박스', style: const TextStyle(fontSize: 12, color: Colors.grey)),
                const SizedBox(height: 4),
                Text('${formatter.format(fruit.price)}원 / ${fruit.weight}kg', style: const TextStyle(fontWeight: FontWeight.bold)),
              ],
            ),
          ),
          const SizedBox(width: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.network(fruit.squareImageUrl, width: 80, height: 80, fit: BoxFit.cover),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentMethod(int value, String title) {
    return InkWell(
      onTap: () => setState(() => _selectedPaymentMethod = value),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 0), // Reduced vertical padding
        child: Row(
          children: [
            Radio<int>(
              value: value,
              groupValue: _selectedPaymentMethod,
              onChanged: (val) => setState(() => _selectedPaymentMethod = val!),
              activeColor: Colors.black,
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            Text(title, style: const TextStyle(fontSize: 14)),
          ],
        ),
      ),
    );
  }

  Widget _buildAgreementRow({
    required bool value,
    required Function(bool?) onChanged,
    required String label,
    bool isAll = false,
    VoidCallback? onMoreTap, // '더보기' 탭 이벤트를 위한 콜백 추가
  }) {
    return Row(
      children: [
        Checkbox(
          value: value,
          onChanged: onChanged,
          visualDensity: const VisualDensity(horizontal: -4, vertical: -4),
          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
          activeColor: Colors.white,
          checkColor: Colors.black,
          side: MaterialStateBorderSide.resolveWith(
            (states) => BorderSide(color: Colors.grey.shade400, width: 2),
          ),
        ),
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: isAll ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ),
        // isAll이 false이고 onMoreTap 콜백이 제공된 경우에만 '더보기' 버튼 표시
        if (!isAll && onMoreTap != null)
          GestureDetector(
            onTap: onMoreTap,
            child: Padding(
              padding: const EdgeInsets.only(left: 8.0),
              child: Text(
                '더보기 >',
                style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
              ),
            ),
          ),
      ],
    );
  }
}

class _AmountRow extends StatelessWidget {
  final String label;
  final String amount;
  final bool isTotal;
  final bool isFree;

  const _AmountRow({
    required this.label,
    required this.amount,
    this.isTotal = false,
    this.isFree = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyle(fontSize: 14, fontWeight: isTotal ? FontWeight.bold : FontWeight.normal)),
        Text(
          amount,
          style: TextStyle(
            fontSize: isTotal ? 16 : 14,
            fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
            color: isFree ? Colors.redAccent : Colors.black,
          ),
        ),
      ],
    );
  }
}
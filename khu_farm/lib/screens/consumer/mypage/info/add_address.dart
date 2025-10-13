import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:daum_postcode_search/daum_postcode_search.dart';
import 'package:khu_farm/screens/address_search.dart';
import 'package:http/http.dart' as http;
import 'package:khu_farm/constants.dart';
import 'package:khu_farm/services/storage_service.dart';

import '../../../../shared/widgets/top_norch_header.dart';

class ConsumerAddAddressScreen extends StatefulWidget {
  const ConsumerAddAddressScreen({super.key});

  @override
  State<ConsumerAddAddressScreen> createState() =>
      _ConsumerAddAddressScreenStatus();
}

class _ConsumerAddAddressScreenStatus extends State<ConsumerAddAddressScreen> {
  final TextEditingController _postalCtrl = TextEditingController();
  final TextEditingController _addressCtrl = TextEditingController();
  final TextEditingController _detailCtrl = TextEditingController();
  final TextEditingController _labelCtrl = TextEditingController();
  final TextEditingController _recipientCtrl = TextEditingController();
  final TextEditingController _phoneCtrl = TextEditingController();
  bool _isDefault = false;
  bool _canSave = false;

  @override
  void initState() {
    super.initState();
    // Add listeners to all controllers to check if the form is valid
    _postalCtrl.addListener(_validateForm);
    _addressCtrl.addListener(_validateForm);
    _detailCtrl.addListener(_validateForm);
    _labelCtrl.addListener(_validateForm);
    _recipientCtrl.addListener(_validateForm);
    _phoneCtrl.addListener(_validateForm);
  }

  @override
  void dispose() {
    _postalCtrl.dispose();
    _addressCtrl.dispose();
    _detailCtrl.dispose();
    _labelCtrl.dispose();
    _recipientCtrl.dispose();
    _phoneCtrl.dispose();
    super.dispose();
  }

  void _validateForm() {
    // Check if all required fields are filled
    final bool isValid = _postalCtrl.text.isNotEmpty &&
        _addressCtrl.text.isNotEmpty &&
        _detailCtrl.text.isNotEmpty &&
        _labelCtrl.text.isNotEmpty &&
        _recipientCtrl.text.isNotEmpty &&
        _phoneCtrl.text.isNotEmpty;

    if (isValid != _canSave) {
      setState(() {
        _canSave = isValid;
      });
    }
  }

  Future<void> _searchAddress() async {
    final result = await Navigator.of(context).push<DataModel>(
      MaterialPageRoute(builder: (_) => const AddressSearchScreen()),
    );

    // If the user selected an address, update the text fields
    if (result != null) {
      setState(() {
        _postalCtrl.text = result.zonecode ?? '';
        _addressCtrl.text = result.address ?? '';
      });
    }
    _validateForm();
  }

  Future<void> _saveAddress() async {
    final accessToken = await StorageService.getAccessToken();
    if (accessToken == null) return;

    final headers = {
      'Authorization': 'Bearer $accessToken',
      'Content-Type': 'application/json',
    };
    final uri = Uri.parse('$baseUrl/address/create');
    final body = jsonEncode({
      "addressName": _labelCtrl.text,
      "portCode": _postalCtrl.text,
      "address": _addressCtrl.text,
      "detailAddress": _detailCtrl.text,
      "recipient": _recipientCtrl.text,
      "phoneNumber": _phoneCtrl.text,
      "isDefault": _isDefault,
    });

    try {
      final response = await http.post(uri, headers: headers, body: body);
      if (response.statusCode == 200 || response.statusCode == 201) {
        if (mounted) {
          showDialog(
            context: context,
            builder: (_) => const _SuccessDialog(),
          );
        }
      } else {
        print('Failed to save address: ${response.statusCode}');
        print('Response: ${response.body}');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('저장에 실패했습니다. 다시 시도해주세요.')),
          );
        }
      }
    } catch (e) {
      print('Error saving address: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    // 시스템 UI 투명
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
      ),
    );
    final double screenWidth = MediaQuery.of(context).size.width;
    final double screenHeight = MediaQuery.of(context).size.height;
    final double statusbarHeight = MediaQuery.of(context).padding.top;
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return Scaffold(
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          ConsumerTopNotchHeader(),

          // 콘텐츠
          Padding(
            padding: EdgeInsets.only(
              top: statusbarHeight + screenHeight * 0.06 + 20,
              left: screenWidth * 0.08,
              right: screenWidth * 0.08,
              bottom: bottomPadding + 20,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 뒤로가기 + 제목 + 우편번호 찾기 버튼
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
                      '배송지 변경',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const Spacer(),
                  ],
                ),
                const SizedBox(height: 24),

                // 입력 필드들
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        // 우편번호
                        _buildAddressSearchRow(),
                        const SizedBox(height: 16),
                        // 주소지
                        _buildTextFieldRow(label: '주소지', controller: _addressCtrl, hint: '서울시 OO구 OO동 123-12', enabled: false),
                        const SizedBox(height: 16),
                        // 상세주소
                        _buildTextFieldRow(label: '상세주소', controller: _detailCtrl, hint: '상세주소를 입력해 주세요.'),
                        const SizedBox(height: 16),
                        // 배송지명
                        _buildTextFieldRow(label: '배송지명', controller: _labelCtrl, hint: '배송지명을 입력해 주세요.'),
                        const SizedBox(height: 16),
                        const Divider(),
                        const SizedBox(height: 16),
                        // 수령인
                        _buildTextFieldRow(label: '수령인', controller: _recipientCtrl, hint: '이름을 입력해 주세요.'),
                        const SizedBox(height: 16),
                        // 전화번호
                        _buildTextFieldRow(label: '전화번호', controller: _phoneCtrl, hint: '숫자만 입력해 주세요.'),
                        const SizedBox(height: 16),
                        const Divider(),
                        const SizedBox(height: 16),
                        // 기본 배송지 설정
                        _buildDefaultAddressCheckbox(),
                      ],
                    ),
                  ),
                ),

                // 저장하기 버튼
                
              ],
            ),
          ),

          Positioned(
            left: screenWidth * 0.08,
            right: screenWidth * 0.08,
            // Position the button above the system nav bar with some margin
            bottom: bottomPadding + 20,
            child: SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                // --- This is updated ---
                onPressed: _canSave ? _saveAddress : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF6FCF4B),
                  disabledBackgroundColor: Colors.grey.shade300,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                // --- End of update ---
                child: const Text(
                  '저장하기',
                  style: TextStyle(fontSize: 16, color: Colors.white),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAddressSearchRow() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const SizedBox(width: 70, child: Text('우편번호', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold))),
        const SizedBox(width: 12),
        Expanded(
          child: TextField(
            controller: _postalCtrl,
            enabled: false,
            decoration: InputDecoration(
              hintText: '우편번호',
              filled: true,
              fillColor: Colors.grey.shade200,
              border: const OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(30)), borderSide: BorderSide.none),
              contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            ),
          ),
        ),
        const SizedBox(width: 12),
        ElevatedButton(
          onPressed: _searchAddress,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF6FCF4B),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            padding: const EdgeInsets.symmetric(horizontal: 16),
          ),
          child: const Text('찾기', style: TextStyle(fontSize: 13, color: Colors.white)),
        ),
      ],
    );
  }

  Widget _buildTextFieldRow({required String label, required TextEditingController controller, required String hint, bool enabled = true}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SizedBox(width: 70, child: Text(label, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold))),
        const SizedBox(width: 12),
        Expanded(
          child: TextField(
            controller: controller,
            enabled: enabled,
            decoration: InputDecoration(
              hintText: hint,
              filled: !enabled,
              fillColor: Colors.grey.shade200,
              border: OutlineInputBorder(
                borderRadius: const BorderRadius.all(Radius.circular(30)),
                borderSide: enabled ? const BorderSide(color: Colors.grey) : BorderSide.none,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: const BorderRadius.all(Radius.circular(30)),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDefaultAddressCheckbox() {
    return Row(
      children: [
        Checkbox(
          value: _isDefault,
          onChanged: (v) => setState(() => _isDefault = v ?? false),
        ),
        const Text('기본 배송지로 설정'),
      ],
    );
  }
}

class _SuccessDialog extends StatelessWidget {
  const _SuccessDialog();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40),
        child: Material(
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(40),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('배송지가 성공적으로 추가되었습니다.'),
                const SizedBox(height: 30),

                // 🔑 버튼과 마스코트를 같은 Stack 안에 배치
                Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Positioned(
                      right: -0, // 버튼 기준 우측으로 살짝
                      top: -30,   // 버튼 기준 위로 살짝
                      child: Image.asset(
                        'assets/mascot/login_mascot.png',
                        width: 50,
                        height: 50,
                      ),
                    ),
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                          Navigator.of(context).pop();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF6FCF4B),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                        child: const Text(
                          '닫기',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
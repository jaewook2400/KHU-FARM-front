import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../shared/widgets/top_norch_header.dart';

class FarmerEditProfileScreen extends StatefulWidget {
  final String initialName;
  final String initialEmail;
  final String initialPhone;

  const FarmerEditProfileScreen({
    super.key,
    this.initialName = '',
    this.initialEmail = '',
    this.initialPhone = '',
  });

  @override
  State<FarmerEditProfileScreen> createState() =>
      _FarmerEditProfileScreenState();
}

class _FarmerEditProfileScreenState extends State<FarmerEditProfileScreen> {
  late TextEditingController _nameCtrl;
  late TextEditingController _emailCtrl;
  late TextEditingController _phoneCtrl;

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController(text: widget.initialName);
    _emailCtrl = TextEditingController(text: widget.initialEmail);
    _phoneCtrl = TextEditingController(text: widget.initialPhone);
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _phoneCtrl.dispose();
    super.dispose();
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

    return Scaffold(
      extendBodyBehindAppBar: true,

      body: Stack(
        children: [
          FarmerTopNotchHeader(),

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
                      '회원 정보 수정',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // 입력 폼
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        // 이름
                        _LabeledField(
                          label: '이름',
                          controller: _nameCtrl,
                          hint: '이름을 입력하세요.',
                        ),
                        const SizedBox(height: 16),
                        // 이메일
                        _LabeledField(
                          label: '이메일',
                          controller: _emailCtrl,
                          hint: '이메일을 입력하세요.',
                        ),
                        const SizedBox(height: 16),
                        // 전화번호
                        _LabeledField(
                          label: '전화번호',
                          controller: _phoneCtrl,
                          hint: "'-' 없이 숫자만 입력하세요.",
                        ),

                        const SizedBox(height: 24),
                        // 계정 삭제하기
                        InkWell(
                          onTap: () {
                            Navigator.pushNamed(
                              context,
                              '/farmer/mypage/info/cancel',
                            );
                          },
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: const [
                                Text(
                                  '계정 탈퇴',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.red,
                                  ),
                                ),
                                SizedBox(width: 4),
                                Icon(Icons.chevron_right, color: Colors.red),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // 변경 완료 버튼
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: () {
                      // TODO: 변경 완료 로직
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF6FCF4B),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    child: const Text(
                      '변경 완료',
                      style: TextStyle(fontSize: 16, color: Colors.white),
                    ),
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

// 공통 입력 필드
class _LabeledField extends StatelessWidget {
  final String label;
  final String hint;
  final TextEditingController controller;

  const _LabeledField({
    required this.label,
    required this.controller,
    required this.hint,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          decoration: InputDecoration(
            hintText: hint,
            border: const OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(30)),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 20,
              vertical: 12,
            ),
          ),
        ),
      ],
    );
  }
}

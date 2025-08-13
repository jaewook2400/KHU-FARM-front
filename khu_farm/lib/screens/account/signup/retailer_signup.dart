// 📄 lib/screens/signup_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:khu_farm/constants.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

class RetailerSignupScreen extends StatefulWidget {
  const RetailerSignupScreen({super.key});

  @override
  State<RetailerSignupScreen> createState() => _RetailerSignupScreenState();
}

class _RetailerSignupScreenState extends State<RetailerSignupScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _idController = TextEditingController();
  final _passwordController = TextEditingController();
  final _passwordConfirmController = TextEditingController();
  final _businessNameController = TextEditingController();
  final _businessIdController = TextEditingController();
  final _openDateController = TextEditingController();

  bool _isIdCheckedAndAvailable = false;
  bool _agreeAll = false;
  bool _agreeService = false;
  bool _agreePrivacy = false;
  bool _agreeThirdParty = false;

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
                        // 텍스트를 분리하여 위젯 리스트로 만드는 함수 호출
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

    // 1. '- 요약문 -'을 기준으로 텍스트를 나눕니다.
    if (markdown.contains(summaryDelimiter)) {
      final parts = markdown.split(summaryDelimiter);
      // 요약문 이전 내용
      if (parts[0].trim().isNotEmpty) {
        widgets.add(MarkdownBody(data: parts[0]));
      }
      // 요약문 (가운데 정렬)
      widgets.add(
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 16.0),
          child: Center(child: Text(summaryDelimiter, style: const TextStyle(fontWeight: FontWeight.bold))),
        ),
      );
      
      // 2. 나머지 텍스트를 '- 전문 -'을 기준으로 나눕니다.
      if (parts[1].contains(fullTextDelimiter)) {
        final subParts = parts[1].split(fullTextDelimiter);
        // 전문 이전 내용
        if (subParts[0].trim().isNotEmpty) {
          widgets.add(MarkdownBody(data: subParts[0]));
        }
        // 전문 (가운데 정렬)
        widgets.add(
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16.0),
            child: Center(child: Text(fullTextDelimiter, style: const TextStyle(fontWeight: FontWeight.bold))),
          ),
        );
        // 전문 이후 내용
        if (subParts[1].trim().isNotEmpty) {
          widgets.add(MarkdownBody(data: subParts[1]));
        }
      } else {
        widgets.add(MarkdownBody(data: parts[1]));
      }
    } else {
      // 구분자가 없으면 전체를 마크다운으로 렌더링
      widgets.add(MarkdownBody(data: markdown));
    }
    
    return widgets;
  }

  Future<void> _handleSignup() async {
    // Basic validation
    if (_passwordController.text != _passwordConfirmController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('비밀번호가 일치하지 않습니다.')),
      );
      return;
    }

    final uri = Uri.parse('$baseUrl/auth/business/signup');
    final headers = {'Content-Type': 'application/json'};
    final body = jsonEncode({
      "name": _nameController.text,
      "email": _emailController.text,
      "userId": _idController.text,
      "password": _passwordController.text,
      "passwordConfirm": _passwordConfirmController.text,
      "termsAgreed": [
        {"termsConditionsId": 1, "agreed": _agreeService},
        {"termsConditionsId": 2, "agreed": _agreePrivacy},
        {"termsConditionsId": 3, "agreed": _agreeThirdParty},
      ],
      "businessInfoDto": {
        "businessName": _businessNameController.text,
        "businessId": _businessIdController.text,
        "openDate": _openDateController.text
      }
    });

    try {
      final response = await http.post(uri, headers: headers, body: body);
      final data = jsonDecode(utf8.decode(response.bodyBytes));

      if (response.statusCode == 200 && data['isSuccess'] == true) {
        print('Signup successful: ${data['result']}');
        if (mounted) {
          Navigator.pushNamed(context, '/signup/retailer/success');
        }
      } else {
        print('Signup failed: ${data['message']}');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('회원가입에 실패했습니다: ${data['message']}')),
          );
        }
      }
    } catch (e) {
      print('An error occurred during signup: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      statusBarBrightness: Brightness.light,
    ));

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
          Positioned(
            top: 0,
            right: 0,
            height: statusBarHeight * 1.2,
            child: Image.asset('assets/notch/morning_right_up_cloud.png', fit: BoxFit.cover),
          ),
          Positioned(
            top: statusBarHeight,
            left: 0,
            height: screenHeight * 0.06,
            child: Image.asset('assets/notch/morning_left_down_cloud.png', fit: BoxFit.cover),
          ),

          // 상단 로고
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
                      '/login',
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
              ],
            ),
          ),

          // 상단 타이틀 및 뒤로가기
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
                const Text('회원가입 (기업)', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500)),
              ],
            ),
          ),

          // 입력 필드 및 체크박스 (스크롤 영역)
          Padding(
            padding: EdgeInsets.only(
              top: statusBarHeight + screenHeight * 0.06 + 60,
              // 하단 버튼의 높이(48) + 여백(30) + 시스템 바 높이만큼 공간을 확보
              bottom: 48 + 30 + bottomPadding,
            ),
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.08),
              child: Column(
                children: [
                  _LabeledTextField(
                      label: '이름',
                      hint: '이름을 입력하세요.',
                      controller: _nameController),
                  _LabeledTextField(
                      label: '이메일',
                      hint: '이메일을 입력하세요.',
                      controller: _emailController),
                  _IdCheckField(
                    controller: _idController,
                    onIdChecked: (isAvailable) {
                      setState(() {
                        _isIdCheckedAndAvailable = isAvailable;
                      });
                    },
                  ),
                  _LabeledTextField(
                    label: '비밀번호',
                    hint: '영문, 숫자, 특수문자 조합',
                    obscureText: true,
                    controller: _passwordController,
                  ),
                  _LabeledTextField(
                    label: '비밀번호 확인',
                    hint: '비밀번호를 다시 입력하세요.',
                    obscureText: true,
                    controller: _passwordConfirmController,
                  ),
                  const SizedBox(height: 16),
                  const Divider(),
                  _LabeledTextField(label: '대표자 성명', hint: '이름을 입력하세요.', controller: _businessNameController,),
                  _LabeledTextField(label: '사업자 등록번호', hint: "'-'없이 기호를 제외한 10자리 숫자를 입력하세요.", controller: _businessIdController,),
                  _LabeledTextField(label: '개업일자', hint: 'YYYYMMDD 형태로 입력하세요. ex)20010101', controller: _openDateController,),
                  const SizedBox(height: 16),
                  _customCheckboxTile(
                    value: _agreeAll,
                    onChanged: (value) {
                      setState(() {
                        _agreeAll = value!;
                        _agreeService = value;
                        _agreePrivacy = value;
                        _agreeThirdParty = value;
                      });
                    },
                    label: '모든 약관에 동의합니다.',
                    isAllAgreement: true,
                  ),
                  _customCheckboxTile(
                    value: _agreeService,
                    onChanged: (value) {
                      setState(() {
                        _agreeService = value!;
                        _agreeAll = _agreeService && _agreePrivacy && _agreeThirdParty;
                      });
                    },
                    label: '(필수) 이용약관에 동의합니다.',
                    onMoreTap: () => showTermsModal(
                      context,
                      signupAgreements[0]['name'] as String,
                      signupAgreements[0]['content'] as String,
                    ),
                  ),
                  _customCheckboxTile(
                    value: _agreePrivacy,
                    onChanged: (value) {
                      setState(() {
                        _agreePrivacy = value!;
                        _agreeAll = _agreeService && _agreePrivacy && _agreeThirdParty;
                      });
                    },
                    label: '(필수) 개인정보 수집 및 이용에 동의합니다.',
                    onMoreTap: () => showTermsModal(
                      context,
                      signupAgreements[1]['name'] as String,
                      signupAgreements[1]['content'] as String,
                    ),
                  ),
                  _customCheckboxTile(
                    value: _agreeThirdParty,
                    onChanged: (value) {
                      setState(() {
                        _agreePrivacy = value!;
                        _agreeAll = _agreeService && _agreePrivacy && _agreeThirdParty;
                      });
                    },
                    label: '(필수) 제3자 제공에 동의합니다.(KG이니시스 결제서비스 제공 목적)',
                    onMoreTap: () => showTermsModal(
                      context,
                      signupAgreements[2]['name'] as String,
                      signupAgreements[2]['content'] as String,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // 하단 고정 버튼
          Positioned(
            left: MediaQuery.of(context).size.width * 0.08,
            right: MediaQuery.of(context).size.width * 0.08,
            bottom: MediaQuery.of(context).padding.bottom + 20,
            child: SizedBox(
              height: 48,
              child: ElevatedButton(
                onPressed: (_isIdCheckedAndAvailable &&
                        _agreeService &&
                        _agreePrivacy &&
                        _agreeThirdParty)
                    ? _handleSignup // Connect the signup function
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: (_isIdCheckedAndAvailable &&
                          _agreeService &&
                          _agreePrivacy &&
                          _agreeThirdParty)
                      ? const Color(0xFF6FCF4B)
                      : Colors.grey.shade300,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: Text(
                  '회원가입 하기',
                  style: TextStyle(
                    fontSize: 16,
                    color: (_isIdCheckedAndAvailable &&
                            _agreeService &&
                            _agreePrivacy &&
                            _agreeThirdParty)
                        ? Colors.white
                        : Colors.grey.shade600,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _customCheckboxTile({
    required bool value,
    required Function(bool?) onChanged,
    required String label,
    bool isAllAgreement = false,
    VoidCallback? onMoreTap,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Checkbox(
            value: value,
            onChanged: onChanged,
            visualDensity: const VisualDensity(horizontal: -4, vertical: -4),
          ),
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: Text(
                    label,
                    style: TextStyle(
                      fontWeight: isAllAgreement ? FontWeight.w800 : FontWeight.normal,
                      fontSize: 14,
                    ),
                  ),
                ),
                if (!isAllAgreement)
                  InkWell(
                    onTap: onMoreTap,
                    child: Padding(
                      padding: const EdgeInsets.only(left: 8.0),
                      child: Text('더보기', style: TextStyle(fontSize: 12, color: Colors.grey)),
                    ),
                  )
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _LabeledTextField extends StatelessWidget {
  final String label;
  final String hint;
  final bool obscureText;
  final TextEditingController controller; // 컨트롤러 추가

  const _LabeledTextField({
    required this.label,
    required this.hint,
    this.obscureText = false,
    required this.controller, // 생성자에 추가
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          TextField(
            controller: controller, // TextField에 컨트롤러 연결
            obscureText: obscureText,
            decoration: InputDecoration(
              hintText: hint,
              border: const OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(30)),
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }
}

class _IdCheckField extends StatefulWidget {
  final TextEditingController controller;
  final Function(bool) onIdChecked;

  const _IdCheckField({required this.controller, required this.onIdChecked});

  @override
  State<_IdCheckField> createState() => _IdCheckFieldState();
}

class _IdCheckFieldState extends State<_IdCheckField> {
  String _helperText = '영문과 숫자로 입력해 주세요.';
  Color _helperTextColor = Colors.grey;
  bool _isIdChecked = false;

  @override
  void initState() {
    super.initState();
    // Listen to changes in the text field
    widget.controller.addListener(_validateId);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_validateId);
    super.dispose();
  }

  void _validateId() {
    final id = widget.controller.text;
    final idRegExp = RegExp(r'^[a-zA-Z0-9]+$');
    
    // Reset check status whenever the user types
    _isIdChecked = false;
    widget.onIdChecked(false);

    setState(() {
      if (id.isEmpty) {
        _helperText = '영문과 숫자로 입력해 주세요.';
        _helperTextColor = Colors.grey;
      } else if (!idRegExp.hasMatch(id)) {
        _helperText = '올바른 아이디 형식이 아닙니다.';
        _helperTextColor = Colors.red;
      } else {
        _helperText = '중복확인을 진행해 주세요.';
        _helperTextColor = Colors.grey;
      }
    });
  }

  Future<void> _checkIdDuplication() async {
    final id = widget.controller.text;
    final idRegExp = RegExp(r'^[a-zA-Z0-9]+$');

    if (!idRegExp.hasMatch(id)) {
      setState(() {
        _helperText = '올바른 아이디 형식이 아닙니다.';
        _helperTextColor = Colors.red;
      });
      return;
    }

    final uri = Uri.parse('$baseUrl/auth/checkExistId?userId=$id');
    
    try {
      final response = await http.get(uri);
      final data = json.decode(utf8.decode(response.bodyBytes));

      _isIdChecked = true;

      // Assuming isSuccess: true means ID does NOT exist (is available)
      if (data['isSuccess'] == true) {
        setState(() {
          _helperText = '사용 가능한 아이디입니다.';
          _helperTextColor = Colors.grey;
          widget.onIdChecked(true); // Notify parent that ID is valid
        });
      } else {
        setState(() {
          _helperText = "'$id'(으)로 이미 가입된 아이디가 있습니다.";
          _helperTextColor = Colors.red;
          widget.onIdChecked(false); // Notify parent that ID is invalid
        });
      }
    } catch (e) {
      print('ID Check Error: $e');
      setState(() {
        _helperText = '오류가 발생했습니다. 다시 시도해주세요.';
        _helperTextColor = Colors.red;
        widget.onIdChecked(false);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('아이디', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                flex: 2,
                child: TextField(
                  controller: widget.controller,
                  decoration: const InputDecoration(
                    hintText: '아이디를 입력하세요.',
                    border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(30))),
                    contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              SizedBox(
                height: 48,
                child: ElevatedButton(
                  onPressed: _checkIdDuplication,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF6FCF4B),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                  ),
                  child: const Text('중복 확인', style: TextStyle(color: Colors.white)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Padding(
            padding: const EdgeInsets.only(left: 16.0),
            child: Text(
              _helperText,
              style: TextStyle(fontSize: 12, color: _helperTextColor),
            ),
          ),
        ],
      ),
    );
  }
}
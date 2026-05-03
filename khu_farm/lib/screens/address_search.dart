import 'package:daum_postcode_search/daum_postcode_search.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:khu_farm/model/user_info.dart';
import 'package:khu_farm/services/storage_service.dart';
import 'package:khu_farm/shared/widgets/top_norch_header.dart';

class AddressSearchScreen extends StatefulWidget {
  const AddressSearchScreen({super.key});

  @override
  State<AddressSearchScreen> createState() => _AddressSearchScreenState();
}

class _AddressSearchScreenState extends State<AddressSearchScreen> {
  UserInfo? _userInfo;

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> _loadInitialData() async {
    final userInfo = await StorageService().getUserInfo();
    if (mounted) {
      setState(() {
        _userInfo = userInfo;
      });
    }
  }

  void _navigateToMainPage() {
    String route = '/login'; // 기본값은 로그인 화면
    if (_userInfo != null) {
      switch (_userInfo!.userType) {
        case 'ROLE_INDIVIDUAL':
          route = '/consumer/main';
          break;
        case 'ROLE_BUSINESS':
          route = '/retailer/main';
          break;
        case 'ROLE_FARMER':
          route = '/farmer/main';
          break;
        case 'ADMIN':
          route = '/admin/daily';
          break;
      }
    }
    // 모든 화면 스택을 제거하고 해당 라우트로 이동합니다.
    Navigator.pushNamedAndRemoveUntil(context, route, (route) => false);
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
    final statusbarHeight = MediaQuery.of(context).padding.top;

    return Scaffold(
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          FarmerTopNotchHeader(),
          Padding(
            padding: EdgeInsets.only(
              top: statusbarHeight + screenHeight * 0.06 + 20,
            ),
            child:Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. Back Button and Title
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.08),
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
                        '주소 검색',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                Expanded(
                  child: DaumPostcodeSearch(
                    webPageTitle: "다음 주소 검색",
                    onConsoleMessage: ((controller, consoleMessage) {}),
                    onProgressChanged: (controller, progress) {},
                  ),
                )
              ]
            ),
          )
        ]
      ),
    );
  }
}
import 'package:flutter/material.dart';
import 'package:portone_flutter/iamport_payment.dart';
import 'package:portone_flutter/model/payment_data.dart';

class PaymentScreen extends StatefulWidget {
  final PaymentData paymentData;
  const PaymentScreen({super.key, required this.paymentData});

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  // 2. 결제 콜백 수신 후 네비게이션 전까지 로딩 화면을 표시하기 위한 상태 변수
  bool _isProcessing = false;

  @override
  Widget build(BuildContext context) {
    if (_isProcessing) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('결제 처리 중'),
          backgroundColor: const Color(0xFF6FCF4B),
          automaticallyImplyLeading: false, // 뒤로가기 버튼 숨김
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset('assets/mascot/main_mascot.png'), // 로고/이미지 사용
              const Padding(padding: EdgeInsets.symmetric(vertical: 15)),
              const Text('결제 결과를 처리 중입니다...', style: TextStyle(fontSize: 20)),
              const SizedBox(height: 20),
              const CircularProgressIndicator(),
            ],
          ),
        ),
      );
    }

    return IamportPayment(
      appBar: AppBar(
        title: const Text('결제하기'),
        backgroundColor: const Color(0xFF6FCF4B), // Example color
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ),
      initialChild: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset('assets/mascot/main_mascot.png'), // Use your own logo/image
            const Padding(padding: EdgeInsets.symmetric(vertical: 15)),
            const Text('잠시만 기다려주세요...', style: TextStyle(fontSize: 20)),
          ],
        ),
      ),
      userCode: 'imp40545344', 
      data: widget.paymentData,
      callback: (Map<String, String> result) {
        setState(() {
          _isProcessing = true;
        });
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (result['imp_success'] == 'true') {
            Navigator.pushReplacementNamed(
              context,
              '/order/success', // 결제 결과 화면 라우트
              arguments: result, // 결제 결과 데이터를 다음 화면으로 전달
            );
          } else {
            Navigator.pushReplacementNamed(
              context,
              '/order/fail',
            );
          }
        });
      },
    );
  }
}
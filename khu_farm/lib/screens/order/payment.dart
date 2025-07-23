import 'package:flutter/material.dart';
import 'package:portone_flutter/iamport_payment.dart';
import 'package:portone_flutter/model/payment_data.dart';

class PaymentScreen extends StatelessWidget {
  // Add a constructor to receive the payment data
  final PaymentData paymentData;
  const PaymentScreen({super.key, required this.paymentData});

  @override
  Widget build(BuildContext context) {
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
      data: paymentData,
      callback: (Map<String, String> result) {
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
      },
    );
  }
}
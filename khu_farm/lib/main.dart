import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'screens/splash/splash.dart';
import 'screens/account/login.dart';
import 'screens/account/signup/usertype.dart';
import 'screens/account/signup/consumer_signup.dart';
import 'screens/account/signup/retailer_signup.dart';
import 'screens/account/signup/farmer_signup.dart';
import 'screens/account/signup/consumer_signup_success.dart';
import 'screens/account/signup/retailer_signup_success.dart';
import 'screens/account/signup/farmer_signup_success.dart';
import 'screens/account/find/account_find.dart';
import 'screens/account/find/id_found.dart';
import 'screens/account/find/temp_password.dart';
import 'screens/account/find/account_not_found.dart';
import 'screens/consumer/main_screen.dart';
import 'screens/consumer/notification_list.dart';
import 'screens/consumer/daily/daily.dart';
import 'screens/consumer/harvest/harvest.dart';
import 'screens/consumer/laicos.dart';
import 'screens/consumer/mypage/mypage.dart';
import 'screens/consumer/mypage/info/info_list.dart';
import 'screens/consumer/mypage/info/edit_profile.dart';
import 'screens/consumer/mypage/info/edit_pw.dart';
import 'screens/consumer/mypage/info/edit_address.dart';
import 'screens/consumer/mypage/info/add_address.dart';
import 'screens/consumer/mypage/info/account_cancellation.dart';
import 'screens/consumer/mypage/info/account_cancelled.dart';
import 'screens/consumer/mypage/csc/personal_inquiry/personal_inquiry_list.dart';
import 'screens/consumer/mypage/csc/personal_inquiry/add_inquiry.dart';
import 'screens/consumer/mypage/csc/faq/faq_list.dart';

void main() {
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.white, // ← 상태바 배경 흰색
      statusBarIconBrightness: Brightness.dark, // ← 아이콘은 어두운색
      statusBarBrightness: Brightness.light, // ← iOS 대응용
    ),
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'KHU:FARM',
      theme: ThemeData(scaffoldBackgroundColor: Colors.white),
      initialRoute: '/',
      routes: {
        '/': (context) => const SplashScreen(),
        '/login': (context) => const LoginScreen(),
        '/signup/usertype': (context) => const UserTypeScreen(),
        '/signup/consumer': (context) => const ConsumerSignupScreen(),
        '/signup/retailer': (context) => const RetailerSignupScreen(),
        '/signup/farmer': (context) => const FarmerSignupScreen(),
        '/signup/consumer/success':
            (context) => const ConsumerSignupSuccessScreen(),
        '/signup/retailer/success':
            (context) => const RetailerSignupSuccessScreen(),
        '/signup/farmer/success':
            (context) => const FarmerSignupSuccessScreen(),
        '/account/find': (context) => const AccountFind(),
        '/account/find/idfound': (context) => const IdFoundScreen(),
        '/account/find/temppw': (context) => const TempPasswordSentScreen(),
        '/account/find/notfound': (context) => const AccountNotFound(),
        '/consumer/main': (context) => const ConsumerMainScreen(),
        '/consumer/notification/list':
            (context) => const ConsumerNotificationListScreen(),
        '/consumer/daily': (context) => const ConsumerDailyScreen(),
        '/consumer/harvest': (context) => const ConsumerHarvestScreen(),
        '/consumer/laicos': (context) => const ConsumerLaicosScreen(),
        '/consumer/mypage': (context) => const ConsumerMypageScreen(),
        '/consumer/mypage/info': (context) => const ConsumerInfoListScreen(),
        '/consumer/mypage/info/edit/profile':
            (context) => const ConsumerEditProfileScreen(),
        '/consumer/mypage/info/edit/pw':
            (context) => const ConsumerEditPwScreen(),
        '/consumer/mypage/info/edit/address':
            (context) => const ConsumerEditAddressScreen(),
        '/consumer/mypage/info/edit/address/add':
            (context) => const ConsumerAddAddressScreen(),
        '/consumer/mypage/info/cancel':
            (context) => const ConsumerAccountCancellationScreen(),
        '/consumer/mypage/info/cancel/success':
            (context) => const ConsumerAccountCancelledScreen(),
        '/consumer/mypage/inquiry/personal':
            (context) => const ConsumerPersonalInquiryListScreen(),
        '/consumer/mypage/inquiry/personal/add':
            (context) => const ConsumerAddInquiryScreen(),
        '/consumer/mypage/inquiry/faq':
            (context) => const ConsumerFAQListScreen(),
      },
    );
  }
}

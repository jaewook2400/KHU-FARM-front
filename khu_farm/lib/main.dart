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
      title: 'Flutter Demo',
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
      },
    );
  }
}

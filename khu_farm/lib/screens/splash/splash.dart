import 'package:flutter/material.dart';
import 'package:khu_farm/auth_service.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _attemptAutoLogin();
  }

  Future<void> _attemptAutoLogin() async {
    final userData = await AuthService.tryAutoLogin();

    if (userData != null) {
      final userType = userData['userType'];
      String route = '/login';
      switch (userType) {
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

      Navigator.pushReplacementNamed(context, route);
    } else {
      Navigator.pushReplacementNamed(context, '/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: CircularProgressIndicator()),
    );
  }
}
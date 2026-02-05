import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/household_model.dart';
import 'dashboard_screen.dart';
import 'login_screen.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
  }

  void _checkLoginStatus() async {
    // Chờ 1 chút cho đẹp (Optional)
    await Future.delayed(Duration(seconds: 1));

    final prefs = await SharedPreferences.getInstance();
    final String? familyId = prefs.getString('familyId');
    final String? username = prefs.getString('username');
    final bool? isAdmin = prefs.getBool('isAdmin');

    if (familyId != null && username != null) {
      // Đã từng đăng nhập -> Tái tạo object Member -> Vào thẳng Dashboard
      Member savedUser = Member(name: username, isAdmin: isAdmin ?? false);
      
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => DashboardScreen(
            familyId: familyId, 
            currentUser: savedUser
          ),
        ),
      );
    } else {
      // Chưa đăng nhập -> Vào trang Login
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => LoginScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Logo hoặc Icon App xoay vòng
            Icon(Icons.home_work, size: 80, color: Colors.blue),
            SizedBox(height: 20),
            CircularProgressIndicator(), // Vòng tròn xoay xoay loading
            SizedBox(height: 20),
            Text("Đang tải dữ liệu...", style: TextStyle(color: Colors.grey)),
          ],
        ),
      ),
    );
  }
}
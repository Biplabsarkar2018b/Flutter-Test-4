import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:test4/constants/color_constants.dart';
import 'package:test4/pages/login_page.dart';
import 'package:test4/providers/auth_provider.dart';

import 'home_page.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  @override
  void initState() {
    super.initState();
    Future.delayed(Duration(seconds: 3), () {
      checkSignedIn();
    });
  }

  void checkSignedIn() async {
    AuthProvider authProvider = context.read<AuthProvider>();
    bool isLoggedIn = await authProvider.isLoggedIn();

    //if logged in -------------- go to home page
    if (isLoggedIn) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => HomePage(),
        ),
      );
      return;
    }
    //if not logged in -------------- go to login page
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => LoginPage(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
        children: [
          Image.asset(
            "assets/images/photo5.jpg",
            width: 100,
            height: 100,
          ),
          SizedBox(
            height: 20,
          ),
          Container(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              color: ColorConstants.themeColor,
            ),
          ),
        ],
      )),
    );
  }
}

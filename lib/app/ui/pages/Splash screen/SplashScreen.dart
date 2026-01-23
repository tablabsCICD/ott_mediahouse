import 'dart:async';
import 'package:flutter/material.dart';
import 'package:media_house/app/core/constant/image_constant.dart';
import 'package:media_house/app/ui/pages/sign%20in%20page/SignInPage.dart';
import '../../../../device/utils/ResponsiveWidget.dart';
import '../../../core/constant/prefrense_constant.dart';
import '../../../core/utils/sharepreferences.dart';
import '../../NavigationPage.dart';
import '../network handler/NetworkHandler.dart';

class SplashScreen extends StatefulWidget {
  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  bool isLoggedIn = false;
  final LocalSharePreferences localSharePreferences = LocalSharePreferences();

  @override
  void initState() {
    super.initState();
    _initializeSplash();
  }

  Future<void> _initializeSplash() async {
    await getData();
    Timer(const Duration(seconds: 2), _navigateToNextScreen);
  }

  Future<void> getData() async {
    final bool? loggedIn =
        await localSharePreferences.getBool(SharedPreferencesConstant.isLogin);
    print(loggedIn);
    setState(() {
      isLoggedIn = loggedIn ?? false; // Default to false if null
    });
  }

  void _navigateToNextScreen() {
    Navigator.pushReplacement(
      context,
      // MaterialPageRoute(
      //   builder: (_) => NetworkHandler(
      //     mainPage: isLoggedIn ? NavigationPage() : SignInPage(),
      //   ),
      // ),
      MaterialPageRoute(
        builder: (_) => isLoggedIn ? NavigationPage() : SignInPage(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Hero(
              tag: "logo",
              child: ClipRRect(
                borderRadius: BorderRadiusGeometry.circular(25),
                child: Image.asset(
                  ImageConstant.logo,
                  width: ResponsiveWidget.isMobile(context) ? 150 : 200,
                  fit: BoxFit.contain,
                ),
              ),
            ),
            SizedBox(
              height: ResponsiveWidget.isMobile(context) ? 80 : 70,
            ),
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Text(
                'Discover, Watch & Collect the Latest Movies',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: ResponsiveWidget.isMobile(context) ? 13 : 18,
                  color: theme.canvasColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}

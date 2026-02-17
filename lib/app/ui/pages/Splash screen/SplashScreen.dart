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
    final size = MediaQuery.of(context).size;

    /// Responsive logo size
    double logoSize;
    if (ResponsiveWidget.isMobile(context)) {
      logoSize = size.width * 0.62;
    } else if (ResponsiveWidget.isTablet(context)) {
      logoSize = size.width * 0.38;
    } else {
      logoSize = size.width * 0.28;
    }

    /// Responsive text size
    double textSize;
    if (ResponsiveWidget.isMobile(context)) {
      textSize = 16;
    } else if (ResponsiveWidget.isTablet(context)) {
      textSize = 20;
    } else {
      textSize = 22;
    }

    return Scaffold(
      backgroundColor: theme.primaryColor,
      body: SafeArea(
        child: Center(
          child: Column(
            children: [
              const Spacer(flex: 3),

              /// Logo
              Hero(
                tag: 'logo',
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(logoSize),
                  child: Image.asset(
                    ImageConstant.logo,
                    width: logoSize,
                    height: logoSize,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
              SizedBox(
                height: 10,
              ),

              /// Tagline
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Text(
                  'Watch First Day First Show',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: textSize,
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.8,
                  ),
                ),
              ),

              const Spacer(flex: 4),
            ],
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:media_house/app/core/constant/image_constant.dart';
import 'package:media_house/app/provider/themeProvider.dart';
import 'package:media_house/app/ui/pages/sign%20in%20page/otp_screen.dart';
import 'package:media_house/app/widget/show_toast.dart';
import 'package:media_house/device/utils/ResponsiveWidget.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../provider/user_provider.dart';

class SignInPage extends StatefulWidget {
  const SignInPage({super.key});

  @override
  State<SignInPage> createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage> {
  final TextEditingController mobileController = TextEditingController();
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    var selectedThemeData =
        Provider.of<ThemeProvider>(context, listen: false).getTheme;

    return Scaffold(
      backgroundColor: selectedThemeData.scaffoldBackgroundColor,
      body: Column(
        children: [
          SizedBox(height: ResponsiveWidget.isMobile(context) ? 35 : 60),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                height: ResponsiveWidget.isMobile(context) ? 90 : 150,
                child: Hero(
                  tag: "logo",
                  child: ClipRRect(
                    borderRadius: BorderRadiusGeometry.circular(25),
                    child: Image.asset(
                      ImageConstant.logo,
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Center(
            child: SizedBox(
              width: ResponsiveWidget.isMobile(context) ? double.infinity : 400,
              child: loginCard(),
            ),
          ),
        ],
      ),
    );
  }

  Widget loginCard() {
    var selectedThemeData =
        Provider.of<ThemeProvider>(context, listen: false).getTheme;

    return Padding(
      padding: ResponsiveWidget.isMobile(context)
          ? EdgeInsets.zero
          : const EdgeInsets.all(16.0),
      child: Card(
        elevation: 4,
        color: selectedThemeData.cardColor,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Sign In',
                style: TextStyle(
                  color: selectedThemeData.primaryColor,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              IntlPhoneField(
                controller: mobileController,
                decoration: const InputDecoration(
                  labelText: 'Mobile Number',
                  border: OutlineInputBorder(),
                ),
                initialCountryCode: 'IN',
                onChanged: (phone) {
                  print(phone.completeNumber); // Full number with country code
                },
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: selectedThemeData.primaryColor,
                  padding:
                      const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onPressed: () {
                  _isLoading ? null : _handleLogin(context);
                },
                child: _isLoading
                    ? const CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      )
                    : Text(
                        'Send OTP',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: selectedThemeData.canvasColor,
                        ),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _handleLogin(BuildContext context) async {
    final mobile = mobileController.text.trim();

    if (mobile.isEmpty) {
      CustomToast.show('Please enter mobile number', isSuccess: false);
      return;
    }

    setState(() {
      _isLoading = true;
    });

    var result = await Provider.of<UserProvider>(context, listen: false)
        .loginWithMobile(mobile, context); // Assume you have this method
    if (result['success'] == true) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('isLoggedIn', true);

      CustomToast.show('OTP sent to $mobile', isSuccess: true);
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => OtpVerificationPage(mobileNumber: mobile),
        ),
      );
    } else {
      CustomToast.show('Failure: ${result['message']}', isSuccess: false);
    }

    setState(() {
      _isLoading = false;
    });
  }
}

import 'package:flutter/material.dart';
import 'package:media_house/app/provider/themeProvider.dart';
import 'package:media_house/app/ui/NavigationPage.dart';
import 'package:media_house/app/widget/show_toast.dart';
import 'package:media_house/device/utils/ResponsiveWidget.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../provider/user_provider.dart';

class OtpVerificationPage extends StatefulWidget {
  final String mobileNumber;

  const OtpVerificationPage({super.key, required this.mobileNumber});

  @override
  State<OtpVerificationPage> createState() => _OtpVerificationPageState();
}

class _OtpVerificationPageState extends State<OtpVerificationPage> {
  final TextEditingController otpController = TextEditingController();
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    var selectedThemeData = Provider.of<ThemeProvider>(context, listen: false).getTheme;

    return Scaffold(
      backgroundColor: selectedThemeData.scaffoldBackgroundColor,
      body: Column(
        children: [
          SizedBox(height: ResponsiveWidget.isMobile(context) ? 35 : 60),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                'assets/images/logo.png', // replace with your logo
                width: ResponsiveWidget.isMobile(context) ? 150 : 200,
              ),
            ],
          ),
          const SizedBox(height: 20),
          Center(
            child: SizedBox(
              width: ResponsiveWidget.isMobile(context) ? double.infinity : 400,
              child: otpCard(selectedThemeData),
            ),
          ),
        ],
      ),
    );
  }

  Widget otpCard(ThemeData selectedThemeData) {
    return Padding(
      padding: ResponsiveWidget.isMobile(context) ? EdgeInsets.zero : const EdgeInsets.all(16.0),
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
                'Verify OTP',
                style: TextStyle(
                  color: selectedThemeData.primaryColor,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                "Enter the OTP sent to ${widget.mobileNumber}",
                style: TextStyle(color: selectedThemeData.primaryColor, fontSize: 16),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              TextField(
                controller: otpController,
                decoration: const InputDecoration(
                  labelText: 'OTP',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                maxLength: 6,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: selectedThemeData.primaryColor,
                  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onPressed: () {
                  _isLoading ? null : _verifyOtp(context);
                },
                child: _isLoading
                    ? const CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                )
                    : Text(
                  'Verify',
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

  Future<void> _verifyOtp(BuildContext context) async {
    final otp = otpController.text.trim();

    if (otp.isEmpty || otp.length != 6) {
      CustomToast.show('Please enter a valid 6-digit OTP', isSuccess: false);
      return;
    }

    setState(() {
      _isLoading = true;
    });

    var result = await Provider.of<UserProvider>(context, listen: false)
        .verifyOtp(widget.mobileNumber, otp, context);

    if (result['success'] == true) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('isLoggedIn', true);

      CustomToast.show('Login Successful!', isSuccess: true);
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => NavigationPage()),
      );
    } else {
      CustomToast.show('Failure: ${result['message']}', isSuccess: false);
    }

    setState(() {
      _isLoading = false;
    });
  }
}

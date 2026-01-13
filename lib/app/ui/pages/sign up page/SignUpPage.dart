import 'package:flutter/material.dart';
import 'package:media_house/app/core/constant/image_constant.dart';
import 'package:media_house/app/provider/themeProvider.dart';
import 'package:media_house/app/ui/NavigationPage.dart';
import 'package:media_house/app/ui/pages/sign%20in%20page/SignInPage.dart';
import 'package:media_house/app/widget/custom_textfield.dart';
import 'package:media_house/device/utils/ResponsiveWidget.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../provider/user_provider.dart';

class SignUpPage extends StatefulWidget {
  @override
  _SignUpPageState createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _contactNumberController =
      TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  String? selectedGender;
  final _formKey = GlobalKey<FormState>(); // GlobalKey for Form validation



  @override
  Widget build(BuildContext context) {
    var themeProvider = Provider.of<ThemeProvider>(context, listen: true);

    var selectedThemeData = themeProvider.getTheme;
    bool isDark = selectedThemeData.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: selectedThemeData.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: selectedThemeData.scaffoldBackgroundColor,
        elevation: 0,
        toolbarHeight: ResponsiveWidget.isMobile(context) ? 60 : 100,
        title: SizedBox(
          height: ResponsiveWidget.isMobile(context) ? 70 : 100,
          child: Image.asset(
            ImageConstant.logo,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(
              isDark ? Icons.wb_sunny_outlined : Icons.nightlight_round,
              color: selectedThemeData.canvasColor,
            ),
            onPressed: themeProvider.toggleTheme,
          ),
        ],
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          return Center(
            child: SingleChildScrollView(
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                bottom: MediaQuery.of(context).viewInsets.bottom,
              ),
              child: SizedBox(
                width:
                    ResponsiveWidget.isMobile(context) ? double.infinity : 400,
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Sign Up",
                        style: TextStyle(
                          color: selectedThemeData.canvasColor,
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 15),
                      CustomTextField(
                        controller: _nameController,
                        hintText: "Enter your name",
                        label: "Name",
                        textInputType: TextInputType.name,
                        capitalization: TextCapitalization.words,
                        isValidator: true,
                        isName: true,
                      ),
                      CustomTextField(
                        controller: _emailController,
                        hintText: "Enter your email",
                        label: "Email",
                        textInputType: TextInputType.emailAddress,
                        isEmail: true,
                        capitalization: TextCapitalization.none,
                        isValidator: true,
                      ),
                      CustomTextField(
                        controller: _contactNumberController,
                        hintText: "Enter your Contact Number",
                        label: "Contact Number",
                        textInputType: TextInputType.number,
                        isPhoneNumber: true,
                        capitalization: TextCapitalization.none,
                        isValidator: true,
                      ),
                      CustomTextField(
                        controller: _passwordController,
                        hintText: "Enter your password",
                        label: "Password",
                        textInputType: TextInputType.text,
                        isPassword: true,
                        isValidator: true,
                      ),
                      CustomTextField(
                        controller: _confirmPasswordController,
                        hintText: "Confirm your password",
                        label: "Confirm Password",
                        textInputType: TextInputType.text,
                        isPassword: true,
                        isValidator: true,
                      ),
                      const SizedBox(height: 15),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _buildGenderButton("Male", selectedThemeData),
                          _buildGenderButton("Female", selectedThemeData),
                          _buildGenderButton("Other", selectedThemeData),
                        ],
                      ),
                      const SizedBox(height: 25),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: selectedThemeData.primaryColor,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(6),
                          ),
                        ),
                        onPressed: () async {
                          if (_formKey.currentState!.validate()) {
                            final email = _emailController.text.trim();
                            final password = _passwordController.text.trim();
                            final name = _nameController.text.trim();
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (context) => NavigationPage(),
                              ),
                            );

                            await Future.delayed(Duration(milliseconds: 500));
                            final prefs = await SharedPreferences.getInstance();
                            await prefs.setBool('isLoggedIn', true);
                            await prefs.setString('userEmail', email);
                            await prefs.setString('Name', name);
                            await prefs.setString('gender', selectedGender!);
                          }
                        },
                        child: const Center(
                          child: Text(
                            "Sign Up",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 15),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text("Already have an account?",
                              style: TextStyle(
                                  color: selectedThemeData.canvasColor,
                                  fontSize: 14)),
                          TextButton(
                            onPressed: _navigateToSignIn,
                            child: Text(
                              "Sign In",
                              style: TextStyle(
                                color: selectedThemeData.primaryColor,
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(
                        height: 50,
                      )
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildGenderButton(String gender, ThemeData selectedThemeData) {
    return GestureDetector(
      onTap: () => setState(() => selectedGender = gender),
      child: Container(
        height: 35,
        width: 90,
        decoration: BoxDecoration(
          color: selectedThemeData.cardColor,
          border: Border.all(
            width: selectedGender == gender ? 2 : 0.5,
            color: selectedGender == gender
                ? selectedThemeData.primaryColor
                : selectedThemeData.canvasColor,
          ),
          borderRadius: BorderRadius.circular(15),
        ),
        child: Center(
          child: Text(
            gender,
            style: TextStyle(
              color: selectedGender == gender
                  ? selectedThemeData.primaryColor
                  : selectedThemeData.canvasColor,
              fontWeight: selectedGender == gender
                  ? FontWeight.bold
                  : FontWeight.normal,
            ),
          ),
        ),
      ),
    );
  }

  // void _handleSignUp() async {
  //   // if (email.isEmpty ||
  //   //     password.isEmpty ||
  //   //     confirmPassword.isEmpty ||
  //   //     name.isEmpty ||
  //   //     selectedGender == null) {
  //   //   ScaffoldMessenger.of(context).showSnackBar(
  //   //       const SnackBar(content: Text('Please fill out all fields.')));
  //   //   return;
  //   // }

  //   if (password != confirmPassword) {
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       const SnackBar(
  //         content: Text('Passwords do not match'),
  //       ),
  //     );
  //     return;
  //   }

  // }

  void _navigateToSignIn() => Navigator.pushReplacement(
      context, MaterialPageRoute(builder: (context) => SignInPage()));
}

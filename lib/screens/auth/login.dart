// ignore_for_file: avoid_print, duplicate_ignore, use_build_context_synchronously

import 'dart:convert';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:lottie/lottie.dart';
import 'package:rc_fl_gopoolar/constants/key.dart';
import 'package:rc_fl_gopoolar/theme/theme.dart';
//import '../notification.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

import '../../utilis/dialog.dart';
import '../../utilis/response.dart';
import '../notification.dart';
import 'firebase.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  DateTime? backPressTime;

  final TextEditingController _mobileNumberController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  void dispose() {
    // Dispose controllers when the widget is disposed
    _mobileNumberController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> login(
      String type, String phone, String password, BuildContext context) async {
    http.Response response;

    try {
      if (type == "login") {
        // Login
        response = await http.post(
          Uri.parse('$apiUrl/api/login'),
          body: {
            'phone_number': phone,
            'password': password,
          },
        );
      } else {
        // Password reset
        response = await http.post(
          Uri.parse('$apiUrl/api/password-reset/request'),
          body: {
            'phone_number': phone,
          },
        );

        print(response.body);
      }

      final responseData = jsonDecode(response.body);
      if (response.statusCode == 200) {
        // Assuming the login API returns user data on successful login
        print("Assuming the login API returns user data on successful login");
        if (type == "login") {
          final user = responseData['user'];
          final access_token = responseData['access_token'];

          // Print and save user data
          print("User Data: ${user.toString()}");

          final prefs = await SharedPreferences.getInstance();
          bool saved = await prefs.setString('userData', jsonEncode(user));
          bool savedAccessUserToken =
              await prefs.setString('AccessUserToken', access_token);

          if (saved && savedAccessUserToken) {
            Navigator.pushNamed(context, '/bottomBar');
          } else {
            // Handle save failure
            print("Failed to save user data");
          }
        } else {
          // Handle password reset success
          print("Handle password reset success");
          final prefs = await SharedPreferences.getInstance();
          prefs.setString('PasswordResetPhone', phone);
          CustomFirebaseAuthenticationService.resetUser(
            phone,
            context: context,
          );
        }
      } else {
        Navigator.pop(context);
        // Assuming displayResponse function exists to format error messages
        String errorMessage = displayResponse(responseData);
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return NotificationDialog(
              message: errorMessage,
              icon: Icons.error,
              iconColor: Colors.red,
            );
          },
        );
      }
    } catch (error) {
      print(error);
      Navigator.pop(context);
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return const NotificationDialog(
            message: "Something went wrong! Please try again later.",
            icon: Icons.error,
            iconColor: Colors.red,
          );
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    // ignore: deprecated_member_use
    return WillPopScope(
      onWillPop: () async {
        bool backStatus = onWillPop(); // Call your existing onWillPop function
        if (backStatus) {
          exit(0);
        }
        return false; // Prevent default back behavior
      },
      child: AnnotatedRegion(
        value: const SystemUiOverlayStyle(
            statusBarColor: Colors.transparent,
            statusBarIconBrightness: Brightness.light),
        child: Scaffold(
          body: Column(
            children: [
              headerImage(size),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.all(fixPadding * 2.0),
                  physics: const BouncingScrollPhysics(),
                  children: [
                    loginTitle(),
                    heightSpace,
                    welcomeText(),
                    heightSpace,
                    heightSpace,
                    heightSpace,
                    heightSpace,
                    mobileNumberField(),
                    heightSpace,
                    heightSpace,
                    passwordField(),
                    heightSpace,
                    heightSpace,
                    heightSpace,
                    forgotText(),
                    heightSpace,
                    heightSpace,
                    heightSpace,
                    loginButton(context),
                    heightSpace,
                    heightSpace,
                    heightSpace,
                    registerText(),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  loginButton(contex) {
    return InkWell(
      onTap: () {
        // Navigator.pushNamed(context, '/register');
        // loginUser('phone', context);
        // pleaseWaitDialog(context);
        login("login", _mobileNumberController.text, _passwordController.text,
            context);
        pleaseWaitDialog(context);
      },
      child: Container(
        width: double.maxFinite,
        padding: const EdgeInsets.symmetric(
            horizontal: fixPadding * 2.0, vertical: fixPadding * 1.4),
        decoration: BoxDecoration(
          color: secondaryColor,
          borderRadius: BorderRadius.circular(10.0),
          boxShadow: [
            BoxShadow(
              color: secondaryColor.withOpacity(0.1),
              blurRadius: 12.0,
              offset: const Offset(0, 6),
            )
          ],
        ),
        alignment: Alignment.center,
        child: const Text(
          "Login",
          style: bold18White,
        ),
      ),
    );
  }

  mobileNumberField() {
    return Container(
      decoration: BoxDecoration(
        color: whiteColor,
        borderRadius: BorderRadius.circular(10.0),
        boxShadow: [
          BoxShadow(
            color: blackColor.withOpacity(0.1),
            blurRadius: 12.0,
            offset: const Offset(0, 6),
          )
        ],
      ),
      child: TextField(
        controller: _mobileNumberController,
        cursorColor: primaryColor,
        style: semibold15Black33,
        keyboardType: TextInputType.phone,
        decoration: const InputDecoration(
          border: InputBorder.none,
          hintText: "Enter your Mobile Number",
          hintStyle: semibold15Grey,
          contentPadding: EdgeInsets.symmetric(vertical: fixPadding * 1.4),
          prefixIcon: Icon(
            CupertinoIcons.phone,
            size: 20.0,
          ),
        ),
      ),
    );
  }

  passwordField() {
    return Container(
      decoration: BoxDecoration(
        color: whiteColor,
        borderRadius: BorderRadius.circular(10.0),
        boxShadow: [
          BoxShadow(
            color: blackColor.withOpacity(0.1),
            blurRadius: 12.0,
            offset: const Offset(0, 6),
          )
        ],
      ),
      child: TextField(
        controller: _passwordController,
        obscureText: true,
        cursorColor: primaryColor,
        style: semibold15Black33,
        keyboardType: TextInputType.emailAddress,
        decoration: const InputDecoration(
          border: InputBorder.none,
          hintText: "Enter your Password",
          hintStyle: semibold15Grey,
          contentPadding: EdgeInsets.symmetric(vertical: fixPadding * 1.4),
          prefixIcon: Icon(
            CupertinoIcons.padlock,
            size: 20.0,
          ),
        ),
      ),
    );
  }

  mobileNumberField1() {
    return Container(
      decoration: BoxDecoration(
        color: whiteColor,
        borderRadius: BorderRadius.circular(10.0),
        boxShadow: [
          BoxShadow(
            color: blackColor.withOpacity(0.1),
            blurRadius: 12.0,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: const IntlPhoneField(
        disableLengthCheck: true,
        showCountryFlag: false,
        dropdownIconPosition: IconPosition.trailing,
        dropdownIcon: Icon(
          Icons.keyboard_arrow_down,
          color: black33Color,
          size: 20.0,
        ),
        cursorColor: primaryColor,
        style: semibold15Black33,
        initialCountryCode: 'IN',
        dropdownTextStyle: semibold15Black33,
        flagsButtonMargin: EdgeInsets.symmetric(horizontal: fixPadding * 0.7),
        decoration: InputDecoration(
          border: InputBorder.none,
          hintText: "Enter your mobile number",
          hintStyle: semibold15Grey,
          contentPadding: EdgeInsets.symmetric(vertical: fixPadding * 1.4),
        ),
      ),
    );
  }

  welcomeText() {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: fixPadding * 2.0),
      child: Text(
        "Welcome, please login your account using mobile number",
        style: medium15Grey,
        textAlign: TextAlign.center,
      ),
    );
  }

  registerText() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: fixPadding * 2.0),
      child: InkWell(
        onTap: () {
          // Navigator.pushNamed(context, '/otp');
          Navigator.pushNamed(context, '/register');
        },
        child: const Text(
          "Don't have an account? Register here.",
          style: medium15Grey,
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  forgotText() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: fixPadding * 2.0),
      child: InkWell(
        onTap: () {
          login("forgot", _mobileNumberController.text, "", context);
          pleaseWaitDialog(context);
        },
        child: const Text(
          "Forgot passowrd?",
          style: medium15Grey,
          textAlign: TextAlign.right,
        ),
      ),
    );
  }

  loginTitle() {
    return const Text(
      "Login",
      style: semibold20Black33,
      textAlign: TextAlign.center,
    );
  }

  headerImage(Size size) {
    return Container(
      padding: const EdgeInsets.only(top: fixPadding * 1.5),
      width: double.maxFinite,
      height: size.height * 0.4,
      color: primaryColor,
      alignment: Alignment.center,
      child: Lottie.asset('assets/lottie_assets/2.json'),
    );
  }

  headerAnimation(Size size) {
    return Container(
      padding: const EdgeInsets.only(top: fixPadding * 1.5),
      width: double.maxFinite,
      height: size.height * 0.4,
      color: primaryColor,
      alignment: Alignment.center,
      child: Lottie.asset('assets/lottie_assets/1.json'),
      // Image.asset(
      //   "assets/lottie_assets/",
      //   height: size.height * 0.22,
      //   fit: BoxFit.cover,
      // ),
    );
  }

  onWillPop() {
    DateTime now = DateTime.now();
    if (backPressTime == null ||
        now.difference(backPressTime!) > const Duration(seconds: 2)) {
      backPressTime = now;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          duration: Duration(milliseconds: 1500),
          behavior: SnackBarBehavior.floating,
          backgroundColor: blackColor,
          content: Text(
            "Press back once again to exit",
            style: semibold15White,
          ),
        ),
      );
      return false;
    } else {
      return true;
    }
  }
}

// void _showLoginFailedAlert(BuildContext context) {
//   showDialog(
//     context: context,
//     builder: (context) {
//       return AlertDialog(
//         title: const Text('Login Failed'),
//         content: const Text('Incorrect username or password.'),
//         actions: <Widget>[
//           TextButton(
//             child: const Text('OK'),
//             onPressed: () {
//               Navigator.of(context).pop(); // Dismiss the dialog
//             },
//           ),
//         ],
//       );
//     },
//   );
// }


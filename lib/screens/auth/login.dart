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

  Future<void> login(String phn, String password, BuildContext context) async {
    print(phn);
    print(password);
    try {
      final response = await http.post(
        Uri.parse('$apiUrl/api/login'),
        body: {
          'phone_number': phn,
          'password': password,
        },
      );
      print(response.body);
      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);

        // Print the JSON response data
        // ignore: avoid_print
        print(responseData); // This will print the entire JSON response

        final user = responseData['user'];

        // Print specific user data
        print("User Data:");
        print("First Name: ${user['first_name']}");
        print("Last Name: ${user['last_name']}");
        print("Email: ${user['email']}");
        print("Phone Number: ${user['phone_number']}");
        print("Profile Picture: ${user['profile_picture']}");
        print("Sex: ${user['sex']}");
        print("Driving License: ${user['driving_license']}");

        // Save user data
        final prefs = await SharedPreferences.getInstance();
        final saved = await Future.wait([
          prefs.setString('firstName', user['first_name'] ?? ''),
          prefs.setString('lastName', user['last_name'] ?? ''),
          prefs.setString('email', user['email'] ?? ''),
          prefs.setString('profilePicture', user['profile_picture'] ?? ''),
          prefs.setString('phoneNumber', user['phone_number'] ?? ''),
          prefs.setString('sex', user['sex'] ?? ''),
          prefs.setString('drivingLicense', user['driving_license'] ?? ''),
        ]);

        // Navigate if saving was successful
        if (saved.every((result) => result)) {
          // ignore: use_build_context_synchronously
          Navigator.pushNamed(context, '/bottomBar');
        } else {
          // Handle save failure
        }
      } else {
        // Handle login error
        _showLoginFailedAlert(context);
      }
    } catch (error) {
      // Handle network or other errors
      _showLoginFailedAlert(context);
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
        login(_mobileNumberController.text, _passwordController.text, context);
        //login('0742552286', 'tanzahost', context);
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

void _showLoginFailedAlert(BuildContext context) {
  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: const Text('Login Failed'),
        content: const Text('Incorrect username or password.'),
        actions: <Widget>[
          TextButton(
            child: const Text('OK'),
            onPressed: () {
              Navigator.of(context).pop(); // Dismiss the dialog
            },
          ),
        ],
      );
    },
  );
}

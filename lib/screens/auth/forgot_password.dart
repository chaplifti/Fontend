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

import '../notification.dart';
import 'firebase.dart';

class ForgotPassword extends StatefulWidget {
  const ForgotPassword({super.key});

  @override
  State<ForgotPassword> createState() => _ForgotPasswordState();
}

class _ForgotPasswordState extends State<ForgotPassword> {
  DateTime? backPressTime;

  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _passwordConfirmController =
      TextEditingController();

  @override
  void dispose() {
    // Dispose controllers when the widget is disposed
    _passwordController.dispose();
    _passwordConfirmController.dispose();
    super.dispose();
  }

  Future<void> reset(
      String password, String c_password, BuildContext context) async {
    http.Response response;

    final prefs = await SharedPreferences.getInstance();
    final String? phone = prefs.getString('PasswordResetPhone');

    try {
      response = await http.post(
        Uri.parse('$apiUrl/api/password-reset/confirm'),
        body: {
          'phone_number': phone,
          'password': password,
          'password_confirmation': c_password,
        },
      );

      final responseData = jsonDecode(response.body);
      if (response.statusCode == 200) {
        // Assuming the login API returns user data on successful login
        Navigator.pushNamed(context, '/login');
      } else {
        Navigator.pop(context);
        // Assuming displayErrors function exists to format error messages
        String errorMessage = displayErrors(responseData);
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
                    Title(),
                    heightSpace,
                    // welcomeText(),
                    heightSpace,
                    heightSpace,
                    heightSpace,
                    heightSpace,
                    passwordField(),
                    heightSpace,
                    heightSpace,
                    heightSpace,
                    confirmField(),
                    heightSpace,
                    heightSpace,
                    heightSpace,
                    resetButton(context),
                    heightSpace,
                    heightSpace,
                    heightSpace,
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  resetButton(contex) {
    return InkWell(
      onTap: () {
        // Navigator.pushNamed(context, '/register');
        // loginUser('phone', context);
        // pleaseWaitDialog(context);
        reset(
            _passwordController.text, _passwordConfirmController.text, context);
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
          "reset",
          style: bold18White,
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

  confirmField() {
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
        controller: _passwordConfirmController,
        obscureText: true,
        cursorColor: primaryColor,
        style: semibold15Black33,
        keyboardType: TextInputType.emailAddress,
        decoration: const InputDecoration(
          border: InputBorder.none,
          hintText: "Confirm your Password",
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

  Title() {
    return const Text(
      "Reset your passowrd",
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

pleaseWaitDialog(BuildContext context) {
  showDialog(
    barrierDismissible: false, // User must tap button to dismiss
    context: context,
    builder: (BuildContext context) {
      return Dialog(
        // Use Dialog instead of Scaffold
        backgroundColor:
            Colors.transparent, // Makes the dialog background transparent
        elevation: 1, // No shadow
        child: Center(
          // Center the animation in the dialog
          child: LoadingAnimationWidget.staggeredDotsWave(
            color: Colors.white,
            size: 50,
          ),
        ),
      );
    },
  );
}

String displayErrors(dynamic response) {
  Map<String, dynamic> jsonResponse;
  if (response is String) {
    jsonResponse = jsonDecode(response) as Map<String, dynamic>;
  } else if (response is Map) {
    jsonResponse = response.cast<String, dynamic>();
  } else {
    return 'Unexpected response format';
  }

  Map<String, dynamic> errors = {};

  if (jsonResponse.containsKey('errors')) {
    errors = jsonResponse['errors'] as Map<String, dynamic>;
  } else if (jsonResponse.containsKey('error')) {
    errors = {
      'general': [jsonResponse['error']]
    };
  }

  String errorMessage = '';
  errors.forEach((key, dynamic value) {
    if (value is List<dynamic> && value.isNotEmpty) {
      errorMessage += '${value[0]}\n';
    } else if (value is String) {
      errorMessage += '$value\n';
    }
  });

  if (errorMessage.isNotEmpty) {
    errorMessage = errorMessage.substring(0, errorMessage.length - 1);
  }

  return errorMessage;
}

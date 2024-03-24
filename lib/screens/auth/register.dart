// ignore_for_file: use_build_context_synchronously, avoid_print

import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:lottie/lottie.dart';
import 'package:rc_fl_gopoolar/constants/key.dart';
import 'package:rc_fl_gopoolar/screens/notification.dart';
import 'package:rc_fl_gopoolar/theme/theme.dart';
import 'package:rc_fl_gopoolar/utilis/response.dart';
import 'package:shared_preferences/shared_preferences.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _mobileNumberController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  void dispose() {
    // Dispose controllers when the widget is disposed
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _mobileNumberController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // Future<void> register(String firstName, String lastName, String email,
  //     String phoneNumber, String password, BuildContext context) async {
  //   pleaseWaitDialog(context);
  //   try {
  //     final response = await http.post(
  //       Uri.parse(
  //           '$apiUrl/api/register'), // Adjusted to the registration endpoint
  //       body: {
  //         'first_name': _firstNameController.text,
  //         'last_name': _lastNameController.text,
  //         'email': _emailController.text,
  //         'phone_number': _mobileNumberController.text,
  //         'password': _passwordController.text,
  //         'password_confirmation': _passwordController.text,
  //       },
  //     );
  //     print(response.body);
  //
  //     final responseData = jsonDecode(response.body);
  //     Navigator.pop(context);
  //     String message = displayResponse(responseData);
  //
  //     if (response.statusCode == 200 || response.statusCode == 201) {
  //       showDialog(
  //         context: context,
  //         builder: (BuildContext context) {
  //           return NotificationDialog(
  //             message: message,
  //             icon: Icons.check_circle,
  //             iconColor: Colors.green,
  //           );
  //         },
  //       ).then((_) {
  //         Navigator.pushNamed(context, '/login'); // Example: Navigate to login
  //       });
  //     } else {
  //       // Handle registration error
  //       showDialog(
  //         context: context,
  //         builder: (BuildContext context) {
  //           return NotificationDialog(
  //             message: message,
  //             icon: Icons.error,
  //             iconColor: Colors.red,
  //           );
  //         },
  //       );
  //     }
  //   } catch (error) {
  //     // Handle network or other errors
  //     _showRegistrationFailedAlert(context, "An error occurred: $error");
  //   }
  // }

  // Future<void> register(String firstName, String lastName, String email,
  //     String phoneNumber, String password, BuildContext context) async {
  //   // Save user data to SharedPreferences
  //
  //   if (phoneNumber.startsWith('0')) {
  //     // Remove the first character (0)
  //     phoneNumber = phoneNumber.substring(1);
  //     // Add "255" at the beginning
  //     phoneNumber = '+255$phoneNumber';
  //   }
  //   print('number--------------$phoneNumber');
  //   final prefs = await SharedPreferences.getInstance();
  //   await prefs.setString('firstName', firstName);
  //   await prefs.setString('lastName', lastName);
  //   await prefs.setString('email', email);
  //   await prefs.setString('phoneNumber', phoneNumber);
  //   await prefs.setString('password', password);
  //
  //   // Validate phone number using Firebase
  //   try {
  //     await FirebaseAuth.instance.verifyPhoneNumber(
  //       phoneNumber: phoneNumber,
  //       verificationCompleted: (PhoneAuthCredential credential) async {
  //         // Sign in the user with the credential
  //         await FirebaseAuth.instance.signInWithCredential(credential);
  //         // Navigate to the forgot password screen
  //         Navigator.pushNamed(context, '/otp-new');
  //       },
  //       verificationFailed: (FirebaseAuthException e) {
  //         // Handle phone number verification failure
  //         print('Phone number verification failed: ${e.message}');
  //       },
  //       codeSent: (String verificationId, int? resendToken) {
  //         // Save verification ID to SharedPreferences
  //         prefs.setString('verificationId', verificationId);
  //         // Navigate to OTP verification screen
  //         Navigator.pushNamed(context, '/otp_verification',
  //             arguments: phoneNumber);
  //       },
  //       codeAutoRetrievalTimeout: (String verificationId) {
  //         // Handle code auto retrieval timeout
  //         print('Code auto retrieval timeout: $verificationId');
  //       },
  //     );
  //   } catch (e) {
  //     print('Error occurred during phone number verification: $e');
  //   }
  // }

  Future<void> register(String firstName, String lastName, String email,
      String phoneNumber, String password, BuildContext context) async {
    // Save user data to SharedPreferences
    if (phoneNumber.startsWith('0')) {
      // Remove the first character (0)
      phoneNumber = phoneNumber.substring(1);
      // Add "255" at the beginning
      phoneNumber = '+255$phoneNumber';
    }
    print('number--------------$phoneNumber');
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('firstName', firstName);
    await prefs.setString('lastName', lastName);
    await prefs.setString('email', email);
    await prefs.setString('phoneNumber', phoneNumber);
    await prefs.setString('password', password);

    // Validate phone number using Firebase
    try {
      await FirebaseAuth.instance.verifyPhoneNumber(
        phoneNumber: phoneNumber,
        verificationCompleted: (PhoneAuthCredential credential) async {
          try {
            // Save user data to the API
            final response = await http.post(
              Uri.parse(
                  '$apiUrl/api/register'), // Adjusted to the registration endpoint
              body: {
                'first_name': firstName,
                'last_name': lastName,
                'email': email,
                'phone_number': phoneNumber,
                'password': password,
                'password_confirmation': password,
              },
            );

            if (response.statusCode == 200 || response.statusCode == 201) {
              // Registration successful, navigate to OTP screen
              Navigator.pushNamed(context, '/otp-new');
            } else {
              // Handle registration error
              final responseData = jsonDecode(response.body);
              String message = displayResponse(responseData);
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return NotificationDialog(
                    message: message,
                    icon: Icons.error,
                    iconColor: Colors.red,
                  );
                },
              );
            }
          } catch (error) {
            // Handle network or other errors
            _showRegistrationFailedAlert(context, "An error occurred: $error");
          }
        },
        verificationFailed: (FirebaseAuthException e) {
          // Handle phone number verification failure
          print('Phone number verification failed: ${e.message}');
        },
        codeSent: (String verificationId, int? resendToken) {
          // Save verification ID to SharedPreferences
          prefs.setString('verificationId', verificationId);
          // Navigate to OTP verification screen
          Navigator.pushNamed(context, '/otp_verification',
              arguments: phoneNumber);
        },
        codeAutoRetrievalTimeout: (String verificationId) {
          // Handle code auto retrieval timeout
          print('Code auto retrieval timeout: $verificationId');
        },
      );
    } catch (e) {
      print('Error occurred during phone number verification: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      body: Column(
        children: [
          headerImage(size),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(fixPadding * 2.0),
              physics: const BouncingScrollPhysics(),
              children: [
                registerTitle(),
                heightSpace,
                welcomeText(),
                heightSpace,
                heightSpace,
                heightSpace,
                heightSpace,
                firstNameField(),
                heightSpace,
                heightSpace,
                lastNameField(),
                heightSpace,
                heightSpace,
                emailField(),
                heightSpace,
                heightSpace,
                mobileNumberField(),
                heightSpace,
                heightSpace,
                passwordField(),
                heightSpace,
                heightSpace,
                registerButton(),
              ],
            ),
          )
        ],
      ),
    );
  }

  registerButton() {
    return InkWell(
      onTap: () {
        register(
          _firstNameController.text,
          _lastNameController.text,
          _emailController.text,
          _mobileNumberController.text,
          _passwordController.text,
          context,
        );
        print(_passwordController.text);
        // FirebaseAuthenticationService.registerUser(_mobileNumberController.text,
        //     context: context);
        // Navigator.pushNamed(context, '/otp');
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
          "Register",
          style: bold18White,
        ),
      ),
    );
  }

  emailField() {
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
        controller: _emailController,
        cursorColor: primaryColor,
        style: semibold15Black33,
        keyboardType: TextInputType.emailAddress,
        decoration: const InputDecoration(
          border: InputBorder.none,
          hintText: "Enter your Email Address",
          hintStyle: semibold15Grey,
          contentPadding: EdgeInsets.symmetric(vertical: fixPadding * 1.4),
          prefixIcon: Icon(
            CupertinoIcons.mail,
            size: 20.0,
          ),
        ),
      ),
    );
  }

  firstNameField() {
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
        controller: _firstNameController,
        cursorColor: primaryColor,
        style: semibold15Black33,
        keyboardType: TextInputType.name,
        decoration: const InputDecoration(
          border: InputBorder.none,
          hintText: "Enter your  First Name",
          hintStyle: semibold15Grey,
          contentPadding: EdgeInsets.symmetric(vertical: fixPadding * 1.4),
          prefixIcon: Icon(
            CupertinoIcons.person,
            size: 20.0,
          ),
        ),
      ),
    );
  }

  lastNameField() {
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
        controller: _lastNameController,
        cursorColor: primaryColor,
        style: semibold15Black33,
        keyboardType: TextInputType.name,
        decoration: const InputDecoration(
          border: InputBorder.none,
          hintText: "Enter your Last Name",
          hintStyle: semibold15Grey,
          contentPadding: EdgeInsets.symmetric(vertical: fixPadding * 1.4),
          prefixIcon: Icon(
            CupertinoIcons.person,
            size: 20.0,
          ),
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

  welcomeText() {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: fixPadding * 2.0),
      child: Text(
        "Welcome, please create your account using email address",
        style: medium15Grey,
        textAlign: TextAlign.center,
      ),
    );
  }

  registerTitle() {
    return const Text(
      "Register",
      style: semibold20Black33,
      textAlign: TextAlign.center,
    );
  }

  headerImage(Size size) {
    return Container(
      width: double.maxFinite,
      height: size.height * 0.25,
      color: primaryColor,
      alignment: Alignment.center,
      child: Stack(
        children: [
          Container(
            padding: const EdgeInsets.only(top: fixPadding * 2.5),
            alignment: Alignment.center,
            child: Lottie.asset('assets/lottie_assets/2.json'),
          ),
          Padding(
            padding: const EdgeInsets.only(top: fixPadding * 2.0),
            child: Row(
              children: [
                IconButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  padding: const EdgeInsets.all(fixPadding * 2.0),
                  icon: const Icon(
                    Icons.arrow_back_ios,
                    color: whiteColor,
                  ),
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}

void _showRegistrationFailedAlert(BuildContext context, String message) {
  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: const Text('Registration Failed'),
        content: Text(message),
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

// ignore_for_file: use_build_context_synchronously, avoid_print

import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:pinput/pinput.dart';
import 'package:rc_fl_gopoolar/screens/auth/firebase.dart';
import 'package:rc_fl_gopoolar/theme/theme.dart';
import 'package:shared_preferences/shared_preferences.dart';

class OTPVerificationScreen extends StatefulWidget {
  const OTPVerificationScreen({super.key});

  @override
  State<OTPVerificationScreen> createState() => _OTPVerificationScreenState();
}

class _OTPVerificationScreenState extends State<OTPVerificationScreen> {
  Timer? countdownTimer;
  Duration myDuration = const Duration(minutes: 1);
  String? passwordResetPhone;

  @override
  void initState() {
    super.initState();
    startTimer();
    _loadPasswordResetPhone();
  }

  Future<void> _loadPasswordResetPhone() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      passwordResetPhone = prefs.getString('PasswordResetPhone');
    });
  }

  void startTimer() {
    countdownTimer =
        Timer.periodic(const Duration(seconds: 1), (_) => setCountDown());
  }

  void stopTimer() {
    setState(() => countdownTimer!.cancel());
  }

  void resetTimer() {
    stopTimer();
    setState(() => myDuration = const Duration(minutes: 1));
  }

  void setCountDown() {
    const reduceSecondsBy = 1;
    if (mounted) {
      setState(
        () {
          final seconds = myDuration.inSeconds - reduceSecondsBy;
          if (seconds < 0) {
            countdownTimer!.cancel();
          } else {
            myDuration = Duration(seconds: seconds);
          }
        },
      );
    }
  }

  PinTheme pinTheme = PinTheme(
    height: 50.0,
    width: 50.0,
    margin: const EdgeInsets.symmetric(horizontal: fixPadding / 3),
    textStyle: medium20Primary,
    decoration: BoxDecoration(
      color: whiteColor,
      borderRadius: BorderRadius.circular(5.0),
      boxShadow: [
        BoxShadow(
          color: blackColor.withOpacity(0.1),
          blurRadius: 12.0,
          offset: const Offset(0, 6),
        )
      ],
    ),
  );

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    String strDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = strDigits(myDuration.inMinutes.remainder(60));
    final seconds = strDigits(myDuration.inSeconds.remainder(60));
    return Scaffold(
      body: Column(
        children: [
          headerImage(size),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(fixPadding * 2.0),
              physics: const BouncingScrollPhysics(),
              children: [
                otpTitle(),
                heightSpace,
                confirmText(),
                heightSpace,
                heightSpace,
                heightSpace,
                otpField(),
                heightSpace,
                heightSpace,
                heightSpace,
                timer(minutes, seconds),
                heightSpace,
                heightSpace,
                heightSpace,
                verifyButton(),
                heightSpace,
                height5Space,
                resendText()
              ],
            ),
          )
        ],
      ),
    );
  }

  void verifyOTP(String enteredOTP, BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    final String? verification_id = prefs.getString('verificationId');

    PhoneAuthCredential credential = PhoneAuthProvider.credential(
      verificationId: verification_id!,
      smsCode: enteredOTP,
    );

    try {
      await FirebaseAuth.instance.signInWithCredential(credential);
      Navigator.pushNamed(context, '/forgot');
    } catch (e) {
      print("Error from verifyOTP $e");
    }
  }

  resendText() {
    return Text.rich(
      TextSpan(
        text: "Didn’t receive code?",
        style: semibold16Black33,
        children: [
          const TextSpan(text: " "),
          TextSpan(
            text: "Resend",
            style: semibold16Primary,
            recognizer: TapGestureRecognizer()
              ..onTap = () {
                if (myDuration == const Duration(seconds: 0)) {
                  resetTimer();
                  startTimer();
                }
              },
          )
        ],
      ),
      textAlign: TextAlign.center,
    );
  }

  otpField() {
    return Pinput(
      length: 6,
      cursor: Container(
        height: 20.0,
        width: 1.5,
        color: primaryColor,
      ),
      defaultPinTheme: pinTheme,
      onCompleted: (value) {
        // Timer(const Duration(seconds: 3), () {
        //   stopTimer();
        //   Navigator.popAndPushNamed(context, '/bottomBar');
        // });
        verifyOTP(value, context);
        // pleaseWaitDialog(context);
        // verifyButton(value);
        // pleaseWaitDialog();
      },
    );
  }

  verifyButton() {
    return InkWell(
      onTap: () {
        // Timer(const Duration(seconds: 3), () {
        //   stopTimer();
        //   Navigator.popAndPushNamed(context, '/bottomBar');
        // });
        // pleaseWaitDialog();
        // CustomFirebaseAuthenticationService.resetUser(
        //   passwordResetPhone!,
        //   smsCode: "code",
        //   context: context,
        // );
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
          "Verify",
          style: bold18White,
        ),
      ),
    );
  }

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

  timer(String minutes, String seconds) {
    return Text(
      "$minutes:$seconds",
      style: semibold16Secondary,
      textAlign: TextAlign.center,
    );
  }

  confirmText() {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: fixPadding),
      child: Text(
        "Confirmation code has been sent to you your mobile number +91 1234567890",
        style: medium15Grey,
        textAlign: TextAlign.center,
      ),
    );
  }

  otpTitle() {
    return const Text(
      "OTP verification",
      style: semibold20Black33,
      textAlign: TextAlign.center,
    );
  }

  headerImage(Size size) {
    return Container(
      width: double.maxFinite,
      height: size.height * 0.4,
      color: primaryColor,
      alignment: Alignment.center,
      child: Stack(
        children: [
          Container(
            padding: const EdgeInsets.only(top: fixPadding * 2.5),
            alignment: Alignment.center,
            child: Image.asset(
              "assets/auth/header-image.png",
              height: size.height * 0.22,
              fit: BoxFit.cover,
            ),
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

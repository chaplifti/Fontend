// ignore_for_file: avoid_print

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../notification.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

class CustomFirebaseAuthenticationService {
  static final FirebaseAuth auth = FirebaseAuth.instance;

  static void registerUser(String phone,
      {String? smsCode, required BuildContext context}) async {
    await auth.verifyPhoneNumber(
      phoneNumber: phone, // Consider making this dynamic
      verificationCompleted: (PhoneAuthCredential credential) async {
        print("Verification completed");
        Navigator.pushNamed(context, '/home');
        // You can implement auto sign-in here if needed
        // await auth.signInWithCredential(credential);
      },
      verificationFailed: (FirebaseAuthException e) {
        if (e.code == 'invalid-phone-number') {
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return const NotificationDialog(
                message: "The provided phone number is not valid.",
                icon: Icons.error,
                iconColor: Colors.red,
              );
            },
          );
        } else {
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return NotificationDialog(
                message: "${e.message}",
                icon: Icons.error,
                iconColor: Colors.red,
              );
            },
          );
        }
      },
      codeSent: (String verificationId, int? resendToken) async {
        if (smsCode != null) {
          PhoneAuthCredential credential = PhoneAuthProvider.credential(
              verificationId: verificationId, smsCode: smsCode);

          await auth.signInWithCredential(credential);
        } else {
          Navigator.pushNamed(context, '/otp');
        }
        // print("Code sent");
        // Implement logic to handle the code being sent
      },
      codeAutoRetrievalTimeout: (String verificationId) {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return const NotificationDialog(
              message: "codeAutoRetrievalTimeout",
              icon: Icons.error,
              iconColor: Colors.red,
            );
          },
        );
        Navigator.pushNamed(context, '/login');
      },
    );
  }

  static void resetUser(String phone,
      {String? smsCode, required BuildContext context}) async {
    String formattedPhone = formatPhoneNumber(phone);
    await auth.verifyPhoneNumber(
      phoneNumber: formattedPhone, // Consider making this dynamic
      verificationCompleted: (PhoneAuthCredential credential) async {
        print("Verification completed");
        Navigator.pushNamed(context, '/bottomBar');
        // You can implement auto sign-in here if needed
        // await auth.signInWithCredential(credential);
      },
      verificationFailed: (FirebaseAuthException e) {
        if (e.code == 'invalid-phone-number') {
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return const NotificationDialog(
                message: "The provided phone number is not valid.",
                icon: Icons.error,
                iconColor: Colors.red,
              );
            },
          );
        } else {
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return NotificationDialog(
                message: "${e.message}",
                icon: Icons.error,
                iconColor: Colors.red,
              );
            },
          );
        }
      },
      codeSent: (String verificationId, int? resendToken) async {
        final prefs = await SharedPreferences.getInstance();
        prefs.setString('verificationId', verificationId);

        if (smsCode != null) {
          try {
            // Create a PhoneAuthCredential with the code
            PhoneAuthCredential credential = PhoneAuthProvider.credential(
                verificationId: verificationId, smsCode: smsCode);

            // Try to sign in the user with the credential
            final UserCredential userCredential =
                await auth.signInWithCredential(credential);

            // If the sign-in succeeds, userCredential will contain information about the signed-in user
            if (userCredential.user != null) {
              print("Firebase Reset Sign in successful!");
              // Navigate to the home screen or another appropriate screen
              // ignore: use_build_context_synchronously
              Navigator.pushNamed(context, '/home');
            } else {
              // This block might not be necessary as an exception should be thrown if Firebase Reset sign-in fails
              print("Firebase Reset Sign in failed: User is null.");
              // Handle the failure (e.g., show an error message)
            }
          } catch (e) {
            // Catch any errors and handle them appropriately
            print("Firebase Reset Sign in failed: ${e.toString()}");
            // ignore: use_build_context_synchronously
            showDialog(
              context: context,
              builder: (BuildContext context) {
                return NotificationDialog(
                  message: "Firebase Reset Sign in failed: ${e.toString()}",
                  icon: Icons.error,
                  iconColor: Colors.red,
                );
              },
            );
          }
        } else {
          Navigator.pushNamed(context, '/otp');
        }
        // print("Code sent");
        // Implement logic to handle the code being sent
      },
      codeAutoRetrievalTimeout: (String verificationId) {
        // showDialog(
        //   context: context,
        //   builder: (BuildContext context) {
        //     return const NotificationDialog(
        //       message: "codeAutoRetrievalTimeout",
        //       icon: Icons.error,
        //       iconColor: Colors.red,
        //     );
        //   },
        // );
        // Navigator.pushNamed(context, '/login');
      },
    );
  }

  // static void verifiyOTP() async {
  //   FirebaseAuth auth = FirebaseAuth.instance;

  //   await auth.verifyPhoneNumber(
  //     phoneNumber: '+44 7123 123 456',
  //     codeSent: (String verificationId, int? resendToken) async {
  //       // Update the UI - wait for the user to enter the SMS code
  //       String smsCode = 'xxxx';

  //       // Create a PhoneAuthCredential with the code
  //       PhoneAuthCredential credential = PhoneAuthProvider.credential(
  //           verificationId: verificationId, smsCode: smsCode);

  //       // Sign the user in (or link) with the credential
  //       await auth.signInWithCredential(credential);
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

  static String formatPhoneNumber(String phoneNumber) {
    if (phoneNumber.startsWith('0')) {
      return '+255${phoneNumber.substring(1)}';
    }
    // If the phone number already starts with +255 or doesn't start with 0, return it as is
    return phoneNumber;
  }
}

// import 'dart:async';

// import 'package:flutter/material.dart';
// import 'package:rc_fl_gopoolar/theme/theme.dart';

// class SplashScreen extends StatefulWidget {
//   const SplashScreen({super.key});

//   @override
//   State<SplashScreen> createState() => _SplashScreenState();
// }

// class _SplashScreenState extends State<SplashScreen> {
//   @override
//   void initState() {
//     Timer(const Duration(seconds: 3), () {
//       Navigator.pushNamed(context, '/onboarding');
//     });
//     super.initState();
//   }

// ignore_for_file: use_build_context_synchronously

//   @override
//   Widget build(BuildContext context) {
//     final size = MediaQuery.of(context).size;
//     return Scaffold(
//       backgroundColor: primaryColor,
//       body: Center(
//         child: ListView(
//           physics: const BouncingScrollPhysics(),
//           padding: const EdgeInsets.all(fixPadding * 2.0),
//           shrinkWrap: true,
//           children: [
//             Image.asset(
//               "assets/splash/poolar-logo.png",
//               height: size.height * 0.125,
//             ),
//             const Text(
//               "Chap Lifti",
//               style: semibold28White,
//               textAlign: TextAlign.center,
//             )
//           ],
//         ),
//       ),
//     );
//   }
// }
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:rc_fl_gopoolar/theme/theme.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    _checkFirstName();
    super.initState();
  }

  Future<void> _checkFirstName() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? firstName = prefs.getString('firstName');

    if (firstName != null && firstName.isNotEmpty) {
      // First name exists, push to onboarding screen
      Navigator.pushNamed(context, '/bottomBar');
    } else {
      // First name not found, push to login screen
      Navigator.pushNamed(context, '/onboarding');
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: primaryColor,
      body: Center(
        child: ListView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.all(fixPadding * 2.0),
          shrinkWrap: true,
          children: [
            Image.asset(
              "assets/splash/poolar-logo.png",
              height: size.height * 0.125,
            ),
            const Text(
              "Chap Lifti",
              style: semibold28White,
              textAlign: TextAlign.center,
            )
          ],
        ),
      ),
    );
  }
}

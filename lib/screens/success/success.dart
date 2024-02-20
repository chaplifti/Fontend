// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lottie/lottie.dart';
import 'package:rc_fl_gopoolar/theme/theme.dart';

class SuccessScreen extends StatefulWidget {
  const SuccessScreen({super.key});

  @override
  State<SuccessScreen> createState() => _SuccessScreenState();
}

class _SuccessScreenState extends State<SuccessScreen> {
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    final data =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>;

    final id = data['id'];

    return WillPopScope(
      onWillPop: () async {
        onWillpop();
        return false;
      },
      child: AnnotatedRegion(
        value: const SystemUiOverlayStyle(
            statusBarColor: Colors.transparent,
            statusBarIconBrightness: Brightness.dark),
        child: Scaffold(
          body: Column(
            children: [
              successContent(size, id),
              backToHomeButton(context),
            ],
          ),
        ),
      ),
    );
  }

  backToHomeButton(BuildContext context) {
    return TextButton(
      onPressed: () {
        Navigator.pushNamed(context, '/bottomBar');
      },
      child: const Text(
        "Back to home",
        style: semibold16Primary,
      ),
    );
  }

  successContent(Size size, id) {
    return Expanded(
      child: Center(
        child: ListView(
          shrinkWrap: true,
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.all(fixPadding * 2.0),
          children: [
            Center(
              // child: Lottie.asset('lottie_assets/1.json'),
              child: Image.asset(
                "assets/success/driving-pana.png",
                height: size.height * 0.2,
                fit: BoxFit.cover,
              ),
            ),
            heightSpace,
            heightSpace,
            const Text(
              "Congratulation",
              style: semibold18Black33,
              textAlign: TextAlign.center,
            ),
            heightSpace,
            Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: size.width * 0.56),
                child: Text(
                  id == 1
                      ? "Your ride offer has been created successfully"
                      : "Your car pooing has been  confirmed",
                  style: semibold14Grey,
                  textAlign: TextAlign.center,
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  onWillpop() {
    Navigator.pushNamed(context, '/bottomBar');
  }
}

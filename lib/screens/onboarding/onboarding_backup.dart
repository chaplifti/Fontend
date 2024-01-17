import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:onboarding/onboarding.dart';
import 'package:rc_fl_gopoolar/theme/theme.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  int currentIndex = 0;

  DateTime? backPressTime;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    final pageModelList = [
      pageModelWidget(
          size,
          "assets/onboarding/image1.png",
          "Your ride your route",
          "Lorem ipsum dolor sit amet consectetur. Faucirisuorem eu netus commodo nisi pellentesque laoreet. Vivamus pulvinar adipiscing tempor ultrices a et."),
      pageModelWidget(size, "assets/onboarding/image2.png", "Fast and reliable",
          "Lorem ipsum dolor sit amet consectetur. Faucirisuorem eu netus commodo nisi pellentesque laoreet. Vivamus pulvinar adipiscing tempor ultrices a et."),
      pageModelWidget(
          size,
          "assets/onboarding/image3.png",
          "Pay for just the seat",
          "Lorem ipsum dolor sit amet consectetur. Faucirisuorem eu netus commodo nisi pellentesque laoreet. Vivamus pulvinar adipiscing tempor ultrices a et."),
    ];
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
            statusBarIconBrightness: Brightness.dark),
        child: Scaffold(
          backgroundColor: screenBgColor,
          body: ListView(
            physics: const BouncingScrollPhysics(),
            padding: EdgeInsets.zero,
            children: [
              SizedBox(
                height: size.height,
                width: size.width,
                child: Stack(
                  children: [
                    bottomBox(),
                    content(pageModelList),
                    currentIndex + 1 == pageModelList.length
                        ? const SizedBox()
                        : skipButton(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  bottomBox() {
    return Align(
      alignment: Alignment.bottomCenter,
      child: Container(
        width: double.maxFinite,
        height: 300,
        padding: const EdgeInsets.all(fixPadding * 2.0),
        decoration: const BoxDecoration(
          color: primaryColor,
          borderRadius: BorderRadius.vertical(top: Radius.circular(40.0)),
        ),
      ),
    );
  }

  skipButton() {
    return Padding(
      padding: const EdgeInsets.only(top: 20.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          TextButton(
            style: TextButton.styleFrom(
                padding:
                    const EdgeInsets.symmetric(horizontal: fixPadding * 2.0)),
            onPressed: () {
              Navigator.pushNamed(context, '/login');
            },
            child: const Text(
              "Skip",
              style: semibold16Grey,
            ),
          )
        ],
      ),
    );
  }

  content(List<PageModel> pageModelList) {
    return Onboarding(
      pages: pageModelList,
      startPageIndex: currentIndex,
      onPageChange: (index) {
        setState(
          () {
            currentIndex = index;
          },
        );
      },
      footerBuilder: (context, netDragDistance, pagesLength, setIndex) {
        return Container(
          padding: const EdgeInsets.all(fixPadding * 2.0),
          height: 170,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  3,
                  (index) => Container(
                    height: 8,
                    width: currentIndex == index ? 50.0 : 8,
                    margin: const EdgeInsets.symmetric(
                        horizontal: fixPadding / 2.5),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20.0),
                      color:
                          currentIndex == index ? secondaryColor : greyB4Color,
                    ),
                  ),
                ),
              ),
              currentIndex + 1 == pageModelList.length
                  ? loginButton()
                  : nextButton(),
            ],
          ),
        );
      },
    );
  }

  loginButton() {
    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(context, '/login');
      },
      child: Container(
        padding: const EdgeInsets.symmetric(
            horizontal: fixPadding * 2.0, vertical: fixPadding * 1.4),
        margin: const EdgeInsets.only(bottom: fixPadding),
        decoration: BoxDecoration(
          color: secondaryColor,
          borderRadius: BorderRadius.circular(10.0),
          boxShadow: [
            BoxShadow(
              color: secondaryColor.withOpacity(0.1),
              blurRadius: 12.0,
              offset: const Offset(0, 6),
            ),
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

  nextButton() {
    return GestureDetector(
      onTap: () {
        setState(() {
          currentIndex++;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(
            horizontal: fixPadding * 2.0, vertical: fixPadding * 1.4),
        margin: const EdgeInsets.only(bottom: fixPadding),
        decoration: BoxDecoration(
          color: secondaryColor,
          borderRadius: BorderRadius.circular(10.0),
          boxShadow: [
            BoxShadow(
              color: secondaryColor.withOpacity(0.1),
              blurRadius: 12.0,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        alignment: Alignment.center,
        child: const Text(
          "Next",
          style: bold18White,
        ),
      ),
    );
  }

  PageModel pageModelWidget(
      Size size, String image, String title, String detail) {
    return PageModel(
      widget: Container(
        color: Colors.transparent,
        child: Column(
          children: [
            Expanded(
              child: Column(
                children: [
                  const Spacer(),
                  Center(
                    child: Image.asset(
                      image,
                      height: size.height * 0.32,
                      fit: BoxFit.cover,
                    ),
                  ),
                  const Spacer(),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: fixPadding * 2.0),
              child: SizedBox(
                height: 100,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      title,
                      style: semibold20White,
                      overflow: TextOverflow.ellipsis,
                    ),
                    heightSpace,
                    Text(
                      detail,
                      style: medium14White,
                      textAlign: TextAlign.center,
                      overflow: TextOverflow.ellipsis,
                      maxLines: 3,
                    ),
                  ],
                ),
              ),
            )
          ],
        ),
      ),
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

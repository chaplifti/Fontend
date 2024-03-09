// ignore_for_file: deprecated_member_use

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:iconify_flutter/iconify_flutter.dart';
import 'package:iconify_flutter/icons/bi.dart';
import 'package:iconify_flutter/icons/carbon.dart';
import 'package:iconify_flutter/icons/ph.dart';
import 'package:iconify_flutter/icons/uil.dart';
import 'package:rc_fl_gopoolar/screens/screens.dart';
import 'package:rc_fl_gopoolar/theme/theme.dart';

class BottomBar extends StatefulWidget {
  const BottomBar({super.key});

  @override
  State<BottomBar> createState() => _BottomBarState();
}

class _BottomBarState extends State<BottomBar> {
  int selectedIndex = 0;

  DateTime? backPressTime;

  final itemList = [
    {
      "icon": Carbon.home,
      "title": "Home",
    },
    {
      "icon": Uil.receipt,
      "title": "Requests",
    },
    {
      "icon": Uil.location_arrow_alt,
      "title": "My rides",
    },
    {
      "icon": Ph.wallet_light,
      "title": "Wallet",
    },
    {
      "icon": Bi.person,
      "title": "Profile",
    },
  ];

  final pages = const [
    HomeScreen(),
    MyRequestScreen(),
    // MyRidesScreen(),
    RideRequestScreen(),
    WalletScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
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
          statusBarIconBrightness: Brightness.light,
        ),
        child: Scaffold(
          body: pages.elementAt(selectedIndex),
          bottomNavigationBar: bottomBar(),
        ),
      ),
    );
  }

  bottomBar() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          decoration: BoxDecoration(
            color: whiteColor,
            boxShadow: [
              BoxShadow(
                color: blackColor.withOpacity(0.15),
                blurRadius: 6.0,
              ),
            ],
          ),
          child: Stack(
            children: [
              BottomNavigationBar(
                showSelectedLabels: true,
                showUnselectedLabels: true,
                currentIndex: selectedIndex,
                onTap: (index) {
                  setState(() {
                    selectedIndex = index;
                  });
                },
                selectedItemColor: primaryColor,
                unselectedItemColor: greyColor,
                selectedLabelStyle: semibold14Primary,
                unselectedLabelStyle: semibold14Grey,
                type: BottomNavigationBarType.fixed,
                iconSize: 22.0,
                backgroundColor: whiteColor,
                items: List.generate(
                  itemList.length,
                  (index) => BottomNavigationBarItem(
                    icon: Padding(
                      padding: const EdgeInsets.only(top: 5.0, bottom: 3.0),
                      child: Iconify(
                        itemList[index]['icon'].toString(),
                        color: greyColor,
                        size: 22.0,
                      ),
                    ),
                    activeIcon: Padding(
                      padding: const EdgeInsets.only(top: 5.0, bottom: 3.0),
                      child: Iconify(
                        itemList[index]['icon'].toString(),
                        color: primaryColor,
                        size: 22.0,
                      ),
                    ),
                    label: itemList[index]['title'].toString(),
                  ),
                ),
              ),
              Column(
                children: [
                  Row(
                    children: List.generate(
                      5,
                      (index) => Expanded(
                        child: Center(
                          child: Container(
                            height: 5.5,
                            width: 45.0,
                            color: selectedIndex == index
                                ? secondaryColor
                                : Colors.transparent,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
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

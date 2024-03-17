import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:iconify_flutter/iconify_flutter.dart';
import 'package:iconify_flutter/icons/material_symbols.dart';
import 'package:rc_fl_gopoolar/theme/theme.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String? _firstName;
  String? _lastName;
  String? _phoneNumber;

  @override
  void initState() {
    super.initState();
    _fetchValue();
  }

  Future<void> _fetchValue() async {
    final prefs = await SharedPreferences.getInstance();
    final String? userDataString = prefs.getString('userData');
    // Obtain shared preferences.

    // print(userDataString);

    if (userDataString != null) {
      final Map<String, dynamic> userData = jsonDecode(userDataString);

      setState(() {
        _firstName = userData['first_name'];
        _lastName = userData['last_name'];
        _phoneNumber = userData['phone_number'];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: f8Color,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: primaryColor,
        automaticallyImplyLeading: false,
        centerTitle: true,
        titleSpacing: 20.0,
        title: const Text(
          "Profile",
          style: semibold18White,
        ),
      ),
      body: Column(
        children: [
          userDetail(),
          profileOptions(context),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          // Add your onPressed code here!
        },
        backgroundColor: Colors.indigo,
        label: const Text(
          'Get Help',
          style: TextStyle(color: Colors.white),
        ),
        icon: const Icon(
          Icons.emoji_people,
          color: Colors.white,
        ),
      ),
    );
  }

  profileOptions(BuildContext context) {
    return Expanded(
      child: Container(
        width: double.maxFinite,
        color: whiteColor,
        child: ListView(
          padding: const EdgeInsets.all(fixPadding * 2.0),
          physics: const BouncingScrollPhysics(),
          children: [
            iconProfileOption(
                CupertinoIcons.text_bubble, "Chat", "Chats History", () {
              Navigator.pushNamed(context, '/chatslist');
            }),
            divider(),
            imageProfileOption("assets/profile/car-line.png", "My vehicle",
                "Add vehicle information", () {
              Navigator.pushNamed(context, '/myVehicle');
            }),
            divider(),
            iconProfileOption(
                Icons.history, "Ride history", "See your ride history", () {
              Navigator.pushNamed(context, '/rideHistory');
            }),
            divider(),
            iconProfileOption(CupertinoIcons.square_list, "Terms and condition",
                "Know our terms and condition", () {
              Navigator.pushNamed(context, '/termsAndCondition');
            }),
            divider(),
            iconProfileOption(CupertinoIcons.exclamationmark_shield,
                "Privacy policy", "Know our policy", () {
              Navigator.pushNamed(context, '/privacyPolicy');
            }),
            divider(),
            iconProfileOption(CupertinoIcons.question_circle, "FAQs",
                "Get your question answer", () {
              Navigator.pushNamed(context, '/faqs');
            }),
            divider(),
            imageProfileOption("assets/profile/headset.png", "Customer support",
                "Connect us for any issue", () {
              Navigator.pushNamed(context, '/customerSupport');
            }),
            divider(),
            imageProfileOption(
                "assets/profile/logout.png", "Logout", "Logout your account",
                () {
              logoutDialog();
            }, color: redColor),
          ],
        ),
      ),
    );
  }

  // chats() {
  //   return ListView(
  //     children: const [],
  //   );
  // }

  logoutDialog() {
    return showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          clipBehavior: Clip.hardEdge,
          backgroundColor: whiteColor,
          insetPadding: const EdgeInsets.all(fixPadding * 3.0),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Padding(
                padding: EdgeInsets.symmetric(
                    vertical: fixPadding * 2.4, horizontal: fixPadding * 2.0),
                child: Text(
                  "Are you sure you want to logout this account?",
                  style: semibold16Black33,
                  textAlign: TextAlign.center,
                ),
              ),
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        Navigator.pop(context);
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: fixPadding, vertical: fixPadding * 1.2),
                        color: secondaryColor,
                        alignment: Alignment.center,
                        child: const Text(
                          "No",
                          style: semibold18White,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                  ),
                  widthBox(2.0),
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        Navigator.pushNamed(context, '/login');
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: fixPadding, vertical: fixPadding * 1.2),
                        color: secondaryColor,
                        alignment: Alignment.center,
                        child: const Text(
                          "Logout",
                          style: semibold18White,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                  ),
                ],
              )
            ],
          ),
        );
      },
    );
  }

  iconProfileOption(
      IconData icon, String title, String subTitle, Function() onTap) {
    return InkWell(
      onTap: onTap,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            size: 18.0,
            color: black33Color,
          ),
          widthSpace,
          Expanded(
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: semibold16Black33,
                      ),
                      heightBox(2.0),
                      Text(
                        subTitle,
                        style: medium14Grey,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      )
                    ],
                  ),
                ),
                width5Space,
                const Icon(
                  Icons.arrow_forward_ios,
                  color: black33Color,
                  size: 16.0,
                )
              ],
            ),
          )
        ],
      ),
    );
  }

  imageProfileOption(
      String image, String title, String subTitle, Function() onTap,
      {Color color = black33Color}) {
    return InkWell(
      onTap: onTap,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 18.0,
            width: 18.0,
            alignment: Alignment.center,
            child: Image.asset(
              image,
              height: 16.0,
              width: 16.0,
              color: color,
            ),
          ),
          widthSpace,
          Expanded(
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: semibold16Black33.copyWith(color: color),
                      ),
                      heightBox(2.0),
                      Text(
                        subTitle,
                        style: medium14Grey,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      )
                    ],
                  ),
                ),
                width5Space,
                const Icon(
                  Icons.arrow_forward_ios,
                  color: black33Color,
                  size: 16.0,
                )
              ],
            ),
          )
        ],
      ),
    );
  }

  divider() {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: fixPadding * 1.8),
      width: double.maxFinite,
      height: 1.0,
      color: greyD4Color,
    );
  }

  userDetail() {
    if (_firstName == null || _lastName == null || _phoneNumber == null) {
      return const CircularProgressIndicator(); // Replace with your loading widget.
    }
    return Padding(
      padding: const EdgeInsets.all(fixPadding * 2.0),
      child: Row(
        children: [
          CircleAvatar(
            maxRadius: 35,
            backgroundColor: Colors.indigo,
            child: Text(
              _firstName?[0] ?? 'No value found',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 33,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          // Container(
          //   height: 75.0,
          //   width: 75.0,
          //   decoration: const BoxDecoration(
          //     shape: BoxShape.circle,
          //     image: DecorationImage(
          //       image: AssetImage(
          //         "assets/profile/user-image.png",
          //       ),
          //     ),
          //   ),
          // ),
          widthSpace,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$_firstName $_lastName',
                  style: semibold17Black33,
                  overflow: TextOverflow.ellipsis,
                ),
                height5Space,
                Text(
                  _phoneNumber!,
                  style: semibold16Grey,
                  overflow: TextOverflow.ellipsis,
                )
              ],
            ),
          ),
          InkWell(
            onTap: () {
              Navigator.pushNamed(context, '/editProfile');
            },
            child: const Iconify(
              MaterialSymbols.edit_square_outline_rounded,
              color: secondaryColor,
              size: 23,
            ),
          )
        ],
      ),
    );
  }
}

import 'dart:convert';
import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:rc_fl_gopoolar/constants/key.dart';
import 'package:rc_fl_gopoolar/theme/theme.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';

import '../../utilis/dialog.dart';
import '../../utilis/response.dart';
import '../notification.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  TextEditingController firstNameController = TextEditingController();
  TextEditingController lastNameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController mobileNumberController = TextEditingController();
  TextEditingController licenceNumberController = TextEditingController();
  TextEditingController profilePictureController = TextEditingController();
  final ImagePicker _picker = ImagePicker();
  File? _pickedImage;

  @override
  void initState() {
    super.initState();
    _fetchValue();
  }

  Future<void> _fetchValue() async {
    final prefs = await SharedPreferences.getInstance();
    final String? userDataString = prefs.getString('userData');
    // Obtain shared preferences.

    // print('userdata------$userDataString');

    if (userDataString != null) {
      final Map<String, dynamic> userData = jsonDecode(userDataString);
      firstNameController.text = userData['first_name'];
      lastNameController.text = userData['last_name'];
      mobileNumberController.text = userData['phone_number'];
      emailController.text = userData['email'];
      // licenceNumberController.text = userData['driving_license'];
      // profilePictureController.text = userData['profile_picture'];
      // print(firstNameController);
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: primaryColor,
        automaticallyImplyLeading: false,
        centerTitle: false,
        titleSpacing: 0.0,
        leading: IconButton(
          padding: const EdgeInsets.symmetric(horizontal: fixPadding * 2.0),
          onPressed: () {
            Navigator.pop(context);
          },
          icon: const Icon(
            Icons.arrow_back_ios,
            color: whiteColor,
          ),
        ),
        title: const Text(
          "Edit profile",
          style: semibold18White,
        ),
      ),
      body: ListView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(fixPadding * 2.0),
        children: [
          profileImage(size),
          heightSpace,
          heightSpace,
          heightSpace,
          heightSpace,
          height5Space,
          firstNameField(),
          heightSpace,
          heightSpace,
          heightSpace,
          lastNameField(),
          // heightSpace,
          // heightSpace,
          // heightSpace,
          // emailField(),
          // heightSpace,
          // heightSpace,
          // heightSpace,
          // mobileNumberField(),
          heightSpace,
          heightSpace,
          heightSpace,
          // vehicleImage(),
          FutureBuilder<Widget>(
            future: vehicleImage(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                // While the image is being loaded
                return CircularProgressIndicator();
              } else if (snapshot.hasError) {
                // If an error occurred
                return Text('Error loading image: ${snapshot.error}');
              } else {
                // If the image is loaded successfully
                return snapshot.data ??
                    Container(); // Return the widget or an empty container
              }
            },
          )
        ],
      ),
      bottomNavigationBar: updateButton(context),
    );
  }

  updateButton(BuildContext context) {
    return Padding(
      padding:
          EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: GestureDetector(
        onTap: () async {
          await updateProfile(
            _pickedImage,
          );
        },
        child: Container(
          margin: const EdgeInsets.all(fixPadding * 2.0),
          padding: const EdgeInsets.symmetric(
              vertical: fixPadding * 1.4, horizontal: fixPadding * 2.0),
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
          child: const Text(
            "Update",
            style: bold18White,
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }

  mobileNumberField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Mobile number",
          style: semibold15Black33,
        ),
        TextField(
          style: medium15Black33,
          keyboardType: TextInputType.phone,
          cursorColor: primaryColor,
          controller: mobileNumberController,
          decoration: const InputDecoration(
            enabledBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: greyD4Color),
            ),
            focusedBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: primaryColor),
            ),
            hintText: "Enter your mobile number",
            hintStyle: medium15Grey,
            contentPadding: EdgeInsets.symmetric(vertical: fixPadding),
            isDense: true,
          ),
        )
      ],
    );
  }

  licenseNumberField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "License number",
          style: semibold15Black33,
        ),
        TextField(
          style: medium15Black33,
          keyboardType: TextInputType.text,
          cursorColor: primaryColor,
          controller: licenceNumberController,
          decoration: const InputDecoration(
            enabledBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: greyD4Color),
            ),
            focusedBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: primaryColor),
            ),
            hintText: "Enter your license number",
            hintStyle: medium15Grey,
            contentPadding: EdgeInsets.symmetric(vertical: fixPadding),
            isDense: true,
          ),
        )
      ],
    );
  }

  emailField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Email address",
          style: semibold15Black33,
        ),
        TextField(
          style: medium15Black33,
          keyboardType: TextInputType.emailAddress,
          cursorColor: primaryColor,
          controller: emailController,
          decoration: const InputDecoration(
            enabledBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: greyD4Color),
            ),
            focusedBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: primaryColor),
            ),
            hintText: "Enter your email address",
            hintStyle: medium15Grey,
            contentPadding: EdgeInsets.symmetric(vertical: fixPadding),
            isDense: true,
          ),
        )
      ],
    );
  }

  firstNameField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "First name",
          style: semibold15Black33,
        ),
        TextField(
          style: medium15Black33,
          controller: firstNameController,
          keyboardType: TextInputType.name,
          cursorColor: primaryColor,
          decoration: const InputDecoration(
            enabledBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: greyD4Color),
            ),
            focusedBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: primaryColor),
            ),
            hintText: "Enter your first name",
            hintStyle: medium15Grey,
            contentPadding: EdgeInsets.symmetric(vertical: fixPadding),
            isDense: true,
          ),
        )
      ],
    );
  }

  lastNameField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Last name",
          style: semibold15Black33,
        ),
        TextField(
          style: medium15Black33,
          controller: lastNameController,
          keyboardType: TextInputType.name,
          cursorColor: primaryColor,
          decoration: const InputDecoration(
            enabledBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: greyD4Color),
            ),
            focusedBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: primaryColor),
            ),
            hintText: "Enter your last name",
            hintStyle: medium15Grey,
            contentPadding: EdgeInsets.symmetric(vertical: fixPadding),
            isDense: true,
          ),
        )
      ],
    );
  }

  profileImage(Size size) {
    return Center(
      child: Stack(
        children: [
          Container(
            height: size.height * 0.14,
            width: size.height * 0.14,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              image: DecorationImage(
                image: AssetImage(
                  "assets/profile/user-image.png",
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 0,
            right: 0,
            child: GestureDetector(
              onTap: () {
                changeProfileBottonsheet();
              },
              child: Container(
                height: size.height * 0.048,
                width: size.height * 0.048,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Color(0xFFF5F5F5),
                ),
                alignment: Alignment.center,
                child: const Icon(
                  CupertinoIcons.camera,
                  size: 20.0,
                  color: secondaryColor,
                ),
              ),
            ),
          )
        ],
      ),
    );
  }

  changeProfileBottonsheet() {
    return showModalBottomSheet(
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.0)),
      ),
      context: context,
      builder: (context) {
        return ListView(
          padding: const EdgeInsets.all(fixPadding * 2.0),
          physics: const BouncingScrollPhysics(),
          shrinkWrap: true,
          children: [
            const Text(
              "Change profile image",
              style: semibold18Black33,
            ),
            heightSpace,
            heightSpace,
            imageChangeOption(Icons.camera_alt, darkBlueColor, "Camera"),
            heightSpace,
            heightSpace,
            imageChangeOption(Icons.photo, darkGreenColor, "Gallery"),
            heightSpace,
            heightSpace,
            imageChangeOption(
                CupertinoIcons.trash_fill, darkRedColor, "Remove image"),
          ],
        );
      },
    );
  }

  Future<Widget> vehicleImage() async {
    final prefs = await SharedPreferences.getInstance();
    final String? userDataString = prefs.getString('userData');

    final Map<String, dynamic> userData =
        userDataString != null ? jsonDecode(userDataString) : {};

    final String? drivingLicense = userData['driving_license'];

    return InkWell(
      onTap: () {
        addImageBottonsheet();
      },
      child: Container(
        height: 140,
        decoration: BoxDecoration(
          color: const Color(0xFFE7E7E7),
          borderRadius: BorderRadius.circular(10.0),
        ),
        alignment: Alignment.center,
        child: drivingLicense != null
            ? Image.network(
                "$apiUrl/storage/$drivingLicense",
                width: double.infinity,
                height: 140,
                fit: BoxFit.cover,
              )
            : _pickedImage == null
                ? Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        CupertinoIcons.camera,
                        size: 35.0,
                        color: greyColor,
                      ),
                      heightBox(fixPadding *
                          0.8), // Assuming this is a SizedBox for spacing
                      const Text(
                        "Add vehicle image",
                        style: semibold14Grey,
                        // Assuming this is a defined TextStyle
                      )
                    ],
                  )
                : ClipRRect(
                    borderRadius: BorderRadius.circular(10.0),
                    child: Image.file(
                      _pickedImage!,
                      width: double.infinity,
                      height: 140,
                      fit: BoxFit.cover,
                    ),
                  ),
      ),
    );
  }

  // vehicleImage() {
  //   return InkWell(
  //     onTap: () {
  //       addImageBottonsheet();
  //     },
  //     child: Container(
  //       height: 140,
  //       decoration: BoxDecoration(
  //         color: const Color(0xFFE7E7E7),
  //         borderRadius: BorderRadius.circular(10.0),
  //       ),
  //       alignment: Alignment.center,
  //       child: _pickedImage == null
  //           ? Column(
  //               mainAxisAlignment: MainAxisAlignment.center,
  //               children: [
  //                 const Icon(
  //                   CupertinoIcons.camera,
  //                   size: 35.0,
  //                   color: greyColor,
  //                 ),
  //                 heightBox(fixPadding *
  //                     0.8), // Assuming this is a SizedBox for spacing
  //                 const Text(
  //                   "Add vehicle image",
  //                   style:
  //                       semibold14Grey, // Assuming this is a defined TextStyle
  //                 )
  //               ],
  //             )
  //           : ClipRRect(
  //               borderRadius: BorderRadius.circular(10.0),
  //               child: Image.file(
  //                 _pickedImage!,
  //                 width: double.infinity,
  //                 height: 140,
  //                 fit: BoxFit.cover,
  //               ),
  //             ),
  //     ),
  //   );
  // }

  addImageBottonsheet() {
    return showModalBottomSheet(
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.0)),
      ),
      context: context,
      builder: (context) {
        return ListView(
          padding: const EdgeInsets.all(fixPadding * 2.0),
          physics: const BouncingScrollPhysics(),
          shrinkWrap: true,
          children: [
            const Text(
              "Add image",
              style: semibold18Black33,
            ),
            heightSpace,
            heightSpace,
            imageChangeOption(Icons.camera_alt, darkBlueColor, "Camera"),
            heightSpace,
            heightSpace,
            imageChangeOption(Icons.photo, darkGreenColor, "Gallery"),
          ],
        );
      },
    );
  }

  imageChangeOption(IconData icon, Color color, String title) {
    return InkWell(
      onTap: () async {
        Navigator.pop(context);

        final pickedFile = await _picker.pickImage(
          source: title == 'Camera' ? ImageSource.camera : ImageSource.gallery,
        );

        if (pickedFile != null) {
          setState(() {
            _pickedImage = File(pickedFile.path);
          });
        }
      },
      child: Row(
        children: [
          Container(
            height: 40.0,
            width: 40.0,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.25),
                  blurRadius: 6.0,
                )
              ],
            ),
            alignment: Alignment.center,
            child: Icon(
              icon,
              size: 23.0,
              color: color,
            ),
          ),
          const SizedBox(width: 10.0),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(fontSize: 16.0),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> updateProfile(
    File? vehicleRegistrationCard,
    // File? vehicleImage,
  ) async {
    pleaseWaitDialog(context);
    final prefs = await SharedPreferences.getInstance();
    String? accessUserTokenid = prefs.getString('AccessUserToken');

    var uri = Uri.parse('$apiUrl/api/user/profile');
    var request = http.MultipartRequest('POST', uri);

    request.headers['Authorization'] = 'Bearer $accessUserTokenid';
    request.headers['Content-Type'] = 'application/json';

    request.fields['first_name'] = firstNameController.text;
    request.fields['last_name'] = lastNameController.text;

    // Add files
    if (vehicleRegistrationCard != null) {
      request.files.add(await http.MultipartFile.fromPath(
        'driving_license',
        vehicleRegistrationCard.path,
        contentType: MediaType('image', 'jpeg'),
      ));
    }

    // if (vehicleImage != null) {
    //   request.files.add(await http.MultipartFile.fromPath(
    //     'vehicle_image',
    //     vehicleImage.path,
    //     contentType: MediaType('image', 'jpg'),
    //   ));
    // }

    try {
      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);

      final responseData = jsonDecode(response.body);

      print("Response Status Code: ${response.statusCode}");
      print("Response Body: ${response.body}");

      String message = displayResponse(responseData);

      if (response.statusCode == 200) {
        // ignore: use_build_context_synchronously
        Navigator.pop(context);

        final user = responseData['user'];
        final prefs = await SharedPreferences.getInstance();
        bool saved = await prefs.setString('userData', jsonEncode(user));

        // ignore: use_build_context_synchronously
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return NotificationDialog(
              message: message,
              icon: Icons.check_circle,
              iconColor: Colors.green,
            );
          },
        ).then((_) {
          // This code will be executed after the dialog is dismissed
          // Navigate to the new screen here
          Navigator.pushNamed(context, '/profile');
        });
      } else {
        // ignore: use_build_context_synchronously
        Navigator.pop(context);
        // ignore: use_build_context_synchronously
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
      print('Error updating profile: $error');
    }
  }

  /* Future<void> updateProfile(_pickedImage)ehicleRegistrationCard) async {
    final prefs = await SharedPreferences.getInstance();
    String? accessUserTokenid = prefs.getString('AccessUserToken');

    if (accessUserTokenid == null || accessUserTokenid.isEmpty) {
      print('Access token is missing or empty.');
      return;
    }
    print('first name-------------------${firstNameController.text}');
    print('last name-------------------${lastNameController.text}');
    print('first name-------------------${mobileNumberController.text}');
    print('first name-------------------${emailController.text}');
    print('first name-------------------${licenceNumberController.text}');
    final updatedUser = {
      'id': accessUserTokenid,
      'first_name': firstNameController.text,
      'last_name': lastNameController.text,
      'phone_number': mobileNumberController.text,
      'email': emailController.text,
      'driving_license': licenceNumberController.text,
      // 'profile_picture': profilePictureController.text,
    };
    var data = jsonEncode(updatedUser);

    print('accessUserTokenid============================$accessUserTokenid');
    print('body json ---------------------------$data');

    const api = '$apiUrl/api/user/profile';

    try {
      final response = await http.patch(
        Uri.parse(api),
        headers: {
          'Authorization': 'Bearer $accessUserTokenid',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(updatedUser),
      );

      if (response.statusCode == 200) {
        // Successfully updated profile
        print('Profile updated successfully');
        Navigator.pop(context);
      } else {
        // Handle error cases
        print(
            'Failed to update profile. Status code: ----------------------------------${response.statusCode}');
        print(
            'Failed to update profile. Body code: ----------------------------------${response.body}');
      }
    } catch (error) {
      // Handle network or other errors
      print('Error updating profile: $error');
    }
  } */
}

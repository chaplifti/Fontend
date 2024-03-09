import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:rc_fl_gopoolar/theme/theme.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'dart:io';

import '../../constants/key.dart';
import '../../utilis/dialog.dart';
import '../../utilis/response.dart';
import '../notification.dart';

class AddNewVehicleScreen extends StatefulWidget {
  const AddNewVehicleScreen({super.key});

  @override
  State<AddNewVehicleScreen> createState() => _AddNewVehicleScreenState();
}

class _AddNewVehicleScreenState extends State<AddNewVehicleScreen> {
  final TextEditingController _vehicleNameController = TextEditingController();
  final TextEditingController _vehicleTypeController = TextEditingController();
  final TextEditingController _vehicleRegNumberController =
      TextEditingController();
  final TextEditingController _vehicleColorController = TextEditingController();
  final TextEditingController _vehicleFacilitiesController =
      TextEditingController();
  final ImagePicker _picker = ImagePicker();
  File? _pickedImage;

  @override
  void dispose() {
    // Dispose controllers when the widget is disposed
    _vehicleNameController.dispose();
    _vehicleTypeController.dispose();
    _vehicleRegNumberController.dispose();
    _vehicleColorController.dispose();
    _vehicleFacilitiesController.dispose();
    super.dispose();
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
          "Add vehicle",
          style: semibold18White,
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(fixPadding * 2.0),
        physics: const BouncingScrollPhysics(),
        children: [
          vehicleImage(),
          heightSpace,
          heightSpace,
          heightSpace,
          vehicleNameField(),
          heightSpace,
          heightSpace,
          vehicleTypeField(),
          heightSpace,
          heightSpace,
          vehiclePlateNumberField(),
          heightSpace,
          heightSpace,
          vehicleColourField(),
          heightSpace,
          heightSpace,
          facilitiesField(size)
        ],
      ),
      bottomNavigationBar: addButton(context),
    );
  }

  addButton(BuildContext context) {
    return Padding(
      padding:
          EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: GestureDetector(
        onTap: () {
          // Navigator.pop(context);
          addVehicle(
              vehicleName: _vehicleNameController.text,
              vehicleType: _vehicleTypeController.text,
              color: _vehicleColorController.text,
              plateNumber: _vehicleRegNumberController.text,
              facilities: _vehicleFacilitiesController.text);
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
              )
            ],
          ),
          child: const Text(
            "Add",
            style: bold18White,
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }

  facilitiesField(Size size) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        title("Facilities(i.e. AC, music)"),
        heightSpace,
        Container(
          height: size.height * 0.13,
          decoration: BoxDecoration(
            color: whiteColor,
            borderRadius: BorderRadius.circular(10.0),
            boxShadow: [
              BoxShadow(
                color: blackColor.withOpacity(0.15),
                blurRadius: 6.0,
              )
            ],
          ),
          child: TextField(
            controller: _vehicleFacilitiesController,
            expands: true,
            maxLines: null,
            minLines: null,
            cursorColor: primaryColor,
            style: semibold15Black33,
            decoration: const InputDecoration(
              hintText: "Enter facilities",
              hintStyle: medium15Grey,
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(
                  horizontal: fixPadding, vertical: fixPadding * 1.4),
              isDense: true,
            ),
          ),
        )
      ],
    );
  }

  vehicleColourField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        title("Vehicle colour"),
        heightSpace,
        Container(
          decoration: BoxDecoration(
            color: whiteColor,
            borderRadius: BorderRadius.circular(10.0),
            boxShadow: [
              BoxShadow(
                color: blackColor.withOpacity(0.15),
                blurRadius: 6.0,
              )
            ],
          ),
          child: TextField(
            controller: _vehicleColorController,
            cursorColor: primaryColor,
            style: semibold15Black33,
            keyboardType: TextInputType.name,
            decoration: const InputDecoration(
              hintText: "Enter vehicle colour",
              hintStyle: medium15Grey,
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(
                  horizontal: fixPadding, vertical: fixPadding * 1.4),
              isDense: true,
            ),
          ),
        )
      ],
    );
  }

  vehiclePlateNumberField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        title("Vehicle plate number"),
        heightSpace,
        Container(
          decoration: BoxDecoration(
            color: whiteColor,
            borderRadius: BorderRadius.circular(10.0),
            boxShadow: [
              BoxShadow(
                color: blackColor.withOpacity(0.15),
                blurRadius: 6.0,
              )
            ],
          ),
          child: TextField(
            controller: _vehicleRegNumberController,
            cursorColor: primaryColor,
            style: semibold15Black33,
            keyboardType: TextInputType.visiblePassword,
            decoration: const InputDecoration(
              hintText: "Enter vehicle reg.number",
              hintStyle: medium15Grey,
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(
                  horizontal: fixPadding, vertical: fixPadding * 1.4),
              isDense: true,
            ),
          ),
        )
      ],
    );
  }

  vehicleTypeField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        title("Vehicle type"),
        heightSpace,
        Container(
          decoration: BoxDecoration(
            color: whiteColor,
            borderRadius: BorderRadius.circular(10.0),
            boxShadow: [
              BoxShadow(
                color: blackColor.withOpacity(0.15),
                blurRadius: 6.0,
              )
            ],
          ),
          child: TextField(
            controller: _vehicleTypeController,
            cursorColor: primaryColor,
            style: semibold15Black33,
            decoration: const InputDecoration(
              hintText: "Enter vehicle type",
              hintStyle: medium15Grey,
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(
                  horizontal: fixPadding, vertical: fixPadding * 1.4),
              isDense: true,
            ),
          ),
        )
      ],
    );
  }

  vehicleNameField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        title("Vehicle name"),
        heightSpace,
        Container(
          decoration: BoxDecoration(
            color: whiteColor,
            borderRadius: BorderRadius.circular(10.0),
            boxShadow: [
              BoxShadow(
                color: blackColor.withOpacity(0.15),
                blurRadius: 6.0,
              )
            ],
          ),
          child: TextField(
            controller: _vehicleNameController,
            cursorColor: primaryColor,
            keyboardType: TextInputType.name,
            style: semibold15Black33,
            decoration: const InputDecoration(
              hintText: "Enter account holder name",
              hintStyle: medium15Grey,
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(
                  horizontal: fixPadding, vertical: fixPadding * 1.4),
              isDense: true,
            ),
          ),
        )
      ],
    );
  }

  title(String title) {
    return Text(
      title,
      style: semibold15Black33,
    );
  }

  vehicleImage() {
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
        child: _pickedImage == null
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
                    style:
                        semibold14Grey, // Assuming this is a defined TextStyle
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
          SizedBox(width: 10.0),
          Expanded(
            child: Text(
              title,
              style: TextStyle(fontSize: 16.0),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> addVehicle({
    required String vehicleName,
    required String vehicleType,
    required String color,
    required String plateNumber,
    File? vehicleRegistrationCard,
    String? facilities,
    File? vehicleImage,
  }) async {
    pleaseWaitDialog(context);
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? savedAccessUserToken = prefs.getString('AccessUserToken');
    var uri = Uri.parse('$apiUrl/api/user/vehicles');
    var request = http.MultipartRequest('POST', uri);

    request.headers.addAll({
      'Authorization':
          'Bearer $savedAccessUserToken', // Include the Bearer token here
      'Content-Type': 'application/json',
    });

    // Add text fields
    request.fields['vehicle_name'] = vehicleName;
    request.fields['vehicle_type'] = vehicleType;
    request.fields['color'] = color;
    request.fields['plate_number'] = plateNumber;
    if (facilities != null) request.fields['facilities'] = facilities;

    // Add files

    if (vehicleRegistrationCard != null) {
      request.files.add(await http.MultipartFile.fromPath(
        'vehicle_registration_card',
        vehicleRegistrationCard.path,
        contentType:
            MediaType('image', 'jpeg'), // Adjust based on your file type
      ));
    }

    if (_pickedImage != null) {
      print("_pickedImage   $_pickedImage");
      request.files.add(await http.MultipartFile.fromPath(
        'vehicle_image',
        _pickedImage!.path,
        contentType:
            MediaType('image', 'jpg'), // Adjust based on your file type
      ));
    }

    try {
      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);
      final responseData = jsonDecode(response.body);
      print(
          "response.body----------------------------------------------------------------------------------------------------");
      String message = displayResponse(responseData);
      // print(response.body);
      if (response.statusCode == 201) {
        Navigator.pop(context);

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
          Navigator.pushNamed(context, '/myVehicle');
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
    } catch (e) {
      print('Error adding vehicle: $e');
    }
  }
}

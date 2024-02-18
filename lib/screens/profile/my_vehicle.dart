import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:rc_fl_gopoolar/theme/theme.dart';
import 'package:http/http.dart' as http;
import '../../constants/key.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../utilis/dialog.dart';
import '../../utilis/response.dart';
import '../notification.dart';

class MyVehicleScreen extends StatefulWidget {
  const MyVehicleScreen({super.key});

  @override
  State<MyVehicleScreen> createState() => _MyVehicleScreenState();
}

class _MyVehicleScreenState extends State<MyVehicleScreen> {
  // final vehicleList = [
  //   {
  //     "image": "assets/myVehicle/image-1.png",
  //     "name": "Mercedes-Benz AMG A35",
  //     "seat": "2",
  //   },
  //   {
  //     "image": "assets/myVehicle/image-2.png",
  //     "name": "Toyota Matrix | KJ 5454 | Black colour",
  //     "seat": "4",
  //   }
  // ];
  List<Map<String, dynamic>> vehicleList = [];

  @override
  void initState() {
    super.initState();
    // Call the function to fetch the vehicle list when the state is loaded
    fetchVehicleList();
  }

  Future<void> fetchVehicleList() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? savedAccessUserToken = prefs.getString('AccessUserToken');

    final response = await http.get(
      Uri.parse('$apiUrl/api/user/vehicles'),
      headers: {
        'Authorization': 'Bearer $savedAccessUserToken',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final jsonResponse = jsonDecode(response.body);
      final vehicles = jsonResponse['vehicles'] as List<dynamic>;
      setState(() {
        vehicleList = List<Map<String, dynamic>>.from(vehicles);
      });
    } else {
      print('Failed to fetch vehicle list');
    }
  }

  Future<void> deleteVehicle(int vehicleId) async {
    pleaseWaitDialog(context);
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? savedAccessUserToken = prefs.getString('AccessUserToken');

    final Uri uri = Uri.parse(
        '$apiUrl/api/user/vehicles/$vehicleId'); // Adjusted for a DELETE request

    final response = await http.delete(
      uri,
      headers: {
        'Authorization':
            'Bearer $savedAccessUserToken', // Include the Bearer token here
        'Content-Type': 'application/json',
      },
    );
    final responseData = jsonDecode(response.body);
    String message = displayResponse(responseData);
    if (response.statusCode == 200) {
      print('Vehicle deleted successfully');
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
        Navigator.pushNamed(context, '/myVehicle');
      });
    } else {
      print('Failed to delete vehicle');
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
          "My vehicle",
          style: semibold18White,
        ),
      ),
      body: vehicleListContent(size),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: addButton(),
    );
  }

  addButton() {
    return InkWell(
      onTap: () {
        Navigator.pushNamed(context, '/addNewVehicle');
      },
      child: Container(
        height: 45.0,
        width: 45.0,
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          color: secondaryColor,
        ),
        alignment: Alignment.center,
        child: const Icon(
          Icons.add,
          size: 40.0,
          color: whiteColor,
        ),
      ),
    );
  }

  vehicleListContent(Size size) {
    return ListView.builder(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(
          horizontal: fixPadding * 2.0, vertical: fixPadding),
      itemCount: vehicleList.length,
      itemBuilder: (context, index) {
        return Container(
          height: size.height * 0.22,
          clipBehavior: Clip.hardEdge,
          width: double.maxFinite,
          margin: const EdgeInsets.symmetric(vertical: fixPadding),
          decoration: BoxDecoration(
            color: whiteColor,
            borderRadius: BorderRadius.circular(10.0),
            image: DecorationImage(
              image: NetworkImage(
                "$apiUrl/storage/${vehicleList[index]['vehicle_image']}",
              ),
              fit: BoxFit.cover,
            ),
          ),
          child: Container(
            width: double.maxFinite,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  whiteColor.withOpacity(0.0),
                  const Color(0xFF1C1C1C).withOpacity(0.5)
                ],
              ),
            ),
            alignment: Alignment.center,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.all(fixPadding * 0.8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      InkWell(
                        onTap: () {
                          deleteVehicle(vehicleList[index]['id']);
                        },
                        child: const Icon(
                          CupertinoIcons.trash,
                          color: redColor,
                          size: 23.0,
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(fixPadding * 1.4),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        vehicleList[index]['vehicle_name'].toString(),
                        style: semibold15White,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      height5Space,
                      Text(
                        "${vehicleList[index]['vehicle_type']}",
                        style: medium15White,
                        overflow: TextOverflow.ellipsis,
                      ),
                      height5Space,
                      Text(
                        "${vehicleList[index]['plate_number']}",
                        style: medium15White,
                        overflow: TextOverflow.ellipsis,
                      )
                    ],
                  ),
                )
              ],
            ),
          ),
        );
      },
    );
  }
}

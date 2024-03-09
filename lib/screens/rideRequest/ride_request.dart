import 'dart:ffi';

import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:rc_fl_gopoolar/theme/theme.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import '../../constants/key.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:geocoding/geocoding.dart';
import '../../utilis/dialog.dart';
import '../../utilis/response.dart';
import '../notification.dart';

class RideRequestScreen extends StatefulWidget {
  const RideRequestScreen({super.key});

  @override
  State<RideRequestScreen> createState() => _RideRequestScreenState();
}

class _RideRequestScreenState extends State<RideRequestScreen> {
  List<Map<String, dynamic>> ridesList = [];

  final requestList = [
    {
      "image": "assets/myRides/image-2.png",
      "name": "Leslie Alexander",
      "pickup": "Mumbai,2464 Royal Ln. Mesa",
      "destination": "Pune,2464 Royal Ln. Mesa",
      "price": "\$13.50",
      "seat": 1
    },
    {
      "image": "assets/myRides/image-4.png",
      "name": "Albert Flores",
      "pickup": "Mumbai,2464 Royal Ln. Mesa",
      "destination": "Pune,2464 Royal Ln. Mesa",
      "price": "\$15.50",
      "seat": 1
    },
    {
      "image": "assets/myRides/image.png",
      "name": "Annette Black",
      "pickup": "Mumbai,2464 Royal Ln. Mesa",
      "destination": "Pune,2464 Royal Ln. Mesa",
      "price": "\$10.50",
      "seat": 1
    },
  ];

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: primaryColor,
        automaticallyImplyLeading: false,
        centerTitle: true,
        titleSpacing: 0.0,
        // leading: IconButton(
        //   padding: const EdgeInsets.symmetric(horizontal: fixPadding * 2.0),
        //   onPressed: () {
        //     Navigator.pop(context);
        //   },
        //   icon: const Icon(
        //     Icons.arrow_back_ios,
        //     color: whiteColor,
        //   ),
        // ),
        title: const Text(
          "My Rides",
          style: semibold18White,
        ),
      ),
      body: rideListCotent(size),
    );
  }

  rideListCotent(size) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(
          vertical: fixPadding, horizontal: fixPadding * 2.0),
      physics: const BouncingScrollPhysics(),
      itemCount: ridesList.length,
      itemBuilder: (context, index) {
        final passengerList = ridesList[index];
        return GestureDetector(
          onTap: () {
            print(ridesList[index]);
            Navigator.pushNamed(context, '/startRide',
                arguments: passengerList);
          },
          child: Container(
            padding: const EdgeInsets.all(fixPadding),
            margin: const EdgeInsets.symmetric(vertical: fixPadding),
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
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          dateTimeWidget(size, Icons.calendar_month_outlined,
                              ridesList[index]['start_time'].toString()),
                          const Text(
                            " | ",
                            style: medium14Black33,
                          ),
                          dateTimeWidget(size, Icons.access_time,
                              ridesList[index]['status'].toString()),
                        ],
                      ),
                      height5Space,
                      rideAddress(greenColor,
                          ridesList[index]['pickupLocation'].toString()),
                      verticalDivider(),
                      rideAddress(redColor,
                          ridesList[index]['destinationLocation'].toString()),
                      height5Space,
                      SingleChildScrollView(
                        child: Row(
                          children: List.generate(
                            4,
                            (i) => 3 > i
                                ? Container(
                                    height: 25.0,
                                    width: 25.0,
                                    margin: const EdgeInsets.only(right: 5.0),
                                    decoration: const BoxDecoration(
                                      shape: BoxShape.circle,
                                      image: DecorationImage(
                                        image: AssetImage(
                                          " passengerList[i].toString()",
                                        ),
                                      ),
                                    ),
                                  )
                                : Container(
                                    height: 25.0,
                                    width: 25.0,
                                    margin: const EdgeInsets.only(right: 5.0),
                                    decoration: const BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: d9E3EAColor,
                                    ),
                                    alignment: Alignment.center,
                                    child: const Icon(
                                      CupertinoIcons.person_fill,
                                      color: whiteColor,
                                      size: 18.0,
                                    ),
                                  ),
                          ),
                        ),
                      )
                    ],
                  ),
                ),
                width5Space,
                requestButton(size, index),
              ],
            ),
          ),
        );
      },
    );
  }

  requestButton(size, int index) {
    return GestureDetector(
      onTap: () {
        requestBottomSheet(size, index);
      },
      child: Container(
        padding: const EdgeInsets.all(fixPadding * 0.9),
        constraints: BoxConstraints(maxWidth: size.width * 0.3),
        decoration: BoxDecoration(
          color: whiteColor,
          borderRadius: BorderRadius.circular(5.0),
          border: Border.all(color: primaryColor),
          boxShadow: [
            BoxShadow(
              color: secondaryColor.withOpacity(0.1),
              blurRadius: 12.0,
              offset: const Offset(0, 2),
            )
          ],
        ),
        child: Text(
          "Request (${ridesList[index]['ride_requests'].length})",
          style: semibold15Primary,
          overflow: TextOverflow.ellipsis,
        ),
      ),
    );
  }

  requestBottomSheet(size, int ride_index) {
    // int requestIndex = ridesList[ride_index]['ride_requests'].length;
    List<dynamic>? rideRequests =
        ridesList[ride_index]['ride_requests'] as List<dynamic>?;

    return showModalBottomSheet(
      backgroundColor: whiteColor,
      isScrollControlled: true,
      constraints: BoxConstraints(
        maxHeight: size.height - 60,
      ),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(40.0),
        ),
      ),
      context: context,
      builder: (context) {
        return ListView.builder(
          shrinkWrap: true,
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.all(fixPadding * 2.0),
          itemCount: rideRequests?.length ?? 0,
          itemBuilder: (context, index) {
            Map<String, dynamic>? user =
                rideRequests![index]['user'] as Map<String, dynamic>?;
            String profilePicture = user?['profile_picture'] ?? '';

            String firstName = user?['first_name'] ?? '';
            String lastName = user?['last_name'] ?? '';
            String fullName = '$firstName $lastName';
            return Container(
              margin: const EdgeInsets.symmetric(vertical: fixPadding),
              padding: const EdgeInsets.all(fixPadding),
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
              child: Column(
                children: [
                  Row(
                    children: [
                      profilePicture.isNotEmpty
                          ? Container(
                              width: 80.0,
                              height: 80.0,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(5.0),
                                image: DecorationImage(
                                  image: NetworkImage(
                                      "$apiUrl/storage/$profilePicture"),
                                  fit: BoxFit.cover,
                                ),
                              ),
                            )
                          : CircleAvatar(
                              radius: size.width * 0.1,
                              backgroundColor: primaryColor,
                              child: Text(
                                firstName[0].toUpperCase(),
                                style: TextStyle(
                                  fontSize: size.width * 0.1,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                      widthSpace,
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              fullName,
                              style: semibold15Black33,
                              overflow: TextOverflow.ellipsis,
                            ),
                            height5Space,
                            requestAddress(
                                greenColor,
                                rideRequests[ride_index]['pickup_location']
                                    ['lat'],
                                rideRequests[ride_index]['pickup_location']
                                    ['lng']),
                            verticalDivider(),
                            requestAddress(
                                redColor,
                                rideRequests[ride_index]['destination']['lat'],
                                rideRequests[ride_index]['destination']['lng']),
                            height5Space,
                            Text(
                              "Tsh ${ridesList[ride_index]['price']}",
                              style: semibold15Primary,
                            )
                          ],
                        ),
                      )
                    ],
                  ),
                  heightSpace,
                  Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            // Navigator.pop(context);

                            cancelRideRequest(ridesList[ride_index]['id'],
                                rideRequests[ride_index]['id']);
                          },
                          child: Container(
                            padding: const EdgeInsets.all(fixPadding),
                            decoration: BoxDecoration(
                              color: whiteColor,
                              borderRadius: BorderRadius.circular(5.0),
                              boxShadow: [
                                BoxShadow(
                                  color: blackColor.withOpacity(0.15),
                                  blurRadius: 6.0,
                                )
                              ],
                            ),
                            alignment: Alignment.center,
                            child: const Text(
                              "Cancel",
                              style: semibold16Primary,
                            ),
                          ),
                        ),
                      ),
                      widthSpace,
                      widthSpace,
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            // Navigator.popAndPushNamed(context, '/startRide');
                            sendRideRequest(ridesList[ride_index]['id'],
                                rideRequests[ride_index]['id']);
                          },
                          child: Container(
                            padding: const EdgeInsets.all(fixPadding),
                            decoration: BoxDecoration(
                              color: secondaryColor,
                              borderRadius: BorderRadius.circular(5.0),
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
                              "Accept",
                              style: semibold16White,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ),
                      )
                    ],
                  )
                ],
              ),
            );
          },
        );
      },
    );
  }

  verticalDivider() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: fixPadding * 0.6),
      child: DottedBorder(
        padding: EdgeInsets.zero,
        dashPattern: const [1.9, 3.9],
        color: greyColor,
        strokeWidth: 1.2,
        child: const SizedBox(height: 6.0),
      ),
    );
  }

  rideAddress(Color color, String address) {
    return Row(
      children: [
        Container(
          height: 12.0,
          width: 12.0,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: color),
          ),
          alignment: Alignment.center,
          child: Icon(
            Icons.location_pin,
            color: color,
            size: 9.0,
          ),
        ),
        widthSpace,
        Expanded(
          child: Text(
            address as String,
            style: medium12Grey,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget requestAddress(Color color, double lat, double lng) {
    print(lat);
    return Row(
      children: [
        Container(
          height: 12.0,
          width: 12.0,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: color),
          ),
          alignment: Alignment.center,
          child: Icon(
            Icons.location_pin,
            color: color,
            size: 9.0,
          ),
        ),
        widthSpace,
        Expanded(
          // Use FutureBuilder to handle the asynchronous nature of _getStopPointsAddresses
          child: FutureBuilder<String>(
            future: _getStopPointsAddresses(lat, lng),
            builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
              if (snapshot.hasData) {
                // If we have data, display it
                return Text(
                  snapshot.data!,
                  style: medium12Grey,
                  overflow: TextOverflow.ellipsis,
                );
              } else if (snapshot.hasError) {
                // Handle any errors
                return Text(
                  'Error: ${snapshot.error}',
                  style: medium12Grey,
                  overflow: TextOverflow.ellipsis,
                );
              }
              // By default, show a loading spinner or placeholder
              return CircularProgressIndicator();
            },
          ),
        ),
      ],
    );
  }

  Future<String> _getStopPointsAddresses(double lat, double lng) async {
    List<Placemark> placemarks = await placemarkFromCoordinates(lng, lat);
    Placemark placeMark = placemarks.first;
    String address =
        "${placeMark.street}, ${placeMark.administrativeArea} ${placeMark.postalCode}, ${placeMark.country}";
    return address;
  }

  dateTimeWidget(size, IconData icon, String title) {
    return Row(
      children: [
        Icon(
          icon,
          color: black33Color,
          size: 14.5,
        ),
        width5Space,
        ConstrainedBox(
          constraints: BoxConstraints(maxWidth: size.width * 0.18),
          child: Text(
            title,
            style: medium14Black33,
            overflow: TextOverflow.ellipsis,
          ),
        )
      ],
    );
  }

  @override
  void initState() {
    super.initState();
    fetchMyRide();
  }

  Future<void> fetchMyRide() async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final String? savedAccessUserToken = prefs.getString('AccessUserToken');

      var url = Uri.parse('$apiUrl/api/user/rides');
      var response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer $savedAccessUserToken',
          'Content-Type': 'application/json',
        },
      );
      print(response.body);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print(data);
        setState(() {
          ridesList = List<Map<String, dynamic>>.from(data['rides'].map((ride) {
            var firstName = ride['user']['first_name'];
            var lastName = ride['user']['last_name'];
            return {
              "id": ride['id'],
              "pickupLocation": ride['starting_point_address'],
              "destinationLocation": ride['destination_address'],
              "start_time": ride['start_time'],
              "price": ride['price'],
              "available_seats": ride['available_seats'],
              "occupied_seats": ride['occupied_seats'],
              "status": ride['status'],
              "user": ride['user'],
              "vehicle": ride['vehicle'],
              "starting_point": ride["starting_point"],
              "stop_points": ride["stop_points"],
              "destination": ride["destination"],
              "name": "$firstName $lastName",
              "rate": 4.8,
              "bookedSeat": 0,
              "dateTime": ride['start_time'],
              "image": ride['profile_picture'],
              "seat": ride['available_seats'],
              "ride_requests": ride['ride_requests']
            };
          }).toList());
        });
      } else {
        throw Exception('Failed to load ride');
      }
    } catch (e) {
      print(e.toString());
    }
  }

  Future<void> sendRideRequest(int rideId, int requestId) async {
    pleaseWaitDialog(context);
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final String? savedAccessUserToken = prefs.getString('AccessUserToken');

      var url = Uri.parse('$apiUrl/api/user/ride-requests/$rideId/$requestId');
      var response = await http.post(
        url,
        headers: {
          'Authorization': 'Bearer $savedAccessUserToken',
          'Content-Type': 'application/json',
        },
      );
      final responseData = jsonDecode(response.body);
      String message = displayResponse(responseData);
      if (response.statusCode == 200) {
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
      print(e.toString());
    }
  }

  Future<void> cancelRideRequest(int rideId, int requestId) async {
    pleaseWaitDialog(context);
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final String? savedAccessUserToken = prefs.getString('AccessUserToken');

      var url = Uri.parse('$apiUrl/api/user/ride-requests/$rideId/$requestId');
      var response = await http.put(
        url,
        headers: {
          'Authorization': 'Bearer $savedAccessUserToken',
          'Content-Type': 'application/json',
        },
      );
      final responseData = jsonDecode(response.body);
      String message = displayResponse(responseData);
      if (response.statusCode == 200) {
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
      print(e.toString());
    }
  }
}

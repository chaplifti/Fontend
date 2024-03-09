import 'dart:convert';
import 'dart:io';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:rc_fl_gopoolar/theme/theme.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import '../../constants/key.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:geocoding/geocoding.dart';

import '../../utilis/dialog.dart';
import '../notification.dart';

class MyRequestScreen extends StatefulWidget {
  const MyRequestScreen({super.key});

  @override
  State<MyRequestScreen> createState() => _MyRequestScreenState();
}

class _MyRequestScreenState extends State<MyRequestScreen> {
  List<Map<String, dynamic>> requestList = [];

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: f8Color,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: primaryColor,
        automaticallyImplyLeading: false,
        centerTitle: true,
        titleSpacing: 20.0,
        title: const Text(
          "My Requests",
          style: semibold18White,
        ),
        // actions: [
        //   requestsIconButton(),
        // ],
      ),
      body: requestList.isEmpty ? emptyListContent() : requestListContent(size),
    );
  }

  emptyListContent() {
    return Center(
      child: ListView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(fixPadding * 0.01),
        shrinkWrap: true,
        children: [
          Image.asset(
            "assets/myRides/no-car.png",
            height: 50.0,
          ),
          heightSpace,
          const Text(
            "Empty Request list",
            style: semibold16Black33,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  requestListContent(Size size) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(
          horizontal: fixPadding * 0.8, vertical: fixPadding),
      physics: const BouncingScrollPhysics(),
      itemCount: requestList.length,
      itemBuilder: (context, index) {
        final ride = requestList[index];

        return GestureDetector(
          onTap: () async {
            if (requestList[index]['status'] != 'pending') {
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return const NotificationDialog(
                    message: "Your request is not approved yet",
                    icon: Icons.error,
                    iconColor: Colors.red,
                  );
                },
              );
            } else {
              // var rideDetails =
              //     await fetchRideDetails(requestList[index]['id']);
              // if (rideDetails != null) {
              //   await Navigator.pushNamed(context, '/startRideRequester',
              //       arguments: {"rideDetails": rideDetails});
              // }
              // if (results == "Cancel") {
              //   setState(() {
              //     requestList.removeAt(index);
              //   });
              // }
            }
          },
          child: Container(
            width: double.maxFinite,
            padding: const EdgeInsets.all(fixPadding),
            margin: const EdgeInsets.symmetric(vertical: fixPadding),
            decoration: BoxDecoration(
              color: whiteColor,
              borderRadius: BorderRadius.circular(10.0),
              boxShadow: [
                BoxShadow(
                  color: blackColor.withOpacity(0.08),
                  blurRadius: 6.0,
                )
              ],
            ),
            child: Row(
              children: [
                // ride['user']['profile_picture'] != null
                //     ? Container(
                //         height: size.width * 0.2,
                //         width: size.width * 0.2,
                //         decoration: BoxDecoration(
                //           borderRadius: BorderRadius.circular(5.0),
                //           image: DecorationImage(
                //             image: NetworkImage(
                //                 "$apiUrl/storage/$ride['user']['profile_picture']"),
                //             fit: BoxFit.cover,
                //           ),
                //         ),
                //       )
                //     : CircleAvatar(
                //         radius: size.width * 0.1,
                //         backgroundColor: primaryColor,
                //         child: Text(
                //           ride['user']['first_name'][0].toUpperCase(),
                //           style: TextStyle(
                //             fontSize: size.width * 0.1,
                //             color: Colors.white,
                //           ),
                //         ),
                //       ),
                widthSpace,
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Request",
                        style: semibold15Black33,
                        overflow: TextOverflow.ellipsis,
                      ),
                      height5Space,
                      Row(
                        children: [
                          dateTimeWidget(size, Icons.calendar_month_outlined,
                              "23-12-2024 12:09 PM"),
                          const Text(
                            " | ",
                            style: medium12Black33,
                          ),
                          dateTimeWidget(
                              size, Icons.access_time, ride['status']),
                        ],
                      ),
                      height5Space,
                      address(greenColor, ride['pickupLocation']),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: fixPadding * 0.6),
                        child: DottedBorder(
                          padding: EdgeInsets.zero,
                          dashPattern: const [1.9, 3.9],
                          color: greyColor,
                          strokeWidth: 1.2,
                          child: const SizedBox(height: 6.0),
                        ),
                      ),
                      address(redColor, ride['destinationLocation'].toString()),
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

  dateTimeWidget(Size size, IconData icon, String title) {
    return Row(
      children: [
        Icon(
          icon,
          color: black33Color,
          size: 14.0,
        ),
        width5Space,
        ConstrainedBox(
          constraints: BoxConstraints(maxWidth: size.width * 0.2),
          child: Text(
            title,
            style: medium12Black33,
            overflow: TextOverflow.ellipsis,
          ),
        )
      ],
    );
  }

  address(Color color, String address) {
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
            address,
            style: medium12Grey,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  requestsIconButton() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.only(right: fixPadding * 2.0),
        child: GestureDetector(
          onTap: () {
            Navigator.pushNamed(context, '/rideRequest');
          },
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                height: 25.0,
                width: 25.0,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: whiteColor,
                ),
                alignment: Alignment.center,
                child: const Icon(
                  CupertinoIcons.person_fill,
                  color: primaryColor,
                  size: 20.0,
                ),
              ),
              Positioned(
                top: -4,
                right: 0,
                child: Container(
                  height: 10.0,
                  width: 10.0,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: redColor,
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    fetchMyRequest();
  }

  Future<void> fetchMyRequest() async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final String? savedAccessUserToken = prefs.getString('AccessUserToken');

      var url = Uri.parse('$apiUrl/api/user/ride-requests');
      var response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer $savedAccessUserToken',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        print(data['ride_requests']);
        var requests = data['ride_requests'] as List<dynamic>;

        // Use Future.wait to resolve all futures generated by the map operation.
        var futureRequests = await Future.wait(requests.map((request) async {
          List<Placemark> pickupPlacemarks = await placemarkFromCoordinates(
            request['pickup_location']['lng'],
            request['pickup_location']['lat'],
          );
          var pickupLocation = pickupPlacemarks.first;
          String formattedPickupLocation =
              "${pickupLocation.street}, ${pickupLocation.administrativeArea} ${pickupLocation.postalCode}, ${pickupLocation.country}";

          List<Placemark> destinationPlacemarks =
              await placemarkFromCoordinates(
            request['destination']['lng'],
            request['destination']['lat'],
          );
          var destinationLocation = destinationPlacemarks.first;
          String formattedDestinationLocation =
              "${destinationLocation.street}, ${destinationLocation.administrativeArea} ${destinationLocation.postalCode}, ${destinationLocation.country}";

          return {
            "id": request['id'],
            "ride_id": request['ride_id'],
            "pickupLocation": formattedPickupLocation,
            "destinationLocation": formattedDestinationLocation,
            "requested_seats": request['requested_seats'],
            "status": request['status'],
          };
        }));

        setState(() {
          requestList = List<Map<String, dynamic>>.from(futureRequests);
        });
      } else {
        throw Exception('Failed to load requests');
      }
    } catch (e) {
      print(e.toString());
    }
  }

  Future<void> requestVadidation() async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final String? savedAccessUserToken = prefs.getString('AccessUserToken');

      var url = Uri.parse('$apiUrl/api/user/ride-requests');
      var response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer $savedAccessUserToken',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        print(data['ride_requests']);
        var requests = data['ride_requests'] as List<dynamic>;

        // Use Future.wait to resolve all futures generated by the map operation.
        var futureRequests = await Future.wait(requests.map((request) async {
          List<Placemark> pickupPlacemarks = await placemarkFromCoordinates(
            request['pickup_location']['lng'],
            request['pickup_location']['lat'],
          );
          var pickupLocation = pickupPlacemarks.first;
          String formattedPickupLocation =
              "${pickupLocation.street}, ${pickupLocation.administrativeArea} ${pickupLocation.postalCode}, ${pickupLocation.country}";

          List<Placemark> destinationPlacemarks =
              await placemarkFromCoordinates(
            request['destination']['lng'],
            request['destination']['lat'],
          );
          var destinationLocation = destinationPlacemarks.first;
          String formattedDestinationLocation =
              "${destinationLocation.street}, ${destinationLocation.administrativeArea} ${destinationLocation.postalCode}, ${destinationLocation.country}";

          return {
            "id": request['id'],
            "ride_id": request['ride_id'],
            "pickupLocation": formattedPickupLocation,
            "destinationLocation": formattedDestinationLocation,
            "requested_seats": request['requested_seats'],
            "status": request['status'],
          };
        }));

        setState(() {
          requestList = List<Map<String, dynamic>>.from(futureRequests);
        });
      } else {
        throw Exception('Failed to load requests');
      }
    } catch (e) {
      print(e.toString());
    }
  }

  // Future<Map<String, dynamic>> fetchRideDetails(String rideId) async {
  //   try {
  //     final SharedPreferences prefs = await SharedPreferences.getInstance();
  //     final String? savedAccessUserToken = prefs.getString('AccessUserToken');

  //     var url = Uri.parse('$apiUrl/api/user/rides/$rideId');
  //     var response = await http.get(
  //       url,
  //       headers: {
  //         'Authorization': 'Bearer $savedAccessUserToken',
  //         'Content-Type': 'application/json',
  //       },
  //     );

  //     if (response.statusCode == 200) {
  //       return jsonDecode(response.body);
  //     } else {
  //       throw Exception('Failed to load ride details');
  //     }
  //   } catch (e) {
  //     print(e.toString());
  //     return false;
  //   }
  // }
}

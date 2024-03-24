import 'dart:convert';

import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:rc_fl_gopoolar/theme/theme.dart';
import 'package:shared_preferences/shared_preferences.dart';

// import 'package:http_parser/http_parser.dart';
import '../../constants/key.dart';

class MyRidesScreen extends StatefulWidget {
  const MyRidesScreen({super.key});

  @override
  State<MyRidesScreen> createState() => _MyRidesScreenState();
}

class _MyRidesScreenState extends State<MyRidesScreen> {
  List<Map<String, dynamic>> ridesList = [];

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
          "My Rides",
          style: semibold18White,
        ),
        actions: [
          requestsIconButton(),
        ],
      ),
      body: ridesList.isEmpty ? emptyListContent() : ridesListContent(size),
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
            "Empty ride list",
            style: semibold16Black33,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  ridesListContent(Size size) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(
          horizontal: fixPadding * 0.8, vertical: fixPadding),
      physics: const BouncingScrollPhysics(),
      itemCount: ridesList.length,
      itemBuilder: (context, index) {
        final ride = ridesList[index];
        // final ride = ridesList[index]['ride_requests'];

        print("ridesList[index]-------------------------------$ride");

        return GestureDetector(
          onTap: () async {
            final results = await Navigator.pushNamed(context, '/rideDetail',
                arguments: {"id": ridesList[index]});
            if (results == "Cancel") {
              setState(() {
                ridesList.removeAt(index);
              });
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
                ride['user']['profile_picture'] != null
                    ? Container(
                        height: size.width * 0.2,
                        width: size.width * 0.2,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(5.0),
                          image: DecorationImage(
                            image: NetworkImage(
                                "$apiUrl/storage/$ride['user']['profile_picture']"),
                            fit: BoxFit.cover,
                          ),
                        ),
                      )
                    : CircleAvatar(
                        radius: size.width * 0.1,
                        backgroundColor: primaryColor,
                        child: Text(
                          ride['user']['first_name'][0].toUpperCase(),
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
                        "${ride['user']['first_name']} ${ride['user']['last_name']}",
                        style: semibold15Black33,
                        overflow: TextOverflow.ellipsis,
                      ),
                      height5Space,
                      Row(
                        children: [
                          dateTimeWidget(size, Icons.calendar_month_outlined,
                              ride['start_time']),
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
      // print(response.body);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
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
}

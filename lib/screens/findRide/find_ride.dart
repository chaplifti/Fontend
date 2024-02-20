import 'dart:convert';

import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:rc_fl_gopoolar/theme/theme.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

import '../../constants/key.dart';
import '../../utilis/dialog.dart';
import '../notification.dart';

class FindRideScreen extends StatefulWidget {
  const FindRideScreen({super.key});

  @override
  State<FindRideScreen> createState() => _FindRideScreenState();
}

class _FindRideScreenState extends State<FindRideScreen> {
  var rideList = [];

  @override
  void initState() {
    super.initState();
    _findRideNearBy();
  }

  Future<String> getAddressFromPlacemark(Placemark placemark) async {
    String street = placemark.street ?? '';
    String administrativeArea = placemark.administrativeArea ?? '';
    String postalCode = placemark.postalCode ?? '';
    String country = placemark.country ?? '';

    return "$street, $administrativeArea $postalCode, $country";
  }

  Future<void> _findRideNearBy() async {
    final prefs = await SharedPreferences.getInstance();
    List<String>? pickupLocationList = prefs.getStringList('sourceLocation');
    List<String>? destinationLocationList =
        prefs.getStringList('destinationLocation');
    final String? dateAndTime = prefs.getString('dateAndTime');

    final String? savedAccessUserToken = prefs.getString('AccessUserToken');

    try {
      http.Response response;
      response = await http.post(
        Uri.parse('$apiUrl/api/user/ride-requests-find'),
        headers: {
          'Authorization': 'Bearer $savedAccessUserToken',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'pickup_location': {
            "lat": destinationLocationList?[1],
            "lng": destinationLocationList?[2]
          },
          'destination': {
            "lat": destinationLocationList?[1],
            "lng": destinationLocationList?[2]
          },
          'start_time': dateAndTime,
        }),
      );

      final responseData = jsonDecode(response.body);

      List<dynamic> rides = responseData['rides'];
      List<Map<String, dynamic>> formattedRides = [];

      for (var ride in rides) {
        var firstName = ride['user']['first_name'];
        var lastName = ride['user']['last_name'];
        formattedRides.add({
          "pickupLocation": ride['starting_point_address'],
          "destinationLocation": ride['destination_address'],
          "price": ride['price'],
          "image": ride['profile_picture'],
          "name": "$firstName $lastName",
          "dateTime": "25 June, 10:30am",
          "rate": 4.8,
          "bookedSeat": 2,
          "vehicle": ride["vehicle"],
          "user": ride["user"],
          "starting_point": ride["starting_point"],
          "destination": ride["destination"],
        });
      }

      setState(() {
        rideList = formattedRides;
      });

      print(
          "formattedRides------------------------------------------------------------$formattedRides");
    } catch (error) {
      // ignore: use_build_context_synchronously
      Navigator.pop(context);
      // ignore: use_build_context_synchronously
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return const NotificationDialog(
            message: "Something went wrong! Please try again later.",
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
          "Rider on 25 June, 10:30 am",
          style: semibold18White,
        ),
      ),
      body: rideListContent(size),
    );
  }

  rideListContent(Size size) {
    return ListView.builder(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(vertical: fixPadding),
      itemCount: rideList.length,
      itemBuilder: (context, index) {
        return GestureDetector(
          onTap: () {
            Navigator.pushNamed(context, '/rideDetail',
                arguments: {"id": rideList[index]});
          },
          child: Container(
            width: double.maxFinite,
            margin: const EdgeInsets.symmetric(
                horizontal: fixPadding * 2.0, vertical: fixPadding),
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
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.all(fixPadding),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            address(greenColor,
                                rideList[index]['pickupLocation'].toString()),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: fixPadding * 0.75),
                              child: DottedBorder(
                                padding: EdgeInsets.zero,
                                dashPattern: const [1.9, 3.9],
                                color: greyColor,
                                strokeWidth: 1.2,
                                child: const SizedBox(height: 14.0),
                              ),
                            ),
                            address(
                                redColor,
                                rideList[index]['destinationLocation']
                                    .toString()),
                          ],
                        ),
                      ),
                      widthSpace,
                      Text(
                        "\Tsh ${rideList[index]['price']}",
                        style: semibold18Primary,
                      )
                    ],
                  ),
                ),
                DottedBorder(
                  padding: EdgeInsets.zero,
                  dashPattern: const [2, 4],
                  color: greyColor,
                  child: const SizedBox(
                    width: double.maxFinite,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(fixPadding),
                  child: Row(
                    children: [
                      rideList[index]['image'] != null
                          ? Container(
                              height: 40.0,
                              width: 40.0,
                              decoration: BoxDecoration(
                                color: whiteColor,
                                borderRadius: BorderRadius.circular(5.0),
                                image: DecorationImage(
                                  image: NetworkImage(
                                    "$apiUrl/storage/${rideList[index]['image']}",
                                  ),
                                  fit: BoxFit.cover,
                                ),
                              ),
                            )
                          : CircleAvatar(
                              radius: 20.0,
                              backgroundColor: primaryColor,
                              child: Text(
                                rideList[index]['name'][0],
                                style: semibold15White,
                              ),
                            ),
                      widthSpace,
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              rideList[index]['name'].toString(),
                              style: semibold15Black33,
                              overflow: TextOverflow.ellipsis,
                            ),
                            Row(
                              children: [
                                ConstrainedBox(
                                  constraints: BoxConstraints(
                                    maxWidth: size.width * 0.28,
                                  ),
                                  child: Text(
                                    rideList[index]['dateTime'].toString(),
                                    style: semibold13Grey,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                Text(
                                  " | ${rideList[index]['rate']}",
                                  style: semibold13Grey,
                                ),
                                const Icon(
                                  Icons.star,
                                  color: secondaryColor,
                                  size: 15.0,
                                )
                              ],
                            ),
                          ],
                        ),
                      ),
                      seats(index)
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

  seats(int index) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 95.0),
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        scrollDirection: Axis.horizontal,
        child: Row(
          children: List.generate(
            4,
            (i) => Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: fixPadding * 0.25),
              child: Icon(
                Icons.event_seat,
                color: (i < (rideList[index]['bookedSeat'] as int))
                    ? primaryColor
                    : greyColor,
                size: 18.0,
              ),
            ),
          ),
        ),
      ),
    );
  }

  address(Color color, String address) {
    return Row(
      children: [
        Container(
          height: 16.0,
          width: 16.0,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: color),
          ),
          alignment: Alignment.center,
          child: Icon(
            Icons.location_pin,
            color: color,
            size: 12.0,
          ),
        ),
        widthSpace,
        Expanded(
          child: Text(
            address,
            style: medium14Black3C,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}

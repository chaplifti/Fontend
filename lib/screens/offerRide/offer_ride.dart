import 'dart:convert';

import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:rc_fl_gopoolar/theme/theme.dart';
import 'package:rc_fl_gopoolar/widget/column_builder.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

import '../../constants/key.dart';
import '../../utilis/dialog.dart';
import '../../utilis/response.dart';
import '../notification.dart';

class OfferRideScreen extends StatefulWidget {
  const OfferRideScreen({super.key});

  @override
  State<OfferRideScreen> createState() => _OfferRideScreenState();
}

class _OfferRideScreenState extends State<OfferRideScreen> {
  final seatList = ["1", "2", "3", "4", "5", "6", "7", "8"];
  String? selectedSeat;
  TextEditingController priceController = TextEditingController();
  TextEditingController dateAndTimeController = TextEditingController();
  // TextEditingController dateAndTimeController = TextEditingController();

  String? selectedCar;
  int? selectedCarID;

  String? pickupAddress;
  String? destinationAddress;
  List<Map<String, dynamic>> stopPointsLocation = [];
  List<Map<String, dynamic>> vehicleList = [];

  Future<void> _loadLocations() async {
    final prefs = await SharedPreferences.getInstance();
    List<String>? pickupLocationList = prefs.getStringList('sourceLocation');
    List<String>? destinationLocationList =
        prefs.getStringList('destinationLocation');
    List<String>? stopsJson = prefs.getStringList('stopPointsLocation');

    // Safely access the first item if available, otherwise null.
    String? localPickupAddress =
        pickupLocationList?.isNotEmpty == true ? pickupLocationList![0] : null;
    String? localDestinationAddress =
        destinationLocationList?.isNotEmpty == true
            ? destinationLocationList![0]
            : null;

    List<Map<String, dynamic>> localStopPointsLocation = [];
    if (stopsJson != null) {
      // Decode each JSON string to Map<String, dynamic> and add to list
      for (String stop in stopsJson) {
        try {
          Map<String, dynamic> decoded = jsonDecode(stop);
          localStopPointsLocation.add(decoded);
        } catch (e) {
          // Handle or log error if JSON decoding fails
          print("Error decoding stop point: $e");
        }
      }
    }

    setState(() {
      pickupAddress = localPickupAddress;
      destinationAddress = localDestinationAddress;
      stopPointsLocation = localStopPointsLocation;
    });
    for (int i = 0; i < stopPointsLocation.length; i++) {
      var data = jsonDecode(stopPointsLocation[i]['details']);
      print(data['address']);
    }
  }

  @override
  void initState() {
    super.initState();
    _loadLocations();
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

      print(
          "vehicleList----------------------------------------------------$vehicleList");
    } else {
      print('Failed to fetch vehicle list');
    }
  }

  String convertDate(String dateStr) {
    final DateFormat originalFormat = DateFormat("d MMMM,HH:mma", "en_US");

    try {
      DateTime dateTime = originalFormat.parse(dateStr);
      final DateFormat iso8601Format = DateFormat("yyyy-MM-ddTHH:mm:ss");
      String iso8601DateStr = iso8601Format.format(dateTime);

      return iso8601DateStr;
    } catch (e) {
      print('Error parsing date: $e');
      return '';
    }
  }

  Future<void> createRide() async {
    pleaseWaitDialog(context);
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? savedAccessUserToken = prefs.getString('AccessUserToken');

    List<String>? pickupLocationList = prefs.getStringList('sourceLocation');
    List<String>? destinationLocationList =
        prefs.getStringList('destinationLocation');

    List<String>? stopsJson = prefs.getStringList('stopPointsLocation');
    // Remove data for the 'counter' key.
    // await prefs.remove('stopPointsLocation');

    if (stopsJson != null) {
      List<Map<String, dynamic>> transformedList = [];

      for (String stopJson in stopsJson) {
        Map<String, dynamic> stopMap = jsonDecode(stopJson);

        // Extracting "lat" and "long" from the "details" field
        Map<String, dynamic> details = jsonDecode(stopMap['details']);
        double lat = double.parse(details['lat']);
        double lng = double.parse(details['long']);

        // Creating the desired format
        Map<String, dynamic> transformedStop = {
          "lat": lat,
          "lng": lng,
        };

        transformedList.add(transformedStop);
      }

      final String? dateAndTime = prefs.getString('dateAndTime');
      final String? noOfSeat = prefs.getString('noOfSeat');
      var date = convertDate(dateAndTime!);
      print(
          "date-----------------------------------------------------------------------------$date");
      final uri = Uri.parse(
          '$apiUrl/api/user/rides'); // Replace with your actual endpoint
      final headers = {
        'Authorization': 'Bearer $savedAccessUserToken',
        'Content-Type': 'application/json'
      };
      final body = jsonEncode({
        'vehicle_id': selectedCarID,
        'starting_point': {
          "lat": pickupLocationList![1],
          "lng": pickupLocationList[2]
        },
        'stop_points': transformedList,
        'destination': {
          "lat": destinationLocationList![1],
          "lng": destinationLocationList[2]
        },
        'price': priceController.text,
        'available_seats': noOfSeat,
        'start_time': convertDate(dateAndTime!),
        'starting_point_address': pickupLocationList[0],
        'destination_address': destinationLocationList[0],
      });

      final response = await http.post(uri, headers: headers, body: body);
      // final responseData = jsonDecode(response.body);
      print('Response body: ${response.body}');
      try {
        final response = await http.post(uri, headers: headers, body: body);
        final responseData = jsonDecode(response.body);

        String message = displayResponse(responseData);
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
            Navigator.pushNamed(context, '/bottomBar');
          });
          print('Trip created successfully: ${response.body}');
        } else {
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
        print('Failed to create trip: ${response.statusCode} ${response.body}');
      } catch (e) {
        // Handle network errors or other exceptions
        print('Error creating trip: $e');
      }
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
          "Offer ride",
          style: semibold18White,
        ),
      ),
      body: ListView(
        physics: const BouncingScrollPhysics(),
        padding: EdgeInsets.zero,
        children: [
          pickupAndDestinatioLocation(),
          Padding(
            padding: const EdgeInsets.all(fixPadding * 2.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                priceField(),
                heightSpace,
                heightSpace,
                yourCar(context),
                heightSpace,
                heightSpace,
              ],
            ),
          )
        ],
      ),
      bottomNavigationBar: continueButton(context),
    );
  }

  continueButton(BuildContext context) {
    return Padding(
      padding:
          EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: GestureDetector(
        onTap: () {
          createRide();
          // Navigator.pushNamed(context, '/success', arguments: {"id": 1});
        },
        child: Container(
          margin: const EdgeInsets.all(fixPadding * 2.0),
          padding: const EdgeInsets.symmetric(
              horizontal: fixPadding * 2.0, vertical: fixPadding * 1.4),
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
            "Continue",
            style: bold18White,
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }

  noOfSeatBottomsheet(Size size) {
    return showModalBottomSheet(
        isScrollControlled: true,
        constraints: BoxConstraints(maxHeight: size.height - 80),
        backgroundColor: whiteColor,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(40.0)),
        ),
        context: context,
        builder: (contetx) {
          return ListView(
            shrinkWrap: true,
            padding: EdgeInsets.zero,
            physics: const BouncingScrollPhysics(),
            children: [
              heightSpace,
              heightSpace,
              const Text(
                "No of seat",
                style: semibold18Primary,
                textAlign: TextAlign.center,
              ),
              ColumnBuilder(
                  itemBuilder: (context, index) {
                    return Column(
                      children: [
                        ListTile(
                          onTap: () {
                            setState(() {
                              selectedSeat = seatList[index];
                            });
                            Navigator.pop(context);
                          },
                          title: Text(
                            "${seatList[index]} Seat",
                            style: selectedSeat == seatList[index]
                                ? semibold16Secondary
                                : semibold16Black33,
                            textAlign: TextAlign.center,
                          ),
                        ),
                        seatList.length == index + 1
                            ? const SizedBox()
                            : Container(
                                width: double.maxFinite,
                                height: 1,
                                color: greyD4Color,
                              )
                      ],
                    );
                  },
                  itemCount: seatList.length)
            ],
          );
        });
  }

  yourCar(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        titleText("Your car"),
        heightSpace,
        GestureDetector(
          onTap: () {
            carListBottomsheet(context);
          },
          child: Container(
            decoration: boxDecoration,
            width: double.maxFinite,
            padding: const EdgeInsets.symmetric(
                horizontal: fixPadding, vertical: fixPadding * 1.2),
            child: Row(
              children: [
                Expanded(
                  child: selectedCar != null
                      ? Text(
                          selectedCar.toString(),
                          style: semibold15Black33,
                          overflow: TextOverflow.ellipsis,
                        )
                      : const Text(
                          "Select your car",
                          style: medium15Grey,
                          overflow: TextOverflow.ellipsis,
                        ),
                ),
                const Icon(
                  Icons.keyboard_arrow_down,
                  color: greyColor,
                )
              ],
            ),
          ),
        )
      ],
    );
  }

  carListBottomsheet(BuildContext context) {
    return showModalBottomSheet(
      backgroundColor: whiteColor,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(40.0),
        ),
      ),
      context: context,
      builder: (context) {
        return ListView(
          physics: const BouncingScrollPhysics(),
          padding: EdgeInsets.zero,
          shrinkWrap: true,
          children: [
            const Padding(
              padding:
                  EdgeInsets.only(top: fixPadding * 2.0, bottom: fixPadding),
              child: Text(
                "Select your car",
                style: semibold18Primary,
                textAlign: TextAlign.center,
              ),
            ),
            ColumnBuilder(
              itemBuilder: (context, index) {
                return Column(
                  children: [
                    ListTile(
                      onTap: () {
                        setState(() {
                          selectedCarID = vehicleList[index]['id'];
                          selectedCar =
                              vehicleList[index]['vehicle_name'].toString();
                        });
                        Navigator.pop(context);
                      },
                      title: Text(
                        vehicleList[index]['vehicle_name'].toString(),
                        style: semibold15Black33,
                        textAlign: TextAlign.center,
                      ),
                    ),
                    vehicleList.length == index + 1
                        ? const SizedBox()
                        : Container(
                            height: 1,
                            width: double.maxFinite,
                            color: greyD4Color,
                          )
                  ],
                );
              },
              itemCount: vehicleList.length,
            )
          ],
        );
      },
    );
  }

  priceField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        titleText("Price"),
        heightSpace,
        Container(
          decoration: boxDecoration,
          alignment: Alignment.center,
          child: TextField(
            style: semibold15Black33,
            cursorColor: primaryColor,
            controller: priceController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
                contentPadding: EdgeInsets.symmetric(
                    horizontal: fixPadding, vertical: fixPadding * 1.5),
                border: InputBorder.none,
                hintText: "Write price per seat",
                hintStyle: medium15Grey,
                isDense: true,
                prefixText: "\Tsh ",
                prefixStyle: medium15Black33),
          ),
        )
      ],
    );
  }

  BoxDecoration boxDecoration = BoxDecoration(
    color: whiteColor,
    borderRadius: BorderRadius.circular(10.0),
    boxShadow: [
      BoxShadow(
        color: blackColor.withOpacity(0.15),
        blurRadius: 6.0,
      )
    ],
  );

  pickupAndDestinatioLocation() {
    return Container(
      padding: const EdgeInsets.symmetric(
          vertical: fixPadding, horizontal: fixPadding * 2.0),
      width: double.maxFinite,
      decoration: BoxDecoration(
        color: whiteColor,
        boxShadow: [
          BoxShadow(
            color: blackColor.withOpacity(0.15),
            blurRadius: 6.0,
          )
        ],
      ),
      child: Row(
        children: [
          Column(
            children: [
              locationIcon(greenColor),
              DottedBorder(
                padding: EdgeInsets.zero,
                color: greyColor,
                dashPattern: const [2.4, 4],
                child: const SizedBox(height: 55.0),
              ),
              for (var stopPoint in stopPointsLocation) ...[
                stopLocationPointIcon(black33Color),
                DottedBorder(
                  padding: EdgeInsets.zero,
                  color: greyColor,
                  dashPattern: const [2.4, 4],
                  child: const SizedBox(height: 55.0),
                ),
              ],
              locationIcon(redColor),
            ],
          ),
          widthSpace,
          width5Space,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                titleText("Pick up location"),
                height5Space,
                Text(
                  pickupAddress ?? 'No pickup address provided',
                  style: medium14Grey,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                heightSpace,
                heightSpace,
                height5Space,
                height5Space,
                height5Space,
                height5Space,
                height5Space,
                height5Space,
                for (int i = 0; i < stopPointsLocation.length; i++) ...[
                  titleText("Point location"),
                  height5Space,
                  Text(
                    jsonDecode(stopPointsLocation[i]['details'])['address'],
                    style: medium14Grey,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  heightSpace,
                  heightSpace,
                  height5Space,
                  height5Space,
                  height5Space,
                  height5Space,
                  height5Space,
                  height5Space,
                ],
                titleText("Destination location"),
                height5Space,
                Text(
                  destinationAddress ?? 'No destination address provided',
                  style: medium14Grey,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  titleText(String title) {
    return Text(
      title,
      style: semibold15Black33,
    );
  }

  locationIcon(Color color) {
    return Container(
      height: 24.0,
      width: 24.0,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: color),
      ),
      alignment: Alignment.center,
      child: Icon(
        Icons.location_pin,
        color: color,
        size: 18.0,
      ),
    );
  }

  stopLocationPointIcon(Color color) {
    return Container(
      height: 24.0,
      width: 24.0,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: color),
      ),
      alignment: Alignment.center,
      child: Icon(
        Icons.circle,
        color: color,
        size: 18.0,
      ),
    );
  }
}

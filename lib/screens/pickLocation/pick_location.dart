// ignore_for_file: prefer_typing_uninitialized_variables

import 'dart:async';
import 'dart:convert';
import 'dart:ui' as ui;

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geocoding/geocoding.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:rc_fl_gopoolar/theme/theme.dart';
import 'package:http/http.dart' as http;
import 'package:geolocator/geolocator.dart';

import '../../constants/key.dart';
import 'package:search_map_place_updated/search_map_place_updated.dart';

class PickLocationScreen extends StatefulWidget {
  const PickLocationScreen({super.key});

  @override
  State<PickLocationScreen> createState() => _PickLocationScreenState();
}

class _PickLocationScreenState extends State<PickLocationScreen> {
  Completer<GoogleMapController> mapcontroller = Completer();

  TextEditingController searchController = TextEditingController();

  CameraPosition locationposition = const CameraPosition(
      target: LatLng(-6.787360782866734, 39.27123535111817), zoom: 13.00);

  Map<String, Marker> markers = {};
  List<String> suggestions = [];

  String? _address;
  String? _addressToShow;

  @override
  void initState() {
    defaultAddress();
    super.initState();
  }

  void defaultAddress() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }

    Position position = await Geolocator.getCurrentPosition();
    CameraPosition currentLocation = CameraPosition(
      target: LatLng(position.latitude, position.longitude),
      zoom: 16.00,
    );

    final GoogleMapController controller = await mapcontroller.future;
    controller.animateCamera(CameraUpdate.newCameraPosition(currentLocation));

    // Place a marker at the current location
    addMarker('currentLocation', LatLng(position.latitude, position.longitude));

    // Optionally, update the address display based on the current location
    List<Placemark> placemarks =
        await placemarkFromCoordinates(position.latitude, position.longitude);
    Placemark placeMark = placemarks.first;
    String street = placeMark.street!;
    String administrativeArea = placeMark.administrativeArea!;
    String postalCode = placeMark.postalCode!;
    String country = placeMark.country!;
    String address = "$street, $administrativeArea $postalCode, $country";

    setState(() {
      _address = address;
      _addressToShow = address;
      locationposition =
          currentLocation; // Update the camera position to the current location
    });
  }

  List<dynamic> _suggestions = [];
  Future<void> _fetchSuggestions(String input) async {
    if (input.isEmpty) {
      setState(() {
        _suggestions = [];
      });
      return;
    }
    // Use your Google API Key
    String baseUrl =
        'https://maps.googleapis.com/maps/api/place/autocomplete/json';
    String request = '$baseUrl?input=$input&key=$googleMapApiKey';

    var response = await http.get(Uri.parse(request));
    if (response.statusCode == 200) {
      final predictions = json.decode(response.body)['predictions'];
      print(predictions);
      setState(() {
        _suggestions = predictions;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 75.0,
        centerTitle: false,
        automaticallyImplyLeading: false,
        leading: IconButton(
          padding: const EdgeInsets.all(fixPadding * 2.0),
          onPressed: () {
            Navigator.pop(context);
          },
          icon: const Icon(
            Icons.arrow_back_ios,
            color: secondaryColor,
          ),
        ),
        titleSpacing: 0.0,
        title: TextField(
          controller: searchController,
          decoration: InputDecoration(
            labelStyle: TextStyle(color: Colors.black),
            hintText: 'Search Place...',
          ),
          onChanged: _fetchSuggestions,
        ),
      ),
      body: Stack(
        children: [
          googleMap(),
          Visibility(
            visible: _suggestions.isNotEmpty,
            child: Positioned(
              left: 0,
              right: 0,
              height: 300,
              child: Container(
                padding: EdgeInsets.symmetric(
                    vertical: 8), // Add some padding inside the container
                decoration: BoxDecoration(
                  color: Colors.white, // Background color
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.5),
                      spreadRadius: 5,
                      blurRadius: 7,
                      offset: Offset(0, 3), // changes position of shadow
                    ),
                  ],
                  borderRadius: BorderRadius.circular(10), // Rounded corners
                ),
                height: 100, // Adjust height as necessary
                child: ListView.builder(
                  itemCount: _suggestions.length,
                  itemBuilder: (context, index) {
                    return ListTile(
                      leading: Icon(Icons.location_on), // Add an icon
                      title: Text(
                        _suggestions[index]['description'],
                        style: TextStyle(color: Colors.black), // Text style
                      ),
                      onTap: () {
                        // Handle the suggestion selection
                      },
                    );
                  },
                ),
              ),
            ),
          ),
          addressAndPickLocationButton(),
        ],
      ),
    );
  }

  addressAndPickLocationButton() {
    return Align(
      alignment: Alignment.bottomCenter,
      child: Container(
        padding: const EdgeInsets.symmetric(
            horizontal: fixPadding * 2.0, vertical: fixPadding * 3.0),
        decoration: const BoxDecoration(
            color: Color(0xFFFBF8F8),
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(20.0),
            )),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: fixPadding * 2.0, vertical: fixPadding * 1.5),
              decoration: BoxDecoration(
                color: whiteColor,
                borderRadius: BorderRadius.circular(10.0),
              ),
              child: Row(
                children: [
                  Container(
                    height: 24.0,
                    width: 24.0,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: greenColor),
                    ),
                    child: const Icon(
                      Icons.location_pin,
                      color: greenColor,
                      size: 18.0,
                    ),
                  ),
                  widthSpace,
                  Expanded(
                    child: Text(
                      _addressToShow.toString(),
                      style: medium14Black33,
                    ),
                  ),
                ],
              ),
            ),
            heightSpace,
            heightSpace,
            GestureDetector(
              onTap: () {
                pickaddress(context);
              },
              child: Container(
                width: double.maxFinite,
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
                alignment: Alignment.center,
                child: const Text(
                  "Pick this location",
                  style: bold18White,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget googleMap() {
    return GoogleMap(
      mapType: MapType.normal,
      initialCameraPosition: locationposition,
      onTap: (LatLng latLng) async {
        final Marker marker = Marker(
          markerId: const MarkerId('yourLocation'),
          position: latLng,
          icon: BitmapDescriptor.fromBytes(
            await getBytesFromAsset("assets/pickLocation/marker.png", 80),
          ),
        );

        List<Placemark> newPlace =
            await placemarkFromCoordinates(latLng.latitude, latLng.longitude);
        print("Latitude: ${latLng.latitude}, Longitude: ${latLng.longitude}");

        Placemark placeMark = newPlace.first;
        String street = placeMark.street ?? "";
        String administrativeArea = placeMark.administrativeArea ?? "";
        String postalCode = placeMark.postalCode ?? "";
        String country = placeMark.country ?? "";
        String address = "$street, $administrativeArea $postalCode, $country";

        Map<String, dynamic> fullData = {
          'address': address,
          'lat': latLng.latitude.toString(),
          'long': latLng.longitude.toString(),
        };

        setState(() {
          _address = jsonEncode(fullData);
          _addressToShow = address;
          markers.clear();
          markers['yourLocation'] = marker;
        });
      },
      onMapCreated: (GoogleMapController controller) {
        mapcontroller.complete(controller);
        // Remove the hardcoded addMarker call here to avoid initial marker placement
      },
      markers: markers.values.toSet(),
    );
  }

  addMarker(String id, LatLng location) async {
    var marker = Marker(
      markerId: MarkerId(id),
      position: location,
      icon: BitmapDescriptor.fromBytes(
        await getBytesFromAsset("assets/pickLocation/marker.png", 80),
      ),
    );

    markers[id] = marker;
    setState(() {});
  }

  static Future<Uint8List> getBytesFromAsset(String path, int width) async {
    ByteData data = await rootBundle.load(path);
    ui.Codec codec = await ui.instantiateImageCodec(data.buffer.asUint8List(),
        targetWidth: width);
    ui.FrameInfo fi = await codec.getNextFrame();
    return (await fi.image.toByteData(format: ui.ImageByteFormat.png))!
        .buffer
        .asUint8List();
  }

  void pickaddress(BuildContext context) async {
    Navigator.pop(context, _address);
  }
}

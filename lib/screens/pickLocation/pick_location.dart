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

class PickLocationScreen extends StatefulWidget {
  const PickLocationScreen({super.key});

  @override
  State<PickLocationScreen> createState() => _PickLocationScreenState();
}

class _PickLocationScreenState extends State<PickLocationScreen> {
  Completer<GoogleMapController> mapcontroller = Completer();

  TextEditingController searchController = TextEditingController();

  static CameraPosition locationposition = const CameraPosition(
      target: LatLng(-6.787360782866734, 39.27123535111817), zoom: 13.00);

  Map<String, Marker> markers = {};

  String? _address;
  String? _addressToShow;

  @override
  void initState() {
    defaultAddress();
    super.initState();
  }

  void defaultAddress() async {
    List<Placemark> defaultPlace =
        await placemarkFromCoordinates(-6.787360782866734, 39.27123535111817);

    Placemark placeMark = defaultPlace.first;
    String street = placeMark.street!;
    String administrativeArea = placeMark.administrativeArea!;
    String postalCode = placeMark.postalCode!;
    String country = placeMark.country!;
    String address = "$street, $administrativeArea $postalCode, $country";

    setState(() {
      _address = address;
      _addressToShow = address;
    });
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
            color: whiteColor,
          ),
        ),
        titleSpacing: 0.0,
        title: Container(
          width: double.maxFinite,
          margin: const EdgeInsets.only(right: fixPadding * 2.0),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: whiteColor,
            borderRadius: BorderRadius.circular(10.0),
            boxShadow: [
              BoxShadow(
                color: blackColor.withOpacity(0.15),
                blurRadius: 8.0,
              )
            ],
          ),
          child: TextField(
            style: semibold16Black33,
            controller: searchController,
            decoration: const InputDecoration(
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(vertical: fixPadding),
              prefixIconConstraints:
                  BoxConstraints(maxHeight: 45.0, minWidth: 35.0),
              prefixIcon: Icon(CupertinoIcons.search),
              hintText: "Search",
              hintStyle: semibold16Grey,
              isDense: true,
            ),
          ),
        ),
      ),
      body: Stack(
        children: [
          googleMap(),
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

  googleMap() {
    return GoogleMap(
      mapType: MapType.normal,
      initialCameraPosition: locationposition,
      onTap: (LatLng latLng) async {
        const MarkerId markerId = MarkerId('yourLocation');
        final Marker marker = Marker(
            markerId: markerId,
            position: latLng,
            icon: BitmapDescriptor.fromBytes(
              await getBytesFromAsset("assets/pickLocation/marker.png", 80),
            ));

        var latitude;
        var longitude;

        markers.forEach((key, value) {
          latitude = value.position.latitude;
          longitude = value.position.longitude;
        });
        List<Placemark> newPlace =
            await placemarkFromCoordinates(latitude, longitude);

        Placemark placeMark = newPlace[0];
        String street = placeMark.street!;
        String administrativeArea = placeMark.administrativeArea!;
        String postalCode = placeMark.postalCode!;
        String country = placeMark.country!;
        String address = "$street, $administrativeArea $postalCode, $country";

        Map<String, dynamic> fullData = {
          'address': '$address',
          'lat': '$latitude',
          'long': '$longitude',
        };

        setState(() {
          _address = jsonEncode(fullData);
          _addressToShow = address;
          markers.clear();

          markers["yourLocation"] = marker;
        });
      },
      onMapCreated: (GoogleMapController controller) {
        mapcontroller.complete(controller);
        addMarker(
          'yourLocation',
          const LatLng(-6.787360782866734, 39.27123535111817),
        );
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

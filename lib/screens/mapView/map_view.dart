import 'dart:async';
import 'dart:ui' as ui;

import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:rc_fl_gopoolar/constants/key.dart';
import 'package:rc_fl_gopoolar/theme/theme.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:geocoding/geocoding.dart';

class MapViewScreen extends StatefulWidget {
  const MapViewScreen({super.key});

  @override
  State<MapViewScreen> createState() => _MapViewScreenState();
}

class _MapViewScreenState extends State<MapViewScreen> {
  GoogleMapController? mapController;

  Map<String, dynamic>? rideData;

  static const CameraPosition currentPosition = CameraPosition(
    target: LatLng(-6.7920480427905, 39.2712279732554),
    zoom: 12.00,
  );

  List<Marker> allMarkers = [];
  Map<PolylineId, Polyline> polylines = {};

  PolylinePoints polylinePoints = PolylinePoints();

  @override
  void initState() {
    super.initState();
    addMarkers();
  }

  List<LatLng> pathPoints = [];
  Future<Uint8List> getBytesFromAsset(String path, int width) async {
    ByteData data = await rootBundle.load(path);
    ui.Codec codec = await ui.instantiateImageCodec(data.buffer.asUint8List(),
        targetWidth: width);
    ui.FrameInfo fi = await codec.getNextFrame();
    return (await fi.image.toByteData(format: ui.ImageByteFormat.png))!
        .buffer
        .asUint8List();
  }

  Future<void> addMarkers() async {
    final startMarkerIcon =
        await getBytesFromAsset('assets/mapView/destinationicon.png', 100);
    final destinationMarkerIcon =
        await getBytesFromAsset('assets/mapView/pickupicon.png', 100);
    final stopMarkerIcon =
        await getBytesFromAsset('assets/mapView/grey-marker.png', 100);

    // Assuming rideData is already loaded
    LatLng origin = LatLng(rideData!['ride']['starting_point']['lng'],
        rideData!['ride']['starting_point']['lat']);
    LatLng destination = LatLng(rideData!['ride']['destination']['lng'],
        rideData!['ride']['destination']['lat']);
    List<dynamic> stopPoints = rideData!['ride']['stop_points'];

    // Add Start Marker
    allMarkers.add(Marker(
      markerId: MarkerId("start_marker"),
      position: origin,
      icon: BitmapDescriptor.fromBytes(startMarkerIcon),
    ));

    // Add Destination Marker
    allMarkers.add(Marker(
      markerId: MarkerId("destination_marker"),
      position: destination,
      icon: BitmapDescriptor.fromBytes(destinationMarkerIcon),
    ));

    // Add Stop Point Markers
    for (var i = 0; i < stopPoints.length; i++) {
      allMarkers.add(Marker(
        markerId: MarkerId("stop_marker_$i"),
        position: LatLng(stopPoints[i]['lat'], stopPoints[i]['lng']),
        icon: BitmapDescriptor.fromBytes(stopMarkerIcon),
      ));
    }

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    rideData =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>;

    print("rideData=-------------------------$rideData");

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
          "Map view",
          style: semibold18White,
        ),
      ),
      body: SizedBox(
        height: size.height,
        width: size.width,
        child: Stack(
          children: [
            googlmap(),
            bottomSheet(),
          ],
        ),
      ),
    );
  }

  bottomSheet() {
    return Align(
      alignment: Alignment.bottomCenter,
      child: AnimationConfiguration.synchronized(
        child: SlideAnimation(
          curve: Curves.easeIn,
          delay: const Duration(milliseconds: 350),
          child: DraggableScrollableSheet(
            initialChildSize: 0.45,
            maxChildSize: 0.55,
            minChildSize: 0.45,
            builder: (BuildContext context, ScrollController scrollController) {
              return FutureBuilder<List<String>>(
                future:
                    _getStopPointsAddresses(rideData!['ride']['stop_points']),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return const Center(
                        child: Text('Error fetching addresses'));
                  } else {
                    return Container(
                      decoration: const BoxDecoration(
                        color: whiteColor,
                        borderRadius: BorderRadius.vertical(
                          top: Radius.circular(40.0),
                        ),
                      ),
                      child: ListView(
                        shrinkWrap: true,
                        controller: scrollController,
                        physics: const BouncingScrollPhysics(),
                        padding: const EdgeInsets.all(fixPadding * 2.0),
                        children: [
                          Text(
                            rideData!['ride']['start_time'],
                            style: semibold16Black33,
                          ),
                          heightSpace,
                          heightSpace,
                          step("Start point (10:00 am)",
                              rideData!['ride']['pickupLocation'],
                              isPickDropPoint: true,
                              textColor: greenColor,
                              iconColor: greenColor),
                          for (var address in snapshot.data!)
                            step("Stop point", address,
                                isPickDropPoint: true,
                                iconColor: greyB4Color,
                                textColor: greyB4Color),
                          step("Destination point (11:00 am)",
                              rideData!['ride']['destinationLocation'],
                              isPickDropPoint: true, textColor: redColor),
                        ],
                      ),
                    );
                  }
                },
              );
            },
          ),
        ),
      ),
    );
  }

  Future<List<String>> _getStopPointsAddresses(List<dynamic> stopPoints) async {
    List<String> addresses = [];
    for (var stopPoint in stopPoints) {
      List<Placemark> placemarks =
          await placemarkFromCoordinates(stopPoint['lat'], stopPoint['lng']);
      Placemark placeMark = placemarks.first;
      String address =
          "${placeMark.street}, ${placeMark.administrativeArea} ${placeMark.postalCode}, ${placeMark.country}";
      addresses.add(address);
    }
    return addresses;
  }

  step(String title, String subTitle,
      {isDivider = true,
      isPickDropPoint = false,
      iconColor = redColor,
      textColor = greyColor}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            isPickDropPoint
                ? Container(
                    height: 16.0,
                    width: 16.0,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: iconColor),
                    ),
                    alignment: Alignment.center,
                    child: Icon(
                      Icons.location_pin,
                      color: iconColor,
                      size: 12.0,
                    ),
                  )
                : Image.asset(
                    "assets/mapView/ride start.png",
                    height: 16.0,
                    width: 16.0,
                  ),
            isDivider
                ? Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: fixPadding * 0.8),
                    child: DottedBorder(
                      padding: EdgeInsets.zero,
                      dashPattern: const [2.2, 4],
                      color: greyD4Color,
                      strokeWidth: 1.2,
                      child: Container(
                        height: 45.0,
                      ),
                    ),
                  )
                : const SizedBox(),
          ],
        ),
        widthSpace,
        Expanded(
            child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: medium14Grey.copyWith(color: textColor),
              overflow: TextOverflow.ellipsis,
            ),
            height5Space,
            Text(
              subTitle,
              style: medium14Black33,
              overflow: TextOverflow.ellipsis,
            )
          ],
        ))
      ],
    );
  }

  googlmap() {
    return GoogleMap(
      zoomControlsEnabled: false,
      mapType: MapType.terrain,
      initialCameraPosition: currentPosition,
      onMapCreated: mapCreated,
      markers: Set.from(allMarkers),
      polylines: Set<Polyline>.of(polylines.values),
    );
  }

  void mapCreated(GoogleMapController controller) async {
    mapController = controller;
    if (rideData != null) {
      await addPolyLine(rideData!); // Make sure to check for null
      setState(() {});
    }
  }

  Future<void> addPolyLine(Map<String, dynamic> ride) async {
    List<LatLng> polylineCoordinates = [];
    PolylineResult result;
    List<dynamic> stopPoints = ride['ride']['stop_points'];

    LatLng origin = LatLng(ride['ride']['starting_point']['lng'],
        ride['ride']['starting_point']['lat']);
    LatLng destination = LatLng(
        ride['ride']['destination']['lng'], ride['ride']['destination']['lat']);

    // Function to fetch and append polyline points
    Future<void> fetchAndAppendPolyline(
        LatLng origin, LatLng destination) async {
      result = await polylinePoints.getRouteBetweenCoordinates(
          googleMapApiKey, // Make sure you have a valid Google API Key
          PointLatLng(origin.latitude, origin.longitude),
          PointLatLng(destination.latitude, destination.longitude),
          travelMode: TravelMode.driving);
      if (result.points.isNotEmpty) {
        result.points.forEach((PointLatLng point) {
          polylineCoordinates.add(LatLng(point.latitude, point.longitude));
        });
      }
    }

    if (stopPoints.isNotEmpty) {
      // Fetch polyline from start to first stop.
      await fetchAndAppendPolyline(
          origin, LatLng(stopPoints.first['lat'], stopPoints.first['lng']));

      // Fetch polyline between stops.
      for (int i = 0; i < stopPoints.length - 1; i++) {
        LatLng stopOrigin = LatLng(stopPoints[i]['lat'], stopPoints[i]['lng']);
        LatLng stopDestination =
            LatLng(stopPoints[i + 1]['lat'], stopPoints[i + 1]['lng']);

        await fetchAndAppendPolyline(stopOrigin, stopDestination);
      }

      // Fetch polyline from last stop to destination.
      await fetchAndAppendPolyline(
          LatLng(stopPoints.last['lat'], stopPoints.last['lng']), destination);
    } else {
      // If there are no stops, directly fetch polyline from start to end.
      await fetchAndAppendPolyline(origin, destination);
    }

    // Create and set the polyline
    final polylineId = PolylineId("route");
    final polyline = Polyline(
      polylineId: polylineId,
      color: Colors.blue,
      points: polylineCoordinates,
      width: 5,
    );

    setState(() {
      polylines[polylineId] = polyline;
    });
  }

  @override
  void dispose() {
    mapController!.dispose();
    super.dispose();
  }
}

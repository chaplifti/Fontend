import 'dart:async';
import 'dart:ui' as ui;
import 'dart:convert';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart';
import 'package:rc_fl_gopoolar/theme/theme.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
// import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:rc_fl_gopoolar/constants/key.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'dart:math' as math;

class StartRideRequesterScreen extends StatefulWidget {
  const StartRideRequesterScreen({super.key});

  @override
  State<StartRideRequesterScreen> createState() =>
      _StartRideRequesterScreenState();
}

class _StartRideRequesterScreenState extends State<StartRideRequesterScreen> {
  GoogleMapController? mapController;

  // static const CameraPosition currentPosition = CameraPosition(
  //     target: LatLng(-6.787360782866734, 39.27123535111817), zoom: 12.00);

  CameraPosition initialCameraPosition = CameraPosition(
      target: LatLng(-6.787360782866734, 39.27123535111817), zoom: 12.00);

  List<Marker> allMarkers = [];
  Map<PolylineId, Polyline> polylines = {};
  Map<String, dynamic>? rideData;
  PolylinePoints polylinePoints = PolylinePoints();

  StreamSubscription<Position>? positionStream; // For tracking location updates
  Position? _currentPosition; // To hold the current position
  final Set<Marker> _markers = {}; // Use a Set for markers to avoid duplicates

  @override
  void initState() {
    super.initState();
    addMarkers();
    _requestPermissions(); // Request permissions on init
    _startTracking(); // Start tracking the device location
    _updateInitialCameraPosition();
  }

  void _updateInitialCameraPosition() async {
    if (rideData != null) {
      LatLng sourceLocation = LatLng(
        rideData!['starting_point']['lng'],
        rideData!['starting_point']['lat'],
      );
      initialCameraPosition = CameraPosition(
        target: sourceLocation,
        zoom: 12.00,
      );
      if (mapController != null) {
        mapController!
            .moveCamera(CameraUpdate.newCameraPosition(initialCameraPosition));
      }
    }
  }

  void _requestPermissions() async {
    LocationPermission permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.denied) {
      // Handle permission denial here
    }
  }

  void _startTracking() {
    positionStream = Geolocator.getPositionStream().listen((Position position) {
      setState(() {
        _currentPosition = position;
        _updateCurrentLocationMarker();
      });

      // Update driver's location in Firestore
      _updateRequesterLocationInFirestore(
          position.latitude, position.longitude);
    });
  }

  void _updateCurrentLocationMarker() {
    if (_currentPosition == null) return;

    final currentLocationMarker = Marker(
      markerId: const MarkerId("current_location"),
      position: LatLng(_currentPosition!.latitude, _currentPosition!.longitude),
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
    );

    setState(() {
      // Remove old location marker
      allMarkers.removeWhere(
          (marker) => marker.markerId == const MarkerId("current_location"));
      // Add new location marker
      allMarkers.add(currentLocationMarker);
    });
  }

  void _updateRequesterLocationInFirestore(double lat, double lng) async {
    final prefs = await SharedPreferences.getInstance();
    final String? userPrefsData = prefs.getString('userData');
    final userId =
        userPrefsData != null ? jsonDecode(userPrefsData)['id'] : null;
    final rideId = rideData?['id'];
    final user_Id = rideData?['user_id'];

    if (userId == null || rideId == null || user_Id == null) {
      print("No user ID or ride ID found.");
      return;
    }

    // Use a combined key of userID and rideID to ensure uniqueness
    String combinedKey = "$user_Id-$rideId";

    DatabaseReference databaseReference =
        FirebaseDatabase.instance.ref().child('rides').child(combinedKey);

    // Check if there's an entry for this unique combined key in the database
    DataSnapshot snapshot = await databaseReference.get();

    if (snapshot.exists && snapshot.value != null) {
      Map<dynamic, dynamic> data = snapshot.value as Map<dynamic, dynamic>;
      List<dynamic> requesterLocations = data.containsKey('requester_location')
          ? List.from(data['requester_location'])
          : [];

      Map<String, dynamic>? driverLocationCurrent =
          data['driver_location_current'] != null
              ? Map<String, dynamic>.from(data['driver_location_current'])
              : null;
      Map<String, dynamic>? driverLocationPrevious =
          data['driver_location_previous'] != null
              ? Map<String, dynamic>.from(data['driver_location_previous'])
              : null;

      // Try to find existing requester entry by userId
      int index = requesterLocations.indexWhere(
          (element) => element['user_id'].toString() == userId.toString());

      if (driverLocationCurrent != null && driverLocationPrevious != null) {
        _updateDriverLocationMarker(
          driverLocationCurrent['lat'],
          driverLocationCurrent['lng'],
          driverLocationPrevious['lat'],
          driverLocationPrevious['lng'],
        );
      }

      if (index != -1) {
        // Existing location entry found for this user, update if changed
        if (requesterLocations[index]['location']['lat'] != lat ||
            requesterLocations[index]['location']['lng'] != lng) {
          requesterLocations[index]['location'] = {'lat': lat, 'lng': lng};
          databaseReference.update({'requester_location': requesterLocations});
          print("Location updated.");
        } else {
          print("Location is the same, not updating.");
        }
      } else {
        // No location entry for this user, add a new one
        requesterLocations.add({
          'user_id': userId,
          'ride_id': rideId,
          'location': {'lat': lat, 'lng': lng},
        });
        databaseReference.update({'requester_location': requesterLocations});
        print("New location added.");
      }
    } else {
      // No record exists for this unique key, create a new one with the requester's location
      databaseReference.set({
        'requester_location': [
          {
            'user_id': userId,
            'ride_id': rideId,
            'location': {'lat': lat, 'lng': lng},
          }
        ]
      });
      print("New ride and location created.");
    }
  }

  // void _updateDriverLocationMarker(double lat, double lng) {
  //   final driverLocationMarker = Marker(
  //     markerId: const MarkerId("driver_location"),
  //     position: LatLng(lat, lng),
  //     icon: BitmapDescriptor.defaultMarkerWithHue(
  //         BitmapDescriptor.hueRed), // or a custom car icon
  //   );

  //   setState(() {
  //     // Remove old driver location marker
  //     allMarkers.removeWhere(
  //         (marker) => marker.markerId == const MarkerId("driver_location"));
  //     // Add new driver location marker
  //     allMarkers.add(driverLocationMarker);
  //   });
  // }

  void _updateDriverLocationMarker(double currentLat, double currentLng,
      double prevLat, double prevLng) async {
    final Uint8List markerIcon =
        await getBytesFromAsset('assets/mapView/car.png', 100);

    final driverLocationMarker = Marker(
      markerId: const MarkerId("driver_location"),
      position: LatLng(currentLat, currentLng),
      icon: BitmapDescriptor.fromBytes(markerIcon), // Custom car icon
      rotation: _getRotation(currentLat, currentLng, prevLat,
          prevLng), // Optional: Calculate rotation based on direction
    );

    setState(() {
      // Remove old driver location marker
      allMarkers.removeWhere(
          (marker) => marker.markerId == const MarkerId("driver_location"));
      // Add new driver location marker
      allMarkers.add(driverLocationMarker);
    });

    // Optional: Animate camera to the new driver position
    if (mapController != null) {
      mapController!.animateCamera(
          CameraUpdate.newLatLng(LatLng(currentLat, currentLng)));
    }
  }

  double _getRotation(
      double currentLat, double currentLng, double prevLat, double prevLng) {
    var deltaLng = currentLng - prevLng;
    var y = math.sin(deltaLng) * math.cos(currentLat);
    var x = math.cos(prevLat) * math.sin(currentLat) -
        math.sin(prevLat) * math.cos(currentLat) * math.cos(deltaLng);
    var bearing = math.atan2(y, x);
    return (bearing * (180 / math.pi) + 360) %
        360; // Convert to degrees and normalize
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
    LatLng origin = LatLng(
        rideData!['starting_point']['lng'], rideData!['starting_point']['lat']);
    LatLng destination = LatLng(
        rideData!['destination']['lng'], rideData!['destination']['lat']);
    List<dynamic> stopPoints = rideData!['stop_points'];

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
          "Requester Ride Dashboard",
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
            startRideButton(),
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
            initialChildSize: 0.3,
            maxChildSize: 0.9,
            minChildSize: 0.2,
            builder: (BuildContext context, ScrollController scrollController) {
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
                  padding:
                      const EdgeInsets.symmetric(vertical: fixPadding * 2.0),
                  children: [
                    const Padding(
                      padding:
                          EdgeInsets.symmetric(horizontal: fixPadding * 2.0),
                      child: Text(
                        "Ride start on 25 june 2023",
                        style: semibold16Black33,
                        textAlign: TextAlign.center,
                      ),
                    ),
                    heightSpace,
                    heightSpace,
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      physics: const BouncingScrollPhysics(),
                      padding: EdgeInsets.zero,
                      child: Row(
                        children: List.generate(
                          rideData!.length,
                          (index) => Container(
                            margin: const EdgeInsets.symmetric(
                                horizontal: fixPadding * 2.0),
                            constraints: const BoxConstraints(maxWidth: 60.0),
                            child: Column(
                              children: [
                                Container(
                                  height: 50.0,
                                  width: 50.0,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    image: DecorationImage(
                                      image: AssetImage(
                                        rideData!['image'].toString(),
                                      ),
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                                height5Space,
                                Text(
                                  rideData!['name'].toString(),
                                  style: medium12Grey,
                                  textAlign: TextAlign.center,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                    heightSpace,
                    heightSpace,
                    step("Ride start",
                        "2715 Ash Dr. San Jose, South Dakota 83475",
                        isPickDropPoint: false),
                    step("Pick up cameron willimson",
                        "2715 Ash Dr. San Jose, South Dakota 83475"),
                    step("Pick up brooklyn simmons",
                        "2715 Ash Dr. San Jose, South Dakota 83475"),
                    step("Pick up leslie alexander ",
                        "2715 Ash Dr. San Jose, South Dakota 83475"),
                    step("Pick up jacob jones",
                        "2715 Ash Dr. San Jose, South Dakota 83475"),
                    step("Drive", "2715 Ash Dr. San Jose, South Dakota 83475",
                        isPickDropPoint: false),
                    step("Drop up brooklyn simmons",
                        "2715 Ash Dr. San Jose, South Dakota 83475"),
                    step("Drop up leslie alexander ",
                        "2715 Ash Dr. San Jose, South Dakota 83475"),
                    step("Drop up jacob jones",
                        "2715 Ash Dr. San Jose, South Dakota 83475"),
                    step(
                        "Ride end", "2715 Ash Dr. San Jose, South Dakota 83475",
                        isPickDropPoint: false, isDivider: false),
                    heightBox(fixPadding * 9.0)
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  startRideButton() {
    return Align(
      alignment: Alignment.bottomCenter,
      child: Container(
        color: whiteColor,
        child: GestureDetector(
          onTap: () {
            Navigator.pushNamed(context, '/roadMap');
          },
          child: Container(
            height: 50.0,
            width: double.maxFinite,
            margin: const EdgeInsets.all(fixPadding * 2.0),
            padding: const EdgeInsets.symmetric(horizontal: fixPadding * 2.0),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10.0),
              color: secondaryColor,
              boxShadow: [
                BoxShadow(
                  color: secondaryColor.withOpacity(0.1),
                  blurRadius: 12.0,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            alignment: Alignment.center,
            child: const Text(
              "Start ride",
              style: semibold18White,
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ),
    );
  }

  step(String title, String subTitle,
      {isDivider = true, isPickDropPoint = true}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: fixPadding * 2.0),
      child: Row(
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
                        border: Border.all(color: greyColor),
                      ),
                      alignment: Alignment.center,
                      child: const Icon(
                        Icons.location_pin,
                        color: greyColor,
                        size: 12.0,
                      ),
                    )
                  : Image.asset(
                      "assets/mapView/ride start.png",
                      height: 16.0,
                      width: 16.0,
                      color: greyColor,
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
                style: medium14Grey,
                overflow: TextOverflow.ellipsis,
              ),
              height5Space,
              Text(
                subTitle,
                style: medium14Black3C,
                overflow: TextOverflow.ellipsis,
              )
            ],
          ))
        ],
      ),
    );
  }

  googlmap() {
    return GoogleMap(
      zoomControlsEnabled: false,
      mapType: MapType.terrain,
      initialCameraPosition: initialCameraPosition,
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
    List<dynamic> stopPoints = ride['stop_points'];

    LatLng origin =
        LatLng(ride['starting_point']['lng'], ride['starting_point']['lat']);
    LatLng destination =
        LatLng(ride['destination']['lng'], ride['destination']['lat']);

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
    positionStream?.cancel();
    super.dispose();
  }
}

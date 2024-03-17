import 'dart:async';
import 'dart:ui' as ui;
import 'dart:convert';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
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

import '../../utilis/dialog.dart';
import '../notification.dart';
import '../../utilis/dialog.dart';
import '../../constants/key.dart';
import '../../utilis/dialog.dart';
import '../../utilis/response.dart';
import '../notification.dart';

class StartRideScreen extends StatefulWidget {
  const StartRideScreen({super.key});

  @override
  State<StartRideScreen> createState() => _StartRideScreenState();
}

class _StartRideScreenState extends State<StartRideScreen> {
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
    print("rideData------------------------------------------$rideData");
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
      // setState(() {
      //   _currentPosition = position;
      //   _updateCurrentLocationMarker();
      // });

      // Update driver's location in Firestore
      _updateDriverLocationInFirestore(position.latitude, position.longitude);
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

  void _updateDriverLocationInFirestore(double lat, double lng) async {
    final prefs = await SharedPreferences.getInstance();
    final driverId = prefs.getString('userData') != null
        ? jsonDecode(prefs.getString('userData')!)['id']
        : null;
    final rideId = rideData!['id'];

    // Combined key
    String combinedKey = "$driverId-$rideId";

    DatabaseReference databaseReference =
        FirebaseDatabase.instance.ref().child('rides').child(combinedKey);

    DataSnapshot snapshot = await databaseReference.get();

    if (snapshot.exists && snapshot.value != null) {
      Map<String, dynamic> rideData =
          (snapshot.value as Map).cast<String, dynamic>();

      Map<String, dynamic>? currentLocation =
          rideData['driver_location_current'] != null
              ? (rideData['driver_location_current'] as Map)
                  .cast<String, dynamic>()
              : null;

      databaseReference.update({
        'driver_location_previous': currentLocation ??
            {'lat': lat, 'lng': lng}, // New previous is the old current
        'driver_location_current': {'lat': lat, 'lng': lng}, // Update current
      });

      // Use previous and current data to update marker
      if (currentLocation != null) {
        _updateAndAnimateDriverMarker(
            lat, lng, currentLocation['lat'], currentLocation['lng']);
      } else {
        _updateAndAnimateDriverMarker(
            lat, lng, lat, lng); // No previous, use current for both
      }
    } else {
      // First time setting the location
      databaseReference.set({
        'driver_id': driverId,
        'ride_id': rideId,
        'driver_location_previous': {'lat': lat, 'lng': lng},
        'driver_location_current': {'lat': lat, 'lng': lng},
      });

      _updateAndAnimateDriverMarker(
          lat, lng, lat, lng); // Use current as both previous and current
    }
    _fetchAndDisplayRequesterLocations();
  }

  void _updateAndAnimateDriverMarker(double currentLat, double currentLng,
      double prevLat, double prevLng) async {
    // Calculate rotation based on previous and current locations
    double rotation = _getRotation(currentLat, currentLng, prevLat, prevLng);

    // Update or create the car marker with rotation
    final Uint8List markerIcon = await getBytesFromAsset(
        'assets/mapView/car.png',
        100); // Make sure you have the correct asset path
    final MarkerId markerId = MarkerId("driver_location");

    final Marker marker = Marker(
      markerId: markerId,
      position: LatLng(currentLat, currentLng),
      icon: BitmapDescriptor.fromBytes(markerIcon),
      rotation: rotation,
      anchor: Offset(0.5, 0.5), // Ensures the icon rotates around its center
    );

    setState(() {
      allMarkers.removeWhere((m) => m.markerId == markerId);
      allMarkers.add(marker);
    });

    // Optionally animate the camera to the driver's new position
    mapController
        ?.animateCamera(CameraUpdate.newLatLng(LatLng(currentLat, currentLng)));
  }

  void _addOrUpdateCarMarker(double lat, double lng, double rotation) async {
    final Uint8List markerIcon = await getBytesFromAsset(
        'assets/car_icon.png', 100); // Ensure this path is correct

    final carMarker = Marker(
      markerId: const MarkerId("driver_location"),
      position: LatLng(lat, lng),
      icon: BitmapDescriptor.fromBytes(markerIcon),
      rotation: rotation,
    );

    setState(() {
      allMarkers.removeWhere(
          (marker) => marker.markerId == const MarkerId("driver_location"));
      allMarkers.add(carMarker);
    });
  }

  double _getRotation(
      double currentLat, double currentLng, double prevLat, double prevLng) {
    var deltaLng = currentLng - prevLng;
    var y = math.sin(deltaLng) * math.cos(currentLat);
    var x = math.cos(prevLat) * math.sin(currentLat) -
        math.sin(prevLat) * math.cos(currentLat) * math.cos(deltaLng);
    var bearing = math.atan2(y, x);
    return (bearing * (180 / math.pi) + 360) % 360; // Normalize to 0-360
  }

  void _fetchAndDisplayRequesterLocations() async {
    print("_fetchAndDisplayRequesterLocations");
    final prefs = await SharedPreferences.getInstance();
    final driverId = prefs.getString('userData') != null
        ? jsonDecode(prefs.getString('userData')!)['id']
        : null;
    final rideId = rideData!['id'];

    if (driverId == null || rideId == null) {
      print("Driver ID or Ride ID is null");
      return;
    }

    String combinedKey = "$driverId-$rideId";
    DatabaseReference databaseReference =
        FirebaseDatabase.instance.ref().child('rides').child(combinedKey);

    DataSnapshot snapshot = await databaseReference.get();

    if (snapshot.exists && snapshot.value != null) {
      final data = Map<String, dynamic>.from(snapshot.value as Map);

      if (data.containsKey('requester_location') &&
          data['requester_location'] is List) {
        List<dynamic> requesterLocations = data['requester_location'];

        setState(() {
          allMarkers.removeWhere(
              (marker) => marker.markerId.value.startsWith("requester_"));
        });

        for (var requesterLocation in requesterLocations) {
          if (requesterLocation is Map) {
            var location = requesterLocation['location'];
            if (location is Map) {
              double lat = location['lat'];
              double lng = location['lng'];
              String userId = requesterLocation['user_id'].toString();

              final requesterMarker = Marker(
                markerId: MarkerId("requester_$userId"),
                position: LatLng(lat, lng),
                icon: BitmapDescriptor.defaultMarkerWithHue(
                    BitmapDescriptor.hueGreen),
              );

              setState(() {
                allMarkers.add(requesterMarker);
              });
            }
          }
        }
      }
    }
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

    print({rideData!['id']});

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
          "Driver Ride Dashboard",
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
            rideActionButton(),
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
            initialChildSize: 0.2,
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

  Widget rideActionButton() {
    return FutureBuilder<String>(
      future:
          getRideStatus(), // Implement this function based on your storage (e.g., SharedPreferences)
      builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return CircularProgressIndicator(); // Show loading indicator while waiting for data
        } else if (snapshot.hasData) {
          final status = snapshot.data!;
          switch (status) {
            case 'open':
            case 'full':
              return buildRideButton(context, "Start Ride", startRide);
            case 'in_progress':
              return buildRideButton(
                  context, "End Ride", endRide); // Implement endRide function
            default:
              return Container(); // Don't show any button for other statuses
          }
        } else {
          return Container(); // Handle error or no data case
        }
      },
    );
  }

  Widget buildRideButton(
      BuildContext context, String buttonText, VoidCallback onPressed) {
    return Align(
      alignment: Alignment.bottomCenter,
      child: Container(
        color:
            whiteColor, // Make sure this color is defined or use Colors.white
        child: GestureDetector(
          onTap: onPressed,
          child: Container(
            height: 50.0,
            width: double.maxFinite,
            margin: const EdgeInsets.all(fixPadding *
                2.0), // Ensure fixPadding is defined or use a fixed value
            padding: const EdgeInsets.symmetric(
                horizontal: fixPadding * 2.0), // Ensure fixPadding is defined
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10.0),
              color:
                  secondaryColor, // Ensure this color is defined or use a specific color
              boxShadow: [
                BoxShadow(
                  color: secondaryColor.withOpacity(0.1), // Adjust as needed
                  blurRadius: 12.0,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            alignment: Alignment.center,
            child: Text(
              buttonText,
              style:
                  semibold18White, // Ensure this style is defined or replace with a TextStyle
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ),
    );
  }

  Future<String> getRideStatus() async {
    return rideData!['status'];
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

  void startRide() async {
    pleaseWaitDialog(context);
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? savedAccessUserToken = prefs.getString('AccessUserToken');
    final rideId = rideData!['id'];

    try {
      var url = Uri.parse('$apiUrl/api/user/rides/$rideId/start');
      var response = await http.post(
        url,
        headers: {
          'Authorization': 'Bearer $savedAccessUserToken',
          'Content-Type': 'application/json',
        },
      );

      final responseData = jsonDecode(response.body);
      print(response.body);
      String message = displayResponse(responseData);
      if (response.statusCode == 200) {
        Navigator.pop(context);

        rideData!['status'] = 'in_progress'; //change status in ridedData

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
        );
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

  Future<void> endRide() async {}

  @override
  void dispose() {
    mapController!.dispose();
    positionStream?.cancel();
    super.dispose();
  }
}

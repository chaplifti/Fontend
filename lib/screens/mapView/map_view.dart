import 'dart:async';
import 'dart:ui' as ui;
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:rc_fl_gopoolar/theme/theme.dart';

class MapViewScreen extends StatefulWidget {
  const MapViewScreen({super.key});

  @override
  State<MapViewScreen> createState() => _MapViewScreenState();
}

class _MapViewScreenState extends State<MapViewScreen> {
  GoogleMapController? mapController;

  static const CameraPosition currentPosition = CameraPosition(
    target: LatLng(22.535524, 88.365300),
    zoom: 12.00,
  );

  List<Marker> allMarkers = [];
  Map<PolylineId, Polyline> polylines = {};

  final points = [
    const LatLng(22.548208, 88.334758),
    const LatLng(22.549476, 88.384917),
    const LatLng(22.573889, 88.408965),
    const LatLng(22.626187, 88.406218),
  ];

  final markerPointList = [
    {
      "image": "assets/mapView/ride-start-icon.png",
      "latLang": const LatLng(22.548208, 88.334758)
    },
    {
      "image": "assets/mapView/destinationicon.png",
      "latLang": const LatLng(22.548476, 88.364917),
    },
    {
      "image": "assets/mapView/ride-start-icon.png",
      "latLang": const LatLng(22.571889, 88.405965),
    },
    {
      "image": "assets/mapView/pickupicon.png",
      "latLang": const LatLng(22.593889, 88.407565),
    },
    {
      "image": "assets/mapView/ride-start-icon.png",
      "latLang": const LatLng(22.626187, 88.406218),
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
                    const Text(
                      "Ride start on 25 june 2023",
                      style: semibold16Black33,
                    ),
                    heightSpace,
                    heightSpace,
                    step("Ride start",
                        "2715 Ash Dr. San Jose, South Dakota 83475"),
                    step("Pick up point (10:00 am)",
                        "2715 Ash Dr. San Jose, South Dakota 83475",
                        isPickDropPoint: true,
                        textColor: greenColor,
                        iconColor: greenColor),
                    step("Drive", "2715 Ash Dr. San Jose, South Dakota 83475"),
                    step("Destination point (11:00 am)",
                        "2715 Ash Dr. San Jose, South Dakota 83475",
                        isPickDropPoint: true, textColor: redColor),
                    step(
                        "Ride end", "2715 Ash Dr. San Jose, South Dakota 83475",
                        isDivider: false),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
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

  static Future<Uint8List> getBytesFromAsset(String path, int width) async {
    ByteData data = await rootBundle.load(path);
    ui.Codec codec = await ui.instantiateImageCodec(data.buffer.asUint8List(),
        targetWidth: width);
    ui.FrameInfo fi = await codec.getNextFrame();
    return (await fi.image.toByteData(format: ui.ImageByteFormat.png))!
        .buffer
        .asUint8List();
  }

  mapCreated(GoogleMapController controller) async {
    mapController = controller;
    await marker();
    await addPolyLine();
    setState(() {});
  }

  marker() async {
    for (int i = 0; i < markerPointList.length; i++) {
      allMarkers.add(
        Marker(
          markerId: MarkerId(i.toString()),
          position: markerPointList[i]['latLang'] as LatLng,
          anchor: const Offset(0.4, 0.5),
          icon: BitmapDescriptor.fromBytes(
            await getBytesFromAsset(markerPointList[i]['image'].toString(), 70),
          ),
        ),
      );
    }
  }

  addPolyLine() {
    PolylineId id = const PolylineId("poly");
    Polyline polyline = Polyline(
      polylineId: id,
      color: primaryColor,
      points: points,
      width: 3,
    );
    polylines[id] = polyline;
    setState(() {});
  }

  @override
  void dispose() {
    mapController!.dispose();
    super.dispose();
  }
}

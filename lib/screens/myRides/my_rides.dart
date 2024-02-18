import 'dart:convert';
import 'dart:io';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:rc_fl_gopoolar/theme/theme.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';

class MyRidesScreen extends StatefulWidget {
  const MyRidesScreen({super.key});

  @override
  State<MyRidesScreen> createState() => _MyRidesScreenState();
}

class _MyRidesScreenState extends State<MyRidesScreen> {
  final ridesList = [
    {
      "image": "assets/myRides/download.jpg",
      "name": "Hemedi Kivuyo",
      "date": "Today",
      "time": "9:00 am",
      "pickup": "Mbagala",
      "destination": "Kariakoo"
    },
    {
      "image": "assets/myRides/download.jpg",
      "name": "Juma Msafiri",
      "date": "22 jan 2023",
      "time": "9:00 am",
      "pickup": "Mbagala",
      "destination": "Mbezi"
    },
    {
      "image": "assets/myRides/download.jpg",
      "name": "Leslie Alexander",
      "date": "23 jan 2023",
      "time": "9:00 am",
      "pickup": "Dar es salaa",
      "destination": "Morogoro"
    },
    {
      "image": "assets/myRides/download.jpg",
      "name": "Pamela Yuston",
      "date": "24 jan 2023",
      "time": "9:00 am",
      "pickup": "Kisesa",
      "destination": "Kilosa"
    },
    {
      "image": "assets/myRides/download.jpg",
      "name": "Mtweve Karanda",
      "date": "25 jan 2023",
      "time": "9:00 am",
      "pickup": "Muheza",
      "destination": "Chalinza"
    },
    {
      "image": "assets/myRides/download.jpg",
      "name": "Elia Mwabukusi",
      "date": "25 jan 2023",
      "time": "9:00 am",
      "pickup": "Chimala",
      "destination": "Chunya"
    },
    {
      "image": "assets/myRides/download.jpg",
      "name": "Rweyemamu Rutashobya",
      "date": "25 jan 2023",
      "time": "9:00 am",
      "pickup": "Kamachumu",
      "destination": "Mleba"
    },
    {
      "image": "assets/myRides/download.jpg",
      "name": "Bhoke Mkandara",
      "date": "25 jan 2023",
      "time": "9:00 am",
      "pickup": "Dodoma",
      "destination": "Singida"
    },
    {
      "image": "assets/myRides/download.jpg",
      "name": "Amina Kilela",
      "date": "25 jan 2023",
      "time": "9:00 am",
      "pickup": "Stesheni",
      "destination": "Mbagala"
    },
  ];

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
        return GestureDetector(
          onTap: () async {
            final results = await Navigator.pushNamed(context, '/rideDetail',
                arguments: {"id": 1});
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
                Container(
                  height: size.width * 0.2,
                  width: size.width * 0.2,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(5.0),
                    image: DecorationImage(
                      image: AssetImage(
                        ridesList[index]['image'].toString(),
                      ),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                widthSpace,
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        ridesList[index]['name'].toString(),
                        style: semibold15Black33,
                        overflow: TextOverflow.ellipsis,
                      ),
                      height5Space,
                      Row(
                        children: [
                          dateTimeWidget(size, Icons.calendar_month_outlined,
                              ridesList[index]['date'].toString()),
                          const Text(
                            " | ",
                            style: medium12Black33,
                          ),
                          dateTimeWidget(size, Icons.access_time,
                              ridesList[index]['time'].toString()),
                        ],
                      ),
                      height5Space,
                      address(
                          greenColor, ridesList[index]['pickup'].toString()),
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
                      address(
                          redColor, ridesList[index]['destination'].toString()),
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
}

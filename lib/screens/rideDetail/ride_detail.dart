import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:rc_fl_gopoolar/theme/theme.dart';
import 'package:rc_fl_gopoolar/widget/column_builder.dart';

class RideDetailScreen extends StatefulWidget {
  const RideDetailScreen({super.key});

  @override
  State<RideDetailScreen> createState() => _RideDetailScreenState();
}

class _RideDetailScreenState extends State<RideDetailScreen> {
  final passengerList = [
    {"image": "assets/rideDetail/passenger-1.png", "name": "Savannah Nguyen"},
    {"image": "assets/rideDetail/passenger-2.png", "name": "Brooklyn Simmons"},
  ];

  final reviewList = [
    {
      "image": "assets/review/download.jpg",
      "name": "Wade Warren",
      "date": "25 jan 2023",
      "rate": "4.8",
      "detail":
          "Lorem ipsum dolor sit amet consectetur. Allaliquam sit mollis adipiscing donec ut sed. Dictum dignissim enim condimentum vitae aliquam sed."
    },
    {
      "image": "assets/review/download.jpg",
      "name": "Jenny wilsom",
      "date": "25 jan 2023",
      "rate": "3.5",
      "detail":
          "Lorem ipsum dolor sit amet consectetur. Allaliquam sit mollis adipiscing donec ut sed. Dictum dignissim enim condimentum vitae aliquam sed."
    },
  ];

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    final data =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>;
    final id = data['id'];
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
          "Ride detail",
          style: semibold18White,
        ),
      ),
      body: ListView(
        physics: const BouncingScrollPhysics(),
        padding: EdgeInsets.zero,
        children: [
          riderDetail(size),
          rideDetail(),
          heightSpace,
          heightSpace,
          passangerDetail(),
          heightSpace,
          heightSpace,
          review(),
          heightSpace,
          heightSpace,
          vehicleInfo()
        ],
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(fixPadding * 2.0),
        child: Row(
          children: [
            id == 0
                ? buttonWidget("Request ride", () {
                    Navigator.pushNamed(context, '/success',
                        arguments: {"id": 0});
                  })
                : cancelButton(),
            widthSpace,
            widthSpace,
            buttonWidget("Message", () {
              Navigator.pushNamed(context, '/messages');
            }),
          ],
        ),
      ),
    );
  }

  cancelButton() {
    return Expanded(
      child: GestureDetector(
        onTap: () {
          cancelDialog();
        },
        child: Container(
          padding: const EdgeInsets.symmetric(
              horizontal: fixPadding, vertical: fixPadding * 1.4),
          decoration: BoxDecoration(
            color: whiteColor,
            borderRadius: BorderRadius.circular(5.0),
            boxShadow: [
              BoxShadow(
                color: blackColor.withOpacity(0.15),
                blurRadius: 6.0,
              )
            ],
          ),
          child: const Text(
            "Cancel ride",
            style: bold18Primary,
            textAlign: TextAlign.center,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ),
    );
  }

  cancelDialog() {
    return showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          clipBehavior: Clip.hardEdge,
          backgroundColor: whiteColor,
          insetPadding: const EdgeInsets.all(fixPadding * 3.0),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Padding(
                padding: EdgeInsets.symmetric(
                    vertical: fixPadding * 2.4, horizontal: fixPadding * 2.0),
                child: Text(
                  "Are you sure you want to cancel your ride?",
                  style: semibold16Black33,
                  textAlign: TextAlign.center,
                ),
              ),
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        Navigator.pop(context);
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: fixPadding, vertical: fixPadding * 1.2),
                        color: secondaryColor,
                        alignment: Alignment.center,
                        child: const Text(
                          "No",
                          style: semibold18White,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                  ),
                  widthBox(2.0),
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.pop(context, "Cancel");
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: fixPadding, vertical: fixPadding * 1.2),
                        color: secondaryColor,
                        alignment: Alignment.center,
                        child: const Text(
                          "yes",
                          style: semibold18White,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                  ),
                ],
              )
            ],
          ),
        );
      },
    );
  }

  buttonWidget(String title, Function() onTap) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(
              horizontal: fixPadding, vertical: fixPadding * 1.4),
          decoration: BoxDecoration(
            color: secondaryColor,
            borderRadius: BorderRadius.circular(5.0),
            boxShadow: [
              BoxShadow(
                color: secondaryColor.withOpacity(0.1),
                blurRadius: 12.0,
                offset: const Offset(0, 6),
              )
            ],
          ),
          child: Text(
            title,
            style: bold18White,
            textAlign: TextAlign.center,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ),
    );
  }

  vehicleInfo() {
    return Container(
      padding: const EdgeInsets.symmetric(
          vertical: fixPadding * 1.5, horizontal: fixPadding * 2.0),
      width: double.maxFinite,
      color: whiteColor,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Vehicle info",
            style: semibold17Secondary,
          ),
          heightSpace,
          height5Space,
          vehicleDetailWidget(
              "Car model", "Toyota Matrix | KJ 5454 | Black colour"),
          heightSpace,
          heightSpace,
          vehicleDetailWidget("Facilities", "AC , Luggage space, Music system")
        ],
      ),
    );
  }

  vehicleDetailWidget(String title, String detail) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: semibold14Grey,
        ),
        Text(
          detail,
          style: medium14Black33,
        )
      ],
    );
  }

  review() {
    return Container(
      padding: const EdgeInsets.symmetric(
          horizontal: fixPadding * 2.0, vertical: fixPadding * 1.5),
      width: double.maxFinite,
      color: whiteColor,
      child: Column(
        children: [
          Row(
            children: [
              const Expanded(
                child: Text(
                  "Review",
                  style: semibold17Secondary,
                ),
              ),
              InkWell(
                onTap: () {
                  Navigator.pushNamed(context, '/review');
                },
                child: const Text(
                  "View all",
                  style: semibold14Primary,
                ),
              )
            ],
          ),
          heightSpace,
          height5Space,
          ColumnBuilder(
            itemBuilder: (context, index) {
              return Column(
                children: [
                  Column(
                    children: [
                      Row(
                        children: [
                          Container(
                            height: 40.0,
                            width: 40.0,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: whiteColor,
                              image: DecorationImage(
                                image: AssetImage(
                                  reviewList[index]['image'].toString(),
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
                                  reviewList[index]['name'].toString(),
                                  style: semibold16Black33,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                Text(
                                  reviewList[index]['date'].toString(),
                                  style: medium14Grey,
                                )
                              ],
                            ),
                          ),
                          widthSpace,
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                reviewList[index]['rate'].toString(),
                                style: semibold16Grey,
                              ),
                              const Icon(
                                Icons.star_rounded,
                                color: secondaryColor,
                                size: 17.0,
                              )
                            ],
                          )
                        ],
                      ),
                      heightSpace,
                      Text(
                        reviewList[index]['detail'].toString(),
                        style: medium14Grey,
                      )
                    ],
                  ),
                  reviewList.length == index + 1
                      ? const SizedBox()
                      : Container(
                          height: 1,
                          width: double.maxFinite,
                          color: greyD4Color,
                          margin: const EdgeInsets.symmetric(
                              vertical: fixPadding * 2.0),
                        )
                ],
              );
            },
            itemCount: reviewList.length,
          )
        ],
      ),
    );
  }

  passangerDetail() {
    return Container(
      width: double.maxFinite,
      color: whiteColor,
      padding: const EdgeInsets.symmetric(vertical: fixPadding * 2.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: fixPadding * 2.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Passenger",
                  style: semibold17Secondary,
                ),
                heightBox(3.0),
                const Text(
                  "2 seat booked(1 male, 1 female)",
                  style: medium16Grey,
                ),
              ],
            ),
          ),
          heightSpace,
          height5Space,
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            padding: EdgeInsets.zero,
            child: Row(
              children: List.generate(
                4,
                (index) => Container(
                  margin:
                      const EdgeInsets.symmetric(horizontal: fixPadding * 2.0),
                  constraints: const BoxConstraints(maxWidth: 60.0),
                  child: Column(
                    children: [
                      passengerList.length > index
                          ? Container(
                              height: 50.0,
                              width: 50.0,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                image: DecorationImage(
                                  image: AssetImage(
                                    passengerList[index]['image'].toString(),
                                  ),
                                  fit: BoxFit.cover,
                                ),
                              ),
                            )
                          : Container(
                              height: 50.0,
                              width: 50.0,
                              decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                                color: d9E3EAColor,
                              ),
                              alignment: Alignment.center,
                              child: const Icon(
                                CupertinoIcons.person_fill,
                                color: whiteColor,
                                size: 35,
                              ),
                            ),
                      height5Space,
                      Text(
                        passengerList.length > index
                            ? passengerList[index]['name'].toString()
                            : "Empty seat",
                        style: medium14Black33,
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      )
                    ],
                  ),
                ),
              ),
            ),
          )
        ],
      ),
    );
  }

  rideDetail() {
    return Container(
      width: double.maxFinite,
      color: whiteColor,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(
                horizontal: fixPadding * 2.0, vertical: fixPadding * 1.5),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Expanded(
                      child: Text(
                        "Rider detail",
                        style: semibold17Secondary,
                      ),
                    ),
                    InkWell(
                      onTap: () {
                        Navigator.pushNamed(context, '/mapView');
                      },
                      child: Text(
                        "Map view",
                        style: semibold14Green.copyWith(
                          color: const Color(0xFF048447),
                          decoration: TextDecoration.underline,
                          decorationColor: const Color(0xFF048447),
                          decorationThickness: 1.5,
                        ),
                      ),
                    )
                  ],
                ),
                heightSpace,
                heightSpace,
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    address(
                      greenColor,
                      '2715 Ash Dr. San Jose, South Dakota 83475',
                    ),
                    Padding(
                      padding:
                          const EdgeInsets.symmetric(horizontal: fixPadding),
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
                      '1901 Thornridge Cir. Shiloh, Hawaii 81063',
                    ),
                  ],
                ),
              ],
            ),
          ),
          DottedBorder(
            padding: EdgeInsets.zero,
            dashPattern: const [2, 4.2],
            color: greyColor,
            child: const SizedBox(
              width: double.maxFinite,
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(
                horizontal: fixPadding * 2.0, vertical: fixPadding * 1.5),
            child: Row(
              children: [
                detailWidget("Start time", "25 June,09 :00AM", 3),
                verticaldivider(),
                detailWidget("Return time", "25 june,09 :00PM", 3),
                verticaldivider(),
                detailWidget("Ride with", "150 people", 2),
              ],
            ),
          ),
        ],
      ),
    );
  }

  verticaldivider() {
    return Container(
      height: 40,
      width: 1,
      color: greyD4Color,
      margin: const EdgeInsets.symmetric(horizontal: fixPadding / 2),
    );
  }

  detailWidget(String title, String detail, int flex) {
    return Expanded(
      flex: flex,
      child: Column(
        children: [
          Text(
            title,
            style: semibold14Black33,
            overflow: TextOverflow.ellipsis,
          ),
          height5Space,
          Text(
            detail,
            style: semibold14Grey,
            overflow: TextOverflow.ellipsis,
          )
        ],
      ),
    );
  }

  address(Color color, String address) {
    return Row(
      children: [
        Container(
          height: 20.0,
          width: 20.0,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: color),
          ),
          alignment: Alignment.center,
          child: Icon(
            Icons.location_pin,
            color: color,
            size: 15.0,
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

  riderDetail(Size size) {
    return Padding(
      padding: const EdgeInsets.all(fixPadding * 2.0),
      child: Row(
        children: [
          Container(
            height: size.width * 0.21,
            width: size.width * 0.21,
            decoration: BoxDecoration(
              color: whiteColor,
              borderRadius: BorderRadius.circular(5.0),
              image: const DecorationImage(
                image: AssetImage("assets/rideDetail/rider-image.png"),
                fit: BoxFit.cover,
              ),
            ),
          ),
          widthSpace,
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Jacob Jones",
                  style: semibold17Black33,
                  overflow: TextOverflow.ellipsis,
                ),
                height5Space,
                Row(
                  children: [
                    Text(
                      "4.8",
                      style: semibold14Grey,
                    ),
                    Icon(
                      Icons.star,
                      color: secondaryColor,
                      size: 15.0,
                    ),
                    Expanded(
                      child: Text(
                        " | 120 review",
                        style: semibold14Grey,
                        overflow: TextOverflow.ellipsis,
                      ),
                    )
                  ],
                ),
                height5Space,
                Text(
                  "Join 2016",
                  style: semibold14Grey,
                )
              ],
            ),
          ),
          widthSpace,
          const Text(
            "\$15.00",
            style: semibold18Primary,
          ),
        ],
      ),
    );
  }
}

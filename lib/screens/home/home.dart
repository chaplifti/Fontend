import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:iconify_flutter/iconify_flutter.dart';
import 'package:iconify_flutter/icons/carbon.dart';
import 'package:intl/intl.dart';
import 'package:rc_fl_gopoolar/theme/theme.dart';
import 'package:rc_fl_gopoolar/widget/column_builder.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String? _firstName;
  String? _lastName;
  String? _phoneNumber;

  @override
  void initState() {
    super.initState();
    _fetchValue();
  }

  Future<void> _fetchValue() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _firstName = prefs.getString('firstName');
      _lastName = prefs.getString('lastName');
      _phoneNumber = prefs.getString('phoneNumber');
    });
  }

  Map<int, Widget> pointsLocations = {};
  int locationCounter = 0;

  String selectedValue = 'Vehicle Type';
  List<String> dropdownItems = [
    'Vehicle Type',
    'Bus',
    'Coaster',
    'SUV',
    'SAV',
    'Saloon'
  ];

  GoogleMapController? mapController;

  TextEditingController dateAndTimeController = TextEditingController();
  TextEditingController noOfSeatController = TextEditingController();

  static const CameraPosition _currentPosition = CameraPosition(
      target: LatLng(-6.886282370427649, 39.27507082065268), zoom: 11);

  final tabList = ["Find ride", "Offer ride"];

  final seatList = ["1", "2", "3", "4", "5", "6", "7", "8"];
  int? selectedSeat;

  int selectedTab = 0;

  String? sourceLocation;
  String? destinationLocation;

  DateTime date = DateTime.now();

  void addNewLocation() {
    setState(() {
      pointsLocations[locationCounter] = pointsLocationAddress(
          context, locationCounter, () => deleteLocation(locationCounter));
      locationCounter++;
    });
  }

  void deleteLocation(int id) {
    setState(() {
      pointsLocations.remove(id);
    });
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: f8Color,
      appBar: AppBar(
        elevation: 0,
        toolbarHeight: 70.0,
        automaticallyImplyLeading: false,
        centerTitle: false,
        backgroundColor: primaryColor,
        titleSpacing: 20.0,
        title: headerTitle(),
        actions: [
          IconButton(
            padding: const EdgeInsets.symmetric(horizontal: fixPadding * 2.0),
            onPressed: () {
              Navigator.pushNamed(context, '/notification');
            },
            icon: const Iconify(
              Carbon.notification,
              color: whiteColor,
              size: 22.0,
            ),
          )
        ],
      ),
      body: Stack(
        children: [
          googleMap(size),
          bottombox(context, size),
        ],
      ),
    );
  }

  Widget bottombox(BuildContext context, Size size) {
    return Align(
      alignment: Alignment.bottomCenter,
      child: Container(
        width: double.maxFinite,
        clipBehavior: Clip.hardEdge,
        margin: const EdgeInsets.only(
            bottom: fixPadding * 3.0,
            left: fixPadding * 2.0,
            right: fixPadding * 2.0),
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
        child: ListView(
          padding: EdgeInsets.zero,
          shrinkWrap: true,
          physics: const BouncingScrollPhysics(),
          children: [
            tabBar(),
            pickupLocation(context),
            heightSpace,
            heightSpace,

            // Conditional rendering based on selectedTab
            if (selectedTab == 1)
              for (var entry in pointsLocations.entries)
                Column(
                  children: [
                    entry.value,
                    heightSpace,
                    heightSpace,
                  ],
                ),

            destinationLocationAddress(context),
            heightSpace,
            heightSpace,
            // ... rest of your code ...
            selectedTab == 0 ? findRideButton() : continueButton()
          ],
        ),
      ),
    );
  }

  continueButton() {
    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(context, '/offerRide');
      },
      child: Container(
        width: double.maxFinite,
        padding: const EdgeInsets.all(fixPadding * 1.4),
        decoration: const BoxDecoration(color: secondaryColor),
        alignment: Alignment.center,
        child: const Text(
          "Continue",
          style: bold18White,
        ),
      ),
    );
  }

  findRideButton() {
    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(context, '/findRide');
      },
      child: Container(
        width: double.maxFinite,
        padding: const EdgeInsets.all(fixPadding * 1.4),
        decoration: const BoxDecoration(color: secondaryColor),
        alignment: Alignment.center,
        child: const Text(
          "Find ride",
          style: bold18White,
        ),
      ),
    );
  }

  noOfSeatField(Size size) {
    return Expanded(
      child: Container(
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
        child: TextField(
          readOnly: true,
          style: semibold15Black33,
          onTap: () {
            noOfSeatBottomsheet(size);
          },
          controller: noOfSeatController,
          decoration: const InputDecoration(
            border: InputBorder.none,
            prefixIconConstraints: BoxConstraints(minWidth: 38.0),
            prefixIcon: Icon(
              CupertinoIcons.person,
              size: 18.0,
              color: greyColor,
            ),
            hintText: "No. of seat",
            hintStyle: semibold15Grey,
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
                              selectedSeat = index;
                              noOfSeatController.text =
                                  "${seatList[selectedSeat!]} Seat";
                            });
                            Navigator.pop(context);
                          },
                          title: Text(
                            "${seatList[index]} Seat",
                            style: selectedSeat == index
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

  dateAndTimeField(Size size) {
    return Expanded(
      child: Container(
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
        child: TextField(
          readOnly: true,
          style: semibold15Black33,
          onTap: () {
            dateAndTimeBottomsheet(size);
          },
          controller: dateAndTimeController,
          decoration: const InputDecoration(
            border: InputBorder.none,
            prefixIconConstraints: BoxConstraints(minWidth: 38.0),
            prefixIcon: Icon(
              Icons.calendar_month_outlined,
              size: 18.0,
              color: greyColor,
            ),
            hintText: "Date & time",
            hintStyle: semibold15Grey,
          ),
        ),
      ),
    );
  }

  dateAndTimeBottomsheet(Size size) {
    return showModalBottomSheet(
      isScrollControlled: true,
      constraints: BoxConstraints(maxHeight: size.height - 80),
      backgroundColor: whiteColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(40.0)),
      ),
      context: context,
      builder: (context) {
        DateTime dateValue = date;
        var hour = DateFormat('h').format(DateTime.now());
        var minute = DateFormat('m').format(DateTime.now());
        var marker = DateFormat('a').format(DateTime.now());
        String selectedHour = hour;
        String selectedMinute = minute;
        String selectedMarker = marker;
        PageController hourController =
            PageController(initialPage: int.parse(hour));
        PageController minuteController =
            PageController(initialPage: int.parse(minute));
        PageController markerController =
            PageController(initialPage: marker == "AM" ? 0 : 1);
        final markerList = ["AM", "PM"];
        return StatefulBuilder(
          builder: (context, state) {
            return ListView(
              shrinkWrap: true,
              padding: EdgeInsets.zero,
              physics: const BouncingScrollPhysics(),
              children: [
                const Padding(
                  padding: EdgeInsets.all(fixPadding * 2.0),
                  child: Text(
                    "Select date & time",
                    style: semibold16Primary,
                    textAlign: TextAlign.center,
                  ),
                ),
                SizedBox(
                  height: 280,
                  child: Theme(
                    data: Theme.of(context).copyWith(
                      colorScheme:
                          const ColorScheme.light(primary: secondaryColor),
                      datePickerTheme: DatePickerThemeData(
                        dayStyle: semibold15White.copyWith(
                            color: const Color(0xFF4A5660)),
                      ),
                    ),
                    child: CalendarDatePicker(
                      initialDate: date,
                      firstDate: DateTime.now(),
                      currentDate: DateTime.now(),
                      lastDate: DateTime.now().add(const Duration(days: 36500)),
                      onDateChanged: (datetime) {
                        state(() {
                          setState(() {
                            dateValue = datetime;
                          });
                        });
                      },
                    ),
                  ),
                ),
                heightSpace,
                dottedDivder(),
                Padding(
                  padding: const EdgeInsets.all(fixPadding * 2.0),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              children: [
                                upButton(() {
                                  state(() {
                                    selectedHour == "00"
                                        ? hourController.jumpToPage(0)
                                        : hourController.previousPage(
                                            duration: const Duration(
                                                microseconds: 10),
                                            curve: Curves.ease);
                                  });
                                }),
                                Container(
                                  height: 50,
                                  decoration: timerBoxDecoration,
                                  alignment: Alignment.center,
                                  child: PageView.builder(
                                    itemCount: 13,
                                    scrollDirection: Axis.vertical,
                                    onPageChanged: (index) {
                                      state(() {
                                        index < 10
                                            ? setState(() {
                                                selectedHour = "0$index";
                                              })
                                            : setState(() {
                                                selectedHour = index.toString();
                                              });
                                      });
                                    },
                                    controller: hourController,
                                    itemBuilder: (context, index) {
                                      return SizedBox(
                                        height: 43,
                                        child: Center(
                                          child: Text(
                                            index < 10
                                                ? "0$index"
                                                : index.toString(),
                                            style: semibold18Primary,
                                            textAlign: TextAlign.center,
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                                downButton(() {
                                  state(() {
                                    selectedHour == "12"
                                        ? hourController.jumpToPage(0)
                                        : hourController.nextPage(
                                            duration: const Duration(
                                                milliseconds: 10),
                                            curve: Curves.ease);
                                  });
                                }),
                              ],
                            ),
                          ),
                          widthSpace,
                          const Text(
                            ":",
                            style: semibold28Black33,
                          ),
                          widthSpace,
                          Expanded(
                            child: Column(
                              children: [
                                upButton(() {
                                  state(() {
                                    selectedMinute == "00"
                                        ? minuteController.jumpToPage(59)
                                        : minuteController.previousPage(
                                            duration: const Duration(
                                                microseconds: 10),
                                            curve: Curves.ease);
                                  });
                                }),
                                Container(
                                  height: 50.0,
                                  decoration: timerBoxDecoration,
                                  alignment: Alignment.center,
                                  child: PageView.builder(
                                    itemCount: 60,
                                    scrollDirection: Axis.vertical,
                                    onPageChanged: (index) {
                                      state(() {
                                        index < 10
                                            ? setState(() {
                                                selectedMinute = "0$index";
                                              })
                                            : setState(() {
                                                selectedMinute =
                                                    index.toString();
                                              });
                                      });
                                    },
                                    controller: minuteController,
                                    itemBuilder: (context, index) {
                                      return SizedBox(
                                        height: 43,
                                        child: Center(
                                          child: Text(
                                            index < 10
                                                ? "0$index"
                                                : index.toString(),
                                            style: semibold18Primary,
                                            textAlign: TextAlign.center,
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                                downButton(() {
                                  state(() {
                                    selectedMinute == "59"
                                        ? minuteController.jumpToPage(0)
                                        : minuteController.nextPage(
                                            duration: const Duration(
                                                microseconds: 10),
                                            curve: Curves.ease);
                                  });
                                }),
                              ],
                            ),
                          ),
                          widthSpace,
                          widthSpace,
                          Expanded(
                            child: Column(
                              children: [
                                selectedMarker == "AM"
                                    ? iconPlaceHolder()
                                    : upButton(() {
                                        state(() {
                                          markerController.previousPage(
                                              duration: const Duration(
                                                  microseconds: 10),
                                              curve: Curves.ease);
                                        });
                                      }),
                                Container(
                                  height: 50.0,
                                  decoration: timerBoxDecoration,
                                  alignment: Alignment.center,
                                  child: PageView.builder(
                                    itemCount: markerList.length,
                                    scrollDirection: Axis.vertical,
                                    onPageChanged: (index) {
                                      state(() {
                                        setState(() {
                                          selectedMarker = markerList[index];
                                        });
                                      });
                                    },
                                    controller: markerController,
                                    itemBuilder: (context, index) {
                                      return SizedBox(
                                        height: 43,
                                        child: Center(
                                          child: Text(
                                            markerList[index].toString(),
                                            style: semibold18Primary,
                                            textAlign: TextAlign.center,
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                                selectedMarker == "PM"
                                    ? iconPlaceHolder()
                                    : downButton(() {
                                        state(() {
                                          markerController.nextPage(
                                              duration: const Duration(
                                                  microseconds: 10),
                                              curve: Curves.ease);
                                        });
                                      }),
                              ],
                            ),
                          ),
                        ],
                      ),
                      heightSpace,
                      heightSpace,
                      okayButton(context, dateValue, selectedHour,
                          selectedMinute, selectedMarker),
                    ],
                  ),
                )
              ],
            );
          },
        );
      },
    );
  }

  iconPlaceHolder() {
    return const IconButton(
        onPressed: null,
        icon: Icon(
          Icons.keyboard_arrow_up_outlined,
          color: Colors.transparent,
        ));
  }

  okayButton(BuildContext context, DateTime dateValue, String selectedHour,
      String selectedMinute, String selectedMarker) {
    return GestureDetector(
      onTap: () {
        Navigator.pop(context);
        setState(() {
          dateAndTimeController.text =
              "${DateFormat('dd MMMM').format(dateValue)},$selectedHour:$selectedMinute$selectedMarker";

          date = dateValue;
        });
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
          "Okay",
          style: bold18White,
        ),
      ),
    );
  }

  dottedDivder() {
    return DottedBorder(
      padding: EdgeInsets.zero,
      color: greyColor,
      dashPattern: const [2, 5],
      child: const SizedBox(
        width: double.maxFinite,
      ),
    );
  }

  downButton(Function() onTap) {
    return IconButton(
      onPressed: onTap,
      icon: const Icon(
        Icons.keyboard_arrow_down,
        color: greyColor,
      ),
    );
  }

  upButton(Function() onTap) {
    return IconButton(
      onPressed: onTap,
      icon: const Icon(
        Icons.keyboard_arrow_up,
        color: greyColor,
      ),
    );
  }

  destinationLocationAddress(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        final result = await Navigator.pushNamed(context, '/pickLocation');
        if (result != null) {
          setState(() {
            destinationLocation = result.toString();
          });
        }
      },
      child: Container(
        padding: const EdgeInsets.all(fixPadding * 1.4),
        margin: const EdgeInsets.symmetric(horizontal: fixPadding * 2.0),
        decoration: BoxDecoration(
            color: whiteColor,
            borderRadius: BorderRadius.circular(8.0),
            boxShadow: [
              BoxShadow(
                color: blackColor.withOpacity(0.15),
                blurRadius: 6.0,
              )
            ]),
        child: Row(
          children: [
            locationIcon(redColor),
            widthSpace,
            width5Space,
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Destination location",
                    style: semibold15Black33,
                    overflow: TextOverflow.ellipsis,
                  ),
                  height5Space,
                  Text(
                    destinationLocation != null
                        ? destinationLocation.toString()
                        : "Select location",
                    style: medium14Grey,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  pointsLocationAddress(
      BuildContext context, int locationCounter, void Function() param2) {
    return GestureDetector(
      onTap: () async {
        final result = await Navigator.pushNamed(context, '/pickLocation');
        if (result != null) {
          setState(() {
            destinationLocation = result.toString();
          });
        }
      },
      child: Container(
        padding: const EdgeInsets.all(fixPadding * 1.4),
        margin: const EdgeInsets.symmetric(horizontal: fixPadding * 2.0),
        decoration: BoxDecoration(
            color: whiteColor,
            borderRadius: BorderRadius.circular(8.0),
            boxShadow: [
              BoxShadow(
                color: blackColor.withOpacity(0.15),
                blurRadius: 6.0,
              )
            ]),
        child: Row(
          children: [
            locationIcon(black3CColor),
            widthSpace,
            width5Space,
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Point location",
                    style: semibold15Black33,
                    overflow: TextOverflow.ellipsis,
                  ),
                  height5Space,
                  Text(
                    destinationLocation != null
                        ? destinationLocation.toString()
                        : "Select location",
                    style: medium14Grey,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.5),
                    spreadRadius: 2,
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: IconButton(
                icon: const Icon(Icons.delete, color: Colors.black),
                onPressed: () => deleteLocation(locationCounter),
                iconSize: 24.0,
                splashRadius: 20.0,
                splashColor: Colors.grey.withOpacity(0.5),
                padding: const EdgeInsets.all(8.0),
                constraints: const BoxConstraints(),
              ),
            )
          ],
        ),
      ),
    );
  }

  pickupLocation(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        final result = await Navigator.pushNamed(context, '/pickLocation');
        if (result != null) {
          setState(() {
            sourceLocation = result.toString();
          });
        }
      },
      child: Container(
        padding: const EdgeInsets.all(fixPadding * 1.4),
        margin: const EdgeInsets.symmetric(horizontal: fixPadding * 2.0),
        decoration: BoxDecoration(
            color: whiteColor,
            borderRadius: BorderRadius.circular(8.0),
            boxShadow: [
              BoxShadow(
                color: blackColor.withOpacity(0.15),
                blurRadius: 6.0,
              )
            ]),
        child: Row(
          children: [
            locationIcon(greenColor),
            widthSpace,
            width5Space,
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Pick up location",
                    style: semibold15Black33,
                    overflow: TextOverflow.ellipsis,
                  ),
                  height5Space,
                  Text(
                    sourceLocation != null
                        ? sourceLocation.toString()
                        : "Select location",
                    style: medium14Grey,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            selectedTab == 0 ? widthBox(fixPadding * 1.5) : const SizedBox(),
            selectedTab == 1
                ? Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.5),
                          spreadRadius: 2,
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.add, color: Colors.black),
                      onPressed: () {
                        addNewLocation();
                      },
                      iconSize: 24.0,
                      splashRadius: 20.0,
                      splashColor: Colors.grey.withOpacity(0.5),
                      padding: const EdgeInsets.all(8.0),
                      constraints: const BoxConstraints(),
                    ),
                  )
                : const SizedBox(),
          ],
        ),
      ),
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

  // tabBar() {
  //   return Container(
  //     margin: const EdgeInsets.fromLTRB(
  //         fixPadding * 2.0, fixPadding, fixPadding * 2.0, fixPadding * 2.0),
  //     clipBehavior: Clip.hardEdge,
  //     decoration: BoxDecoration(
  //       color: f8Color,
  //       borderRadius: BorderRadius.circular(10.0),
  //       boxShadow: [
  //         BoxShadow(
  //           color: blackColor.withOpacity(0.15),
  //           blurRadius: 6.0,
  //         ),
  //       ],
  //     ),
  //     child: Row(
  //       children: List.generate(
  //         tabList.length,
  //         (index) => Expanded(
  //           child: GestureDetector(
  //             onTap: () {
  //               setState(() {
  //                 selectedTab = index;
  //               });
  //             },
  //             child: Container(
  //               padding: const EdgeInsets.symmetric(
  //                   vertical: fixPadding * 1.3, horizontal: fixPadding),
  //               color: selectedTab == index ? secondaryColor : f8Color,
  //               alignment: Alignment.center,
  //               child: Text(
  //                 tabList[index].toString(),
  //                 style:
  //                     selectedTab == index ? semibold15White : semibold15Grey,
  //               ),
  //             ),
  //           ),
  //         ),
  //       ),
  //     ),
  //   );
  // }

  Widget tabBar() {
    return Container(
      margin: const EdgeInsets.fromLTRB(
          fixPadding * 2.0, fixPadding, fixPadding * 2.0, fixPadding * 2.0),
      clipBehavior: Clip.hardEdge,
      decoration: BoxDecoration(
        color: screenBgColor, // Set the background color to transparent
        borderRadius: BorderRadius.circular(10.0),
        boxShadow: [
          BoxShadow(
            color: blackColor.withOpacity(0.15),
            blurRadius: 6.0,
            spreadRadius: 1.0,
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment:
            MainAxisAlignment.spaceEvenly, // Distributes the children evenly
        children: List.generate(
          tabList.length * 2 - 1, // Adjust the number for the SizedBox
          (index) {
            if (index % 2 == 1) {
              return const SizedBox(width: 10); // Spacing between buttons
            }
            int tabIndex = index ~/ 2;
            return Expanded(
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    selectedTab = tabIndex;
                  });
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                  padding: const EdgeInsets.symmetric(
                      vertical: fixPadding * 1.3, horizontal: fixPadding),
                  decoration: BoxDecoration(
                    color: selectedTab == tabIndex ? secondaryColor : f8Color,
                    borderRadius: BorderRadius.circular(10.0),
                    border: selectedTab == tabIndex
                        ? Border.all(color: Colors.transparent)
                        : Border.all(color: greyBorderColor),
                    gradient: selectedTab == tabIndex
                        ? const LinearGradient(
                            colors: [gradientStartColor, gradientEndColor],
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                          )
                        : null,
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    tabList[tabIndex].toString(),
                    style: selectedTab == tabIndex
                        ? semibold15White
                        : semibold15Grey,
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  googleMap(Size size) {
    return SizedBox(
      height: double.maxFinite,
      width: size.width,
      child: GoogleMap(
        mapType: MapType.normal,
        initialCameraPosition: _currentPosition,
        onMapCreated: mapCreated,
        zoomControlsEnabled: false,
      ),
    );
  }

  mapCreated(GoogleMapController controller) async {
    mapController = controller;
  }

  headerTitle() {
    return Row(
      children: [
        Container(
          height: 45.0,
          width: 45.0,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            image: DecorationImage(
              image: AssetImage(
                "assets/home/userImage.png",
              ),
            ),
          ),
        ),
        widthSpace,
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    _firstName ?? 'No value found',
                    style: semibold16White,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(
                    width: 5,
                  ),
                  Text(
                    _lastName ?? 'No value found',
                    style: semibold16White,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
              heightBox(2.0),
              Row(
                children: [
                  const Iconify(
                    Carbon.phone,
                    color: whiteColor,
                    size: 14.0,
                  ),
                  width5Space,
                  Expanded(
                    child: Text(
                      _phoneNumber ?? 'No value found',
                      style: medium14White,
                      overflow: TextOverflow.ellipsis,
                    ),
                  )
                ],
              )
            ],
          ),
        )
      ],
    );
  }

  var timerBoxDecoration = BoxDecoration(
    color: whiteColor,
    borderRadius: BorderRadius.circular(5.0),
    boxShadow: [
      BoxShadow(
        color: blackColor.withOpacity(0.2),
        blurRadius: 6.0,
      )
    ],
  );
}

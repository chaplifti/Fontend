import 'dart:convert';

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:rc_fl_gopoolar/theme/theme.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MessagesScreen extends StatefulWidget {
  late int userID;
  late String fullName;

  MessagesScreen({Key? key, required this.userID, required this.fullName})
      : super(key: key);

  @override
  State<MessagesScreen> createState() => _MessagesScreenState();
}

// Messages List model class
class ListMessages {
  final String senderName;
  final String body;
  final String createdAt;

  ListMessages({
    required this.senderName,
    required this.body,
    required this.createdAt,
  });

  // Factory constructor to create a Message instance from a JSON map
  factory ListMessages.fromJson(Map<String, dynamic> json) {
    return ListMessages(
      senderName: json['sender_name'],
      body: json['body'],
      createdAt: json['created_at'],
    );
  }

  // Method to convert a Message instance to a JSON map
  Map<String, dynamic> toJson() {
    return {
      'sender_name': senderName,
      'body': body,
      'created_at': createdAt,
    };
  }
}

class _MessagesScreenState extends State<MessagesScreen> {
  TextEditingController messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  List<ListMessages> messagesList = [];
  String? firstName;
  String? lastName;
  String? username;

  // Future<void> fetchChatsList() async {
  //   final SharedPreferences prefs = await SharedPreferences.getInstance();
  //   final String? savedAccessUserToken = prefs.getString('AccessUserToken');
  //
  //   final response = await http.get(
  //     Uri.parse('$apiUrl/api/user/messages/view/${widget.userID}'),
  //     headers: {
  //       'Authorization': 'Bearer $savedAccessUserToken',
  //       'Content-Type': 'application/json',
  //     },
  //   );
  //
  //   if (response.statusCode == 200) {
  //     final List<dynamic> jsonResponse = jsonDecode(response.body);
  //     List<ListMessages> tempList =
  //         []; // Temporary list to store the converted messages
  //     for (var item in jsonResponse) {
  //       tempList.add(ListMessages.fromJson(item));
  //     }
  //     setState(() {
  //       messagesList = tempList; // Update messagesList with the converted list
  //     });
  //   } else {
  //     print('Failed to fetch chats list');
  //   }
  // }

  /*Future<void> fetchChatsList() async {
    final DatabaseReference messagesRef =
        FirebaseDatabase.instance.ref('messages/${widget.userID}');
    messagesRef.onValue.listen((DatabaseEvent event) {
      final data = event.snapshot.value as Map<dynamic, dynamic>?;
      List<ListMessages> tempList = [];
      data?.forEach((key, value) {
        tempList.add(ListMessages.fromJson(Map<String, dynamic>.from(value)));
      });
      setState(() {
        messagesList = tempList;
      });
    }, onError: (error) {
      // Handle error
      print(error);
    });
  }*/
  Future<void> fetchChatsList() async {
    final DatabaseReference messagesRef =
        FirebaseDatabase.instance.ref('messages/${widget.userID}');
    messagesRef.onValue.listen((DatabaseEvent event) {
      final data = event.snapshot.value as Map<dynamic, dynamic>?;
      List<ListMessages> tempList = [];
      data?.forEach((key, value) {
        tempList.add(ListMessages.fromJson(Map<String, dynamic>.from(value)));
      });
      tempList.sort((a, b) =>
          a.createdAt.compareTo(b.createdAt)); // Sort the messages by createdAt
      setState(() {
        messagesList = tempList; // Now messagesList is sorted
      });
    }, onError: (error) {
      // Handle error
      print(error);
    });
  }

  Future<void> _fetchValue() async {
    final prefs = await SharedPreferences.getInstance();
    final String? userDataString = prefs.getString('userData');

    if (userDataString != null) {
      final Map<String, dynamic> userData = jsonDecode(userDataString);
      String firstName = userData['first_name'];
      String spacer = " ";
      String lastName = userData['last_name'];

      String username = firstName + spacer + lastName;

      print("---------$username-------------");

      setState(() {
        this.firstName = firstName;
        this.lastName = lastName;
        this.username = username;
      });
    }
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  void initState() {
    super.initState();
    _fetchValue();
    fetchChatsList();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
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
          padding:
              const EdgeInsets.only(left: fixPadding * 2.0, right: fixPadding),
          onPressed: () {
            Navigator.pop(context);
          },
          icon: const Icon(
            Icons.arrow_back_ios,
            color: whiteColor,
          ),
        ),
        leadingWidth: 50.0,
        title: title(),
      ),
      body: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: Expanded(
          child: ListView.builder(
            shrinkWrap: true,
            //reverse: true,
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(
                vertical: fixPadding, horizontal: fixPadding * 2.0),
            itemCount: messagesList.length,
            itemBuilder: (context, index) {
              // Note: Since we're reversing the list view,
              // you don't need to calculate the reverseIndex anymore.
              // The newest message is at the 0th index now.
              bool isCurrentUser = messagesList[index].senderName == username;
              return isCurrentUser
                  ? sendMessages(size, index)
                  : receiveMessages(size, index);
            },
          ),
        ),
      ),
      /*ListView.builder(
        shrinkWrap: true,
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(
            vertical: fixPadding, horizontal: fixPadding * 2.0),
        itemCount: messagesList.length,
        //reverse: true,
        itemBuilder: (context, index) {
          int reverseIndex = messagesList.length - index - 1;
          bool isCurrentUser = messagesList[index].senderName == username;
          return isCurrentUser
              ? sendMessages(size, index)
              : receiveMessages(size, index);
        },
      ),*/
      bottomNavigationBar: Padding(
        padding:
            EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        child: Container(
          padding: const EdgeInsets.only(
              left: fixPadding * 2.0,
              right: fixPadding * 2.0,
              bottom: fixPadding * 2.0),
          child: Row(
            children: [
              messageField(),
              widthSpace,
              sendButton(),
            ],
          ),
        ),
      ),
    );
  }

  messageField() {
    return Expanded(
      child: Container(
        height: 50.0,
        width: double.maxFinite,
        decoration: BoxDecoration(
          color: whiteColor,
          borderRadius: BorderRadius.circular(10.0),
          border: Border.all(color: secondaryColor),
          boxShadow: [
            BoxShadow(
              color: secondaryColor.withOpacity(0.1),
              blurRadius: 12.0,
              offset: const Offset(0, 6),
            )
          ],
        ),
        alignment: Alignment.center,
        child: TextField(
          controller: messageController, // Ensure this is correctly referenced
          style: medium14Black33, // Assuming this is a predefined style
          cursorColor: primaryColor, // Assuming this is a predefined color
          decoration: const InputDecoration(
            border: InputBorder.none,
            hintText: "Type your message here..",
            hintStyle: medium14Grey, // Assuming this is a predefined style
            contentPadding: EdgeInsets.symmetric(
                horizontal:
                    fixPadding), // Ensure fixPadding is correctly defined
          ),
        ),
      ),
    );
  }

  // Future<void> sendMessage() async {
  //   final SharedPreferences prefs = await SharedPreferences.getInstance();
  //   final String? savedAccessUserToken = prefs.getString('AccessUserToken');
  //   final int userId = widget.userID; // Assuming this is the user ID
  //   final String messageText = messageController.text;
  //
  //   if (messageText.isEmpty) {
  //     print(messageController.text);
  //     print("Message text is empty");
  //     return;
  //   }
  //
  //   final uri = Uri.parse('$apiUrl/api/user/messages/send');
  //   final response = await http.post(
  //     uri,
  //     headers: {
  //       'Authorization': 'Bearer $savedAccessUserToken',
  //       'Content-Type': 'application/json',
  //     },
  //     body: jsonEncode({
  //       'recipient_id': userId,
  //       'body': messageText,
  //     }),
  //   );
  //
  //   if (response.statusCode == 200) {
  //     print("Message sent successfully");
  //     messageController.clear();
  //   } else {
  //     print("Failed to send message: ${response.body}");
  //     messageController.clear();
  //   }
  // }
  Future<void> sendMessage() async {
    final DatabaseReference messagesRef =
        FirebaseDatabase.instance.ref('messages/${widget.userID}');
    final messageText = messageController.text;

    if (messageText.isEmpty) {
      print("Message text is empty");
      return;
    }

    final newMessageRef = messagesRef.push();
    await newMessageRef.set({
      'recipient_id': widget.userID,
      'body': messageText,
      'sender_name': username, // Assuming you have a username variable
      'created_at': DateTime.now().toIso8601String(),
    });

    messageController.clear();
  }

  sendButton() {
    return InkWell(
      onTap: () async {
        print("Attempting to send message: ${messageController.text}");
        if (messageController.text.isNotEmpty) {
          await sendMessage();
          fetchChatsList();
          messageController.clear();
        }
      },

      // onTap: () async {
      //   if (messageController.text.isNotEmpty) {
      //     await sendMessage();
      //     setState(() {
      //       // messagesList.add({
      //       //   "message": messageController.text,
      //       //   "time": DateFormat.jm().format(DateTime.now()),
      //       //   "isMe": true
      //       // });
      //       fetchChatsList();
      //     });
      //   }
      // },
      child: Container(
        height: 50.0,
        width: 50.0,
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
        child: const Icon(
          Icons.send,
          color: whiteColor,
        ),
      ),
    );
  }

  sendMessages(Size size, int index) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Container(
          margin: EdgeInsets.only(
              top: fixPadding, bottom: fixPadding, left: size.width * 0.2),
          padding: const EdgeInsets.symmetric(
              horizontal: fixPadding * 1.5, vertical: fixPadding),
          decoration: const BoxDecoration(
            color: Color(0xFFFFEED2),
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(fixPadding),
              topRight: Radius.circular(fixPadding),
              bottomLeft: Radius.circular(fixPadding),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                messagesList[index].body.toString(),
                style: medium14Black33,
              ),
              Text(
                messagesList[index].senderName.toString(),
                style: medium14Black33,
              ),
              height5Space,
              Text(
                messagesList[index].createdAt.toString(),
                style: medium12Grey,
              )
            ],
          ),
        ),
      ],
    );
  }

  receiveMessages(Size size, int index) {
    return Padding(
      padding: EdgeInsets.only(
          top: fixPadding, bottom: fixPadding, right: size.width * 0.2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 30.0,
            width: 30.0,
            decoration: const BoxDecoration(
                shape: BoxShape.circle,
                image: DecorationImage(
                    image: AssetImage("assets/findRide/rider-2.png"))),
          ),
          width5Space,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: fixPadding * 1.5, vertical: fixPadding),
                  decoration: const BoxDecoration(
                    color: whiteColor,
                    borderRadius: BorderRadius.only(
                      bottomRight: Radius.circular(fixPadding),
                      topRight: Radius.circular(fixPadding),
                      bottomLeft: Radius.circular(fixPadding),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        messagesList[index].body.toString(),
                        style: medium14Black33,
                      ),
                      Text(
                        messagesList[index].senderName.toString(),
                        style: medium14Black33,
                      ),
                      height5Space,
                      Text(
                        messagesList[index].createdAt.toString(),
                        style: medium12Grey,
                      )
                    ],
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  title() {
    return Row(
      children: [
        Container(
          height: 39.0,
          width: 39.0,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            image: DecorationImage(
              image: AssetImage("assets/findRide/rider-2.png"),
            ),
          ),
        ),
        widthSpace,
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.fullName,
                // "Jenny Wilson",
                style: semibold16White,
                overflow: TextOverflow.ellipsis,
              ),
              // const Text(
              //   "Ride on 25 june 2023",
              //   style: medium12White,
              //   overflow: TextOverflow.ellipsis,
              // )
            ],
          ),
        ),
      ],
    );
  }
}

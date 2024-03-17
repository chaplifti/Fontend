import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:rc_fl_gopoolar/constants/key.dart';
import 'package:rc_fl_gopoolar/screens/messages/messages.dart';
import 'package:rc_fl_gopoolar/theme/theme.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Chat model class
class Chat {
  final int chatWithId;
  final String chatWithName;
  final String lastMessage;
  final String lastMessageTime;

  Chat({
    required this.chatWithId,
    required this.chatWithName,
    required this.lastMessage,
    required this.lastMessageTime,
  });

  factory Chat.fromJson(Map<String, dynamic> json) {
    return Chat(
      chatWithId: json['chat_with_id'],
      chatWithName: json['chat_with_name'],
      lastMessage: json['last_message'],
      lastMessageTime: json['last_message_time'],
    );
  }
}

class ChatsList extends StatefulWidget {
  const ChatsList({super.key});

  @override
  State<ChatsList> createState() => _ChatsListState();
}

class _ChatsListState extends State<ChatsList> {
  List<Chat> chatsList = [];

  Future<void> fetchChatsList() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? savedAccessUserToken = prefs.getString('AccessUserToken');

    final response = await http.get(
      Uri.parse('$apiUrl/api/user/messages/chats'),
      headers: {
        'Authorization': 'Bearer $savedAccessUserToken',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final List<dynamic> jsonResponse = jsonDecode(response.body);
      setState(() {
        chatsList = jsonResponse.map((data) => Chat.fromJson(data)).toList();
      });
    } else {
      print('Failed to fetch chats list');
    }
  }

  @override
  void initState() {
    super.initState();
    fetchChatsList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: f8Color,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: primaryColor,
        automaticallyImplyLeading: false,
        centerTitle: true,
        titleSpacing: 20.0,
        leading: IconButton(
          onPressed: () {
            Navigator.pushNamed(context, '/bottomBar');
          },
          icon: const Icon(
            Icons.arrow_back_ios_new,
            color: Colors.white,
          ),
        ),
        title: const Text(
          "Chats History",
          style: semibold18White,
        ),
      ),
      body: ListView.builder(
        itemCount: chatsList.length,
        itemBuilder: (context, index) {
          final chat = chatsList[index];
          return Column(
            children: [
              ListTile(
                onTap: () {
                  Navigator.of(context).push(MaterialPageRoute(
                    builder: (_) => MessagesScreen(
                        userID: chat.chatWithId, fullName: chat.chatWithName),
                  ));
                },
                title: Text(
                  chat.chatWithName,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                subtitle: Text(
                  chat.lastMessage,
                ),
                trailing: Text(
                  chat.lastMessageTime,
                  style: const TextStyle(),
                ),
              ),
              divider(),
            ],
          );
        },
      ),
    );
  }

  divider() {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: fixPadding * 1.8),
      width: double.maxFinite,
      height: 1.0,
      color: greyD4Color,
    );
  }
}

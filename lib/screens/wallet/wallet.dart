import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:iconify_flutter/iconify_flutter.dart';
import 'package:iconify_flutter/icons/mdi.dart';
import 'package:intl/intl.dart';
import 'package:rc_fl_gopoolar/constants/key.dart';
import 'package:rc_fl_gopoolar/theme/theme.dart';
import 'package:shared_preferences/shared_preferences.dart';

class WalletScreen extends StatefulWidget {
  const WalletScreen({super.key});
  @override
  State<WalletScreen> createState() => _WalletScreenState();
}

class _WalletScreenState extends State<WalletScreen> {
  bool _isTextVisible = false;
  String _balance = "*****";
  bool _isLoading = false;

  Future<void> _fetchBalance() async {
    setState(() {
      _isLoading = true; // Start loading
    });
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? savedAccessUserToken = prefs.getString('AccessUserToken');
    var uri = Uri.parse('$apiUrl/api/user/wallet/total-balance');
    var headers = {
      'Authorization': 'Bearer $savedAccessUserToken',
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
    var response = await http.get(uri, headers: headers);
    if (response.statusCode == 200) {
      var data = jsonDecode(response.body);
      // Check if the total_balance is not null and is a number or string that can be parsed
      print(data['total_balance']);
      double balance = 0;
      if (data['total_balance'] != null) {
        balance = double.tryParse(data['total_balance'].toString()) ?? 0;
      }
      final NumberFormat formatter = NumberFormat("#,##0.00", "en_US");
      String formattedBalance = formatter.format(balance);
      String fetchedBalance = "TZS $formattedBalance";
      setState(() {
        _balance = fetchedBalance;
        _isLoading = false;
      });
    } else {
      print('Failed to fetch balance');
      setState(() {
        _isLoading = false; // Stop loading
      });
    }
  }

  // Future<void> _fetchBalance() async {
  //   final SharedPreferences prefs = await SharedPreferences.getInstance();
  //   final String? savedAccessUserToken = prefs.getString('AccessUserToken');
  //   var uri = Uri.parse('$apiUrl/api/user/wallet/total-balance');
  //   var headers = {
  //     'Authorization': 'Bearer $savedAccessUserToken',
  //     'Content-Type': 'application/json',
  //     'Accept': 'application/json',
  //   };
  //   var response = await http.get(uri, headers: headers);
  //   if (response.statusCode == 200) {
  //     var data = jsonDecode(response.body);
  //     // Check if the total_balance is not null and is a number or string that can be parsed
  //     double balance = 0;
  //     if (data['total_balance'] != null) {
  //       balance = double.tryParse(data['total_balance'].toString()) ?? 0;
  //     }
  //     final NumberFormat formatter = NumberFormat("#,##0.00", "en_US");
  //     String formattedBalance = formatter.format(balance);
  //     String fetchedBalance = "TZS $formattedBalance";
  //     setState(() {
  //       _balance = fetchedBalance;
  //     });
  //   } else {
  //     print('Failed to fetch balance');
  //   }
  // }

  void _toggleTextVisibility() async {
    if (!_isTextVisible) {
      await _fetchBalance();
    }
    setState(() {
      _isTextVisible = !_isTextVisible;
    });
  }

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
          "Wallet",
          style: semibold18White,
        ),
      ),
      body: ListView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(
            fixPadding * 2.0, fixPadding, fixPadding * 2.0, fixPadding * 2.0),
        children: [
          topImage(size),
          balanceBox(),
        ],
      ),
    );
  }

  topImage(Size size) {
    return Image.asset(
      "assets/wallet/credit card.png",
      height: size.height * 0.23,
    );
  }

  balanceBox() {
    return Container(
      width: double.maxFinite,
      padding: const EdgeInsets.symmetric(
          horizontal: fixPadding * 1.4, vertical: fixPadding * 3.5),
      decoration: BoxDecoration(
        color: whiteColor,
        borderRadius: BorderRadius.circular(10.0),
        boxShadow: [
          BoxShadow(
            color: blackColor.withOpacity(0.08),
            blurRadius: 15.0,
            offset: const Offset(0, 5),
          )
        ],
      ),
      child: Column(
        children: [
          if (_isLoading) // Check if it is loading
            const CircularProgressIndicator() // Show loading indicator
          else
            Text(
              _isTextVisible ? _balance : "******",
              style: medium30Primary,
            ),
          // Text(
          //   _isTextVisible ? _balance : "******",
          //   style: medium30Primary,
          // ),
          ElevatedButton(
            onPressed: _toggleTextVisibility,
            child: Text(_isTextVisible ? 'Hide Balance' : 'Show Balance'),
          ),
          heightSpace,
          const Text(
            "Available balance",
            style: medium18Grey,
          ),
          heightSpace,
          height5Space,
          optionWidget(
              Mdi.swap_vertical, "Transaction", "View all transaction list",
              () {
            Navigator.pushNamed(context, '/walletTransaction');
          }),
          heightSpace,
          heightSpace,
          optionWidget(
              Mdi.wallet_add_outline, "Add money", "You can easily add money",
              () {
            Navigator.pushNamed(context, '/addAndSendMoney',
                arguments: {"id": 0});
          }),
        ],
      ),
    );
  }

  optionWidget(String icon, String title, String subTitle, Function() onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.maxFinite,
        padding: const EdgeInsets.symmetric(
            horizontal: fixPadding, vertical: fixPadding * 1.6),
        decoration: BoxDecoration(
          color: whiteColor,
          borderRadius: BorderRadius.circular(10.0),
          boxShadow: [
            BoxShadow(
              color: blackColor.withOpacity(0.1),
              blurRadius: 6.0,
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              height: 40.0,
              width: 40.0,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: whiteColor,
                boxShadow: [
                  BoxShadow(
                    color: blackColor.withOpacity(0.15),
                    blurRadius: 6.0,
                  )
                ],
              ),
              alignment: Alignment.center,
              child: Iconify(
                icon,
                size: 22.0,
                color: secondaryColor,
              ),
            ),
            widthSpace,
            width5Space,
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: semibold16Black33,
                  ),
                  height5Space,
                  Text(
                    subTitle,
                    style: medium14Grey,
                  )
                ],
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios,
              color: blackColor,
              size: 20.0,
            )
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:rc_fl_gopoolar/theme/theme.dart';

class AddAndSendMoneyScreen extends StatefulWidget {
  const AddAndSendMoneyScreen({super.key});

  @override
  State<AddAndSendMoneyScreen> createState() => _AddAndSendMoneyScreenState();
}

class _AddAndSendMoneyScreenState extends State<AddAndSendMoneyScreen> {
  String selectedValue = 'Select Network';
  List<String> dropdownItems = [
    'Select Network',
    'Airtel Money',
    'HaloPesa',
    'M-Pesa',
    'Tigo Pesa'
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
        title: Text(
          id == 0 ? "Deposit money" : "Send to bank",
          style: semibold18White,
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(fixPadding * 2.0),
        physics: const BouncingScrollPhysics(),
        children: [
          Image.asset(
            "assets/wallet/credit card.png",
            height: size.height * 0.23,
          ),
          heightSpace,
          heightSpace,
          heightSpace,
          amountField(id),
          heightSpace,
          heightSpace,
          continueButton(id),
        ],
      ),
    );
  }

  continueButton(id) {
    return GestureDetector(
      onTap: () {
        /*id == 0
            ? Navigator.pushNamed(context, '/paymentSuccess')
            : Navigator.pushNamed(context, '/bankInformation');*/
        Navigator.pushNamed(context, '/paymentSuccess', arguments: {"id": 0});
      },
      child: Container(
        width: double.maxFinite,
        padding: const EdgeInsets.symmetric(
            vertical: fixPadding * 1.4, horizontal: fixPadding * 2.0),
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
          "Continue",
          style: bold18White,
        ),
      ),
    );
  }

  amountField(id) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          id == 0 ? "Add amount" : "Add amount to send",
          style: semibold15Black33,
        ),
        const SizedBox(
          height: 10,
        ),
        Container(
          width: double.infinity, // Set width to full width
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10.0),
            color: whiteColor,
            boxShadow: [
              BoxShadow(
                color: blackColor.withOpacity(0.15),
                blurRadius: 6.0,
              ),
            ],
          ),
          child: DropdownButtonHideUnderline(
            // Hide the default underline
            child: DropdownButton<String>(
              value: selectedValue,
              onChanged: (newValue) {
                setState(() {
                  selectedValue = newValue!;
                });
              },
              items: dropdownItems.map((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Row(
                    // You can modify this to include images
                    children: [
                      // Add your image widget here if needed
                      const SizedBox(width: 8), // Adjust spacing
                      Text(value),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
        ),
        const SizedBox(
          height: 10,
        ),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10.0),
            color: whiteColor,
            boxShadow: [
              BoxShadow(
                color: blackColor.withOpacity(0.15),
                blurRadius: 6.0,
              )
            ],
          ),
          child: TextField(
            style: semibold15Black33,
            cursorColor: primaryColor,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              border: InputBorder.none,
              hintText: id == 0 ? "Enter Phone Number" : "Enter amount to send",
              hintStyle: medium15Grey,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: fixPadding,
                vertical: fixPadding * 1.5,
              ),
              prefixText: "255 ",
              prefixStyle: semibold15Black33,
              isDense: true,
            ),
          ),
        ),
        const SizedBox(
          height: 10,
        ),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10.0),
            color: whiteColor,
            boxShadow: [
              BoxShadow(
                color: blackColor.withOpacity(0.15),
                blurRadius: 6.0,
              )
            ],
          ),
          child: TextField(
            style: semibold15Black33,
            cursorColor: primaryColor,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              border: InputBorder.none,
              hintText:
                  id == 0 ? "Enter amount to add" : "Enter amount to send",
              hintStyle: medium15Grey,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: fixPadding,
                vertical: fixPadding * 1.5,
              ),
              prefixText: "TZS ",
              prefixStyle: semibold15Black33,
              isDense: true,
            ),
          ),
        ),
      ],
    );
  }
}

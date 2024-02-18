import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

void pleaseWaitDialog(BuildContext context) {
  showDialog(
    barrierDismissible: false,
    context: context,
    builder: (BuildContext context) {
      return Dialog(
        backgroundColor: Colors.transparent,
        elevation: 0,
        child: Center(
          child: LoadingAnimationWidget.staggeredDotsWave(
            color: Colors.white,
            size: 50,
          ),
        ),
      );
    },
  );
}

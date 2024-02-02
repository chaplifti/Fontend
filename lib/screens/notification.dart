import 'package:flutter/material.dart';

class NotificationDialog extends StatefulWidget {
  final String message;
  final IconData icon;
  final Color iconColor;

  const NotificationDialog(
      {Key? key,
      required this.message,
      required this.icon,
      required this.iconColor})
      : super(key: key);

  @override
  // ignore: library_private_types_in_public_api
  _NotificationDialogState createState() => _NotificationDialogState();
}

class _NotificationDialogState extends State<NotificationDialog>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _bounceAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.7),
      ),
    );

    _bounceAnimation = Tween<double>(
      begin: 1.0,
      end: 1.2,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.7, 1.0, curve: Curves.bounceOut),
      ),
    );

    // Start the animation when the dialog is shown
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Material(
        type: MaterialType.transparency,
        child: ScaleTransition(
          scale: _scaleAnimation,
          child: AlertDialog(
            backgroundColor: const Color(0xFFEBF7FE),
            contentPadding: const EdgeInsets.all(20.0),
            title: Container(
              alignment: Alignment.center,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  AnimatedBuilder(
                    animation: _bounceAnimation,
                    builder: (context, child) {
                      return Transform.scale(
                        scale: _bounceAnimation.value,
                        child: child,
                      );
                    },
                    child: SizedBox(
                      width: 80.0,
                      height: 80.0,
                      child: Icon(
                        widget.icon,
                        color: widget.iconColor,
                        size: 80.0,
                      ),
                    ),
                  ),
                  const SizedBox(height: 15.0),
                  Text(
                    textAlign: TextAlign.center,
                    widget.message,
                    style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF02509C)),
                  ),
                ],
              ),
            ),
            // content: Text(
            //   'You have a new message!',
            //   style: TextStyle(fontSize: 18.0),
            // ),
            actions: const <Widget>[
              // TextButton(
              //   onPressed: () {
              //     Navigator.of(context).pop(); // Close the dialog
              //   },
              //   child: Text(
              //     'Close',
              //     style: TextStyle(
              //       fontSize: 20.0,
              //       color: Colors.blue,
              //     ),
              //   ),
              // ),
            ],
          ),
        ),
      ),
    );
  }
}

// Contributed by: Tong Qian Ru

import 'package:flutter/material.dart';

class HomeButton extends StatefulWidget {
  const HomeButton({Key? key}) : super(key: key);

  @override
  _HomeButtonState createState() => _HomeButtonState();
}

class _HomeButtonState extends State<HomeButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity, // Takes full width
      child: GestureDetector(
        behavior: HitTestBehavior.opaque, // Makes entire area tappable
        onTapDown: (_) => setState(() => _isPressed = true),
        onTapUp: (_) => setState(() => _isPressed = false),
        onTapCancel: () => setState(() => _isPressed = false),
        onTap: () {
          Navigator.pushNamedAndRemoveUntil(context, '/home', (route) => false);
        },
        child: Image.asset(
          _isPressed
              ? 'assets/images/home_click.png'
              : 'assets/images/home.png',
          width: double.infinity, // Full width
          height: 60, // Fixed height
          fit: BoxFit.fill, // Stretch to fill width
        ),
      ),
    );
  }
}

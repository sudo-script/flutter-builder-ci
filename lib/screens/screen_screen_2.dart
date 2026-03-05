import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class Screen2Screen extends StatefulWidget {
  const Screen2Screen({super.key});

  @override
  State<Screen2Screen> createState() => _Screen2ScreenState();
}

class _Screen2ScreenState extends State<Screen2Screen> {
  // No dynamic state variables

  // No controllers









  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Stack(
          children: [
            Positioned(
              left: 56,
              top: 224,
              child: Text('toow', style: TextStyle(fontSize: 40.0, color: const Color(0xFF2C6ABD))),
            )
          ],
        ),
      ),
    );
  }
}
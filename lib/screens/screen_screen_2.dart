import 'package:flutter/material.dart';

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
              left: 128,
              top: 232,
              child: SizedBox(
              width: 120,
              child: GestureDetector(
                onTap: null,
                child: Text('screenwto', style: TextStyle(fontSize: 30.0, color: const Color(0xFFCE441F))),
              ),
            ),
            )
          ],
        ),
      ),
    );
  }
}
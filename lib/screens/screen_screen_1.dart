import 'package:flutter/material.dart';

class Screen1Screen extends StatefulWidget {
  const Screen1Screen({super.key});

  @override
  State<Screen1Screen> createState() => _MainScreenState();
}

class _Screen1ScreenState extends State<Screen1Screen> {
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
              left: 96,
              top: 336,
              child: SizedBox(
              width: 200,
              child: GestureDetector(
                onTap: null,
                child: Text('', style: TextStyle(fontSize: 16, color: const Color(0xFF000000))),
              ),
            ),
            )
          ],
        ),
      ),
    );
  }
}
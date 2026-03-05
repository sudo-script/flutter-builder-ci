import 'package:flutter/material.dart';

class Screen1Screen extends StatefulWidget {
  const Screen1Screen({super.key});

  @override
  State<Screen1Screen> createState() => _Screen1ScreenState();
}

class _Screen1ScreenState extends State<Screen1Screen> {
  // No dynamic state variables

  // No controllers





  void _handleButton_1Tap() {
    Navigator.pushNamed(context, '/screen2');
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Stack(
          children: [
            Positioned(
              left: 80,
              top: 272,
              child: SizedBox(
              width: 232, height: 96,
              child: ElevatedButton(
                onPressed: true ? _handleButton_1Tap() : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF3B4046),
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                child: Text('Button', style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600)),
              ),
            ),
            )
          ],
        ),
      ),
    );
  }
}
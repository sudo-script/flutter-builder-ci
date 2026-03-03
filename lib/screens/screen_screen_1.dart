import 'package:flutter/material.dart';

class Screen1Screen extends StatelessWidget {
  const Screen1Screen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Stack(
          children: [
            Positioned(
              left: 72, top: 240,
              child: Text(
                'label',
                style: TextStyle(fontSize: 16, color: const Color(0xFF1A1B1D)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

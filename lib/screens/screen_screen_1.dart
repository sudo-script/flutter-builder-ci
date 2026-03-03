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
              left: 104, top: 368,
              child: Text(
                'Text',
                style: TextStyle(fontSize: 16, color: const Color(0xFF000000)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

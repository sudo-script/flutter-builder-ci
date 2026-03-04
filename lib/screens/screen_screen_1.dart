import 'package:flutter/material.dart';

class Screen1Screen extends StatefulWidget {
  const Screen1Screen({super.key});

  @override
  State<Screen1Screen> createState() => _Screen1ScreenState();
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
              left: 64,
              top: 280,
              child: SizedBox(
              width: 200, height: 48,
              child: Card(
                elevation: 4.0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                child: InkWell(
                  onTap: null,
                  borderRadius: BorderRadius.circular(8),
                  child: const Padding(padding: EdgeInsets.all(16), child: SizedBox.shrink()),
                ),
              ),
            ),
            ),
            Positioned(
              left: 120,
              top: 312,
              child: SizedBox(
              width: 200,
              child: GestureDetector(
                onTap: null,
                child: Text('text inside', style: TextStyle(fontSize: 24, color: const Color(0xFFFAFAFA))),
              ),
            ),
            )
          ],
        ),
      ),
    );
  }
}
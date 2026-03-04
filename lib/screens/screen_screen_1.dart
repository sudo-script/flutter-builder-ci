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
              top: 264,
              child: SizedBox(
              width: 248, height: 128,
              child: Card(
                elevation: 4.0,
                color: const Color(0xFFF6D92F),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                child: InkWell(
                  onTap: null,
                  borderRadius: BorderRadius.circular(8),
                  child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Center(
                    child: Text(
                      'tete',
                      style: TextStyle(
                        fontSize: 40,
                        color: const Color(0xFFFFFFFF),
                      ),
                    ),
                  ),
                ),
                ),
              ),
            ),
            )
          ],
        ),
      ),
    );
  }
}
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class Screen1Screen extends StatefulWidget {
  const Screen1Screen({super.key});

  @override
  State<Screen1Screen> createState() => _Screen1ScreenState();
}

class _Screen1ScreenState extends State<Screen1Screen> {
  // No dynamic state variables

  // No controllers





  void _handleButton_1Tap() {
    context.go('/screen_2');
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Stack(
          children: [
            Positioned(
              left: 152,
              top: 184,
              child: SizedBox(
                width: 112, height: 272,
                child: ElevatedButton(
                  onPressed: () { _handleButton_1Tap(); },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1E5FB5),
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
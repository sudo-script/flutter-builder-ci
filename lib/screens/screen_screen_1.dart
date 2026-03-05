import 'package:flutter/material.dart';

class Screen1Screen extends StatefulWidget {
  const Screen1Screen({super.key});

  @override
  State<Screen1Screen> createState() => _Screen1ScreenState();
}

class _Screen1ScreenState extends State<Screen1Screen> {
  String text_1_text = 'furst';

  // No controllers

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 2000), () {
    if (mounted) { setState(() { text_1_text = 'mew'; }); }
  });
  }







  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Stack(
          children: [
            Positioned(
              left: 120,
              top: 192,
              child: SizedBox(
              width: 160,
              child: GestureDetector(
                onTap: null,
                child: Text(text_1_text, style: TextStyle(fontSize: 16.0, color: const Color(0xFFA18AEC))),
              ),
            ),
            )
          ],
        ),
      ),
    );
  }
}
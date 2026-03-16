import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class Screen1Screen extends StatefulWidget {
  const Screen1Screen({super.key});

  @override
  State<Screen1Screen> createState() => _Screen1ScreenState();
}

class _Screen1ScreenState extends State<Screen1Screen> {
  String text_1_text = 'heh';

  // No controllers

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 3000), () {
    if (mounted) { setState(() { text_1_text = 'wow'; }); }
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
              left: 152,
              top: 184,
              child: Text(text_1_text, style: TextStyle(fontSize: 16.0, color: const Color(0xFF34373B))),
            )
          ],
        ),
      ),
    );
  }
}
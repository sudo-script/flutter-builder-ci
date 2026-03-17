import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class Screen1Screen extends StatefulWidget {
  const Screen1Screen({super.key});

  @override
  State<Screen1Screen> createState() => _Screen1ScreenState();
}

class _Screen1ScreenState extends State<Screen1Screen> {
  String text_2_text = 'contact me: 99999999';

  // No controllers

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 5000), () {
    if (mounted) { setState(() { text_2_text = 'kumar'; }); }
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
              left: 168,
              top: 520,
              child: Text(text_2_text, style: TextStyle(fontSize: 16.0, color: const Color(0xFF080809))),
            ),
            Positioned(
              left: 272,
              top: 120,
              child: SizedBox(
                width: 80, height: 80,
                child: GestureDetector(
                  onTap: null,
                  child: Opacity(
                    opacity: 1.0,
                    child: '' != '' && ''.isNotEmpty
                      ? Image.network('', width: 80, height: 80, fit: BoxFit.cover)
                      : Container(color: Colors.grey.shade200, child: const Icon(Icons.image, size: 48, color: Colors.grey)),
                  ),
                ),
              ),
            ),
            Positioned(
              left: 128,
              top: 200,
              child: Text('chandan', style: TextStyle(fontSize: 16.0, color: const Color(0xFFE2E8F0))),
            )
          ],
        ),
      ),
    );
  }
}
import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Stack(
          children: [
            Positioned(
              left: 56.0, top: 448.0,
              child: Image.asset(
                  'assets/images/scatter_best_fit.png',
                  width: 248.0, height: 200.0,
                  fit: BoxFit.cover,
                ),
            ),
          ],
        ),
      ),
    );
  }
}


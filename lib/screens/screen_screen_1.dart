import 'package:flutter/material.dart';

class Screen1Screen extends StatelessWidget {
  const Screen1Screen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Text('Add components to get started', style: TextStyle(fontSize: 18, color: Colors.grey.shade400)),
      ),
    );
  }
}
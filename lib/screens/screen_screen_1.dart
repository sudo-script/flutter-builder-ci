import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:go_router/go_router.dart';

class Screen1Screen extends StatefulWidget {
  const Screen1Screen({Key? key}) : super(key: key);

  @override
  State<Screen1Screen> createState() => _Screen1ScreenState();
}

class _Screen1ScreenState extends State<Screen1Screen> {
  String _label = 'Label';

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 4)).then((_) {
      if (mounted) {
        setState(() {
          _label = 'meow';
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned(
            left: 80,
            top: 232,
            child: SizedBox(
              width: 208,
              height: 24,
              child: Text(
                _label,
                style: const TextStyle(
                  fontSize: 24,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
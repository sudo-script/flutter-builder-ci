import 'package:flutter/material.dart';
import '../utils/image_helper.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late PageController _controller;
  int _page = 0;

  @override
  void initState() {
    super.initState();
    _controller = PageController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          PageView(
            controller: _controller,
            onPageChanged: (index) => setState(() => _page = index),
            children: [
              SizedBox.expand(
                child: Stack(
                  children: [
                    Positioned(
                      left: 96,
                      top: 320,
                      width: 232,
                      height: 352,
                      child: Image.asset(
                        'assets/images/midjourney_aiart_aiartcommunity_animeart.jpg',
                        fit: BoxFit.cover,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox.expand(
                child: Stack(
                  children: [
                    Positioned(
                      left: 56,
                      top: 224,
                      width: 224,
                      height: 520,
                      child: Image.asset(
                        'assets/images/midjourney_aiart_aiartcommunity_animeart_2.jpg',
                        fit: BoxFit.cover,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          Positioned(
            bottom: 40,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(2, (index) {
                final isActive = _page == index;
                return Container(
                  width: isActive ? 10 : 8,
                  height: isActive ? 10 : 8,
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  decoration: BoxDecoration(
                    color: isActive
                        ? const Color(0xFF6366F1)
                        : const Color(0xFF374151),
                    shape: BoxShape.circle,
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }
}
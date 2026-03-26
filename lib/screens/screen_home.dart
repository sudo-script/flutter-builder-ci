import 'package:flutter/material.dart';
import '../utils/image_helper.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final PageController _ctrl = PageController();
  int _page = 0;

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: PageView(
        controller: _ctrl,
        onPageChanged: (i) => setState(() => _page = i),
        children: [
          SizedBox.expand(
            child: Stack(
              children: [
                Positioned(
                  left: 48,
                  top: 160,
                  width: 272,
                  height: 400,
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
                  left: 40,
                  top: 168,
                  width: 272,
                  height: 456,
                  child: Image.asset(
                    'assets/images/midjourney_aiart_aiartcommunity_animeart.jpg',
                    fit: BoxFit.cover,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
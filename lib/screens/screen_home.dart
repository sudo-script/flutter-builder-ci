import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
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
                  left: 96,
                  top: 320,
                  width: 232,
                  height: 376,
                  child: Container(
                    color: Colors.transparent,
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
                  top: 80,
                  width: 272,
                  height: 352,
                  child: Container(
                    color: Colors.transparent,
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
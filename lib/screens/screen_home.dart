import 'package:flutter/material.dart';
import '../utils/image_helper.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final PageController _ctrl = PageController(initialPage: 0);
  int _page = 0;

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _onPageChanged(int page) {
    setState(() {
      _page = page;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: PageView(
        controller: _ctrl,
        onPageChanged: _onPageChanged,
        children: <Widget>[
          PageOne(currentIndex: _page),
          PageTwo(),
        ],
      ),
    );
  }
}

class PageOne extends StatelessWidget {
  final int currentIndex;

  PageOne({required this.currentIndex});

  @override
  Widget build(BuildContext context) {
    return SizedBox.expand(
      child: Stack(
        children: [
          Positioned(
            left: 40,
            top: 336,
            width: 304,
            height: 200,
            child: SizedBox(
              width: 304,
              height: 200,
              child: Image.asset(
                'assets/images/loss_vs_iterations.png',
                fit: BoxFit.cover,
              ),
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 20,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(2, (index) {
                bool isSelected = index == currentIndex;
                return Container(
                  width: isSelected ? 12 : 8,
                  height: isSelected ? 12 : 8,
                  margin: EdgeInsets.symmetric(horizontal: 4),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isSelected ? Colors.blue : Colors.grey,
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

class PageTwo extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SizedBox.expand(
      child: Stack(
        children: [
          Positioned(
            left: 64,
            top: 112,
            width: 256,
            height: 528,
            child: Container(
              color: Colors.transparent,
            ),
          ),
        ],
      ),
    );
  }
}
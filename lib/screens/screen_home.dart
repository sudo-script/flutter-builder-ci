import 'package:flutter/material.dart';
import '../utils/image_helper.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);
  @override
  _HomeScreenState createState() => _HomeScreenState();
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
        children: const [
          PageOneWidget(),
          PageTwoWidget(),
        ],
      ),
    );
  }
}

class PageOneWidget extends StatelessWidget {
  const PageOneWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox.expand(
      child: Stack(
        children: [
          Positioned(
            left: 96,
            top: 320,
            width: 232,
            height: 376,
            child: Image.asset(
              'assets/images/☁️ ..... #midjourney #aiart #aiartcommunity #animeart #animeartist #niji #digitalart #pokemon #a (1).jpg',
              fit: BoxFit.cover,
            ),
          ),
        ],
      ),
    );
  }
}

class PageTwoWidget extends StatelessWidget {
  const PageTwoWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox.expand(
      child: Stack(
        children: [
          Positioned(
            left: 40,
            top: 120,
            width: 272,
            height: 352,
            child: Image.asset(
              'assets/images/1354791.jpeg',
              fit: BoxFit.cover,
            ),
          ),
        ],
      ),
    );
  }
}
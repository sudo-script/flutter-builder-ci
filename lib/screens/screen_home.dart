import 'package:flutter/material.dart';
import '../utils/image_helper.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late final PageController _pageController;
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _pageController.addListener(() {
      final page = _pageController.page?.round() ?? 0;
      if (page != _currentPage) {
        setState(() {
          _currentPage = page;
        });
      }
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Widget _buildPageIndicator() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(
        2,
        (index) => AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          margin: const EdgeInsets.symmetric(horizontal: 4.0),
          width: 8.0,
          height: 8.0,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: _currentPage == index ? Colors.black : Colors.grey,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          PageView.builder(
            controller: _pageController,
            itemCount: 2,
            itemBuilder: (context, index) {
              switch (index) {
                case 0:
                  return const PageOne();
                case 1:
                  return const PageTwo();
                default:
                  return const SizedBox.shrink();
              }
            },
          ),
          Positioned(
            bottom: 20.0,
            left: 0,
            right: 0,
            child: Center(
              child: _buildPageIndicator(),
            ),
          ),
        ],
      ),
    );
  }
}

class PageOne extends StatelessWidget {
  const PageOne({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final image = Image.asset(
      'assets/images/☁️ ..... #midjourney #aiart #aiartcommunity #animeart #animeartist #niji #digitalart #pokemon #a (3).jpg',
      fit: BoxFit.cover,
    );

    return Scaffold(
      body: Stack(
        children: [
          Positioned(
            left: 80,
            top: 168,
            width: 240,
            height: 424,
            child: image,
          ),
        ],
      ),
    );
  }
}

class PageTwo extends StatelessWidget {
  const PageTwo({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final image = Image.asset(
      'assets/images/☁️ ..... #midjourney #aiart #aiartcommunity #animeart #animeartist #niji #digitalart #pokemon #a (2).jpg',
      fit: BoxFit.cover,
    );

    return Scaffold(
      body: Stack(
        children: [
          Positioned(
            left: 56,
            top: 148,
            width: 280,
            height: 496,
            child: image,
          ),
        ],
      ),
    );
  }
}
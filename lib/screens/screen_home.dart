import 'package:flutter/material.dart';
import '../utils/image_helper.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _pageController.addListener(() {
      final int next = _pageController.page?.round() ?? 0;
      if (_currentPage != next) {
        setState(() {
          _currentPage = next;
        });
      }
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Widget _buildDots() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(2, (index) {
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: _currentPage == index ? Colors.black : Colors.grey,
          ),
        );
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        PageView.builder(
          controller: _pageController,
          itemCount: 2,
          itemBuilder: (context, index) {
            return index == 0 ? const PageOne() : const PageTwo();
          },
        ),
        Positioned(
          bottom: 16,
          left: 0,
          right: 0,
          child: Align(
            alignment: Alignment.center,
            child: _buildDots(),
          ),
        ),
      ],
    );
  }
}

class PageOne extends StatelessWidget {
  const PageOne({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topCenter,
      child: Stack(
        children: const [
          Positioned(
            left: 96,
            top: 320,
            width: 216,
            height: 432,
            child: Image(
              image: AssetImage(
                'assets/images/☁️ ..... #midjourney #aiart #aiartcommunity #animeart #animeartist #niji #digitalart #pokemon #a (3).jpg',
              ),
              fit: BoxFit.cover,
            ),
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
    return Align(
      alignment: Alignment.topCenter,
      child: Stack(
        children: const [
          Positioned(
            left: 64,
            top: 172,
            width: 264,
            height: 504,
            child: Image(
              image: AssetImage(
                'assets/images/☁️ ..... #midjourney #aiart #aiartcommunity #animeart #animeartist #niji #digitalart #pokemon #a.jpg',
              ),
              fit: BoxFit.cover,
            ),
          ),
        ],
      ),
    );
  }
}
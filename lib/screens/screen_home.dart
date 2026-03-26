import 'package:flutter/material.dart';
import '../utils/image_helper.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: PageView.builder(
            controller: _pageController,
            itemCount: 2,
            onPageChanged: (index) {
              setState(() {
                _currentPage = index;
              });
            },
            itemBuilder: (context, index) {
              if (index == 0) {
                return const PageOneWidget();
              } else {
                return const PageTwoWidget();
              }
            },
          ),
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(2, (index) {
            return Container(
              width: 8,
              height: 8,
              margin: const EdgeInsets.symmetric(horizontal: 4),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _currentPage == index ? Colors.black : Colors.grey,
              ),
            );
          }),
        ),
        const SizedBox(height: 16),
      ],
    );
  }
}

class PageOneWidget extends StatelessWidget {
  const PageOneWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 844,
      child: Stack(
        children: [
          Positioned(
            left: 80,
            top: 168,
            child: Image.asset(
              'assets/images/midjourney_aiart_aiartcommunity_animeart_animeartist_niji_digitalart_pokemon_a_3.jpg',
              width: 240,
              height: 424,
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
    return SizedBox(
      width: double.infinity,
      height: 844,
      child: Stack(
        children: [
          Positioned(
            left: 56,
            top: 148,
            child: Image.asset(
              'assets/images/midjourney_aiart_aiartcommunity_animeart_animeartist_niji_digitalart_pokemon_a_2.jpg',
              width: 280,
              height: 496,
              fit: BoxFit.cover,
            ),
          ),
        ],
      ),
    );
  }
}
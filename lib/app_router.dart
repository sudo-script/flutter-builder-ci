import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'screens/screen_screen_1.dart';
import 'screens/screen_screen_2.dart';

abstract class AppRouter {
  AppRouter._();

  static final GoRouter router = GoRouter(
    initialLocation: '/screen_1',
    debugLogDiagnostics: false,
    routes: [
    GoRoute(
      path: '/screen_1',
      name: 'Screen1Screen',
      builder: (context, state) => const Screen1Screen(),
    ),
    GoRoute(
      path: '/screen_2',
      name: 'Screen2Screen',
      builder: (context, state) => const Screen2Screen(),
    ),
    ],
    errorBuilder: (context, state) => const _ErrorScreen(),
  );
}

class _ErrorScreen extends StatelessWidget {
  const _ErrorScreen();
  @override
  Widget build(BuildContext context) =>
      const Scaffold(body: Center(child: Text('Page not found')));
}

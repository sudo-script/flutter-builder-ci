import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'screens/screen_home.dart';

abstract class AppRouter {
  AppRouter._();

  static final GoRouter router = GoRouter(
    initialLocation: '/home',
    debugLogDiagnostics: false,
    routes: [
    GoRoute(
      path: '/home',
      name: 'HomeScreen',
      builder: (context, state) => HomeScreen(),
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

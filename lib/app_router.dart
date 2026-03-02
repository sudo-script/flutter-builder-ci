import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'screens/screen_screen_1.dart';

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
    ],
    errorBuilder: (context, state) => _ErrorScreen(error: state.error),
  );

  // Navigate from anywhere without a BuildContext
  static void go(String route) => router.go(route);
  static void push(String route) => router.push(route);
  static void pop() => router.pop();
}

class _ErrorScreen extends StatelessWidget {
  final Exception? error;
  const _ErrorScreen({this.error});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Page not found')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text(error?.toString() ?? 'Unknown error'),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: () => AppRouter.go('/screen_1'),
              child: const Text('Go Home'),
            ),
          ],
        ),
      ),
    );
  }
}

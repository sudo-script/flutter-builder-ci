import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'screens/screen_login.dart';
import 'screens/screen_dashboard.dart';
import 'screens/screen_add_task.dart';
import 'screens/screen_profile.dart';

abstract class AppRouter {
  AppRouter._();

  static final GoRouter router = GoRouter(
    initialLocation: '/login',
    debugLogDiagnostics: false,
    routes: [
    GoRoute(
      path: '/login',
      name: 'LoginScreen',
      builder: (context, state) => LoginScreen(),
    ),
    GoRoute(
      path: '/dashboard',
      name: 'DashboardScreen',
      builder: (context, state) => DashboardScreen(),
    ),
    GoRoute(
      path: '/add_task',
      name: 'AddTaskScreen',
      builder: (context, state) => AddTaskScreen(),
    ),
    GoRoute(
      path: '/profile',
      name: 'ProfileScreen',
      builder: (context, state) => ProfileScreen(),
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

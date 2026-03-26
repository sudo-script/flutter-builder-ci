import 'package:flutter/material.dart';
import 'app_router.dart';
import 'theme/app_theme.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyAppApp());
}

class MyAppApp extends StatelessWidget {
  const MyAppApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'My App',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      // No darkTheme — prevents black screen on dark-mode devices
      // The app uses a consistent light theme matching the designer canvas
      routerConfig: AppRouter.router,
    );
  }
}

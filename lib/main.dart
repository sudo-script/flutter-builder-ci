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
      darkTheme: AppTheme.light(), // Force light theme even on dark-mode devices
      themeMode: ThemeMode.light,  // Never use system dark mode — prevents black screen
      routerConfig: AppRouter.router,
    );
  }
}

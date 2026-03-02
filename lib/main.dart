import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'app_router.dart';
import 'theme/app_theme.dart';
import 'screens/screen_screen_1.dart';

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
      darkTheme: AppTheme.dark(),
      themeMode: ThemeMode.system,
      routerConfig: AppRouter.router,
    );
  }
}

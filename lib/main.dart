import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'app_router.dart';
import 'theme/app_theme.dart';
import 'config/supabase_config.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // ── Supabase ─────────────────────────────────────────────
  if (SupabaseConfig.isConfigured) {
    try {
      await Supabase.initialize(
        url: SupabaseConfig.url,
        anonKey: SupabaseConfig.anonKey,
      );
    } catch (e) {
      debugPrint('Supabase init failed: $e');
    }
  }

  // ── Local notifications ───────────────────────────────────
  try {
    tz.initializeTimeZones();
    const initSettings = InitializationSettings(
      android: AndroidInitializationSettings('@mipmap/ic_launcher'),
      iOS: DarwinInitializationSettings(),
    );
    await FlutterLocalNotificationsPlugin().initialize(initSettings);
  } catch (e) {
    debugPrint('Notifications init failed: $e');
  }

  runApp(MyAppApp(supabaseReady: SupabaseConfig.isConfigured));
}

class MyAppApp extends StatelessWidget {
  final bool supabaseReady;
  const MyAppApp({super.key, this.supabaseReady = false});

  @override
  Widget build(BuildContext context) {
    if (!supabaseReady) {
      return MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light(),
        home: Scaffold(
          backgroundColor: const Color(0xFF1a1a2e),
          body: Center(child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
              const Icon(Icons.cloud_off, size: 64, color: Color(0xFF6366f1)),
              const SizedBox(height: 24),
              const Text('Supabase not configured',
                style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              const Text(
                'Open this project in Glassbox, go to the Backend tab, enter your Supabase credentials, then re-export.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Color(0xFF9ca3af), fontSize: 14, height: 1.5)),
              const SizedBox(height: 8),
              const Text('Settings -> API -> Project URL + anon key',
                textAlign: TextAlign.center,
                style: TextStyle(color: Color(0xFF6366f1), fontSize: 13)),
            ]),
          )),
        ),
      );
    }
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

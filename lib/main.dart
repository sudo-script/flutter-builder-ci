import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'app_router.dart';
import 'theme/app_theme.dart';
import 'config/supabase_config.dart';

/// Global ScaffoldMessenger key — used by SupabaseHelper to surface
/// "Supabase isn't configured" toasts even when no widget context is
/// available (e.g. errors thrown in a fire-and-forget Future).
final GlobalKey<ScaffoldMessengerState> rootMessengerKey =
    GlobalKey<ScaffoldMessengerState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // ── Crash-resistance ──────────────────────────────────────
  // Any uncaught async exception (typical for unhandled Supabase network
  // calls) is logged but does NOT crash the app. Combined with
  // SupabaseHelper.safe, this means the user can always navigate the rest
  // of the app even when Supabase hasn't been wired up yet.
  PlatformDispatcher.instance.onError = (error, stack) {
    debugPrint('[uncaught] $error');
    return true;
  };
  FlutterError.onError = (details) {
    FlutterError.presentError(details);
  };

  // ── Supabase (always initialised) ────────────────────────
  // We initialise Supabase even when the user hasn't entered real
  // credentials at build time — using well-formed placeholder values —
  // so screen code that touches Supabase.instance.client doesn't blow
  // up with LateInitializationError. SupabaseConfig.isConfigured stays
  // false in that case, and SupabaseHelper.safe() catches the resulting
  // network failures and shows a friendly toast.
  try {
    await Supabase.initialize(
      url: SupabaseConfig.url,
      anonKey: SupabaseConfig.anonKey,
    );
  } catch (e) {
    debugPrint('Supabase init failed (continuing without): $e');
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

  runApp(const AdvApp());
}

class AdvApp extends StatelessWidget {
  const AdvApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Always boot into the real router. Missing Supabase credentials are
    // surfaced lazily by SupabaseHelper as a toast on the first failed
    // call, never as a full-screen gate that blocks the rest of the app.
    return MaterialApp.router(
      title: 'adv',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: ThemeMode.system,
      scaffoldMessengerKey: rootMessengerKey,
      routerConfig: AppRouter.router,
    );
  }
}

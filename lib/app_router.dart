import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'screens/screen_auth.dart';
import 'screens/screen_notes_list.dart';
import 'screens/screen_note_editor.dart';
import 'screens/screen_tag_manager.dart';
import 'screens/screen_trash.dart';
import 'screens/screen_settings.dart';

abstract class AppRouter {
  AppRouter._();

  static final GoRouter router = GoRouter(
    initialLocation: '/auth',
    debugLogDiagnostics: false,
    routes: [
    GoRoute(
      path: '/auth',
      name: 'AuthScreen',
      builder: (context, state) => AuthScreen(),
    ),
    GoRoute(
      path: '/notes_list',
      name: 'NotesListScreen',
      builder: (context, state) => NotesListScreen(),
    ),
    GoRoute(
      path: '/note_editor',
      name: 'NoteEditorScreen',
      builder: (context, state) => NoteEditorScreen(),
    ),
    GoRoute(
      path: '/tag_manager',
      name: 'TagManagerScreen',
      builder: (context, state) => TagManagerScreen(),
    ),
    GoRoute(
      path: '/trash',
      name: 'TrashScreen',
      builder: (context, state) => TrashScreen(),
    ),
    GoRoute(
      path: '/settings',
      name: 'SettingsScreen',
      builder: (context, state) => SettingsScreen(),
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
